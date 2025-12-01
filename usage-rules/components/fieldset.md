# Fieldset Component

Styled fieldset component for grouping related form elements with customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/fieldset

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component fieldset

# Generate with specific options
mix mishka.ui.gen.component fieldset --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component fieldset --module MyAppWeb.Components.CustomFieldset
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
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Fieldset size |
| `space` | `:string` | `"small"` | Space between elements |
| `padding` | `:string` | `"small"` | Content padding |
| `rounded` | `:string` | `"small"` | Border radius |
| `legend` | `:string` | `nil` | Legend text |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `control` Slot

Form controls to be grouped within the fieldset.

### `inner_block` Slot

Additional content.

## Available Options

### Variants
`base`, `default`, `outline`, `unbordered`, `shadow`, `transparent`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Fieldset

```heex
<.fieldset legend="Contact Information">
  <:control>
    <.text_field name="name" label="Name" />
    <.email_field name="email" label="Email" />
    <.tel_field name="phone" label="Phone" />
  </:control>
</.fieldset>
```

### With Variant Styling

```heex
<.fieldset variant="outline" color="primary" legend="Personal Details">
  <:control>
    <.text_field name="first_name" label="First Name" />
    <.text_field name="last_name" label="Last Name" />
  </:control>
</.fieldset>
```

### Different Variants

```heex
<.fieldset variant="default" legend="Default">
  <:control><.text_field name="f1" /></:control>
</.fieldset>

<.fieldset variant="outline" legend="Outline">
  <:control><.text_field name="f2" /></:control>
</.fieldset>

<.fieldset variant="shadow" legend="Shadow">
  <:control><.text_field name="f3" /></:control>
</.fieldset>

<.fieldset variant="gradient" color="primary" legend="Gradient">
  <:control><.text_field name="f4" /></:control>
</.fieldset>
```

### Nested Fieldsets

```heex
<.fieldset legend="Account Settings" variant="outline">
  <:control>
    <.fieldset legend="Personal" variant="transparent" padding="small">
      <:control>
        <.text_field name="username" label="Username" />
        <.email_field name="email" label="Email" />
      </:control>
    </.fieldset>

    <.fieldset legend="Security" variant="transparent" padding="small">
      <:control>
        <.password_field name="password" label="Password" />
        <.checkbox_field name="2fa" label="Enable 2FA" />
      </:control>
    </.fieldset>
  </:control>
</.fieldset>
```

### With Radio Options

```heex
<.fieldset legend="Subscription Plan" color="success" variant="outline">
  <:control>
    <.radio_field name="plan" value="basic" label="Basic - $9/month" />
    <.radio_field name="plan" value="pro" label="Pro - $29/month" />
    <.radio_field name="plan" value="enterprise" label="Enterprise - $99/month" />
  </:control>
</.fieldset>
```

## Common Patterns

### Form Sections

```heex
<.form for={@form} phx-submit="save">
  <.fieldset legend="Billing Address" variant="outline" space="medium">
    <:control>
      <.text_field field={@form[:street]} label="Street" />
      <div class="grid grid-cols-2 gap-4">
        <.text_field field={@form[:city]} label="City" />
        <.text_field field={@form[:state]} label="State" />
      </div>
      <.text_field field={@form[:zip]} label="ZIP Code" />
    </:control>
  </.fieldset>

  <.fieldset legend="Shipping Address" variant="outline" space="medium">
    <:control>
      <.checkbox_field name="same_as_billing" label="Same as billing address" />
      <!-- Shipping fields -->
    </:control>
  </.fieldset>

  <.button type="submit">Save</.button>
</.form>
```

### Preference Groups

```heex
<.fieldset legend="Notification Preferences" color="natural">
  <:control>
    <.group_checkbox name="notifications">
      <:checkbox value="email" label="Email notifications" />
      <:checkbox value="sms" label="SMS notifications" />
      <:checkbox value="push" label="Push notifications" />
    </.group_checkbox>
  </:control>
</.fieldset>
```
