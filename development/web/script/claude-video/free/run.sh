#!/usr/bin/env bash
# free/run.sh — the whole pipeline with NO account, NO API key and NO metered
# service. Captions plus a local text-to-speech voice.
#
#   ./free/run.sh                      every spec
#   ./free/run.sh --only otp_field     one component, both variants
#   ./free/run.sh --variant headless   one variant
#   ./free/run.sh --silent             captions only, skip narration entirely
#   ./free/run.sh --dry-run            count narration characters, generate nothing
#   ./free/run.sh --setup              install deps and stop
#
# Narration uses kokoro or piper running on this machine. If neither is
# installed the run still completes — narration is skipped with a warning and
# you get a complete caption video, which is what CI and a fresh clone get.

set -euo pipefail
# shellcheck source=../shared/preflight.sh
. "$(dirname "${BASH_SOURCE[0]}")/../shared/preflight.sh"

ONLY=""; VARIANT=""; SILENT=""; DRY=""; SETUP_ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)      ONLY="$2"; shift 2 ;;
    --only=*)    ONLY="${1#*=}"; shift ;;
    --variant)   VARIANT="$2"; shift 2 ;;
    --variant=*) VARIANT="${1#*=}"; shift ;;
    --silent)    SILENT="1"; shift ;;
    --dry-run)   DRY="--dry-run"; shift ;;
    --setup)     SETUP_ONLY="1"; shift ;;
    -h|--help)   sed -n '2,18p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) die "unknown flag: $1" ;;
  esac
done

preflight_tools
preflight_env
preflight_font

[[ -n "$SETUP_ONLY" ]] && { echo "setup complete."; exit 0; }

preflight_server

ARGS=()
[[ -n "$ONLY" ]] && ARGS+=("--only=$ONLY")
[[ -n "$VARIANT" ]] && ARGS+=("--variant=$VARIANT")

say "validate specs"
node shared/validate-specs.mjs

say "capture"
node shared/capture.mjs ${ARGS[@]+"${ARGS[@]}"}

say "cards"
node shared/render-cards.mjs

if [[ -z "$SILENT" ]]; then
  say "narrate"
  # A missing local TTS binary must not fail the run: captions are the product,
  # the voice is polish.
  node shared/narrate.mjs ${DRY:+$DRY} || warn "narration skipped — captions unaffected"
fi

[[ -n "$DRY" ]] && exit 0

say "assemble"
node shared/assemble.mjs ${ONLY:+--only=$ONLY}

say "done"
find out/final -name '*.mp4' -exec ls -lh {} \; 2>/dev/null | awk '{print "  " $9 "  " $5}'
