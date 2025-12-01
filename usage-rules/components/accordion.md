# Accordion Component

Collapsible sections component for organizing content into expandable panels with smooth animations.

**Documentation**: https://mishka.tools/chelekom/docs/accordion

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component accordion

# Generate with specific options
mix mishka.ui.gen.component accordion --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component accordion --module MyAppWeb.Components.CustomAccordion
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | `collapsible.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | auto-generated | Unique identifier for the accordion |
| `class` | `:any` | `nil` | Custom CSS class for additional styling |
| `multiple` | `:boolean` | `false` | Allow multiple panels open simultaneously |
| `collapsible` | `:boolean` | `true` | Allow all panels to be closed |
| `duration` | `:integer` | `200` | Animation duration in milliseconds |
| `keep_mounted` | `:boolean` | `false` | Keep content mounted after first open |
| `server_events` | `:boolean` | `false` | Send open/close events to LiveView |
| `event_handler` | `:string` | `nil` | Specify event handler for accordion events |
| `initial_open` | `:list` | `[]` | List of initially open item IDs |
| `variant` | `:string` | `"base"` | Visual style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"medium"` | Overall size |
| `rounded` | `:string` | `"medium"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border style |
| `space` | `:string` | `"small"` | Space between separated items |
| `media_size` | `:string` | `"small"` | Size of media elements like icons and images |
| `padding` | `:string` | `"small"` | Padding for accordion items |
| `chevron_icon` | `:string` | `"hero-chevron-down"` | Chevron icon |
| `chevron_position` | `:string` | `"right"` | Chevron position (left/right) |
| `left_chevron` | `:boolean` | `false` | Position chevron on the left |
| `right_chevron` | `:boolean` | `false` | Position chevron on the right |
| `hide_chevron` | `:boolean` | `false` | Hide the chevron icon |
| `chevron_class` | `:string` | `nil` | Additional CSS classes for the chevron |

## Slots

### `item` Slot

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | `:string` | No | Unique identifier (auto-generated if not provided) |
| `title` | `:string` | **Yes** | Title of the accordion item |
| `description` | `:string` | No | Optional description/subtitle |
| `icon` | `:string` | No | Optional icon name |
| `icon_class` | `:string` | No | Additional CSS classes for the item icon |
| `icon_wrapper_class` | `:string` | No | Additional CSS classes for the item icon wrapper |
| `image` | `:string` | No | Optional image source URL |
| `image_class` | `:string` | No | Additional CSS classes for the image |
| `trigger_class` | `:string` | No | Additional CSS classes for the trigger |
| `content_class` | `:string` | No | Additional CSS classes for the content |
| `open` | `:boolean` | No | Whether this item should be initially open |

## Available Options

### Variants
`base`, `base_separated`, `default`, `bordered`, `bordered_separated`, `outline`, `outline_separated`, `transparent`, `shadow`, `gradient`

### Colors
`natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Usage

```heex
<.accordion>
  <:item title="Section 1">
    Content for section 1
  </:item>
  <:item title="Section 2">
    Content for section 2
  </:item>
</.accordion>
```

### With Colors and Variants

```heex
<.accordion variant="outline" color="primary" rounded="large">
  <:item title="Primary Outline" description="With description">
    This is an outlined accordion with primary color.
  </:item>
</.accordion>
```

### Multiple Open Panels

```heex
<.accordion multiple={true}>
  <:item title="Panel 1" open={true}>
    Initially open panel
  </:item>
  <:item title="Panel 2">
    Closed by default
  </:item>
</.accordion>
```

### With Icons and Images

```heex
<.accordion>
  <:item title="Settings" icon="hero-cog-6-tooth">
    Settings content here
  </:item>
  <:item title="Profile" image="/images/avatar.png">
    Profile content here
  </:item>
</.accordion>
```

### Server Events Integration

```heex
<.accordion server_events={true} event_handler="handle_accordion">
  <:item id="item-1" title="Tracked Panel">
    This panel sends events to LiveView
  </:item>
</.accordion>
```

Handle events in your LiveView:

```elixir
def handle_event("collapsible_open", %{"id" => id}, socket) do
  # Handle panel open
  {:noreply, socket}
end

def handle_event("collapsible_close", %{"id" => id}, socket) do
  # Handle panel close
  {:noreply, socket}
end
```

### Initial Open Items

```heex
<.accordion initial_open={["section-1", "section-3"]}>
  <:item id="section-1" title="Section 1">Open by default</:item>
  <:item id="section-2" title="Section 2">Closed</:item>
  <:item id="section-3" title="Section 3">Open by default</:item>
</.accordion>
```

### Separated Variant with Space

```heex
<.accordion variant="bordered_separated" space="medium" rounded="large">
  <:item title="Card 1">Content 1</:item>
  <:item title="Card 2">Content 2</:item>
</.accordion>
```

### Custom Chevron

```heex
<.accordion
  chevron_icon="hero-plus"
  chevron_position="left"
  chevron_class="text-primary-500"
>
  <:item title="Custom Chevron">
    Content with custom chevron on the left
  </:item>
</.accordion>
```

### Hidden Chevron

```heex
<.accordion hide_chevron={true}>
  <:item title="No Chevron">
    Accordion without chevron indicator
  </:item>
</.accordion>
```

## JavaScript Hook

The accordion uses the `Collapsible` JavaScript hook for animations. This is automatically configured when you generate the component.

The hook is registered in `assets/js/app.js`:

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```

## Accessibility

- WAI-ARIA compliant with proper `aria-expanded` attributes
- Keyboard navigation support
- Screen reader friendly
- Focus management for opened/closed states
