---
name: mob-component-fix
description: "Definition of done for fixing a Mob component. Use when the user reports a bug in, or asks you to check, any component under development/mob — it enforces the seven things that ship with the fix (usage rule, showcase handlers, e2e, props/eex/exs checks)."
---

# Fixing a Mob component

Fixing the reported bug is **one seventh** of the job. All seven ship together, or the component is not done.

Run from `development/mob` unless a path says otherwise.

## 1. Fix the reported bug

And any earlier-reported bug on that component that is still outstanding. Ask yourself what the user said last time about this one.

## 2. Usage rule

`usage-rules/mob/<name>.md`. **Check first — many components have none.**

```bash
ls usage-rules/mob/
```

Match the house style: Generate → What it renders → Example (with handler) → Props table → "Three things to know" → Related. Lead with the platform wall the component ran into, not the prop list.

## 3. Showcase examples

If the component has any `on_*` prop, its `code:` sample must show the **handler** receiving it — a sample that stops at the tag leaves a control that renders and does nothing.

```bash
grep -c "handle_info" lib/mishka_mob/showcase/components/<name>.ex
```

Also confirm every sample matches what it actually renders. They drift.

## 4. e2e test

A device test that would have caught the bug you just fixed.

```bash
ls android/app/src/androidTest/java/com/example/mishka_mob/
mix android          # ← DEPLOY THE ELIXIR FIRST. `mix e2e` does not.
mix e2e <Name>Test
```

**`mix e2e` only builds and runs the Kotlin.** It does not push BEAM files, so without `mix android` you are testing the device's old Elixir and every conclusion you draw is about code you already changed. The tell is a showcase page still quoting a `code:` sample you edited. This cost several wasted runs and one wrong diagnosis.

Assert the thing the node tree cannot show — geometry, hit-testing, a round trip through the screen. If `mix test` could already prove it, it does not belong here.

### Scroll first, then measure

A node outside the scroll viewport reports `(0, 0, 0, 0)` **whatever its layout**. So a zero rect means one of two completely different things, and measuring before scrolling cannot tell them apart:

```kotlin
compose.onAllNodesWithText(label, substring = false)[0].performScrollTo()
compose.waitForIdle()
val rect = boundsOf(label)          // only NOW is this worth anything
```

If it is still zero-width after scrolling, it is a real layout bug. To see where a node actually sits — including off-screen — dump the tree, which prints true bounds either way:

```kotlin
android.util.Log.d("DUMP", compose.onRoot().printToString(maxDepth = 60))
```
```bash
adb logcat -c && mix e2e <Name>Test >/dev/null 2>&1
adb logcat -d -s DUMP | grep -B3 "Text = '\[Import\]'"
```

## 5. Props check, both directions

`props/0` against what the component actually reads:

```bash
grep -o 'Map.get(props, :[a-z_]*' lib/mishka_mob/components/mishka_<name>.ex | sort -u
grep -n 'name: "' lib/mishka_mob/showcase/components/<name>.ex
```

Props the component reads but the page omits **and** props the page lists that the component ignores. The second kind is worse: it sends a reader off wiring something inert.

## 6. Check the `.eex`

`priv/mob/<name>.eex` is generated from the component. After any component change:

```bash
cd .. && cd .. && mix mishka.mob.sync --yes
```

`GeneratedComponentsTest` fails if you forget.

## 7. Check the `.exs`

`priv/mob/<name>.exs` — `doc_url` (should be `/chelekom/docs/mob/<hyphenated>`), `necessary`, `category`, `mob: function/kit`. `mix test test/mishka_chelekom/generators/mob_test.exs` in the repo root covers the invariants.

## Give text-less controls an `:id`

Mob turns `:id` into a native testTag, and it is the **only** handle a device test has on a
control that renders no text. Needed so far by the colour-swatch, the tree's disclosure arrows and
checkboxes, the skeleton's bars, and all four colour canvases — so assume any new drawn or
icon-only control needs one, and add it with the fix rather than when the test fails.

Where a component owns more than one such control, suffix them (`<id>-area` / `<id>-hue`) so they
cannot collide, and number repeated ones (`<id>-0`, `<id>-1`).

```elixir
props = if id, do: Map.put(props, :id, id), else: props
```

Document it in the props table as "A native testTag. A canvas has no text to find it by."

## Assert on strings unique to the RENDER

A showcase page displays its own code sample as text, so `showing("Saving…")` is true whether or
not the overlay is up. This has cost a full device run three times — on the loading overlay, on
the accordion's first panel body, and on the pill samples. Before asserting on a phrase, check it
does not also appear in the `code:` block; prefer a button label or a caption that only the render
produces.

## Three defect classes to check unprompted

Each has bitten several components — look for them even when unreported.

**A Box given neither `width` nor `fill_width` fills its parent.** Broke pill, mark, tree's disclosure arrow, color_input's ▾ trigger. Anything meant to hug its content needs `fill_width={false}`.

**`Mob.Composite` pre-widens tag props to `{screen_pid, tag}`.** Composing that with a per-item value yields a tag no `handle_info` clause matches — the handler registers, the tap fires, the catch-all eats it. Use `Event.handler/2`, never `Event.handler({tag, value})`. Broke ten components at once.

**A Row's first child takes every pixel it asks for.** A control not told to hug asks for all of them, so the later children are measured to **zero width** and parked past the edge. They stay in the node tree with working click handlers, so `mix test` passes, `performClick` "succeeds", and only a finger on the device can tell. Any component laying out a row of caller-supplied controls must make them hug:

```elixir
defp hug(%{props: props} = node), do: %{node | props: Map.put_new(props, :fill_width, false)}

actions |> Enum.map(&hug/1) |> Enum.intersperse(~MOB(<Spacer size={8} />))
```

**Not `weight`.** It also places them, and it is wrong: `weight` is `Modifier.weight` and Mob's iOS renderer does not implement it (`MobRootView.swift` builds `HStack(alignment:, spacing: 0)`; every `weight` in that file is a *font* weight). The row would divide evenly on Android and not on iOS. Same trap as `meter`, which avoided a hand-drawn weighted gauge for this reason. Broke empty_state; check any component whose slot is "a row of your widgets".

**A Column cannot align its children.** Mob maps it to a bare Compose Column — no `horizontalAlignment`, and `align` is read for Box and Row only. So a "centred" layout built as a Column centres nothing: the widest child sets the width and every narrower one left-aligns. Centre by wrapping each part in its own `<Box fill_width={true} align={:center}>`, and add `text_align={:center}` for the lines inside a wrapped paragraph. The failure is invisible until two parts differ in width, which is why it survives review.

## Slots ARE expressible in `~MOB`

Do not claim otherwise (an earlier empty_state rule did, wrongly). A slot is a child tag matched on `:type` and consumed by the parent's `expand/3` — `<MishkaAccordionItem>` is the precedent:

```elixir
@actions_type :mishka_empty_state_actions

children |> Enum.filter(&match?(%{type: @actions_type}, &1)) |> Enum.flat_map(&Map.get(&1, :children, []))
```

Children arrive at `expand/3` **unexpanded**, which is what makes this work (`Mob.Composite.do_expand/4` runs the expander before recursing). Slot tags are not in Mob's whitelist, so the sigil warns "pass-through" — cosmetic, and it is the reason to prefer a slot over an opaque list-of-nodes prop: the component can then own the layout it is responsible for. Keep the prop as a fallback for callers assembling actions from data.

## Before saying it is done

```bash
mix format --check-formatted && mix compile --warnings-as-errors && mix test
mix deploy --android && mix e2e
```

Then commit per logical change. **Never push** — that is the user's call.

## Traps that cost real time

- A `~S"""` sample containing `~MOB"""` closes the outer heredoc. Use the single-line `~MOB"…"` form inside samples.
- `performClick` fires at a node's coordinates whether or not they are on screen — always `performScrollTo` first, or the tap misses silently with no exception.
- Infinite animations and Compose idling: the suite once hit `IdlingResourceTimeoutException` in a run where a page with an indeterminate `Progress` had just been added, and `performScrollTo` waits for idle. But `ProgressTest` later walked exactly such a page with the ordinary helpers and passed, so treat this as a suspect to check rather than a rule. **Do not** "fix" it with `compose.mainClock.autoAdvance = false` — that freezes the whole render loop, and because this app's trees arrive from the BEAM asynchronously, nothing renders at all and every assertion times out.
