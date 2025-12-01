# Floating Hook

JavaScript hook for positioning floating elements like dropdowns, popovers, and tooltips.

## Hook Name

```javascript
Floating
```

## Used By Components

- `dropdown`
- `popover`
- `tooltip`
- `progress` (tooltip display)

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-position` | `string` | `"bottom"` | Position relative to trigger |
| `data-floating-type` | `string` | `"dropdown"` | Type: `dropdown`, `popover`, `tooltip` |
| `data-clickable` | `string` | `"true"` | Open on click (vs hover) |
| `data-smart-position` | `string` | `"true"` | Auto-adjust to stay in viewport |

## Features

- **Smart Positioning**: Adjusts to stay within viewport
- **Multiple Positions**: Top, bottom, left, right
- **Click/Hover Triggers**: Configurable activation
- **Click Outside**: Closes on outside click
- **Escape Key**: Closes on Escape press
- **Focus Management**: Handles focus for accessibility
- **Scroll Handling**: Repositions on scroll

## Positions

| Position | Description |
|----------|-------------|
| `top` | Above the trigger |
| `bottom` | Below the trigger |
| `left` | To the left of trigger |
| `right` | To the right of trigger |

## Element Structure

The hook expects a trigger and content element:

```html
<div id="dropdown-1" phx-hook="Floating" data-position="bottom" data-floating-type="dropdown">
  <div data-floating-trigger="true" class="dropdown-trigger">
    <button>Open Menu</button>
  </div>

  <div class="dropdown-content">
    <a href="#">Option 1</a>
    <a href="#">Option 2</a>
  </div>
</div>
```

## Usage Examples

### Dropdown

```heex
<.dropdown id="user-menu">
  <:trigger>
    <.button>Menu</.button>
  </:trigger>
  <:content>
    <.dropdown_item>Profile</.dropdown_item>
    <.dropdown_item>Settings</.dropdown_item>
    <.dropdown_divider />
    <.dropdown_item>Logout</.dropdown_item>
  </:content>
</.dropdown>
```

### Dropdown with Position

```heex
<.dropdown id="actions-menu" position="right">
  <:trigger>
    <.icon name="hero-ellipsis-vertical" class="size-5" />
  </:trigger>
  <:content>
    <.dropdown_item>Edit</.dropdown_item>
    <.dropdown_item>Delete</.dropdown_item>
  </:content>
</.dropdown>
```

### Popover

```heex
<.popover id="help-popover">
  <:trigger>
    <.icon name="hero-question-mark-circle" class="size-5 cursor-help" />
  </:trigger>
  <:content>
    <h4 class="font-medium">Need Help?</h4>
    <p class="text-sm text-gray-600">
      Click here to learn more about this feature.
    </p>
  </:content>
</.popover>
```

### Tooltip

```heex
<.tooltip>
  <:trigger>
    <.button>Hover me</.button>
  </:trigger>
  <:content>Helpful tooltip text</:content>
</.tooltip>
```

### Tooltip with Positions

```heex
<.tooltip position="top">
  <:trigger><span>Top</span></:trigger>
  <:content>Top tooltip</:content>
</.tooltip>

<.tooltip position="bottom">
  <:trigger><span>Bottom</span></:trigger>
  <:content>Bottom tooltip</:content>
</.tooltip>

<.tooltip position="left">
  <:trigger><span>Left</span></:trigger>
  <:content>Left tooltip</:content>
</.tooltip>

<.tooltip position="right">
  <:trigger><span>Right</span></:trigger>
  <:content>Right tooltip</:content>
</.tooltip>
```

### Clickable Popover

```heex
<.popover id="info-popover" clickable={true}>
  <:trigger>
    <.button>Click for Info</.button>
  </:trigger>
  <:content>
    <p>This popover opens on click.</p>
    <.button size="small">Action</.button>
  </:content>
</.popover>
```

### With Smart Positioning Disabled

```heex
<.dropdown id="fixed-dropdown" smart_position={false} position="bottom">
  <:trigger>
    <.button>Fixed Position</.button>
  </:trigger>
  <:content>
    <p>Always shows below, even if clipped.</p>
  </:content>
</.dropdown>
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.dropdown-trigger` | Trigger element container |
| `.dropdown-content` | Floating content container |
| `.show-dropdown` | Applied when visible |
| `.popover-trigger` | Popover trigger |
| `.popover-content` | Popover content |
| `.show-popover` | Popover visible state |

## Behavior by Type

### Dropdown
- Opens on click
- Closes on outside click
- Closes on Escape
- Closes on item selection

### Popover
- Opens on click (default)
- Closes on outside click
- Closes on Escape
- Stays open for interaction

### Tooltip
- Opens on hover
- Opens on focus
- Closes on mouse leave
- No click interaction needed

## Keyboard Controls

| Key | Action |
|-----|--------|
| `Escape` | Close floating element |
| `Tab` | Navigate focusable items |
| `Enter` | Activate trigger/item |

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Floating from "./floating"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Floating }
})
```
