# Popover Component

Interactive popover for additional information on hover or click.

**Documentation**: https://mishka.tools/chelekom/docs/popover

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component popover
```

## Dependencies

None (necessary, optional, or JS).

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `shadow`, `bordered`, `gradient` |
| `color` | `:string` | `"base"` | Color theme — `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Content size |
| `padding` | `:string` | `"small"` | Content padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"small"` | Trigger spacing |
| `position` | `:string` | `"top"` | Popover position — `top`, `bottom`, `left`, `right` |
| `clickable` | `:boolean` | `false` | Click (instead of hover) to activate |
| `inline` | `:boolean` | `false` | Inline display |

## Slots

- `trigger` — element that triggers the popover.
- `inner_block` — popover content.

## Usage Examples

### Basic (hover) and click-activated

```heex
<.popover>
  <:trigger>
    <.button>Hover Me</.button>
  </:trigger>
  <p>Popover content appears here.</p>
</.popover>

<.popover clickable>
  <:trigger>
    <.button>Click Me</.button>
  </:trigger>
  <p>This popover is triggered by click.</p>
</.popover>
```

### Positions

```heex
<.popover position="top"><:trigger>Top</:trigger>Content</.popover>
<.popover position="bottom"><:trigger>Bottom</:trigger>Content</.popover>
<.popover position="left"><:trigger>Left</:trigger>Content</.popover>
<.popover position="right"><:trigger>Right</:trigger>Content</.popover>
```

### Variants

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

### Inline popover

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

### Info tooltip (icon trigger)

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

### User card popover (`padding="none"` for custom layout)

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
