# Component demo video pipeline

Read `README.md` first for how to run it. This file is the part that needs
judgement: writing specs, and the decisions that are not obvious from the code.

## Do not relitigate these

**Gladia cannot narrate.** It is speech-to-text. Both tracks generate the voice
with the same local TTS; Gladia only reads that audio back for word-level
timestamps. If you find yourself looking for a Gladia TTS endpoint, stop.

**Word timestamps have no flag.** Gladia always returns
`result.transcription.utterances[].words[]`. There is no `word_timestamps`
option to enable and searching for one is wasted time.

**Gladia reports SECONDS as floats; this pipeline works in ms.** The conversion
happens once, in `sync-captions.mjs`, at the boundary. Do not convert again
downstream — getting this wrong is silent and puts every caption 1000x off.
Words also arrive with leading spaces (`" code"`); they are trimmed there too.

**Generative video is the wrong tool.** A component demo must show the actual
component with the actual Tailwind classes and theme tokens. Accuracy is the
entire point, so this is a deterministic screen-capture problem.

**Card duration is trimmed from the END of the recording.** Playwright starts
recording before webfonts rasterise and that startup jitter is not constant. The
tail is deterministic — the context closes the moment the animation completes.
So `render-cards.mjs` probes total duration and trims `total - duration - tail`,
never from `0`.

**Captions are burned from ASS, not drawtext.** Chained `drawtext` filters get
unreadable past three captions and cannot style one beat differently.

**ASS colour is `&HAABBGGRR`** — alpha first, then blue, green, red, and alpha is
inverted (`00` opaque, `FF` transparent). Wrong byte order produces a
plausible-looking wrong colour rather than an error, so it is pinned by test in
`shared/assemble.test.mjs` against values observed in a real render.

**Specs are committed, `out/` is not.**

## Writing specs

For each component:

1. Read the component source and its `@doc`, every `attr`, every `slot`.
2. **Open the showcase route and read the real markup.** Never invent a
   selector. The headless showcase renders `id={"hl-#{component}"}` on the live
   preview (secondary previews suffix it, e.g. `#hl-otp_field-an`); the Base UI
   gallery uses literal ids per section, e.g. `#baseui-otp_field-grouped`.
   Prefer an id or a `data-part` over structural selectors — `div > div:nth-child(3)`
   is not a contract.
3. Write `specs/<variant>/<component>.json`, then `npm run validate`.

Rules:

- 3–6 beats. Each beat demonstrates exactly ONE attr, slot or state.
- Beat order: default appearance -> primary interaction -> variants -> edge state.
- Captions max 48 chars, sentence case, active voice, no marketing words.
  "Paste fills every slot at once" — not "Seamlessly handles paste!"
- At most one `accent: true` beat per video.
- `hero: true` requires `narration`; narration without `hero` is never spoken and
  the validator rejects it.
- If the showcase genuinely has no element for a beat you want, change the beat.
  Do not add `needs_markup: true` and move on — the validator fails on it,
  because a placeholder selector surfaces as a Playwright timeout three minutes
  into a capture rather than as an error.

## Signature motion

The intro card is not a generic title slide; it is the component performing
itself. `signature` names the animation:

- `otp_field` -> `segments`: slots fill one character at a time
- `accordion` -> `unfold`: stacked rules expand
- `modal` -> `lift`: a plane rises off the backdrop

A component with no obvious signature gets `"plain"`. A forced signature is
worse than none. Adding one means editing `templates/intro.html` and the
`signature` enum in `specs/_schema.json`.

## Hard rules

- Never write a key, token or `.env` value into a spec, template, script or commit.
- Never commit anything under `out/`.
- Local TTS missing must warn, never fail — captions are the product, voice is
  polish. The exception is `gladia/run.sh`, where narration is fatal because
  without audio there is nothing to sync and continuing would silently produce
  free-track output.
