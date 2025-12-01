# Number Field Component

Number input with increment/decrement controls and customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/number-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component number_field
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
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `min` | `:number` | `nil` | Minimum value |
| `max` | `:number` | `nil` | Maximum value |
| `step` | `:number` | `1` | Step increment |
| `label` | `:string` | `nil` | Label text |
| `show_controls` | `:boolean` | `true` | Show +/- buttons |
| `floating` | `:string` | `nil` | Floating label |

## Slots

### `start_section` / `end_section` Slots

Content before/after input.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Number Field

```heex
<.number_field name="quantity" label="Quantity" />
```

### With Min/Max

```heex
<.number_field
  name="age"
  label="Age"
  min={18}
  max={120}
  value={25}
/>
```

### With Step

```heex
<.number_field
  name="price"
  label="Price"
  min={0}
  max={1000}
  step={0.01}
/>
```

### Without Controls

```heex
<.number_field
  name="amount"
  label="Amount"
  show_controls={false}
/>
```

### Different Variants

```heex
<.number_field variant="default" label="Default" />
<.number_field variant="outline" label="Outline" />
<.number_field variant="bordered" label="Bordered" />
```

### With Form Field

```heex
<.number_field
  field={@form[:quantity]}
  label="Quantity"
  min={1}
  max={100}
/>
```

## Common Patterns

### Quantity Selector

```heex
<.number_field
  field={@form[:quantity]}
  label="Quantity"
  min={1}
  max={@max_stock}
  color="primary"
/>
```

### Price Input

```heex
<.number_field name="price" label="Price" min={0} step={0.01}>
  <:start_section>$</:start_section>
</.number_field>
```
