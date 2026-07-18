# External JS libraries — editors (plan)

How Chelekom ships components that depend on an **npm package** (first case: editors), while keeping
the promise: *the developer runs one `mix` task and has a working editor — no manual config.*

## TL;DR

1. **No new mix command.** `mix mishka.ui.gen.headless code_editor` stays the entry point. The npm
   install is an implementation detail of the catalog.
2. **We already own the whole install path** — `mishka.assets.deps` + `mishka.assets.install` detect
   npm/bun/yarn and fall back to the `{:bun, ...}` hex binary when the machine has no Node. We call
   it; we do not rebuild it.
3. **Ship two editors:** `code_editor` (CodeMirror 6) first, then `editor` (TipTap 3). Both MIT, both
   headless, both ship **zero CSS files** — that last one is what makes zero-config possible.

## 1. What editors we can have

### Naming — capability first, library is an implementation detail

We name components by *what they do*, like the rest of the library (`select`, not `downshift_select`):

| Component | What it is | Engine |
|---|---|---|
| **`editor`** | **HTML / rich text (WYSIWYG)** — the one people mean by "an editor" | TipTap 3 |
| `markdown_editor` | markdown source in, markdown out | Milkdown 7 |
| `code_editor` | syntax-highlighted **code** (JSON/SQL/config field) — *not* HTML | CodeMirror 6 |

### Tier 1 — ship these, `editor` first

| Component | Library | npm packages | License | Size (gz) | Why |
|---|---|---|---|---|---|
| **`editor`** | **TipTap 3** (`3.28.0`) | `@tiptap/core`, `@tiptap/pm`, `@tiptap/starter-kit` | MIT | **114 KB (measured here)** | Genuinely headless (zero UI), `new Editor()` / `editor.destroy()` maps 1:1 onto a hook lifecycle, no `.css` file — injects functional CSS at runtime |
| `code_editor` | **CodeMirror 6** | `@codemirror/state`, `@codemirror/view`, `@codemirror/commands`, one `@codemirror/lang-*` | MIT | ~89 KB min / ~162 KB w/ basicSetup | Real `destroy()`, `Compartment` for live readonly, plain-string content, best a11y, injects its own styles |

### Every free HTML/rich-text library, and what we do with it

Only these pass the permissive-license rule. There are no others worth listing — the rest of the
market (TinyMCE, CKEditor, Froala) is GPL or commercial.

| Library | License | Headless | Verdict |
|---|---|---|---|
| **TipTap 3** | MIT | yes | **Default `editor` engine.** The only one that is MIT *and* headless *and* has a clean destroy |
| **Lexical** | MIT | yes | Second engine, when it hits 1.0 — still 0.x with routine breaking changes, and we pin versions into the user's `package.json` |
| **Quill 2** | BSD-3 | no | Skip: **no `destroy()`** at all → leaks on every LiveView navigation. License is fine, the lifecycle is not |
| **Trix** | MIT | no | Skip: ships its own toolbar/UI, fights a headless library. Fine choice for someone who wants batteries-included, but that isn't us |
| **Squire** | MIT | yes-ish | Tiny contenteditable core. Possible ultra-light alternative if TipTap's 114 KB is ever a blocker |
| **ProseMirror (raw)** | MIT | yes | Skip: TipTap *is* the MIT ProseMirror layer; using it raw means rebuilding TipTap |

Markdown side: **Milkdown 7** (MIT) is the pick; Toast UI and EasyMDE are MIT but lower ceiling.

### How the user creates one

```bash
mix mishka.ui.gen.headless editor                 # HTML editor, TipTap (default)
mix mishka.ui.gen.headless editor --lib lexical   # same component, different engine (later)
mix mishka.ui.gen.headless markdown_editor        # Milkdown
mix mishka.ui.gen.headless code_editor --language elixir
```

One component name, engine chosen by `--lib`. The catalog carries a `libs:` map from day one so a
second engine is **data, not a refactor**:

```elixir
libs: [
  tiptap:  [default: true, npm: [...], engine: "editor_tiptap.js"],
  lexical: [npm: [...], engine: "editor_lexical.js"]
]
```

Only `tiptap` is populated for v1 — the flag exists so adding Lexical later costs one catalog entry
plus one engine file, with no change to the component's public API or the developer's markup.

### Rejected — and why

| Library | Verdict |
|---|---|
| **Monaco** | Hard-fails stock Phoenix esbuild (`No loader is configured for ".ttf"`), needs `config/config.exs` edits + worker entry points, ~943 KB gz. **Point users at `live_monaco_editor` instead** |
| **Quill 2** | Has **no `destroy()`** (10-year-old open request, documented leaks). LiveView destroys hooks on every navigation — structural mismatch. Not headless, dormant since 2024 |
| **TinyMCE 7/8, CKEditor 5** | **Never generate.** GPLv2+ — copyleft lands on the *consumer's* app. CKEditor also refuses to boot without a `licenseKey` since v44 (blank page by default) |
| **`@tiptap-pro/*`** | Not on public npm — private registry + auth token. Would break `npm install` and CI for everyone without a subscription |
| **Ace** | Pre-ESM, not headless, resolves modes by runtime URL (silent 404s in prod) |
| **Raw ProseMirror** | We'd be rebuilding TipTap. TipTap *is* the MIT ProseMirror layer |
| **Trix / EasyMDE / Toast UI** | Clean licenses (Toast UI is still MIT — the "license changed" rumor is false), but not headless and lower ceiling |

### Admission rules for ANY external-JS component (editors are just the first)

1. **Permissive license only** — MIT / Apache-2.0 / BSD / ISC. No GPL/copyleft, no license-key gate,
   no private registry, no paid tier required to run. Declared in the catalog's `:license` key and
   asserted by a catalog test.
2. **The library must ship no required stylesheet.** A JS `import "pkg/dist/x.css"` silently emits
   `priv/static/assets/js/app.css`, which no layout links — an instant manual-config bug.
3. **Any CSS we need is ours**, hand-written into the existing global stylesheets (see "Where things
   live"), never a per-component vendored file.

## 2. Do we need another mix command? **No.**

We already have every piece. The gap is one no-op function.

| Need | Already exists |
|---|---|
| Create `assets/package.json` | `mishka.assets.deps` → `ensure_package_json_exists/1` |
| Add/remove deps at pinned versions | `mishka.assets.deps` → `update_package_json_deps/3` |
| Pick npm / bun / yarn | auto-detects PATH, or `--npm` / `--bun` / `--yarn` |
| **No package manager on the machine** | adds `{:bun, "~> 1.0"}` to `mix.exs` + `config :bun`, runs via `Mix.Task.run("bun", ["install"])` — **no system Node needed** |
| Actually run the install | `mishka.assets.install` (handles yarn `add` vs npm/bun `install`) |
| Copy engine JS + wire hooks | `Assets.wire_scripts/2` → `update_js_files/2` (IgniterJs AST edits to `mishka_components.js` + `app.js`) |
| Chain one task from another | `Igniter.add_task/3`, already used by `mishka.assets.deps`; `Igniter.compose_task/3`, already used by `mishka_chelekom.install` |
| Refcount shared assets on uninstall | `mishka.ui.uninstall` already folds over remaining catalogs' `:scripts` |

**The only gap** — `lib/mishka_chelekom/generators/assets.ex:30`:

```elixir
defp check_package_json(igniter, _) do
  # TODO: for now we have no plan for it, it needs some way to handle npm, bun or etc
  igniter
end
```

It is already called by `wire_scripts/2` on every scripts-bearing generation. **Fill this body** — read
the catalog's npm deps and `Igniter.add_task("mishka.assets.deps", [...])`. That is the feature.

Public API delta: two optional flags on the existing generators.

- `--pm npm|bun|yarn|mix-bun` — passthrough (default `mix-bun`: it's the only option that keeps
  Phoenix's "no Node required" promise, including in Docker).
- `--no-npm` — write everything, skip the install, print the exact command (air-gapped / CI).

## 3. Catalog keys to add

`Core.validate_catalog/1` only checks `:name` and `:args`, so **new keys are free** — no validator change.

```elixir
[
  code_editor: [
    name: "code_editor",
    # ... existing keys ...

    # NEW — installed via mix mishka.assets.deps. EXACT versions, never carets:
    # @tiptap/core peer-depends on @tiptap/pm at an exact pin, and drift gives you
    # two prosemirror-model instances + opaque runtime RangeErrors.
    npm: [
      %{name: "@codemirror/state", version: "6.7.1"},
      %{name: "@codemirror/view", version: "6.43.6"},
      %{name: "@codemirror/commands", version: "6.10.4"},
      %{name: "@codemirror/lang-javascript", version: "6.2.5"}
    ],

    # NEW — license manifest: printed on generate, asserted by a catalog test so a
    # GPL / licenseKey-gated / private-registry package can never slip in.
    license: [spdx: "MIT", note: "All @codemirror/* and @lezer/* are MIT. Public npm, no key."],

    # NO :css key. Component CSS lives in the global stylesheets we already ship
    # (priv/assets/css/mishka_chelekom_headless.css) — see "Where things live".

    scripts: [%{module: "CodeEditor", type: "file", file: "code_editor.js",
                imports: "import CodeEditor from \"./code_editor.js\";"}]
  ]
]
```

TipTap's catalog additionally wants `hex_deps: [%{name: "html_sanitize_ex", version: "~> 1.5"}]` (see Risks).

## 3b. Where things live

**Not a new category — editors are headless components**, generated by the existing
`mix mishka.ui.gen.headless`. They are behaviour + ARIA + a JS engine, which is exactly what that
layer already is; they inherit the showcase, uninstall, refcounting and catalog tests for free. A
styled sibling in `priv/components/` can come later and reuse the same engine. `category: "editors"`
in the `.exs` only groups them in the showcase sidebar.

| Thing | Path |
|---|---|
| Catalog + template | `priv/headless/code_editor.exs` + `.eex` |
| JS engine | `priv/assets/js/code_editor.js` |
| **CSS** | a new commented section inside **`priv/assets/css/mishka_chelekom_headless.css`** (headless) — or `mishka_chelekom.css` for a styled sibling. Same file the 72 existing components already share; both are already vendored + `@import`ed by `setup_headless_css/2`, so **no new CSS mechanism at all** |
| Dev-harness component | `development/lib/development_web/components/headless/code_editor.ex` (kept in sync as usual) |
| Dev-harness engine copy | `development/assets/vendor/code_editor.js` |
| **Manual-test page** | automatic at **`/showcase/headless/code_editor`** — `HeadlessCatalog` discovers it from `priv/headless/*.exs`. Add the `show/1` clause + class helper in `headless_preview.ex`, and a bottom Examples section (`has_examples?/1` + `examples/1`) with a real `<.form>` LiveComponent demo, exactly like every other component. Skip `headless_baseui_examples.ex` (no Base UI counterpart) |
| **New dev-harness infra** | `development/assets/package.json` + `bun install` (currently absent — the harness has never needed npm). One-time setup, then `bin/setup.sh` runs it |

The mechanism is **library-agnostic**: `:npm` + `check_package_json/2` is the generic external-JS
path. Editors are only its first consumer — chart libs, DOMPurify, anything else uses the same road.

## 4. End-to-end: what `mix mishka.ui.gen.headless code_editor` does

Existing steps unchanged; **NEW** marks additions.

| # | Step | Files |
|---|---|---|
| 1 | `write_component` | CREATE `lib/<app>_web/components/headless/code_editor.ex` |
| 2 | **NEW** `check_package_json` | CREATE `assets/package.json` (if absent) · EDIT it with the `:npm` deps at exact versions |
| 3 | **NEW** mix.exs aliases | EDIT `assets.setup` / `assets.build` / `assets.deploy` to include the install step (idempotent) — without this, prod/CI bundles without the package and fails |
| 4 | **NEW** queue install | `Igniter.add_task("mishka.assets.deps", [deps, "--yes", pm_flag])` |
| 5 | `update_js_files` | CREATE `assets/vendor/code_editor.js` · EDIT `assets/vendor/mishka_components.js` (import + `Components`) · EDIT `assets/js/app.js` (`...MishkaComponents`) |
| 6 | `setup_headless_css` (unchanged) | CREATE `assets/vendor/mishka_chelekom_headless.css` (already contains the editor's section) · EDIT `assets/css/app.css` `@import` |
| 7 | Igniter drains queue | `mishka.assets.deps` → `mishka.assets.install` → real `bun/npm install` · CREATE `assets/node_modules/` + lockfile |

Then `mix phx.server` → working editor. **Zero manual steps.**

**Not touched:** the `config :esbuild` block (see §5), and `assets/tsconfig.json` (see §5).

## 5. Verified on this machine (2026-07-18)

Run against `development/` with the repo's own esbuild binary, then reverted:

| Check | Result |
|---|---|
| `bun add @tiptap/core @tiptap/starter-kit @tiptap/pm` | 42 packages, 20s, resolved **3.28.0** |
| Bare specifier from `assets/vendor/*.js` → `assets/node_modules` | **Resolves, zero warnings, zero config change** |
| Bundle via the real `mix esbuild development` profile | Works — app.js 680K → 1.4M, real TipTap code (`CommandManager`, `ExtensionManager`, `createDocument`) |
| Minified / gzipped (core + StarterKit) | 360 KB / **114 KB gz** |
| `assets/node_modules/` gitignored in dev harness | Already ignored |

**Correction to a common claim:** Phoenix 1.8 generates `assets/tsconfig.json` with
`"paths": {"*": ["../deps/*"]}`, and it is often said this hijacks every bare specifier. **It does not.**
TS `paths` are *tried first and fall back* — `@tiptap/core` → `../deps/@tiptap/core` (missing) →
`assets/node_modules/@tiptap/core` ✓. It only bites when a package name collides with a real
`deps/` entry or a `vendor/` file, and that fails loudly with a clear esbuild error. So **we do not
edit the user's tsconfig**; at most we print a notice pointing at Phoenix's own comment in that file.

## 6. LiveView contract for editor hooks (non-obvious, verified against LV 1.2.7)

- **Put `phx-update="ignore"` on an INNER element**, not the styled wrapper. On an ignored element
  LiveView merges `data-*` **only** — `class`, `style`, `aria-*` are frozen at first render.
- **Stable `id` is mandatory** — a changed id makes morphdom replace the node, destroying the editor
  and its undo history. Generate a compile-time raise if `id` is missing.
- **Hidden mirror input carries `name`, never `phx-change`** — form recovery filters out elements that
  have `phx-change`, so putting it there silently loses the document on reconnect.
- **`flush()` must `dispatchEvent(new Event("input", {bubbles: true}))`** — same rule the rest of our
  engines already follow; without it `<.form phx-change>` never fires.
- **`phx-debounce="blur"` is a no-op on a hidden input** (hidden inputs never blur). Debounce in the hook.
- **Namespace pushed events per instance** (`chelekom:set:<id>`) — `push_event/3` dispatches to *every*
  hook listening for that name; two editors on a page would both react.
- **`destroyed()` must call `editor.destroy()`** + clear timers + abort listeners — the single biggest leak.
- `mounted()` does **not** re-run on rejoin; use `reconnected()` to re-assert client truth.

## 7. Risks

| Risk | Mitigation |
|---|---|
| **No Node on the machine** | Default to `mix-bun` — the hex bun binary needs nothing from the host. Escape hatch: `--pm npm`. (Verify whether to bump `{:bun, "~> 1.0"}` → `~> 2.0` and re-pin `version:` before relying on it) |
| **Docker / CI builds** | Loud failure (esbuild exits 1). Phoenix's Dockerfile has no Node **and `.dockerignore` excludes `assets/node_modules`** — committing it does not help. Fixed by the mix.exs alias wiring (step 3); with `mix-bun` the Dockerfile needs no change |
| **Bundle size** | Opt-in only — nothing installs unless generated. `--minimal` flag, languages chosen at generate time, size printed as a notice. Note: dynamic `import()` does **not** help — our esbuild args set neither `--splitting` nor esm output, so it inlines |
| **XSS** | Default TipTap to **JSON storage** (`getJSON()`), never `raw/1` on stored HTML. For HTML users, generate an `html_sanitize_ex ~> 1.5` scrubber **matched to the editor's own schema** (built-in `basic_html` strips alignment/colors/colspan; `html5` allows `iframe`/`object`). Don't add DOMPurify — client-side sanitization has no authority over what's POSTed at the socket |
| **Uninstall** | Extend the existing `:scripts` refcount fold to `:npm`, emit `mishka.assets.deps <pkgs> --remove` **only for packages no remaining component declares**. Never delete `package.json`, never strip aliases |

## 8. Roadmap

- [ ] **Phase 0 — pipeline only, no editor.** Fill `check_package_json/2`; add `:npm` / `:license` /
      `:libs` keys; alias wiring; `:npm` refcount in uninstall; bun pin review. Prove with an
      integration test that generates a throwaway one-package catalog into `development/`, asserts the
      exact file diff, then runs `mix assets.build` and asserts exit 0. *De-risks deployment before any
      114 KB dependency exists.*
- [ ] **Phase 1 — `editor` (TipTap 3).** The HTML editor, first. Everything lands here: the hook
      contract in §6, the typography section in `mishka_chelekom_headless.css`, `hex_deps` +
      generated `html_sanitize_ex` scrubber, and the JSON-by-default / HTML-opt-in storage decision.
      Toolbar = HEEx slots reusing our existing headless `toolbar` component. Ships with the
      `libs:` map in place but only `tiptap` populated.
- [ ] **Phase 2 — `code_editor` (CodeMirror 6).** Cheap after Phase 1 — same pipeline, plain-string
      content, no sanitization, no typography CSS. Flags `--minimal`, `--language`.
- [ ] **Phase 3 — breadth, no new deps.** CodeMirror: readonly viewer, diff, more `lang-*` (note
      `codemirror-lang-elixir` is Apache-2.0, not MIT). TipTap: bubble/floating menu (adds
      `@floating-ui/dom`), list + table extension packs.
- [ ] **Phase 4 — on demand.** `markdown_editor` (Milkdown). Re-evaluate Lexical at 1.0. Monaco stays
      rejected → point at `live_monaco_editor`.
