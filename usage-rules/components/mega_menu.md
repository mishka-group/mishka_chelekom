# Mega Menu Component

Multi-column navigation menu for complex site hierarchies.

**Documentation**: https://mishka.tools/chelekom/docs/mega-menu

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component mega_menu
mix mishka.ui.gen.component mega_menu --variant default,shadow --color white,natural
mix mishka.ui.gen.component mega_menu --module MyAppWeb.Components.CustomMegaMenu
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
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Text size |
| `space` | `:string` | `"small"` | Space between elements |
| `padding` | `:string` | `"medium"` | Content padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `clickable` | `:boolean` | `false` | Activate on click (default: hover) |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

- **`trigger`** — the element that activates the mega menu.
- **`inner_block`** — mega menu content (columns, links, sections).

## Available Options

| Option | Values |
|--------|--------|
| Variants | `base`, `default`, `outline`, `bordered`, `shadow`, `gradient` |
| Colors | `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Space / Padding / Rounded | `extra_small`, `small`, `medium`, `large`, `extra_large` |

## Usage Examples

### Basic (hover-activated, multi-column)

```heex
<.mega_menu>
  <:trigger>
    <button class="flex items-center gap-1">
      Products <.icon name="hero-chevron-down" class="size-4" />
    </button>
  </:trigger>
  <div class="grid grid-cols-3 gap-6 p-6">
    <div>
      <h3 class="font-bold mb-3">Category 1</h3>
      <ul class="space-y-2">
        <li><a href="#">Link 1</a></li>
        <li><a href="#">Link 2</a></li>
      </ul>
    </div>
    <div>
      <h3 class="font-bold mb-3">Category 2</h3>
      <ul class="space-y-2">
        <li><a href="#">Link 1</a></li>
        <li><a href="#">Link 2</a></li>
      </ul>
    </div>
  </div>
</.mega_menu>
```

### Click Activated

```heex
<.mega_menu clickable variant="shadow">
  <:trigger>
    <.button>
      Menu <.icon name="hero-chevron-down" class="size-4" />
    </.button>
  </:trigger>
  <div class="p-6">Menu content...</div>
</.mega_menu>
```

### Variant/Color Combos

```heex
<.mega_menu variant="default" color="white">Default</.mega_menu>
<.mega_menu variant="shadow" color="white">Shadow</.mega_menu>
<.mega_menu variant="bordered" color="natural">Bordered</.mega_menu>
```

## Common Patterns

### E-commerce Navigation (columns + promo card)

```heex
<nav class="flex items-center gap-6">
  <.mega_menu variant="shadow" padding="large" rounded="large">
    <:trigger>
      <button class="flex items-center gap-1 font-medium">
        Shop <.icon name="hero-chevron-down" class="size-4" />
      </button>
    </:trigger>
    <div class="grid grid-cols-4 gap-8 min-w-[800px]">
      <div>
        <h4 class="font-bold text-sm text-gray-500 uppercase mb-4">Women</h4>
        <ul class="space-y-2">
          <li><a href="/women/dresses" class="hover:text-primary-500">Dresses</a></li>
          <li><a href="/women/tops" class="hover:text-primary-500">Tops</a></li>
        </ul>
      </div>
      <div>
        <h4 class="font-bold text-sm text-gray-500 uppercase mb-4">Men</h4>
        <ul class="space-y-2">
          <li><a href="/men/shirts" class="hover:text-primary-500">Shirts</a></li>
          <li><a href="/men/pants" class="hover:text-primary-500">Pants</a></li>
        </ul>
      </div>
      <div>
        <h4 class="font-bold text-sm text-gray-500 uppercase mb-4">Kids</h4>
        <ul class="space-y-2">
          <li><a href="/kids/boys" class="hover:text-primary-500">Boys</a></li>
          <li><a href="/kids/girls" class="hover:text-primary-500">Girls</a></li>
        </ul>
      </div>
      <div class="bg-gray-50 p-4 rounded-lg">
        <h4 class="font-bold mb-2">New Arrivals</h4>
        <p class="text-sm text-gray-600 mb-4">Check out the latest styles</p>
        <.button_link navigate="/new-arrivals" color="primary" size="small">
          Shop Now
        </.button_link>
      </div>
    </div>
  </.mega_menu>
</nav>
```

### Product Cards (icon + title + description grid)

```heex
<.mega_menu variant="shadow" padding="extra_large">
  <:trigger>
    <button class="flex items-center gap-1">
      Products <.icon name="hero-chevron-down" class="size-4" />
    </button>
  </:trigger>
  <div class="grid grid-cols-3 gap-8 min-w-[700px]">
    <a href="/product-a" class="p-4 hover:bg-gray-50 rounded-lg group">
      <.icon name="hero-cube" class="size-8 text-primary-500 mb-3" />
      <h4 class="font-bold group-hover:text-primary-500">Product A</h4>
      <p class="text-sm text-gray-600 mt-1">Description of product A features.</p>
    </a>
    <a href="/product-b" class="p-4 hover:bg-gray-50 rounded-lg group">
      <.icon name="hero-chart-bar" class="size-8 text-primary-500 mb-3" />
      <h4 class="font-bold group-hover:text-primary-500">Product B</h4>
      <p class="text-sm text-gray-600 mt-1">Description of product B features.</p>
    </a>
  </div>
</.mega_menu>
```

### Resources Menu (using `.list` for items)

```heex
<.mega_menu variant="shadow" color="white">
  <:trigger>
    <button class="flex items-center gap-1">
      Resources <.icon name="hero-chevron-down" class="size-4" />
    </button>
  </:trigger>
  <div class="grid grid-cols-2 gap-6 p-6 min-w-[500px]">
    <div>
      <h4 class="font-bold mb-4">Learn</h4>
      <.list variant="transparent" size="small">
        <:item icon="hero-book-open" padding="small" class="hover:bg-gray-50 rounded">
          Documentation
        </:item>
        <:item icon="hero-academic-cap" padding="small" class="hover:bg-gray-50 rounded">
          Tutorials
        </:item>
      </.list>
    </div>
    <div>
      <h4 class="font-bold mb-4">Community</h4>
      <.list variant="transparent" size="small">
        <:item icon="hero-user-group" padding="small" class="hover:bg-gray-50 rounded">
          Forum
        </:item>
        <:item icon="hero-code-bracket" padding="small" class="hover:bg-gray-50 rounded">
          GitHub
        </:item>
      </.list>
    </div>
  </div>
</.mega_menu>
```
