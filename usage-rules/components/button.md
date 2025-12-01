# Button Component

Comprehensive button components with multiple variants, icons, indicators, and loading states for Phoenix LiveView.

**Documentation**: https://mishka.tools/chelekom/docs/button

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component button

# Generate with specific options
mix mishka.ui.gen.component button --variant default,outline,gradient --color primary,danger

# Generate specific component types only
mix mishka.ui.gen.component button --type button,button_link,button_group

# Generate with custom module name
mix mishka.ui.gen.component button --module MyAppWeb.Components.CustomButton
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
| `button/1` | Standard button element |
| `button_group/1` | Group of buttons with shared styling |
| `input_button/1` | Input element styled as button |
| `button_link/1` | Button as navigation link |
| `back/1` | Back navigation button |

## Attributes

### `button/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"large"` | Button size |
| `rounded` | `:string` | `"large"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border width |
| `type` | `:string` | `nil` | Button type: `button`, `submit`, `reset` |
| `icon` | `:string` | `nil` | Icon name |
| `icon_class` | `:string` | `nil` | Icon styling class |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `line_height` | `:string` | `"leading-5"` | Line height class |
| `display` | `:string` | `"inline-flex"` | CSS display property |
| `content_position` | `:string` | `"center"` | Content alignment |
| `full_width` | `:boolean` | `false` | Make button full width |
| `indicator_class` | `:string` | `nil` | Indicator styling |
| `indicator_size` | `:string` | `"extra_small"` | Indicator size |
| `content_class` | `:string` | `"block"` | Content wrapper class |
| `class` | `:any` | `nil` | Custom CSS class |

### `button_group/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variation` | `:string` | `"horizontal"` | Layout: `horizontal`, `vertical` |
| `color` | `:string` | `"base"` | Border color theme |
| `rounded` | `:string` | `"small"` | Border radius |
| `class` | `:any` | `nil` | Custom CSS class |

### `button_link/1` Attributes

Same as `button/1` plus:

| Attribute | Type | Description |
|-----------|------|-------------|
| `navigate` | `:string` | LiveView navigation path |
| `patch` | `:string` | LiveView patch path |
| `href` | `:string` | External URL |
| `target` | `:string` | Link target (`_blank`, etc.) |
| `download` | `:boolean` | Download attribute |

### `input_button/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `:string` | `""` | Button text |
| `type` | `:string` | `"button"` | Input type |
| Plus standard button attributes | | | |

## Global Attributes (Boolean Flags)

| Attribute | Description |
|-----------|-------------|
| `disabled` | Disable the button |
| `circle` | Create circular button |
| `pinging` | Animate indicator |
| `left_icon` | Position icon on left |
| `right_icon` | Position icon on right |
| `indicator` | Show indicator (left side) |
| `left_indicator` | Show indicator on left |
| `right_indicator` | Show indicator on right |
| `top_left_indicator` | Show indicator top-left |
| `top_center_indicator` | Show indicator top-center |
| `top_right_indicator` | Show indicator top-right |
| `middle_left_indicator` | Show indicator middle-left |
| `middle_right_indicator` | Show indicator middle-right |
| `bottom_left_indicator` | Show indicator bottom-left |
| `bottom_center_indicator` | Show indicator bottom-center |
| `bottom_right_indicator` | Show indicator bottom-right |

## Slots

### `inner_block` Slot

Button content (text, icons, etc.).

### `loading` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `class` | `:any` | Loading element class |
| `position` | `:string` | `start` or `end` |

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `subtle`, `shadow`, `inverted`, `bordered`, `default_gradient`, `outline_gradient`, `inverted_gradient`

### Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`, `transparent`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Buttons

```heex
<.button>Default Button</.button>

<.button color="primary">Primary</.button>

<.button color="danger" variant="default">Danger</.button>
```

### Button Variants

```heex
<.button variant="default" color="primary">Default</.button>
<.button variant="outline" color="primary">Outline</.button>
<.button variant="transparent" color="primary">Transparent</.button>
<.button variant="subtle" color="primary">Subtle</.button>
<.button variant="shadow" color="primary">Shadow</.button>
<.button variant="inverted" color="primary">Inverted</.button>
<.button variant="bordered" color="primary">Bordered</.button>
```

### Gradient Variants

```heex
<.button variant="default_gradient" color="primary">Default Gradient</.button>
<.button variant="outline_gradient" color="success">Outline Gradient</.button>
<.button variant="inverted_gradient" color="danger">Inverted Gradient</.button>
```

### With Icons

```heex
<.button icon="hero-plus" color="primary">Add Item</.button>

<.button icon="hero-arrow-right" right_icon color="success">
  Continue
</.button>

<.button icon="hero-trash" color="danger" />
```

### Button Sizes

```heex
<.button size="extra_small">Extra Small</.button>
<.button size="small">Small</.button>
<.button size="medium">Medium</.button>
<.button size="large">Large</.button>
<.button size="extra_large">Extra Large</.button>
```

### Circular Buttons

```heex
<.button icon="hero-plus" circle color="primary" />
<.button icon="hero-pencil" circle color="success" size="large" />
<.button icon="hero-trash" circle color="danger" size="small" />
```

### With Indicators

```heex
<.button indicator color="primary">Notifications</.button>

<.button top_right_indicator pinging color="danger">
  Messages
</.button>

<.button bottom_center_indicator indicator_size="medium" color="success">
  Status
</.button>
```

### Full Width

```heex
<.button full_width color="primary">Full Width Button</.button>
```

### Disabled State

```heex
<.button disabled color="primary">Disabled</.button>
```

### Form Submit

```heex
<.button type="submit" color="success">Save Changes</.button>
<.button type="reset" color="warning">Reset Form</.button>
```

### With Loading State

```heex
<.button color="primary" disabled={@loading}>
  <:loading :if={@loading} position="start">
    <.spinner size="small" />
  </:loading>
  {@loading && "Saving..." || "Save"}
</.button>
```

### Button Group

```heex
<.button_group>
  <.button>Left</.button>
  <.button>Center</.button>
  <.button>Right</.button>
</.button_group>

<.button_group variation="vertical" color="primary">
  <.button icon="hero-home">Home</.button>
  <.button icon="hero-user">Profile</.button>
  <.button icon="hero-cog-6-tooth">Settings</.button>
</.button_group>
```

### Button Link

```heex
<.button_link navigate={~p"/dashboard"} color="primary">
  Go to Dashboard
</.button_link>

<.button_link patch={~p"/users/#{@user.id}/edit"} color="success">
  Edit User
</.button_link>

<.button_link href="https://example.com" target="_blank" color="info">
  External Link
</.button_link>
```

### Input Button

```heex
<.input_button value="Submit" color="primary" />
<.input_button value="Reset" type="reset" color="warning" />
```

### Back Button

```heex
<.back navigate={~p"/users"}>Back to Users</.back>
```

## Common Patterns

### Action Bar

```heex
<div class="flex gap-2">
  <.button color="natural" variant="outline">Cancel</.button>
  <.button color="primary" type="submit">Save</.button>
</div>
```

### Icon Button Group

```heex
<.button_group>
  <.button icon="hero-bold" circle />
  <.button icon="hero-italic" circle />
  <.button icon="hero-underline" circle />
</.button_group>
```

### CTA Button

```heex
<.button
  color="primary"
  variant="default_gradient"
  size="extra_large"
  rounded="full"
  icon="hero-arrow-right"
  right_icon
  full_width
>
  Get Started Now
</.button>
```

### Delete Confirmation

```heex
<.button
  phx-click="delete"
  phx-value-id={@item.id}
  data-confirm="Are you sure?"
  color="danger"
  icon="hero-trash"
>
  Delete
</.button>
```

## Notes

- Gradient variants (`outline_gradient`, `inverted_gradient`) should not be used with `input_button` as it only accepts plain text
- Use `button_link` for navigation instead of wrapping buttons in links
- The `back` component is a convenience wrapper for common back navigation pattern
