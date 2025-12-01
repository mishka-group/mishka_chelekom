# Text Field Component

Customizable text input with labels, descriptions, and error handling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/text-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component text_field
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
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
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

### Basic Text Field

```heex
<.text_field name="username" label="Username" />
```

### With Placeholder

```heex
<.text_field
  name="name"
  label="Full Name"
  placeholder="Enter your full name"
/>
```

### With Form Field

```heex
<.text_field
  field={@form[:name]}
  label="Name"
  placeholder="Your name"
/>
```

### With Description

```heex
<.text_field
  name="username"
  label="Username"
  description="This will be your public display name"
/>
```

### Floating Label

```heex
<.text_field
  name="company"
  floating="outer"
  label="Company Name"
/>
```

### Different Variants

```heex
<.text_field name="input" variant="default" label="Default" />
<.text_field name="input" variant="outline" label="Outline" />
<.text_field name="input" variant="shadow" label="Shadow" />
<.text_field name="input" variant="bordered" label="Bordered" />
```

### Different Sizes

```heex
<.text_field name="input" size="small" label="Small" />
<.text_field name="input" size="medium" label="Medium" />
<.text_field name="input" size="large" label="Large" />
```

### With Start/End Sections

```heex
<.text_field name="website" label="Website">
  <:start_section>
    <span class="text-gray-500">https://</span>
  </:start_section>
</.text_field>

<.text_field name="username" label="Username">
  <:start_section>
    <.icon name="hero-at-symbol" class="size-5" />
  </:start_section>
</.text_field>

<.text_field name="search" placeholder="Search...">
  <:end_section>
    <.button size="small" variant="ghost">
      <.icon name="hero-magnifying-glass" class="size-4" />
    </.button>
  </:end_section>
</.text_field>
```

## Common Patterns

### Registration Form

```heex
<.form for={@form} phx-submit="register">
  <.text_field
    field={@form[:first_name]}
    label="First Name"
    placeholder="John"
  />
  <.text_field
    field={@form[:last_name]}
    label="Last Name"
    placeholder="Doe"
  />
  <.email_field
    field={@form[:email]}
    label="Email"
    placeholder="john@example.com"
  />
  <.password_field
    field={@form[:password]}
    label="Password"
  />
  <.button type="submit" color="primary" full_width>
    Register
  </.button>
</.form>
```

### Profile Form

```heex
<.form for={@form} phx-submit="update_profile">
  <.text_field
    field={@form[:display_name]}
    label="Display Name"
    description="This is how others will see you"
  />
  <.text_field
    field={@form[:bio]}
    label="Bio"
    placeholder="Tell us about yourself"
  />
  <.text_field field={@form[:website]} label="Website">
    <:start_section>
      <span class="text-gray-500 text-sm">https://</span>
    </:start_section>
  </.text_field>
</.form>
```

### Inline Form

```heex
<div class="flex gap-2">
  <.text_field
    name="coupon"
    placeholder="Enter coupon code"
    class="flex-1"
  />
  <.button color="primary">Apply</.button>
</div>
```
