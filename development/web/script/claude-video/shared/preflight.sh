#!/usr/bin/env bash
# shared/preflight.sh — dependency and environment checks common to both tracks.
#
# Sourced, not executed, so it can export into the caller's shell. Both run.sh
# scripts source this so a fix made here reaches both tracks; the only thing
# each track owns is which pipeline steps it runs.

say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
warn() { printf '\033[33m%s\033[0m\n' "$1" >&2; }
die() { printf '\033[31m%s\033[0m\n' "$1" >&2; exit 1; }

# PKG is the package root (claude-video/), regardless of which track called us.
PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PKG"

# Keep the browser download inside this directory instead of the machine-wide
# ~/Library/Caches/ms-playwright.
#
# Not a style preference: that shared cache is easy to end up owning as root
# (one `sudo npx playwright install`, ever), and afterwards every non-sudo
# install dies with `EACCES: mkdir '.../__dirlock'`. Pointing at a project-local
# path sidesteps the whole class of problem, needs no sudo to fix, and makes the
# pipeline self-contained — which is what the gitignored node_modules already
# assumes. Costs one chromium download that is then cached here.
export PLAYWRIGHT_BROWSERS_PATH="$PKG/.playwright"

preflight_tools() {
  command -v node >/dev/null || die "node not found.   brew install node"
  command -v ffmpeg >/dev/null || die "ffmpeg not found. brew install ffmpeg"
  command -v ffprobe >/dev/null || die "ffprobe not found. brew install ffmpeg"

  if [[ ! -d node_modules/playwright ]]; then
    say "installing playwright"
    npm install --no-fund --no-audit
  fi

  # Chromium downloads once; re-running is a cheap no-op but the marker keeps
  # the common path from shelling out to npx at all.
  if [[ ! -f .chromium-ok ]]; then
    say "installing chromium (into ./.playwright, ~150MB, once)"
    npx playwright install chromium || die "$(printf 'Chromium install failed.\n\nIf this is EACCES on ~/Library/Caches/ms-playwright, that cache is\nroot-owned from an old sudo install and is NOT what this script uses —\ncheck that PLAYWRIGHT_BROWSERS_PATH is exported before npx runs.\n')"
    touch .chromium-ok
  fi
}

preflight_env() {
  [[ -f .env ]] || { cp .env.example .env; echo "created .env from .env.example"; }
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
}

# The cards load JetBrains Mono over the network via CSS, but ffmpeg's caption
# burner resolves fonts through the OS, not the browser. Without it installed the
# captions silently fall back while the cards render correctly, and the two
# halves of the finished video end up in different typefaces. This was found in
# testing, not predicted — hence the explicit check rather than a doc note.
preflight_font() {
  local ok=1
  if command -v fc-match >/dev/null; then
    fc-match "JetBrains Mono" 2>/dev/null | grep -qi "jetbrains" || ok=0
  else
    ls ~/Library/Fonts /Library/Fonts 2>/dev/null | grep -qi "jetbrains" || ok=0
  fi

  if [[ $ok -eq 0 ]]; then
    warn "! JetBrains Mono is not installed system-wide."
    warn "  Captions will fall back to a different face than the intro/outro cards."
    warn "  Fix:  brew install --cask font-jetbrains-mono"
    echo
  fi
}

# The showcase must already be serving. Starting it from here would fight the
# endpoint supervisor and leave an orphan on failure, so check and instruct.
preflight_server() {
  local origin="${CHELEKOM_DEV_ORIGIN:-http://localhost:4002}"
  curl -sf -o /dev/null --max-time 3 "$origin" || die "$(printf 'Nothing on %s.\n\nStart the showcase in another shell first:\n\n    cd development && mix phx.server\n' "$origin")"
}
