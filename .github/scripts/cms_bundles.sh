#!/usr/bin/env bash
# Exports the styled and the headless kit as CMS bundles stamped with $VERSION and checks both:
# at least one component, and the version they say. Run from the repository root after
# `mix deps.get`; the release puts dist/*.json on its GitHub release.
set -euo pipefail
: "${VERSION:?VERSION must be set}"

mix compile

mix mishka.ui.export priv/components --cms \
  --name chelekom --bundle-name chelekom \
  --bundle-version "$VERSION" --yes

mix mishka.ui.export priv/headless --cms \
  --name chelekom_headless --bundle-name chelekom_headless \
  --bundle-version "$VERSION" --yes

mkdir -p dist
cp priv/components/chelekom.json dist/chelekom.json
cp priv/headless/chelekom_headless.json dist/chelekom_headless.json
for f in dist/chelekom.json dist/chelekom_headless.json; do
  n="$(jq '.components | length' "$f")"
  got="$(jq -r '.version' "$f")"
  [ "$n" -gt 0 ] || { echo "::error::$f has no components"; exit 1; }
  [ "$got" = "$VERSION" ] || { echo "::error::$f says version $got"; exit 1; }
  echo "$f: $n components, version $got"
done
