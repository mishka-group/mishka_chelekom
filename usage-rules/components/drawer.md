# Drawer Component

Sliding panel component for displaying content from screen edges with customizable positioning and styling.

**Documentation**: https://mishka.tools/chelekom/docs/drawer

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component drawer
mix mishka.ui.gen.component drawer --variant default,outline --color primary,natural
mix mishka.ui.gen.component drawer --module MyAppWeb.Components.CustomDrawer
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier; the helpers take it |
| `title` | `:string` | `nil` | Title in the header, and the dialog's name; the `header` slot is used when it is `nil` |
| `description` | `:string` | `nil` | What screen readers announce as the drawer's description; `"Drawer content"` when `nil` |
| `position` | `:string` | `"left"` | `left`, `right`, `top`, `bottom` |
| `variant` | `:string` | `"base"` | Style variant — see Variants |
| `color` | `:string` | `"natural"` | Color theme — see Colors |
| `size` | `:string` | `"large"` | Width (`left`, `right`) or minimum height (`top`, `bottom`) — see Sizes |
| `border` | `:string` | `"extra_small"` | Border on the inner edge (`base`, `outline` and `bordered` only) |
| `show` | `:boolean` | `false` | Open the drawer when it mounts |
| `on_show` | `JS` | `%JS{}` | Commands run before the drawer opens on mount (`show`) |
| `on_hide` | `JS` | `%JS{}` | Commands run before Escape or the close button closes it |
| `on_hide_away` | `JS` | `%JS{}` | Commands run before a click outside closes it |
| `class` | `:any` | `nil` | Class of the drawer root |
| `title_class` | `:string` | `nil` | Class of the title (default `text-lg font-semibold`) |
| `wrapper_class` | `:string` | `nil` | Class of the panel |
| `content_class` | `:string` | `nil` | Class of the content |
| `close_class` | `:string` | `nil` | Class of the close button |
| `overlay_class` | `:string` | `nil` | Class of the backdrop |

Global attributes are passed to the root. The close button is always rendered.

The title or the `header` slot names the dialog (`aria-labelledby`). A drawer with neither has no
name unless you pass one with `aria-label`, a global attribute the root takes:
`<.drawer id="filters" aria-label="Filters">`.

## Slots

- `header` — header content, used when `title` is not set
- `inner_block` — main drawer content

## Helper Functions

Both take the drawer's `position`, which decides which way it slides:

```elixir
show_drawer(js \\ %JS{}, id, position)
hide_drawer(js \\ %JS{}, id, position)
```

`hide_drawer/2,3` called directly does not run `on_hide`.

## Keyboard and Focus

- Escape, a click outside the panel and the close button close the drawer.
- A closed drawer is `inert`: it is only moved off-screen, and `inert` keeps its controls out of
  the Tab order and away from screen readers.
- Opening moves focus to the first focusable element in the drawer (the close button), and Tab
  stays inside the drawer while it is open.
- Closing gives focus back to the element that had it when the drawer opened. A drawer opened
  while nothing had focus (with `show`, or from a button in Safari, which does not focus a clicked
  button) moves no focus when it closes.
- Opening locks the page's scroll (`overflow-hidden` on `<body>`) and closing unlocks it.
- Opening a drawer that is already open, or closing one that is already closed, leaves focus and
  the page's scroll alone, so a closed drawer never takes focus from another open dialog or unlocks
  the scroll under it.

## The Trigger

The drawer cannot reach the button that opens it, so the button's state is yours to keep. Give it
`aria-haspopup="dialog"`, `aria-controls` with the drawer's id, and an `aria-expanded` that the
open sets to `"true"` and every way of closing sets back to `"false"`: `on_hide` runs on Escape and
the close button, `on_hide_away` on a click outside, and a `hide_drawer/3` you call yourself runs
neither, so chain the same command to it.

```heex
<.button
  id="cart-trigger"
  aria-haspopup="dialog"
  aria-controls="cart-drawer"
  aria-expanded="false"
  phx-click={
    show_drawer("cart-drawer", "right")
    |> JS.set_attribute({"aria-expanded", "true"}, to: "#cart-trigger")
  }
>
  Cart
</.button>

<.drawer
  id="cart-drawer"
  position="right"
  title="Cart"
  on_hide={JS.set_attribute({"aria-expanded", "false"}, to: "#cart-trigger")}
  on_hide_away={JS.set_attribute({"aria-expanded", "false"}, to: "#cart-trigger")}
>
  <p>Content...</p>
  <.button phx-click={
    hide_drawer("cart-drawer", "right")
    |> JS.set_attribute({"aria-expanded", "false"}, to: "#cart-trigger")
  }>
    Keep shopping
  </.button>
</.drawer>
```

## Available Options

- **Variants**: `base`, `default`, `outline`, `transparent`, `bordered`, `gradient`
- **Colors**: `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`
- **Sizes**: `extra_small`, `small`, `medium`, `large`, `extra_large`
- **Borders**: `extra_small`, `small`, `medium`, `large`, `extra_large`
- **Position**: `left`, `right`, `top`, `bottom`

The `base` variant ignores `color`. `white` and `dark` are colors of `default` and `bordered`.

## Usage Examples

### Positions

```heex
<.button phx-click={show_drawer("left-drawer", "left")}>Open Drawer</.button>

<.drawer id="left-drawer">
  <:header>Navigation</:header>
  <nav class="space-y-2">
    <a href="/" class="block p-2 hover:bg-gray-100 rounded-sm">Home</a>
    <a href="/about" class="block p-2 hover:bg-gray-100 rounded-sm">About</a>
    <a href="/contact" class="block p-2 hover:bg-gray-100 rounded-sm">Contact</a>
  </nav>
</.drawer>

<!-- Same pattern for other edges: -->
<.drawer id="right-drawer" position="right">...</.drawer>
<.drawer id="top-drawer" position="top" size="small">...</.drawer>
<.drawer id="bottom-drawer" position="bottom">...</.drawer>
```

### Initially Visible

```heex
<.drawer id="sidebar" position="left" show={true}>
  <:header>Menu</:header>
  <nav>Navigation items...</nav>
</.drawer>
```

### Variants

```heex
<.drawer id="default-drawer" variant="default" color="natural">Default variant</.drawer>
<.drawer id="outline-drawer" variant="outline" color="primary">Outline variant</.drawer>
<.drawer id="gradient-drawer" variant="gradient" color="primary">Gradient variant</.drawer>
```

### Custom Header Styling

```heex
<.drawer id="styled-drawer" title_class="text-2xl font-light text-primary-500">
  <:header>Custom Styled Header</:header>
  <p>Drawer content...</p>
</.drawer>
```

### Closing From Inside

```heex
<.drawer id="confirm-drawer" position="bottom" title="Discard changes?">
  <p>Content...</p>
  <.button phx-click={hide_drawer("confirm-drawer", "bottom")}>Keep editing</.button>
</.drawer>
```

## Common Patterns

### Mobile Navigation

```heex
<.button phx-click={show_drawer("mobile-nav", "left")} class="md:hidden">
  <.icon name="hero-bars-3" />
</.button>

<.drawer id="mobile-nav" position="left" size="large">
  <:header>
    <div class="flex items-center gap-2">
      <img src="/logo.svg" alt="" class="h-8" />
      <span class="font-bold">MyApp</span>
    </div>
  </:header>
  <nav class="space-y-1">
    <a :for={item <- @nav_items} href={item.path} class="block p-3 hover:bg-gray-100 rounded-sm">
      {item.label}
    </a>
  </nav>
</.drawer>
```

### Shopping Cart

```heex
<.button phx-click={show_drawer("cart-drawer", "right")} class="relative">
  <.icon name="hero-shopping-cart" />
  <.badge :if={@cart_count > 0} class="absolute -top-2 -right-2">{@cart_count}</.badge>
</.button>

<.drawer id="cart-drawer" position="right" size="large">
  <:header>Shopping Cart ({@cart_count})</:header>
  <div class="space-y-4">
    <div :for={item <- @cart_items} class="flex gap-4 border-b pb-4">
      <img src={item.image} alt={item.name} class="w-16 h-16 object-cover rounded-sm" />
      <div class="flex-1">
        <p class="font-medium">{item.name}</p>
        <p class="text-gray-500">${item.price}</p>
      </div>
    </div>
  </div>
  <div class="mt-auto pt-4 border-t">
    <div class="flex justify-between mb-4">
      <span>Total:</span>
      <span class="font-bold">${@cart_total}</span>
    </div>
    <.button full_width color="primary">Checkout</.button>
  </div>
</.drawer>
```

### Filter Panel

```heex
<.button phx-click={show_drawer("filters", "right")}>
  <.icon name="hero-funnel" /> Filters
</.button>

<.drawer id="filters" position="right">
  <:header>Filters</:header>
  <.form for={@filter_form} phx-change="filter">
    <div class="space-y-4">
      <div>
        <label class="font-medium">Category</label>
        <.group_checkbox field={@filter_form[:categories]}>
          <:checkbox :for={cat <- @categories} value={cat.id} label={cat.name} />
        </.group_checkbox>
      </div>
      <div>
        <label class="font-medium">Price Range</label>
        <.range_field field={@filter_form[:price]} min={0} max={1000} />
      </div>
    </div>
    <.button type="submit" class="mt-4">Apply Filters</.button>
  </.form>
</.drawer>
```
