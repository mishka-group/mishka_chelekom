# Keyboard Component

Keyboard key display component for showing shortcuts, key combinations, and hotkeys.

**Documentation**: https://mishka.tools/chelekom/docs/keyboard

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component keyboard

# Generate with specific options
mix mishka.ui.gen.component keyboard --variant default,outline --color natural,dark

# Generate with custom module name
mix mishka.ui.gen.component keyboard --module MyAppWeb.Components.CustomKeyboard
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
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Key size |
| `rounded` | `:string` | `"small"` | Border radius |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Key label or content.

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Key

```heex
<.keyboard>Ctrl</.keyboard>
```

### Key Combination

```heex
<span class="flex items-center gap-1">
  <.keyboard>Ctrl</.keyboard>
  <span>+</span>
  <.keyboard>C</.keyboard>
</span>
```

### Different Variants

```heex
<.keyboard variant="default">Enter</.keyboard>
<.keyboard variant="outline">Enter</.keyboard>
<.keyboard variant="shadow">Enter</.keyboard>
<.keyboard variant="bordered">Enter</.keyboard>
```

### Different Colors

```heex
<.keyboard color="natural">Esc</.keyboard>
<.keyboard color="primary">Tab</.keyboard>
<.keyboard color="dark">Space</.keyboard>
```

### Different Sizes

```heex
<.keyboard size="extra_small">A</.keyboard>
<.keyboard size="small">A</.keyboard>
<.keyboard size="medium">A</.keyboard>
<.keyboard size="large">A</.keyboard>
<.keyboard size="extra_large">A</.keyboard>
```

### Different Rounded

```heex
<.keyboard rounded="none">Key</.keyboard>
<.keyboard rounded="small">Key</.keyboard>
<.keyboard rounded="medium">Key</.keyboard>
<.keyboard rounded="large">Key</.keyboard>
<.keyboard rounded="full">Key</.keyboard>
```

### Arrow Keys

```heex
<div class="flex flex-col items-center gap-1">
  <.keyboard>&#8593;</.keyboard>
  <div class="flex gap-1">
    <.keyboard>&#8592;</.keyboard>
    <.keyboard>&#8595;</.keyboard>
    <.keyboard>&#8594;</.keyboard>
  </div>
</div>
```

### Special Keys

```heex
<.keyboard>&#8984; Cmd</.keyboard>
<.keyboard>&#8997; Alt</.keyboard>
<.keyboard>&#8679; Shift</.keyboard>
<.keyboard>&#8963; Ctrl</.keyboard>
```

## Common Patterns

### Shortcut Documentation

```heex
<div class="space-y-2">
  <div class="flex justify-between items-center">
    <span>Copy</span>
    <span class="flex items-center gap-1">
      <.keyboard size="small">&#8984;</.keyboard>
      <.keyboard size="small">C</.keyboard>
    </span>
  </div>
  <div class="flex justify-between items-center">
    <span>Paste</span>
    <span class="flex items-center gap-1">
      <.keyboard size="small">&#8984;</.keyboard>
      <.keyboard size="small">V</.keyboard>
    </span>
  </div>
  <div class="flex justify-between items-center">
    <span>Undo</span>
    <span class="flex items-center gap-1">
      <.keyboard size="small">&#8984;</.keyboard>
      <.keyboard size="small">Z</.keyboard>
    </span>
  </div>
</div>
```

### Inline Shortcut Hint

```heex
<p>
  Press
  <.keyboard size="small" variant="outline">Ctrl</.keyboard>
  +
  <.keyboard size="small" variant="outline">K</.keyboard>
  to open the command palette.
</p>
```

### Search Input with Shortcut

```heex
<div class="relative">
  <.text_field name="search" placeholder="Search..." />
  <div class="absolute right-2 top-1/2 -translate-y-1/2">
    <.keyboard size="extra_small" variant="outline" color="natural">/</.keyboard>
  </div>
</div>
```

### Help Modal Shortcuts

```heex
<div class="grid grid-cols-2 gap-4">
  <div>
    <h4 class="font-semibold mb-2">Navigation</h4>
    <ul class="space-y-1">
      <li class="flex justify-between">
        <span>Go to Home</span>
        <.keyboard size="small">G H</.keyboard>
      </li>
      <li class="flex justify-between">
        <span>Go to Search</span>
        <.keyboard size="small">/</span>
      </li>
    </ul>
  </div>
  <div>
    <h4 class="font-semibold mb-2">Actions</h4>
    <ul class="space-y-1">
      <li class="flex justify-between">
        <span>New Item</span>
        <.keyboard size="small">N</.keyboard>
      </li>
      <li class="flex justify-between">
        <span>Edit</span>
        <.keyboard size="small">E</.keyboard>
      </li>
    </ul>
  </div>
</div>
```

### Tooltip with Shortcut

```heex
<.button>
  Save
  <span class="ml-2 opacity-60">
    <.keyboard size="extra_small" variant="transparent">&#8984;S</.keyboard>
  </span>
</.button>
```
