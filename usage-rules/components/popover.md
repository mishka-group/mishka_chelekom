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

The style attributes of `popover/1` style its content; the `trigger` and `content` slots take only `class`.

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `shadow`, `bordered`, `gradient` |
| `color` | `:string` | `"natural"` | Color theme — `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"small"` | Content size |
| `padding` | `:string` | `"small"` | Content padding — `none`, `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"medium"` | Border radius — `none`, `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `border` | `:string` | `"extra_small"` | Border width |
| `space` | `:string` | `""` | Space between items in the content |
| `width` | `:string` | `"fit"` | Content minimum width — `extra_small` to `quadruple_large`, or a class |
| `text_position` | `:string` | `"start"` | Text alignment of the content |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `position` | `:string` | `"top"` | Popover position — `top`, `bottom`, `left`, `right` |
| `clickable` | `:boolean` | `false` | Click (instead of hover) to activate |
| `inline` | `:boolean` | `false` | Inline display |
| `show_arrow` | `:boolean` | `true` | Show the arrow (not drawn for `base` and `bordered`) |
| `show_delay` | `:integer` | `0` | Delay before showing (ms) |
| `hide_delay` | `:integer` | `200` | Delay before hiding (ms) |
| `class` | `:any` | `nil` | Custom CSS class |
| `trigger_class` | `:string` | `""` | CSS class of the trigger wrapper |
| `content_class` | `:string` | `""` | CSS class of the content wrapper |
| `arrow_class` | `:string` | `""` | CSS class of the arrow |

## Slots

| Slot | Attributes | Description |
|------|------------|-------------|
| `trigger` | `class` | Element that triggers the popover |
| `content` | `class` | Popover content |
| `inner_block` | | Trigger element when there is no `trigger` slot |

## Usage Examples

### Basic (hover) and click-activated

```heex
<.popover id="hover-popover">
  <:trigger>
    <.button>Hover Me</.button>
  </:trigger>
  <:content>
    <p>Popover content appears here.</p>
  </:content>
</.popover>

<.popover id="click-popover" clickable>
  <:trigger>
    <.button>Click Me</.button>
  </:trigger>
  <:content>
    <p>This popover is triggered by click.</p>
  </:content>
</.popover>
```

### Positions

```heex
<.popover id="popover-top" position="top"><:trigger>Top</:trigger><:content>Content</:content></.popover>
<.popover id="popover-bottom" position="bottom"><:trigger>Bottom</:trigger><:content>Content</:content></.popover>
<.popover id="popover-left" position="left"><:trigger>Left</:trigger><:content>Content</:content></.popover>
<.popover id="popover-right" position="right"><:trigger>Right</:trigger><:content>Content</:content></.popover>
```

### Variants

```heex
<.popover id="popover-default" variant="default" color="white">
  <:trigger>Default</:trigger>
  <:content>Content</:content>
</.popover>

<.popover id="popover-shadow" variant="shadow" color="white">
  <:trigger>Shadow</:trigger>
  <:content>Content</:content>
</.popover>
```

### Inline popover

```heex
<p>
  Learn more about
  <.popover id="feature-popover" inline variant="shadow">
    <:trigger>
      <span class="text-primary-500 underline cursor-pointer">this feature</span>
    </:trigger>
    <:content>
      <p>Detailed explanation of the feature.</p>
    </:content>
  </.popover>
  in our docs.
</p>
```

## Common Patterns

### Info tooltip (icon trigger)

```heex
<div class="flex items-center gap-2">
  <label>Email</label>
  <.popover id="email-help" variant="shadow" color="dark" size="small">
    <:trigger>
      <.icon name="hero-question-mark-circle" class="size-4 text-gray-400 cursor-help" />
    </:trigger>
    <:content>
      <p class="text-white text-sm">We'll never share your email.</p>
    </:content>
  </.popover>
</div>
```

### User card popover (`padding="none"` for custom layout)

```heex
<.popover id="user-card" variant="shadow" padding="none">
  <:trigger>
    <.avatar src={@user.avatar} size="small" class="cursor-pointer" />
  </:trigger>
  <:content>
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
  </:content>
</.popover>
```
