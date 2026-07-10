# Combobox Component

Searchable select/dropdown component with filtering, single/multiple selection, and keyboard navigation.

**Documentation**: https://mishka.tools/chelekom/docs/forms/combobox

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component combobox
mix mishka.ui.gen.component combobox --variant default,bordered --color primary,natural
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
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `bordered` |
| `color` | `:string` | `"natural"` | Color theme — `base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Component size — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `space` | `:string` | `"small"` | Space between elements — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `padding` | `:string` | `"small"` | Dropdown padding — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"medium"` | Border radius — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `searchable` | `:boolean` | `true` | Enable search filtering |
| `multiple` | `:boolean` | `false` | Enable multiple selection |
| `options` | `:list` | `[]` | List of options (alternative to `:option` slot) |
| `on_change` | `:string` | `nil` | Change event handler |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

| Slot | Attribute | Type | Description |
|------|-----------|------|-------------|
| `option` | `value` | `:string` | Option value |
| `option` | `disabled` | `:boolean` | Disable option |
| `start_section` | — | — | Content before the input |

## Usage Examples

### Basic Combobox

```heex
<.combobox placeholder="Select an option">
  <:option value="option1">Option 1</:option>
  <:option value="option2">Option 2</:option>
  <:option value="option3">Option 3</:option>
</.combobox>
```

### With Options List (`options` attr instead of slot)

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

### Multiple + Searchable Selection

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

### With Form Integration (field + label/description)

```heex
<.form for={@form} phx-submit="save">
  <.combobox
    field={@form[:country]}
    label="Country"
    description="Select product category"
    placeholder="Select your country"
    searchable={true}
  >
    <:option :for={country <- @countries} value={country.code}>
      {country.flag} {country.name}
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

## JavaScript Hook

The combobox uses the `Combobox` JavaScript hook. This is automatically configured when you generate the component.

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
