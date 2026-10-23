# Device tests

Host-driven ExUnit tests for the real MishkaMob app on a phone. One app runs for
the whole suite; each test remounts the page it needs and drives it with real
in-process touches over Erlang distribution (`Mob.Test`). This replaces the
Compose instrumentation in `android/app/src/androidTest`, which relaunched the
Activity for every test.

## Running

```sh
# once: build and install an app that has the harness (this branch's MobBridge.kt)
ASDF_ZIG_VERSION=0.17.0-dev.269+ebff43698 JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  mix android.native --device <adb serial>

# attach the tunnels without restarting the app (after a replug or an adb restart)
mix mob.connect --no-iex --no-restart

mix test --only device                              # the whole device suite
mix test --only device test/device/popover_test.exs # one class
mix test --only device test/device/popover_test.exs:61   # one test
```

A plain `mix test` (and `mix precommit`) excludes `:device` and never touches a
phone. The suite finds the app in the Mac's EPMD, reads its cookie from
`~/.mob/dist_cookies`, and checks that the build on the phone can be driven; if
not it says what to run. `MOB_DEVICE_NODE=<name>@127.0.0.1` picks one when
several phones are registered.

After a Kotlin change reinstall with `mix android.native`; after an Elixir change
under `lib/` push with `mix mob.push --all`. Changes to the tests themselves need
neither.

The phone is shared: nothing else should be driving it while the suite runs.

## Writing a test

```elixir
defmodule MishkaMob.Device.PopoverTest do
  use MishkaMob.DeviceCase, page: :popover

  test "tapping the trigger opens the panel" do
    refute_shown("pop-panel")

    tap("pop-trigger-closed")

    assert_shown("pop-panel")
  end
end
```

`page: :popover` remounts that component's showcase page before every test: fresh
assigns, scroll at the top, default (dark) theme. Override one test with
`@tag page: :other`, or opt out with `@tag page: nil` and call `fresh_page/2`
yourself. The module is tagged `:device` and runs serially.

Address everything by tag, the `:id` of its node. The frame table (`frame/1`,
`assert_shown/2`) knows only tagged nodes, and a node that left the screen has no
frame. Assert on tags rather than page text: the page is one eagerly rendered
tree, and every code sample is text too. If the component you are porting lacks a
tag you need, add one to its page; the Kotlin tests asked for them the same way.

When porting a Kotlin class, keep one test per `@Test` and keep its comments when
they explain why. Leave the Kotlin class where it is: `androidTest` is deleted in one
go, once every class has a device test.

## The helpers

All come from `MishkaMob.Device`, imported by `use MishkaMob.DeviceCase`. Units are
dp of the activity window; a frame is
`%{left, top, right, bottom, width, height}`.

| Helper | What it does |
| --- | --- |
| `tap(tag, opts)` | A real touch at the tag's centre, scrolling the page to it first if needed. Verifies a handler received it. |
| `tap_xy(x, y, opts)` | The same at a point, for what has no tag (outside a panel). |
| `hold(tag, ms \\ 650, opts)` | A real long press; blocks for `ms`. |
| `drag(tag, {dx, dy})` / `swipe({x1, y1}, {x2, y2})` | A real drag over real frames, enough to cross touch slop. |
| `type(text)` / `delete_backward(n)` | Key events into the focused field (ASCII only). Tap the field first. |
| `event(tag, prop \\ :on_tap)` | Delivers the handler message the node carries, with no touch. For a payload under test, or a control a modal popup covers. |
| `frame(tag)` / `frame!(tag)` | The tag's frame, `nil` / a failure when it is not laid out. |
| `settled_frame(tag)` | `frame!/1` once it stops moving. Use for popup panels, which follow their anchor a frame behind. |
| `shown?(tag)` | Is it laid out. |
| `assert_shown(tag)` / `refute_shown(tag)` | Wait for it to be there / gone. Failure lists the tags near the one you named. |
| `assert_text(text)` | The rendered tree carries `text`. Render tree, not pixels. |
| `scroll_into_view(tag)` | Scroll the page so the tag is on screen. `tap/2` does this itself. |
| `scroll_page(:top \| :bottom \| {:page, n})` | Scroll the page. |
| `assert_eventually(fun, opts)` | Polls every 10ms until `fun` is truthy. A failed `assert` inside `fun` means "not yet". `timeout:` defaults to 3s. |
| `assigns()` / `render_tree()` | The screen's assigns / the tree its `render/1` produced. |
| `fresh_page(slug, opts)` | The reset that `page:` runs. Call it to switch pages mid-test. |
| `sync()` | Settle the BEAM and wait a frame natively. Every helper already ends in it; you need it only after poking `Mob.Test` directly. |
| `device!()` | The app's node, for calling `Mob.Test` yourself. |
| `stats()` | `%{taps, retried}`. `retried` should stay 0. |

`tap` and `hold` options: `expect: :event` (default) fails if the touch reaches no
handler; `expect: :none` fails if it does (a disabled control); `retry: n` (default
1) is how often a dropped tap is repeated.

## Rules that keep it fast and honest

- **Never sleep a fixed time.** Every interaction already waits for the app to
  settle. To wait for something else, `assert_eventually/2`, or `assert_shown/2`.
- **Don't read a frame mid-flight.** `settled_frame/1` for a panel, not `frame/1`.
- **A negative check proves nothing without the interaction before it.** `refute_shown`
  passes at once if nothing was ever there. Do the thing that could have put it there
  first, through a helper (which waits for the result).
- **A touch is routed like a finger.** An open popup is a modal window: a tap on
  the trigger underneath reaches the popup as an outside touch and dismisses it,
  exactly as it would for a user. When the handler's payload is what you are testing,
  use `event/2`.
- **A popup window is reachable once any node in it carries an `:id`.** The router
  finds popup windows through the frame table.
- **Text typed is ASCII.** The virtual keyboard has no key sequence for anything else.

## How it works

`MobBridge.kt` carries a debug-only harness (a release build answers every
input call with an error): `tapXy`, `longPressXy`, `swipeXy`, the held press,
`typeText` and `deleteBackward` dispatch real `MotionEvent`s and `KeyEvent`s
in-process, `touchTarget` routes a touch to the topmost popup window that holds the
point or is touch-modal, and `screenInfo` doubles as the native barrier. `mob_nif.zig`
(in the `mob` dep) already binds each of these by name.

Event handles carry the generation of the render that minted them, and native drops
a tap sent with a stale one, silently. So after every interaction `sync/0` waits for
the BEAM to commit (`Mob.Test.settle/2`) and then for the main looper to apply it and
draw a frame (`Mob.Test.screen_info/1`). With the BEAM half alone, 12 of 30 rapid taps
were lost; with both, none in 180. On top of that every tap compares
`Mob.Agent.Receipts` before and after, so a drop that gets through anyway fails where
it happened. `harness_test.exs` runs 40 toggles with the retry off.

In debug builds `reset_to` skips the 250ms cross-fade (the showcase never resets
its own stack): the outgoing page, popups and all, would otherwise stay alive under
the next test. A push or pop still animates, and the barrier waits for it to end.
