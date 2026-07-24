# Mishka Chelekom — Development Harness

A real Phoenix 1.8 / LiveView 1.2 app that consumes the in-repo library as a **path
dependency**, renders every component in an interactive showcase, and runs real
end-to-end tests for the mix tasks.

Git-tracked but **never shipped to Hex** — the root `mix.exs` `files:` whitelist excludes `development/`.

## Stack

| Phoenix | LiveView | Tailwind | esbuild | Elixir |
|---|---|---|---|---|
| 1.8.x | 1.2.x | 4.x.x (CSS-first, no config file) | 0.25.x | ~> 1.18 |

## How it's wired

```elixir
# mix.exs
{:mishka_chelekom, path: "../", only: [:dev, :test]},
{:igniter, "~> 0.7", only: [:dev, :test]}
```

The generator resolves the library's templates/JS/CSS via `:code.priv_dir(:mishka_chelekom)`
(`MishkaChelekom.Generators.Core.lib_priv/1`), which works for path deps, hex deps and umbrellas
— **no symlink required**. Mix links the path dep's `priv/` into `_build`, so editing
`../priv/components/*.eex` and re-running the generator reflects immediately.

## Setup (from a fresh clone)

```bash
cd development
mix phx.server     # http://localhost:4002/showcase
```

## What you get

- Every styled component generated into `lib/development_web/components/`.
- `/showcase` — components grouped by category.
- `/showcase/:component` — an interactive prop explorer: controls derived from the component's
  catalog `args`, a live preview, and a copy-paste HEEx snippet.

## Live-edit loop

```bash
# edit ../priv/components/button.eex, then:
mix mishka.ui.gen.component button --yes
# refresh the browser — priv/ is linked into _build, so the change is live.
```

## Testing

```bash
mix test               # everything
mix test test/mishka   # real e2e tests that invoke each mix task directly
```

`test/mishka/*_test.exs` drives every `mishka.ui.*` task — `gen.component(s)`,
`gen.headless(s)`, `install`, `add`, `uninstall`, `css.config`, `mcp.setup`,
`assets.deps`, `export` — against the live generator.

## Dev scripts

| Script | What it does |
|---|---|
| `mix run gen_showcase.exs` | Regenerates `live/showcase/preview_generated.ex` from the catalog. Re-run after (re)generating components. |
| `mix run smoke.exs` | Renders every component preview and reports failures — a fast regression check. |
| `mix run --no-start check_http.exs` | GETs sample showcase pages from a running server and checks they mount. |

Hand-written previews for composite components (accordion, tabs, …) live in
`live/showcase/preview.ex`; the rest are generated.
