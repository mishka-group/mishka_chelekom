# Device tests

Host-driven ExUnit tests for the real MishkaMob app on a phone or an emulator. One app
runs for the whole suite; each test remounts the page it needs and drives it with real
in-process touches over Erlang distribution (`Mob.Test`). They replaced the Compose
instrumentation that lived in `android/app/src/androidTest`, which relaunched the
Activity for every test.

## Running

```sh
mix e2e                          # the whole suite, on every attached device
mix e2e popover                  # one file (popover_test.exs, PopoverTest, ...)
mix e2e test/device/popover_test.exs:61   # one test
mix e2e --device emulator-5554   # only this device
```

`mix e2e` (the runner is `test/e2e.exs`; its moduledoc lists the options) does what used to
be done by hand, per device:

1. installs the APK with `mix android.native` **only if something native changed** since it
   last did (the Kotlin and JNI under `android/`, `priv/`, `config/`, `mob.exs`,
   `mix.lock`), and otherwise leaves the install alone;
2. attaches to the running app in the Mac's EPMD, with the adb tunnels `mix mob.connect`
   sets up, restarting the app only if it does not answer;
3. hot-loads the modules of this app's `:dev` build that differ (by MD5) from the ones the
   app has loaded. Only this app's: never `mob_nif`, which is why it is not `mix mob.push`
   (`--all` overwrites the app's `mob_nif.beam` and the harness stops answering, and plain
   `mix mob.push` pushes nothing for beams that were compiled before it ran);
4. runs `mix test --only device` once per device in its own OS process, with
   `MOB_DEVICE_NODE` and `MIX_TEST_PARTITION` set and `--partitions` equal to the number of
   devices, so a phone and an emulator each take half of the files. One summary at the end.

On the build machine (`mix android.native` needs them):
`ASDF_ZIG_VERSION=0.17.0-dev.269+ebff43698` and
`JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`.

By hand, with one device and the app already running with its tunnels up:

```sh
mix test --only device                                   # the whole suite
mix test --only device test/device/popover_test.exs:61   # one test
```

A plain `mix test` (and `mix precommit`) excludes `:device` and never touches a
phone. The suite finds the app in the Mac's EPMD, reads its cookie from
`~/.mob/dist_cookies`, and checks that the build on the phone can be driven; if
not it says what to run. `MOB_DEVICE_NODE=<name>@127.0.0.1` picks one when
several devices are registered (`mix e2e` sets it for each partition).

`mix e2e --report DIR` keeps a JUnit file per partition, each partition's output and the
device's logcat in `DIR`. CI runs it as two shards, one emulator each
(`mix e2e --device emulator-5554 --shard 1/2 --report ...`), and uploads `DIR` on failure.

Nothing else should be driving a device while the suite runs.

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
tag you need, add one to its page.

## The helpers

All come from `MishkaMob.Device`, imported by `use MishkaMob.DeviceCase`. Units are
dp of the activity window; a frame is
`%{left, top, right, bottom, width, height}`. Tests keep no helper of their own for
anything on this list: if two modules want the same private function, it belongs
here.

**Touch**

| Helper | What it does |
| --- | --- |
| `tap(tag, opts)` | A real touch at the tag's centre, scrolling the page to it first if needed. Verifies a handler received it. On a text field it returns once the keyboard's resize has settled; the first tap after typing waits the same way before it aims. |
| `tap_xy(x, y, opts)` | The same at a point, for what has no tag (outside a panel). |
| `touch(tag, fx \\ 0.5, fy \\ 0.5)` | A tap `fx` across and `fy` down the tag with no receipt required. For a canvas, whose position is its value. |
| `focus(tag)` | A touch in the bottom-right corner of a text field, so the caret lands at the end. For a field with no `on_focus` (a tap on it delivers no event and fails) or one that already has focus. |
| `hold(tag, ms \\ 650, opts)` | A real long press; blocks for `ms`. |
| `drag(tag, {dx, dy})` / `swipe({x1, y1}, {x2, y2})` | A real drag over real frames, enough to cross touch slop. Both return once the fling is over, so the next tap is not swallowed by it. |
| `while_pressed({x, y}, fun)` / `press_move({x, y})` | A finger held down while `fun` runs; the lift is in an `after`, at the last position. For a state that exists only while pressed. |
| `event(tag, prop \\ :on_tap)` | Delivers the handler message the node carries, with no touch. Only with a comment saying why a touch cannot do it. |

`tap`, `tap_xy`, `touch`, `focus`, `hold` and `event` return the receipts they produced.
`tap`, `tap_xy` and `hold` take `expect: :event` (default: fails if the touch reaches no
handler), `expect: :none` (fails if it does: a disabled control) or `expect: :any` (only
has to be dispatched: a canvas, a field that already has focus), and `retry: n` (default 1)
for how often a dropped tap is repeated.

**Keyboard**

| Helper | What it does |
| --- | --- |
| `type(text)` / `delete_backward(n)` | Key events into the focused field (ASCII only). `focus/1` or `tap/2` the field first. `type("\n")` is the IME action. |
| `type_each(text)` | One key at a time, settling between them, for a value the screen sanitises key by key. |
| `replace_text(tag, text)` | `focus/1`, a backspace per character of the field's current value, then `type_each/1`. There is no select-all or clear-text. |

**Frames and scrolling**

| Helper | What it does |
| --- | --- |
| `frame(tag)` / `frame!(tag)` / `frames()` | The tag's frame, `nil` / a failure when it is not laid out, and the whole table. |
| `settled_frame(tag)` | `frame!/1` once it stops moving. Use for popup panels, which follow their anchor a frame behind. |
| `shown?(tag)` | Is it laid out. |
| `assert_shown(tag)` / `refute_shown(tag)` | Wait for it to be there / gone. Failure lists the tags near the one you named. |
| `scroll_into_view(tag, opts)` | Scroll the page so the tag is on screen (`tap/2` does this itself). `center: true` also brings a tag that is merely on screen to the middle, so a drag has room both ways; `in: "<id>"` scrolls another scroll view. |
| `scroll_page(:top \| :bottom \| {:page, n})` | Scroll the page. |
| `center(frame)` / `point(tag, fx, fy)` | A frame's centre / a point a fraction across and down a tag (scrolls to it first). |
| `same_row?(a, b)` / `outside(frame, gap \\ 80)` | Two frames on one row / a point a finger could land on outside a popup. |
| `screen()` / `step()` / `reach()` | The window's width, height, scale and insets / a vertical drag distance (15% of the height) / a sideways one (40% of the width). |

**The render tree** (what the screen asked for, not what is drawn; native state such as
a field's own text is unreadable from the host, so the tree stands in and a test says so)

| Helper | What it does |
| --- | --- |
| `render_tree()` / `assigns()` | The tree `render/1` produced / the screen's assigns. |
| `find_node(tag)` / `node!(tag)` | The node with that `:id`, `nil` / a failure when there is none. `find_node(tree, tag)` searches a subtree. |
| `text_of(tag)` / `text_of!(tag)` | Its text: `nil` when there is none (for `assert_eventually/2`) / a failure. |
| `value_of(tag)` | The value the screen gave a text field. |
| `texts()` / `texts_under(tag)` / `labelled?(tag, label)` | Every rendered text / those inside one node / does that node carry exactly that label. |
| `text_count(text)` | How many nodes read exactly `text`. |
| `showing?(text)` / `assert_text(text)` | Is a string prop containing `text` rendered anywhere. Substring over the whole page, so a code sample can satisfy it: use a string no sample quotes. |
| `readout(regex)` / `readout_int(regex)` / `percent()` | The first rendered text that is, whole, the pattern / its number / the topmost `NN%`. |
| `state_of(prefix, states)` / `state_of!/2` / `state_tag/2` | A control whose state rides in its tag (`<prefix>-<state>`): which state, a failure unless it has one, the whole tag. |
| `assert_headings(list)` | Every heading is rendered and the page scrolls to its props table. |

**Pacing and bookkeeping**

| Helper | What it does |
| --- | --- |
| `assert_eventually(fun, opts)` | Polls every 10ms until `fun` is truthy. A failed `assert` inside `fun` means "not yet". `timeout:` defaults to 3s. |
| `fresh_page(slug, opts)` | The reset that `page:` runs. Call it to switch pages mid-test. |
| `sync()` / `barrier()` | Settle the BEAM and wait a frame natively / only the native half. Every helper already ends in `sync/0`; you need it only after poking `Mob.Test` directly. |
| `device!()` | The app's node, for calling `Mob.Test` yourself. |
| `stats()` | `%{taps, retried}`. `retried` should stay 0. |

## Rules that keep it fast and honest

- **Never sleep a fixed time.** Every interaction already waits for the app to
  settle. To wait for something else, `assert_eventually/2`, or `assert_shown/2`. That
  includes the soft keyboard (`tap/2` waits for it) and a fling (`drag/2` waits for it):
  do not add a pause after either.
- **Don't read a frame mid-flight.** `settled_frame/1` for a panel, not `frame/1`.
- **A control that must do nothing is tapped with `expect: :none`.** A disabled or inert
  control wires no handler, so a real touch on it reaches nothing, and `expect: :none`
  fails if it reaches something. Tapping it and then checking that nothing changed
  proves less: the tap may not have landed at all.
- **A negative check proves nothing without the interaction before it.** `refute_shown`
  passes at once if nothing was ever there. Do the thing that could have put it there
  first, through a helper (which waits for the result).
- **Touch first, `event/2` last.** A touch is routed like a finger. An open popup is a
  modal window: a tap on the trigger underneath reaches the popup as an outside touch
  and dismisses it, exactly as it would for a user. Use `event/2` only when the handler's
  payload is what you are testing, or a modal popup covers the control, and say which in
  a comment next to the call.
- **Match the field to the touch.** A text field with an `on_focus` handler is tapped
  (`tap/2`); one without, or one that already has focus, takes `focus/1`; a canvas takes
  `touch/3`.
- **Ask a tag, not the page.** The page is one eagerly rendered tree and every code sample
  is a text node too: `text_of/1` or `labelled?/2` for one component, `showing?/1` and
  `assert_text/1` only for strings no sample quotes.
- **Compare a readout whole.** A description often contains the unit; use `readout/1`
  with `\A...\z`, or `x in texts()`, not a substring.
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

Two more things the pacing absorbs. Focusing a text field raises the soft keyboard,
which resizes the page over ~400ms, and a frame read inside that window is a frame in
flight: `tap/2` on a field, `focus/1`, and the first touch after typing wait for the page
and the target to hold still. And a drag ends in a fling, which swallows any tap that lands
on it (taps 90 to 350ms after a drag were lost, even retried): `drag/2` and `swipe/3` wait
until the page's scroll offset, and the dragged tag, have held still for three frames.
A canvas drag leaves no receipt, so what proves it landed is the readout the page renders.

In debug builds `reset_to` skips the 250ms cross-fade (the showcase never resets
its own stack): the outgoing page, popups and all, would otherwise stay alive under
the next test. A push or pop still animates, and the barrier waits for it to end.
