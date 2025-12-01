# Collapsible Hook

JavaScript hook for accordion and collapse functionality with smooth animations.

## Hook Name

```javascript
Collapsible
```

## Used By Components

- `accordion`
- `collapse`

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-multiple` | `boolean` | `false` | Allow multiple sections open |
| `data-collapsible` | `string` | `"true"` | Allow all sections to close |
| `data-duration` | `number` | `200` | Animation duration in milliseconds |
| `data-keep-mounted` | `string` | `"true"` | Keep content in DOM when closed |
| `data-server-events` | `string` | `"false"` | Send events to server |
| `data-event-handler` | `string` | `nil` | Server event handler name |
| `data-initial-open` | `string` | `""` | Comma-separated IDs of initially open sections |

## Features

- **Single/Multiple Mode**: Open one or many sections at once
- **Smooth Animations**: Height-based CSS transitions
- **Server Events**: Optional LiveView server notifications
- **Keep Mounted**: Content stays in DOM for forms/state
- **Keyboard Navigation**: Arrow keys and Enter/Space
- **Accessibility**: ARIA expanded states and roles

## Element Structure

The hook expects this DOM structure:

```html
<div id="accordion-1" phx-hook="Collapsible" data-multiple="false">
  <div class="accordion-item">
    <button class="accordion-trigger" aria-expanded="false">
      Section 1
    </button>
    <div class="accordion-content" role="region">
      Content 1
    </div>
  </div>
  <div class="accordion-item">
    <button class="accordion-trigger" aria-expanded="false">
      Section 2
    </button>
    <div class="accordion-content" role="region">
      Content 2
    </div>
  </div>
</div>
```

## Usage Examples

### Basic Accordion

```heex
<.accordion id="faq-accordion">
  <:item title="What is Mishka Chelekom?">
    A UI component library for Phoenix LiveView.
  </:item>
  <:item title="How do I install it?">
    Add mishka_chelekom to your mix.exs dependencies.
  </:item>
</.accordion>
```

### Multiple Open Sections

```heex
<.accordion id="features-accordion" multiple={true}>
  <:item title="Feature 1">Description 1</:item>
  <:item title="Feature 2">Description 2</:item>
  <:item title="Feature 3">Description 3</:item>
</.accordion>
```

### With Initial Open

```heex
<.accordion id="docs-accordion" initial_open={["section-1", "section-3"]}>
  <:item id="section-1" title="Getting Started">
    Installation guide...
  </:item>
  <:item id="section-2" title="Configuration">
    Config options...
  </:item>
  <:item id="section-3" title="Examples">
    Code examples...
  </:item>
</.accordion>
```

### Collapse Component

```heex
<.collapse id="details-collapse">
  <:trigger>
    <.button>Show Details</.button>
  </:trigger>
  <:content>
    <p>Hidden content revealed on click.</p>
  </:content>
</.collapse>
```

### With Server Events

```heex
<.accordion
  id="tracked-accordion"
  server_events={true}
  event_handler="accordion_changed"
>
  <:item title="Section 1">Content 1</:item>
  <:item title="Section 2">Content 2</:item>
</.accordion>
```

Handle in LiveView:

```elixir
def handle_event("accordion_changed", %{"id" => id, "open" => open}, socket) do
  # Track which sections are open
  {:noreply, socket}
end
```

### Non-Collapsible (Always One Open)

```heex
<.accordion id="tabs-accordion" collapsible={false}>
  <:item title="Tab 1">Content always visible</:item>
  <:item title="Tab 2">Other content</:item>
</.accordion>
```

### Custom Animation Duration

```heex
<.accordion id="slow-accordion" duration={500}>
  <:item title="Slow Animation">
    This opens with a 500ms animation.
  </:item>
</.accordion>
```

## Keyboard Controls

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Toggle current section |
| `ArrowDown` | Focus next trigger |
| `ArrowUp` | Focus previous trigger |
| `Home` | Focus first trigger |
| `End` | Focus last trigger |

## CSS Classes

| Class | Description |
|-------|-------------|
| `.accordion-item` | Container for each section |
| `.accordion-trigger` | Clickable header button |
| `.accordion-content` | Collapsible content area |
| `.accordion-icon` | Rotate icon on open/close |

## Animation

The hook animates using CSS height transitions:

```css
.accordion-content {
  overflow: hidden;
  transition: height var(--duration, 200ms) ease;
}
```

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Collapsible from "./collapsible"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Collapsible }
})
```
