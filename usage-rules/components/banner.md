# Banner Component

Fixed-position dismissible notification banners for announcements, warnings, and promotional content in Phoenix LiveView.

**Documentation**: https://mishka.tools/chelekom/docs/banner

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component banner

# Generate with specific options
mix mishka.ui.gen.component banner --variant default,bordered --color primary,warning,danger

# Generate with custom module name
mix mishka.ui.gen.component banner --module MyAppWeb.Components.CustomBanner
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
| `show_banner/1` | Shows a banner with transition effect |
| `show_banner/2` | Shows a banner with JS struct and selector |
| `hide_banner/1` | Hides a banner with transition effect |
| `hide_banner/2` | Hides a banner with JS struct and selector |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"large"` | Overall size |
| `border` | `:string` | `"extra_small"` | Border width |
| `border_position` | `:string` | `"top"` | Border position: `top`, `bottom`, `full`, `none` |
| `rounded` | `:string` | `"none"` | Border radius |
| `rounded_position` | `:string` | `"none"` | Rounded position: `top`, `bottom`, `all`, `none` |
| `space` | `:string` | `"extra_small"` | Space between content items |
| `padding` | `:string` | `"extra_small"` | Padding size |
| `vertical_position` | `:string` | `"top"` | Vertical position: `top`, `bottom` |
| `vertical_size` | `:string` | `"none"` | Vertical offset size |
| `position` | `:string` | `"full"` | Horizontal position |
| `position_size` | `:string` | `"none"` | Position offset size |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `hide_dismiss` | `:boolean` | `false` | Hide dismiss button |
| `dismiss_size` | `:string` | `"small"` | Dismiss button size |
| `class` | `:any` | `nil` | Custom CSS class |
| `dismiss_class` | `:string` | `nil` | Dismiss button styling |
| `content_wrapper_class` | `:string` | `nil` | Content wrapper styling |
| `params` | `:map` | `%{kind: "banner"}` | Additional params for events |

## Global Attributes

| Attribute | Description |
|-----------|-------------|
| `right_dismiss` | Place dismiss button on right |
| `left_dismiss` | Place dismiss button on left |

## Slots

### `inner_block` Slot

Banner content (text, links, buttons, etc.).

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Position
`top_left`, `top_right`, `bottom_left`, `bottom_right`, `center`, `full`

### Border Position
`top`, `bottom`, `full`, `none`

### Rounded Position
`top`, `bottom`, `all`, `none`

### Vertical Position
`top`, `bottom`

### Padding / Space / Vertical Size / Position Size
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Banner

```heex
<.banner id="announcement">
  Welcome to our website! Check out our new features.
</.banner>
```

### Colored Variants

```heex
<.banner id="success-banner" variant="default" color="success">
  Your changes have been saved successfully!
</.banner>

<.banner id="warning-banner" variant="bordered" color="warning">
  Please update your profile information.
</.banner>

<.banner id="error-banner" variant="default" color="danger">
  An error occurred. Please try again.
</.banner>
```

### Bottom Position

```heex
<.banner id="cookie-banner" vertical_position="bottom" color="natural">
  We use cookies to improve your experience.
  <.button size="small" color="primary">Accept</.button>
</.banner>
```

### Corner Positioned Banner

```heex
<.banner
  id="promo-banner"
  position="top_right"
  position_size="small"
  vertical_size="small"
  rounded="medium"
  rounded_position="all"
  color="primary"
>
  Limited time offer!
</.banner>
```

### Banner Without Dismiss

```heex
<.banner id="permanent-notice" hide_dismiss={true} color="info">
  Maintenance scheduled for tonight.
</.banner>
```

### Custom Dismiss Position

```heex
<.banner id="left-dismiss" left_dismiss color="warning">
  Important notice with left dismiss button.
</.banner>

<.banner id="right-dismiss" right_dismiss color="success">
  Success message with right dismiss button.
</.banner>
```

### With Border Styling

```heex
<.banner
  id="styled-banner"
  border="medium"
  border_position="bottom"
  variant="bordered"
  color="primary"
>
  Banner with bottom border.
</.banner>
```

### Gradient Banner

```heex
<.banner id="gradient-banner" variant="gradient" color="primary">
  Beautiful gradient background banner!
</.banner>
```

### Centered Banner

```heex
<.banner
  id="centered-banner"
  position="center"
  rounded="large"
  rounded_position="all"
  vertical_size="medium"
  color="success"
>
  Centered notification banner.
</.banner>
```

### Multiple Content Sections

```heex
<.banner id="multi-content" space="large" color="primary">
  <div>First line of content.</div>
  <div>Second line with more details.</div>
</.banner>
```

### With Custom Styling

```heex
<.banner
  id="custom-banner"
  class="backdrop-blur-sm"
  content_wrapper_class="max-w-4xl mx-auto"
  font_weight="font-medium"
  color="natural"
>
  Custom styled banner content.
</.banner>
```

## Handling Dismiss Events

When banner is dismissed, handle the event in your LiveView:

```elixir
def handle_event("dismiss", %{"id" => id, "kind" => "banner"}, socket) do
  # Handle banner dismissal (e.g., save preference)
  {:noreply, socket}
end
```

## Programmatic Show/Hide

```heex
<button phx-click={show_banner("#promo")}>Show Promo</button>
<button phx-click={hide_banner("#promo")}>Hide Promo</button>

<.banner id="promo" color="primary" hidden>
  Special promotion content!
</.banner>
```

## Common Patterns

### Cookie Consent Banner

```heex
<.banner
  id="cookie-consent"
  vertical_position="bottom"
  variant="bordered"
  color="natural"
  padding="medium"
>
  <div class="flex items-center justify-between w-full gap-4">
    <p>We use cookies to enhance your experience.</p>
    <div class="flex gap-2">
      <.button size="small" variant="outline">Decline</.button>
      <.button size="small" color="primary">Accept</.button>
    </div>
  </div>
</.banner>
```

### Announcement Bar

```heex
<.banner
  id="announcement"
  hide_dismiss={true}
  variant="default"
  color="primary"
  padding="small"
>
  <div class="text-center w-full">
    Free shipping on orders over $50!
    <.link href="/shop" class="underline ml-2">Shop now</.link>
  </div>
</.banner>
```

### Maintenance Notice

```heex
<.banner
  id="maintenance"
  variant="bordered"
  color="warning"
  vertical_position="top"
>
  Scheduled maintenance on Dec 15, 2024 from 2:00 AM - 4:00 AM UTC.
</.banner>
```
