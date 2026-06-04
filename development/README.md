# Mishka Chelekom — Development Harness

A real Phoenix 1.8 / LiveView 1.1 app that consumes the **in-repo** Mishka Chelekom library
as a **path dependency** and renders every component in an interactive showcase. It is the
living test bed for the library: generate components against the latest Phoenix/LiveView,
exercise them in a browser, and (later) host the headless layer and serve as the base for
generating production output projects.

This directory is **git-tracked but never shipped to Hex** — the package `files:` whitelist in
the root `mix.exs` does not include `development/`, so `mix hex.publish` excludes it.

## Stack (verified latest as of build)

| | |
|---|---|
| Phoenix | 1.8.7 |
| LiveView | ~> 1.1 (1.1.x) |
| Tailwind | 4.1.x (CSS-first, no `tailwind.config.js`) + daisyUI 5 |
| esbuild | 0.25.x |
| Elixir | 1.19 / OTP 28 |

## How it's wired

```elixir
# mix.exs
{:mishka_chelekom, path: "../", only: :dev},
{:igniter, "~> 0.7", only: [:dev, :test]}
```

A path dependency is **not** materialised into `deps/`. As of Phase 0 the generator resolves the
library's templates/JS/CSS via `:code.priv_dir(:mishka_chelekom)`
(`MishkaChelekom.Generators.Core.lib_priv/1`), which works for path deps, hex deps and umbrellas
— **no symlink required** (earlier revisions needed a `deps/mishka_chelekom -> ../..` symlink; it
has been retired).

Because Mix symlinks the path dep's `priv/` into `_build`, **editing a template in
`../priv/components/*.eex` and re-running the generator reflects immediately here** — no recompile
of the dependency needed.

## Setup (from a fresh clone)

```bash
cd development
./bin/setup.sh        # symlink + deps.get + generate all components + build assets
mix phx.server        # http://localhost:4002/showcase
```

## What you get

- All current styled components generated into `lib/development_web/components/`.
- `/showcase` — every component grouped by category.
- `/showcase/:component` — an **interactive prop explorer**: controls derived from the
  component's catalog `args`, a live preview, and a copy-paste HEEx snippet.

## The live-edit loop

```bash
# 1. edit a template in the repo, e.g. ../priv/components/button.eex
# 2. regenerate just that component:
mix mishka.ui.gen.component button --yes
# 3. refresh the browser — the change is live (priv/ is symlinked into _build).
```

## Dev scripts

| Script | What it does |
|---|---|
| `mix run gen_showcase.exs` | Regenerates `live/showcase/preview_generated.ex` (one preview clause per component) from the catalog. Re-run after (re)generating components. |
| `mix run smoke.exs` | Renders every component preview to iodata and reports failures — a fast regression check. |
| `mix run --no-start check_http.exs` | GETs a sample of showcase pages from a running server and checks they mount. |

Richer, hand-written previews for composite components (accordion, tabs, carousel, …) live in
`live/showcase/preview.ex`; everything else is generated.

## Notes

- The library starts an MCP server (anubis_mcp) on port **4003** in `:dev` because it is a
  `:dev` dependency — harmless for the harness.
- `--no-ecto` was intentionally **not** used: many components depend on Gettext, which the
  default Phoenix scaffold provides.
