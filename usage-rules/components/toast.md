# Toast Component

Temporary notification messages with customizable positioning.

**Documentation**: https://mishka.tools/chelekom/docs/toast

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component toast
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
| `toast/1` | Individual toast notification |
| `toast_group/1` | Container for multiple toasts |

## `toast/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `padding` | `:string` | `"small"` | Content padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"small"` | Internal spacing |
| `horizontal` | `:string` | `"right"` | Horizontal position |
| `vertical` | `:string` | `"top"` | Vertical position |
| `vertical_space` | `:string` | `"medium"` | Vertical offset |
| `border_position` | `:string` | `nil` | Border accent position |
| `content_border` | `:string` | `nil` | Content border size |

**Slot**: `inner_block` — toast content.

## Available Options

- **Variants**: `base`, `default`, `outline`, `shadow`, `bordered`, `gradient`
- **Colors**: `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`
- **Horizontal**: `left`, `center`, `right`
- **Vertical**: `top`, `bottom`

## Usage Examples

### Basic / colored / variant

```heex
<.toast id="notification">
  <p>Your changes have been saved.</p>
</.toast>

<.toast id="success-toast" color="success" variant="shadow">
  <div class="flex items-center gap-2">
    <.icon name="hero-check-circle" class="size-5" />
    <span>Operation completed successfully!</span>
  </div>
</.toast>

<.toast id="error-toast" color="danger" variant="shadow">
  <div class="flex items-center gap-2">
    <.icon name="hero-x-circle" class="size-5" />
    <span>An error occurred. Please try again.</span>
  </div>
</.toast>

<.toast id="gradient-toast" variant="gradient" color="primary">Gradient style</.toast>
```

### Positioning (combine any `horizontal` + `vertical`)

```heex
<.toast id="top-left" horizontal="left" vertical="top">Top Left</.toast>
<.toast id="bottom-center" horizontal="center" vertical="bottom">Bottom Center</.toast>
```

### With Border Accent

```heex
<.toast id="accent-toast" color="primary" content_border="small" border_position="start">
  <p>Important notification with accent border</p>
</.toast>
```

### Toast Group

```heex
<.toast_group vertical="top" horizontal="right">
  <.toast id="toast-1" color="success">First notification</.toast>
  <.toast id="toast-2" color="info">Second notification</.toast>
  <.toast id="toast-3" color="warning">Third notification</.toast>
</.toast_group>
```

## Common Patterns

### Flash Message (dismissible)

```heex
<.toast
  :if={@flash["info"]}
  id="flash-info"
  color="info"
  variant="shadow"
  horizontal="center"
  vertical="top"
>
  <div class="flex items-center justify-between gap-4">
    <span>{@flash["info"]}</span>
    <button phx-click={hide_toast("#flash-info")}>
      <.icon name="hero-x-mark" class="size-4" />
    </button>
  </div>
</.toast>
```

Same pattern for `@flash["error"]` with `color="danger"`.

### Action Toast

```heex
<.toast id="action-toast" variant="shadow">
  <div class="flex items-center justify-between gap-4">
    <span>Item deleted</span>
    <.button size="small" variant="outline" phx-click="undo_delete">
      Undo
    </.button>
  </div>
</.toast>
```

### Progress Toast

```heex
<.toast id="upload-toast" variant="shadow" color="primary">
  <div class="space-y-2">
    <div class="flex items-center justify-between">
      <span>Uploading file...</span>
      <span>{@progress}%</span>
    </div>
    <.progress value={@progress} color="primary" size="small" />
  </div>
</.toast>
```

## Helper Functions

```elixir
# Show a toast
show_toast(js \\ %JS{}, id)

# Hide a toast
hide_toast(js \\ %JS{}, id)
```
