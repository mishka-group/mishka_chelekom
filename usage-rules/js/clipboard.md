# Clipboard Hook

JS hook (`Clipboard`) for copying text to clipboard with visual feedback and accessibility support. Used by the `clipboard` component.

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-timeout` | `number` | `1500` | Duration to show success/error state (ms) |
| `data-success-class` | `string` | `"clipboard-success"` | CSS class for success state |
| `data-error-class` | `string` | `"clipboard-error"` | CSS class for error state |
| `data-clipboard-text` | `string` | `nil` | Static text to copy |
| `data-target-selector` | `string` | `nil` | CSS selector for element to copy from |
| `data-copy-success-text` | `string` | `"Copied!"` | Success message text |
| `data-copy-error-text` | `string` | `"Failed!"` | Error message text |
| `data-dynamic-label` | `string` | `"false"` | Update label with status message |

## Features

- **Clipboard API**: modern `navigator.clipboard.writeText()` with fallback (temporary textarea for older browsers)
- **Visual Feedback**: success/error states toggled via CSS classes
- **Dynamic Labels**: optionally updates button text on copy
- **Accessibility**: ARIA live announcements for screen readers
- **Multiple Sources**: copy from attribute, selector, or content slot

## Element Structure

```html
<span id="clip-1" phx-hook="Clipboard" data-clipboard-text="Copy me">
  <!-- Content to copy (optional) -->
  <span class="clipboard-content">Text to copy</span>

  <!-- Copy button -->
  <button class="clipboard-button">
    <span class="clipboard-default-label">Copy</span>
    <span class="clipboard-success-label hidden">Copied!</span>
    <span class="clipboard-error-label hidden">Failed!</span>
  </button>
</span>
```

## Usage Examples

### Basic

```heex
<.clipboard text="Hello, World!">
  <:trigger>
    <.button>Copy</.button>
  </:trigger>
</.clipboard>
```

### Copy From Content Slot

```heex
<.clipboard>
  <:content>
    <code>npm install mishka_chelekom</code>
  </:content>
  <:trigger>
    <.icon name="hero-clipboard" class="size-5" />
  </:trigger>
</.clipboard>
```

### Dynamic Label

```heex
<.clipboard
  text={@api_key}
  dynamic_label={true}
  copy_success_text="Copied!"
  copy_error_text="Failed"
>
  <:trigger>
    <.button>Copy API Key</.button>
  </:trigger>
</.clipboard>
```

### Copy From Selector

```heex
<div id="code-block">
  <pre><code>defmodule Example do
  def hello, do: "world"
end</code></pre>
</div>

<.clipboard target_selector="#code-block code">
  <:trigger>
    <.button size="small">Copy Code</.button>
  </:trigger>
</.clipboard>
```

### Custom Feedback (class + timeout)

```heex
<.clipboard
  text={@share_url}
  success_class="text-green-500"
  error_class="text-red-500"
  timeout={2000}
>
  <:trigger>
    <.button variant="outline">
      <.icon name="hero-share" class="size-4" />
      Share Link
    </.button>
  </:trigger>
</.clipboard>
```

### Icon States via Label Classes

```heex
<.clipboard text={@code_snippet}>
  <:trigger>
    <span class="clipboard-default-label">
      <.icon name="hero-clipboard" class="size-5" />
    </span>
    <span class="clipboard-success-label hidden">
      <.icon name="hero-check" class="size-5 text-green-500" />
    </span>
  </:trigger>
</.clipboard>
```

## CSS Classes

| Class | When Applied |
|-------|--------------|
| `clipboard-success` | After successful copy |
| `clipboard-error` | After failed copy |
| `.clipboard-default-label` | Hidden on success/error |
| `.clipboard-success-label` | Shown on success |
| `.clipboard-error-label` | Shown on error |

## JavaScript Integration

```javascript
import Clipboard from "./clipboard"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Clipboard }
})
```
