# Tooltip Component

Hover-triggered informational popup with customizable positioning.

**Documentation**: https://mishka.tools/chelekom/docs/tooltip

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component tooltip
```

## Dependencies

None (no components, no JS).

## Attributes

| Attribute | Type | Default | Description | Options |
|-----------|------|---------|-------------|---------|
| `variant` | `:string` | `"base"` | Style variant | `base`, `default`, `shadow`, `bordered`, `gradient` |
| `color` | `:string` | `"base"` | Color theme | `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Text size | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `padding` | `:string` | `"small"` | Content padding | |
| `rounded` | `:string` | `"medium"` | Border radius | |
| `position` | `:string` | `"top"` | Tooltip position | `top`, `bottom`, `left`, `right` |

## Slots

- `trigger` — element that triggers the tooltip
- `content` — tooltip content

## Usage Examples

### Basic

```heex
<.tooltip>
  <:trigger>
    <.button>Hover me</.button>
  </:trigger>
  <:content>This is a tooltip</:content>
</.tooltip>
```

### Positions

```heex
<.tooltip position="top">
  <:trigger><.button>Top</.button></:trigger>
  <:content>Top tooltip</:content>
</.tooltip>

<.tooltip position="bottom">
  <:trigger><.button>Bottom</.button></:trigger>
  <:content>Bottom tooltip</:content>
</.tooltip>

<.tooltip position="left">
  <:trigger><.button>Left</.button></:trigger>
  <:content>Left tooltip</:content>
</.tooltip>

<.tooltip position="right">
  <:trigger><.button>Right</.button></:trigger>
  <:content>Right tooltip</:content>
</.tooltip>
```

### Colors and Variants

```heex
<.tooltip color="dark">
  <:trigger><span class="underline cursor-help">Dark tooltip</span></:trigger>
  <:content>Dark themed tooltip</:content>
</.tooltip>

<.tooltip color="primary">
  <:trigger><span class="underline cursor-help">Primary tooltip</span></:trigger>
  <:content>Primary themed tooltip</:content>
</.tooltip>

<.tooltip color="warning">
  <:trigger><span class="underline cursor-help">Warning tooltip</span></:trigger>
  <:content>Warning themed tooltip</:content>
</.tooltip>

<.tooltip variant="shadow" color="white">
  <:trigger><.button>Shadow</.button></:trigger>
  <:content>Shadow variant</:content>
</.tooltip>

<.tooltip variant="bordered" color="natural">
  <:trigger><.button>Bordered</.button></:trigger>
  <:content>Bordered variant</:content>
</.tooltip>
```

### With Icon Trigger

```heex
<.tooltip color="dark" position="right">
  <:trigger>
    <.icon name="hero-question-mark-circle" class="size-5 text-gray-500 cursor-help" />
  </:trigger>
  <:content>Helpful information here</:content>
</.tooltip>
```

## Common Patterns

### Form Field Help

```heex
<div class="flex items-center gap-2">
  <label>Password</label>
  <.tooltip color="dark" size="small">
    <:trigger>
      <.icon name="hero-information-circle" class="size-4 text-gray-400 cursor-help" />
    </:trigger>
    <:content>
      <div class="space-y-1">
        <p class="font-medium">Password requirements:</p>
        <ul class="text-xs list-disc pl-4">
          <li>At least 8 characters</li>
          <li>One uppercase letter</li>
          <li>One number</li>
        </ul>
      </div>
    </:content>
  </.tooltip>
</div>
```

### Icon Action Tooltips

```heex
<div class="flex gap-2">
  <.tooltip position="bottom">
    <:trigger>
      <.button variant="ghost" size="small">
        <.icon name="hero-pencil" class="size-4" />
      </.button>
    </:trigger>
    <:content>Edit</:content>
  </.tooltip>

  <.tooltip position="bottom">
    <:trigger>
      <.button variant="ghost" size="small">
        <.icon name="hero-trash" class="size-4" />
      </.button>
    </:trigger>
    <:content>Delete</:content>
  </.tooltip>
</div>
```

### Truncated Text

```heex
<.tooltip>
  <:trigger>
    <span class="truncate max-w-32 block">{@long_text}</span>
  </:trigger>
  <:content>{@long_text}</:content>
</.tooltip>
```

### Status Indicator

```heex
<.tooltip color="success">
  <:trigger>
    <span class="inline-block w-3 h-3 rounded-full bg-green-500" />
  </:trigger>
  <:content>Online</:content>
</.tooltip>
```
