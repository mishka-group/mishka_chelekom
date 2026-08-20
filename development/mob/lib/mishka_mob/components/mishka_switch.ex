defmodule MishkaMob.Components.MishkaSwitch do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Switch** — an on/off control.

  Unlike the Drawer and Accordion, this one is a thin wrapper by default: Mob
  ships a real `Toggle` widget (a Compose `Switch` / SwiftUI `Toggle`), so the
  port maps the Chelekom API onto it rather than rebuilding a track and thumb out
  of boxes. That means the control animates, reports accessibility state, and
  follows the platform's own switch metrics for free.

  `render={:box}` is the way out when "the platform's own metrics" is the
  problem — see "Two renderings" below.

  ## Controlled — on Android

  On Android `Toggle` is controlled: it renders whatever `checked` says and
  reports intent through `on_change`, so nothing moves until the screen writes
  the new value back. The value arrives as `{:change, tag, boolean}`:

      <MishkaSwitch label="Wi-Fi" checked={@wifi?} on_change={:wifi_changed} />

      def handle_info({:change, :wifi_changed, on?}, socket) do
        {:noreply, Mob.Socket.assign(socket, :wifi?, on?)}
      end

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `checked` | boolean | `false` | The on state. |
  | `label` | string | `nil` | Leading label; the switch sits at the trailing edge. |
  | `on_change` | event tag (atom) | — | Sent as `{:change, tag, boolean}`. Omit for a read-only switch. Native rendering only. |
  | `color` | color token / ARGB int | platform default | Thumb colour when on. |
  | `track_color` | **ARGB int** | platform default | Track colour when on. |
  | `disabled` | boolean | `false` | Wires no handler, so the control cannot move. |
  | `render` | `:toggle` `:box` | `:toggle` | Which primitive draws the control — the native `Toggle`, or a `Box` track carrying a `Box` thumb. See "Two renderings". |

  > #### Colour is Android-only, and `track_color` takes no tokens {: .warning}
  >
  > `color` and `track_color` reach Compose's `SwitchDefaults.colors`, so on
  > Android they tint the thumb and the track independently — set one and you get
  > a two-tone switch, which is why both exist.
  >
  > `track_color` must be a raw **ARGB integer**. Mob's renderer resolves colour
  > *tokens* only for the props in its `@color_props` whitelist, and
  > `track_color` is not one of them — pass `:primary` and it arrives as an
  > unparseable string and is silently ignored. `color` is whitelisted and takes
  > either.
  >
  > **iOS ignores both.** Its `MobToggle` is a bare `Toggle(label, isOn:)` with
  > no `.tint(...)`, so the control always paints in the system accent.
  >
  > All three sentences are about `render={:toggle}`. A drawn switch paints its
  > own boxes, so both colours land on a `background` — token or integer, the
  > same on both platforms.

  > #### Three iOS gaps, all in the dependency {: .warning}
  >
  > None of these is this component's doing, and none can be fixed from here.
  >
  > 1. **The switch is uncontrolled.** iOS `MobToggle` seeds a `@State` once in
  >    its initialiser and binds the control to that local copy, so the thumb
  >    moves on touch whatever the screen decides. A screen that rejects or
  >    overrides the change will not be reflected until the view is rebuilt.
  > 2. **`disabled` does not disable.** It works by omitting the handler, which
  >    is enough for a controlled widget — but an uncontrolled one flips anyway
  >    and simply reports nowhere. A disabled switch is inert on Android and
  >    freely movable on iOS.
  > 3. **Colour is ignored**, as above.
  >
  > The label used to be a third: the bridge decodes text from `props["text"]`,
  > so a `label` prop was dropped and the Toggle came up blank. This component
  > now builds the label row itself, so that one is closed.
  >
  > `render={:box}` sidesteps all three, because a drawn switch is boxes: it
  > paints exactly what `checked` says, a `Box` with no `on_tap` is genuinely
  > inert, and a `background` is a `background` everywhere. That is a
  > consequence of the mode, not its purpose — see what it costs, below.

  ## Two renderings

  `render={:toggle}` (the default) is the native widget, unchanged.

  `render={:box}` draws the control: a track `Box` carrying a thumb `Box`.

      <MishkaSwitch
        render={:box}
        checked={@wifi?}
        on_toggle={:wifi_tapped}
        track_width={46}
        track_height={28}
        track_radius={14}
        thumb_size={22}
      />

  ### Why the drawn mode had to exist

  Mob's `<Toggle>` is Compose's Material `Switch`, and material3 fixes its
  metrics in `SwitchTokens`: `TrackWidth` 52dp, `TrackHeight` 32dp,
  `SelectedHandleSize` 24dp, `UnselectedHandleSize` 16dp, `TrackOutlineWidth`
  2dp. `SwitchDefaults` parameterises **colours and nothing else**. There is no
  prop at any layer of this stack — not here, not in the bridge, not in Compose —
  that makes a Material `Switch` 46x28 with a 14dp radius, a 22dp thumb in both
  states, and no outline. The geometry is not a default that a caller can
  override; it is baked into the widget.

  So a design that specifies its own switch metrics has, until now, had exactly
  one option: hand-build the control at the call site, once per screen. The drawn
  mode moves that construction in here, where it can be got right once.

  ### Why `:toggle` is still the default

  Two reasons, and neither is inertia:

    1. **No existing caller's pixels may move.** Every `<MishkaSwitch>` written
       so far renders a Material `Switch`, at Material's metrics, with Material's
       ripple and animation. The drawn mode is a different-looking control, so it
       is opt-in.
    2. **The native widget is better when its metrics are acceptable.** It
       animates, it ripples, and it carries the platform's switch semantics. Not
       one of those survives the trip to boxes.

  ### What the drawn mode loses

  A caller choosing pixel-exactness should know the bill:

    * **No ripple / press state.** The track is a `Box` with an `on_tap`. It
      paints the same the instant before and the instant after a finger lands.
    * **No thumb animation.** Mob has no animation primitive — a node tree is a
      still frame. The thumb is at one offset in this render and the other offset
      in the next, so it **snaps**; it does not slide.
    * **No platform accessibility semantics.** A native `Switch` carries a role,
      an on/off state and a toggle action into TalkBack and VoiceOver. A pair of
      boxes carries none of that: the drawn switch announces as an unlabelled
      tappable region. Pair it with a `label` — the label row is a real `Text`
      and is read out — and prefer `:toggle` anywhere accessibility outranks
      geometry.
    * **One thumb size.** Material grows its handle from 16dp to 24dp on the way
      on. The drawn thumb is `thumb_size` in both states, which is what the
      designs asking for this mode have wanted, but it is a difference.

  ### Drawn-mode props

  All are ignored by `render={:toggle}`.

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `track_width` | number | `52` | Track width, dp/pt. |
  | `track_height` | number | `32` | Track height, dp/pt. |
  | `track_radius` | radius token / number | `track_height / 2` | Track rounding. The default is a pill, whatever the height. |
  | `thumb_size` | number | `24` | Thumb edge, in both states. |
  | `thumb_radius` | radius token / number | `thumb_size / 2` | Thumb rounding. The default is a circle. |
  | `thumb_inset` | number | `(track_height - thumb_size) / 2` | Gap between the thumb and the track's leading/trailing edge. The default is the gap that is already above and below the thumb, i.e. a symmetric capsule. |
  | `track_on_color` | color token / ARGB int | `track_color`, else `:primary` | Track when on. |
  | `track_off_color` | color token / ARGB int | `:border` | Track when off. |
  | `thumb_on_color` | color token / ARGB int | `color`, else `:on_primary` | Thumb when on. |
  | `thumb_off_color` | color token / ARGB int | `:on_primary` | Thumb when off. `:on_primary` is the theme's "mark on a filled control" colour — white in the default theme, which is what a switch thumb is. |
  | `disabled_track_color` | color token / ARGB int | the enabled track colour | Track while `disabled`. |
  | `disabled_thumb_color` | color token / ARGB int | the enabled thumb colour | Thumb while `disabled`. |
  | `thumb_shadow` | shadow string | `nil` | `"dx dy blur spread #AARRGGBB"`, read on any node. The one way back to the elevation Material's handle has. |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, tag}`. |

  The two disabled colours default to the enabled ones on purpose: a disabled
  native switch paints as though it were live (the bridge does not forward
  Compose's `enabled` flag), and the drawn mode matches that rather than
  inventing a greyed look nobody asked for. Set them to grey it.

  ### `on_toggle` is a tap, not a value

  A `Box` does not know it is a switch, so it reports `{:tap, tag}` with no
  payload. The screen owns `checked` and flips it:

      def handle_info({:tap, :wifi_tapped}, socket) do
        {:noreply, Mob.Socket.assign(socket, :wifi?, !socket.assigns.wifi?)}
      end

  `on_change` is a `Toggle` prop and is **not** read in drawn mode — a tap
  carries no boolean to send. `on_toggle` is likewise not read by the native
  rendering. `disabled` drops whichever handler applies, which is what makes
  either control inert.

  ### The geometry, and why the thumb moves by `offset_x`

  The track `Box` carries `align={:center}`, so it stacks its children and
  centres them. That does two jobs at once: the thumb is vertically centred for
  free at any pair of sizes, and its horizontal position becomes a single signed
  number — `thumb_offset/4` — mirrored between the two states.

  `offset_x` shifts paint without disturbing layout, which is the property that
  matters here: the thumb moves inside a track whose width never changes.

  **Padding is not an option for the inset.** Mob applies padding *before* width,
  so a `width={46} padding={3}` track measures 52 — the caller's exact geometry
  would be silently inflated by the very prop meant to place the thumb inside it.
  Negative padding is worse: it throws on the bridge and takes the activity down
  with it. Offsets take floats, positive or negative, and change no measurement.

  ## What is deliberately not ported

  The web attrs that exist only to make an `<input>` submit inside an HTML form
  — `name`, `value`, `unchecked_value`, `form`, `required` — have no meaning on
  a phone: there is no form post, and the screen already holds the value. `id`
  is dropped too (it exists to anchor `aria-*` relationships in the DOM).

  `readonly` and `disabled` collapse into one thing here: both simply omit the
  handler. Note the platform still paints an *enabled-looking* switch — Mob's
  `Toggle` bridge does not forward Compose's `enabled` flag — so a disabled
  switch looks normal but cannot be moved. Pair it with a muted label when that
  distinction matters, or, in drawn mode, with `disabled_track_color` /
  `disabled_thumb_color`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaSwitch />`). Delegates to `switch/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: switch(props)

  @doc """
  The switch node. Accepts a map or keyword list.

      switch(label: "Wi-Fi", checked: true, on_change: :wifi)
      switch(render: :box, track_width: 46, track_height: 28, thumb_size: 22)
  """
  @spec switch(map() | keyword()) :: map()
  def switch(props \\ %{}) do
    props = Map.new(props)
    checked = truthy?(Map.get(props, :checked, false))
    # `||` rather than a Map.get default, so an explicit `render: nil` still
    # lands on the two-clause control/3 instead of raising.
    render = Map.get(props, :render) || :toggle

    props
    |> control(render, checked)
    |> labelled(Map.get(props, :label))
  end

  @doc """
  How far a drawn thumb sits from the track's **centre**, in dp/pt — negative
  when off, positive when on.

  The track centres its children, so one signed number places the thumb in
  either state:

      travel = track_width / 2 - inset - thumb_size / 2

  The design this mode was built for — a 46x28 track, a 22pt thumb, a 3pt inset
  — travels 9pt either side of centre:

      iex> MishkaMob.Components.MishkaSwitch.thumb_offset(true, 46, 22, 3)
      9.0

      iex> MishkaMob.Components.MishkaSwitch.thumb_offset(false, 46, 22, 3)
      -9.0

  which puts the off thumb across 3..25 and the on thumb across 21..43 — the
  same 3pt gap at each end. The caller states the track and the inset; the
  arithmetic is not theirs to redo.
  """
  @spec thumb_offset(
          checked :: boolean(),
          track_width :: number(),
          thumb_size :: number(),
          inset :: number()
        ) :: float()
  def thumb_offset(checked, track_width, thumb_size, inset) do
    travel = track_width / 2 - inset - thumb_size / 2

    if checked, do: travel, else: -travel
  end

  # The native widget: unchanged, and the only thing an existing caller reaches.
  defp control(props, :toggle, checked) do
    ~MOB(<Toggle value={checked} />)
    |> put_prop(:color, Map.get(props, :color))
    |> put_prop(:track_color, Map.get(props, :track_color))
    |> put_prop(:on_change, handler(props))
  end

  # The drawn control. `fill_width={false}` on both boxes because an iOS Box
  # fills its parent's width by default: the track has to hug so it can sit at a
  # label row's trailing edge, and the thumb has to hug so centring means
  # anything. `align={:center}` is what stacks and centres the thumb.
  defp control(props, :box, checked) do
    disabled? = truthy?(Map.get(props, :disabled, false))
    width = Map.get(props, :track_width, 52)
    height = Map.get(props, :track_height, 32)
    size = Map.get(props, :thumb_size, 24)
    radius = Map.get(props, :track_radius, height / 2)
    inset = Map.get(props, :thumb_inset, (height - size) / 2)
    fill = track_fill(props, checked, disabled?)

    thumb =
      props
      |> thumb_node(checked, disabled?, size)
      |> put_prop(:offset_x, thumb_offset(checked, width, size, inset))

    ~MOB"""
    <Box
      width={width}
      height={height}
      corner_radius={radius}
      background={fill}
      align={:center}
      fill_width={false}
    >
      {thumb}
    </Box>
    """
    |> put_prop(:on_tap, tap_handler(props, disabled?))
  end

  defp thumb_node(props, checked, disabled?, size) do
    radius = Map.get(props, :thumb_radius, size / 2)
    fill = thumb_fill(props, checked, disabled?)

    ~MOB"""
    <Box width={size} height={size} corner_radius={radius} background={fill} fill_width={false} />
    """
    |> put_prop(:shadow, Map.get(props, :thumb_shadow))
  end

  # `color` / `track_color` keep meaning "the on colour" here, so a caller who
  # already tinted a native switch gets the same tint from the drawn one.
  defp track_fill(props, checked, disabled?) do
    enabled =
      if checked do
        Map.get(props, :track_on_color) || Map.get(props, :track_color) || :primary
      else
        Map.get(props, :track_off_color) || :border
      end

    if disabled?, do: Map.get(props, :disabled_track_color) || enabled, else: enabled
  end

  defp thumb_fill(props, checked, disabled?) do
    enabled =
      if checked do
        Map.get(props, :thumb_on_color) || Map.get(props, :color) || :on_primary
      else
        Map.get(props, :thumb_off_color) || :on_primary
      end

    if disabled?, do: Map.get(props, :disabled_thumb_color) || enabled, else: enabled
  end

  # The label row is built HERE rather than handed to the native Toggle as a
  # `label` prop, because that prop never arrives on iOS: the bridge decodes a
  # node's text from `props["text"]`, so `label` was dropped and the Toggle came
  # up with an empty string. Building the row in Elixir renders the same
  # arrangement on both platforms and makes the label an ordinary styleable Text.
  #
  # `<Spacer weight={1} />` is portable despite weight being Compose-only: on
  # iOS a Spacer with no size is a flexible `Spacer()`, which pushes the toggle
  # to the trailing edge just the same.
  defp labelled(toggle, label) when is_binary(label) do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <Text text={label} text_color={:on_surface} />
      <Spacer weight={1} />
      {toggle}
    </Row>
    """
  end

  defp labelled(toggle, _label), do: toggle

  # A disabled switch keeps its handler off, which is what makes it inert:
  # `Toggle` is controlled, so with nothing listening the thumb cannot move.
  # Everything else is widened to {pid, tag} — see MishkaMob.Components.Event.
  defp handler(props) do
    if truthy?(Map.get(props, :disabled, false)) do
      nil
    else
      Event.handler(Map.get(props, :on_change))
    end
  end

  # A drawn track reports a TAP: a Box has no idea what it stands for, so there
  # is no boolean to carry. Disabled drops the handler, and a Box with no
  # `on_tap` is inert on BOTH platforms — unlike the native Toggle on iOS.
  defp tap_handler(_props, true), do: nil
  defp tap_handler(props, _disabled?), do: Event.handler(Map.get(props, :on_toggle))

  defp put_prop(node, _key, nil), do: node
  defp put_prop(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
