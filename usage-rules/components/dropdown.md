# Dropdown Component

Dropdown menu component with trigger-based display, hover/click activation, and flexible positioning.

**Documentation**: https://mishka.tools/chelekom/docs/dropdown

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component dropdown

# Generate with specific options
mix mishka.ui.gen.component dropdown --variant default,shadow --color primary,natural

# Generate specific component types only
mix mishka.ui.gen.component dropdown --type dropdown,dropdown_trigger,dropdown_content

# Generate with custom module name
mix mishka.ui.gen.component dropdown --module MyAppWeb.Components.CustomDropdown
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `floating.js` |

## Component Types

| Component | Description |
|-----------|-------------|
| `dropdown/1` | Main dropdown container |
| `dropdown_trigger/1` | Trigger element wrapper |
| `dropdown_content/1` | Dropdown content wrapper |

## Attributes

### `dropdown/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `clickable` | `:boolean` | `false` | Activate on click (default: hover) |
| `position` | `:string` | `"bottom"` | Position: `top`, `bottom`, `left`, `right` |
| `relative` | `:string` | `nil` | Position context class |
| `class` | `:any` | `nil` | Custom CSS class |

### `dropdown_content/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Content size |
| `space` | `:string` | `"small"` | Space between items |
| `rounded` | `:string` | `"medium"` | Border radius |
| `padding` | `:string` | `"small"` | Content padding |
| `width` | `:string` | `nil` | Width: `full`, `fit`, custom |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `trigger` Slot

The element that activates the dropdown.

### `content` Slot

The dropdown content with attributes for styling.

## Available Options

### Variants
`base`, `default`, `outline`, `bordered`, `shadow`, `gradient`

### Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Padding / Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Position
`top`, `bottom`, `left`, `right`

## Usage Examples

### Basic Dropdown (Hover)

```heex
<.dropdown relative="relative">
  <:trigger>
    <.button color="primary">
      Hover Me
      <.icon name="hero-chevron-down" class="size-4" />
    </.button>
  </:trigger>
  <:content space="small" rounded="large" padding="small">
    <.list size="small">
      <:item padding="extra_small">Option 1</:item>
      <:item padding="extra_small">Option 2</:item>
      <:item padding="extra_small">Option 3</:item>
    </.list>
  </:content>
</.dropdown>
```

### Click Activated

```heex
<.dropdown relative="relative" clickable>
  <:trigger>
    <.button color="primary" icon="hero-chevron-down" right_icon>
      Click Me
    </.button>
  </:trigger>
  <:content>
    <.list>
      <:item>Dashboard</:item>
      <:item>Settings</:item>
      <:item>Sign Out</:item>
    </.list>
  </:content>
</.dropdown>
```

### Different Positions

```heex
<.dropdown relative="relative" position="bottom">
  <:trigger><.button>Bottom</.button></:trigger>
  <:content>Content below</:content>
</.dropdown>

<.dropdown relative="relative" position="top">
  <:trigger><.button>Top</.button></:trigger>
  <:content>Content above</:content>
</.dropdown>

<.dropdown relative="relative" position="left">
  <:trigger><.button>Left</.button></:trigger>
  <:content>Content left</:content>
</.dropdown>

<.dropdown relative="relative" position="right">
  <:trigger><.button>Right</.button></:trigger>
  <:content>Content right</:content>
</.dropdown>
```

### With Icons

```heex
<.dropdown relative="relative" clickable>
  <:trigger>
    <.button icon="hero-ellipsis-vertical" circle />
  </:trigger>
  <:content space="small" rounded="large">
    <.list size="small">
      <:item padding="extra_small" icon="hero-pencil">Edit</:item>
      <:item padding="extra_small" icon="hero-document-duplicate">Duplicate</:item>
      <:item padding="extra_small" icon="hero-trash" class="text-red-500">Delete</:item>
    </.list>
  </:content>
</.dropdown>
```

### Styled Content

```heex
<.dropdown relative="relative" clickable>
  <:trigger>
    <.button color="primary">Options</.button>
  </:trigger>
  <:content variant="shadow" color="white" rounded="large" padding="medium" width="fit">
    <div class="min-w-48">
      <p class="font-semibold mb-2">Actions</p>
      <.list size="small">
        <:item padding="small">View Details</:item>
        <:item padding="small">Edit</:item>
        <:item padding="small">Delete</:item>
      </.list>
    </div>
  </:content>
</.dropdown>
```

## Common Patterns

### User Menu

```heex
<.dropdown relative="relative" clickable>
  <:trigger>
    <button class="flex items-center gap-2">
      <.avatar src={@current_user.avatar} size="small" rounded="full" />
      <span>{@current_user.name}</span>
      <.icon name="hero-chevron-down" class="size-4" />
    </button>
  </:trigger>
  <:content variant="shadow" rounded="large" padding="none" width="fit">
    <div class="min-w-48">
      <div class="p-3 border-b">
        <p class="font-semibold">{@current_user.name}</p>
        <p class="text-sm text-gray-500">{@current_user.email}</p>
      </div>
      <.list size="small">
        <:item padding="small" icon="hero-user">
          <.link navigate={~p"/profile"}>Profile</.link>
        </:item>
        <:item padding="small" icon="hero-cog-6-tooth">
          <.link navigate={~p"/settings"}>Settings</.link>
        </:item>
      </.list>
      <div class="border-t p-2">
        <.button variant="transparent" full_width icon="hero-arrow-right-on-rectangle">
          Sign Out
        </.button>
      </div>
    </div>
  </:content>
</.dropdown>
```

### Action Menu

```heex
<.dropdown :for={item <- @items} relative="relative" clickable>
  <:trigger>
    <.button icon="hero-ellipsis-horizontal" variant="transparent" size="small" />
  </:trigger>
  <:content variant="shadow" rounded="medium">
    <.list size="small">
      <:item padding="extra_small">
        <button phx-click="edit" phx-value-id={item.id} class="flex items-center gap-2 w-full">
          <.icon name="hero-pencil" class="size-4" /> Edit
        </button>
      </:item>
      <:item padding="extra_small">
        <button phx-click="duplicate" phx-value-id={item.id} class="flex items-center gap-2 w-full">
          <.icon name="hero-document-duplicate" class="size-4" /> Duplicate
        </button>
      </:item>
      <:item padding="extra_small">
        <button phx-click="delete" phx-value-id={item.id} class="flex items-center gap-2 w-full text-red-500">
          <.icon name="hero-trash" class="size-4" /> Delete
        </button>
      </:item>
    </.list>
  </:content>
</.dropdown>
```

### Navigation Dropdown

```heex
<nav class="flex items-center gap-4">
  <.dropdown relative="relative">
    <:trigger>
      <button class="flex items-center gap-1">
        Products <.icon name="hero-chevron-down" class="size-4" />
      </button>
    </:trigger>
    <:content variant="shadow" rounded="large" padding="medium">
      <div class="grid grid-cols-2 gap-4 min-w-80">
        <a href="/products/software" class="p-3 hover:bg-gray-50 rounded-lg">
          <.icon name="hero-computer-desktop" class="size-6 text-primary-500" />
          <p class="font-medium mt-1">Software</p>
          <p class="text-sm text-gray-500">Desktop and mobile apps</p>
        </a>
        <a href="/products/hardware" class="p-3 hover:bg-gray-50 rounded-lg">
          <.icon name="hero-cpu-chip" class="size-6 text-primary-500" />
          <p class="font-medium mt-1">Hardware</p>
          <p class="text-sm text-gray-500">Devices and accessories</p>
        </a>
      </div>
    </:content>
  </.dropdown>
</nav>
```

## JavaScript Hook

The dropdown uses the `Floating` JavaScript hook for positioning. This is automatically configured when you generate the component.

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
