# slider (headless)

An unstyled, accessible single-thumb slider: markup + WAI-ARIA wiring + keyboard/pointer behavior, with logic delegated to the shared `Slider` JS engine. Implements the [WAI-ARIA APG Slider pattern](https://www.w3.org/WAI/ARIA/apg/patterns/slider/).

## Generate

```bash
mix mishka.ui.gen.headless slider
```

Generates `lib/<app>_web/components/headless/slider.ex`. Wire up the JS engine in `app.js`:

```js
import Slider from "./slider.js";
const Hooks = { Slider };
```

## Anatomy

Root is a `<div>` carrying `phx-hook="Slider"`, config `data-min`/`data-max`/`data-step`/`data-value` attributes, and `class="chelekom-slider"`. `Slider` queries `[data-part="track"]` (falls back to the root), `[data-part="thumb"]`, and `[data-part="input"]`.

| Part | Element | `data-part` | Class | Rendered |
|------|---------|-------------|-------|----------|
| root | `div` | — | `chelekom-slider` | always |
| track | `div` | `track` | `chelekom-slider__track` | always |
| range | `div` | `range` | `chelekom-slider__range` | always |
| thumb | `div` | `thumb` | `chelekom-slider__thumb` | always |
| input | `input` (hidden) | `input` | `chelekom-sr-only` | only when `name` is set |

## ARIA & keyboard

- **thumb** — `role="slider"`, `tabindex="0"`, `aria-valuemin={@min}`, `aria-valuemax={@max}`, `aria-valuenow={@value}`, `aria-labelledby={@labelledby}` (override via `labelledby` attr). The engine updates `aria-valuenow` as the value changes.

Keyboard (bound to the thumb's `keydown` by `Slider`; each preventsDefault):

| Key | Action |
|-----|--------|
| ArrowRight / ArrowUp | increase by `step` |
| ArrowLeft / ArrowDown | decrease by `step` |
| PageUp | increase by `10·step` |
| PageDown | decrease by `10·step` |
| Home | set to `min` |
| End | set to `max` |

Pointer: `pointerdown` on the track sets the value from the cursor position; dragging updates it until `pointerup`. All values are snapped to `step` and clamped to `[min, max]`.

## State

No paired-presence `data-*` state attributes. `data-min`/`data-max`/`data-step`/`data-value` are config inputs read once on mount, not toggled state.

`Slider` instead exposes the resolved position as the `--chelekom-slider` CSS custom property (a `0`–`1` ratio) on the root, sets the thumb's inline `left` to `${ratio * 100}%`, mirrors the value into `aria-valuenow` on the thumb, and syncs it to the hidden `[data-part="input"]` for form submission. Style from `--chelekom-slider` rather than from state attributes.

## Example

```heex
<.slider id="volume" name="volume" min={0} max={100} step={5} value={40} />
```

With an external label:

```heex
<span id="vol-label">Volume</span>
<.slider id="volume" name="volume" min={0} max={100} step={5} value={40} labelledby="vol-label" />
```

**Attrs**: `id` (required) · `name` (enables hidden form input; default `nil`) · `min` (default `0`) · `max` (default `100`) · `step` (default `1`) · `value` (initial/controlled, default `0`) · `labelledby` (overrides thumb's `aria-labelledby`) · `class` (extra root classes) · `rest` (global). No slots.

## Styling

Ships **no** colors or spacing — only structural markup. Style via the `chelekom-slider*` classes (`chelekom-slider`, `__track`, `__range`, `__thumb`) and the `--chelekom-slider` CSS variable the engine writes to the root:

```css
.chelekom-slider__track { position: relative; height: 0.5rem; }
.chelekom-slider__range {
  position: absolute;
  inset-inline-start: 0;
  width: calc(var(--chelekom-slider) * 100%);
}
.chelekom-slider__thumb { position: absolute; transform: translateX(-50%); }
```

The thumb's `left` is set inline by the engine. Add your own classes to the root via the `class` attr.
