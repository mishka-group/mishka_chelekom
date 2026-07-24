// dev/video/narrate.mjs
// Track B only. Reads hero specs, generates one audio file each.
//
// The dashboard has no per-key credit cap on the lower tiers, so the cap lives
// here instead: characters are counted and checked against CHAR_BUDGET BEFORE
// any request goes out. Failed generations still consume credits upstream, so a
// runaway loop is the actual risk — this makes it structurally impossible.
//
//   node narrate.mjs --dry-run          count characters, send nothing
//   node narrate.mjs --provider=say     macOS built-in, always available
//   node narrate.mjs --provider=kokoro  local, no key, no quota (needs install)
//   node narrate.mjs                    uses TTS_PROVIDER, defaults to kokoro

import { mkdirSync, readdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join } from "node:path";
import { paths } from "./config.mjs";

const arg = (n, d) => process.argv.find((a) => a.startsWith(`--${n}=`))?.split("=")[1] ?? d;
const DRY = process.argv.includes("--dry-run");
const PROVIDER = arg("provider", process.env.TTS_PROVIDER ?? (process.platform === "darwin" ? "say" : "kokoro"));
const CHAR_BUDGET = Number(process.env.CHAR_BUDGET ?? 9000); // under the 10k free tier
const VOICE_ID = process.env.VOICE_ID ?? "";
const KEY = process.env.ELEVEN_KEY ?? "";

const jobs = [];
for (const f of readdirSync(paths.specs).filter((f) => f.endsWith(".json") && !f.startsWith("_"))) {
  const spec = JSON.parse(readFileSync(join(paths.specs, f), "utf8"));
  if (!spec.hero) continue;
  if (!spec.narration) {
    console.warn(`! ${spec.component} is hero but has no narration — skipped`);
    continue;
  }
  jobs.push({ component: spec.component, text: spec.narration.trim() });
}

const total = jobs.reduce((n, j) => n + j.text.length, 0);

console.log(`\nprovider   ${PROVIDER}`);
console.log(`hero specs ${jobs.length}`);
console.log(`characters ${total} / budget ${CHAR_BUDGET}`);
for (const j of jobs) console.log(`  ${String(j.text.length).padStart(4)}  ${j.component}`);

if (total > CHAR_BUDGET) {
  console.error(
    `\nOver budget by ${total - CHAR_BUDGET} characters. Trim narration, ` +
      `drop a hero, or raise CHAR_BUDGET deliberately. Nothing was sent.\n`
  );
  process.exit(1);
}
if (DRY) {
  console.log("\nDry run — nothing sent.\n");
  process.exit(0);
}

async function elevenlabs(text, out) {
  if (!KEY || !VOICE_ID) {
    console.warn("! ELEVEN_KEY or VOICE_ID unset — skipping Track B, Track A is unaffected.");
    return false;
  }
  const res = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}`, {
    method: "POST",
    headers: { "xi-api-key": KEY, "Content-Type": "application/json" },
    // Turbo bills at roughly half the credits per character. On a 10k budget
    // that difference decides whether you get 20 components or 40.
    body: JSON.stringify({ text, model_id: "eleven_turbo_v2_5" }),
  });
  if (!res.ok) {
    console.error(`  ${res.status} ${await res.text()}`);
    return false;
  }
  writeFileSync(out, Buffer.from(await res.arrayBuffer()));
  return true;
}

function local(text, out, provider) {
  try {
    if (provider === "say") {
      // macOS built-in. No install, no model download, no key — which makes it
      // the only local provider guaranteed to exist on this machine, so it is
      // the default. kokoro/piper sound better; use them if you have them.
      execFileSync(
        "say",
        ["-o", out, "--data-format=LEI16@22050", "--file-format=WAVE",
         ...(process.env.SAY_VOICE ? ["-v", process.env.SAY_VOICE] : []),
         "-r", process.env.SAY_RATE ?? "175", text],
        { stdio: "inherit" }
      );
    } else if (provider === "kokoro") {
      execFileSync("python3", ["-m", "kokoro", "--text", text, "--voice", process.env.KOKORO_VOICE ?? "af_heart", "--output", out], { stdio: "inherit" });
    } else {
      execFileSync("sh", ["-c", `echo ${JSON.stringify(text)} | piper --model ${process.env.PIPER_MODEL} --output_file ${out}`], { stdio: "inherit" });
    }
    return true;
  } catch (e) {
    console.error(`  ${provider} failed: ${e.message}`);
    return false;
  }
}

mkdirSync(paths.vo, { recursive: true });

for (const j of jobs) {
  const ext = PROVIDER === "elevenlabs" ? "mp3" : "wav";
  const out = join(paths.vo, `${j.component}.${ext}`);

  const ok =
    PROVIDER === "elevenlabs" ? await elevenlabs(j.text, out) : local(j.text, out, PROVIDER);

  console.log(`${ok ? "  ok " : "  -- "} ${j.component}`);
}
