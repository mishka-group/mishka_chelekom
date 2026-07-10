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
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant — see Variants |
| `color` | `:string` | `"base"` | Color theme — see Colors |
| `size` | `:string` | `"medium"` | Drawer width/height — see Sizes |
| `position` | `:string` | `"left"` | `left`, `right`, `top`, `bottom` |
| `rounded` | `:string` | `"none"` | Border radius |
| `border` | `:string` | `"none"` | Border style |
| `padding` | `:string` | `"medium"` | Content padding |
| `show` | `:boolean` | `false` | Initial visibility |
| `hide_close` | `:boolean` | `false` | Hide close button |
| `title_class` | `:string` | `nil` | Header title styling |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

- `header` — custom header content
- `inner_block` — main drawer content

## Helper Functions

Show/hide a drawer programmatically (both accept an optional leading `%JS{}` and optional trailing `options`):

```elixir
show_drawer(js \\ %JS{}, id)
show_drawer(js \\ %JS{}, id, options)

hide_drawer(js \\ %JS{}, id)
hide_drawer(js \\ %JS{}, id, options)
```

## Available Options

- **Variants**: `base`, `default`, `outline`, `transparent`, `bordered`, `gradient`
- **Colors**: `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`
- **Sizes**: `extra_small`, `small`, `medium`, `large`, `extra_large`
- **Position**: `left`, `right`, `top`, `bottom`

## Usage Examples

### Positions

```heex
<.button phx-click={show_drawer("left-drawer")}>Open Drawer</.button>

<.drawer id="left-drawer">
  <:header>Navigation</:header>
  <nav class="space-y-2">
    <a href="/" class="block p-2 hover:bg-gray-100 rounded">Home</a>
    <a href="/about" class="block p-2 hover:bg-gray-100 rounded">About</a>
    <a href="/contact" class="block p-2 hover:bg-gray-100 rounded">Contact</a>
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

### Without Close Button

Use `hide_close={true}` and close manually via `hide_drawer/1,2`:

```heex
<.drawer id="no-close-drawer" hide_close={true}>
  <:header>Manual Close Only</:header>
  <p>Content...</p>
  <.button phx-click={hide_drawer("no-close-drawer")}>Close</.button>
</.drawer>
```

## Common Patterns

### Mobile Navigation

```heex
<.button phx-click={show_drawer("mobile-nav")} class="md:hidden">
  <.icon name="hero-bars-3" />
</.button>

<.drawer id="mobile-nav" position="left" size="large">
  <:header>
    <div class="flex items-center gap-2">
      <img src="/logo.svg" class="h-8" />
      <span class="font-bold">MyApp</span>
    </div>
  </:header>
  <nav class="space-y-1">
    <a :for={item <- @nav_items} href={item.path} class="block p-3 hover:bg-gray-100 rounded">
      {item.label}
    </a>
  </nav>
</.drawer>
```

### Shopping Cart

```heex
<.button phx-click={show_drawer("cart-drawer")} class="relative">
  <.icon name="hero-shopping-cart" />
  <.badge :if={@cart_count > 0} class="absolute -top-2 -right-2">{@cart_count}</.badge>
</.button>

<.drawer id="cart-drawer" position="right" size="large">
  <:header>Shopping Cart ({@cart_count})</:header>
  <div class="space-y-4">
    <div :for={item <- @cart_items} class="flex gap-4 border-b pb-4">
      <img src={item.image} class="w-16 h-16 object-cover rounded" />
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
<.button phx-click={show_drawer("filters")}>
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
