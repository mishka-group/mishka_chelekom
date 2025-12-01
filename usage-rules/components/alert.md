# Alert Component

Displays static alerts and dynamic flash messages for clear and effective user communication in Phoenix LiveView applications.

**Documentation**: https://mishka.tools/chelekom/docs/alert

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Important: Phoenix 1.8+ Flash Group

**Phoenix 1.8+ includes a built-in `flash_group` in `lib/your_app_web/components/layouts.ex`.**

Mishka's `flash_group` is **NOT automatically imported** to avoid conflicts. To use Mishka's flash_group:

1. Open `lib/your_app_web/components/layouts.ex`
2. Replace the existing flash_group call with Mishka's version
3. Or call it in any template where you need it

```elixir
# In layouts.ex or any template
<YourAppWeb.Components.Alert.flash_group flash={@flash} />
```

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component alert

# Generate with specific options
mix mishka.ui.gen.component alert --variant default,bordered --color success,danger,info

# Generate specific component types only
mix mishka.ui.gen.component alert --type flash,alert

# Generate with custom module name
mix mishka.ui.gen.component alert --module MyAppWeb.Components.CustomAlert
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

This module provides **three component types**:

| Component | Description |
|-----------|-------------|
| `flash/1` | Renders flash notices with auto-dismiss on click |
| `flash_group/1` | Renders a group of flash messages with predefined content |
| `alert/1` | Renders static alert messages |

## Helper Functions

| Function | Description |
|----------|-------------|
| `show_alert/1` | Shows an alert with transition effect |
| `show_alert/2` | Shows an alert with JS struct and selector |
| `hide_alert/1` | Hides an alert with transition effect |
| `hide_alert/2` | Hides an alert with JS struct and selector |

## Attributes

### Common Attributes (all components)

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | auto-generated | Unique identifier |
| `kind` | `:atom` | `:natural` | Color/type: `:info`, `:danger`, `:success`, `:warning`, `:error`, `:natural`, `:primary`, `:secondary`, `:misc`, `:dawn`, `:silver`, `:white`, `:dark` |
| `variant` | `:string` | varies | Style variant |
| `position` | `:string` | `""` | Fixed position: `"top_left"`, `"top_right"`, `"bottom_left"`, `"bottom_right"` |
| `width` | `:string` | `"full"` | Width: `"extra_small"`, `"small"`, `"medium"`, `"large"`, `"extra_large"`, `"full"`, `"fit"` |
| `border` | `:string` | `"extra_small"` | Border width |
| `padding` | `:string` | `"small"` | Padding size |
| `size` | `:string` | `"medium"` | Overall size (text, icons) |
| `rounded` | `:string` | `"small"` | Border radius |
| `z_index` | `:string` | `"z-50"` | Custom z-index class |
| `class` | `:any` | `nil` | Custom CSS class |

### `flash/1` Specific Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `flash` | `:map` | `%{}` | Map of flash messages to display |
| `title` | `:string` | `nil` | Title of the flash |
| `icon` | `:any` | `"hero-chat-bubble-bottom-center-text"` | Icon name |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `content_class` | `:string` | `nil` | Custom class for content |
| `title_class` | `:string` | `"flex items-center gap-1.5..."` | Custom class for title |
| `button_class` | `:string` | `"p-2"` | Custom class for close button |
| `rest` | `:global` | - | Global attributes |

### `flash_group/1` Specific Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `"flash-group"` | Unique identifier |
| `flash` | `:map` | **required** | Map of flash messages |
| `variant` | `:string` | `"bordered"` | Style variant |
| `position` | `:string` | `"top_right"` | Position on screen |

### `alert/1` Specific Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `:string` | `nil` | Alert title |
| `icon` | `:any` | `"hero-chat-bubble-bottom-center-text"` | Icon name |
| `icon_class` | `:string` | `nil` | Custom class for icon |
| `title_class` | `:string` | `"flex items-center gap-1.5..."` | Custom class for title |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |

## Slots

### `inner_block` Slot

All alert components accept an `inner_block` slot for custom content.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `gradient`

### Colors (kind)
`:natural`, `:white`, `:dark`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:error`, `:info`, `:misc`, `:dawn`, `:silver`

**Note**: `:error` and `:danger` are equivalent.

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Width
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `fit`

### Positions
`top_left`, `top_right`, `bottom_left`, `bottom_right`

## Usage Examples

### Basic Alert

```heex
<.alert kind={:info} title="Information">
  This is an informational message.
</.alert>
```

### Alert with Different Variants

```heex
<.alert kind={:success} variant="default" title="Success!">
  Your changes have been saved.
</.alert>

<.alert kind={:danger} variant="bordered" title="Error">
  Something went wrong.
</.alert>

<.alert kind={:warning} variant="outline" title="Warning">
  Please review your input.
</.alert>
```

### Alert Without Icon

```heex
<.alert kind={:primary} title="Note" icon={nil}>
  This alert has no icon.
</.alert>
```

### Positioned Alert

```heex
<.alert kind={:info} position="top_right" width="medium">
  Fixed position alert in top right corner.
</.alert>
```

### Flash Message

```heex
<.flash kind={:info} title="Welcome!" flash={@flash}>
  <p>You have successfully logged in.</p>
</.flash>
```

### Flash with Custom Styling

```heex
<.flash
  kind={:error}
  title="Error!"
  variant="bordered"
  width="large"
  size="large"
  flash={@flash}
/>
```

### Flash Group

```heex
<%# In your layout or root template %>
<.flash_group flash={@flash} />

<%# With custom position %>
<.flash_group flash={@flash} position="bottom_right" variant="shadow" />
```

### Using Helper Functions

```heex
<%# Show alert on mount %>
<.flash kind={:info} phx-mounted={show_alert("#welcome-flash")}>
  Welcome Back!
</.flash>

<%# Programmatic show/hide in LiveView %>
<button phx-click={show_alert("#my-alert")}>Show Alert</button>
<button phx-click={hide_alert("#my-alert")}>Hide Alert</button>

<.alert id="my-alert" kind={:success} title="Dynamic Alert" hidden>
  This alert can be shown/hidden programmatically.
</.alert>
```

### In LiveView Module

```elixir
def handle_event("show_notification", _, socket) do
  {:noreply, push_event(socket, "js-exec", %{to: "#notification", attr: "phx-show"})}
end

# Or using the helper functions directly
def handle_event("toggle_alert", _, socket) do
  # The show_alert/hide_alert functions return JS commands
  {:noreply, socket}
end
```

### Flash with Reconnection Handling

The `flash_group/1` component automatically handles LiveView disconnection/reconnection:

```heex
<.flash_group flash={@flash} />
```

This includes:
- Client error flash (shown on disconnect)
- Server error flash (shown on server error)
- Both auto-hide on reconnection

### Custom Gradient Alert

```heex
<.alert kind={:primary} variant="gradient" title="Premium Feature">
  Upgrade to access this feature.
</.alert>
```

### Alert Sizes

```heex
<.alert kind={:info} size="extra_small" title="Extra Small">Content</.alert>
<.alert kind={:info} size="small" title="Small">Content</.alert>
<.alert kind={:info} size="medium" title="Medium">Content</.alert>
<.alert kind={:info} size="large" title="Large">Content</.alert>
<.alert kind={:info} size="extra_large" title="Extra Large">Content</.alert>
```

## Phoenix Flash Integration

The flash components integrate with Phoenix's flash system:

```elixir
# In your controller
def create(conn, params) do
  # ...
  conn
  |> put_flash(:info, "Item created successfully!")
  |> redirect(to: ~p"/items")
end

# In your LiveView
def handle_event("save", params, socket) do
  # ...
  {:noreply, put_flash(socket, :info, "Saved!")}
end
```

```heex
<%# The flash component will automatically display the message %>
<.flash kind={:info} flash={@flash} title="Success" />
```

## Accessibility

- Uses `role="alert"` for screen reader announcement
- `aria-live="assertive"` for immediate announcement
- `aria-labelledby` links title to alert for context
- Close button has `aria-label` for accessibility
