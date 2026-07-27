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
./gradlew assembleDebugAndroidTest

# 3. deploy to the emulator/device (native rebuild + BEAM push)
cd development/mob && mix android.native

# 4. run the e2e suite on the device
cd development/mob/android && ./gradlew installDebugAndroidTest
cd development/mob && mix android.native
adb shell am instrument -w \
  com.example.mishka_mob.test/androidx.test.runner.AndroidJUnitRunner
```

**Not `./gradlew connectedDebugAndroidTest`.** That task reinstalls the APK, and
Android wipes `/data/user/0/<pkg>/files/` on any reinstall — which is where the
entire OTP release lives. The BEAM then has no boot file and the app dies with
`cannot get bootfile` about a second after `onCreate`. The order above installs
first, deploys the release second, and runs the instrumentation directly so
nothing reinstalls underneath it.

The same trap catches Android Studio's **Run** button: it installs the APK and
leaves the app unable to boot until `mix android.native` re-pushes the release.
Note that `mix mob.deploy` is not enough on its own — it restores the `.beam`
modules but not the release.

Step 2 is only needed when you want Android Studio to pick a change up — step 3
rebuilds natively on its own. If you changed **only** Elixir, skip both and use
`mix mob.push`, which hot-pushes the changed modules into the running app
without rebuilding anything. That is the fast path, and it is most of the day.

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
2. Add a gallery page under `lib/mishka_mob/showcase/components/`.
3. Register both in `MishkaMob.Showcase`'s `@catalog` — app boot and the tests
   read the same list, so they cannot drift.
4. Write tests, run `mix mishka.mob.sync` from the repository root so `priv/mob`
   follows, and check the four gates: `mix compile --warnings-as-errors`,
   `mix test --warnings-as-errors`, `mix credo --strict`,
   `mix format --check-formatted`.

Two rules that are easy to get wrong and expensive to find later:

**Our components are composite tags, and the whitelist warning is expected.**
A registered composite is written `<MishkaChip … />` like any other tag, and
`~MOB` warns that it is "not in the Mob tag whitelist" because registration
happens at runtime and the sigil runs at compile time — Mob documents that
warning as normal (CHANGELOG 0.7.13); an unregistered tag rendering *nothing* is
the real failure to look for. This repo builds with `--warnings-as-errors`, so
its own code calls the function (`{chip(...)}`) while the docs show the tag,
which is what an app would actually write.

**Event props must go through `MishkaMob.Components.Event.handler/1`.** The
renderer only registers a handler when the prop is `{screen_pid, tag}`; a bare
atom serialises as an ordinary prop, and the control then renders perfectly and
does nothing.

## Two kinds of test, and what each is for

| | Where | Run with | What it can see |
|---|---|---|---|
| **Unit** | `test/mishka_mob/` | `mix test` | The node tree a component returns |
| **E2E** | `android/app/src/androidTest/` | `am instrument` — see above | What the device actually draws and does |

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

### Writing e2e tests

They are Compose UI tests, so they read like Playwright: find a node, click it,
type into it, assert. They run **inside** the app process on the device; they do
not drive Android Studio, which is only one way to launch them (the green ▶ in
the gutter of a test class).

```kotlin
compose.onNodeWithText("OTP Field").performClick()
compose.onNodeWithTag("otp-code").performTextInput("123456")
compose.onNodeWithText("6 of 6 digits").assertIsDisplayed()
```

Three properties of this app shape every test you will write here:

**The BEAM boots asynchronously.** Nothing is on screen when the Activity
appears, so every entry point has to `waitUntil` for content rather than assume
it.

**The BEAM outlives the Activity.** Relaunching `MainActivity` does not reset
the app — the screen stack is whatever the previous test left behind. Tests
navigate themselves to a known place and reset the state they depend on.

**To target a widget, give it an `id`.** The bridge turns an `:id` prop into a
Compose `testTag`. Without one there is often nothing to match on — the OTP
input is invisible by design, so its `id` is the only handle it has.

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
