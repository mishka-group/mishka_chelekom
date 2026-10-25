# MishkaMob — the Mob development app

The native [Mob](https://hexdocs.pm/mob) application where
[Mishka Chelekom](https://mishka.tools/chelekom)'s components are built,
exercised on a device, and shown off. It is a real BEAM-on-device app: Elixir
renders a tree of native widgets that Jetpack Compose and SwiftUI draw directly
— no HTML, no WebView.

Two things live here:

* `lib/mishka_mob/components/` — the ported Chelekom components. This is also
  the source `mix mishka.mob.sync` derives `priv/mob` from, so **edit them here**
  and never in `priv/mob`, or the two will drift.
* `lib/mishka_mob/showcase/` — a gallery page per component, with live examples
  and a props table.

## Requirements

Elixir and OTP as pinned in `.tool-versions`, plus the Android toolchain:

| | |
|---|---|
| JDK | 17 or 21 |
| Android SDK | compileSdk 35 |
| Android NDK | 27.2.12479018 |
| Gradle | 8.5 (via the wrapper — do not install it) |
| adb, zig | on `PATH` |

`mix mob.doctor` checks all of it and is the first thing to run when a build
behaves oddly. For iOS you also need Xcode.

## The loop

```bash
# 1. Elixir unit tests
cd development/mob && mix test

# 2. compile the app (what Android Studio needs to see the change)
cd development/mob/android && ./gradlew assembleDebug

# 3. deploy to the emulator/device (native rebuild + BEAM push)
cd development/mob && mix android.native

# 4. run the device suite
cd development/mob && mix e2e                 # every device test, on every attached device
mix e2e popover                               # one file (popover_test.exs, PopoverTest, ...)
mix e2e --device emulator-5554                # only this device
```

`mix e2e` is the whole of step 3 and 4 for a day-to-day change. For each attached
device it installs the APK **only if something native changed** (the Kotlin and JNI
under `android/`, `priv/`, `config/`, `mob.exs`, `mix.lock`), attaches to the running app
over Erlang distribution, and hot-loads the modules of your `:dev` build that differ
from the ones the app has loaded. Then it runs `mix test --only device` once per
device, in parallel: with two devices attached (a phone and an emulator, say) the
files of `test/device` are split between them, and one summary comes out at the end.
It raises when a test fails. How the tests are written and how they drive the app:
[`test/device/README.md`](test/device/README.md); the runner's options:
the moduledoc of [`test/e2e.exs`](test/e2e.exs).

**Never `mix mob.push --all`** while the suite is in use: it also pushes the host's
`mob_nif.beam` over the device's, which breaks the harness. `mix e2e` pushes only this
app's own modules.

**Not `./gradlew connectedDebugAndroidTest`, and not Android Studio's Run button for
the app.** Both reinstall the app APK, and Android wipes `/data/user/0/<pkg>/files/`
on any reinstall — which is where the entire OTP release lives. The BEAM then has no
boot file and the app dies with `cannot get bootfile` about a second after `onCreate`.
`mix android.native` installs the APK and pushes the release again; `mix e2e` runs it
for you when it has to.

The same trap catches Android Studio's **Run** button: it installs the APK and
leaves the app unable to boot until `mix android.native` re-pushes the release.
Note that `mix mob.deploy` is not enough on its own — it restores the `.beam`
modules but not the release.

Step 2 is only needed when you want Android Studio to pick a change up — step 3
rebuilds natively on its own. If you changed **only** Elixir, skip both and use
`mix e2e` (which hot-loads what changed), or `mix mob.push` to look at the app
yourself: it hot-pushes the changed modules into the running app without
rebuilding anything. That is the fast path, and it is most of the day.

## No device? Use an emulator

Nothing here needs a cable. `local.properties` already carries an x86_64 OTP
release, so an AVD behaves exactly like a phone:

```bash
mix mob.emulators                        # list AVDs and simulators
mix mob.emulators --start --id Pixel_9a  # boot one
mix deploy                               # then deploy as normal
```

## Adding a component

1. Write it in `lib/mishka_mob/components/mishka_<name>.ex`, exposing both
   `expand/3` (the composite tag) and a function component.
2. Add a gallery page under `lib/mishka_mob/showcase/components/` — a module
   that `use MishkaMob.Showcase.Page`.
3. Register both in `MishkaMob.Showcase`'s `@catalog` — app boot and the tests
   read the same list, so they cannot drift.
4. Write tests, run `mix mishka.mob.sync` from the repository root so `priv/mob`
   follows, and check the four gates: `mix compile --warnings-as-errors`,
   `mix test --warnings-as-errors`, `mix credo --strict`,
   `mix format --check-formatted`.

Two rules that are easy to get wrong and expensive to find later:

**Our components are composite tags — write them as tags.** A registered
composite is `<MishkaChip … />` like any other tag, and that is what the
showcase, the code samples and the generated docs all use. Reach for the
function form (`{chip(...)}`) only for something a tag cannot express.

`~MOB` validates tag names at compile time against a list Mob bakes in from its
own `priv/tags/`, and our composites register at runtime, so the sigil cannot
know about them and warns. `mix.exs` adds them to that list on every compile
(see `tags/1`) — which is why the tags compile quietly here even though the
build treats warnings as errors. An unregistered tag renders *nothing* rather
than failing, so that warning is worth keeping honest; `TAG_WHITELIST.md` is
the write-up of the whole problem.

Consumers get the same thing from the CLI: `mix mishka.ui.gen.mob` adds the
tags it generates to `config :mob, :extra_tags` and wires `register_all/0` into the app's `on_start/0`.

**Event props must go through `MishkaMob.Components.Event.handler/1`.** The
renderer only registers a handler when the prop is `{screen_pid, tag}`; a bare
atom serialises as an ordinary prop, and the control then renders perfectly and
does nothing.

## Two kinds of test, and what each is for

| | Where | Run with | What it can see |
|---|---|---|---|
| **Unit** | `test/mishka_mob/` | `mix test` | The node tree a component returns |
| **Device** | `test/device/` | `mix e2e` | What the device actually draws and does |

Most coverage belongs in the unit tests: they are fast, they run everywhere, and
`Mob.ScreenCase` asserts on the rendered tree far more precisely than a device
test can.

The e2e tests exist for what a node tree **cannot** show you — bugs that live in
the bridge, where Elixir is right and the screen is wrong. The whole unit suite
has been green while a field kept characters the BEAM had discarded, while every
`background` and `text_color` set on a `TextField` was silently ignored, and
while typing into the first slot of an OTP inserted at the front. A device is
the only place those are observable, which is the argument for the second suite
— and the reason to keep it small rather than mirroring the first.

### Writing device tests

They are ExUnit tests that run on your Mac and drive the real app on the device over
Erlang distribution (`Mob.Test`): real touches and key events dispatched inside the
app process, the screen's layout read back as frames. One app runs for the whole
suite and each test remounts the page it needs, so a test is a few lines:

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

`test/device/README.md` has the helpers and the rules that keep them honest. Three
properties of this app shape every test:

**To target a widget, give it an `id`.** The bridge turns an `:id` prop into a
Compose `testTag` and records its frame; the frame table knows only tagged nodes.
Without one there is often nothing to find — the OTP input is invisible by design,
so its `id` is the only handle it has. Assert on tags rather than text: a page
shows its own code sample, so any phrase in it is on screen whether or not the
component rendered it.

**Never press system back.** Back at the gallery pops the app's root screen and
Android leaves the app — the launcher becomes the resumed activity and every
later query silently runs against the home screen, which reads as a timeout
rather than as navigation walking out of the app. Use the showcase's own
`← Back` button, or `fresh_page/2`, which resets the stack.

**Nothing else may drive the device while the suite runs.** A phone someone is
using, or an emulator another run is on, makes taps land on the wrong screen.

## Android Studio

Open `development/mob/android`, not the repository root — the Gradle project is
that directory.

It earns its keep for Logcat, the layout inspector and debugging `MobBridge.kt`.
It is **not** a way to skip `mix`: the APK carries `libmishka_mob.so` and no
application `.beam` files, and installing it wipes the OTP release along with
them. After any **Run**, re-push both with `mix android.native` — `mix mob.deploy`
restores the modules but not the release, and `mix mob.push` neither.

**No soft keyboard on the emulator?** That is the AVD, not the app. `hw.keyboard=yes`
makes Android route typing to your computer's keyboard and never draw the
on-screen one, while `dumpsys input_method` still reports `mInputShown=true`
because the app asked for it correctly. Device Manager → ⋮ → Edit → Show Advanced
Settings → uncheck **Enable keyboard input**, then cold boot.

Set **Settings → Build Tools → Gradle → Gradle JDK** to the bundled JBR. Decline
the "upgrade Android Gradle Plugin" prompt — AGP 8.3+ raises the minimum Gradle
again and AGP 9 removes `packagingOptions`, which is a far larger change than it
looks.

## Toolchain notes

Gradle is pinned at **8.5** deliberately: it is the minimum version that
supports running on JDK 21, and Kotlin 1.9.22's documented Gradle range stops at
8.1.1, so every version above 8.5 widens that gap for nothing. The wrapper is
checksum-pinned — update `distributionSha256Sum` alongside `distributionUrl` or
the build fails with a mismatch.

CameraX is held at 1.4.2 in the hand-editable half of `app/build.gradle`.
1.3.4's `libimage_processing_util_jni.so` was the one native library that was
not 16 KB page-aligned, which Android flags as a compatibility warning. The
managed `mob:plugin-deps` block below re-injects 1.3.4 on every build and
Gradle's highest-wins resolution beats it. Anything inside a `mob:plugin-*`
region is regenerated on every build; edit above it.

## Links

* [Mishka Chelekom](https://mishka.tools/chelekom) — the component library
* [Chelekom docs](https://mishka.tools/chelekom/docs) — every component, styled and headless
* [Mob](https://hexdocs.pm/mob) — the BEAM-on-device framework
