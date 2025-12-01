# Icon Component

Flexible icon component supporting Hero Icons with customizable sizes, colors, and variants.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component icon

# Generate with custom module name
mix mishka.ui.gen.component icon --module MyAppWeb.Components.CustomIcon
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
| `name` | `:string` | **required** | Icon identifier (e.g., `hero-home`) |
| `class` | `:any` | `nil` | Custom CSS class |

## Icon Naming Convention

Hero Icons use the following naming pattern:
- Solid variant: `hero-{icon-name}`
- Outline variant: `hero-{icon-name}-solid`
- Mini variant: `hero-{icon-name}-mini`

## Usage Examples

### Basic Icon

```heex
<.icon name="hero-home" class="size-6" />
```

### Different Sizes

```heex
<.icon name="hero-star" class="size-4" />
<.icon name="hero-star" class="size-5" />
<.icon name="hero-star" class="size-6" />
<.icon name="hero-star" class="size-8" />
<.icon name="hero-star" class="size-10" />
```

### With Colors

```heex
<.icon name="hero-heart" class="size-6 text-red-500" />
<.icon name="hero-check-circle" class="size-6 text-green-500" />
<.icon name="hero-exclamation-circle" class="size-6 text-yellow-500" />
<.icon name="hero-x-circle" class="size-6 text-red-500" />
<.icon name="hero-information-circle" class="size-6 text-blue-500" />
```

### Solid Icons

```heex
<.icon name="hero-home-solid" class="size-6" />
<.icon name="hero-star-solid" class="size-6" />
<.icon name="hero-heart-solid" class="size-6" />
```

### Mini Icons

```heex
<.icon name="hero-home-mini" class="size-5" />
<.icon name="hero-star-mini" class="size-5" />
```

### With Animation

```heex
<.icon name="hero-arrow-path" class="size-6 animate-spin" />
<.icon name="hero-bell" class="size-6 animate-bounce" />
<.icon name="hero-cursor-arrow-rays" class="size-6 animate-pulse" />
```

### In Buttons

```heex
<.button icon="hero-plus" color="primary">Add Item</.button>
<.button icon="hero-trash" color="danger">Delete</.button>
<.button icon="hero-arrow-right" right_icon color="success">Continue</.button>
```

### Inline with Text

```heex
<p class="flex items-center gap-2">
  <.icon name="hero-map-pin" class="size-5 text-gray-500" />
  <span>New York, NY</span>
</p>
```

### In Lists

```heex
<ul class="space-y-2">
  <li class="flex items-center gap-2">
    <.icon name="hero-check" class="size-5 text-green-500" />
    <span>Feature one</span>
  </li>
  <li class="flex items-center gap-2">
    <.icon name="hero-check" class="size-5 text-green-500" />
    <span>Feature two</span>
  </li>
  <li class="flex items-center gap-2">
    <.icon name="hero-check" class="size-5 text-green-500" />
    <span>Feature three</span>
  </li>
</ul>
```

## Common Patterns

### Navigation Icons

```heex
<nav class="flex items-center gap-4">
  <a href="/" class="flex items-center gap-1">
    <.icon name="hero-home" class="size-5" />
    Home
  </a>
  <a href="/profile" class="flex items-center gap-1">
    <.icon name="hero-user" class="size-5" />
    Profile
  </a>
  <a href="/settings" class="flex items-center gap-1">
    <.icon name="hero-cog-6-tooth" class="size-5" />
    Settings
  </a>
</nav>
```

### Status Icons

```heex
<div class="flex items-center gap-2">
  <.icon :if={@status == :success} name="hero-check-circle-solid" class="size-5 text-green-500" />
  <.icon :if={@status == :warning} name="hero-exclamation-triangle-solid" class="size-5 text-yellow-500" />
  <.icon :if={@status == :error} name="hero-x-circle-solid" class="size-5 text-red-500" />
  <.icon :if={@status == :info} name="hero-information-circle-solid" class="size-5 text-blue-500" />
  <span>{@status_message}</span>
</div>
```

### Loading State

```heex
<button class="flex items-center gap-2" disabled={@loading}>
  <.icon :if={@loading} name="hero-arrow-path" class="size-5 animate-spin" />
  <.icon :if={!@loading} name="hero-paper-airplane" class="size-5" />
  {@loading && "Sending..." || "Send"}
</button>
```

### Social Icons (with custom classes)

```heex
<div class="flex gap-4">
  <a href="#" class="hover:text-blue-500 transition">
    <.icon name="hero-globe-alt" class="size-6" />
  </a>
  <a href="#" class="hover:text-blue-400 transition">
    <.icon name="hero-chat-bubble-left-right" class="size-6" />
  </a>
  <a href="#" class="hover:text-red-500 transition">
    <.icon name="hero-heart" class="size-6" />
  </a>
</div>
```

## Common Hero Icons Reference

| Category | Icons |
|----------|-------|
| **Navigation** | `hero-home`, `hero-arrow-left`, `hero-arrow-right`, `hero-chevron-down`, `hero-bars-3` |
| **Actions** | `hero-plus`, `hero-minus`, `hero-pencil`, `hero-trash`, `hero-check`, `hero-x-mark` |
| **Communication** | `hero-envelope`, `hero-phone`, `hero-chat-bubble-left`, `hero-bell` |
| **Media** | `hero-photo`, `hero-camera`, `hero-video-camera`, `hero-musical-note` |
| **Files** | `hero-document`, `hero-folder`, `hero-cloud-arrow-up`, `hero-arrow-down-tray` |
| **User** | `hero-user`, `hero-users`, `hero-user-circle`, `hero-identification` |
| **Status** | `hero-check-circle`, `hero-x-circle`, `hero-exclamation-circle`, `hero-information-circle` |
| **Misc** | `hero-cog-6-tooth`, `hero-magnifying-glass`, `hero-star`, `hero-heart`, `hero-bookmark` |
