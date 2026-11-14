#!/usr/bin/env bash
# The Phoenix harness in development/web: dependency checks, then the assets its tests need,
# compile, format and tests.
set -euo pipefail
cd development/web

mix deps.get
mix deps.unlock --check-unused
mix deps.audit
mix hex.audit
mix assets.setup
mix compile --warnings-as-errors
mix format --check-formatted
MIX_ENV=test mix test
