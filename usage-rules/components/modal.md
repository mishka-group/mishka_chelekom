# Modal Component

Dialog/popup component for content overlays with customizable styling and accessibility.

**Documentation**: https://mishka.tools/chelekom/docs/modal

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component modal
mix mishka.ui.gen.component modal --variant default,shadow --color white,natural
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
| `id` | `:string` | **required** | Unique identifier; the helpers take it |
| `title` | `:string` | `nil` | Title, rendered beside the close button and used as the dialog's label |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"extra_large"` | Maximum width |
| `rounded` | `:string` | `"small"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border width (`base` and `bordered` only) |
| `padding` | `:string` | `"medium"` | Padding |
| `show` | `:boolean` | `false` | Open the modal when it mounts |
| `on_cancel` | `JS` | `%JS{}` | Commands run before the modal closes on Escape, a click outside or the close button |
| `class` | `:any` | `nil` | Class of the modal root |
| `title_class` | `:string` | `"text-base md:text-lg xl:text-2xl"` | Class of the title |
| `icon_class` | `:string` | `"size-5"` | Class of the close button's icon |
| `close_class` | `:string` | `nil` | Class of the close button |
| `content_class` | `:string` | `nil` | Class of the content |
| `focus_wrap_class` | `:string` | `nil` | Class of the panel (the focus wrap) |
| `inner_wrapper_class` | `:string` | `nil` | Class of the centring wrapper |
| `wrapper_class` | `:string` | `nil` | Class of the scrolling dialog wrapper |
| `overlay_class` | `:string` | `nil` | Class of the backdrop |

The close button is always rendered. `show` is read when the modal mounts; to open or close it
later, use the helpers.

## Slots

- `inner_block` (required) — modal content.

## Helper Functions

- `show_modal(js \\ %JS{}, id)` — opens the modal.
- `hide_modal(js \\ %JS{}, id)` — closes it. It does not run `on_cancel`.
- `show(js \\ %JS{}, selector)` / `hide(js \\ %JS{}, selector)` — the fade and scale transition on any
  element, kept for Phoenix `CoreComponents` compatibility; they do not open or close a modal.

## Keyboard and Focus

- Escape, a click outside the panel and the close button close the modal.
- Opening moves focus to the first focusable element in the panel, the close button, and Tab stays
  inside the panel while the modal is open.
- Closing gives focus back to the element that had it when the modal opened. A modal opened while
  nothing had focus (with `show`, or from a button in Safari, which does not focus a clicked
  button) moves no focus when it closes.
- Opening locks the page's scroll (`overflow-hidden` on `<body>`) and closing unlocks it.
- Opening a modal that is already open, or closing one that is already closed, leaves focus and
  the page's scroll alone, so a closed modal on the page, or one a patch removes, never takes
  focus from another open dialog or unlocks the scroll under it.

## Available Options

| Option | Values |
|--------|--------|
| Variants | `base`, `default`, `shadow`, `bordered`, `gradient` |
| Colors | `base`, `white`, `natural`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`, `screen` |
| Rounded | `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| Border | `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| Padding | `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |

The `base` variant ignores `color`. `white` and `dark` are colors of `default` and `bordered`;
`shadow` and `gradient` take the other colors.

## Usage Examples

### Basic

```heex
<.button phx-click={show_modal("basic-modal")}>Open Modal</.button>

<.modal id="basic-modal" title="Modal Title">
  <p>Modal content goes here.</p>
</.modal>
```

### With Confirm/Cancel Actions

```heex
<.modal id="confirm-modal" title="Confirm Action" variant="shadow">
  <p>Are you sure you want to proceed?</p>
  <div class="flex justify-end gap-4 mt-6">
    <.button variant="outline" phx-click={hide_modal("confirm-modal")}>Cancel</.button>
    <.button color="primary" phx-click="confirm">Confirm</.button>
  </div>
</.modal>
```

### Sizes and Variants

`size` and `variant` accept any value from the tables above:

```heex
<.modal id="small-modal" size="small" title="Small Modal">Small content</.modal>
<.modal id="full-modal" size="screen" title="Full Screen">Full screen content</.modal>

<.modal id="default-modal" variant="default" title="Default">Content</.modal>
<.modal id="bordered-modal" variant="bordered" title="Bordered">Content</.modal>
```

### Initially Visible

```heex
<.modal id="welcome-modal" title="Welcome!" show={@show_welcome}>
  <p>Welcome to our application!</p>
</.modal>
```

### Without a Title (own close button)

```heex
<.modal id="custom-modal" padding="none">
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
<.button phx-click={show_modal("delete-confirm")} phx-value-id={@item.id} color="danger">
  Delete
</.button>

<.modal id="delete-confirm" title="Delete Item" variant="shadow">
  <p>Are you sure you want to delete this item? This action cannot be undone.</p>
  <div class="flex justify-end gap-4 mt-6">
    <.button variant="outline" phx-click={hide_modal("delete-confirm")}>Cancel</.button>
    <.button color="danger" phx-click="delete" phx-value-id={@delete_id}>Delete</.button>
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
    <.button color="success" class="mt-6" phx-click={hide_modal("success-modal")}>
      Done
    </.button>
  </div>
</.modal>
```

### Multi-Step Modal

```heex
<.modal id="wizard-modal" title="Setup Wizard" size="large">
  <div :if={@step == 1}><h3>Step 1: Basic Info</h3></div>
  <div :if={@step == 2}><h3>Step 2: Preferences</h3></div>
  <div :if={@step == 3}><h3>Step 3: Confirmation</h3></div>

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
