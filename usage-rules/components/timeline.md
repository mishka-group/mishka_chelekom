# Timeline Component

Chronological event display in horizontal or vertical layouts.

**Documentation**: https://mishka.tools/chelekom/docs/timeline

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component timeline
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `timeline/1` | Timeline container |
| `timeline_section/1` | Individual timeline event |

## Attributes

### `timeline/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `:string` | `"base"` | Color theme |
| `horizontal` | `:boolean` | `false` | Horizontal layout |
| `gapped_sections` | `:boolean` | `false` | Add gap between sections |
| `hide_last_line` | `:boolean` | `false` | Hide last connector line |

### `timeline_section/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `:string` | `nil` | Section color |
| `size` | `:string` | `"medium"` | Bullet size |
| `icon` | `:string` | `nil` | Bullet icon |
| `image` | `:string` | `nil` | Bullet image |

## Available Options

### Colors
`base`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `natural`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`

## Usage Examples

### Basic Timeline

```heex
<.timeline>
  <.timeline_section>
    <p class="font-bold">Event 1</p>
    <p class="text-sm text-gray-600">Description of event 1</p>
  </.timeline_section>
  <.timeline_section>
    <p class="font-bold">Event 2</p>
    <p class="text-sm text-gray-600">Description of event 2</p>
  </.timeline_section>
  <.timeline_section>
    <p class="font-bold">Event 3</p>
    <p class="text-sm text-gray-600">Description of event 3</p>
  </.timeline_section>
</.timeline>
```

### With Icons

```heex
<.timeline color="primary">
  <.timeline_section icon="hero-check">
    <p class="font-bold">Order Placed</p>
    <p class="text-sm">March 1, 2024</p>
  </.timeline_section>
  <.timeline_section icon="hero-truck">
    <p class="font-bold">Shipped</p>
    <p class="text-sm">March 3, 2024</p>
  </.timeline_section>
  <.timeline_section icon="hero-home">
    <p class="font-bold">Delivered</p>
    <p class="text-sm">March 5, 2024</p>
  </.timeline_section>
</.timeline>
```

### With Images

```heex
<.timeline>
  <.timeline_section image="/images/user1.jpg" size="large">
    <p class="font-bold">John commented</p>
    <p class="text-sm text-gray-600">Great work on this project!</p>
  </.timeline_section>
  <.timeline_section image="/images/user2.jpg" size="large">
    <p class="font-bold">Jane replied</p>
    <p class="text-sm text-gray-600">Thanks! It was a team effort.</p>
  </.timeline_section>
</.timeline>
```

### Horizontal Timeline

```heex
<.timeline horizontal>
  <.timeline_section>Step 1</.timeline_section>
  <.timeline_section>Step 2</.timeline_section>
  <.timeline_section>Step 3</.timeline_section>
  <.timeline_section>Step 4</.timeline_section>
</.timeline>
```

### Different Colors

```heex
<.timeline>
  <.timeline_section color="success" icon="hero-check">Completed</.timeline_section>
  <.timeline_section color="warning" icon="hero-clock">In Progress</.timeline_section>
  <.timeline_section color="natural" icon="hero-ellipsis-horizontal">Pending</.timeline_section>
</.timeline>
```

### With Gap

```heex
<.timeline gapped_sections>
  <.timeline_section>
    <.card padding="medium">
      <p class="font-bold">Event with card</p>
      <p>Content inside a card component</p>
    </.card>
  </.timeline_section>
  <.timeline_section>
    <.card padding="medium">
      <p class="font-bold">Another event</p>
      <p>More card content</p>
    </.card>
  </.timeline_section>
</.timeline>
```

### Hide Last Line

```heex
<.timeline hide_last_line>
  <.timeline_section>First event</.timeline_section>
  <.timeline_section>Second event</.timeline_section>
  <.timeline_section>Last event (no line below)</.timeline_section>
</.timeline>
```

## Common Patterns

### Order Tracking

```heex
<.timeline color="primary" hide_last_line>
  <.timeline_section icon="hero-check" color="success">
    <p class="font-bold">Order Confirmed</p>
    <p class="text-sm text-gray-600">March 1, 2024 at 10:30 AM</p>
  </.timeline_section>
  <.timeline_section icon="hero-cube" color="success">
    <p class="font-bold">Packed</p>
    <p class="text-sm text-gray-600">March 2, 2024 at 2:15 PM</p>
  </.timeline_section>
  <.timeline_section icon="hero-truck" color="primary">
    <p class="font-bold">In Transit</p>
    <p class="text-sm text-gray-600">Expected: March 5, 2024</p>
  </.timeline_section>
  <.timeline_section icon="hero-home" color="natural">
    <p class="font-bold text-gray-400">Delivered</p>
    <p class="text-sm text-gray-400">Pending</p>
  </.timeline_section>
</.timeline>
```

### Activity Feed

```heex
<.timeline>
  <.timeline_section :for={activity <- @activities} image={activity.user.avatar} size="medium">
    <div class="flex items-center gap-2">
      <span class="font-medium">{activity.user.name}</span>
      <span class="text-gray-600">{activity.action}</span>
    </div>
    <p class="text-sm text-gray-500">{format_time(activity.timestamp)}</p>
  </.timeline_section>
</.timeline>
```

### Version History

```heex
<.timeline color="info">
  <.timeline_section :for={version <- @versions} icon="hero-code-bracket">
    <div class="flex items-center justify-between">
      <span class="font-mono font-bold">v{version.number}</span>
      <span class="text-sm text-gray-500">{version.date}</span>
    </div>
    <p class="text-sm mt-1">{version.description}</p>
  </.timeline_section>
</.timeline>
```
