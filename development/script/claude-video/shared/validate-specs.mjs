// shared/validate-specs.mjs
// Check every committed spec against specs/_schema.json plus the rules the
// schema cannot express.
//
// Worth having as its own step because a bad spec fails LATE and confusingly:
// a wrong selector surfaces as a Playwright timeout three minutes into a
// capture, and a missing narration on a hero spec surfaces as a silent skip in
// narrate.mjs. This catches both in under a second, before the browser starts.
//
//   node shared/validate-specs.mjs

import { readFileSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { paths, DEV_ORIGIN } from "./config.mjs";

const schema = JSON.parse(readFileSync(join(paths.specs, "_schema.json"), "utf8"));
const props = schema.properties;

let failures = 0;

const ACTIONS = schema.properties.segments.items.properties.beats.items.properties.action.enum;

for (const file of readdirSync(paths.specs).filter((f) => f.endsWith(".json") && !f.startsWith("_"))) {
  const spec = JSON.parse(readFileSync(join(paths.specs, file), "utf8"));
  const errs = [];

  for (const key of schema.required) if (!(key in spec)) errs.push(`missing required "${key}"`);
  // additionalProperties:false in the schema, so an unknown key is a typo — and
  // a typo'd key is silently ignored at runtime rather than erroring.
  for (const key of Object.keys(spec)) if (!(key in props)) errs.push(`unknown key "${key}"`);

  const segments = spec.segments ?? [];
  if (!segments.length) errs.push("no segments");

  let accents = 0;

  for (const [i, seg] of segments.entries()) {
    const where = `segment ${i} ("${seg.title ?? "?"}")`;
    for (const key of ["title", "route", "beats"]) {
      if (!(key in seg)) errs.push(`${where}: missing "${key}"`);
    }
    if (seg.route && !seg.route.startsWith("/")) errs.push(`${where}: route must be a path, not a URL`);
    if (seg.route && !seg.route.includes(spec.component)) {
      errs.push(`${where}: route "${seg.route}" does not mention ${spec.component}`);
    }

    const beats = seg.beats ?? [];
    if (beats.length < 2) errs.push(`${where}: ${beats.length} beats, need at least 2`);

    for (const beat of beats) {
      if (!beat.caption) errs.push(`${where}: a beat has no caption`);
      if (!ACTIONS.includes(beat.action)) errs.push(`${where}: unknown action "${beat.action}"`);
      if ((beat.caption ?? "").length > 48) errs.push(`${where}: caption over 48 chars: "${beat.caption}"`);

      // `theme` acts on the document; everything else needs a target.
      if (beat.action === "theme") {
        if (!["light", "dark"].includes(beat.value)) {
          errs.push(`${where}: theme beat value must be "light" or "dark", got "${beat.value}"`);
        }
        if (beat.selector) errs.push(`${where}: theme beat should not carry a selector`);
      } else if (!beat.selector) {
        errs.push(`${where}: "${beat.action}" beat needs a selector`);
      }

      if (["type", "paste", "key"].includes(beat.action) && !beat.value) {
        errs.push(`${where}: "${beat.action}" beat needs a value`);
      }
      if (beat.accent) accents += 1;
    }
  }

  // At most one accent beat per VIDEO, across all segments. Mint only reads as
  // "this is the moment" while it stays rare.
  if (accents > 1) errs.push(`${accents} accent beats across the video, at most 1`);

  if (spec.hero && !spec.narration) errs.push("hero:true requires narration");
  if (spec.narration && !spec.hero) errs.push("narration set but hero is false — it will never be spoken");
  if (spec.needs_markup) errs.push("needs_markup is true — selectors are placeholders, capture will time out");

  if (errs.length) failures += errs.length;
  const beats = segments.reduce((n, s) => n + (s.beats?.length ?? 0), 0);
  console.log(
    errs.length
      ? `  FAIL  ${file}\n          - ${errs.join("\n          - ")}`
      : `  ok    ${file}  (${segments.length} segments, ${beats} beats)`
  );
}

if (failures) {
  console.error(`\n${failures} problem(s). Fix the specs before capturing.\n`);
  process.exit(1);
}
