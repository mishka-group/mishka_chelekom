# Scroll Area Component

Customizable scrollable container with styled scrollbars.

**Documentation**: https://mishka.tools/chelekom/docs/scroll-area

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component scroll_area
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `scrollArea.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `type` | `:string` | `"auto"` | Scrollbar visibility (`hover`, `auto`, `never`) |
| `horizontal` | `:boolean` | `false` | Enable horizontal scrollbar |
| `vertical` | `:boolean` | `true` | Enable vertical scrollbar |
| `height` | `:string` | `"h-96"` | Container height |
| `width` | `:string` | `"w-full"` | Container width |
| `padding` | `:string` | `"extra_small"` | Content padding |
| `scrollbar_width` | `:string` | `"w-2"` | Vertical scrollbar width |
| `scrollbar_height` | `:string` | `"h-2"` | Horizontal scrollbar height |

## Slots

### `inner_block` Slot

Scrollable content.

## Available Options

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Scroll Area

```heex
<.scroll_area id="content-scroll" height="h-64">
  <p>Long content goes here...</p>
  <p>More content...</p>
  <p>Even more content...</p>
</.scroll_area>
```

### Custom Dimensions

```heex
<.scroll_area id="custom-scroll" height="h-48" width="w-96">
  Content here...
</.scroll_area>
```

### Horizontal Scrolling

```heex
<.scroll_area id="horizontal-scroll" horizontal vertical={false}>
  <div class="flex gap-4 w-max">
    <div :for={i <- 1..10} class="w-48 h-32 bg-gray-200 rounded">
      Item {i}
    </div>
  </div>
</.scroll_area>
```

### Both Directions

```heex
<.scroll_area id="both-scroll" horizontal vertical height="h-64" width="w-96">
  <div class="w-[800px] h-[600px]">
    Large content that scrolls both ways
  </div>
</.scroll_area>
```

### Hover Scrollbar

```heex
<.scroll_area id="hover-scroll" type="hover" height="h-64">
  Scrollbar appears on hover
</.scroll_area>
```

### Custom Scrollbar Size

```heex
<.scroll_area id="thick-scroll" scrollbar_width="w-3" height="h-64">
  Content with thicker scrollbar
</.scroll_area>
```

## Common Patterns

### Chat Messages Container

```heex
<.scroll_area id="chat-messages" height="h-96" class="border rounded-lg">
  <div class="p-4 space-y-4">
    <div :for={message <- @messages} class="flex gap-3">
      <.avatar src={message.user.avatar} size="small" />
      <div>
        <p class="font-medium">{message.user.name}</p>
        <p class="text-sm text-gray-600">{message.content}</p>
      </div>
    </div>
  </div>
</.scroll_area>
```

### Code Preview

```heex
<.scroll_area id="code-preview" horizontal vertical height="h-64" class="bg-gray-900 rounded-lg">
  <pre class="p-4 text-sm text-gray-100 font-mono">
    <code>{@code}</code>
  </pre>
</.scroll_area>
```

### Sidebar Navigation

```heex
<.scroll_area id="sidebar-nav" height="h-[calc(100vh-4rem)]" padding="small">
  <nav class="space-y-2">
    <a :for={item <- @nav_items} href={item.path} class="block p-2 rounded hover:bg-gray-100">
      {item.label}
    </a>
  </nav>
</.scroll_area>
```
