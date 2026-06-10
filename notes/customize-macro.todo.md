# `customize` / `skin` Kit — ✅ IMPLEMENTED (2026-06-11)

Status: built 100% in Spark and shipped. Library: `lib/mishka_chelekom/kit/{dsl,runtime}.ex`,
`kit/transformers/generate.ex`, `kit.ex` (base + Info + safelist). Tests: `test/mishka_chelekom/kit_test.exs`
(8, green; full suite 477 green). Showcase: `development/.../kit.ex` + `kit_live.ex` + updated
component/headless pages. Dead code deleted: `component.ex` (from-scratch macro), `kit/components.ex`,
old `kit/dsl.ex`+`kit.ex`, `component_test.exs`, dev `macro_*`/`kit_components`.

Spark features used: Section (`top_level?`), Entity (`args`, `schema`, `entities`, `auto_set_fields`,
`identifier`), **Transformer + `eval/3`** (wrapper codegen), **Verifier** (no-op guard), **InfoGenerator**.
Runtime: remap custom value → neutral `base` + Tailwind-v4 trailing-`!` classes; `Kit.safelist/1` for purge.

## Next Spark options to consider (related to the macro) — see chat
preset · compose · rename/alias · trim(only) · tokens · variant×color matrix · doc/MCP export ·
Spark fragments · Spark.Dsl.Patch (let plugins extend a Kit) · `mix spark.cheat_sheets` · `mix spark.formatter`.

---
# (original design notes below)

# TODO — `customize` macro (Kit) for Mishka Chelekom components

Goal: a **new, opt-in** way to customize *existing* Mishka components (styled + headless) — NOT
build HTML from scratch. Existing CLI-generated components keep working as normal components; the
macro is additive sugar. Lives as a **Spark entity inside `MishkaChelekom.Kit`**, generated into
the user's project.

## Key analysis findings (why the design is what it is)
- CLI components compose class as a **plain list** `[default, size, color_variant(@variant,@kind), …, @class]`.
- **No tailwind-merge** and **no `Overrides` hook** in CLI components → caller `@class` only wins with Tailwind `!` (important).
- `color_variant/…` has **no fallback clause** → an unknown color/variant passed straight to the component **crashes**.
- ⇒ Therefore: **change NOTHING in the generated components.** Implement `customize` as a **wrapper** the macro generates.

## Styled — `customize`

```elixir
defmodule MyAppWeb.Kit do
  use MishkaChelekom.Kit

  customize :button do
    color   :primary, "bg-indigo-600 text-white"        # REPLACE (name exists)
    color   :brand,   "bg-brand-500 text-white"          # ADD (new name)
    variant :glow,    "shadow-[0_0_20px_currentColor]"   # ADD
    size    :small,   "h-8 px-3 text-xs"                 # REPLACE
    default color: :brand, size: :medium
  end
end
```

Rule: **same value name ⇒ replace · new name ⇒ add.** Applies to `color`, `variant`, `size`,
`padding`, `rounded`. Use it by importing your module → `<.button color={:brand} variant="glow">`.

### Generated wrapper (button.ex stays untouched)
```elixir
def button(assigns) do
  {variant, color, extra} = resolve(assigns)   # macro-built lookup of your custom names
  assigns =
    assigns
    |> assign(:variant, variant)   # added "glow" → safe "base"; existing kept
    |> assign(:color, color)       # added :brand → safe "natural"; existing kept
    |> assign(:class, [extra, assigns[:class]])  # your classes (prefixed `!`) + caller's
  MyAppWeb.Components.Button.button(assigns)     # delegate to the REAL component
end
```
- replace → keep the real value, append your `!`-classes (win over source, structure intact).
- add → map the new value to a neutral safe value (no crash), append your `!`-classes.
- everything else → passed straight through.

✅ CLI components unchanged · ✅ non-macro users unaffected · ✅ opt-in · ✅ no regeneration.

### Open questions / impl notes
- How `resolve/1` knows the real component module (config? convention `…Web.Components.<Name>`?).
- "Safe value" per component = its colorless `base` variant / `natural` color (confirm each).
- Whether to auto-prefix `!` or document that replace = "wins on conflicts".
- Spark entity: `@customize` section with `color/variant/size/padding/rounded/default` entities.

## Unstyled (headless) — `skin`  (TODO: flesh out)
Headless ships no colors → no color/variant matrix to replace. Customizing = **fixed per-part
styling + default props**, under a name. Wrapper sets the root `class` with `[&_[data-part=X]]:`
variants compiled from your per-part classes. No headless component change.
(See follow-up notes.)
