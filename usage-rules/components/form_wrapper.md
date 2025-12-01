# Form Wrapper Component

Styled form container with consistent layout, spacing, and action slots.

**Documentation**: https://mishka.tools/chelekom/docs/forms

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component form_wrapper

# Generate with specific options
mix mishka.ui.gen.component form_wrapper --variant default,outline --color white,natural

# Generate with custom module name
mix mishka.ui.gen.component form_wrapper --module MyAppWeb.Components.CustomFormWrapper
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `form_wrapper/1` | Styled form container |
| `simple_form/1` | Simple form with Phoenix integration |

## Attributes

### `form_wrapper/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Form size |
| `space` | `:string` | `"medium"` | Space between elements |
| `padding` | `:string` | `"medium"` | Content padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Form fields and content.

### `actions` Slot

Form action buttons (submit, cancel, etc.).

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `unbordered`

### Colors
`base`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `light`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Form Wrapper

```heex
<.form_wrapper>
  <.text_field name="name" label="Name" />
  <.email_field name="email" label="Email" />

  <:actions>
    <.button type="submit" color="primary">Submit</.button>
  </:actions>
</.form_wrapper>
```

### With Form Integration

```heex
<.form for={@form} phx-submit="save">
  <.form_wrapper variant="default" color="white" padding="large">
    <.text_field field={@form[:name]} label="Name" />
    <.email_field field={@form[:email]} label="Email" />
    <.password_field field={@form[:password]} label="Password" />

    <:actions>
      <.button type="submit" color="primary">Create Account</.button>
    </:actions>
  </.form_wrapper>
</.form>
```

### Different Variants

```heex
<.form_wrapper variant="default" color="white">
  Default variant
</.form_wrapper>

<.form_wrapper variant="outline" color="primary">
  Outline variant
</.form_wrapper>

<.form_wrapper variant="shadow" color="white">
  Shadow variant
</.form_wrapper>
```

### With Actions Row

```heex
<.form_wrapper padding="large" space="large">
  <.text_field name="title" label="Title" />
  <.textarea_field name="description" label="Description" />

  <:actions>
    <div class="flex gap-4">
      <.button type="button" variant="outline">Cancel</.button>
      <.button type="submit" color="primary">Save</.button>
    </div>
  </:actions>
</.form_wrapper>
```

### Styled Login Form

```heex
<.form for={@form} phx-submit="login">
  <.form_wrapper
    variant="shadow"
    color="white"
    padding="extra_large"
    rounded="large"
    class="max-w-md mx-auto"
  >
    <h2 class="text-2xl font-bold text-center mb-6">Welcome Back</h2>

    <.email_field field={@form[:email]} label="Email" placeholder="you@example.com" />
    <.password_field field={@form[:password]} label="Password" />

    <div class="flex items-center justify-between">
      <.checkbox_field name="remember" label="Remember me" />
      <a href="/forgot-password" class="text-sm text-primary-500">Forgot password?</a>
    </div>

    <:actions>
      <.button type="submit" color="primary" full_width>Sign In</.button>
    </:actions>

    <p class="text-center text-sm text-gray-500 mt-4">
      Don't have an account? <a href="/register" class="text-primary-500">Sign up</a>
    </p>
  </.form_wrapper>
</.form>
```

## Common Patterns

### Registration Form

```heex
<.form for={@form} phx-submit="register" phx-change="validate">
  <.form_wrapper
    variant="outline"
    color="natural"
    padding="large"
    rounded="large"
  >
    <div class="text-center mb-6">
      <h1 class="text-2xl font-bold">Create Account</h1>
      <p class="text-gray-500">Get started with your free account</p>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <.text_field field={@form[:first_name]} label="First Name" />
      <.text_field field={@form[:last_name]} label="Last Name" />
    </div>

    <.email_field field={@form[:email]} label="Email" />
    <.password_field field={@form[:password]} label="Password" />
    <.password_field field={@form[:password_confirmation]} label="Confirm Password" />

    <.checkbox_field name="terms" label="I agree to the Terms of Service" />

    <:actions>
      <.button type="submit" color="primary" full_width size="large">
        Create Account
      </.button>
    </:actions>
  </.form_wrapper>
</.form>
```

### Contact Form

```heex
<.form for={@form} phx-submit="send_message">
  <.form_wrapper variant="default" padding="large" space="medium">
    <h2 class="text-xl font-semibold">Contact Us</h2>
    <p class="text-gray-500 mb-4">We'd love to hear from you</p>

    <div class="grid grid-cols-2 gap-4">
      <.text_field field={@form[:name]} label="Name" />
      <.email_field field={@form[:email]} label="Email" />
    </div>

    <.text_field field={@form[:subject]} label="Subject" />
    <.textarea_field field={@form[:message]} label="Message" rows={5} />

    <:actions>
      <.button type="submit" color="primary" icon="hero-paper-airplane">
        Send Message
      </.button>
    </:actions>
  </.form_wrapper>
</.form>
```

### Settings Form

```heex
<.form for={@form} phx-submit="save_settings">
  <.form_wrapper variant="transparent" padding="none" space="large">
    <.fieldset legend="Profile" variant="outline">
      <:control>
        <.text_field field={@form[:username]} label="Username" />
        <.email_field field={@form[:email]} label="Email" />
        <.textarea_field field={@form[:bio]} label="Bio" />
      </:control>
    </.fieldset>

    <.fieldset legend="Notifications" variant="outline">
      <:control>
        <.checkbox_field name="email_updates" label="Email updates" />
        <.checkbox_field name="marketing" label="Marketing emails" />
      </:control>
    </.fieldset>

    <:actions>
      <.button type="submit" color="primary">Save Changes</.button>
    </:actions>
  </.form_wrapper>
</.form>
```
