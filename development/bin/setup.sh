#!/usr/bin/env bash
#
# Rebuilds the Mishka Chelekom development harness from a fresh clone:
#   - recreates the path-dep symlink (deps/mishka_chelekom -> repo root)
#   - fetches deps, generates all styled components, regenerates showcase previews
#   - installs + builds assets
#
# Usage:  development/bin/setup.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# NOTE: As of Phase 0, the library's generator resolves its templates/JS/CSS via
# `:code.priv_dir(:mishka_chelekom)` (MishkaChelekom.Generators.Core), so the old
# `deps/mishka_chelekom -> ../..` symlink is no longer required. Live template editing
# still works because Mix symlinks the path dep's priv into `_build`.

echo "==> mix deps.get"
mix deps.get

echo "==> Generating all styled components"
mix mishka.ui.gen.components --import --helpers --global --yes

echo "==> Regenerating showcase previews"
mix run gen_showcase.exs

echo "==> Building assets"
mix assets.setup
mix assets.build

echo
echo "Done. Start the harness with:"
echo "    mix phx.server   ->   http://localhost:4000/showcase"
