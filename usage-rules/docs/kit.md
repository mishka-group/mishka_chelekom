# The Kit — one DSL for your whole design system

`MishkaChelekom.Kit` is a single [Spark](https://hexdocs.pm/spark) DSL that describes your entire
design system in one module, and drives **four** outputs from that one declaration. It is
**additive and non-breaking**: components you generated or wrote keep working standalone — the Kit
only layers options on top.

```elixir
defmodule MyAppWeb.Kit do
  use MishkaChelekom.Kit

  tokens do
    color :brand, "oklch(62% 0.2 255)"
    radius :md, "0.75rem"
    space :gap, "1rem"
  end

  # ① MODIFY an existing component — trim options, set defaults, restyle a part
  component :button do
    only_colors [:primary, :danger]
    only_sizes  [:small, :medium, :large]
    default     color: :primary, size: :medium
    override    :root, "rounded-full"
  end

  # ② ADD a brand-new headless component from its parts
  headless :star_rating do
    hook "Rating"
    part :star, tag: :button, role: "radio", repeat: 5
  end

  headless :faq do
    hook "Disclosure"
    part :trigger, tag: :button, id: true, slot: true,
                   aria: [controls: {:ref, :panel}, expanded: "false"]
    part :panel,   tag: :div, id: true, role: "region", state: true,
                   aria: [labelledby: {:ref, :trigger}], slot: :inner_block
  end

  # ③ COMPOSE existing components into a new one
  compose :search_box do
    place :text_field, props: [placeholder: "Search…"]
    place :button,     props: [color: :primary]
  end
end
```

## The four outputs

| # | Output | How |
|---|--------|-----|
| 🏭 | **Generation config** | `MishkaChelekom.Kit.gen_config(MyAppWeb.Kit)` returns the `component_colors`/`component_variants`/`component_sizes` trim that `mix mishka.ui.gen.*` honors. Merge it into your generator config. |
| 🎨 | **Runtime theming** | The Kit module **is** a `MishkaChelekom.Overrides` source (it exposes `__overrides__/0`). Set `config :mishka_chelekom, overrides: [MyAppWeb.Kit]` and every styled component composes the Kit's `override`s in (first-wins). |
| 🧩 | **New components** | `use MishkaChelekom.Kit.Components, kit: MyAppWeb.Kit` in a companion module materializes each `headless` declaration into a real Phoenix component. |
| 🤖 | **Introspection** | `MishkaChelekom.Kit.Info` (structured) and `MishkaChelekom.Kit.describe/1` (Markdown for docs/LLMs); `MishkaChelekom.Kit.safelist/1` lists every override class to keep through Tailwind purge. |

## Sections & entities

### `tokens do … end`
`color :name, "value"`, `radius :name, "value"`, `space :name, "value"` — shared design tokens
(introspect with `Kit.Info.tokens/1`, grouped by `:kind`).

### `component :name do … end` — modify an EXISTING component
Never re-declares HTML; only layers options:
- `only_variants [..]` / `only_colors [..]` / `only_sizes [..]` — trim the allowed option set.
- `default key: value` — set defaults. **Compile-time checked**: a default outside its `only_*`
  set raises a `Spark.Error.DslError`.
- `override :part, "classes"` — Pyro-style class override for `{component, part}`.

### `headless :name do … end` — define a NEW component
- `hook "JsHook"` — the JS behavior hook attached to the root.
- `part :name, opts` — one anatomy part; nest with a `do … end` block (`part :outer do part :inner … end`).

Part options: `tag:` (default `:div`), `role:`, `state: true` (paired-presence
`data-open`/`data-closed`), `id: true` (`id="#{@id}-name"`), `slot: true` (named `<:name>` slot) or
`slot: :inner_block` (default slot), `repeat: n` (n sibling parts, e.g. 5 stars),
`aria: [key: value]` where a value of `{:ref, :other_part}` resolves to `"#{@id}-other_part"`.

The generated component is an ordinary Phoenix component with the full headless contract:
`chelekom-<comp>__<part>` classes, `data-part`, ARIA, state, and the hook.

### `compose :name do … end` — compose existing components
`place :component, props: [..]` — currently introspection-level (`Kit.Info.composes/1`).

## Usage

```elixir
# Companion module — turns the Kit's `headless` declarations into <.star_rating> / <.faq>
defmodule MyAppWeb.KitComponents do
  use MishkaChelekom.Kit.Components, kit: MyAppWeb.Kit
end

# Theming — make the Kit's overrides global (first-wins over component base classes)
config :mishka_chelekom, overrides: [MyAppWeb.Kit]

# Introspection
MishkaChelekom.Kit.describe(MyAppWeb.Kit)   # => Markdown summary of the whole system
MishkaChelekom.Kit.safelist(MyAppWeb.Kit)   # => ["rounded-full", ...] for Tailwind safelist
```

> The generated/companion components use `mishka_chelekom` at runtime (like the `component` macro),
> which is why `phoenix_live_view` is an **optional** dependency. The zero-runtime path is still
> `mix mishka.ui.gen.*`; the Kit's `gen_config/1` feeds that path.
