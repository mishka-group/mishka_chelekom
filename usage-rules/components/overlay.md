# Overlay Component

Layered overlay for modals, loading screens, and background dimming.

**Documentation**: https://mishka.tools/chelekom/docs/overlay

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component overlay
```

## Dependencies

None (no other components, no JavaScript).

## Attributes

| Attribute | Type | Default | Description | Options |
|-----------|------|---------|-------------|---------|
| `color` | `:string` | `"base"` | Color theme | `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver` |
| `opacity` | `:string` | `"semi_opaque"` | Opacity level | `transparent`, `light`, `semi_opaque`, `opaque`, `solid` |
| `backdrop` | `:string` | `nil` | Backdrop blur size | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `class` | `:any` | `nil` | Custom CSS class | — |

## Slots

### `inner_block` Slot

Content to display over the overlay.

## Usage Examples

### Basic Overlay

```heex
<.overlay color="dark" opacity="semi_opaque" />
```

### With Content / Loading Screen

```heex
<.overlay :if={@loading} color="dark" opacity="semi_opaque">
  <div class="flex flex-col items-center justify-center h-full text-white">
    <.spinner size="large" color="white" />
    <p class="mt-4">Loading...</p>
  </div>
</.overlay>
```

### With Backdrop Blur

```heex
<.overlay color="white" opacity="light" backdrop="medium" />
```

## Common Patterns

### Modal Backdrop

```heex
<div class="relative">
  <.overlay color="dark" opacity="semi_opaque" />
  <div class="absolute inset-0 flex items-center justify-center">
    <.modal id="my-modal" show={true}>
      Modal content
    </.modal>
  </div>
</div>
```

### Image Overlay

```heex
<div class="relative">
  <img src="/image.jpg" alt="Image" />
  <.overlay color="primary" opacity="semi_opaque">
    <div class="flex items-center justify-center h-full text-white">
      <h2 class="text-2xl font-bold">Overlay Title</h2>
    </div>
  </.overlay>
</div>
```
