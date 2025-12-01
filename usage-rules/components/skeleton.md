# Skeleton Component

Loading placeholder with customizable dimensions and animations.

**Documentation**: https://mishka.tools/chelekom/docs/skeleton

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component skeleton
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
| `color` | `:string` | `"base"` | Background color |
| `rounded` | `:string` | `"medium"` | Border radius |
| `height` | `:string` | `nil` | Custom height |
| `width` | `:string` | `nil` | Custom width |
| `visible` | `:boolean` | `true` | Visibility control |
| `animated` | `:boolean` | `false` | Pulse animation |

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Skeleton

```heex
<.skeleton />
```

### Animated Skeleton

```heex
<.skeleton animated />
```

### Custom Dimensions

```heex
<.skeleton height="h-4" width="w-32" />
<.skeleton height="h-8" width="w-64" />
<.skeleton height="h-48" width="w-full" />
```

### Circle Skeleton

```heex
<.skeleton width="w-12" height="h-12" rounded="full" />
```

### Different Colors

```heex
<.skeleton color="natural" animated />
<.skeleton color="primary" animated />
<.skeleton color="dark" animated />
```

### Conditional Visibility

```heex
<.skeleton :if={@loading} animated />
<div :if={!@loading}>{@content}</div>
```

## Common Patterns

### Text Placeholder

```heex
<div class="space-y-2">
  <.skeleton height="h-4" width="w-3/4" animated />
  <.skeleton height="h-4" width="w-full" animated />
  <.skeleton height="h-4" width="w-5/6" animated />
  <.skeleton height="h-4" width="w-2/3" animated />
</div>
```

### Card Skeleton

```heex
<div class="border rounded-lg p-4 space-y-4">
  <.skeleton height="h-48" width="w-full" animated />
  <.skeleton height="h-6" width="w-3/4" animated />
  <.skeleton height="h-4" width="w-full" animated />
  <.skeleton height="h-4" width="w-2/3" animated />
</div>
```

### Avatar with Text

```heex
<div class="flex items-center gap-4">
  <.skeleton width="w-12" height="h-12" rounded="full" animated />
  <div class="space-y-2 flex-1">
    <.skeleton height="h-4" width="w-32" animated />
    <.skeleton height="h-3" width="w-24" animated />
  </div>
</div>
```

### Table Row Skeleton

```heex
<div :for={_ <- 1..5} class="flex items-center gap-4 py-3 border-b">
  <.skeleton height="h-4" width="w-8" animated />
  <.skeleton height="h-4" width="w-32" animated />
  <.skeleton height="h-4" width="w-48" animated />
  <.skeleton height="h-4" width="w-24" animated />
</div>
```

### Article Skeleton

```heex
<article class="space-y-6">
  <.skeleton height="h-8" width="w-2/3" animated />
  <div class="flex items-center gap-3">
    <.skeleton width="w-10" height="h-10" rounded="full" animated />
    <div class="space-y-1">
      <.skeleton height="h-4" width="w-24" animated />
      <.skeleton height="h-3" width="w-16" animated />
    </div>
  </div>
  <.skeleton height="h-64" width="w-full" animated />
  <div class="space-y-2">
    <.skeleton height="h-4" width="w-full" animated />
    <.skeleton height="h-4" width="w-full" animated />
    <.skeleton height="h-4" width="w-3/4" animated />
  </div>
</article>
```

### Grid Skeleton

```heex
<div class="grid grid-cols-3 gap-4">
  <div :for={_ <- 1..6} class="space-y-2">
    <.skeleton height="h-32" width="w-full" animated />
    <.skeleton height="h-4" width="w-3/4" animated />
    <.skeleton height="h-3" width="w-1/2" animated />
  </div>
</div>
```
