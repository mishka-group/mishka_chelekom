# Dropdown Component

Dropdown menu component with trigger-based display, hover/click activation, and flexible positioning.

**Documentation**: https://mishka.tools/chelekom/docs/dropdown

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component dropdown
mix mishka.ui.gen.component dropdown --variant default,shadow --color primary,natural
mix mishka.ui.gen.component dropdown --type dropdown,dropdown_trigger,dropdown_content
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

### `dropdown/1`

The style attributes of `dropdown/1` style its content; the `content` slot takes only `class`.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `clickable` | `:boolean` | `true` | Activate on click; `clickable={false}` activates on hover |
| `position` | `:string` | `"bottom"` | `top`, `bottom`, `left`, `right` |
| `relative` | `:string` | `nil` | Position context class |
| `width` | `:string` | `"w-fit"` | Width class of the dropdown and its content (`w-fit`, `w-full`, ...) |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `""` | Content size |
| `space` | `:string` | `""` | Space between items |
| `rounded` | `:string` | `""` | Border radius |
| `padding` | `:string` | `"none"` | Content padding |
| `border` | `:string` | `"extra_small"` | Border width |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `smart_position` | `:boolean` | `false` | Move the content when it does not fit |
| `nomobile` | `:boolean` | `false` | Disable the dropdown on mobile |
| `class` | `:any` | `nil` | Custom CSS class |

### `dropdown_content/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `""` | Content size |
| `space` | `:string` | `""` | Space between items |
| `rounded` | `:string` | `""` | Border radius |
| `padding` | `:string` | `"none"` | Content padding |
| `width` | `:string` | `"extra_large"` | `extra_small` to `quadruple_large`, `full`, custom |
| `border` | `:string` | `"extra_small"` | Border width |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `class` | `:any` | `nil` | Custom CSS class |

### `dropdown_trigger/1`

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

| Slot | Attributes | Description |
|------|------------|-------------|
| `trigger` | `class` | The element that activates the dropdown |
| `content` | `class` | The dropdown content |

## Available Options

| Group | Values |
|-------|--------|
| Variants | `base`, `default`, `outline`, `bordered`, `shadow`, `gradient` |
| Colors | `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Padding / Rounded | `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| Space | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Position | `top`, `bottom`, `left`, `right` |

## Usage Examples

### Basic Dropdown (Hover)

```heex
<.dropdown id="hover-dropdown" relative="relative" clickable={false} space="small" rounded="large" padding="small">
  <:trigger>
    <.button color="primary">
      Hover Me
      <.icon name="hero-chevron-down" class="size-4" />
    </.button>
  </:trigger>
  <:content>
    <.list size="small">
      <:item padding="extra_small">Option 1</:item>
      <:item padding="extra_small">Option 2</:item>
      <:item padding="extra_small">Option 3</:item>
    </.list>
  </:content>
</.dropdown>
```

### Click Activated (`clickable`) + Positions

```heex
<.dropdown id="click-dropdown" relative="relative" clickable>
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

<%!-- position accepts: top, bottom (default), left, right --%>
<.dropdown id="top-dropdown" relative="relative" position="top">
  <:trigger><.button>Top</.button></:trigger>
  <:content>Content above</:content>
</.dropdown>
```

### With Icons

```heex
<.dropdown id="icons-dropdown" relative="relative" clickable space="small" rounded="large">
  <:trigger>
    <.button icon="hero-ellipsis-vertical" circle />
  </:trigger>
  <:content>
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
<.dropdown
  id="styled-dropdown"
  relative="relative"
  clickable
  variant="shadow"
  color="white"
  rounded="large"
  padding="medium"
>
  <:trigger>
    <.button color="primary">Options</.button>
  </:trigger>
  <:content>
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
<.dropdown
  id="user-menu"
  relative="relative"
  clickable
  variant="shadow"
  rounded="large"
  padding="none"
>
  <:trigger>
    <button class="flex items-center gap-2 cursor-pointer">
      <.avatar src={@current_user.avatar} size="small" rounded="full" />
      <span>{@current_user.name}</span>
      <.icon name="hero-chevron-down" class="size-4" />
    </button>
  </:trigger>
  <:content>
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

### Action Menu (per-row, with `phx-click`)

```heex
<.dropdown
  :for={item <- @items}
  id={"row-menu-#{item.id}"}
  relative="relative"
  clickable
  variant="shadow"
  rounded="medium"
>
  <:trigger>
    <.button icon="hero-ellipsis-horizontal" variant="transparent" size="small" />
  </:trigger>
  <:content>
    <.list size="small">
      <:item padding="extra_small">
        <button phx-click="edit" phx-value-id={item.id} class="flex items-center gap-2 w-full cursor-pointer">
          <.icon name="hero-pencil" class="size-4" /> Edit
        </button>
      </:item>
      <:item padding="extra_small">
        <button phx-click="delete" phx-value-id={item.id} class="flex items-center gap-2 w-full text-red-500 cursor-pointer">
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
  <.dropdown id="products-menu" relative="relative" variant="shadow" rounded="large" padding="medium">
    <:trigger>
      <button class="flex items-center gap-1 cursor-pointer">
        Products <.icon name="hero-chevron-down" class="size-4" />
      </button>
    </:trigger>
    <:content>
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
