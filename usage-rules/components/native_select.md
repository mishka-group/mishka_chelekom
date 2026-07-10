# Native Select Component

Native HTML select input with customizable styling and form integration.

**Documentation**: https://mishka.tools/chelekom/docs/forms/native-select

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component native_select
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
| `native_select/1` | Select dropdown |
| `select_option_group/1` | Option group |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant — one of `base`, `default`, `shadow`, `bordered`, `native` |
| `color` | `:string` | `"base"` | Color theme — one of `base`, `white`, `natural`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Select size — one of `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `multiple` | `:boolean` | `false` | Multi-select |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description |
| `prompt` | `:string` | `nil` | Placeholder option |

## Slots

### `option` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `value` | `:string` | Option value |
| `selected` | `:boolean` | Selected state |
| `disabled` | `:boolean` | Disabled state |

## Usage Examples

### Basic Select

```heex
<.native_select name="country" label="Country">
  <:option value="">Select a country</:option>
  <:option value="us">United States</:option>
  <:option value="uk">United Kingdom</:option>
  <:option value="ca">Canada</:option>
</.native_select>
```

### With Form Field, Prompt, and Color

```heex
<.native_select field={@form[:country]} label="Country" prompt="Select your country" color="primary">
  <:option :for={country <- @countries} value={country.code}>{country.name}</:option>
</.native_select>
```

### Multiple Select

```heex
<.native_select name="categories" label="Categories" multiple={true}>
  <:option :for={cat <- @categories} value={cat.id}>{cat.name}</:option>
</.native_select>
```
