# Alert Component

Static alerts and dynamic flash messages for Phoenix LiveView.

**Documentation**: https://mishka.tools/chelekom/docs/alert

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Important: Phoenix 1.8+ Flash Group

Phoenix 1.8+ ships a built-in `flash_group` in `lib/your_app_web/components/layouts.ex`. Mishka's `flash_group` is **NOT auto-imported** (avoids conflicts). To use Mishka's version, replace the existing call in `layouts.ex` (or call it in any template):

```elixir
<YourAppWeb.Components.Alert.flash_group flash={@flash} />
```

## Generate

```bash
mix mishka.ui.gen.component alert
mix mishka.ui.gen.component alert --variant default,bordered --color success,danger,info
mix mishka.ui.gen.component alert --type flash,alert
mix mishka.ui.gen.component alert --module MyAppWeb.Components.CustomAlert
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
| `flash/1` | Flash notices with auto-dismiss on click |
| `flash_group/1` | Group of flash messages with predefined content |
| `alert/1` | Static alert messages |

## Helper Functions

| Function | Description |
|----------|-------------|
| `show_alert/1` | Show an alert with transition effect |
| `show_alert/2` | Show an alert with JS struct and selector |
| `hide_alert/1` | Hide an alert with transition effect |
| `hide_alert/2` | Hide an alert with JS struct and selector |

## Attributes

### Common (all components)

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | auto-generated | Unique identifier |
| `kind` | `:atom` | `:natural` | Color/type: `:info`, `:danger`, `:success`, `:warning`, `:error`, `:natural`, `:primary`, `:secondary`, `:misc`, `:dawn`, `:silver`, `:white`, `:dark` (`:error` and `:danger` are equivalent) |
| `variant` | `:string` | varies | `base`, `default`, `outline`, `shadow`, `bordered`, `gradient` |
| `position` | `:string` | `""` | Fixed position: `"top_left"`, `"top_right"`, `"bottom_left"`, `"bottom_right"` |
| `width` | `:string` | `"full"` | `"extra_small"`, `"small"`, `"medium"`, `"large"`, `"extra_large"`, `"full"`, `"fit"` |
| `border` | `:string` | `"extra_small"` | Border width |
| `padding` | `:string` | `"small"` | `"extra_small"`, `"small"`, `"medium"`, `"large"`, `"extra_large"`, `"none"` |
| `size` | `:string` | `"medium"` | Overall size (text, icons): `"extra_small"`, `"small"`, `"medium"`, `"large"`, `"extra_large"` |
| `rounded` | `:string` | `"small"` | `"extra_small"`, `"small"`, `"medium"`, `"large"`, `"extra_large"`, `"full"`, `"none"` |
| `z_index` | `:string` | `"z-50"` | Custom z-index class |
| `class` | `:any` | `nil` | Custom CSS class |

### `flash/1` specific

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

### `flash_group/1` specific

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `"flash-group"` | Unique identifier |
| `flash` | `:map` | **required** | Map of flash messages |
| `variant` | `:string` | `"bordered"` | Style variant |
| `position` | `:string` | `"top_right"` | Position on screen |

### `alert/1` specific

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `:string` | `nil` | Alert title |
| `icon` | `:any` | `"hero-chat-bubble-bottom-center-text"` | Icon name |
| `icon_class` | `:string` | `nil` | Custom class for icon |
| `title_class` | `:string` | `"flex items-center gap-1.5..."` | Custom class for title |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |

## Slots

`inner_block` — all three components accept it for custom content.

## Usage Examples

### Basic alert, variants, no icon, positioned

```heex
<.alert kind={:info} title="Information">
  This is an informational message.
</.alert>

<.alert kind={:success} variant="default" title="Success!">
  Your changes have been saved.
</.alert>

<.alert kind={:danger} variant="bordered" title="Error">
  Something went wrong.
</.alert>

<.alert kind={:warning} variant="outline" title="Warning">
  Please review your input.
</.alert>

<%# No icon %>
<.alert kind={:primary} title="Note" icon={nil}>
  This alert has no icon.
</.alert>

<%# Fixed position %>
<.alert kind={:info} position="top_right" width="medium">
  Fixed position alert in top right corner.
</.alert>

<%# Gradient variant %>
<.alert kind={:primary} variant="gradient" title="Premium Feature">
  Upgrade to access this feature.
</.alert>

<%# Sizes: extra_small, small, medium, large, extra_large %>
<.alert kind={:info} size="large" title="Large">Content</.alert>
```

### Flash message and flash group

```heex
<.flash kind={:info} title="Welcome!" flash={@flash}>
  <p>You have successfully logged in.</p>
</.flash>

<%# Custom styling %>
<.flash
  kind={:error}
  title="Error!"
  variant="bordered"
  width="large"
  size="large"
  flash={@flash}
/>

<%# In your layout or root template %>
<.flash_group flash={@flash} />

<%# With custom position/variant %>
<.flash_group flash={@flash} position="bottom_right" variant="shadow" />
```

`flash_group/1` also auto-handles LiveView disconnection/reconnection: shows a client-error flash on disconnect and a server-error flash on server error, both auto-hiding on reconnection.

### Helper functions (show/hide)

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

Server-side push works too — `show_alert`/`hide_alert` return JS commands, or you can push the `"js-exec"` event directly:

```elixir
def handle_event("show_notification", _, socket) do
  {:noreply, push_event(socket, "js-exec", %{to: "#notification", attr: "phx-show"})}
end
```

## Phoenix Flash Integration

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
