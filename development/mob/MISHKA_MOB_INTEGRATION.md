# Mishka Chelekom × Mob — Integration Plan

> R&D document for porting Mishka Chelekom (Phoenix LiveView component kit)
> to render as native iOS / Android UI through the Mob framework.
>
> **Audience**: Mishka maintainers + Mob author (GenericJam).
> **Status**: Pre-implementation R&D. Decisions in §5 and §6 still need the
> Mob author's sign-off before we commit to APIs.
>
> Sources consulted:
> - `deps/mob/` (Mob v0.6.18) — full library source
> - `/Users/shahryar/Documents/Programming/Elixir/mishka_chelekom` (v0.0.9-beta.1)
> - `/Users/shahryar/Documents/Programming/Elixir/mishka` — production app using Chelekom
> - https://hexdocs.pm/mob/theming.html
> - https://github.com/GenericJam/mob/blob/master/lib/mob/theme.ex
> - https://hexdocs.pm/mob_dev/0.5.11/readme.html

---

## 0. TL;DR

1. **You cannot reuse a single line of HEEx.** Mob does not render HTML. There is no `~H`, no `@assign` shorthand, no `Phoenix.LiveView.JS`, no `phx-*` attributes, no Tailwind. The Chelekom templates have to be re-authored.
2. **The right model is a parallel generator track**, not a runtime adapter. Keep Chelekom's existing `.exs` config files as the source of truth for variants/colors/sizes, ship a **second** template set (`*.mob.eex`) and a **second** mix task (`mix mishka.mob.gen.component`) that emits Mob-native modules.
3. **Theme bridge is the hard problem, not the syntax bridge.** Mishka has ~14 variants × 14 colors per component = 196 visual combinations. Mob has 13 semantic color tokens and the `:variant` axis doesn't exist in Mob's vocabulary at all. We have to **collapse, not translate**.
4. **Pilot with Button.** It's already used in `lib/first_mob_beam/home_screen.ex` (via the `nav_button/2` helper), has the cleanest 1:1 native analogue, and exercises every system we care about (props, events, theming).
5. **Custom native widgets stay out of scope for v0.1.** Mob's `Mob.Component` + native factory contract requires shipping Swift + Kotlin per widget. Pure-Elixir composition over Mob's 18 built-in widgets is enough for ~60% of Chelekom's catalog.

---

## 1. The two libraries at a glance

| | **Mishka Chelekom** | **Mob** |
|---|---|---|
| Version | 0.0.9-beta.1 | 0.6.18 |
| Renders to | HTML in the browser, server-rendered through Phoenix LiveView | Native iOS (SwiftUI) + Android (Jetpack Compose) via NIF |
| Template engine | HEEx (`~H`) | NimbleParsec sigil (`~MOB`) or hand-written maps |
| Distribution | Dev-only dep. `mix mishka.ui.gen.component <name>` copies an `.ex` file into the host project from a `.eex` template + `.exs` config. The library is **not** in the runtime. | Runtime library. App calls `use Mob.App` / `use Mob.Screen`. |
| Component count | 74 components, organised by category (form / nav / feedback / layout / media / typography / specialised) | 18 built-in native widgets, closed enum |
| Theming | Tailwind 4 utility classes hardcoded in templates + CSS custom-property overrides | `%Mob.Theme{}` struct of 13 semantic colour tokens + scales + radii; fixed enum |
| Interactivity | `phx-click`, `phx-mounted`, `Phoenix.LiveView.JS`, 8 JS hooks (carousel, combobox, floating, …) | Tagged-tuple events delivered to the screen GenServer's `handle_info/2`; **no JS at all** |
| Form binding | `Phoenix.HTML.FormField` | None — you manage your own `value` / `on_change` state |
| Slots | Named slots (`:inner_block`, `:loading`, …) | Single ordered `children` array, no names |
| Variant axes per component | variant × color × size × rounded × padding × space (often 5–6 axes, hundreds of combos) | Semantic tokens at the prop level — no `variant` concept built-in |
| i18n / RTL | Gettext for labels. No RTL helpers in Chelekom today. | None — apps roll their own |
| Maturity flag | "beta" | "Early development. Not yet ready for production use." (README) |

---

## 2. What Mob actually is — the parts that matter for this port

> The full §1–§4 audit is in `/tmp/mob_research.md` (1500 lines).
> Here's what's load-bearing for the integration.

### 2.1 The rendering model is a node map

Every screen's `render/1` returns a tree of maps:

```elixir
%{
  type: :column,
  props: %{padding: :space_md, background: :background},
  children: [
    %{type: :text, props: %{text: "Hello", text_size: :xl}, children: []}
  ]
}
```

That map is JSON-serialised in one call and handed to the NIF. SwiftUI / Compose
do their own diffing on the native side — **there is no LiveView-style diff on the BEAM**.
Every render passes the entire tree, every time. Performance budget for our
components has to be measured against that.

There are three equivalent surfaces for producing the map:

| Form | Example | When to use |
|---|---|---|
| `~MOB` sigil | `~MOB(<Text text="Hi" />)` | Most ergonomic for human-authored screens |
| `Mob.UI` constructor | `Mob.UI.text(text: "Hi")` | When you want function composition without parsing |
| Raw map | `%{type: :text, props: %{text: "Hi"}, children: []}` | When you're generating dynamically |

**All three produce byte-identical output.** That matters: our generator can emit any of them.

### 2.2 The `~MOB` sigil is NOT HEEx

What it has in common with HEEx: PascalCase tag names, `{...}` expression interpolation, balanced brace nesting, nesting tags inside tags.

What it does NOT have:

- ❌ `@variable` shorthand → you must write `text={assigns.title}`
- ❌ Named slots → only `children` (a single ordered list)
- ❌ `:for=` / `:if=` directives → use plain Elixir expressions
- ❌ `phx-*` attributes → events are props (`on_tap={...}`)
- ❌ `Phoenix.LiveView.JS` → no client-side JS at all
- ❌ Components calling other components with `<.button>` syntax → you call Elixir functions and splice the result in with `{my_button(label: ...)}`

Worked example, from `lib/first_mob_beam/home_screen.ex:11`:

```elixir
def render(assigns) do
  ~MOB"""
  <Scroll background={:background}>
    <Column background={:background} padding={:space_lg}>
      <Image src={logo_src(assigns.theme)} width={120} height={120} content_mode="fit" />
      <Spacer size={16} />
      <Text text="Shahryar!" text_size={:xl} text_color={:on_surface} padding={:space_sm} />
      ...
      {nav_button("Text Input", :open_text)}
      ...
    </Column>
  </Scroll>
  """
end
```

The `{nav_button(...)}` interpolation is how Chelekom-style components plug in:
**they're plain Elixir functions returning a node map**, spliced into the tree
at the call site. There is no `<.button>` calling convention — there can't be,
because Mob's sigil doesn't know about user functions.

### 2.3 The 18 built-in native widgets

Closed enum. Listed in `deps/mob/priv/tags/ios.txt` and `android.txt`. Identical on both platforms:

| Group | Widgets |
|---|---|
| Layout | `Box`, `Column`, `Row`, `Spacer`, `Scroll`, `Divider` |
| Text & input | `Text`, `TextField`, `Toggle`, `Slider` |
| Display | `Image`, `Video`, `Progress`, `List`, `LazyList` |
| Navigation | `TabBar` |
| Action | `Button` |
| Specialised | `CameraPreview`, `WebView`, `Canvas`, `GpuView` |

Anything Chelekom needs that isn't on this list must be **composed from these primitives**. (e.g. Chelekom's `<.alert>` becomes a `<Box>` wrapping an `<Image>` icon + `<Column>` of text. There is no native Alert widget.)

The set is **closed**. Mob's maintainers add widgets by editing iOS Swift + Android Kotlin. Mishka cannot ship new ones.

### 2.4 The theme — full token inventory

Source: `deps/mob/lib/mob/theme.ex` + `https://hexdocs.pm/mob/theming.html`.

```elixir
defstruct [
  # ── 13 semantic colour tokens ───────────────────────────
  primary:        :blue_500,
  on_primary:     :white,
  secondary:      :gray_600,
  on_secondary:   :white,
  background:     :gray_900,
  on_background:  :gray_100,
  surface:        :gray_800,
  surface_raised: :gray_700,
  on_surface:     :gray_100,
  muted:          :gray_500,
  error:          :red_500,
  on_error:       :white,
  border:         :gray_700,

  # ── scale factors ───────────────────────────────────────
  type_scale:  1.0,
  space_scale: 1.0,

  # ── radii (dp/pt) ───────────────────────────────────────
  radius_sm:   6,
  radius_md:  10,
  radius_lg:  16,
  radius_pill: 100,

  # ── effect flags ────────────────────────────────────────
  glass: false
]
```

Spacing tokens (`Mob.Renderer`, base values × `space_scale`):

| Token | Base |
|---|---|
| `:space_xs` | 4 |
| `:space_sm` | 8 |
| `:space_md` | 16 |
| `:space_lg` | 24 |
| `:space_xl` | 32 |

Text-size tokens (× `type_scale`):

| Token | Base (sp) |
|---|---|
| `:xs` | 12 |
| `:sm` | 14 |
| `:base` | 16 |
| `:lg` | 18 |
| `:xl` | 20 |
| `:"2xl"` | 24 |
| `:"3xl"` | 30 |
| `:"4xl"` | 36 |
| `:"5xl"` | 48 |
| `:"6xl"` | 60 |

**Critical constraint: the theme struct is NOT extensible.** Third parties cannot add new tokens (e.g. `:rose_pulse_500`). The supported escape hatches:

1. **Override built-in tokens at startup**: `use Mob.App, theme: {Mob.Theme.Obsidian, primary: :rose_500}`
2. **Override at runtime**: `Mob.Theme.set({Mob.Theme.Obsidian, primary: :rose_500})`
3. **Pass raw ARGB integers**: `text_color: 0xFFFF5733` — but this **breaks theming**: no dark mode, no theme switching, no semantic meaning. Use sparingly.

There's also a built-in **base palette** of ~80 named colours (`:blue_500`, `:gray_200`, `:emerald_400`, `:rose_700`, …) you can reference directly. Useful for the Chelekom `color: "danger"` / `color: "success"` / etc. mapping (see §5).

### 2.5 Events

Native taps/changes arrive at the **screen GenServer's `handle_info/2`** as tagged tuples — not at the component:

```elixir
# Component declares:
<Button text="Save" on_tap={{self(), :save}} background={:primary} />

# Screen receives:
def handle_info({:tap, :save}, socket) do
  {:noreply, Mob.Socket.assign(socket, :saved?, true)}
end
```

For TextField, the payload includes the value:

```elixir
<TextField value={assigns.email} on_change={{self(), :email_changed}} />

def handle_info({:change, :email_changed, value}, socket) do
  {:noreply, Mob.Socket.assign(socket, :email, value)}
end
```

A newer unified model is emerging (`Mob.Event.Address` + `{:mob_event, addr, event, payload}`) but the tagged-tuple form is what every example uses today.

### 2.6 Lifecycle

A screen is a GenServer:

```elixir
mount/3   → render/1   → handle_info/2 (event arrives)
            ↑              ↓
            └── render/1 ──┘   ... repeat
```

State lives in `socket.assigns`. `Mob.Socket.assign/2` is the LiveView analogue. Navigation is `Mob.Socket.push_screen/2`, `pop_screen/1`, `reset_to/2`, `switch_tab/1`.

Optional state persistence via `dump_state/1` + `load_state/2` (opt in with `use Mob.Screen, vsn: 1`). Backed by ETS + SQLite on the device.

### 2.7 Custom native components — why we won't use them in v0.1

`Mob.Component` + `Mob.UI.native_view(MyChart, id: :revenue, data: ...)` is Mob's escape hatch for non-built-in widgets. Lifecycle is a real GenServer (`Mob.ComponentServer`) with `mount/2`, `update/2`, `handle_event/3`. The catch:

- You must **register a native factory on iOS in Swift** and **on Android in Kotlin** for every custom widget.
- The component is a **leaf** — its children are not part of Mob's render tree, they're whatever your Swift/Kotlin code draws.
- Users of your library would have to add native code to their `ios/` and `android/` directories. That defeats the "pure dev-dep" model Mishka uses today.

**Conclusion**: a Mishka-Mob component library should ship **only composition wrappers over built-in widgets**, at least for v0.1. Custom native widgets are a v2 conversation that needs separate scaffolding (probably an opt-in `mix mishka.mob.add_native_widget` task).

---

## 3. What Mishka Chelekom actually is — the parts that matter for this port

> The full audit is in `/tmp/mishka_research.md`.

### 3.1 The distribution model

You already nailed this with the existing generator:

```
priv/components/button.exs   ← per-component config (variants, colors, sizes)
priv/components/button.eex   ← EEx template with HEEx output
        ↓
mix mishka.ui.gen.component button --variant default --color primary
        ↓
lib/<app>_web/components/button.ex   ← generated, owned by the user
```

The library is **not in the runtime**. That's the property we want to preserve: the Mob track should be the same shape, but emit different output.

### 3.2 The 74 components

Already catalogued in `/tmp/mishka_research.md` §2. For the integration plan,
the relevant grouping is by "natural Mob analogue":

- **Clean port** (~30 components): Button, Avatar, Badge, Card, Divider, Image, Video, Spinner, Skeleton, Progress, Indicator, Typography, Blockquote, Keyboard, text/email/password/number/url/tel/search/textarea/range/color/date_time fields, Toggle, Checkbox, Radio, Toggle field, Stat
- **Possible with composition + Mob primitives** (~25): Alert, Banner, Layout, Footer, Navbar, Sidebar, Tabs, Drawer, Modal (uses SwiftUI sheet / Android dialog → still pure-composition, no native code, but UX differs from web), Toast, List, Pagination, Stepper, Timeline, Form wrapper, Fieldset, Radio card, Checkbox card, File field, Carousel (just a `<Scroll horizontal>`), Accordion, Collapse, Footer, Footer, Card
- **Hard — needs rethink, or skipped in v0.1** (~19): Combobox (no autocomplete native widget), Dropdown / Popover / Tooltip (no floating-positioned overlays in Mob today), Mega menu (web-specific UX), Table / Table_content (would have to be a vertical list of rows), Device mockup (web demo tool, no point on mobile), Jumbotron (a hero section — keep, but redesign), Gallery with filter, Scroll area (Mob's `<Scroll>` already does this), Clipboard (Mob has `Mob.Clipboard`, but the UI is different), Speed dial, Dock, Floating, Shape, Chat, Footer
- **Out of scope** (~0): nothing's truly impossible, but the LOW group should be Phase 3.

### 3.3 What Chelekom does that doesn't translate

| Pattern | Where used | Mob equivalent |
|---|---|---|
| `phx-mounted={show_modal(@id)}` | modal, drawer, toast | `mount/3` of a new screen, or assign-flag-and-conditional-render |
| `Phoenix.LiveView.JS.show / hide / transition` | modal, drawer, dropdown, toast | Conditional rendering. Mob has no client-side JS at all. Animations come from SwiftUI/Compose defaults. |
| JS hooks (carousel, floating, combobox, …) | 8 components | Either replace with a Mob-native pattern (e.g. carousel → horizontal `<Scroll>`) or skip in v0.1 |
| `Phoenix.HTML.FormField` | every form input | The component author manages `value` + `on_change` manually. Or build a `Mishka.Mob.Form` helper. |
| `Tailwind class={[...]}` lists | every component | Atom-valued props on the underlying Mob widget |
| `aria-*` / `role=` | most accessible components | Mob has limited a11y plumbing today; we'd file an issue upstream. SwiftUI and Compose have their own a11y; not clear yet what Mob exposes. (**Open question for Mob author.**) |
| Gettext for labels | modal, drawer, alert | Same approach works — Gettext is BEAM-side, has nothing to do with rendering |

---

## 4. The core architectural gap, illustrated

Side-by-side of the same conceptual button. Both produce a primary, large, rounded action button.

### 4.1 Mishka (web, today)

```elixir
# lib/mishka_web/components/button.ex — generated, ~2000 lines
def button(assigns) do
  ~H"""
  <button
    type={@type}
    id={@id}
    class={[
      default_classes(@rest[:pinging], @indicator),
      size_class(@size, @rest[:circle]),
      color_variant(@variant, @color, @indicator),
      content_position(@content_position),
      rounded_size(@rounded),
      border_size(@border, @variant),
      @full_width && "w-full",
      @class
    ]}
  >
    <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
    <span :if={@inner_block && render_slot(@inner_block)}>
      {render_slot(@inner_block)}
    </span>
    <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
  </button>
  """
end

# ...followed by 100+ defp color_variant("default", "primary", _), do: "bg-..."
# clauses, one per variant × color combination.
```

Call site:

```heex
<.button color="primary" variant="default" size="large" rounded="large" phx-click="save">
  Save
</.button>
```

### 4.2 Mishka.Mob (proposed, native)

```elixir
# lib/first_mob_beam/components/mishka/button.ex — generated, ~150 lines
defmodule Mishka.Mob.Button do
  @moduledoc "Mob-native port of Chelekom button."

  # Pure function — returns a node map, no sigil needed.
  def button(opts) do
    on_tap     = Keyword.fetch!(opts, :on_tap)         # {pid, tag}
    label      = Keyword.get(opts, :label, "")
    color      = Keyword.get(opts, :color, :base)      # :primary, :danger, …
    variant    = Keyword.get(opts, :variant, :default) # :default, :outline, :subtle, …
    size       = Keyword.get(opts, :size, :large)      # :extra_small … :extra_large, :full
    rounded    = Keyword.get(opts, :rounded, :large)
    full_width = Keyword.get(opts, :full_width, false)

    %{
      type: :button,
      props: Map.merge(
        %{
          text:          label,
          on_tap:        on_tap,
          text_size:     mob_text_size(size),
          padding:       mob_padding(size),
          corner_radius: mob_radius(rounded),
          fill_width:    full_width
        },
        mob_colors(variant, color)
      ),
      children: []
    }
  end

  # ── colour bridge (Chelekom 14×14 → Mob semantic + base-palette tokens) ──
  defp mob_colors(:default, :primary),   do: %{background: :primary,   text_color: :on_primary}
  defp mob_colors(:default, :secondary), do: %{background: :secondary, text_color: :on_secondary}
  defp mob_colors(:default, :success),   do: %{background: :emerald_500, text_color: :white}
  defp mob_colors(:default, :danger),    do: %{background: :error,    text_color: :on_error}
  defp mob_colors(:default, :warning),   do: %{background: :amber_500,  text_color: :gray_900}
  defp mob_colors(:default, :info),      do: %{background: :sky_500,    text_color: :white}
  defp mob_colors(:default, _base),      do: %{background: :surface,  text_color: :on_surface}

  defp mob_colors(:outline, color) do
    fg = palette_for(color)
    %{background: 0x00000000, text_color: fg, border_color: fg, border_width: 1}
  end

  defp mob_colors(:subtle, color),       do: %{background: :surface_raised, text_color: palette_for(color)}
  defp mob_colors(:transparent, color),  do: %{background: 0x00000000,      text_color: palette_for(color)}
  defp mob_colors(_, _),                 do: %{background: :primary,        text_color: :on_primary}

  defp palette_for(:primary),   do: :primary
  defp palette_for(:secondary), do: :secondary
  defp palette_for(:success),   do: :emerald_500
  defp palette_for(:danger),    do: :error
  defp palette_for(:warning),   do: :amber_500
  defp palette_for(:info),      do: :sky_500
  defp palette_for(_),          do: :on_surface

  # ── size bridge ─────────────────────────────────────────
  defp mob_text_size(:extra_small), do: :xs
  defp mob_text_size(:small),       do: :sm
  defp mob_text_size(:medium),      do: :base
  defp mob_text_size(:large),       do: :lg
  defp mob_text_size(:extra_large), do: :xl
  defp mob_text_size(:full),        do: :base

  defp mob_padding(:extra_small), do: :space_xs
  defp mob_padding(:small),       do: :space_sm
  defp mob_padding(:medium),      do: :space_md
  defp mob_padding(:large),       do: :space_md
  defp mob_padding(:extra_large), do: :space_lg
  defp mob_padding(:full),        do: :space_lg

  defp mob_radius(:none),        do: 0
  defp mob_radius(:extra_small), do: :radius_sm
  defp mob_radius(:small),       do: :radius_sm
  defp mob_radius(:medium),      do: :radius_md
  defp mob_radius(:large),       do: :radius_lg
  defp mob_radius(:extra_large), do: :radius_lg
  defp mob_radius(:full),        do: :radius_pill
end
```

Call site:

```elixir
def render(assigns) do
  ~MOB"""
  <Column padding={:space_lg}>
    {Mishka.Mob.Button.button(label: "Save", color: :primary, variant: :default,
                              size: :large, rounded: :large, full_width: true,
                              on_tap: {self(), :save})}
  </Column>
  """
end

def handle_info({:tap, :save}, socket) do
  # ...
end
```

The takeaways:

- **The Chelekom config (.exs files) survives verbatim.** Variants, colours, sizes are the same atom names. The user-facing API axes are preserved.
- **The visual fidelity does not survive verbatim.** Chelekom's "default" + "primary" is a specific Tailwind gradient + shadow + ring; Mob's `:primary` is a flat fill. Native users won't expect web-fidelity; they'll expect platform-fidelity. Accept the collapse and document it.
- **No JS.** "Click X to open modal Y" becomes "tap fires `:open_modal`, screen handles it by `push_screen` or an `:modal_visible?` assign + conditional render."
- **No HEEx.** Generated module is plain Elixir functions over Mob's node maps.

---

## 5. The theme bridge — concrete mapping

The hardest design call. Mishka's templates have ~100 hand-tuned colour/variant cells per component. Mob has 13 semantic tokens. We **collapse**, with documented losses.

### 5.1 Colour-name mapping

| Mishka `color` | Mob token | Notes |
|---|---|---|
| `"base"` | `:on_surface` | Foreground default |
| `"natural"` | `:muted` | |
| `"white"` | `:white` (palette) | |
| `"dark"` | `:gray_900` (palette) | |
| `"primary"` | `:primary` | The only first-class mapping |
| `"secondary"` | `:secondary` | |
| `"success"` | `:emerald_500` (palette) | No `:success` in Mob theme — base-palette fallback |
| `"warning"` | `:amber_500` (palette) | Same |
| `"danger"` | `:error` | First-class |
| `"info"` | `:sky_500` (palette) | Same |
| `"silver"` | `:gray_400` (palette) | |
| `"misc"` | `:purple_500` (palette) | |
| `"dawn"` | `:rose_400` (palette) | |
| `"transparent"` | `0x00000000` (raw ARGB) | Documented theme escape |

**Recommendation for the Mob author**: Consider adding `:success`, `:warning`, `:info` to `%Mob.Theme{}` as first-class semantic tokens. They're standard everywhere except Mob. Without them, Mishka components have to use base-palette atoms, which means **dark-mode aware success/warning/info colours are not possible** unless the user explicitly overrides at theme-set time.

### 5.2 Variant mapping

| Mishka `variant` | Strategy |
|---|---|
| `"base"` | Flat surface fill + `:on_surface` text |
| `"default"` | Solid colour fill + `on_*` text |
| `"outline"` | `background: 0x00000000` + 1px `border_color: <color>` + matching `text_color` |
| `"transparent"` | Same as outline but no border |
| `"subtle"` | `background: :surface_raised` + `text_color: <color>` |
| `"shadow"` | Same as `"default"` — Mob doesn't expose shadow primitives today. **Open: ask Mob author re: `<Box shadow={true}>`** |
| `"inverted"` | Swap fg/bg of `"default"` |
| `"bordered"` | `"default"` with `border_color: <color>` + `border_width: 2` |
| `"default_gradient"` | Same as `"default"`. **Mob doesn't support gradients** as of v0.6.18. Track as upstream feature request. |
| `"outline_gradient"` | Falls back to `"outline"` |
| `"inverted_gradient"` | Falls back to `"inverted"` |

**Document the collapse openly.** Generated Mob components for gradient variants emit a warning at compile time so users aren't surprised by the visual delta.

### 5.3 Size mapping

| Mishka | Mob `text_size` | Mob `padding` |
|---|---|---|
| `"extra_small"` | `:xs` | `:space_xs` |
| `"small"` | `:sm` | `:space_sm` |
| `"medium"` | `:base` | `:space_md` |
| `"large"` | `:lg` | `:space_md` |
| `"extra_large"` | `:xl` | `:space_lg` |
| `"full"` | `:base` | `:space_lg` + `fill_width: true` |

### 5.4 Rounded mapping

| Mishka | Mob |
|---|---|
| `"none"` | `0` |
| `"extra_small"` | `:radius_sm` (6) |
| `"small"` | `:radius_sm` (6) |
| `"medium"` | `:radius_md` (10) |
| `"large"` | `:radius_lg` (16) |
| `"extra_large"` | `:radius_lg` (16) |
| `"full"` | `:radius_pill` (100) |

### 5.5 Padding / space scale mapping

Linear: `extra_small → :space_xs`, `small → :space_sm`, `medium → :space_md`, `large → :space_lg`, `extra_large → :space_xl`.

---

## 6. Component portability matrix (the honest version)

For each Chelekom component, this lists the **port strategy**, the **Mob primitives used**, and **what we lose**.

### 6.1 Phase 1 — pure-composition, no UX surprises (~30 components)

| Chelekom | Mob primitives | What we lose |
|---|---|---|
| Button | `<Button>` | Gradients, ping/indicator animations, hover styles |
| Badge | `<Box>` + `<Text>` | Same |
| Avatar | `<Box>` + `<Image>` | Web's fancy ring patterns |
| Card | `<Box>` containing children | Hover effects |
| Divider | `<Divider>` | Custom dashed/dotted styles |
| Image | `<Image>` | Lazy-loading attribute (Mob loads eagerly) |
| Video | `<Video>` (iOS only — Android is stub in 0.6.18) | Cross-platform parity until Mob ships Android ExoPlayer |
| Spinner | `<Progress>` indeterminate | Custom animations |
| Skeleton | `<Box background={:surface_raised}>` | Pulse animation |
| Progress | `<Progress>` | Stripe/animated styles |
| Indicator | `<Box>` 8×8 with colour | Pulse |
| Typography (h1–h6, p) | `<Text>` with size token | Web typography ramp differs |
| Blockquote | `<Box>` with left border + `<Text>` | Italic? Mob text supports `font_weight` but not italics today — **open question** |
| Keyboard kbd | `<Box>` + `<Text>` monospace | Mob doesn't expose `font_family` per element — falls back to platform default |
| TextField | `<TextField>` | RTL handling, IME quirks (Mob has `on_compose` for IME) |
| EmailField | `<TextField keyboard={:email}>` | |
| PasswordField | `<TextField secure={true}>` (v0.6.15+) | |
| NumberField | `<TextField keyboard={:number}>` | |
| URL/Tel/Search fields | same TextField with keyboard hint | |
| Textarea field | `<TextField multiline={true}>` | |
| Range field | `<Slider>` | Marks/ticks |
| Toggle | `<Toggle>` | Custom track/thumb colours |
| Toggle field (label + toggle) | `<Row>` of `<Text>` + `<Toggle>` | |
| Checkbox / Radio | **No native widget in Mob v0.6.18.** Compose as `<Box>` + `<Image>` toggle, or push upstream feature request. |
| Stat | `<Column>` of `<Text>` size variants | |

### 6.2 Phase 2 — possible but with UX deltas (~25 components)

| Chelekom | Strategy | Open issue |
|---|---|---|
| Alert / Banner | `<Row>` of icon + `<Column>` of text + dismiss `<Button>` | Auto-dismiss requires `Process.send_after` from the screen, not the component. We'll need a helper. |
| Modal | Stay on the same screen, conditionally render an overlay `<Box>` with translucent background + content card. **Or** `Mob.Socket.push_screen` to a dedicated modal-style screen. | iOS/Android each have native sheet APIs that Mob doesn't expose yet. Ask the Mob author if `<Sheet>` is on the roadmap. |
| Drawer | Same as Modal — conditional `<Box>` slid in via flex, OR push a screen. | Animations / gesture-driven dismiss are not in Mob today. |
| Toast | Conditional `<Box>` at bottom of screen. Auto-dismiss via screen-side `Process.send_after`. | No native toast widget. |
| Accordion / Collapse | Conditional rendering of children, toggled by an `:expanded?` assign. | No animation. |
| Tabs | `<TabBar>` (built-in) — best fit. Or roll our own with `<Row>` of buttons + content swap. | Built-in TabBar is screen-level (each tab is a sub-stack). For an in-screen tab, we use Row+conditional. |
| Pagination | `<Row>` of numbered buttons + on_tap | Or migrate to infinite-scroll with `on_end_reached`. |
| Stepper | `<Row>` / `<Column>` of `<Circle>`-styled `<Box>` + connector `<Divider>` + `<Text>` | |
| Timeline | `<Column>` of rows, each with a vertical connector | |
| Form wrapper | A function that wraps children in a `<Column>` + maintains a form-state map | We owe Mishka a form-binding helper module (`Mishka.Mob.Form`) — see §9 |
| Fieldset | `<Box>` with `border_color` + `<Text>` legend at top | |
| Checkbox card / Radio card | `<Box>` (tappable) wrapping content + a checkbox indicator | |
| File field | `<Button>` calling `Mob.Files.pick/2` → `handle_info` → display selection | Mob already has `Mob.Files` |
| Carousel | `<Scroll horizontal={true}>` with snap behaviour | No snap-to-page in Mob today — items free-scroll. Track. |
| Layout / Footer / Navbar / Sidebar | `<Column>` / `<Row>` composition. Sidebar = overlay or split layout. | |

### 6.3 Phase 3 — hard / skip in v0.1 (~19 components)

| Chelekom | Verdict | Reason |
|---|---|---|
| Combobox | Skip. | No native autocomplete in Mob. Would need custom widget. |
| Dropdown / Popover / Tooltip | Skip in v0.1. | No floating-positioned overlay primitives. Mob `<Box>` is in-flow only. |
| Mega menu | Skip. | Web-only UX, doesn't fit mobile. |
| Table / Table content | Compose as `<Column>` of `<Row>`s. **Loses**: header pinning, column-resize, sort indicators (no native equivalent). | |
| Device mockup | Skip. | It's a web demo tool for showcasing other components in a phone frame; pointless on a phone. |
| Jumbotron | Trivial compose — `<Column>` with large `<Text>` + child Button. Keep, but redesign for mobile narrowness. | |
| Gallery (filterable) | Compose `<LazyList>` + filter state. Phase 2/3. | |
| Scroll area | Skip — `<Scroll>` already exists in Mob. | |
| Speed dial / Dock | Skip in v0.1 — heavy gesture-driven UX. | |
| Chat | Skip in v0.1 — composite of many lower-level components, defer. | |
| Floating / Shape | Skip / out of scope. | |

---

## 7. The pilot — Button

Concrete plan to validate the whole approach on one component. **Do this before extending to anything else.**

### 7.1 Why Button

- Already exercised by `lib/first_mob_beam/home_screen.ex:20` via the `nav_button/2` helper. Replacing it is risk-free.
- Touches **every** subsystem we care about: props, theming (colour + size + radius), event registration, accessibility id.
- Has the most variant explosion (14 × 14 = 196 in Mishka), so the collapse strategy gets stress-tested.
- Native button is a fully-fleshed-out Mob widget — no missing-primitive surprises.

### 7.2 File layout

```
first_mob_beam/
├── lib/
│   └── first_mob_beam/
│       ├── components/
│       │   └── mishka/
│       │       └── button.ex   ← new, the pilot
│       └── home_screen.ex      ← swap nav_button/2 for Mishka.Mob.Button.button/1
```

Once validated, this same file is what the future `mix mishka.mob.gen.component button` task will generate. The module name (`Mishka.Mob.Button`) is a placeholder — see §9 for naming discussion.

### 7.3 Acceptance criteria for the pilot

1. ✅ A button with `color: :primary, variant: :default` renders correctly on Android (Samsung A55).
2. ✅ Tapping fires a `{:tap, tag}` to the screen and `handle_info/2` handles it.
3. ✅ Changing `Mob.Theme.set/1` at runtime re-tints the button without a relaunch.
4. ✅ At least 3 variants render distinctly (`:default`, `:outline`, `:subtle`).
5. ✅ At least 5 colours map sensibly (`:primary`, `:secondary`, `:success`, `:danger`, `:warning`).
6. ✅ Size + rounded combinations render at the expected scale (`:extra_small`–`:extra_large`).
7. ✅ `full_width: true` causes the button to fill the parent's width.
8. ✅ A passing unit test that `Mishka.Mob.Button.button/1` returns a `%{type: :button, props: %{...}, children: []}` map (no need to render — just assert the shape).
9. ✅ Documented limitations: gradients fall back to flat, no shadow, no ping animation, no icon position (deferred to v0.2 once we add `<Image>` composition).

### 7.4 Test harness

For headless testing, no device needed:

```elixir
# test/mishka/mob/button_test.exs
defmodule Mishka.Mob.ButtonTest do
  use ExUnit.Case, async: true

  test "primary/default produces the expected node map" do
    out = Mishka.Mob.Button.button(label: "Save", color: :primary, on_tap: {self(), :save})

    assert out.type == :button
    assert out.props.text == "Save"
    assert out.props.background == :primary
    assert out.props.text_color == :on_primary
    assert out.props.on_tap == {self(), :save}
  end

  test "outline collapses to transparent fill + border" do
    out = Mishka.Mob.Button.button(label: "Cancel", variant: :outline, color: :danger, on_tap: {self(), :cancel})
    assert out.props.background == 0x00000000
    assert out.props.border_color == :error
    assert out.props.text_color == :error
  end

  test "size maps both text_size and padding" do
    out = Mishka.Mob.Button.button(label: "x", size: :small, on_tap: {self(), :x})
    assert out.props.text_size == :sm
    assert out.props.padding == :space_sm
  end
end
```

### 7.5 Where to wire it on-device

Replace this in `home_screen.ex:20`:

```elixir
{nav_button("Text Input", :open_text)}
```

with:

```elixir
{Mishka.Mob.Button.button(label: "Text Input", on_tap: {self(), :open_text},
                          color: :primary, variant: :default, size: :large, full_width: true)}
```

Then `mix mob.deploy --android` and verify on the phone.

---

## 8. The generator track (Phase 1.5)

Once Button is validated by hand, the next milestone is regenerating it via a Mob-aware mix task.

### 8.1 Design

```
deps/mishka_chelekom/
├── priv/components/
│   ├── button.exs           ← shared config (variants/colors/sizes)
│   ├── button.eex           ← existing — emits HEEx for the web track
│   └── button.mob.eex       ← new — emits Mob node maps
└── lib/mix/tasks/
    ├── mishka.ui.gen.component.ex      ← existing (web)
    └── mishka.mob.gen.component.ex     ← new (mob)
```

The `button.mob.eex` template would look approximately like:

```elixir
defmodule <%= @module %> do
  @moduledoc "Mob-native port of Chelekom button."

  def <%= @component_prefix %>button(opts) do
    %{
      type: :button,
      props: Map.merge(
        %{
          text:          Keyword.fetch!(opts, :label),
          on_tap:        Keyword.fetch!(opts, :on_tap),
          text_size:     mob_text_size(Keyword.get(opts, :size, :large)),
          padding:       mob_padding(Keyword.get(opts, :size, :large)),
          corner_radius: mob_radius(Keyword.get(opts, :rounded, :large)),
          fill_width:    Keyword.get(opts, :full_width, false)
        },
        mob_colors(Keyword.get(opts, :variant, :default),
                   Keyword.get(opts, :color, :base))
      ),
      children: []
    }
  end

  <%= for {variant, color, props} <- emit_color_variants(@variants, @colors) do %>
  defp mob_colors(<%= inspect(variant) %>, <%= inspect(color) %>), do: <%= inspect(props) %>
  <% end %>
  defp mob_colors(_, _), do: %{background: :primary, text_color: :on_primary}

  <%= for {size, atom} <- @sizes |> Enum.map(&{&1, size_atom(&1)}) do %>
  defp mob_text_size(<%= inspect(size_atom(size)) %>), do: <%= inspect(atom) %>
  <% end %>

  # ... etc
end
```

The same `.exs` config drives both tracks. **The user picks colours/variants/sizes once, and gets matching web + mob components.**

### 8.2 Mix task surface

```bash
mix mishka.mob.gen.component button \
    --variant default,outline,subtle \
    --color primary,secondary,success,danger,warning \
    --size small,medium,large \
    --module-prefix MyApp.Mob
```

Writes to `lib/<app>/components/mob/button.ex` (mirroring the web track's `lib/<app>_web/components/button.ex`).

### 8.3 What's reusable from the existing generator

- ✅ `.exs` config files — unchanged
- ✅ Igniter integration, file I/O, prompt-for-confirmation
- ✅ Variant/colour/size enumeration logic
- ❌ EEx templates — must be rewritten per component
- ❌ Tailwind class generation helpers — useless here
- ❌ JS hook copying — useless here
- ✅ Module naming, prefix handling

---

## 9. Naming + namespacing decision needed

Three viable options, ranked by how I'd recommend them.

| Option | Package name | Module pattern | Pros | Cons |
|---|---|---|---|---|
| **A. Sibling library** | `mishka_chelekom_mob` | `MyApp.Mob.Components.Button` | Cleanest. Web users don't pull mobile templates. Mob users don't pull JS hooks. | Two repos / hex packages to maintain. |
| **B. Same library, second mix task** | `mishka_chelekom` | `MyApp.Mob.Components.Button` via `mix mishka.mob.gen.component` | One repo, shared `.exs` config, atomic releases. | Web-only users see Mob-related code (small overhead). |
| **C. Bundled in Mob itself** | (lives in `mob`) | `Mob.Components.Mishka.Button` | Easiest for Mob users to discover. | Couples release cycles. The Mob author would have to vendor Mishka templates. Not what they asked for. |

**Recommendation: B for v0.1, possibly A for v1.0.** Same library, second mix task — that keeps the `.exs` configs as the single source of truth (the whole point of the generator). Split into a sibling package only if/when the install footprint becomes a real complaint.

---

## 10. Open questions to clarify with the Mob author before we ship

These all surfaced during the audit. Worth a Discord/issue thread before locking the API:

1. **Will `%Mob.Theme{}` ever get `:success`, `:warning`, `:info` as first-class tokens?**  
   Without them, our success/warning/info colours bypass theming. (Filed as a feature request candidate.)
2. **Roadmap for `<Shadow>` / shadow props on `<Box>` / `<Button>`?**  
   Chelekom has `variant: "shadow"`. Today we silently collapse it.
3. **Roadmap for gradients?**  
   Chelekom has `default_gradient`, `outline_gradient`, `inverted_gradient`. Today we collapse all three to their flat equivalents.
4. **Roadmap for `<Checkbox>` / `<Radio>` native widgets?**  
   Today these aren't in `priv/tags/{ios,android}.txt`. Composing via `<Box>` works but loses platform-native a11y.
5. **Floating/popover/tooltip primitive?**  
   Web's `<.dropdown>`, `<.popover>`, `<.tooltip>` all need a floating overlay. Native APIs exist (iOS `.popover`, Android `Popup`); is exposing them on the roadmap?
6. **`<Sheet>` for modal/drawer?**  
   iOS has `.sheet()`, Android has `ModalBottomSheet`. Today modal/drawer require an in-flow `<Box>` overlay. A first-class sheet widget would unlock cleaner ports.
7. **Animation primitives?**  
   Chelekom relies on `JS.transition` for show/hide animations. Mob has no animation API today, just hard cuts. What's the plan?
8. **Accessibility props beyond `accessibility_id`?**  
   For an ARIA-rich library like Mishka, are `accessibility_label`, `accessibility_role`, `accessibility_hint` planned? SwiftUI and Compose both have rich a11y APIs.
9. **What does the Mob author want the Mishka package name + module namespace to look like?** (See §9.)
10. **Compatibility commitment** — Mob is on 0.6.x with "Early development" tag. What's the minimum Mob version we should target, and what's the Mob author's compat policy across 0.x bumps?

---

## 11. Maturity flags + risks

Things to be honest about with users.

| Risk | Severity | Mitigation |
|---|---|---|
| Mob is 0.6.x, breaking changes possible | High | Pin Mob version range tightly per Mishka release. Add CI matrix across Mob 0.6.18, 0.7.x, … |
| Custom native widget contract may evolve | Medium | We're not using it in v0.1 — no exposure. |
| Event model has two parallel APIs today (`{:tap, tag}` vs `Mob.Event.Address`) | Low | Generated code uses the legacy form (what every example uses). Migrate when the new model is stabilised. |
| Mob's iOS support requires Xcode 26 (Liquid Glass) | Medium for users | Document. Mostly a Mob-side issue. |
| Android x86_64 OTP not shipped → Intel Mac users can't emulate | High for Intel Mac users | Already filed as upstream issue (see `INTEL_MAC_ISSUE.md` draft). Workaround: physical phone. |
| Mishka's existing component set assumes Tailwind 4 is on the host project | N/A for Mob track | Mob track doesn't need Tailwind at all. |
| Visual fidelity gap (gradients, shadows, hovers, animations) | High vs web users' expectations | Document clearly. Generated code emits `@moduledoc` notes about each collapse. |
| No JS hooks port | Medium | 8 hooks affect ~10 components. Most fall into Phase 3 (skip in v0.1). |

---

## 12. Roadmap

### Phase 0 — done before any code lands
- [x] Both libraries audited (this document)
- [ ] §9 naming decision agreed with Mob author + Mishka team
- [ ] §10 open questions answered (at least the blocking ones: theme tokens, sheet, animations)

### Phase 1 — pilot (~1 week)
- [ ] Hand-port Button as `Mishka.Mob.Button` (see §7)
- [ ] Replace `nav_button/2` in `home_screen.ex` with the new function
- [ ] Verify on device
- [ ] Write the test (§7.4)
- [ ] Document the visual deltas

### Phase 1.5 — generator (~1 week)
- [ ] Build `mix mishka.mob.gen.component` (see §8)
- [ ] Author `button.mob.eex` from the hand-port
- [ ] Regenerate Button via the task; verify byte-identical (or near-) to hand-port
- [ ] Add a second component (Card) to validate the template path generalises

### Phase 2 — clean-port catalog (~3–4 weeks)
- [ ] Port the 30 Phase 1 components from §6.1
- [ ] Test each on iOS sim + Android device
- [ ] Publish docs

### Phase 3 — composition catalog (~4–6 weeks)
- [ ] Port Phase 2 components from §6.2 (Alert, Modal, Drawer, Toast, Tabs, …)
- [ ] Build `Mishka.Mob.Form` helper for form-binding (§3.3, §6.2)
- [ ] Document modal/drawer's lack of native sheets

### Phase 4 — fill in or skip (~ongoing)
- [ ] Re-evaluate Phase 3 components from §6.3 as Mob ships new primitives (sheet, popover, animations)
- [ ] Skip the ones that don't fit mobile

---

## 13. Appendix — the three forms of "the same button" in Mob

Reference for templates/generator authors. Pick one consistent form for generated code.

### A. Raw map
```elixir
%{type: :button, props: %{text: "Save", on_tap: {self(), :save}, background: :primary}, children: []}
```

### B. `Mob.UI` constructor
```elixir
Mob.UI.button(text: "Save", on_tap: {self(), :save}, background: :primary)
```

### C. `~MOB` sigil
```elixir
~MOB(<Button text="Save" on_tap={{self(), :save}} background={:primary} />)
```

**Recommendation for generated code**: use **form A** (raw map). Reasons:
- Zero parsing overhead at function call
- Easier to inspect / pattern-match in tests
- Doesn't pull `Mob.UI`'s prop allow-list (which silently drops unknown keys)
- The sigil is for human-authored screens; generated code can skip it

---

## 14. Appendix — index of source files inspected

### Mob
- `deps/mob/mix.exs` — version, deps
- `deps/mob/lib/mob/theme.ex` — theme struct + tokens
- `deps/mob/lib/mob/renderer.ex` — token resolution, event registration (lines 156–473)
- `deps/mob/lib/mob/sigil.ex` — `~MOB` DSL
- `deps/mob/lib/mob/screen.ex` — screen GenServer lifecycle
- `deps/mob/lib/mob/socket.ex` — assigns + nav API
- `deps/mob/lib/mob/component.ex` — custom native component contract
- `deps/mob/lib/mob/ui.ex` — constructor functions
- `deps/mob/lib/mob/list.ex` — data-driven list expansion
- `deps/mob/priv/tags/ios.txt` + `android.txt` — built-in widget allow-list
- `deps/mob/CHANGELOG.md` — v0.6.11–0.6.18 release notes
- `deps/mob/README.md` — "Early development" status

### Mishka Chelekom
- `mishka_chelekom/mix.exs` — package, deps, version
- `mishka_chelekom/priv/components/*.exs` — 74 component configs
- `mishka_chelekom/priv/components/*.eex` — 74 HEEx templates
- `mishka_chelekom/lib/mix/tasks/mishka.ui.gen.component.ex` — generator
- `mishka_chelekom/lib/mishka_chelekom/config.ex` — runtime config
- `mishka_chelekom/usage-rules.md` — LLM integration rules
- `mishka_chelekom/MCP.md` — MCP server design

### Reference usage
- `mishka/lib/mishka_web/components/button.ex` — production-generated Chelekom button (~2000 lines), grounds §4.1
- `first_mob_beam/lib/first_mob_beam/home_screen.ex` — current Mob screen using built-in `<Button>`, grounds §7

### External docs
- https://hexdocs.pm/mob/theming.html
- https://hexdocs.pm/mob_dev/0.5.11/readme.html
- https://github.com/GenericJam/mob/blob/master/lib/mob/theme.ex
- https://hex.pm/packages/mishka_chelekom
- https://mishka.tools/chelekom/docs

---

*Document v1. Generated 2026-05-23. Author: Arian (arian@alijani.dev).*
*Open for review — mark up freely, every recommendation in §5–§9 is a proposal, not a commitment.*
