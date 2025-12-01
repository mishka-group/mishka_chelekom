# Modal Component

Dialog/popup component for displaying content overlays with customizable styling and accessibility.

**Documentation**: https://mishka.tools/chelekom/docs/modal

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component modal

# Generate with specific options
mix mishka.ui.gen.component modal --variant default,shadow --color white,natural

# Generate with custom module name
mix mishka.ui.gen.component modal --module MyAppWeb.Components.CustomModal
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
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Modal width |
| `rounded` | `:string` | `"medium"` | Border radius |
| `padding` | `:string` | `"medium"` | Content padding |
| `show` | `:boolean` | `false` | Initial visibility |
| `title` | `:string` | `nil` | Modal title |
| `hide_close` | `:boolean` | `false` | Hide close button |
| `on_cancel` | `JS` | `nil` | Cancel action |
| `on_confirm` | `JS` | `nil` | Confirm action |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Modal content.

## Helper Functions

### `show_modal/1` and `show_modal/2`

Show a modal programmatically.

```elixir
show_modal(id)
show_modal(js \\ %JS{}, id)
```

### `hide_modal/1` and `hide_modal/2`

Hide a modal programmatically.

```elixir
hide_modal(id)
hide_modal(js \\ %JS{}, id)
```

### `show/1` and `show/2`

Alternative show function.

### `hide/1` and `hide/2`

Alternative hide function.

## Available Options

### Variants
`base`, `default`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `white`, `natural`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`, `screen`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Modal

```heex
<.button phx-click={show_modal("basic-modal")}>Open Modal</.button>

<.modal id="basic-modal" title="Modal Title">
  <p>Modal content goes here.</p>
</.modal>
```

### With Actions

```heex
<.modal id="confirm-modal" title="Confirm Action">
  <p>Are you sure you want to proceed?</p>
  <div class="flex justify-end gap-4 mt-6">
    <.button variant="outline" phx-click={hide_modal("confirm-modal")}>Cancel</.button>
    <.button color="primary" phx-click="confirm">Confirm</.button>
  </div>
</.modal>
```

### Different Sizes

```heex
<.modal id="small-modal" size="small" title="Small Modal">
  Small content
</.modal>

<.modal id="large-modal" size="large" title="Large Modal">
  Large content
</.modal>

<.modal id="full-modal" size="screen" title="Full Screen">
  Full screen content
</.modal>
```

### Different Variants

```heex
<.modal id="default-modal" variant="default" title="Default">Content</.modal>
<.modal id="shadow-modal" variant="shadow" title="Shadow">Content</.modal>
<.modal id="bordered-modal" variant="bordered" title="Bordered">Content</.modal>
```

### Initially Visible

```heex
<.modal id="welcome-modal" title="Welcome!" show={@show_welcome}>
  <p>Welcome to our application!</p>
</.modal>
```

### Without Title/Close

```heex
<.modal id="custom-modal" hide_close={true} padding="none">
  <div class="p-6">
    <h2 class="text-xl font-bold">Custom Header</h2>
    <p class="mt-4">Custom content with manual close button.</p>
    <.button phx-click={hide_modal("custom-modal")} class="mt-4">Close</.button>
  </div>
</.modal>
```

### Form Modal

```heex
<.modal id="form-modal" title="Edit Profile" size="large">
  <.form for={@form} phx-submit="save_profile">
    <.text_field field={@form[:name]} label="Name" />
    <.email_field field={@form[:email]} label="Email" />
    <.textarea_field field={@form[:bio]} label="Bio" />

    <div class="flex justify-end gap-4 mt-6">
      <.button type="button" variant="outline" phx-click={hide_modal("form-modal")}>
        Cancel
      </.button>
      <.button type="submit" color="primary">Save</.button>
    </div>
  </.form>
</.modal>
```

## Common Patterns

### Confirmation Dialog

```heex
<.button
  phx-click={show_modal("delete-confirm")}
  phx-value-id={@item.id}
  color="danger"
>
  Delete
</.button>

<.modal id="delete-confirm" title="Delete Item" variant="shadow">
  <p>Are you sure you want to delete this item? This action cannot be undone.</p>
  <div class="flex justify-end gap-4 mt-6">
    <.button variant="outline" phx-click={hide_modal("delete-confirm")}>
      Cancel
    </.button>
    <.button color="danger" phx-click="delete" phx-value-id={@delete_id}>
      Delete
    </.button>
  </div>
</.modal>
```

### Image Preview Modal

```heex
<.modal id="image-preview" size="extra_large" padding="none">
  <img :if={@preview_image} src={@preview_image} alt="Preview" class="w-full" />
</.modal>
```

### Success/Info Modal

```heex
<.modal id="success-modal" variant="default" color="success">
  <div class="text-center">
    <.icon name="hero-check-circle" class="size-16 text-green-500 mx-auto" />
    <h3 class="text-xl font-bold mt-4">Success!</h3>
    <p class="text-gray-600 mt-2">Your changes have been saved.</p>
    <.button
      color="success"
      class="mt-6"
      phx-click={hide_modal("success-modal")}
    >
      Done
    </.button>
  </div>
</.modal>
```

### Multi-Step Modal

```heex
<.modal id="wizard-modal" title="Setup Wizard" size="large">
  <div :if={@step == 1}>
    <h3>Step 1: Basic Info</h3>
    <!-- Step 1 content -->
  </div>
  <div :if={@step == 2}>
    <h3>Step 2: Preferences</h3>
    <!-- Step 2 content -->
  </div>
  <div :if={@step == 3}>
    <h3>Step 3: Confirmation</h3>
    <!-- Step 3 content -->
  </div>

  <div class="flex justify-between mt-6">
    <.button :if={@step > 1} variant="outline" phx-click="prev_step">Back</.button>
    <.button :if={@step < 3} color="primary" phx-click="next_step">Next</.button>
    <.button :if={@step == 3} color="success" phx-click="complete">Complete</.button>
  </div>
</.modal>
```

### Login Modal

```heex
<.modal id="login-modal" title="Sign In" variant="shadow" rounded="large">
  <.form for={@form} phx-submit="login" class="space-y-4">
    <.email_field field={@form[:email]} label="Email" placeholder="you@example.com" />
    <.password_field field={@form[:password]} label="Password" />

    <div class="flex items-center justify-between">
      <.checkbox_field name="remember" label="Remember me" />
      <a href="/forgot-password" class="text-sm text-primary-500">Forgot password?</a>
    </div>

    <.button type="submit" color="primary" full_width>Sign In</.button>
  </.form>

  <.divider class="my-4"><:text>Or</:text></.divider>

  <.button variant="outline" full_width icon="hero-globe-alt">
    Continue with Google
  </.button>
</.modal>
```
