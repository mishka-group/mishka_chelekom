// shared/config.mjs
// Single source of truth for ports, paths and brand tokens.
// Templates read the same tokens so intro/outro/captions never drift.
//
// Layout: this file lives in shared/, one level below the package root. Specs
// and templates are shared inputs so they sit beside it; out/ is generated and
// belongs to the package, not to either track, so both free/ and gladia/ write
// to the SAME out/ tree. That is deliberate — gladia/ reuses the capture and
// the narration the free track already produced rather than re-recording them.

import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = dirname(fileURLToPath(import.meta.url));
export const PKG = dirname(ROOT);

// Browsers live in the package, not in ~/Library/Caches/ms-playwright. That
// shared cache is easy to end up owning as root (one `sudo npx playwright
// install`, ever) and then every later install fails with EACCES on __dirlock.
// Exported so each entry point can set PLAYWRIGHT_BROWSERS_PATH itself rather
// than depending on run.sh having exported it — otherwise `node capture.mjs`
// run directly silently resolves back to the broken global cache.
export const BROWSERS_PATH = join(PKG, ".playwright");

export const DEV_ORIGIN = process.env.CHELEKOM_DEV_ORIGIN ?? "http://localhost:4002";
export const DOCS_ORIGIN = "https://mishka.tools/chelekom/docs";

// One video per component now, so specs live in a flat specs/ directory and a
// spec's `segments` name the routes it visits. VARIANTS is gone with it — the
// showcase paths appear literally in each segment's `route`.
export const DOCS_SECTION = "headless";

export const paths = {
  specs: join(ROOT, "specs"),
  templates: join(ROOT, "templates"),
  raw: join(PKG, "out/raw"),
  frames: join(PKG, "out/frames"),
  vo: join(PKG, "out/vo"),
  final: join(PKG, "out/final"),
};

export const video = {
  // 1080p, not 720p. Playwright records VP8 at a bitrate it does not expose, so
  // the only lever on sharpness is giving it more pixels to spend them on —
  // fast full-page repaints (a form submit) were visibly mushy at 720p. Paired
  // with deviceScaleFactor 2 the page renders at 3840x2160 and is downsampled
  // into the recording, which supersamples away most aliasing.
  width: 1920,
  height: 1080,
  fps: 30,
  scheme: "dark", // showcase reads better dark; flip per-spec with "scheme"
};

// Design tokens. Kept deliberately narrow — mint appears exactly once per video,
// on the completion beat, so it still means something when it lands.
export const tokens = {
  ink: "#17131f", // deep aubergine-black, warmer than true black
  paper: "#f2ecf7", // pale lilac white
  signal: "#b48ead", // resting accent, muted mauve
  live: "#7bdcb5", // reserved: the "accepted" moment only
  dim: "#5c5170", // labels, meta, rules
  display: "'Inter Tight', system-ui, sans-serif",
  mono: "'JetBrains Mono', ui-monospace, monospace",
};

/** otp_field -> otp-field */
export const docsSlug = (component) => component.replaceAll("_", "-");

export const docsUrl = (component) =>
  `${DOCS_ORIGIN}/${DOCS_SECTION}/${docsSlug(component)}`;
