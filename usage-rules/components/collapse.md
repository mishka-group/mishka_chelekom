# Collapse Component

Collapsible content component with smooth animations and server event support.

**Documentation**: https://mishka.tools/chelekom/docs/collapse

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component collapse

# Generate with custom module name
mix mishka.ui.gen.component collapse --module MyAppWeb.Components.CustomCollapse
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `collapsible.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `open` | `:boolean` | `false` | Initial open state |
| `duration` | `:integer` | `200` | Animation duration (ms) |
| `keep_mounted` | `:boolean` | `false` | Keep content in DOM when closed |
| `server_events` | `:boolean` | `false` | Enable server-side events |
| `event_handler` | `:string` | `nil` | Custom event handler name |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `trigger` Slot

The clickable element that toggles the collapse.

### `inner_block` Slot

The collapsible content.

## Server Events

When `server_events={true}`, the component sends events to the server:

- `collapsible_open` - Fired when content opens
- `collapsible_close` - Fired when content closes

Use `event_handler` to customize the event name.

## Usage Examples

### Basic Collapse

```heex
<.collapse id="basic-collapse">
  <:trigger>
    <button class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg">
      Toggle Content
    </button>
  </:trigger>
  <p class="p-4">
    This content can be toggled on and off.
  </p>
</.collapse>
```

### Initially Open

```heex
<.collapse id="open-collapse" open={true}>
  <:trigger>
    <button class="px-4 py-2 bg-blue-500 text-white rounded">
      Settings
    </button>
  </:trigger>
  <div class="p-4 border rounded mt-2">
    <p>Settings content is visible by default.</p>
  </div>
</.collapse>
```

### Custom Animation Duration

```heex
<.collapse id="slow-collapse" duration={500}>
  <:trigger>
    <button class="btn">Slow Animation</button>
  </:trigger>
  <div class="p-4">
    This uses a 500ms animation.
  </div>
</.collapse>
```

### Fast Animation

```heex
<.collapse id="fast-collapse" duration={100}>
  <:trigger>
    <button class="btn">Fast Animation</button>
  </:trigger>
  <div class="p-4">
    This uses a 100ms animation.
  </div>
</.collapse>
```

### With Server Events

```heex
<.collapse id="server-collapse" server_events={true}>
  <:trigger>
    <button class="px-4 py-2 border rounded">
      Track Toggle
    </button>
  </:trigger>
  <div class="p-4">
    Opening/closing this sends events to the server.
  </div>
</.collapse>
```

Handle in LiveView:

```elixir
def handle_event("collapsible_open", %{"id" => id}, socket) do
  # Handle open event
  {:noreply, socket}
end

def handle_event("collapsible_close", %{"id" => id}, socket) do
  # Handle close event
  {:noreply, socket}
end
```

### Custom Event Handler

```heex
<.collapse id="custom-collapse" server_events={true} event_handler="panel_toggled">
  <:trigger>
    <button class="btn">Toggle Panel</button>
  </:trigger>
  <div class="p-4">Panel content</div>
</.collapse>
```

```elixir
def handle_event("panel_toggled", %{"id" => id, "state" => state}, socket) do
  # state is "open" or "closed"
  {:noreply, socket}
end
```

### Keep Content Mounted

```heex
<.collapse id="mounted-collapse" keep_mounted={true}>
  <:trigger>
    <button class="btn">Toggle (Keep Mounted)</button>
  </:trigger>
  <div class="p-4">
    This content stays in the DOM even when hidden.
  </div>
</.collapse>
```

### With Icon Indicator

```heex
<.collapse id="icon-collapse">
  <:trigger>
    <button class="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded w-full justify-between">
      <span>More Options</span>
      <.icon name="hero-chevron-down" class="size-5 transition-transform" />
    </button>
  </:trigger>
  <div class="p-4 space-y-2">
    <p>Option 1</p>
    <p>Option 2</p>
    <p>Option 3</p>
  </div>
</.collapse>
```

## Common Patterns

### FAQ Section

```heex
<div class="space-y-2">
  <.collapse :for={{question, answer, index} <- Enum.with_index(@faqs)} id={"faq-#{index}"}>
    <:trigger>
      <button class="flex items-center justify-between w-full p-4 text-left bg-gray-50 hover:bg-gray-100 rounded-lg">
        <span class="font-medium">{question}</span>
        <.icon name="hero-plus" class="size-5" />
      </button>
    </:trigger>
    <div class="p-4 text-gray-600">
      {answer}
    </div>
  </.collapse>
</div>
```

### Sidebar Menu

```heex
<nav class="space-y-1">
  <.collapse id="menu-products">
    <:trigger>
      <button class="flex items-center justify-between w-full px-4 py-2 hover:bg-gray-100 rounded">
        <span class="flex items-center gap-2">
          <.icon name="hero-cube" class="size-5" />
          Products
        </span>
        <.icon name="hero-chevron-right" class="size-4" />
      </button>
    </:trigger>
    <div class="ml-6 space-y-1">
      <a href="/products/all" class="block px-4 py-2 hover:bg-gray-100 rounded">All Products</a>
      <a href="/products/new" class="block px-4 py-2 hover:bg-gray-100 rounded">New Arrivals</a>
      <a href="/products/sale" class="block px-4 py-2 hover:bg-gray-100 rounded">On Sale</a>
    </div>
  </.collapse>
</nav>
```

### Expandable Card

```heex
<div class="border rounded-lg">
  <.collapse id="card-details" open={true}>
    <:trigger>
      <div class="flex items-center justify-between p-4 cursor-pointer hover:bg-gray-50">
        <div>
          <h3 class="font-semibold">Order #12345</h3>
          <p class="text-sm text-gray-500">3 items - $149.99</p>
        </div>
        <.icon name="hero-chevron-down" class="size-5" />
      </div>
    </:trigger>
    <div class="border-t p-4">
      <ul class="space-y-2">
        <li class="flex justify-between">
          <span>Product A</span>
          <span>$49.99</span>
        </li>
        <li class="flex justify-between">
          <span>Product B</span>
          <span>$59.99</span>
        </li>
        <li class="flex justify-between">
          <span>Product C</span>
          <span>$40.01</span>
        </li>
      </ul>
    </div>
  </.collapse>
</div>
```

### Filter Panel

```heex
<.collapse id="filters" open={@show_filters} server_events={true}>
  <:trigger>
    <button class="flex items-center gap-2 px-4 py-2 border rounded">
      <.icon name="hero-funnel" class="size-5" />
      Filters
      <.badge :if={@active_filter_count > 0} color="primary">{@active_filter_count}</.badge>
    </button>
  </:trigger>
  <div class="p-4 mt-2 border rounded space-y-4">
    <div>
      <label class="font-medium">Category</label>
      <.group_checkbox field={@form[:categories]} variation="vertical">
        <:checkbox :for={cat <- @categories} value={cat.id} label={cat.name} />
      </.group_checkbox>
    </div>
    <div>
      <label class="font-medium">Price Range</label>
      <.range_field field={@form[:price_range]} min={0} max={1000} />
    </div>
  </div>
</.collapse>
```

## JavaScript Hook

The collapse uses the `Collapsible` JavaScript hook for smooth animations. This is automatically configured when you generate the component.

The hook is registered in `assets/js/app.js`:

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
