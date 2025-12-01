# Blockquote Component

Stylized quotation component with customizable borders, icons, and captions for highlighting quotes and key content.

**Documentation**: https://mishka.tools/chelekom/docs/blockquote

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component blockquote

# Generate with specific options
mix mishka.ui.gen.component blockquote --variant default,bordered --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component blockquote --module MyAppWeb.Components.CustomBlockquote
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
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"medium"` | Overall size |
| `border` | `:string` | `"medium"` | Border width |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"small"` | Space between elements |
| `padding` | `:string` | `"small"` | Padding size |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `icon` | `:string` | `"hero-quote"` | Quote icon |
| `icon_class` | `:string` | `nil` | Icon styling class |
| `blockquote_class` | `:string` | `nil` | Blockquote element styling |
| `class` | `:any` | `nil` | Custom CSS class |

## Global Attributes

| Attribute | Description |
|-----------|-------------|
| `left_border` | Show border on left side (default) |
| `right_border` | Show border on right side |
| `full_border` | Show border on all sides |
| `hide_border` | Hide all borders |
| `hide_icon` | Hide the quote icon |

## Slots

### `caption` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `image` | `:string` | Author image URL |
| `image_class` | `:string` | Image styling class |
| `alt` | `:string` | Image alt text |
| `class` | `:any` | Caption wrapper class |
| `content_class` | `:string` | Caption content class |
| `position` | `:string` | Alignment: `left`, `right`, `center` |

### `inner_block` Slot

Quote content.

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

### Padding / Space
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Blockquote

```heex
<.blockquote>
  The only way to do great work is to love what you do.
</.blockquote>
```

### With Caption

```heex
<.blockquote left_border>
  <p>Innovation distinguishes between a leader and a follower.</p>
  <:caption image="/images/steve.jpg" position="left">
    Steve Jobs | Apple CEO
  </:caption>
</.blockquote>
```

### Different Border Positions

```heex
<.blockquote left_border color="primary">
  Left border quote
</.blockquote>

<.blockquote right_border color="success">
  Right border quote
</.blockquote>

<.blockquote full_border color="warning">
  Full border quote
</.blockquote>
```

### Without Icon

```heex
<.blockquote hide_icon left_border>
  <p>Simple quote without the decorative icon.</p>
  <:caption position="center">
    Anonymous
  </:caption>
</.blockquote>
```

### Custom Icon

```heex
<.blockquote icon="hero-chat-bubble-left-ellipsis" color="info">
  <p>A custom icon can be used instead of the default quote icon.</p>
</.blockquote>
```

### Variant Styles

```heex
<.blockquote variant="default" color="primary">
  Default variant with solid background.
</.blockquote>

<.blockquote variant="outline" color="success">
  Outline variant with border only.
</.blockquote>

<.blockquote variant="shadow" color="dark">
  Shadow variant with elevation effect.
</.blockquote>

<.blockquote variant="gradient" color="primary">
  Gradient background variant.
</.blockquote>
```

### Transparent Style

```heex
<.blockquote variant="transparent" color="primary">
  <p>Minimal styling without background.</p>
  <:caption image="/images/author.jpg">
    Author Name
  </:caption>
</.blockquote>
```

### Different Sizes

```heex
<.blockquote size="extra_small">Extra small quote</.blockquote>
<.blockquote size="small">Small quote</.blockquote>
<.blockquote size="medium">Medium quote</.blockquote>
<.blockquote size="large">Large quote</.blockquote>
<.blockquote size="extra_large">Extra large quote</.blockquote>
```

### Caption Positions

```heex
<.blockquote>
  <p>Quote with left-aligned caption.</p>
  <:caption image="/images/avatar.jpg" position="left">
    Author Name
  </:caption>
</.blockquote>

<.blockquote>
  <p>Quote with centered caption.</p>
  <:caption position="center">
    Author Name
  </:caption>
</.blockquote>

<.blockquote>
  <p>Quote with right-aligned caption.</p>
  <:caption image="/images/avatar.jpg" position="right">
    Author Name
  </:caption>
</.blockquote>
```

## Common Patterns

### Testimonial Card

```heex
<.blockquote
  variant="bordered"
  color="primary"
  rounded="large"
  padding="large"
  left_border
>
  <p>
    This product has completely transformed how we work.
    Highly recommended for any team!
  </p>
  <:caption image={@testimonial.avatar} position="left">
    {@testimonial.name} | {@testimonial.title}
  </:caption>
</.blockquote>
```

### Article Quote

```heex
<.blockquote
  variant="transparent"
  color="natural"
  size="large"
  hide_icon
  left_border
  border="large"
>
  <p class="italic">
    "The future belongs to those who believe in the beauty of their dreams."
  </p>
  <:caption position="right">
    — Eleanor Roosevelt
  </:caption>
</.blockquote>
```
