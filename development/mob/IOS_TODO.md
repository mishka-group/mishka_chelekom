# iOS TODO — gaps found while porting, all in the `mob` dependency

Every item here was found by reading both renderers while porting a Chelekom
component, and **none of them can be fixed from this repo**: the iOS renderer
lives in the `mob` hex package (`deps/mob/ios/`), while the Android bridge
(`development/mob/android/.../MobBridge.kt`) is ours and has already been fixed
where noted.

Each entry says what is wrong, where, and what the fix looks like — enough to
pick up cold.

> Android is the reference implementation for all of these. When you fix the iOS
> side, port the Android behaviour rather than inventing a second one, and
> re-run the matching `mix e2e <Component>Test` on both platforms.

---

## 1. `MobBox` drops a Box's height unless it also has a width

`MobRootView.swift` — `MobBox` applies `fixedHeight` only inside its
`if node.fixedWidth > 0` branch. A Box with a `height` and no `width` therefore
falls to `.frame(maxWidth: .infinity)` with no height at all, and a childless one
(a skeleton bar, a hairline rule) measures **0pt tall and draws nothing**.
Android applies width and height unconditionally in `nodeModifier`.

**Fix:** apply `fixedHeight` in all three branches — the same
`.ifLet(node.fixedHeight > 0 ...) { v, h in v.frame(height: h) }` chain the
image and video cases already use. Until then `mishka_skeleton` works around it
by putting a sized `Spacer` inside every bar, which can be removed afterwards.

## 2. `MobToggle` is uncontrolled

`MobRootView.swift` — `MobToggle` seeds `@State private var isOn` once in its
initialiser and binds the control to that local copy; `node.checked` is read only
at view-identity creation and there is no resync. So the thumb moves on touch
whatever the screen decides, and a screen that rejects or clamps a change is
never reflected. Android re-reads `checked` from props on every recomposition.

**Consequence:** `disabled` does not disable on iOS. It works by omitting the
handler, which stops an uncontrolled control from *reporting* but not from
moving.

**Fix:** add `.onChange(of: node.checked) { _, new in if new != isOn { isOn = new } }`,
and forward a real `enabled` flag so a disabled switch also looks disabled.

## 3. `MobSlider` is uncontrolled, for the same reason

`MobRootView.swift` — `MobSlider` has the identical `@State` seeded-once shape as
`MobToggle`. Android solved this with a render-epoch resync
(`LocalRenderEpoch` + `seenEpoch`); iOS never got one.

**Fix:** mirror the Android epoch resync, or bind to `node.value` with an
`onChange` guard.

## 4. `MobToggle` ignores colour

`MobRootView.swift` — `Toggle(label, isOn:)` carries no `.tint(...)`, so the
control always paints the system accent. Android reads `color` (thumb) and
`track_color` (track) into `SwitchDefaults.colors`; the track half was added
here and needs the same on iOS.

**Fix:** `.tint(...)` colours the track; the thumb needs a
`.toggleStyle(SwitchToggleStyle(tint:))` or a custom style.

## 5. The slider has no range (two thumbs) and no vertical orientation

SwiftUI ships neither, so both must be built. Android now has both — Compose's
`RangeSlider`, and a `Modifier.rotate(-90f)` inside a fixed-height Box for
vertical — behind the `values`, `orientation` and `length` props, which
`MishkaSlider` already emits and iOS currently ignores.

**Fix:** a custom SwiftUI control for the range case (two draggable thumbs over
a shared track), and `.rotationEffect(.degrees(-90))` in a sized frame for
vertical.

Android's range slider is **already hand-built** for this reason — Compose's
`RangeSlider` clamps the dragged thumb and then reports the clamped value, so
once the thumbs meet nothing says the finger is still pushing. `MobRangeSlider`
owns its drag (`detectDragGestures`), so it always knows the pointer and can
push. Port that shape to SwiftUI rather than reaching for a stock control.

## 6. `MobBox` never reads `fill_width`, so nothing can hug on iOS

`MobRootView.swift` — `MobBox` branches on `fixedWidth > 0` and `fillHeight`
only, then falls through to `.frame(maxWidth: .infinity)`. `fill_width` IS
decoded (`MobNode.h`, `mob_nif.m`) and simply never read for a box, so a Box can
only stop filling by carrying an explicit width — which a label's width is not.

This is why `mishka_chip` renders full-width on iOS. `Button` is the one node
that reads the prop on both, but Material3 gives it a minimum size and content
padding that made the chips oversized enough to overflow their row and clip the
last label, so the chip uses a Box and is correct on Android only. `mishka_pill`
has the same shape.

**Fix:** honour the prop —
`.frame(maxWidth: node.fillWidth == false ? nil : .infinity)` — after which the
chip is correct on both with no Elixir change.

## 7. There is no `on_commit` on either platform

The headless slider distinguishes `on_change` (dragging) from `on_commit`
(release). Neither bridge emits a drag-ended event, so only `on_change` is
ported. Worth adding to both bridges together rather than one at a time.

## 8. A `fill_width` Row CENTRES its content on iOS, but is left-aligned on Android

`MobRootView.swift:253` — the row case applies
`.ifLet(node.fillWidth ? () : nil) { view, _ in view.frame(maxWidth: .infinity) }`
with **no `alignment:` argument**, so SwiftUI defaults to `.center`. The column
case two dozen lines above (line 229) explicitly passes `alignment: .topLeading`,
which is what makes the omission look accidental rather than chosen. Android's
`Row` uses the default `horizontalArrangement = Start` (`MobBridge.kt:2235`).

So any `<Row fill_width={true}>` whose children are all inflexible — an indicator
Box of fixed width, a sized Spacer, a Text that hugs — reports the sum of its
children, and the frame then centres that block. Every checkbox and radio row is
exactly that shape: on Android a group renders as a straight left-hand column, on
iOS each row centres *independently*, so rows with different label lengths put
their boxes at different x positions and the list reads as ragged and broken.
Taps are unaffected (`.contentShape(Rectangle())` is applied after the frame), so
this is purely visual — and invisible to every device test we have, which is why
it went uncaught this long.

This is **not** specific to one component: it affects roughly every row-based
component in the library, `mishka_checkbox`, `mishka_radio`, and both groups
included.

**Fix:** `view.frame(maxWidth: .infinity, alignment: .leading)` — matching what
the column case does. Nothing in Elixir needs to change.

**In-repo workaround if iOS is needed before that lands** (unverified — no iOS
device has been run this session): append a flexible `<Spacer />` with **no
`size`** as the row's last child. On iOS `fixedSize == 0` means "fill available
space" (`MobNode.h:167`, `MobRootView.swift:381-389`), so it absorbs the slack and
pins the content to the leading edge; on Android a sizeless `MobSpacer` is
`Spacer(modifier = Modifier)` (`MobBridge.kt:2812`), which measures 0×0 with no
weight and changes nothing. Apply it only when `fill_width` is true.

## 9. `Text` has no `max_lines` on iOS

`MobBridge.kt`'s `MobText` now reads `max_lines` and pairs it with
`TextOverflow.Ellipsis`; the iOS side has no equivalent — `MobRootView.swift`
builds its Text with no `.lineLimit`, and the only `.lineLimit(1)` in the file
belongs to the Button label.

It matters because of what Compose (and SwiftUI) do to a Text squeezed narrower
than its content: they wrap it CHARACTER BY CHARACTER. A token that does not
quite fit its row renders as a vertical stack of letters — "Ja", "pa", "n" —
rather than being clipped. Every pill sets `max_lines: 1` for that reason, so on
iOS a slightly over-packed row of chips will still stack letters vertically
where Android now ellipsises.

**Fix:** read the prop and apply `.lineLimit(n)` plus `.truncationMode(.tail)`
in the `.text` case. One line, and it makes the packing estimate's failure mode
survivable on both platforms rather than one.

---

## Also worth knowing

`track_color` is not in `Mob.Renderer`'s `@color_props` whitelist, so it accepts
a raw ARGB int only — a colour token passes through as a string and is silently
ignored. Adding it upstream would let both platforms take tokens.

Bridge fixes made in `MobBridge.kt` here do **not** reach consumers: apps
generated by `mix mishka.ui.gen.mob` get the mob templates, not this file. Any
Android fix above should be upstreamed the same way as the iOS ones.
