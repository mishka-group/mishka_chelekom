# Combobox Component

Searchable select/dropdown component with filtering, single/multiple selection, and keyboard navigation.

**Documentation**: https://mishka.tools/chelekom/docs/forms/combobox

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component combobox

# Generate with specific options
mix mishka.ui.gen.component combobox --variant default,bordered --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component combobox --module MyAppWeb.Components.CustomCombobox
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `scroll_area`, `icon` |
| **Optional** | None |
| **JavaScript** | `combobox.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | auto-generated | Unique identifier |
| `name` | `:string` | `nil` | Input field name |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"medium"` | Component size |
| `space` | `:string` | `"small"` | Space between elements |
| `padding` | `:string` | `"small"` | Dropdown padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `searchable` | `:boolean` | `true` | Enable search filtering |
| `multiple` | `:boolean` | `false` | Enable multiple selection |
| `options` | `:list` | `[]` | List of options |
| `on_change` | `:string` | `nil` | Change event handler |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `option` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `value` | `:string` | Option value |
| `disabled` | `:boolean` | Disable option |

### `start_section` Slot

Content before the input.

## Available Options

### Variants
`base`, `default`, `bordered`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Padding / Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Combobox

```heex
<.combobox placeholder="Select an option">
  <:option value="option1">Option 1</:option>
  <:option value="option2">Option 2</:option>
  <:option value="option3">Option 3</:option>
</.combobox>
```

### With Options List

```heex
<.combobox
  options={[
    %{value: "us", label: "United States"},
    %{value: "uk", label: "United Kingdom"},
    %{value: "ca", label: "Canada"}
  ]}
  placeholder="Select country"
  on_change="country_selected"
/>
```

### Multiple Selection

```heex
<.combobox
  name="tags"
  placeholder="Select tags"
  multiple={true}
>
  <:option value="frontend">Frontend</:option>
  <:option value="backend">Backend</:option>
  <:option value="devops">DevOps</:option>
  <:option value="design">Design</:option>
</.combobox>
```

### Searchable

```heex
<.combobox
  placeholder="Search and select..."
  searchable={true}
>
  <:option :for={country <- @countries} value={country.code}>
    {country.name}
  </:option>
</.combobox>
```

### With Form Integration

```heex
<.form for={@form} phx-submit="save">
  <.combobox
    field={@form[:category]}
    label="Category"
    description="Select product category"
    placeholder="Choose category"
  >
    <:option :for={cat <- @categories} value={cat.id}>
      {cat.name}
    </:option>
  </.combobox>
</.form>
```

### Different Variants

```heex
<.combobox variant="default" color="primary" placeholder="Default">
  <:option value="1">Option 1</:option>
</.combobox>

<.combobox variant="bordered" color="success" placeholder="Bordered">
  <:option value="1">Option 1</:option>
</.combobox>
```

### With Start Section

```heex
<.combobox placeholder="Select user">
  <:start_section>
    <.icon name="hero-user" class="size-5" />
  </:start_section>
  <:option :for={user <- @users} value={user.id}>
    {user.name}
  </:option>
</.combobox>
```

## Common Patterns

### Country Selector

```heex
<.combobox
  field={@form[:country]}
  label="Country"
  placeholder="Select your country"
  searchable={true}
>
  <:option :for={country <- @countries} value={country.code}>
    {country.flag} {country.name}
  </:option>
</.combobox>
```

### Tag Selection

```heex
<.combobox
  field={@form[:tags]}
  label="Tags"
  placeholder="Add tags..."
  multiple={true}
  searchable={true}
>
  <:option :for={tag <- @available_tags} value={tag.id}>
    {tag.name}
  </:option>
</.combobox>
```

## JavaScript Hook

The combobox uses the `Combobox` JavaScript hook. This is automatically configured when you generate the component.

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
