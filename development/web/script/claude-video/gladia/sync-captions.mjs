// gladia/sync-captions.mjs
// Narration audio -> word-level timestamps -> out/raw/<component>/00/words.json
//
// This is the ONLY part of the pipeline that talks to a paid service, and it is
// deliberately the last step: everything before it has already produced a
// finished, watchable video. If this fails, `free/run.sh` output still stands.
//
// WHY GLADIA IS HERE AT ALL
//
// Gladia is speech-TO-text. It cannot generate narration — the local TTS in
// shared/narrate.mjs does that. What Gladia adds is the reverse direction: it
// reads the generated audio back and returns when each word was actually
// spoken, so captions land on the words instead of on the interaction beats.
// That is a real improvement (a beat caption sits still for 1.2s whether the
// sentence took 0.6s or 2s) and it is the one job this key is right for.
//
// API contract verified against https://api.gladia.io/openapi.json:
//   POST /v2/upload         multipart, field name "audio"     -> { audio_url }
//   POST /v2/pre-recorded   json, { audio_url, ... }          -> { id, result_url }
//   GET  result_url         poll until status === "done"
//   words at result.transcription.utterances[].words[]
//
// Two contract details that silently corrupt output if missed:
//
//   1. `start` and `end` are SECONDS AS FLOATS, not milliseconds. The rest of
//      this pipeline works in ms, so the conversion happens here, once, at the
//      boundary — getting it wrong puts every caption 1000x off.
//   2. Words arrive with LEADING SPACES (" infinity"). Trimmed on the way in.
//
// Word-level timestamps need no flag; they are always returned. There is no
// `word_timestamps` option to set and looking for one is wasted time.

import { readFile } from "node:fs/promises";
import { mkdirSync, readdirSync, writeFileSync, existsSync, readFileSync } from "node:fs";
import { basename, join } from "node:path";
import { paths } from "../shared/config.mjs";

const API = "https://api.gladia.io/v2";
const KEY = process.env.GLADIA_API_KEY ?? "";
const only = process.argv.find((a) => a.startsWith("--only="))?.split("=")[1];

if (!KEY) {
  console.error(`
GLADIA_API_KEY is not set.

  cp .env.example .env    # then paste the key into .env

The free track needs no key at all — use ./free/run.sh for a complete video
with captions and a local voice.
`);
  process.exit(1);
}

const headers = { "x-gladia-key": KEY };

async function orThrow(res, step) {
  if (res.ok) return res.json();

  let body;
  try {
    body = await res.json();
  } catch {
    body = { message: await res.text() };
  }

  // Gladia's error envelope is uniform; request_id is what their support asks
  // for, so surface it rather than swallowing it.
  throw new Error(
    `${step} failed (HTTP ${res.status}): ${body.message ?? "unknown error"}` +
      (body.validation_errors?.length ? `\n  - ${body.validation_errors.join("\n  - ")}` : "") +
      (body.request_id ? `\n  request_id: ${body.request_id}` : "")
  );
}

async function transcribe(file) {
  // 1. upload. The field name must be "audio", and Content-Type must NOT be set
  //    by hand — fetch generates the multipart boundary, and forcing the header
  //    produces "Content-Type is missing Multipart Boundary".
  const form = new FormData();
  form.append("audio", new Blob([await readFile(file)]), basename(file));

  const { audio_url } = await orThrow(
    await fetch(`${API}/upload`, { method: "POST", headers, body: form }),
    "upload"
  );

  // 2. queue the job. `model` is omitted deliberately: the docs show one, but it
  //    is absent from the published pre-recorded schema, so passing it is
  //    unverifiable and may 4xx on some deployments. The server default is fine.
  const { id, result_url } = await orThrow(
    await fetch(`${API}/pre-recorded`, {
      method: "POST",
      headers: { ...headers, "Content-Type": "application/json" },
      body: JSON.stringify({
        audio_url,
        language_config: { languages: ["en"], code_switching: false },
        diarization: false,
      }),
    }),
    "create job"
  );

  // 3. poll result_url rather than rebuilding it — the server may hand back a
  //    /v2/transcription/{id} form instead of /v2/pre-recorded/{id}.
  for (let i = 0; i < 150; i++) {
    await new Promise((r) => setTimeout(r, 1000));
    const job = await orThrow(await fetch(result_url, { headers }), "poll");

    if (job.status === "done") {
      const words = job.result.transcription.utterances.flatMap((u) => u.words);
      return {
        transcript: job.result.transcription.full_transcript,
        words: words.map((w) => ({
          word: String(w.word).trim(),
          startMs: Math.round(w.start * 1000),
          endMs: Math.round(w.end * 1000),
          confidence: w.confidence,
        })),
      };
    }

    if (job.status === "error") {
      throw new Error(`job ${id} errored (error_code ${job.error_code})`);
    }
    // "queued" | "processing" — keep waiting
  }

  throw new Error(`job ${id} did not reach "done" within 150s`);
}

// Pair each narration audio file with the capture it belongs to. A missing half
// just means that component was never narrated — skip it, do not fail the batch.
function jobs() {
  const found = [];
  if (!existsSync(paths.vo)) return found;

  for (const file of readdirSync(paths.vo).filter((f) => /\.(wav|mp3)$/.test(f))) {
    const component = file.replace(/\.(wav|mp3)$/, "");
    if (only && component !== only) continue;

    // Narration is one track per component and plays from the first frame of
    // the first segment, so its word timings belong to segment 00 — that is the
    // segment whose captions --synced will retime.
    const segDir = join(paths.raw, component, "00");
    if (!existsSync(join(segDir, "timeline.json"))) {
      console.warn(`  -- ${component}: narration but no capture, skipped`);
      continue;
    }

    found.push({ component, audio: join(paths.vo, file), rawDir: segDir });
  }

  return found;
}

const queue = jobs();

if (!queue.length) {
  console.error(`
No narration audio found under ${paths.vo}.

Run the free track first — it captures the interaction and generates the voice
that this step reads back:

  ./free/run.sh --only <component>
`);
  process.exit(1);
}

console.log(`\nsyncing ${queue.length} narration file(s) through Gladia\n`);

let failed = 0;

for (const job of queue) {
  try {
    const { words, transcript } = await transcribe(job.audio);

    if (!words.length) {
      console.warn(`  -- ${job.component}: no words returned, skipped`);
      failed += 1;
      continue;
    }

    mkdirSync(job.rawDir, { recursive: true });
    writeFileSync(
      join(job.rawDir, "words.json"),
      JSON.stringify({ component: job.component, transcript, words }, null, 2)
    );

    // Cross-check against the narration we asked for. A large mismatch means the
    // TTS mispronounced something or the audio is truncated, and the captions
    // will read wrong even though every timestamp is technically correct.
    const spec = specNarration(job.component);
    const drift = spec ? Math.abs(transcript.length - spec.length) / spec.length : 0;
    const note = drift > 0.25 ? `  (transcript differs ${Math.round(drift * 100)}% from spec narration — check it)` : "";

    console.log(`  ok  ${job.component}  ${words.length} words${note}`);
  } catch (err) {
    console.error(`  --  ${job.component}\n      ${err.message}`);
    failed += 1;
  }
}

function specNarration(component) {
  const file = join(paths.specs, `${component}.json`);
  if (!existsSync(file)) return null;
  try {
    return JSON.parse(readFileSync(file, "utf8")).narration ?? null;
  } catch {
    return null;
  }
}

if (failed === queue.length) {
  console.error("\nEvery file failed. Not writing anything — assemble with the free track instead.\n");
  process.exit(1);
}

console.log("\nNow assemble with word-synced captions:\n  node shared/assemble.mjs --synced\n");
