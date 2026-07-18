# External JS libraries — editors (plan)

How Chelekom ships components that depend on an **npm package** (first case: editors), while keeping
the promise: *the developer runs one `mix` task and has a working editor — no manual config.*

## TL;DR

1. **No new mix command.** `mix mishka.ui.gen.headless editor` is the entry point. The npm install
   is an implementation detail of the catalog. ✅ *shipped*
2. **We already own the whole install path** — `mishka.assets.deps` + `mishka.assets.install` detect
   npm/bun/yarn and fall back to the `{:bun, ...}` hex binary when the machine has no Node. We call
   its functions directly (never `compose_task` — both drive an `Owl.Spinner` under the same id).
   ✅ *shipped*
3. **One `editor` component, engine chosen by `--lib`** (tiptap ✅ shipped; lexical / code_mirror /
   milk_down are data + one engine file each, once `--lib` lands — see §1).
4. **Still open:** how a developer adds TipTap extensions without hand-editing a generated file —
   see §3a.

## 1. What editors we can have

### Naming — ONE `editor` component, the library chosen by `--lib`

There is a single `editor` component. Which external library backs it is an install-time choice,
not a different component name — the developer's markup, attrs and `data-part` contract are
identical whichever engine they pick:

```bash
mix mishka.ui.gen.headless editor                    # default engine (tiptap)
mix mishka.ui.gen.headless editor --lib tiptap       # HTML / rich text
mix mishka.ui.gen.headless editor --lib lexical      # HTML / rich text, Meta's engine
mix mishka.ui.gen.headless editor --lib code_mirror  # code / syntax highlighting
mix mishka.ui.gen.headless editor --lib milk_down    # markdown source
```

`--lib` takes the **external library's name**, so it reads as what it is. The catalog's `libs:` map
holds one entry per engine; every entry pins its own npm packages and its own engine file, and all
of them must register the **same hook module** so the template never branches (asserted by
`catalog_integrity_test.exs`).

```elixir
libs: [
  tiptap:      [default: true, npm: [...], scripts: [%{module: "Editor", file: "editor_tiptap.js", ...}]],
  lexical:     [npm: [...], scripts: [%{module: "Editor", file: "editor_lexical.js", ...}]],
  code_mirror: [npm: [...], scripts: [%{module: "Editor", file: "editor_code_mirror.js", ...}]],
  milk_down:   [npm: [...], scripts: [%{module: "Editor", file: "editor_milk_down.js", ...}]]
]
```

**Status:** the `libs:` map ships and `tiptap` is populated; the `--lib` flag itself is **not yet
implemented**. Two things must be solved first, and they are the real work:

1. **Content format.** `format` is `json | html` today. CodeMirror's document is a plain string and
   Milkdown's is markdown, so the attr grows a `text` / `markdown` value and each engine declares
   which formats it supports. The catalog test should reject a `format` an engine cannot produce.
2. **The orphan-package bug.** Re-running without `--lib` after choosing a non-default engine would
   swap the engine file back while leaving the previous library's packages stranded in
   `package.json`. The chosen lib must be persisted (`priv/mishka_chelekom/config.exs`, next to
   `component_prefix` / `module_prefix`) and a switch must remove the old library's packages via the
   refcount path that `mix mishka.ui.uninstall --include-npm` already uses.

Engine-specific attrs (`language` for CodeMirror, toolbar command sets) stay optional and are simply
ignored by engines that do not use them.

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

✅ **Done.** `check_package_json/3` now resolves the catalog's `npm:` and calls
`MishkaChelekom.Generators.Npm` directly, then gitignores `assets/node_modules` and prepends
`mishka.assets.install` to the `assets.setup`/`build`/`deploy` aliases so CI and Docker builds work.

Public API delta, as shipped:

- `--no-npm` — write everything, skip the install (air-gapped/CI; also keeps `igniter.tasks` empty,
  so Igniter never shells out to `mix deps.get`).
- `--with-npm` on the **batch** generators — npm-backed components are skipped by
  `mix mishka.ui.gen.headless.components` by default, because "generate everything" must not
  silently pull a third-party dependency and edit `mix.exs`. Naming the component also works.
- `--include-npm` on `mix mishka.ui.uninstall` — off by default; even then a package is removed only
  when the manifest still pins the exact version we declared, since `package.json` is the user's file.
- No `--pm` flag: the existing auto-detect + bun fallback is used unchanged.

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

## 3a. Extensions / plugins — configuring the editor WITHOUT the CLI

Open question the first release does not answer. TipTap's value is its extension ecosystem
(tables, images, links, mentions, task lists, collaboration…), and the generated engine hardcodes
`extensions: [StarterKit]`. Today a developer who wants `@tiptap/extension-table` has to npm-install
it and hand-edit `assets/vendor/editor_tiptap.js` — a **generated file that the next
`mix mishka.ui.gen.headless editor` overwrites**. That is the single worst papercut in the current
design and must be fixed before the component is widely used.

**Recommended: a user-owned config file the generator writes once and never touches again.**

- The generator creates `assets/vendor/editor_extensions.js` with `on_exists: :skip` (the same
  never-clobber treatment `priv/mishka_chelekom/config.exs` already gets), containing a documented
  stub:

  ```js
  // Your editor extensions. Chelekom created this file once and will never overwrite it.
  // Install the package yourself (mix mishka.assets.deps @tiptap/extension-table@3.28.0)
  // and add it here; the engine merges these after StarterKit.
  export default [];
  ```

- The engine imports it and merges: `extensions: [StarterKit, ...userExtensions]`. A missing file is
  not possible (the generator wrote it), and an empty array is the default.
- Extension **npm packages** are installed with the facility that already exists —
  `mix mishka.assets.deps @tiptap/extension-table@3.28.0` — so no new command is needed for that
  either. The catalog only pins the packages the engine itself imports.

Why not the alternatives:

- **CLI flags** (`--with table,image`) — the maintainer's requirement is configuration *without* the
  CLI, and it would put an unbounded list of every library's extensions into our schema.
- **`data-*` allowlist on the component** — limits users to extensions we thought of, and pulls
  their npm packages into our catalog whether or not they are used.
- **Editing the generated engine** — works until the next regeneration silently reverts it.

Two related items to settle at the same time: StarterKit's own options (heading levels, history
depth) want the same treatment (a second export from that file, merged into the constructor), and
extensions that ship required CSS collide with the "no required stylesheet" admission rule — the
docs must say that styling an extension's DOM is the consumer's job.

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

## 4. End-to-end: what `mix mishka.ui.gen.headless editor` does

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

- [x] **Phase 0 — pipeline only, no editor.** *(done)* Fill `check_package_json/2`; add `:npm` / `:license` /
      `:libs` keys; alias wiring; `:npm` refcount in uninstall; bun pin review. Prove with an
      integration test that generates a throwaway one-package catalog into `development/`, asserts the
      exact file diff, then runs `mix assets.build` and asserts exit 0. *De-risks deployment before any
      114 KB dependency exists.*
- [x] **Phase 1 — `editor` (TipTap 3).** *(done — shipped with uninstall support, round-trip
      keys and CI-run JS tests; `--lib` deliberately still deferred)* The HTML editor, first. Everything lands here: the hook
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
