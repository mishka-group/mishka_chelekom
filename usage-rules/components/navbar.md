# Navbar Component

Responsive navigation bar with slots for logo, links, and actions.

**Documentation**: https://mishka.tools/chelekom/docs/navbar

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component navbar
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `navbar/1` | Navigation bar |
| `header/1` | Header variant |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `padding` | `:string` | `"small"` | Content padding |
| `rounded` | `:string` | `"none"` | Border radius |
| `space` | `:string` | `"small"` | Space between elements |
| `max_width` | `:string` | `nil` | Max width constraint |
| `position` | `:string` | `nil` | Fixed positioning |

## Slots

### `brand` Slot

Logo/brand area.

### `inner_block` Slot

Navigation links and content.

### `action` Slot

Action buttons area.

## Available Options

### Variants
`base`, `default`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

## Usage Examples

### Basic Navbar

```heex
<.navbar color="white" variant="shadow">
  <:brand>
    <img src="/logo.svg" alt="Logo" class="h-8" />
  </:brand>
  <nav class="flex gap-6">
    <a href="/">Home</a>
    <a href="/about">About</a>
    <a href="/contact">Contact</a>
  </nav>
  <:action>
    <.button color="primary">Sign Up</.button>
  </:action>
</.navbar>
```

### With Mobile Menu

```heex
<.navbar color="white" variant="shadow">
  <:brand>
    <img src="/logo.svg" alt="Logo" class="h-8" />
  </:brand>

  <%# Desktop nav %>
  <nav class="hidden md:flex gap-6">
    <a href="/">Home</a>
    <a href="/products">Products</a>
    <a href="/about">About</a>
  </nav>

  <%# Mobile menu button %>
  <.button
    class="md:hidden"
    variant="transparent"
    icon="hero-bars-3"
    phx-click={show_drawer("mobile-menu")}
  />

  <:action class="hidden md:flex">
    <.button color="primary">Get Started</.button>
  </:action>
</.navbar>
```

### Different Variants

```heex
<.navbar variant="default" color="natural">Default</.navbar>
<.navbar variant="shadow" color="white">Shadow</.navbar>
<.navbar variant="bordered" color="white">Bordered</.navbar>
<.navbar variant="gradient" color="primary">Gradient</.navbar>
```

## Common Patterns

### Full Header

```heex
<.navbar color="white" variant="shadow" padding="medium" max_width="7xl" class="mx-auto">
  <:brand>
    <a href="/" class="flex items-center gap-2">
      <img src="/logo.svg" alt="MyApp" class="h-8" />
      <span class="font-bold text-xl">MyApp</span>
    </a>
  </:brand>

  <nav class="hidden lg:flex items-center gap-6">
    <.mega_menu>
      <:trigger>Products</:trigger>
      <!-- Menu content -->
    </.mega_menu>
    <a href="/pricing">Pricing</a>
    <a href="/docs">Documentation</a>
  </nav>

  <:action>
    <div class="flex items-center gap-4">
      <a href="/login">Sign In</a>
      <.button color="primary">Start Free</.button>
    </div>
  </:action>
</.navbar>
```

### Dark Navbar

```heex
<.navbar color="dark" variant="default" padding="medium">
  <:brand>
    <img src="/logo-white.svg" alt="Logo" class="h-8" />
  </:brand>
  <nav class="flex gap-6 text-gray-300">
    <a href="/" class="hover:text-white">Home</a>
    <a href="/features" class="hover:text-white">Features</a>
    <a href="/pricing" class="hover:text-white">Pricing</a>
  </nav>
  <:action>
    <.button color="white">Get Started</.button>
  </:action>
</.navbar>
```
