# Avatar Component

Displays user profile images, initials, icons, or fallback placeholders in Phoenix LiveView applications. Supports individual avatars and grouped layouts.

**Documentation**: https://mishka.tools/chelekom/docs/avatar

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component avatar

# Generate with specific options
mix mishka.ui.gen.component avatar --color primary,success --size small,medium,large

# Generate specific component types only
mix mishka.ui.gen.component avatar --type avatar,avatar_group

# Generate with custom module name
mix mishka.ui.gen.component avatar --module MyAppWeb.Components.CustomAvatar
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | `indicator` |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `avatar/1` | Individual avatar with image, icon, or text |
| `avatar_group/1` | Group of avatars with overlap spacing |

## Attributes

### `avatar/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `src` | `:string` | `nil` | Image URL/path |
| `color` | `:string` | `"transparent"` | Color theme for background/border |
| `size` | `:string` | `"small"` | Avatar size |
| `shadow` | `:string` | `"none"` | Shadow style |
| `font_weight` | `:string` | `"font-normal"` | Font weight class for text |
| `rounded` | `:string` | `"medium"` | Border radius |
| `border` | `:string` | `"none"` | Border width |
| `class` | `:any` | `nil` | Custom CSS class |
| `rest` | `:global` | - | Global attributes (alt, title, etc.) |

### `avatar_group/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `space` | `:string` | `"medium"` | Overlap spacing between avatars |
| `class` | `:any` | `nil` | Custom CSS class |
| `rest` | `:global` | - | Global attributes |

## Slots

### `icon` Slot (for avatar/1)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `:string` | **Yes** | Hero icon name (e.g., `"hero-user"`) |
| `class` | `:any` | No | Custom CSS class |
| `icon_class` | `:string` | No | Icon-specific styling |
| `color` | `:string` | No | Icon color |
| `size` | `:string` | No | Icon size |

### `inner_block` Slot

Both components accept `inner_block` for custom content (text, initials, indicators).

## Available Options

### Colors
`transparent`, `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

### Border
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Shadow
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Space (avatar_group)
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Image Avatar

```heex
<.avatar src="/images/profile.jpg" size="medium" rounded="full" />

<.avatar src={@user.avatar_url} size="large" rounded="full" alt={@user.name} />
```

### Icon Avatar (Placeholder)

```heex
<.avatar size="medium" rounded="full" color="primary">
  <:icon name="hero-user" />
</.avatar>

<.avatar size="large" rounded="full" color="silver">
  <:icon name="hero-user-circle" icon_class="size-8" />
</.avatar>
```

### Text/Initials Avatar

```heex
<.avatar size="medium" rounded="full" color="primary">
  JD
</.avatar>

<.avatar size="large" rounded="full" color="success" font_weight="font-bold">
  AB
</.avatar>
```

### Avatar with Indicator (Status)

```heex
<.avatar src="/images/profile.jpg" size="medium" rounded="full">
  <.indicator size="small" color="success" bottom_right />
</.avatar>

<.avatar size="large" rounded="full" color="silver">
  <:icon name="hero-user" />
  <.indicator size="extra_small" color="danger" top_right />
</.avatar>
```

### Avatar with Border

```heex
<.avatar
  src="/images/profile.jpg"
  size="large"
  rounded="full"
  border="medium"
  color="primary"
/>
```

### Avatar with Shadow

```heex
<.avatar
  src="/images/profile.jpg"
  size="large"
  rounded="full"
  shadow="medium"
/>
```

### Avatar Group

```heex
<.avatar_group>
  <.avatar src="/images/user1.jpg" size="large" rounded="full" />
  <.avatar src="/images/user2.jpg" size="large" rounded="full" />
  <.avatar src="/images/user3.jpg" size="large" rounded="full" />
  <.avatar size="large" rounded="full" color="natural" border="medium">
    +5
  </.avatar>
</.avatar_group>
```

### Avatar Group with Custom Spacing

```heex
<.avatar_group space="small">
  <.avatar src="/images/user1.jpg" size="medium" rounded="full" border="small" color="white" />
  <.avatar src="/images/user2.jpg" size="medium" rounded="full" border="small" color="white" />
  <.avatar src="/images/user3.jpg" size="medium" rounded="full" border="small" color="white" />
</.avatar_group>
```

### Different Rounded Styles

```heex
<%# Circular avatar %>
<.avatar src="/images/profile.jpg" size="medium" rounded="full" />

<%# Rounded corners %>
<.avatar src="/images/profile.jpg" size="medium" rounded="large" />

<%# Square avatar %>
<.avatar src="/images/profile.jpg" size="medium" rounded="none" />
```

### All Sizes Comparison

```heex
<.avatar src="/images/profile.jpg" size="extra_small" rounded="full" />
<.avatar src="/images/profile.jpg" size="small" rounded="full" />
<.avatar src="/images/profile.jpg" size="medium" rounded="full" />
<.avatar src="/images/profile.jpg" size="large" rounded="full" />
<.avatar src="/images/profile.jpg" size="extra_large" rounded="full" />
```

### Colored Placeholder Avatars

```heex
<.avatar size="medium" rounded="full" color="primary"><:icon name="hero-user" /></.avatar>
<.avatar size="medium" rounded="full" color="success"><:icon name="hero-user" /></.avatar>
<.avatar size="medium" rounded="full" color="warning"><:icon name="hero-user" /></.avatar>
<.avatar size="medium" rounded="full" color="danger"><:icon name="hero-user" /></.avatar>
<.avatar size="medium" rounded="full" color="info"><:icon name="hero-user" /></.avatar>
```

## Common Patterns

### User Profile Display

```heex
<div class="flex items-center gap-3">
  <.avatar src={@user.avatar} size="medium" rounded="full">
    <.indicator size="extra_small" color="success" bottom_right />
  </.avatar>
  <div>
    <p class="font-medium">{@user.name}</p>
    <p class="text-sm text-gray-500">{@user.role}</p>
  </div>
</div>
```

### Team Members List

```heex
<.avatar_group space="small">
  <%= for member <- @team_members do %>
    <.avatar
      src={member.avatar}
      size="small"
      rounded="full"
      border="small"
      color="white"
      alt={member.name}
    />
  <% end %>
  <%= if @remaining_count > 0 do %>
    <.avatar size="small" rounded="full" color="natural" border="small">
      +{@remaining_count}
    </.avatar>
  <% end %>
</.avatar_group>
```

### Fallback Pattern

```heex
<%= if @user.avatar do %>
  <.avatar src={@user.avatar} size="medium" rounded="full" />
<% else %>
  <.avatar size="medium" rounded="full" color="primary">
    {String.first(@user.first_name)}{String.first(@user.last_name)}
  </.avatar>
<% end %>
```

## Notes

- When using `rounded="full"` with images, the component handles indicator positioning automatically
- The `indicator` component must be generated separately if you want to use status badges
- For image avatars, always provide an `alt` attribute for accessibility
- Border colors are determined by the `color` attribute
