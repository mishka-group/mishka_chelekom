# List Component

Versatile list components for ordered, unordered, and grouped lists with customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/list

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component list

# Generate with specific options
mix mishka.ui.gen.component list --variant default,bordered --color natural,primary

# Generate specific component types only
mix mishka.ui.gen.component list --type list,ul,ol,list_group

# Generate with custom module name
mix mishka.ui.gen.component list --module MyAppWeb.Components.CustomList
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
| `list/1` | Generic list container |
| `li/1` | List item |
| `ul/1` | Unordered list |
| `ol/1` | Ordered list |
| `list_group/1` | Grouped list container |

## Attributes

### `list/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Text size |
| `space` | `:string` | `"small"` | Space between items |
| `padding` | `:string` | `"small"` | Item padding |
| `rounded` | `:string` | `"small"` | Border radius |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `item` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `icon` | `:string` | Icon name |
| `icon_class` | `:string` | Icon styling |
| `padding` | `:string` | Item padding |
| `class` | `:any` | Item class |

### `inner_block` Slot

Content for list items.

## Available Options

### Variants
`base`, `default`, `bordered`, `outline`, `shadow`, `gradient`, `outline_separated`, `bordered_separated`, `transparent`, `base_separated`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic List

```heex
<.list>
  <:item>First item</:item>
  <:item>Second item</:item>
  <:item>Third item</:item>
</.list>
```

### With Icons

```heex
<.list>
  <:item icon="hero-home">Home</:item>
  <:item icon="hero-user">Profile</:item>
  <:item icon="hero-cog-6-tooth">Settings</:item>
</.list>
```

### Different Variants

```heex
<.list variant="default">Default</.list>
<.list variant="bordered">Bordered</.list>
<.list variant="outline">Outline</.list>
<.list variant="shadow">Shadow</.list>
<.list variant="bordered_separated">Bordered Separated</.list>
```

### Different Colors

```heex
<.list color="primary">
  <:item>Primary colored</:item>
</.list>

<.list color="success">
  <:item>Success colored</:item>
</.list>
```

### Unordered List

```heex
<.ul>
  <.li>Item one</.li>
  <.li>Item two</.li>
  <.li>Item three</.li>
</.ul>
```

### Ordered List

```heex
<.ol>
  <.li>First step</.li>
  <.li>Second step</.li>
  <.li>Third step</.li>
</.ol>
```

### List Group

```heex
<.list_group>
  <.list variant="bordered">
    <:item icon="hero-envelope" padding="medium">Messages</:item>
    <:item icon="hero-bell" padding="medium">Notifications</:item>
    <:item icon="hero-cog-6-tooth" padding="medium">Settings</:item>
  </.list>
</.list_group>
```

### Navigation List

```heex
<.list variant="transparent" size="small">
  <:item icon="hero-home" padding="small" class="hover:bg-gray-100 rounded cursor-pointer">
    Dashboard
  </:item>
  <:item icon="hero-users" padding="small" class="hover:bg-gray-100 rounded cursor-pointer">
    Users
  </:item>
  <:item icon="hero-chart-bar" padding="small" class="hover:bg-gray-100 rounded cursor-pointer">
    Analytics
  </:item>
</.list>
```

## Common Patterns

### Feature List

```heex
<.list variant="transparent" space="medium">
  <:item icon="hero-check-circle" icon_class="text-green-500 size-6">
    <div>
      <p class="font-medium">Unlimited projects</p>
      <p class="text-sm text-gray-500">Create as many as you need</p>
    </div>
  </:item>
  <:item icon="hero-check-circle" icon_class="text-green-500 size-6">
    <div>
      <p class="font-medium">Priority support</p>
      <p class="text-sm text-gray-500">Get help when you need it</p>
    </div>
  </:item>
  <:item icon="hero-check-circle" icon_class="text-green-500 size-6">
    <div>
      <p class="font-medium">Advanced analytics</p>
      <p class="text-sm text-gray-500">Track everything</p>
    </div>
  </:item>
</.list>
```

### User List

```heex
<.list variant="bordered_separated" rounded="large">
  <:item :for={user <- @users} padding="medium">
    <div class="flex items-center gap-4">
      <.avatar src={user.avatar} size="small" rounded="full" />
      <div>
        <p class="font-medium">{user.name}</p>
        <p class="text-sm text-gray-500">{user.email}</p>
      </div>
    </div>
  </:item>
</.list>
```

### Activity Feed

```heex
<.list variant="transparent" space="small">
  <:item :for={activity <- @activities} padding="small">
    <div class="flex items-start gap-3">
      <.icon name={activity.icon} class="size-5 text-gray-400 mt-0.5" />
      <div>
        <p><span class="font-medium">{activity.user}</span> {activity.action}</p>
        <p class="text-sm text-gray-500">{activity.time}</p>
      </div>
    </div>
  </:item>
</.list>
```

### Dropdown Menu Items

```heex
<.list variant="transparent" size="small" padding="none">
  <:item icon="hero-pencil" padding="extra_small" class="hover:bg-gray-100 cursor-pointer">
    Edit
  </:item>
  <:item icon="hero-document-duplicate" padding="extra_small" class="hover:bg-gray-100 cursor-pointer">
    Duplicate
  </:item>
  <:item icon="hero-trash" padding="extra_small" class="hover:bg-gray-100 cursor-pointer text-red-500">
    Delete
  </:item>
</.list>
```

### Settings List

```heex
<.list variant="bordered_separated" rounded="large">
  <:item padding="medium">
    <div class="flex items-center justify-between w-full">
      <div>
        <p class="font-medium">Email notifications</p>
        <p class="text-sm text-gray-500">Receive email updates</p>
      </div>
      <.toggle_field name="email_notifications" checked={@settings.email_notifications} />
    </div>
  </:item>
  <:item padding="medium">
    <div class="flex items-center justify-between w-full">
      <div>
        <p class="font-medium">Push notifications</p>
        <p class="text-sm text-gray-500">Get push alerts</p>
      </div>
      <.toggle_field name="push_notifications" checked={@settings.push_notifications} />
    </div>
  </:item>
</.list>
```
