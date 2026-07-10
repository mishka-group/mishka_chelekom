# Checkbox Field Component

Customizable checkbox input component with individual and grouped options for Phoenix LiveView forms.

**Documentation**: https://mishka.tools/chelekom/docs/forms/checkbox-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component checkbox_field

# Generate with specific options
mix mishka.ui.gen.component checkbox_field --color primary,natural --size small,medium

# Generate specific component types only
mix mishka.ui.gen.component checkbox_field --type checkbox_field,group_checkbox

# Generate with custom module name
mix mishka.ui.gen.component checkbox_field --module MyAppWeb.Components.CustomCheckboxField
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
| `checkbox_field/1` | Individual checkbox input |
| `group_checkbox/1` | Grouped checkbox collection |

## Attributes

### `checkbox_field/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:any` | `nil` | Unique identifier; managed automatically when `field` is used |
| `name` | `:any` | `nil` | Input field name (auto-derived from `field`; gets `[]` suffix when `multiple` is true) |
| `value` | `:any` | `nil` | Checkbox value (auto-derived from `field`) |
| `field` | `Phoenix.HTML.FormField` | — | Form field struct; when set, `id`/`name`/`value`/`checked` are auto-derived |
| `color` | `:string` | `"primary"` | Color theme |
| `size` | `:string` | `"extra_large"` | Checkbox size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `border` | `:string` | `"extra_small"` | Border width |
| `checked` | `:boolean` | `false` | Pre-selected state |
| `multiple` | `:boolean` | `false` | Multiple/select-input flag; when true with `field`, appends `[]` to name and randomizes id |
| `reverse` | `:boolean` | `false` | Reverse checkbox/label order |
| `ring` | `:boolean` | `true` | Show focus ring |
| `label` | `:string` | `nil` | Label text |
| `label_class` | `:string` | `"block"` | Label styling |
| `wrapper_class` | `:string` | `nil` | Custom CSS class for the label/wrapper element |
| `checkbox_class` | `:string` | `nil` | Custom CSS class for the `<input>` element |
| `error_icon` | `:string` | `nil` | Error icon name |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class on the outer wrapper |
| `rest` | `:global` | — | Includes `autocomplete`, `disabled`, `form`, `checked`, `readonly`, `required`, `title`, `autofocus` |

### `group_checkbox/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:any` | `nil` | Unique identifier (prefixes each item's id as `#{id}-#{index}`); auto-derived from `field` |
| `name` | `:any` | `nil` | Input field name; auto-derived from `field` as `field.name <> "[]"` |
| `field` | `Phoenix.HTML.FormField` | — | Form field struct; when set, `id`/`name`/`value` are auto-derived and `multiple` is forced `true` |
| `color` | `:string` | `"primary"` | Color theme |
| `size` | `:string` | `"extra_large"` | Checkbox size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between items (a per-`:checkbox` slot `space` overrides this) |
| `variation` | `:string` | `"vertical"` | Layout: `vertical`, `horizontal` |
| `border` | `:string` | `"extra_small"` | Border width |
| `reverse` | `:boolean` | `false` | Reverse order |
| `ring` | `:boolean` | `true` | Show focus ring |
| `label` | `:string` | `nil` | Group label |
| `label_class` | `:string` | `"block"` | Label styling |
| `wrapper_class` | `:string` | `nil` | Custom CSS class for each item's wrapper `<div>` |
| `checkbox_class` | `:string` | `nil` | Custom CSS class for each `<input>` element |
| `checkbox_wrapper_class` | `:string` | `nil` | Custom CSS class for each item's `<label>` |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class on the outer wrapper |
| `rest` | `:global` | — | Includes `autocomplete`, `disabled`, `form`, `indeterminate`, `readonly`, `required`, `title`, `autofocus` |

## Slots

### `:checkbox` (required, `group_checkbox` only)

One entry per checkbox item. Renders its inner content as the item's label.

| Slot Attribute | Type | Required | Description |
|----------------|------|----------|--------------|
| `value` | `:string` | yes | Checkbox value |
| `checked` | `:boolean` | no | Pre-selected state for this item |
| `space` | `:string` | no | Overrides the group's `space` for this item |

### `inner_block` (`group_checkbox` only)

Optional; renders arbitrary content before the checkbox items (e.g. custom markup alongside the group).

## Available Options

| Option | Values |
|--------|--------|
| Colors | `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Rounded | `extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none` |
| Space | `none`, `extra_small`, `small`, `medium`, `large`, `extra_large` |

## Helper Functions

### `checkbox_check/3`

Check if a value is selected in form parameters.

```elixir
checkbox_check(form, field, value)
```

## Usage Examples

### Basic, Form Field, Pre-checked, Reversed, No Ring

```heex
<.checkbox_field name="terms" value="accepted" label="I accept the terms and conditions" />

<.checkbox_field field={@form[:newsletter]} value="subscribed" label="Subscribe to newsletter" color="primary" />

<.checkbox_field name="remember" value="yes" label="Remember me" checked={true} />

<.checkbox_field name="option" value="1" label="Label on the left" reverse={true} />

<.checkbox_field name="option" value="1" label="No focus ring" ring={false} />
```

### Colors and Sizes

```heex
<.checkbox_field name="c1" value="1" color="primary" label="Primary" />
<.checkbox_field name="c2" value="1" color="success" label="Success" />
<.checkbox_field name="c3" value="1" color="warning" label="Warning" />
<.checkbox_field name="c4" value="1" color="danger" label="Danger" />
<.checkbox_field name="c5" value="1" color="info" label="Info" />

<.checkbox_field name="s1" value="1" size="extra_small" label="Extra Small" />
<.checkbox_field name="s2" value="1" size="small" label="Small" />
<.checkbox_field name="s3" value="1" size="medium" label="Medium" />
<.checkbox_field name="s4" value="1" size="large" label="Large" />
<.checkbox_field name="s5" value="1" size="extra_large" label="Extra Large" />
```

### With Error Messages

```heex
<.checkbox_field
  field={@form[:terms]}
  value="accepted"
  label="I accept the terms"
  error_icon="hero-exclamation-circle"
/>
```

### Group Checkbox (Vertical / Horizontal)

```heex
<.group_checkbox name="interests" label="Select your interests">
  <:checkbox value="sports" label="Sports" />
  <:checkbox value="music" label="Music" />
  <:checkbox value="movies" label="Movies" />
  <:checkbox value="reading" label="Reading" />
</.group_checkbox>

<.group_checkbox name="sizes" label="Available Sizes" variation="horizontal">
  <:checkbox value="xs" label="XS" />
  <:checkbox value="s" label="S" />
  <:checkbox value="m" label="M" />
  <:checkbox value="l" label="L" />
  <:checkbox value="xl" label="XL" />
</.group_checkbox>
```

### Group with Form Integration

```heex
<.form for={@form} phx-submit="save">
  <.group_checkbox field={@form[:categories]} label="Select Categories" color="primary">
    <:checkbox value="tech" label="Technology" />
    <:checkbox value="science" label="Science" />
    <:checkbox value="art" label="Art" />
  </.group_checkbox>
  <.button type="submit">Submit</.button>
</.form>
```

## Common Patterns

### Terms and Conditions

```heex
<.checkbox_field
  field={@form[:terms]}
  value="accepted"
  color="primary"
>
  I agree to the <a href="/terms" class="text-primary-500 underline">Terms of Service</a>
  and <a href="/privacy" class="text-primary-500 underline">Privacy Policy</a>
</.checkbox_field>
```

### Feature Selection (dynamic items)

```heex
<.group_checkbox
  field={@form[:features]}
  label="Enable Features"
  color="success"
  space="large"
>
  <:checkbox
    :for={feature <- @available_features}
    value={feature.id}
    label={feature.name}
    checked={feature.id in @enabled_features}
  />
</.group_checkbox>
```

### Filter Options

```heex
<.group_checkbox
  name="filters"
  label="Filter by Status"
  variation="horizontal"
  size="small"
>
  <:checkbox value="active" label="Active" checked={true} />
  <:checkbox value="pending" label="Pending" />
  <:checkbox value="completed" label="Completed" />
  <:checkbox value="archived" label="Archived" />
</.group_checkbox>
```

### Multiple Selection Form

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.group_checkbox field={@form[:notifications]} label="Notification Preferences" color="primary">
    <:checkbox value="email" label="Email notifications" />
    <:checkbox value="sms" label="SMS notifications" />
    <:checkbox value="push" label="Push notifications" />
    <:checkbox value="in_app" label="In-app notifications" />
  </.group_checkbox>
</.form>
```
