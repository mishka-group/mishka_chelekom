#!/usr/bin/env bash
# gladia/run.sh — the free pipeline, plus captions timed to the spoken words.
#
#   ./gladia/run.sh                      every spec
#   ./gladia/run.sh --only otp_field     one component, both variants
#   ./gladia/run.sh --variant headless   one variant
#   ./gladia/run.sh --sync-only          skip capture, re-sync existing audio
#
# What this adds over free/run.sh is ONE step. Gladia is speech-to-text: it does
# not generate the narration — the same local TTS does that in both tracks. It
# reads the generated audio back and reports when each word was actually spoken,
# so captions follow the voice instead of sitting on fixed interaction beats.
#
# Requires GLADIA_API_KEY in .env. Everything up to the sync step is identical to
# the free track and produces a complete video on its own, so a failure here
# costs you the sync, never the video.

set -euo pipefail
# shellcheck source=../shared/preflight.sh
. "$(dirname "${BASH_SOURCE[0]}")/../shared/preflight.sh"

ONLY=""; VARIANT=""; SYNC_ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)      ONLY="$2"; shift 2 ;;
    --only=*)    ONLY="${1#*=}"; shift ;;
    --variant)   VARIANT="$2"; shift 2 ;;
    --variant=*) VARIANT="${1#*=}"; shift ;;
    --sync-only) SYNC_ONLY="1"; shift ;;
    -h|--help)   sed -n '2,17p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) die "unknown flag: $1" ;;
  esac
done

preflight_tools
preflight_env
preflight_font

[[ -n "${GLADIA_API_KEY:-}" ]] || die "$(printf 'GLADIA_API_KEY is not set in .env.\n\nThe free track needs no key:\n\n    ./free/run.sh %s\n' "${ONLY:+--only $ONLY}")"

ARGS=()
[[ -n "$ONLY" ]] && ARGS+=("--only=$ONLY")
[[ -n "$VARIANT" ]] && ARGS+=("--variant=$VARIANT")

if [[ -z "$SYNC_ONLY" ]]; then
  preflight_server

  say "validate specs"
  node shared/validate-specs.mjs

  say "capture"
  node shared/capture.mjs ${ARGS[@]+"${ARGS[@]}"}

  say "cards"
  node shared/render-cards.mjs

  # Unlike the free track this is fatal: without narration audio there is
  # nothing for Gladia to read back, so continuing would just produce the free
  # track's output while implying the sync happened.
  say "narrate"
  node shared/narrate.mjs || die "$(printf 'Narration failed, so there is no audio to sync.\n\nInstall a local TTS (kokoro or piper), or run the free track for\ncaption-only videos:\n\n    ./free/run.sh --silent\n')"
fi

say "sync captions"
node gladia/sync-captions.mjs ${ONLY:+--only=$ONLY}

say "assemble"
node shared/assemble.mjs --synced ${ONLY:+--only=$ONLY}

say "done"
find out/final -name '*.mp4' -exec ls -lh {} \; 2>/dev/null | awk '{print "  " $9 "  " $5}'
