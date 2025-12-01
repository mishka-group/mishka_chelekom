# Badge Component

Displays badges with icons, indicators, and dismiss functionality for notifications and status updates in Phoenix LiveView.

**Documentation**: https://mishka.tools/chelekom/docs/badge

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component badge

# Generate with specific options
mix mishka.ui.gen.component badge --variant default,outline --color primary,success,danger

# Generate with custom module name
mix mishka.ui.gen.component badge --module MyAppWeb.Components.CustomBadge
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Helper Functions

| Function | Description |
|----------|-------------|
| `show_badge/1` | Shows a badge with transition effect |
| `show_badge/2` | Shows a badge with JS struct and selector |
| `hide_badge/1` | Hides a badge with transition effect |
| `hide_badge/2` | Hides a badge with JS struct and selector |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"extra_small"` | Badge size |
| `rounded` | `:string` | `"small"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border width |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `icon` | `:string` | `nil` | Icon name |
| `class` | `:any` | `nil` | Custom CSS class |
| `icon_class` | `:string` | `nil` | Icon styling class |
| `content_class` | `:string` | `nil` | Content styling class |
| `dismiss_class` | `:string` | `nil` | Dismiss button styling |
| `badge_position` | `:string` | `""` | Position for floating badges |
| `indicator_class` | `:string` | `nil` | Indicator styling class |
| `indicator_size` | `:string` | `""` | Indicator size |
| `params` | `:map` | `%{kind: "badge"}` | Additional params for events |
| `type` | `:string` | `"button"` | Button type for dismiss |

## Global Attributes (Boolean Flags)

| Attribute | Description |
|-----------|-------------|
| `pinging` | Adds ping animation to indicator |
| `circle` | Creates circular badge (equal width/height) |
| `dismiss` | Adds dismiss button (right side) |
| `right_dismiss` | Adds dismiss button on right |
| `left_dismiss` | Adds dismiss button on left |
| `indicator` | Shows indicator (left side) |
| `left_indicator` | Shows indicator on left |
| `right_indicator` | Shows indicator on right |
| `top_left_indicator` | Shows indicator top-left |
| `top_center_indicator` | Shows indicator top-center |
| `top_right_indicator` | Shows indicator top-right |
| `middle_left_indicator` | Shows indicator middle-left |
| `middle_right_indicator` | Shows indicator middle-right |
| `bottom_left_indicator` | Shows indicator bottom-left |
| `bottom_center_indicator` | Shows indicator bottom-center |
| `bottom_right_indicator` | Shows indicator bottom-right |
| `left_icon` | Places icon on left |
| `right_icon` | Places icon on right |

## Slots

### `inner_block` Slot

Badge content (text, numbers, etc.).

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

### Border
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Badge Position
`top-left`, `top-right`, `bottom-left`, `bottom-right`

### Indicator Size
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Badge

```heex
<.badge>Default</.badge>

<.badge color="primary">Primary</.badge>

<.badge color="success" variant="default">Success</.badge>
```

### Badge with Icon

```heex
<.badge icon="hero-bell" color="primary">Notifications</.badge>

<.badge icon="hero-envelope" right_icon color="info">Messages</.badge>

<.badge icon="hero-arrow-down-tray" color="warning">Download</.badge>
```

### Badge with Indicator

```heex
<.badge indicator color="success">Active</.badge>

<.badge right_indicator color="danger">Alert</.badge>

<.badge top_right_indicator pinging color="primary">New</.badge>
```

### Dismissible Badge

```heex
<.badge id="notification-1" dismiss color="info">
  New message
</.badge>

<.badge id="alert-1" left_dismiss color="danger">
  Error
</.badge>
```

### Circular Badge

```heex
<.badge circle color="danger">5</.badge>

<.badge circle color="primary" size="medium">12</.badge>

<.badge circle indicator pinging color="success" />
```

### Badge Variants

```heex
<.badge variant="default" color="primary">Default</.badge>
<.badge variant="outline" color="primary">Outline</.badge>
<.badge variant="transparent" color="primary">Transparent</.badge>
<.badge variant="shadow" color="primary">Shadow</.badge>
<.badge variant="bordered" color="primary">Bordered</.badge>
<.badge variant="gradient" color="primary">Gradient</.badge>
```

### Floating Badge (Positioned)

```heex
<div class="relative inline-block">
  <.icon name="hero-bell" class="size-6" />
  <.badge badge_position="top-right" circle color="danger" size="extra_small">
    3
  </.badge>
</div>
```

### Badge with Custom Styling

```heex
<.badge
  color="primary"
  rounded="full"
  font_weight="font-semibold"
  class="uppercase tracking-wide"
>
  PRO
</.badge>
```

### All Indicator Positions

```heex
<.badge top_left_indicator>Top Left</.badge>
<.badge top_center_indicator>Top Center</.badge>
<.badge top_right_indicator>Top Right</.badge>
<.badge middle_left_indicator>Middle Left</.badge>
<.badge middle_right_indicator>Middle Right</.badge>
<.badge bottom_left_indicator>Bottom Left</.badge>
<.badge bottom_center_indicator>Bottom Center</.badge>
<.badge bottom_right_indicator>Bottom Right</.badge>
```

### Pinging Indicator

```heex
<.badge indicator pinging color="success">Online</.badge>

<.badge bottom_center_indicator pinging color="danger">Live</.badge>
```

## Handling Dismiss Events

When using dismissible badges, handle the event in your LiveView:

```elixir
def handle_event("dismiss", %{"id" => id, "kind" => "badge"}, socket) do
  # Handle badge dismissal
  {:noreply, socket}
end
```

## Programmatic Show/Hide

```heex
<button phx-click={show_badge("#my-badge")}>Show Badge</button>
<button phx-click={hide_badge("#my-badge")}>Hide Badge</button>

<.badge id="my-badge" color="success" hidden>
  Revealed!
</.badge>
```

## Common Patterns

### Notification Counter

```heex
<div class="relative">
  <button class="p-2">
    <.icon name="hero-bell" class="size-6" />
  </button>
  <.badge
    badge_position="top-right"
    circle
    color="danger"
    size="extra_small"
  >
    {@ unread_count}
  </.badge>
</div>
```

### Status Indicator

```heex
<.badge
  indicator
  pinging={@user.online}
  color={if @user.online, do: "success", else: "natural"}
>
  {if @user.online, do: "Online", else: "Offline"}
</.badge>
```

### Tag List

```heex
<div class="flex gap-2 flex-wrap">
    <.badge
        :for={tag <- @tags}
        id={"tag-#{tag.id}"}
        dismiss
        color="primary"
        variant="bordered"
        params={%{kind: "tag", tag_id: tag.id}}
    >
        {tag.name}
    </.badge>
</div>
```
