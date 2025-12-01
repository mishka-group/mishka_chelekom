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

## Attributes

### `toast/1` Attributes

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

## Slots

### `inner_block` Slot

Toast content.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Positions
- Horizontal: `left`, `center`, `right`
- Vertical: `top`, `bottom`

## Usage Examples

### Basic Toast

```heex
<.toast id="notification">
  <p>Your changes have been saved.</p>
</.toast>
```

### Success Toast

```heex
<.toast id="success-toast" color="success" variant="shadow">
  <div class="flex items-center gap-2">
    <.icon name="hero-check-circle" class="size-5" />
    <span>Operation completed successfully!</span>
  </div>
</.toast>
```

### Error Toast

```heex
<.toast id="error-toast" color="danger" variant="shadow">
  <div class="flex items-center gap-2">
    <.icon name="hero-x-circle" class="size-5" />
    <span>An error occurred. Please try again.</span>
  </div>
</.toast>
```

### Different Positions

```heex
<.toast id="top-left" horizontal="left" vertical="top">Top Left</.toast>
<.toast id="top-center" horizontal="center" vertical="top">Top Center</.toast>
<.toast id="top-right" horizontal="right" vertical="top">Top Right</.toast>
<.toast id="bottom-left" horizontal="left" vertical="bottom">Bottom Left</.toast>
<.toast id="bottom-center" horizontal="center" vertical="bottom">Bottom Center</.toast>
<.toast id="bottom-right" horizontal="right" vertical="bottom">Bottom Right</.toast>
```

### With Border Accent

```heex
<.toast id="accent-toast" color="primary" content_border="small" border_position="start">
  <p>Important notification with accent border</p>
</.toast>
```

### Different Variants

```heex
<.toast id="default-toast" variant="default">Default style</.toast>
<.toast id="shadow-toast" variant="shadow">Shadow style</.toast>
<.toast id="bordered-toast" variant="bordered">Bordered style</.toast>
<.toast id="gradient-toast" variant="gradient" color="primary">Gradient style</.toast>
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

### Flash Messages

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

<.toast
  :if={@flash["error"]}
  id="flash-error"
  color="danger"
  variant="shadow"
  horizontal="center"
  vertical="top"
>
  <div class="flex items-center justify-between gap-4">
    <span>{@flash["error"]}</span>
    <button phx-click={hide_toast("#flash-error")}>
      <.icon name="hero-x-mark" class="size-4" />
    </button>
  </div>
</.toast>
```

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
