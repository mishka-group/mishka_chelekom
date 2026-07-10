# Footer Component

Customizable footer component with sections for links, content, and copyright information.

**Documentation**: https://mishka.tools/chelekom/docs/footer

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component footer

# Generate with specific options
mix mishka.ui.gen.component footer --variant default,shadow --color natural,dark

# Generate specific component types only
mix mishka.ui.gen.component footer --type footer,footer_section

# Generate with custom module name
mix mishka.ui.gen.component footer --module MyAppWeb.Components.CustomFooter
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `footer/1` | Main footer container |
| `footer_section/1` | Section within footer |

## Attributes

### `footer/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Text size |
| `space` | `:string` | `"small"` | Space between sections |
| `padding` | `:string` | `"medium"` | Content padding |
| `rounded` | `:string` | `"none"` | Border radius |
| `max_width` | `:string` | `nil` | Max width constraint |
| `text_position` | `:string` | `"center"` | Text alignment |
| `class` | `:any` | `nil` | Custom CSS class |

### `footer_section/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `padding` | `:string` | `"none"` | Section padding |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

`inner_block` — footer content, including `footer_section` components.

## Available Options

| Group | Values |
|-------|--------|
| Variants | `base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient` |
| Colors | `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Space / Padding / Rounded | `extra_small`, `small`, `medium`, `large`, `extra_large` |

## Usage Examples

### Basic Footer

```heex
<.footer color="dark" padding="large">
  <.footer_section>
    <p>&copy; 2024 Company Name. All rights reserved.</p>
  </.footer_section>
</.footer>
```

### Multi-Section Footer (grid columns + bottom bar)

```heex
<.footer color="dark" variant="default" padding="extra_large" space="medium">
  <.footer_section class="max-w-7xl mx-auto">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
      <%# Brand Column %>
      <div class="col-span-1">
        <img src="/logo.svg" alt="Brand" class="h-10 mb-4" />
        <p class="text-gray-400">Building great products for amazing people.</p>
      </div>

      <%# Links Column %>
      <div>
        <h5 class="font-semibold text-white mb-4">Product</h5>
        <ul class="space-y-2 text-gray-400">
          <li><a href="/features" class="hover:text-white">Features</a></li>
          <li><a href="/pricing" class="hover:text-white">Pricing</a></li>
          <li><a href="/changelog" class="hover:text-white">Changelog</a></li>
        </ul>
      </div>

      <div>
        <h5 class="font-semibold text-white mb-4">Company</h5>
        <ul class="space-y-2 text-gray-400">
          <li><a href="/about" class="hover:text-white">About</a></li>
          <li><a href="/blog" class="hover:text-white">Blog</a></li>
          <li><a href="/careers" class="hover:text-white">Careers</a></li>
        </ul>
      </div>

      <div>
        <h5 class="font-semibold text-white mb-4">Support</h5>
        <ul class="space-y-2 text-gray-400">
          <li><a href="/help" class="hover:text-white">Help Center</a></li>
          <li><a href="/contact" class="hover:text-white">Contact</a></li>
          <li><a href="/status" class="hover:text-white">Status</a></li>
        </ul>
      </div>
    </div>
  </.footer_section>

  <%# Bottom bar section, separately padded %>
  <.footer_section class="border-t border-gray-700 mt-8 pt-8" padding="small">
    <div class="max-w-7xl mx-auto flex justify-between items-center">
      <p class="text-gray-400 text-sm">&copy; 2024 Company Inc.</p>
      <div class="flex gap-6 text-gray-400">
        <a href="/privacy" class="hover:text-white text-sm">Privacy</a>
        <a href="/terms" class="hover:text-white text-sm">Terms</a>
      </div>
    </div>
  </.footer_section>
</.footer>
```

Use multiple `<.footer_section>` blocks to separate a main grid area from a bordered bottom bar; each section can have its own `class`/`padding`.

### Different Variants

```heex
<.footer variant="default" color="natural">Default</.footer>
<.footer variant="shadow" color="white">Shadow</.footer>
<.footer variant="bordered" color="primary">Bordered</.footer>
<.footer variant="gradient" color="primary">Gradient</.footer>
```

### With Logo and Social Links

```heex
<.footer color="dark" padding="large">
  <.footer_section class="flex justify-between items-center">
    <img src="/logo-white.svg" alt="Logo" class="h-8" />
    <div class="flex gap-4">
      <a href="https://twitter.com"><.icon name="fa-twitter" /></a>
      <a href="https://github.com"><.icon name="fa-github" /></a>
      <a href="https://linkedin.com"><.icon name="fa-linkedin" /></a>
    </div>
  </.footer_section>
</.footer>
```

### Centered Simple Footer

```heex
<.footer color="natural" text_position="center" padding="medium">
  <.footer_section>
    <p>Made with love by the team</p>
    <p class="text-sm mt-2">&copy; 2024 All rights reserved.</p>
  </.footer_section>
</.footer>
```

### Newsletter Footer

```heex
<.footer color="primary" variant="gradient" padding="large">
  <.footer_section class="text-center text-white">
    <h3 class="text-2xl font-bold mb-2">Subscribe to our newsletter</h3>
    <p class="mb-6 opacity-90">Get the latest updates directly to your inbox.</p>
    <div class="flex max-w-md mx-auto gap-2">
      <.email_field name="email" placeholder="Enter your email" class="flex-1" />
      <.button color="white">Subscribe</.button>
    </div>
  </.footer_section>
</.footer>
```
