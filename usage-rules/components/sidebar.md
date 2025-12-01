# Sidebar Component

Collapsible navigation panel with toggle functionality.

**Documentation**: https://mishka.tools/chelekom/docs/sidebar

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component sidebar
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | `sidebar.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"large"` | Sidebar width |
| `hide_position` | `:string` | `"left"` | Side position (`left`, `right`) |

## Slots

### `inner_block` Slot

Sidebar content.

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Sidebar

```heex
<.sidebar id="main-sidebar" color="dark">
  <div class="p-4">
    <h2 class="text-white font-bold mb-4">Menu</h2>
    <nav class="space-y-2">
      <a href="#" class="block text-white hover:bg-white/10 p-2 rounded">Home</a>
      <a href="#" class="block text-white hover:bg-white/10 p-2 rounded">Products</a>
      <a href="#" class="block text-white hover:bg-white/10 p-2 rounded">Settings</a>
    </nav>
  </div>
</.sidebar>
```

### Right-Side Sidebar

```heex
<.sidebar id="right-sidebar" hide_position="right" color="white">
  <div class="p-4">
    Right sidebar content
  </div>
</.sidebar>
```

### Different Sizes

```heex
<.sidebar id="small-sidebar" size="small" color="dark">
  <div class="p-4">Small sidebar</div>
</.sidebar>

<.sidebar id="large-sidebar" size="large" color="dark">
  <div class="p-4">Large sidebar</div>
</.sidebar>
```

### Different Variants

```heex
<.sidebar id="bordered-sidebar" variant="bordered" color="white">
  Bordered sidebar
</.sidebar>

<.sidebar id="gradient-sidebar" variant="gradient" color="primary">
  Gradient sidebar
</.sidebar>
```

### Toggle Button

```heex
<.button phx-click={JS.dispatch("toggle-sidebar", to: "#main-sidebar")}>
  <.icon name="hero-bars-3" class="size-5" />
</.button>

<.sidebar id="main-sidebar" color="dark">
  Sidebar content
</.sidebar>
```

## Common Patterns

### App Navigation Sidebar

```heex
<.sidebar id="app-sidebar" color="dark" size="medium">
  <div class="flex flex-col h-full">
    <div class="p-4 border-b border-white/10">
      <img src="/logo.svg" alt="Logo" class="h-8" />
    </div>

    <nav class="flex-1 p-4 space-y-1">
      <a href="/" class="flex items-center gap-3 text-white p-2 rounded hover:bg-white/10">
        <.icon name="hero-home" class="size-5" />
        <span>Dashboard</span>
      </a>
      <a href="/users" class="flex items-center gap-3 text-white p-2 rounded hover:bg-white/10">
        <.icon name="hero-users" class="size-5" />
        <span>Users</span>
      </a>
      <a href="/settings" class="flex items-center gap-3 text-white p-2 rounded hover:bg-white/10">
        <.icon name="hero-cog-6-tooth" class="size-5" />
        <span>Settings</span>
      </a>
    </nav>

    <div class="p-4 border-t border-white/10">
      <.button variant="outline" color="white" full_width>
        Logout
      </.button>
    </div>
  </div>
</.sidebar>
```

### Mobile Menu

```heex
<.button class="md:hidden" phx-click={JS.dispatch("toggle-sidebar", to: "#mobile-menu")}>
  <.icon name="hero-bars-3" class="size-6" />
</.button>

<.sidebar id="mobile-menu" color="white" class="md:hidden">
  <div class="p-4">
    <nav class="space-y-2">
      <a href="/" class="block p-2">Home</a>
      <a href="/about" class="block p-2">About</a>
      <a href="/contact" class="block p-2">Contact</a>
    </nav>
  </div>
</.sidebar>
```
