# Divider Component

Horizontal and vertical divider lines with customizable styles, colors, and optional text/icon content.

**Documentation**: https://mishka.tools/chelekom/docs/divider

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component divider

# Generate with specific options
mix mishka.ui.gen.component divider --color primary,natural --size small,medium

# Generate specific component types only
mix mishka.ui.gen.component divider --type divider,hr

# Generate with custom module name
mix mishka.ui.gen.component divider --module MyAppWeb.Components.CustomDivider
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
| `divider/1` | Divider with optional text/icon |
| `hr/1` | Simple horizontal rule |

## Attributes

### `divider/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `type` | `:string` | `"solid"` | Line style: `solid`, `dashed`, `dotted` |
| `color` | `:string` | `"base"` | Color theme: `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver` |
| `size` | `:string` | `"extra_small"` | Line thickness: `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `position` | `:string` | `"center"` | Content position: `start`, `center`, `end` |
| `orientation` | `:string` | `"horizontal"` | Direction: `horizontal`, `vertical` |
| `width` | `:string` | `nil` | Custom width |
| `height` | `:string` | `nil` | Custom height (for vertical) |
| `margin` | `:string` | `nil` | Custom margin |
| `class` | `:any` | `nil` | Custom CSS class |

### `hr/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `:string` | `"base"` | Color theme (same options as `divider/1`) |
| `size` | `:string` | `"extra_small"` | Line thickness (same options as `divider/1`) |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

| Slot | Attribute | Type | Description |
|------|-----------|------|-------------|
| `text` | — | — | Text content displayed on the divider line |
| `icon` | `name` | `:string` | Icon name |
| `icon` | `class` | `:string` | Icon styling |

## Usage Examples

### Basic

```heex
<.divider />
<.hr />
```

### Text / Icon content

```heex
<.divider>
  <:text>Or</:text>
</.divider>

<.divider>
  <:icon name="hero-star" class="size-5 text-yellow-500" />
</.divider>
```

### Type, color, size, position

```heex
<.divider type="solid" />
<.divider type="dashed" />
<.divider type="dotted" />

<.divider color="primary" />
<.divider color="success" />
<.divider color="danger" />
<.divider color="warning" />

<.divider size="extra_small" />
<.divider size="small" />
<.divider size="medium" />
<.divider size="large" />

<.divider position="start">
  <:text>Start</:text>
</.divider>
<.divider position="center">
  <:text>Center</:text>
</.divider>
<.divider position="end">
  <:text>End</:text>
</.divider>
```

### Vertical divider

```heex
<div class="flex items-center h-20 gap-4">
  <span>Item 1</span>
  <.divider orientation="vertical" height="100%" />
  <span>Item 2</span>
  <.divider orientation="vertical" height="100%" />
  <span>Item 3</span>
</div>
```

### Combined type + color + position/size

```heex
<.divider type="dashed" color="primary" position="center">
  <:text>Section Break</:text>
</.divider>

<.divider type="dotted" size="medium">
  <:icon name="hero-circle-stack" class="p-2 bg-white text-yellow-600" />
</.divider>
```

## Common Patterns

### Login form divider

```heex
<.divider color="natural">
  <:text class="px-4 bg-white text-gray-500 text-sm">
    Or continue with
  </:text>
</.divider>
```

### Section separator (icon + margin)

```heex
<.divider type="dashed" color="natural" margin="my-8">
  <:icon name="hero-sparkles" class="size-6 text-primary-500 bg-white px-2" />
</.divider>
```

### Footer divider (`hr`)

```heex
<.hr color="natural" size="small" class="my-6" />
```

### Content sections

```heex
<article>
  <h2>Section 1</h2>
  <p>Content...</p>

  <.divider type="solid" color="natural" margin="my-6" />

  <h2>Section 2</h2>
  <p>Content...</p>
</article>
```

### Inline items (vertical, compact height)

```heex
<div class="flex items-center gap-4">
  <span>Home</span>
  <.divider orientation="vertical" height="1rem" color="natural" />
  <span>Products</span>
  <.divider orientation="vertical" height="1rem" color="natural" />
  <span>Contact</span>
</div>
```
