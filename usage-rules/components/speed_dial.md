# Speed Dial Component

Floating action button with expandable action menu.

**Documentation**: https://mishka.tools/chelekom/docs/speed-dial

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component speed_dial
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | `base`, `default`, `bordered`, `shadow`, `gradient` |
| `color` | `:string` | `"base"` | `base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dark`, `white`, `dawn` |
| `size` | `:string` | `"medium"` | `extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large` |
| `rounded` | `:string` | `"full"` | Border radius |
| `padding` | `:string` | `"small"` | Button padding |
| `space` | `:string` | `"small"` | Space between items |
| `icon` | `:string` | `nil` | Main button icon |
| `icon_animated` | `:boolean` | `false` | Animate icon on hover |
| `clickable` | `:boolean` | `false` | Click to toggle (vs. hover) |
| `position` | `:string` | `"bottom-end"` | Menu position |

## Slots

### `item` Slot

Action items in the speed dial menu.

| Attribute | Type | Description |
|-----------|------|-------------|
| `icon` | `:string` | Item icon |
| `color` | `:string` | Item color |
| `variant` | `:string` | Item variant |
| `href` | `:string` | Link URL |
| `patch` | `:string` | LiveView patch |
| `navigate` | `:string` | LiveView navigate |

## Usage Examples

### Basic (hover-triggered)

```heex
<.speed_dial id="actions" icon="hero-plus">
  <:item icon="hero-home" href="/" />
  <:item icon="hero-envelope" href="/contact" />
  <:item icon="hero-cog-6-tooth" href="/settings" />
</.speed_dial>
```

### Click to Toggle + Animated Icon

```heex
<.speed_dial id="fab" icon="hero-plus" clickable icon_animated>
  <:item icon="hero-photo" color="primary" />
  <:item icon="hero-document" color="success" />
  <:item icon="hero-link" color="info" />
</.speed_dial>
```

### Variant + Color

```heex
<.speed_dial id="shadow-dial" icon="hero-plus" variant="shadow" color="primary">
  <:item icon="hero-share" variant="shadow" color="primary" />
  <:item icon="hero-heart" variant="shadow" color="primary" />
</.speed_dial>
```

### With Labels

```heex
<.speed_dial id="labeled-dial" icon="hero-plus" clickable>
  <:item icon="hero-document-plus">New Document</:item>
  <:item icon="hero-folder-plus">New Folder</:item>
  <:item icon="hero-arrow-up-tray">Upload</:item>
</.speed_dial>
```

## Common Patterns

### Floating Action Button

```heex
<div class="fixed bottom-6 right-6">
  <.speed_dial id="main-fab" icon="hero-plus" color="primary" size="large" clickable icon_animated>
    <:item icon="hero-pencil" color="primary" navigate="/new-post">Write</:item>
    <:item icon="hero-photo" color="success" navigate="/upload">Upload</:item>
    <:item icon="hero-link" color="info" navigate="/share">Share</:item>
  </.speed_dial>
</div>
```

### Social Share

```heex
<.speed_dial id="share-dial" icon="hero-share" clickable>
  <:item icon="hero-envelope" href={"mailto:?body=#{@url}"} color="danger" />
  <:item icon="hero-link" phx-click="copy_link" color="info" />
</.speed_dial>
```

### Quick Actions

```heex
<.speed_dial id="quick-actions" icon="hero-bolt" variant="gradient" color="primary">
  <:item icon="hero-plus" navigate="/create" color="success" />
  <:item icon="hero-pencil" navigate="/edit" color="warning" />
  <:item icon="hero-trash" phx-click="delete" color="danger" />
</.speed_dial>
```
