# Clipboard Component

Copy-to-clipboard utility with customizable feedback, accessibility features, and dynamic status messages.

**Documentation**: https://mishka.tools/chelekom/docs/clipboard

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component clipboard

# Generate with custom module name
mix mishka.ui.gen.component clipboard --module MyAppWeb.Components.CustomClipboard
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `clipboard.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | auto-generated | Unique identifier |
| `text` | `:string` | `nil` | Static text to copy (highest priority) |
| `target_selector` | `:string` | `nil` | CSS selector for element to copy from |
| `timeout` | `:integer` | `2000` | Feedback reset time (ms) |
| `success_class` | `:string` | `nil` | Class applied on success |
| `error_class` | `:string` | `nil` | Class applied on error |
| `copy_success_text` | `:string` | `"Copied!"` | Success message |
| `copy_error_text` | `:string` | `"Failed to copy"` | Error message |
| `show_status_text` | `:boolean` | `true` | Show status message |
| `dynamic_label` | `:boolean` | `false` | Update label on copy |
| `copy_button_label` | `:string` | `"Copy to clipboard"` | Screen reader label |
| `text_description` | `:string` | `nil` | Hidden accessibility description |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `trigger` Slot (Required)

The clickable element that activates the copy action.

### `content` Slot (Optional)

Fallback content to copy if `text` and `target_selector` are not provided.

### `inner_block` Slot (Optional)

Additional wrapper content.

## Copy Priority

Content sources are prioritized in this order:
1. `text` attribute (explicit text)
2. `target_selector` (content from DOM element)
3. `:content` slot

## Usage Examples

### Basic Copy Button

```heex
<.clipboard text="Text to copy">
  <:trigger>
    <button class="px-4 py-2 bg-blue-500 text-white rounded">
      Copy
    </button>
  </:trigger>
</.clipboard>
```

### Copy from Element

```heex
<div id="code-block" class="p-4 bg-gray-100 rounded">
  npm install mishka_chelekom
</div>

<.clipboard target_selector="#code-block">
  <:trigger>
    <button class="text-sm text-blue-500">Copy command</button>
  </:trigger>
</.clipboard>
```

### With Custom Feedback

```heex
<.clipboard
  text="Copied content"
  copy_success_text="Copied to clipboard!"
  copy_error_text="Copy failed, try again"
  timeout={3000}
>
  <:trigger>
    <button class="btn">Copy</button>
  </:trigger>
</.clipboard>
```

### With Success/Error Classes

```heex
<.clipboard
  text="Copy me"
  success_class="bg-green-500 text-white"
  error_class="bg-red-500 text-white"
>
  <:trigger>
    <button class="px-4 py-2 border rounded transition-colors">
      Copy
    </button>
  </:trigger>
</.clipboard>
```

### Dynamic Label

```heex
<.clipboard text="API Key: abc123" dynamic_label={true}>
  <:trigger>
    <button class="flex items-center gap-2">
      <.icon name="hero-clipboard" class="size-5" />
      <span>Copy API Key</span>
    </button>
  </:trigger>
</.clipboard>
```

### Hidden Status Text

```heex
<.clipboard text="Secret value" show_status_text={false}>
  <:trigger>
    <button class="p-2 hover:bg-gray-100 rounded">
      <.icon name="hero-clipboard" class="size-5" />
    </button>
  </:trigger>
</.clipboard>
```

### With Content Slot

```heex
<.clipboard>
  <:trigger>
    <button class="btn">Copy Code</button>
  </:trigger>
  <:content>
defmodule MyApp do
  def hello, do: "world"
end
  </:content>
</.clipboard>
```

### With Accessibility Description

```heex
<.clipboard
  text={@api_key}
  copy_button_label="Copy API key to clipboard"
  text_description="Your unique API key for authentication"
>
  <:trigger>
    <button class="btn btn-primary">
      <.icon name="hero-key" class="size-5" />
      Copy Key
    </button>
  </:trigger>
</.clipboard>
```

## Common Patterns

### Code Block with Copy

```heex
<div class="relative">
  <pre id="code-example" class="p-4 bg-gray-900 text-gray-100 rounded-lg overflow-x-auto">
    <code>mix deps.get && mix phx.server</code>
  </pre>
  <.clipboard target_selector="#code-example" class="absolute top-2 right-2">
    <:trigger>
      <button class="p-2 bg-gray-700 hover:bg-gray-600 rounded text-gray-300">
        <.icon name="hero-clipboard" class="size-4" />
      </button>
    </:trigger>
  </.clipboard>
</div>
```

### Share Link

```heex
<div class="flex items-center gap-2">
  <input
    id="share-link"
    type="text"
    value={@share_url}
    readonly
    class="flex-1 px-3 py-2 border rounded"
  />
  <.clipboard target_selector="#share-link">
    <:trigger>
      <button class="px-4 py-2 bg-primary-500 text-white rounded">
        Copy Link
      </button>
    </:trigger>
  </.clipboard>
</div>
```

### API Key Display

```heex
<div class="p-4 bg-gray-50 rounded-lg">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm text-gray-500">API Key</p>
      <code id="api-key" class="text-sm font-mono">{@masked_key}</code>
    </div>
    <.clipboard text={@full_api_key}>
      <:trigger>
        <button class="flex items-center gap-1 text-sm text-blue-500 hover:text-blue-700">
          <.icon name="hero-clipboard-document" class="size-4" />
          Copy
        </button>
      </:trigger>
    </.clipboard>
  </div>
</div>
```

### Color Picker Copy

```heex
<div :for={color <- @colors} class="flex items-center gap-2">
  <div class="size-8 rounded" style={"background-color: #{color}"} />
  <span id={"color-#{color}"} class="font-mono text-sm">{color}</span>
  <.clipboard text={color} show_status_text={false}>
    <:trigger>
      <button class="p-1 hover:bg-gray-100 rounded">
        <.icon name="hero-clipboard" class="size-4" />
      </button>
    </:trigger>
  </.clipboard>
</div>
```

## JavaScript Hook

The clipboard uses the `Clipboard` JavaScript hook. This is automatically configured when you generate the component.

The hook is registered in `assets/js/app.js`:

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
