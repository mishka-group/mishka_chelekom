# Range Field Component

Customizable range slider input with labels and value display.

**Documentation**: https://mishka.tools/chelekom/docs/forms/range-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component range_field
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
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Slider size |
| `appearance` | `:string` | `"default"` | Visual style |
| `min` | `:string` | `"0"` | Minimum value |
| `max` | `:string` | `"100"` | Maximum value |
| `step` | `:string` | `"1"` | Step increment |
| `value` | `:string` | `nil` | Current value |
| `label` | `:string` | `nil` | Label text |

## Slots

### `range_value` Slot

Value labels at different positions.

| Attribute | Type | Description |
|-----------|------|-------------|
| `position` | `:string` | `start`, `middle`, or `end` |

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Range Field

```heex
<.range_field name="volume" value="50" />
```

### With Label

```heex
<.range_field name="brightness" label="Brightness" value="75" />
```

### Custom Range

```heex
<.range_field
  name="price"
  min="100"
  max="1000"
  step="50"
  value="500"
/>
```

### With Value Labels

```heex
<.range_field name="price" value="500" min="100" max="1000">
  <:range_value position="start">$100</:range_value>
  <:range_value position="middle">$500</:range_value>
  <:range_value position="end">$1000</:range_value>
</.range_field>
```

### Different Colors

```heex
<.range_field name="slider" value="50" color="primary" />
<.range_field name="slider" value="50" color="success" />
<.range_field name="slider" value="50" color="warning" />
```

### Different Sizes

```heex
<.range_field name="slider" value="50" size="small" />
<.range_field name="slider" value="50" size="medium" />
<.range_field name="slider" value="50" size="large" />
```

### Custom Appearance

```heex
<.range_field
  name="custom"
  appearance="custom"
  value="40"
  color="warning"
  size="small"
  min="10"
  max="100"
  step="5"
>
  <:range_value position="start">Min ($100)</:range_value>
  <:range_value position="middle">$700</:range_value>
  <:range_value position="end">Max ($1500)</:range_value>
</.range_field>
```

## Common Patterns

### Volume Control

```heex
<div class="flex items-center gap-3">
  <.icon name="hero-speaker-wave" class="size-5" />
  <.range_field name="volume" value={@volume} min="0" max="100" class="flex-1" />
  <span class="text-sm w-8">{@volume}%</span>
</div>
```

### Price Filter

```heex
<div class="space-y-2">
  <label class="font-medium">Price Range</label>
  <.range_field name="max_price" value={@max_price} min="0" max="1000" step="10">
    <:range_value position="start">$0</:range_value>
    <:range_value position="end">$1000</:range_value>
  </.range_field>
  <p class="text-sm text-gray-600">Max: ${@max_price}</p>
</div>
```

### Rating Slider

```heex
<.range_field
  name="rating"
  label="Your Rating"
  min="1"
  max="10"
  step="1"
  value="5"
  color="warning"
>
  <:range_value position="start">1</:range_value>
  <:range_value position="middle">5</:range_value>
  <:range_value position="end">10</:range_value>
</.range_field>
```
