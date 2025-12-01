# Popover Component

Interactive popover for additional information on hover or click.

**Documentation**: https://mishka.tools/chelekom/docs/popover

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component popover
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
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Content size |
| `padding` | `:string` | `"small"` | Content padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"small"` | Trigger spacing |
| `position` | `:string` | `"top"` | Popover position |
| `clickable` | `:boolean` | `false` | Click to activate |
| `inline` | `:boolean` | `false` | Inline display |

## Slots

### `trigger` Slot

Element that triggers the popover.

### `inner_block` Slot

Popover content.

## Available Options

### Variants
`base`, `default`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Positions
`top`, `bottom`, `left`, `right`

## Usage Examples

### Basic Popover (Hover)

```heex
<.popover>
  <:trigger>
    <.button>Hover Me</.button>
  </:trigger>
  <p>Popover content appears here.</p>
</.popover>
```

### Click Activated

```heex
<.popover clickable>
  <:trigger>
    <.button>Click Me</.button>
  </:trigger>
  <p>This popover is triggered by click.</p>
</.popover>
```

### Different Positions

```heex
<.popover position="top"><:trigger>Top</:trigger>Content</.popover>
<.popover position="bottom"><:trigger>Bottom</:trigger>Content</.popover>
<.popover position="left"><:trigger>Left</:trigger>Content</.popover>
<.popover position="right"><:trigger>Right</:trigger>Content</.popover>
```

### Different Variants

```heex
<.popover variant="default" color="white">
  <:trigger>Default</:trigger>
  Content
</.popover>

<.popover variant="shadow" color="white">
  <:trigger>Shadow</:trigger>
  Content
</.popover>
```

### Inline Popover

```heex
<p>
  Learn more about
  <.popover inline variant="shadow">
    <:trigger>
      <span class="text-primary-500 underline cursor-pointer">this feature</span>
    </:trigger>
    <p>Detailed explanation of the feature.</p>
  </.popover>
  in our docs.
</p>
```

## Common Patterns

### Info Tooltip

```heex
<div class="flex items-center gap-2">
  <label>Email</label>
  <.popover variant="shadow" color="dark" size="small">
    <:trigger>
      <.icon name="hero-question-mark-circle" class="size-4 text-gray-400 cursor-help" />
    </:trigger>
    <p class="text-white text-sm">We'll never share your email.</p>
  </.popover>
</div>
```

### User Card Popover

```heex
<.popover variant="shadow" padding="none">
  <:trigger>
    <.avatar src={@user.avatar} size="small" class="cursor-pointer" />
  </:trigger>
  <div class="p-4 min-w-48">
    <div class="flex items-center gap-3 mb-3">
      <.avatar src={@user.avatar} size="medium" />
      <div>
        <p class="font-bold">{@user.name}</p>
        <p class="text-sm text-gray-500">{@user.role}</p>
      </div>
    </div>
    <.button size="small" full_width>View Profile</.button>
  </div>
</.popover>
```
