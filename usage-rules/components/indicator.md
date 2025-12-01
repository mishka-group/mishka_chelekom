# Indicator Component

Visual indicator dots for notifications, status updates, and highlighting elements.

**Documentation**: https://mishka.tools/chelekom/docs/indicator

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component indicator

# Generate with specific options
mix mishka.ui.gen.component indicator --color primary,danger,success --size small,medium

# Generate with custom module name
mix mishka.ui.gen.component indicator --module MyAppWeb.Components.CustomIndicator
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"small"` | Indicator size |
| `position` | `:string` | `"top_right"` | Position relative to parent |
| `ping` | `:boolean` | `false` | Enable ping animation |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Content to display inside the indicator (like a number).

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Positions
`top_left`, `top_center`, `top_right`, `middle_left`, `middle_right`, `bottom_left`, `bottom_center`, `bottom_right`

## Usage Examples

### Basic Indicator

```heex
<div class="relative inline-block">
  <.icon name="hero-bell" class="size-6" />
  <.indicator color="danger" />
</div>
```

### Different Positions

```heex
<div class="relative inline-block">
  <.icon name="hero-bell" class="size-8" />
  <.indicator position="top_right" color="danger" />
</div>

<div class="relative inline-block">
  <.icon name="hero-bell" class="size-8" />
  <.indicator position="top_left" color="danger" />
</div>

<div class="relative inline-block">
  <.icon name="hero-bell" class="size-8" />
  <.indicator position="bottom_right" color="danger" />
</div>

<div class="relative inline-block">
  <.icon name="hero-bell" class="size-8" />
  <.indicator position="bottom_left" color="danger" />
</div>
```

### Different Colors

```heex
<.indicator color="primary" />
<.indicator color="success" />
<.indicator color="warning" />
<.indicator color="danger" />
<.indicator color="info" />
```

### Different Sizes

```heex
<.indicator size="extra_small" color="danger" />
<.indicator size="small" color="danger" />
<.indicator size="medium" color="danger" />
<.indicator size="large" color="danger" />
<.indicator size="extra_large" color="danger" />
```

### With Ping Animation

```heex
<div class="relative inline-block">
  <.icon name="hero-bell" class="size-6" />
  <.indicator color="danger" ping />
</div>
```

### With Content (Badge Number)

```heex
<div class="relative inline-block">
  <.icon name="hero-inbox" class="size-6" />
  <.indicator color="danger" size="medium">5</.indicator>
</div>

<div class="relative inline-block">
  <.icon name="hero-shopping-cart" class="size-6" />
  <.indicator color="primary" size="medium">99+</.indicator>
</div>
```

### On Avatar

```heex
<div class="relative inline-block">
  <.avatar src="/images/user.jpg" size="medium" rounded="full" />
  <.indicator color="success" position="bottom_right" />
</div>
```

### Status Indicator

```heex
<div class="relative inline-block">
  <.avatar src={@user.avatar} rounded="full" />
  <.indicator
    color={if @user.online, do: "success", else: "natural"}
    position="bottom_right"
  />
</div>
```

## Common Patterns

### Notification Bell

```heex
<button class="relative p-2 hover:bg-gray-100 rounded-lg">
  <.icon name="hero-bell" class="size-6" />
  <.indicator :if={@unread_count > 0} color="danger" ping />
</button>
```

### Inbox with Count

```heex
<a href="/inbox" class="relative inline-flex items-center gap-2">
  <.icon name="hero-inbox" class="size-6" />
  <span>Messages</span>
  <.indicator :if={@message_count > 0} color="primary" size="medium" position="top_right">
    {min(@message_count, 99)}
  </.indicator>
</a>
```

### Online Status

```heex
<div class="flex items-center gap-3">
  <div class="relative">
    <.avatar src={@user.avatar} size="medium" rounded="full" />
    <.indicator
      color={status_color(@user.status)}
      position="bottom_right"
      size="small"
    />
  </div>
  <div>
    <p class="font-medium">{@user.name}</p>
    <p class="text-sm text-gray-500">{format_status(@user.status)}</p>
  </div>
</div>
```

```elixir
defp status_color(:online), do: "success"
defp status_color(:away), do: "warning"
defp status_color(:busy), do: "danger"
defp status_color(_), do: "natural"
```

### Cart Icon

```heex
<.button_link navigate={~p"/cart"} variant="transparent" class="relative">
  <.icon name="hero-shopping-cart" class="size-6" />
  <.indicator :if={@cart_count > 0} color="primary" size="small">
    {@cart_count}
  </.indicator>
</.button_link>
```

### Task Status

```heex
<div :for={task <- @tasks} class="flex items-center gap-3 p-3 border rounded">
  <.indicator
    color={task_status_color(task.status)}
    size="small"
  />
  <span class="flex-1">{task.title}</span>
  <span class="text-sm text-gray-500">{task.due_date}</span>
</div>
```

### Connection Status

```heex
<div class="flex items-center gap-2">
  <.indicator
    color={if @connected, do: "success", else: "danger"}
    size="extra_small"
  />
  <span class="text-sm">
    {if @connected, do: "Connected", else: "Disconnected"}
  </span>
</div>
```
