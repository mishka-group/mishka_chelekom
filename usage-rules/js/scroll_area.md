# ScrollArea Hook

JavaScript hook for custom styled scrollbars with draggable thumb support.

## Hook Name

```javascript
ScrollArea
```

## Used By Components

- `scroll_area`

## Features

- **Custom Scrollbars**: Replace native scrollbars with styled versions
- **Vertical Scrolling**: Custom vertical scrollbar
- **Horizontal Scrolling**: Custom horizontal scrollbar
- **Draggable Thumbs**: Click and drag to scroll
- **Scroll Sync**: Thumb position syncs with content
- **Auto-hide**: Optional auto-hiding scrollbars
- **Keyboard Support**: Focus and keyboard scroll

## Element Structure

The hook expects this DOM structure:

```html
<div id="scroll-1" phx-hook="ScrollArea" class="scroll-area-wrapper">
  <!-- Scrollable viewport -->
  <div class="scroll-viewport">
    <div class="scroll-content">
      <!-- Your content here -->
    </div>
  </div>

  <!-- Vertical scrollbar -->
  <div class="scrollbar-y">
    <div class="thumb-y"></div>
  </div>

  <!-- Horizontal scrollbar -->
  <div class="scrollbar-x">
    <div class="thumb-x"></div>
  </div>
</div>
```

## Usage Examples

### Basic Scroll Area

```heex
<.scroll_area id="content-scroll" height="h-64">
  <p>Long scrollable content here...</p>
  <p>More content...</p>
  <p>Even more content...</p>
</.scroll_area>
```

### Fixed Height Container

```heex
<.scroll_area id="sidebar-scroll" height="h-[400px]" width="w-64">
  <nav>
    <a :for={item <- @nav_items} href={item.url} class="block p-2">
      {item.label}
    </a>
  </nav>
</.scroll_area>
```

### Both Scrollbars

```heex
<.scroll_area
  id="code-scroll"
  height="h-96"
  horizontal={true}
  vertical={true}
>
  <pre><code>{@code_content}</code></pre>
</.scroll_area>
```

### With Custom Scrollbar Width

```heex
<.scroll_area
  id="thin-scroll"
  height="h-48"
  scrollbar_width="w-1"
>
  <p>Content with thin scrollbar...</p>
</.scroll_area>
```

### Auto-hide Scrollbars

```heex
<.scroll_area
  id="auto-scroll"
  height="h-64"
  type="hover"
>
  <p>Scrollbars appear on hover...</p>
</.scroll_area>
```

### Horizontal Only

```heex
<.scroll_area
  id="horizontal-scroll"
  horizontal={true}
  vertical={false}
  class="w-full"
>
  <div class="flex gap-4 w-max">
    <.card :for={item <- @items} class="w-64 shrink-0">
      {item.title}
    </.card>
  </div>
</.scroll_area>
```

### Chat Messages Container

```heex
<.scroll_area
  id="chat-messages"
  height="h-[500px]"
  class="border rounded-lg"
  padding="medium"
>
  <div :for={message <- @messages} class="mb-4">
    <div class="font-medium">{message.sender}</div>
    <div class="text-gray-600">{message.content}</div>
  </div>
</.scroll_area>
```

### Code Editor Panel

```heex
<div class="flex gap-4">
  <.scroll_area id="file-tree" height="h-[600px]" width="w-48">
    <div :for={file <- @files} class="py-1 px-2 hover:bg-gray-100">
      {file.name}
    </div>
  </.scroll_area>

  <.scroll_area id="code-panel" height="h-[600px]" class="flex-1" horizontal={true}>
    <pre class="text-sm"><code>{@file_content}</code></pre>
  </.scroll_area>
</div>
```

### With Content Class

```heex
<.scroll_area
  id="padded-scroll"
  height="h-64"
  content_class="space-y-4"
  padding="large"
>
  <p :for={paragraph <- @paragraphs}>
    {paragraph}
  </p>
</.scroll_area>
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.scroll-area-wrapper` | Main container |
| `.scroll-viewport` | Scrollable area |
| `.scroll-content` | Inner content wrapper |
| `.scrollbar-y` | Vertical scrollbar track |
| `.scrollbar-x` | Horizontal scrollbar track |
| `.thumb-y` | Vertical scrollbar thumb |
| `.thumb-x` | Horizontal scrollbar thumb |

## Scrollbar Visibility

The component hides native scrollbars:

```css
.scroll-viewport {
  scrollbar-width: none; /* Firefox */
}
.scroll-viewport::-webkit-scrollbar {
  display: none; /* Chrome, Safari */
}
```

## Thumb Behavior

- **Click track**: Scroll to position
- **Drag thumb**: Smooth scroll
- **Wheel scroll**: Updates thumb position
- **Keyboard**: Arrow keys when focused

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import ScrollArea from "./scrollArea"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ScrollArea }
})
```
