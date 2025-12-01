# Color Field Component

Customizable color picker input component for Phoenix LiveView forms.

**Documentation**: https://mishka.tools/chelekom/docs/forms/color-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component color_field

# Generate with specific options
mix mishka.ui.gen.component color_field --color primary,natural --size small,medium

# Generate with custom module name
mix mishka.ui.gen.component color_field --module MyAppWeb.Components.CustomColorField
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
| `name` | `:string` | `nil` | Input field name |
| `value` | `:string` | `nil` | Color value (hex) |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"small"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border width |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `error_icon` | `:string` | `nil` | Error icon name |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `start_section` Slot

Content before the color input.

### `end_section` Slot

Content after the color input.

## Available Options

### Colors
`base`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Color Field

```heex
<.color_field name="color" value="#ff5733" label="Select Color" />
```

### With Form Integration

```heex
<.color_field
  field={@form[:brand_color]}
  label="Brand Color"
  description="Choose your brand's primary color"
/>
```

### Different Sizes

```heex
<.color_field name="c1" size="small" label="Small" />
<.color_field name="c2" size="medium" label="Medium" />
<.color_field name="c3" size="large" label="Large" />
```

### Different Colors

```heex
<.color_field name="c1" color="primary" label="Primary" />
<.color_field name="c2" color="success" label="Success" />
<.color_field name="c3" color="danger" label="Danger" />
```

### With Description

```heex
<.color_field
  name="background"
  value="#ffffff"
  label="Background Color"
  description="This color will be used for the page background"
/>
```

### With Sections

```heex
<.color_field name="theme_color" label="Theme Color">
  <:start_section>
    <.icon name="hero-swatch" class="size-5" />
  </:start_section>
</.color_field>
```

## Common Patterns

### Theme Customizer

```heex
<div class="space-y-4">
  <.color_field
    field={@form[:primary_color]}
    value="#3b82f6"
    label="Primary Color"
    description="Main brand color"
  />
  <.color_field
    field={@form[:secondary_color]}
    value="#64748b"
    label="Secondary Color"
    description="Supporting color"
  />
  <.color_field
    field={@form[:accent_color]}
    value="#f59e0b"
    label="Accent Color"
    description="Highlight color"
  />
</div>
```
