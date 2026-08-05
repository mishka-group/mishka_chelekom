// shared/assemble.test.mjs — node --test
//
// Covers groupWords(), the only part of the word-synced caption path with real
// logic in it. Everything else in assemble.mjs shells out to ffmpeg and is
// verified by watching the output.
//
// The input is derived from the ACTUAL narration in the committed specs rather
// than from invented strings, so adding a hero component or rewording its
// narration exercises this test with new data automatically. Timings are
// synthesised (there is no API key in CI) but shaped like Gladia's real output:
// per-word start/end in ms after the conversion sync-captions.mjs performs, with
// realistic inter-word gaps and a sentence pause.

import test from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { groupWords, ass } from "./assemble.mjs";
import { paths, tokens } from "./config.mjs";

/** Every narration string committed in specs/, so new hero specs are auto-covered. */
function narrations() {
  const out = [];
  if (!existsSync(paths.specs)) return out;
  for (const f of readdirSync(paths.specs).filter((f) => f.endsWith(".json") && !f.startsWith("_"))) {
    const spec = JSON.parse(readFileSync(join(paths.specs, f), "utf8"));
    if (spec.narration) out.push({ id: spec.component, text: spec.narration });
  }
  return out;
}

/**
 * Shape a narration into Gladia-like word timings.
 * ~380ms per word, plus a 700ms pause after sentence-ending punctuation —
 * long enough to trip the gap rule, which is what makes the pause meaningful.
 */
function asWords(text) {
  let t = 0;
  return text.split(/\s+/).filter(Boolean).map((word) => {
    const dur = 240 + word.length * 18;
    const startMs = t;
    const endMs = t + dur;
    t = endMs + (/[.!?]$/.test(word) ? 700 : 90);
    return { word, startMs, endMs, confidence: 0.99 };
  });
}

const CORPUS = narrations();

test("specs actually carry narration to test against", () => {
  assert.ok(CORPUS.length > 0, "no spec declares `narration` — groupWords would be untested");
});

for (const { id, text } of CORPUS) {
  const words = asWords(text);

  test(`${id}: every word survives grouping, in order`, () => {
    const grouped = groupWords(words).map((l) => l.text).join(" ");
    assert.equal(grouped, words.map((w) => w.word).join(" "));
  });

  test(`${id}: lines respect the caption budget`, () => {
    for (const line of groupWords(words)) {
      assert.ok(
        line.text.length <= 48 || line.count === 1,
        `"${line.text}" is ${line.text.length} chars; only a single over-long word may exceed 48`
      );
      assert.ok(line.count <= 8, `"${line.text}" has ${line.count} words, max is 8`);
    }
  });

  test(`${id}: timestamps are monotonic and non-overlapping`, () => {
    const lines = groupWords(words);
    for (const line of lines) assert.ok(line.endMs > line.startMs, `"${line.text}" has no duration`);
    for (let i = 1; i < lines.length; i++) {
      assert.ok(
        lines[i].startMs >= lines[i - 1].endMs,
        `line ${i} starts at ${lines[i].startMs} before line ${i - 1} ends at ${lines[i - 1].endMs}`
      );
    }
  });

  test(`${id}: a speech pause forces a line break`, () => {
    const lines = groupWords(words);
    // Any word whose gap from its predecessor exceeds the threshold must begin
    // a line — that is the rule that keeps two sentences off one caption.
    const starts = new Set(lines.map((l) => l.startMs));
    for (let i = 1; i < words.length; i++) {
      if (words[i].startMs - words[i - 1].endMs > 420) {
        assert.ok(
          starts.has(words[i].startMs),
          `"${words[i].word}" follows a pause but did not start a new caption`
        );
      }
    }
  });
}

test("empty and whitespace-only words are dropped, not rendered blank", () => {
  const lines = groupWords([
    { word: "  ", startMs: 0, endMs: 100 },
    { word: "paste", startMs: 120, endMs: 400 },
    { word: "", startMs: 420, endMs: 500 },
  ]);
  assert.equal(lines.length, 1);
  assert.equal(lines[0].text, "paste");
});

test("no words in, no lines out", () => {
  assert.deepEqual(groupWords([]), []);
});

// ---------------------------------------------------------------------------
// ASS colour encoding.
//
// These three expectations are not derived — they are the values observed in a
// real rendered video during the pipeline's original bring-up. ASS reverses RGB
// to BGR and inverts alpha, so a mistake here produces a plausible-looking wrong
// colour instead of an error. Pinning them against the live token table means a
// palette edit that forgets the encoding fails loudly.

test("ASS colour encoding matches the verified reference values", () => {
  assert.equal(ass(tokens.paper), "&H00F7ECF2", "paper #f2ecf7");
  assert.equal(ass(tokens.live), "&H00B5DC7B", "live/mint #7bdcb5");
  assert.equal(ass(tokens.ink, 0x1f), "&H1F1F1317", "ink #17131f at 88% opacity");
});

test("ASS alpha is inverted — 00 is opaque, FF is transparent", () => {
  assert.ok(ass(tokens.ink, 0x00).startsWith("&H00"), "opaque");
  assert.ok(ass(tokens.ink, 0xff).startsWith("&HFF"), "transparent");
});
