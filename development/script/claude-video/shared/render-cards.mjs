// shared/render-cards.mjs
// Records the HTML cards to video: one intro and one outro per component, plus
// one segment card per segment.
//
// Playwright already rasterises HTML at a fixed framerate, which is the only
// thing a dedicated card renderer would add. Keeping it here means the default
// path has no extra install, and one tool controls framerate and viewport for
// every piece — so the final concat can stream-copy instead of re-encoding.
//
// Exact duration is taken off the END of each recording (`-ss total-duration`)
// rather than the start, because the tail is deterministic — the context closes
// the moment the animation finishes — while startup jitter is not.

import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync, readFileSync, existsSync, rmSync } from "node:fs";
import { join } from "node:path";
import { paths, video, ROOT, BROWSERS_PATH } from "./config.mjs";
import { LOGO_VIEWBOX, LOGO_PATHS } from "./assets/logo.mjs";

// Must be set before playwright is loaded, hence the dynamic import below.
process.env.PLAYWRIGHT_BROWSERS_PATH ??= BROWSERS_PATH;
const { chromium } = await import("playwright");

const DURATION = { intro: 3.2, segment: 1.4, outro: 2.6 }; // must match the templates
const TAIL = 0.35; // held after the animation, then trimmed off

const probeDuration = (file) =>
  Number(
    execFileSync("ffprobe", [
      "-v", "error",
      "-show_entries", "format=duration",
      "-of", "default=noprint_wrappers=1:nokey=1",
      file,
    ])
      .toString()
      .trim()
  );

/** Every component that has been captured, with its segment manifest. */
function components() {
  if (!existsSync(paths.raw)) return [];
  return readdirSync(paths.raw)
    .map((component) => join(paths.raw, component, "spec.json"))
    .filter(existsSync)
    .map((f) => JSON.parse(readFileSync(f, "utf8")));
}

const specs = components();
if (!specs.length) {
  console.error("No captures found. Run capture.mjs first.");
  process.exit(1);
}

const browser = await chromium.launch();

/** Record one template to `<outDir>/<name>.mp4`, trimmed to an exact duration. */
async function card(template, name, duration, payload, outDir) {
  const tmp = join(outDir, `_${name}_raw`);
  rmSync(tmp, { recursive: true, force: true });
  mkdirSync(tmp, { recursive: true });

  const ctx = await browser.newContext({
    viewport: { width: video.width, height: video.height },
    recordVideo: { dir: tmp, size: { width: video.width, height: video.height } },
    deviceScaleFactor: 2,
  });
  const page = await ctx.newPage();
  await page.addInitScript(
    ([key, value, logo, scale]) => {
      window[key] = value;
      window.__LOGO = logo;
      // Applied by the template itself, not here: addInitScript runs before
      // document.documentElement exists, so assigning zoom at this point is a
      // silent no-op. `zoom` also needs a plain number — the obvious CSS
      // spelling (`calc(100vw / 1280)`) computes to 1, which left the card
      // rendering at 1280x720 in the top-left corner of a 1080p frame.
      window.__SCALE = scale;
    },
    [
      template === "segment" ? "__SEGMENT" : "__SPEC",
      payload,
      { viewBox: LOGO_VIEWBOX, paths: LOGO_PATHS },
      video.width / 1280,
    ]
  );
  await page.goto(`file://${join(ROOT, "templates", `${template}.html`)}`);

  // The cards flag themselves ready once webfonts are rasterised.
  await page
    .waitForFunction(() => document.body.dataset.ready === "1", null, { timeout: 15000 })
    .catch(() => console.warn(`  ! ${name}: font gate timed out, recording anyway`));

  await page.waitForTimeout(duration * 1000 + TAIL * 1000);
  await ctx.close();

  const raw = join(tmp, readdirSync(tmp).find((f) => f.endsWith(".webm")));
  const total = probeDuration(raw);
  const start = Math.max(0, total - duration - TAIL);

  execFileSync("ffmpeg", [
    "-y", "-loglevel", "error",
    "-ss", String(start), "-t", String(duration), "-i", raw,
    "-r", String(video.fps),
    "-s", `${video.width}x${video.height}`,
    "-c:v", "libx264", "-preset", "slow", "-crf", "16",
    "-pix_fmt", "yuv420p", "-an",
    join(outDir, `${name}.mp4`),
  ]);

  rmSync(tmp, { recursive: true, force: true });
}

for (const spec of specs) {
  const outDir = join(paths.frames, spec.component);
  mkdirSync(outDir, { recursive: true });

  await card("intro", "intro", DURATION.intro, spec, outDir);
  await card("outro", "outro", DURATION.outro, spec, outDir);

  for (const segment of spec.segments) {
    await card(
      "segment",
      `segment-${String(segment.index).padStart(2, "0")}`,
      DURATION.segment,
      { ...segment, total: spec.segments.length, component: spec.component },
      outDir
    );
  }

  console.log(`  ok  cards  ${spec.component}  (intro + ${spec.segments.length} segments + outro)`);
}

await browser.close();
