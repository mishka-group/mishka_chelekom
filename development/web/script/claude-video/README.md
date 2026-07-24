# Component demo videos

Generates a short demo video for every showcase component, from source, in one
command. There are too many components to record by hand and they change every
release, so the videos regenerate rather than get edited.

```bash
cd development && mix phx.server          # showcase on :4002, separate shell

cd development/script/claude-video
./free/run.sh --only otp_field            # no key, no account, no cost
```

Output lands in `out/final/<variant>/<component>.mp4`. `out/` is gitignored —
the **specs** are the reviewable source of truth, the mp4s are derived.

## Two tracks

| | `free/` | `gladia/` |
|---|---|---|
| captions | timed to interaction beats | timed to the **spoken words** |
| voice | local TTS (kokoro / piper) | same local TTS |
| needs | nothing | `GLADIA_API_KEY` |
| runnable in CI | yes | no |

**Gladia does not generate the voice.** It is speech-**to**-text. Both tracks
narrate with the same local TTS; what `gladia/` adds is reading that audio back
to find out when each word was actually spoken, so a caption appears with its
sentence instead of sitting still for a fixed 1.2s. That is the one job this key
is right for.

Everything `gladia/` does before the sync step is identical to `free/`, so a
failure there costs you the sync, never the video.

## Requirements

```bash
brew install node ffmpeg
brew install --cask font-jetbrains-mono   # see below — this one is not optional
```

Playwright and Chromium install into this directory on first run.

JetBrains Mono must be installed **system-wide**. The intro/outro cards load it
over the network via CSS, but ffmpeg's caption burner resolves fonts through the
OS, so without it the captions silently fall back and the two halves of the
finished video end up in different typefaces. `run.sh` preflights this and warns.

Local TTS is optional. Without kokoro or piper installed, `free/run.sh` still
produces a complete caption video and just warns — which is what a fresh clone
and CI get.

## Commands

```bash
./free/run.sh                      # every spec
./free/run.sh --only otp_field     # one component, both variants
./free/run.sh --variant headless   # one variant
./free/run.sh --silent             # captions only, skip narration
./free/run.sh --dry-run            # count narration characters, generate nothing
./free/run.sh --setup              # install deps and stop

./gladia/run.sh --only otp_field   # same, plus word-synced captions
./gladia/run.sh --sync-only        # re-sync existing audio, skip re-capture

npm run validate                   # check specs without starting a browser
npm test                           # caption grouping + ASS colour encoding
```

## Layout

```
shared/     specs, templates and every pipeline step — both tracks use these
  specs/<variant>/<component>.json    committed, reviewed in PRs
  templates/intro.html outro.html     the title and docs cards
  capture.mjs        Playwright -> capture.webm + timeline.json
  render-cards.mjs   Playwright -> intro.mp4 + outro.mp4
  narrate.mjs        narration text -> out/vo/*.wav  (local TTS)
  assemble.mjs       ffmpeg: burn captions, concat, mix audio
  validate-specs.mjs cheap pre-flight; catches what fails late and confusingly
free/       run.sh — the whole pipeline, no credentials
gladia/     run.sh + sync-captions.mjs — adds word-level caption timing
out/        GITIGNORED. raw/ frames/ vo/ final/
```

Both tracks write to the same `out/`, deliberately: `gladia/` reuses the capture
and narration the free track already produced rather than re-recording them.

## Writing a spec

`shared/specs/_schema.json` is the contract; `npm run validate` enforces it plus
the rules the schema cannot express. Rules that matter:

- 3–6 beats, each demonstrating exactly ONE attr, slot or state.
- Captions max 48 characters, sentence case, active voice, no marketing words.
- **Never invent a selector.** Open the showcase route and use what is really
  rendered. The headless showcase gives every preview a stable id
  (`#hl-<component>`); the Base UI gallery uses `#baseui-<component>-<section>`.
- At most one `accent: true` beat. Mint only reads as "this is the moment" while
  it stays rare.
- `hero: true` adds narration and must be listed in the hero set. Narration is
  one sentence, under 45 words, and must not restate the captions.

## Security

The only secret is `GLADIA_API_KEY`, and it belongs in `.env`, which is
gitignored. `.env.example` carries the empty shape and is committed. Never write
a key into a spec, a template, a script or a commit. Rotate anything that has
been pasted into a chat, an issue or a PR — treat it as burned.
