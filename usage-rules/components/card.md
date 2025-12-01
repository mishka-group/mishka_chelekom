# Card Component

Flexible card layout with title, media, content, and footer sub-components for organizing content.

**Documentation**: https://mishka.tools/chelekom/docs/card

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component card

# Generate with specific options
mix mishka.ui.gen.component card --variant default,shadow,bordered --color primary,natural

# Generate specific component types only
mix mishka.ui.gen.component card --type card,card_title,card_content

# Generate with custom module name
mix mishka.ui.gen.component card --module MyAppWeb.Components.CustomCard
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
| `card/1` | Main card container |
| `card_title/1` | Card header with title and icon |
| `card_media/1` | Media element (image/video) |
| `card_content/1` | Card body content |
| `card_footer/1` | Card footer section |

## Attributes

### `card/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `border` | `:string` | `"extra_small"` | Border width |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"small"` | Space between elements |
| `padding` | `:string` | `"none"` | Padding size |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `class` | `:any` | `nil` | Custom CSS class |

### `card_title/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `:string` | `nil` | Header text |
| `icon` | `:string` | `nil` | Icon name |
| `icon_class` | `:string` | `nil` | Icon styling class |
| `position` | `:string` | `"start"` | Alignment: `start`, `center`, `end`, `between`, `around` |
| `size` | `:string` | `"large"` | Title size |
| `font_weight` | `:string` | `"font-semibold"` | Font weight |
| `padding` | `:string` | `"none"` | Padding size |
| `class` | `:any` | `nil` | Custom CSS class |

### `card_content/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `space` | `:string` | `"extra_small"` | Space between elements |
| `padding` | `:string` | `"none"` | Padding size |
| `class` | `:any` | `nil` | Custom CSS class |

### `card_media/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `src` | `:string` | **required** | Image/media URL |
| `alt` | `:string` | `nil` | Alt text for accessibility |
| `rounded` | `:string` | `nil` | Border radius |
| `class` | `:any` | `nil` | Custom CSS class |

### `card_footer/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `padding` | `:string` | `"none"` | Padding size |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

All components accept `inner_block` for custom content.

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Padding / Space
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`, `none`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Card

```heex
<.card>
  <.card_title title="Card Title" />
  <.card_content>
    <p>Card content goes here.</p>
  </.card_content>
</.card>
```

### Card with All Sections

```heex
<.card variant="default" color="natural" padding="medium" rounded="large">
  <.card_title title="Featured Article" icon="hero-document-text" />
  <.card_media src="/images/article.jpg" alt="Article image" />
  <.card_content space="small">
    <p>This is the main content of the card.</p>
    <p>It can contain multiple paragraphs.</p>
  </.card_content>
  <.card_footer padding="small">
    <.button size="small" color="primary">Read More</.button>
  </.card_footer>
</.card>
```

### Variant Styles

```heex
<.card variant="default" color="primary">Default Card</.card>
<.card variant="outline" color="success">Outline Card</.card>
<.card variant="shadow" color="info">Shadow Card</.card>
<.card variant="bordered" color="warning">Bordered Card</.card>
<.card variant="gradient" color="primary">Gradient Card</.card>
```

### Card with Centered Title

```heex
<.card padding="large">
  <.card_title title="Centered Title" position="center" size="extra_large" />
  <.card_content>
    Content with centered title above.
  </.card_content>
</.card>
```

### Card with Icon Title

```heex
<.card variant="bordered" color="primary" padding="medium">
  <.card_title
    title="Settings"
    icon="hero-cog-6-tooth"
    position="between"
  >
    <.button size="small" variant="outline">Edit</.button>
  </.card_title>
  <.card_content>
    Manage your account settings.
  </.card_content>
</.card>
```

### Media Card

```heex
<.card variant="shadow" rounded="large">
  <.card_media
    src="/images/product.jpg"
    alt="Product image"
    rounded="large"
  />
  <.card_content padding="medium">
    <.card_title title="Product Name" size="medium" />
    <p>Product description here.</p>
    <p class="text-xl font-bold">$99.99</p>
  </.card_content>
  <.card_footer padding="medium">
    <.button full_width color="primary">Add to Cart</.button>
  </.card_footer>
</.card>
```

### Horizontal Card

```heex
<.card class="flex flex-row" variant="bordered">
  <.card_media
    src="/images/avatar.jpg"
    alt="User"
    class="w-24 h-24 object-cover"
  />
  <div class="flex-1">
    <.card_content padding="small">
      <.card_title title="John Doe" size="medium" />
      <p>Software Developer</p>
    </.card_content>
  </div>
</.card>
```

## Common Patterns

### Product Card

```heex
<.card variant="shadow" rounded="large" class="overflow-hidden">
  <.card_media src={@product.image} alt={@product.name} />
  <.card_content padding="medium" space="small">
    <.card_title title={@product.name} size="medium" />
    <p class="text-gray-600">{@product.description}</p>
    <div class="flex items-center justify-between">
      <span class="text-xl font-bold">${@product.price}</span>
      <.badge :if={@product.on_sale} color="danger">Sale</.badge>
    </div>
  </.card_content>
  <.card_footer padding="medium">
    <.button full_width color="primary" icon="hero-shopping-cart">
      Add to Cart
    </.button>
  </.card_footer>
</.card>
```

### User Profile Card

```heex
<.card variant="default" color="natural" padding="large" class="text-center">
  <.avatar src={@user.avatar} size="extra_large" rounded="full" class="mx-auto" />
  <.card_content>
    <.card_title title={@user.name} position="center" />
    <p class="text-gray-500">{@user.role}</p>
  </.card_content>
  <.card_footer class="flex justify-center gap-2">
    <.button variant="outline" size="small">Message</.button>
    <.button color="primary" size="small">Follow</.button>
  </.card_footer>
</.card>
```

### Stats Card

```heex
<.card variant="gradient" color="primary" padding="large">
  <.card_content class="text-center">
    <p class="text-4xl font-bold">{@stat.value}</p>
    <p class="text-sm opacity-80">{@stat.label}</p>
  </.card_content>
</.card>
```
