# Email Field Component

Customizable email input component with floating labels, validation support, and start/end sections.

**Documentation**: https://mishka.tools/chelekom/docs/forms/email-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component email_field

# Generate with specific options
mix mishka.ui.gen.component email_field --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component email_field --module MyAppWeb.Components.CustomEmailField
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
| `value` | `:string` | `nil` | Input value |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `floating` | `:string` | `nil` | Floating label: `inner`, `outer` |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `error_icon` | `:string` | `nil` | Error icon name |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `start_section` Slot

Content before the input (icon, text, etc.).

### `end_section` Slot

Content after the input (button, icon, etc.).

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Email Field

```heex
<.email_field name="email" label="Email Address" placeholder="Enter your email" />
```

### With Form Integration

```heex
<.email_field
  field={@form[:email]}
  label="Email"
  placeholder="you@example.com"
/>
```

### With Floating Label (Outer)

```heex
<.email_field
  name="email"
  floating="outer"
  label="Email Address"
  placeholder="Enter your email"
/>
```

### With Floating Label (Inner)

```heex
<.email_field
  name="email"
  floating="inner"
  label="Email Address"
/>
```

### Different Variants

```heex
<.email_field name="e1" variant="default" label="Default" />
<.email_field name="e2" variant="outline" label="Outline" />
<.email_field name="e3" variant="shadow" label="Shadow" />
<.email_field name="e4" variant="bordered" label="Bordered" />
<.email_field name="e5" variant="transparent" label="Transparent" />
```

### Different Colors

```heex
<.email_field name="e1" color="primary" label="Primary" />
<.email_field name="e2" color="success" label="Success" />
<.email_field name="e3" color="danger" label="Danger" />
<.email_field name="e4" color="warning" label="Warning" />
```

### Different Sizes

```heex
<.email_field name="e1" size="small" label="Small" />
<.email_field name="e2" size="medium" label="Medium" />
<.email_field name="e3" size="large" label="Large" />
```

### With Description

```heex
<.email_field
  name="email"
  label="Work Email"
  description="We'll use this for important notifications"
  placeholder="work@company.com"
/>
```

### With Start Section (Icon)

```heex
<.email_field name="email" label="Email" placeholder="Enter email">
  <:start_section>
    <.icon name="hero-envelope" class="size-5 text-gray-400" />
  </:start_section>
</.email_field>
```

### With End Section

```heex
<.email_field name="email" label="Email">
  <:end_section>
    <.button size="small" variant="transparent">Verify</.button>
  </:end_section>
</.email_field>
```

### With Both Sections

```heex
<.email_field name="email" placeholder="Enter email">
  <:start_section>
    <.icon name="hero-envelope" class="size-5" />
  </:start_section>
  <:end_section>
    <.icon name="hero-check-circle" class="size-5 text-green-500" />
  </:end_section>
</.email_field>
```

### With Error

```heex
<.email_field
  field={@form[:email]}
  label="Email"
  error_icon="hero-exclamation-circle"
/>
```

## Common Patterns

### Login Form

```heex
<.form for={@form} phx-submit="login">
  <.email_field
    field={@form[:email]}
    label="Email"
    placeholder="you@example.com"
    autocomplete="email"
  >
    <:start_section>
      <.icon name="hero-envelope" class="size-5 text-gray-400" />
    </:start_section>
  </.email_field>

  <.password_field
    field={@form[:password]}
    label="Password"
  />

  <.button type="submit" full_width color="primary">
    Sign In
  </.button>
</.form>
```

### Newsletter Signup

```heex
<div class="flex gap-2">
  <.email_field
    name="email"
    placeholder="Enter your email"
    class="flex-1"
  >
    <:start_section>
      <.icon name="hero-envelope" class="size-5" />
    </:start_section>
  </.email_field>
  <.button color="primary">Subscribe</.button>
</div>
```

### Contact Form

```heex
<.form for={@form} phx-submit="submit">
  <.text_field field={@form[:name]} label="Name" />
  <.email_field
    field={@form[:email]}
    label="Email Address"
    description="We'll never share your email"
  />
  <.textarea_field field={@form[:message]} label="Message" />
  <.button type="submit" color="primary">Send Message</.button>
</.form>
```
