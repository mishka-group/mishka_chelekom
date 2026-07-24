// shared/assemble.mjs
// intro + captioned capture + outro -> out/final/<variant>/<component>.mp4
//
// Captions are burned from an .ass file generated off timeline.json, not from
// chained drawtext filters — ASS gives real styling and exact timing, and the
// accent beat only needs a colour override rather than a second filter chain.
//
// Two caption sources, same styling:
//
//   default    beats from timeline.json — timing measured from the interaction
//   --synced   words from words.json — timing measured from the spoken audio
//              (written by gladia/sync-captions.mjs; falls back to beats and
//              says so if the file is absent, so --synced can never produce a
//              silently un-synced video)
//
// The word timestamps need NO offset. Gladia measures them against the
// narration audio, which starts at the first frame of the capture segment, and
// the .ass is burned onto that segment BEFORE the intro is concatenated. Adding
// the intro duration here would push every caption 3.2s late.

import { execFileSync } from "node:child_process";
import {
  mkdirSync,
  readdirSync,
  readFileSync,
  writeFileSync,
  existsSync,
  rmSync,
} from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { paths, video, tokens } from "./config.mjs";

const ff = (args, cwd) =>
  execFileSync("ffmpeg", ["-y", "-loglevel", "error", ...args], {
    cwd,
    stdio: "inherit",
  });

const probe = (file) =>
  Number(
    execFileSync("ffprobe", [
      "-v",
      "error",
      "-show_entries",
      "format=duration",
      "-of",
      "default=noprint_wrappers=1:nokey=1",
      file,
    ])
      .toString()
      .trim(),
  );

/**
 * #rrggbb -> &HAABBGGRR. ASS reverses the channel order and INVERTS alpha:
 * 00 is opaque, FF transparent. Getting either wrong yields a plausible-looking
 * but wrong colour rather than an error, which is why this is pinned by test.
 */
export const ass = (hex, alpha = 0) => {
  const [r, g, b] = [1, 3, 5].map((i) => hex.slice(i, i + 2));
  return `&H${alpha.toString(16).padStart(2, "0").toUpperCase()}${b}${g}${r}`.toUpperCase();
};

const stamp = (ms) => {
  const cs = Math.round(ms / 10);
  const h = Math.floor(cs / 360000);
  const m = Math.floor((cs % 360000) / 6000);
  const s = Math.floor((cs % 6000) / 100);
  return `${h}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}.${String(cs % 100).padStart(2, "0")}`;
};

function assFile(tl) {
  const head = `[Script Info]
ScriptType: v4.00+
PlayResX: ${video.width}
PlayResY: ${video.height}
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Cap,JetBrains Mono,26,${ass(tokens.paper)},${ass(tokens.paper)},${ass(tokens.ink)},${ass(tokens.ink, 0x1f)},0,0,0,0,100,100,0,0,3,6,0,1,80,80,32,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
`;

  const lines = tl.beats.map((b) => {
    const colour = b.accent ? `{\\c${ass(tokens.live)}}` : "";
    return `Dialogue: 0,${stamp(b.startMs)},${stamp(b.endMs)},Cap,,0,0,0,,${colour}${b.caption}`;
  });

  return head + lines.join("\n") + "\n";
}

/**
 * Group word-level timestamps into readable caption lines.
 *
 * Exported and pure so it can be unit-tested without an API key, a network, or
 * an audio file — the grouping is the only part of the synced path with real
 * logic in it, so it is the part worth testing.
 *
 * A line closes on whichever comes first: the character budget, the word
 * budget, or a gap longer than `gapMs` (a natural pause in the speech). The
 * gap rule is what keeps sentences from running together when the speaker
 * breathes.
 */
export function groupWords(
  words,
  { maxChars = 48, maxWords = 8, gapMs = 420 } = {},
) {
  const lines = [];
  let cur = null;

  for (const w of words) {
    const text = String(w.word ?? "").trim();
    if (!text) continue;

    const wouldBe = cur ? `${cur.text} ${text}` : text;
    const gap = cur ? w.startMs - cur.endMs : 0;

    if (
      cur &&
      (wouldBe.length > maxChars || cur.count >= maxWords || gap > gapMs)
    ) {
      lines.push(cur);
      cur = null;
    }

    if (!cur) cur = { text, startMs: w.startMs, endMs: w.endMs, count: 1 };
    else {
      cur.text = wouldBe;
      cur.endMs = w.endMs;
      cur.count += 1;
    }
  }

  if (cur) lines.push(cur);
  return lines;
}

/** Same styling as assFile, but timed to the spoken words rather than the beats. */
function assFileSynced(tl, words) {
  const head = assFile({ beats: [] }).trimEnd() + "\n";
  const lines = groupWords(words).map(
    (l) =>
      `Dialogue: 0,${stamp(l.startMs)},${stamp(l.endMs)},Cap,,0,0,0,,${l.text}`,
  );
  return head + lines.join("\n") + "\n";
}

const only = process.argv.find((a) => a.startsWith("--only="))?.split("=")[1];
const synced = process.argv.includes("--synced");

// Only assemble when run as a script. Importing this file must have no side
// effects, so the caption-grouping logic can be unit-tested without a capture
// on disk, an API key, or ffmpeg installed.
if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) main();

function main() {
  if (!existsSync(paths.raw)) {
    console.error("No captures found. Run capture.mjs first.");
    process.exit(1);
  }

  for (const component of readdirSync(paths.raw)) {
    if (only && component !== only) continue;

    const rawDir = join(paths.raw, component);
    const frameDir = join(paths.frames, component);
    const manifestFile = join(rawDir, "spec.json");

    if (!existsSync(manifestFile) || !existsSync(join(frameDir, "intro.mp4"))) {
      console.warn(`  -- ${component}: missing manifest or cards, skipped`);
      continue;
    }

    const manifest = JSON.parse(readFileSync(manifestFile, "utf8"));
    mkdirSync(paths.final, { recursive: true });

    const work = join(rawDir, "_work");
    rmSync(work, { recursive: true, force: true });
    mkdirSync(work, { recursive: true });

    // One captioned body per segment. Each is encoded to the SAME codec,
    // pixel format, size and framerate as the cards, so the final concat can
    // stream-copy — that is the only reason the durations add up exactly.
    const parts = [join(frameDir, "intro.mp4")];
    let missing = false;

    for (const segment of manifest.segments) {
      const pad = String(segment.index).padStart(2, "0");
      const segDir = join(rawDir, pad);
      const capture = join(segDir, "capture.webm");
      const cardFile = join(frameDir, `segment-${pad}.mp4`);

      if (!existsSync(capture)) {
        console.warn(
          `  -- ${component}[${segment.index}]: no capture, skipped`,
        );
        missing = true;
        continue;
      }

      const tl = JSON.parse(
        readFileSync(join(segDir, "timeline.json"), "utf8"),
      );

      // --synced swaps the caption timing source from interaction beats to
      // spoken words. If words.json is absent we fall back to beats and SAY
      // SO — silently shipping un-synced captions from a --synced run would be
      // indistinguishable from success.
      const wordsFile = join(segDir, "words.json");
      let captions = assFile(tl);

      if (synced) {
        if (existsSync(wordsFile)) {
          captions = assFileSynced(
            tl,
            JSON.parse(readFileSync(wordsFile, "utf8")).words,
          );
        } else {
          console.warn(
            `  !  ${component}[${segment.index}]: --synced but no words.json — beat timing`,
          );
        }
      }

      writeFileSync(join(work, `cap-${pad}.ass`), captions);
      ff(
        [
          "-i",
          capture,
          "-vf",
          `ass=cap-${pad}.ass,fps=${video.fps},scale=${video.width}:${video.height}:flags=lanczos`,
          "-c:v",
          "libx264",
          "-preset",
          "medium",
          "-crf",
          "18",
          "-pix_fmt",
          "yuv420p",
          "-an",
          `body-${pad}.mp4`,
        ],
        work,
      );

      if (existsSync(cardFile)) parts.push(cardFile);
      parts.push(join(work, `body-${pad}.mp4`));
    }

    if (parts.length === 1) {
      console.warn(`  -- ${component}: no usable segments, skipped`);
      rmSync(work, { recursive: true, force: true });
      continue;
    }

    parts.push(join(frameDir, "outro.mp4"));

    writeFileSync(
      join(work, "list.txt"),
      parts.map((p) => `file '${p}'`).join("\n"),
    );
    ff(
      [
        "-f",
        "concat",
        "-safe",
        "0",
        "-i",
        "list.txt",
        "-c",
        "copy",
        "silent.mp4",
      ],
      work,
    );

    // Narration, if any was generated.
    const vo = ["mp3", "wav"]
      .map((e) => join(paths.vo, `${component}.${e}`))
      .find(existsSync);
    const final = join(paths.final, `${component}.mp4`);

    if (!vo) {
      ff(["-i", join(work, "silent.mp4"), "-c", "copy", final]);
      console.log(
        `  ok  ${component}  (captions)${missing ? " [some segments missing]" : ""}`,
      );
    } else {
      const introMs = probe(join(frameDir, "intro.mp4")) * 1000;
      const videoDur = probe(join(work, "silent.mp4"));
      const audioEnd = introMs / 1000 + probe(vo);
      // Hold the last frame rather than speeding the video up to fit the voice.
      const pad = Math.max(0, audioEnd - videoDur + 0.4);

      ff([
        "-i",
        join(work, "silent.mp4"),
        "-i",
        vo,
        "-filter_complex",
        `[0:v]tpad=stop_mode=clone:stop_duration=${pad.toFixed(2)}[v];` +
          `[1:a]adelay=${Math.round(introMs)}|${Math.round(introMs)},loudnorm=I=-16:TP=-1.5:LRA=11[a]`,
        "-map",
        "[v]",
        "-map",
        "[a]",
        "-c:v",
        "libx264",
        "-preset",
        "medium",
        "-crf",
        "18",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        "160k",
        final,
      ]);
      console.log(
        `  ok  ${component}  (captions + voice)${missing ? " [some segments missing]" : ""}`,
      );
    }

    rmSync(work, { recursive: true, force: true });
  }
}
