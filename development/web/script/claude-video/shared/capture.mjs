// shared/capture.mjs
// Records one webm per SEGMENT and writes a timeline.json beside it so the
// caption layer knows when each beat starts. Timing is measured, not guessed —
// that is why this step emits JSON rather than only video.
//
// A spec is one COMPONENT and produces one video. Its `segments` are the parts
// of that video: the headless showcase, the Base UI styling, the form examples.
// Each segment names its own route, so one video can walk several pages, and
// each gets a title card in the finished cut.
//
// Four things here are load-bearing and easy to get wrong:
//
// 1. THEME. Tailwind's `dark:` variant in this app is wired to
//    `[data-theme=dark]` (see @custom-variant in assets/css/app.css), NOT to
//    prefers-color-scheme. Playwright's `colorScheme` option only sets the
//    media query, so on its own it darkens the showcase chrome while leaving
//    every `dark:` utility light — the Base UI gallery alone has ~750 of them,
//    which is exactly why its colours looked wrong. The app reads
//    localStorage["phx:theme"] on boot, so we seed that (and the attribute
//    itself, to beat any first-paint flash) via addInitScript, which runs
//    before any page script.
//
// 2. THE `theme` ACTION. A beat can flip the page between light and dark
//    mid-take, so one video shows the component both ways. It writes the same
//    attribute the app's own toggle writes, rather than reloading.
//
// 3. LOAD WAIT. `networkidle` is the wrong signal for a LiveView page: the
//    socket keeps connections alive, so it burns seconds and usually ends at
//    its own timeout. We wait for the element the first beat needs instead —
//    the only thing that truly must exist before we act.
//
// 4. CARET. A blinking caret makes frames differ for no reason, so it is made
//    transparent.

import { mkdirSync, readdirSync, readFileSync, writeFileSync, renameSync, rmSync } from "node:fs";
import { join } from "node:path";
import { paths, video, DEV_ORIGIN, docsUrl, BROWSERS_PATH, tokens } from "./config.mjs";
import { LOGO_VIEWBOX, LOGO_PATHS } from "./assets/logo.mjs";

// Must be set before playwright loads; a static import would hoist above it.
process.env.PLAYWRIGHT_BROWSERS_PATH ??= BROWSERS_PATH;
const { chromium } = await import("playwright");

const only = process.argv.find((a) => a.startsWith("--only="))?.split("=")[1];

function loadSpecs() {
  const out = [];
  for (const file of readdirSync(paths.specs).filter((f) => f.endsWith(".json") && !f.startsWith("_"))) {
    const spec = JSON.parse(readFileSync(join(paths.specs, file), "utf8"));
    if (only && spec.component !== only) continue;
    out.push(spec);
  }
  return out;
}

const setTheme = (page, theme) =>
  page.evaluate((t) => {
    document.documentElement.setAttribute("data-theme", t);
    try {
      localStorage.setItem("phx:theme", t);
    } catch {
      /* storage disabled; the attribute is what actually styles the page */
    }
  }, theme);

/**
 * The element a keyboard beat should actually click.
 *
 * `${selector} input` is WRONG and cost 30s per beat: chelekom form components
 * render a HIDDEN input (data-part="value") for form submission, and on
 * otp_field it comes FIRST in the DOM — so .first() picked an unclickable node
 * and every type/paste on a NAMED field timed out. Fields without `name` have no
 * hidden input, which is why some beats worked and others did not.
 *
 * Prefer the component's declared slot part, fall back to a visible input, and
 * only then the element itself.
 */
async function typeTarget(page, selector) {
  const candidates = [`${selector} [data-part="input"]`, `${selector} input:visible`, selector];

  for (const sel of candidates) {
    const loc = page.locator(sel).first();
    if ((await loc.count()) && (await loc.isVisible().catch(() => false))) return loc;
  }

  return page.locator(selector).first();
}

async function runBeat(page, beat) {
  // `theme` acts on the document, not on an element, so it skips the locator
  // work entirely — giving it a dummy selector would just invite a timeout.
  if (beat.action === "theme") {
    await setTheme(page, beat.value);
    await page.waitForTimeout(beat.hold ?? 1400);
    return;
  }

  const el = page.locator(beat.selector).first();
  await el.scrollIntoViewIfNeeded({ timeout: 5000 });

  switch (beat.action) {
    case "settle":
      break;
    case "focus":
      await el.focus();
      break;
    case "hover":
      await el.hover();
      break;
    case "click":
      await el.click();
      break;
    case "key":
      await el.click();
      await page.keyboard.press(beat.value);
      break;
    case "type": {
      // Type through the keyboard rather than fill(): the component's own
      // auto-advance logic is the thing being demonstrated.
      //
      // But NOT via keyboard.type(text, {delay}) — that does not yield to the
      // page between keystrokes, so a component that moves focus asynchronously
      // (otp_field advances a slot per digit) silently loses characters. Measured
      // on the real showcase: "428913" arrived as "13" at 60ms and still only
      // "28913" at 300ms, and non-monotonically, so no fixed delay fixes it.
      //
      // Instead send one character and wait for focus to actually move before
      // sending the next. Components that do not move focus just fall through
      // the timeout and keep the natural cadence.
      await (await typeTarget(page, beat.selector)).click();
      // Let the click settle before the first key. The hook wires up focus
      // asynchronously, and a character sent into that gap is dropped — which is
      // why the LEADING digit went missing while the rest arrived. Measured on
      // the real showcase: the plain and alphanumeric fields need ~250ms, the
      // masked one (-webkit-text-security) still dropped at 400ms and only
      // became reliable at 600ms. Overridable per beat via `settle`.
      await page.waitForTimeout(beat.settle ?? 600);
      const delay = beat.charDelay ?? 170;

      for (const ch of beat.value) {
        const before = await page.evaluate(() => document.activeElement?.id ?? "");
        await page.keyboard.type(ch);
        await page
          .waitForFunction((prev) => (document.activeElement?.id ?? "") !== prev, before, { timeout: 500 })
          .catch(() => {});
        await page.waitForTimeout(delay);
      }
      break;
    }
    case "paste": {
      await (await typeTarget(page, beat.selector)).click();
      await page.evaluate((t) => navigator.clipboard.writeText(t), beat.value);
      await page.keyboard.press(process.platform === "darwin" ? "Meta+V" : "Control+V");
      break;
    }
    default:
      throw new Error(`Unknown action: ${beat.action}`);
  }

  await page.waitForTimeout(beat.hold ?? 900);
}

const specs = loadSpecs();
if (!specs.length) {
  console.error("No specs matched. Nothing to capture.");
  process.exit(1);
}

const browser = await chromium.launch();

for (const spec of specs) {
  const scheme = spec.scheme ?? video.scheme;
  rmSync(join(paths.raw, spec.component), { recursive: true, force: true });

  for (const [index, segment] of spec.segments.entries()) {
    const outDir = join(paths.raw, spec.component, String(index).padStart(2, "0"));
    mkdirSync(outDir, { recursive: true });

    const ctx = await browser.newContext({
      viewport: { width: video.width, height: video.height },
      recordVideo: { dir: outDir, size: { width: video.width, height: video.height } },
      colorScheme: scheme,
      deviceScaleFactor: 2,
      permissions: ["clipboard-read", "clipboard-write"],
      reducedMotion: "no-preference",
    });

    // Seed the app's own theme mechanism. Without this every `dark:` utility
    // stays light no matter what colorScheme above says.
    await ctx.addInitScript((theme) => {
      try {
        localStorage.setItem("phx:theme", theme);
      } catch {
        /* private mode — the attribute below still applies */
      }
      document.documentElement.setAttribute("data-theme", theme);
    }, scheme);

    ctx.setDefaultTimeout(5000);

    // Persistent corner mark on the footage itself. It has to be theme-aware
    // because a `theme` beat flips the page mid-take — a fixed colour would
    // vanish into one of the two backgrounds.
    await ctx.addInitScript(
      ([viewBox, pathData, dark, light]) => {
        const draw = () => {
          if (document.getElementById("chelekom-video-mark")) return;
          if (!document.body) return;
          const el = document.createElement("div");
          el.id = "chelekom-video-mark";
          el.setAttribute("aria-hidden", "true");
          el.innerHTML = `<svg viewBox="${viewBox}" fill="currentColor">${pathData}</svg>`;
          document.body.appendChild(el);

          const style = document.createElement("style");
          style.textContent = `
            #chelekom-video-mark {
              position: fixed; top: 22px; left: 22px;
              width: 34px; height: 34px;
              z-index: 2147483647; pointer-events: none;
              opacity: .42; color: ${dark};
            }
            #chelekom-video-mark svg { width: 100%; height: 100%; display: block; }
            :root:not([data-theme="dark"]) #chelekom-video-mark { color: ${light}; }
          `;
          document.head.appendChild(style);
        };
        document.addEventListener("DOMContentLoaded", draw);
        if (document.readyState !== "loading") draw();
      },
      [LOGO_VIEWBOX, LOGO_PATHS, tokens.paper, tokens.ink]
    );

    const page = await ctx.newPage();
    // Playwright begins writing the video when the page is created, so this is
    // the zero point the trim below is measured against.
    const recStart = Date.now();
    await page.goto(`${DEV_ORIGIN}${segment.route}`, { waitUntil: "domcontentloaded", timeout: 20000 });
    await page.addStyleTag({ content: "*{caret-color:transparent}" });

    // Wait for what the first beat needs, rather than for the network to fall
    // quiet — which on a LiveView page it does not.
    const firstSelector = segment.beats.find((b) => b.action !== "theme")?.selector;
    if (firstSelector) {
      await page
        .locator(firstSelector)
        .first()
        .waitFor({ state: "visible", timeout: 15000 })
        .catch(() => console.warn(`  ! ${spec.component}[${index}]: "${firstSelector}" never appeared`));
    }
    // Wait for LiveView to finish connecting. Acting before this means hooks
    // are not mounted yet — the OTP field takes keystrokes that go nowhere.
    await page
      .waitForFunction(() => window.liveSocket?.isConnected?.() === true, null, { timeout: 15000 })
      .catch(() => console.warn(`  ! ${spec.component}[${index}]: liveSocket never connected`));
    await page.waitForTimeout(400);

    const t0 = Date.now();
    // Everything before this point is page load; assemble.mjs cuts it out so
    // the viewer never watches the app boot.
    const leadMs = t0 - recStart;
    const timeline = [];

    for (const beat of segment.beats) {
      const start = Date.now() - t0;
      try {
        await runBeat(page, beat);
      } catch (err) {
        console.error(`  beat failed (${beat.selector}): ${err.message.split("\n")[0]}`);
        await page.waitForTimeout(beat.hold ?? 900);
      }
      timeline.push({
        caption: beat.caption,
        accent: beat.accent ?? false,
        startMs: start,
        endMs: Date.now() - t0,
      });
    }

    const durationMs = Date.now() - t0;
    await ctx.close();

    // Playwright names the file with a random hash; give it a stable name.
    const produced = readdirSync(outDir).find((f) => f.endsWith(".webm"));
    if (produced) renameSync(join(outDir, produced), join(outDir, "capture.webm"));

    writeFileSync(
      join(outDir, "timeline.json"),
      JSON.stringify(
        {
          component: spec.component,
          index,
          title: segment.title,
          subtitle: segment.subtitle ?? "",
          route: segment.route,
          leadMs,
          durationMs,
          beats: timeline,
        },
        null,
        2
      )
    );

    console.log(
      `  ok  ${spec.component}[${index}] ${segment.title}  ${(durationMs / 1000).toFixed(1)}s  (cut ${(leadMs / 1000).toFixed(1)}s of load)`
    );
  }

  // One manifest per component — what the cards and the assembler read.
  writeFileSync(
    join(paths.raw, spec.component, "spec.json"),
    JSON.stringify(
      {
        component: spec.component,
        title: spec.title ?? spec.component,
        tagline: spec.tagline ?? "",
        signature: spec.signature ?? "plain",
        docsUrl: docsUrl(spec.component),
        hero: spec.hero ?? false,
        segments: spec.segments.map((s, i) => ({ index: i, title: s.title, subtitle: s.subtitle ?? "" })),
      },
      null,
      2
    )
  );
}

await browser.close();
