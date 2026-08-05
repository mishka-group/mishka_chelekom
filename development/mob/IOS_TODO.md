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

## 10. `MobTextField` ignores `lines`, and styles itself instead of reading props

`MobRootView.swift` — the text-field case renders a single-line field whatever
`lines` says, and applies `.textFieldStyle(.roundedBorder)` rather than reading
`background`, `border_color` or `border_width`. Android's `MobTextField` honours
all four (`singleLine = !multiline` with `minLines`/`maxLines`, plus the colours
through `TextFieldDefaults.colors`).

Two consequences worth naming. `mishka_json_input` is a **textarea** — six rows
by default — and on iOS it is a one-line box, so a JSON document is edited
through a slit. And because the border props are inert there, a field that
signals an error state by reddening its border shows nothing at all; only the
message underneath survives.

**Fix:** read `lines` (`axis: .vertical` with `lineLimit(n...n)` on iOS 16+), and
honour `background` / `border_color` / `border_width` instead of the stock style
— matching what `nodeModifier` already does on Android.

## 11. `MobBox` ignores `fill_height` as soon as a `width` is set

`MobRootView.swift` — `MobBox`'s first branch fires on `fixedWidth > 0` and
passes `height: node.fixedHeight > 0 ? ... : nil`. `fillHeight` is consulted
only in the *second* branch, the one taken when there is no width. So a Box with
a width and `fill_height` and no explicit height measures **0pt tall**.

This is the mirror image of item 1 and is **not** fixed by item 1's remedy.

`mishka_separator`'s vertical rule is exactly that shape — `<Box width={thickness}
fill_height={true} background={color} />` — so a vertical separator is 1pt wide,
0pt tall, and therefore invisible on iOS. It is also childless, so there is no
intrinsic height to fall back on. Android applies `fillMaxHeight()` before the
width in `nodeModifier` and is correct.

**Fix:** apply `maxHeight: .infinity` when `fillHeight` is set, inside the
`fixedWidth > 0` branch too.

## 12. `Divider` draws along its container's axis on iOS, so it is vertical inside a Row

`MobRootView.swift` — the divider case is `Divider().frame(height: node.thickness)`.
SwiftUI's `Divider()` is context-sensitive: a horizontal line inside a VStack, a
**vertical** one inside an HStack. Android's `MobDivider` always uses Material3's
`HorizontalDivider`.

So any `<Divider>` inside a `<Row>` comes out as a vertical hairline and is then
clamped by `.frame(height:)` to a `thickness`-tall tick — a 1x1pt dot at the
default. `mishka_separator`'s labelled variant ("line — label — line") puts both
of its rules in a Row, so on iOS the label is flanked by two dots.

**Fix:** in the `.row` case, or on the divider itself, force the orientation —
a `Rectangle().frame(height: thickness)` with `maxWidth: .infinity` behaves the
same in both stacks and does not depend on the container.

## 13. `weight` is read nowhere in the iOS renderer

Not partial support — absent. Every `weight` in `MobRootView.swift` is a *font*
weight; the row case renders children with a bare `ForEach` and no per-child
modifier. Android reads it in both `Row` and `Column`
(`MobBridge.kt:2240-2244`).

This is broader than one component. `Kit.props_table` weights its two columns
2:1 and `Kit.component_card` weights its label — so **every showcase page** lays
out differently on iOS, and every component that shares space by ratio (the
separator's flanking lines, the segmented control's segments, number_field's
body) falls back to intrinsic sizes.

**Fix:** SwiftUI has no direct equivalent, but `.frame(maxWidth: .infinity)` on
weighted children divides space evenly, and a `GeometryReader` + explicit widths
handles unequal ratios. Even the even-split approximation would fix most callers.

## 14. The scroll NIFs do not exist on an iOS release build

`ios/mob_nif.m` — `scroll_info`, `scroll_to` and `element_frames` are inside
`#if !MOB_RELEASE`, both their implementations and their entries in the NIF
function table. On a release build the Erlang stub
`scroll_to(_Id, _X, _Y) -> erlang:nif_error(not_loaded)` runs and **raises**,
taking the calling screen process down.

That matters now that this is not only a test path: `MishkaScroller.nudge/3`
calls `:mob_nif.scroll_to/3` so a rail's arrows actually move it. It rescues and
returns `:unsupported`, so the arrows are simply inert there rather than fatal —
but "the arrows do nothing on iOS release" is a real gap, not a styling one.

Android registers the NIF unconditionally (`jni/mob_nif.zig`) and
`MobBridge.scrollTo` has no debug gate, so it works in every Android build.

**Fix:** move scroll_info/scroll_to out of the debug-only block — reading and
setting a scroll offset is not a debugging capability. `element_frames` can stay
gated.

## 15. `mob_nif.scroll_to/3` blocks a scheduler and is not dirty-flagged

`MobBridge.scrollTo` launches on `Dispatchers.Main` then blocks on
`latch.await(2, TimeUnit.SECONDS)`, and the NIF is registered with `.flags = 0`
rather than `ERL_NIF_DIRTY_JOB_CPU_BOUND` (which `element_frames` alongside it
does use). Fine for a harness driven over rpc; a screen handler calling it inline
stalls a BEAM scheduler until the main thread services the coroutine.

**Fix:** flag it dirty, like its neighbour.

## 16. Android `scroll_info` reports width in the height fields for a horizontal rail

Ours, not iOS's — `MobBridge.kt`'s `scrollInfo`. In the horizontal branch
`viewportPx` holds the **width**, yet the JSON sets `content_h`, `viewport_w`
*and* `viewport_h` from it. Only `offset_x` and `max_x` are trustworthy for a
horizontal scroller.

It also feeds a second bug upstream: `Mob.Test.scroll_to(node, id, {:page, n})`
computes `{ox, n * vh}` — it always pages on Y — so `{:page, n}` is a silent
no-op on any horizontal rail. `MishkaScroller.nudge/3` reads only the x-axis
figures for this reason.

**Fix:** set the height fields from the measured height (or 0) in the horizontal
branch, and make `resolve_scroll_target/2` page along the scroller's own axis.

## 17. There is no `:anchored` node type on iOS, so every floating panel is still an accordion

`:anchored` is a node type this app renders itself — `MobAnchored`,
`MobBridge.kt:2431` — and it exists on Android only. It takes exactly two
children: child [0] is the anchor and renders **in flow**, child [1] is the panel
and renders in its own window via `androidx.compose.ui.window.Popup`. The panel
therefore overlays the page: it takes no space, it may sit above or left of its
trigger, and no ancestor can clip it. Position is a transliteration of the web's
`positionPopup()` — `side` (top/right/bottom/left), `align` (start/center/end),
`side_offset`, `align_offset`, a main-axis flip when the requested side has no
room **and** the opposite one does, then an unconditional clamp to the window
with 8dp of edge padding plus the safe-area inset.

iOS does something else instead, and the reason this went unnoticed is that it
does not fail loudly. `mob_nif.m`'s `mob_node_from_dict` maps the type string
through an `if`/`else if` chain (`mob_nif.m:604-648`) that ends at `"gpu_view"`
with **no else**, so an unrecognised type leaves `node.nodeType` at the
zero-initialised value — which is `MobNodeTypeColumn` (`MobNode.h:22`). An
anchored node therefore renders as a plain `VStack` of `[trigger, panel]`
(`MobRootView.swift:220`): exactly the stacked accordion the node type was built
to replace. It neither errors nor blanks. `MishkaPopover`, `MishkaTooltip` and
`MishkaPreviewCard` all build on `:anchored` now, so on iOS all three are back to
pushing their siblings down the page, and `side` / `align` / `side_offset` are
inert there.

**The trap: a green unit test proves nothing about iOS here.**
`Mob.ScreenCase.assert_renderable/2` bakes `@renderable_types` from
`read.("ios.txt") ++ read.("android.txt")` (`deps/mob/lib/mob/screen_case.ex:112`)
— a **union**, so an Android-only type counts as renderable. And `Anchored` is
literally in `ios.txt` (line 28) besides: our own `mix.exs` writes the composites
fence into both files from `@tag_files ~w(android ios)` (`mix.exs:90`), which is
what teaches the `~MOB` sigil our tag names. Nothing in the unit suite can see
this gap. Only a device run can.

**Fix — the SwiftUI mechanism.** Not `.overlay(alignment:)` + `.offset`: an
overlay draws inside its host's subtree, so a `corner_radius` Box or a vertical
`Scroll` clips it, and that clipping is the measured failure that made
`:anchored` a node type rather than a positioned Box. The shape that works is
`anchorPreference` + a root-level overlay. `MobRootView` (`MobRootView.swift:1317`)
is already a top-level `ZStack` sitting above every Box and Scroll: publish the
anchor child's bounds with `.anchorPreference(key:value:.bounds)`, collect them
at that ZStack with `.overlayPreferenceValue`, resolve each through the
`GeometryProxy` and `.position` the panel there. `MobFrameTracker`
(`MobRootView.swift:489`) already reads `geo.frame(in: .global)` for id-carrying
nodes, so the measurement half is not new ground. Port
`MobAnchoredPositionProvider`'s arithmetic verbatim rather than rewriting it —
all three headless engines carry a byte-identical copy of `positionPopup()`, and
a fourth version will drift. `.popover(isPresented:attachmentAnchor:)` is the
wrong tool despite the name: it adapts to a sheet on iPhone, brings its own arrow
and dimming, and dismisses itself on an outside tap — and the BEAM owns
open/closed here, so a self-dismissing window desynchronises from the screen's
assign.

**Blocker: this cannot ship from this repo at all.** `deps/mob` is a hex package
pinned in `mix.lock` (`mob 0.7.20`) with its checksums; anything written into
`deps/` is local scratch that `deps.get`, `deps.clean` and a fresh clone all drop
— `mix.exs` regenerates its tags fence on every compile for precisely that reason
— and consumers get the published package, never our copy. Unlike every Android
half above, where `MobBridge.kt` is ours, the anchored primitive has to land
upstream in `mob` itself.

---

## Also worth knowing

`track_color` is not in `Mob.Renderer`'s `@color_props` whitelist, so it accepts
a raw ARGB int only — a colour token passes through as a string and is silently
ignored. Adding it upstream would let both platforms take tokens.

Bridge fixes made in `MobBridge.kt` here do **not** reach consumers: apps
generated by `mix mishka.ui.gen.mob` get the mob templates, not this file. Any
Android fix above should be upstreamed the same way as the iOS ones.
