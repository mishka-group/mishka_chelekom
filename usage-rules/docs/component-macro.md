# The `component` macro (MishkaChelekom.Component)

One declarative macro for **both** styled and headless components, with Pyro-style overrides
and class-merging built in. Original Mishka design.

```elixir
use MishkaChelekom.Component
```

> Trade-off: components authored with this macro use `mishka_chelekom` at **runtime** (like
> Doggo/Pyro). It is the opt-in alternative to the zero-runtime-dependency `mix mishka.ui.gen.*`
> generators. `phoenix_live_view` is an optional dependency; host Phoenix apps already provide it.

## Styled

```elixir
defmodule MyAppWeb.Components.Button do
  use MishkaChelekom.Component

  component :button,
    tag: :button,
    base: "inline-flex items-center font-medium rounded-md",
    variants: [
      color: [primary: "bg-primary text-primary-content", ghost: "bg-transparent hover:bg-base-200"],
      size:  [sm: "h-8 px-3 text-xs", md: "h-9 px-4 text-sm", lg: "h-11 px-6"]
    ],
    defaults: [color: :primary, size: :md]
end
```

```heex
<.button color={:ghost} size={:lg} class="px-6">Save</.button>
```

* `variants:` become real `attr`s with allowed values; `defaults:` set them.
* classes compose as `base ++ variant ++ project-override ++ caller-class` through
  `MishkaChelekom.Overrides` + `MishkaChelekom.CSS` (the caller's class wins).
* a `default` naming an undeclared value **fails at compile time**.

## Headless

```elixir
component :dialog,
  headless: true,
  hook: "FocusTrap",
  parts: [
    trigger:  [tag: :button, slot: true, aria: [haspopup: "dialog"]],
    backdrop: [tag: :div, aria: [hidden: "true"]],
    popup:    [tag: :div, role: "dialog", state: true,
               aria: [modal: "true", labelledby: {:ref, :title}],
               children: [
                 title:   [tag: :h2, id: true, slot: true],
                 content: [tag: :div, slot: :inner_block]
               ]]
  ]
```

```heex
<.dialog id="confirm" open={@open}>
  <:trigger>Open</:trigger>
  <:title>Confirm</:title>
  Body
</.dialog>
```

Generates `chelekom-dialog__<part>` classes, `data-part`, ARIA, paired-presence
`data-open`/`data-closed`, the JS `hook`, and named slots.

### Part options

| Option | Meaning |
|---|---|
| `tag:` | HTML tag (default `:div`) |
| `role:` | ARIA role |
| `aria:` | keyword of `aria-*`; value `{:ref, :other_part}` → `"#{@id}-other_part"` (id wiring) |
| `state: true` | emit `data-open`/`data-closed` from the `open` assign |
| `id: true` | give the part `id="#{@id}-<part>"` |
| `slot: true` | render the named `<:part>` slot here |
| `slot: :inner_block` | render the default slot here |
| `children:` | nested parts |

The root automatically gets `id={@id}`, the `phx-hook`, `class` (merged with the caller's),
`data-open`/`data-closed` (if any part uses `state`), and the global `@rest`.
