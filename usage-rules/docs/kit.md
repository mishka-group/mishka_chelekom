# The Kit — reuse & restyle your components

`MishkaChelekom.Kit` is an opt-in [Spark](https://hexdocs.pm/spark) DSL that **reuses and restyles the components you already have** — it never builds HTML from scratch and never edits a component's file. Each `customize` generates a thin wrapper function that transforms `assigns` and delegates to the real styled or headless component. It is additive: your components keep working standalone.

```elixir
defmodule MyAppWeb.Kit do
  use MishkaChelekom.Kit

  # STYLED component — add/replace colors, variants, sizes, … (classes verbatim; write the `!`)
  customize :button do
    color :primary, "bg-indigo-600! text-white!"       # replace an existing name
    color :brand,   "bg-brand-500! text-white!"         # add a new one
    variant :glow,  "shadow-[0_0_20px_currentColor]!"
    default color: :brand
  end

  # HEADLESS component — style its parts (write the full `[&_[data-part=…]]:` variant)
  customize :confirm_dialog do
    from :dialog
    part :popup, "[&_[data-part=popup]]:rounded-2xl [&_[data-part=popup]]:p-6"
    part :title, "[&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold"
  end
end
```

## `customize :name do … end`

The one verb. The macro infers the target world from the **rules you write** — never mix both in one block:

- **styled** rules: `color`, `variant`, `size`, `padding`, `rounded`, `space`, `border`, `width`, `kind` — written `dimension :value, "classes"`.
- **headless** rule: `part :name, "classes"`.

Options inside the block:

| Option | Meaning |
|--------|---------|
| `from:` | Component to reuse. Defaults to the `customize` name. A **bare atom** resolves by convention (`<Web>.Components.<Name>` for styled, `<Web>.Components.Headless.<Name>` for headless); a **`{Module, :function}` tuple** targets an exact function verbatim. |
| `base:` | The neutral value a customized dimension falls back to on the real component (default `"base"`). |
| `default:` | Keyword list of default props for the generated wrapper, e.g. `default color: :brand`. |

Pair a rule on the **variant×color** axis for a combo-specific rule (mirrors how components key `color_variant(variant, color)`):

```elixir
customize :alert do
  variant :bordered, "border-2 border-red-600!", color: :danger   # matches only bordered × danger
end
```

## Rules (compile-time checked)

- Classes are used **verbatim** — write them whole, including the trailing `!` for precedence (styled) and the full `[&_[data-part=…]]:` variant (headless). Because they are literal strings in your module, Tailwind scans them straight from the file: **no safelist, no `@source inline`**.
- A `customize` must declare **at least one** rule and may **not** mix styled rules with a `part`.
- A pair must pin the **other** axis (a `variant` rule with `color:`, or a `color` rule with `variant:`).
- `from:` must be a real component of the inferred kind (a "did you mean?" hint is offered), unless it is a `{Module, :function}` tuple or you set a custom namespace.
- Two `customize`s may not generate the same name.

## Namespaces & introspection

- `components MyAppWeb.Components` / `headless MyAppWeb.Components.Headless` — override the module namespace the convention resolves against (top-level options).
- `MishkaChelekom.Kit.Info.customizes(MyAppWeb.Kit)` — list every `customize` entry.
- Reach a wrapper by remote call so it never clashes with the globally-imported original: `<MyAppWeb.Kit.button color="brand">…</MyAppWeb.Kit.button>`.

## Shipping to production — `mix mishka.ui.gen.kit`

Generated components are plain code with no runtime dependency, but the Kit is a **live macro**: `use` runs Spark transformers at compile time and each wrapper calls the runtime at render time. So, unlike components, it cannot ride a `only: :dev, runtime: false` install of `mishka_chelekom`.

Run once to **vendor the engine into your app**:

```bash
mix mishka.ui.gen.kit
```

This copies the engine to `lib/<app>/kit/` (default module `<App>.Kit`, override with `--module`), regenerates a **self-contained catalog** (no read of chelekom's `priv/`), adds `{:spark, "~> 2.7"}` to `mix.exs` via Igniter (`--no-deps` to skip), and scaffolds a `<App>.Kit.Customizations` starter (`--no-starter` to skip) — everything under one folder, with **zero `mishka_chelekom` references**. Write your `customize` blocks in that starter (`use <App>.Kit`) and keep chelekom dev-only:

```elixir
{:mishka_chelekom, "~> 0.0.9", only: :dev, runtime: false},
{:spark, "~> 2.7"}
```

Re-run the task any time to refresh the engine and the catalog snapshot after adding components.
