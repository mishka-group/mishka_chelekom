defmodule MishkaMob.Components.MishkaProgress do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Progress** — a determinate or
  indeterminate progress bar, optionally labelled and showing its own readout.

  Wraps Mob's native `Progress` widget (a Compose `LinearProgressIndicator` /
  SwiftUI `ProgressView`), so the indeterminate state animates on its own and
  the bar follows platform metrics. `render={:box}` draws the bar out of `Box`
  nodes instead, for a design that specifies its own — see "Material's bar is
  Material's bar" below.

  ## Range translation

  Chelekom expresses `value` inside `[min, max]`; the native widget wants a
  fraction in `0.0..1.0`. `progress/1` does that conversion and **clamps**, so a
  value outside the range renders a full or empty bar rather than a bar that
  overshoots its track. A degenerate range (`max == min`) reads as `0.0` instead
  of raising `ArithmeticError`.

  Omitting `value` (or passing `nil`) gives the **indeterminate** bar — the
  widget renders its own looping animation, and the readout is suppressed
  because there is no percentage to show.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number or `nil` | `nil` | Current value in `[min, max]`. `nil` = indeterminate. |
  | `min` | number | `0` | Lower bound. |
  | `max` | number | `100` | Upper bound. |
  | `label` | string | `nil` | Caption above the bar. |
  | `show_value` | boolean | `false` | Render a readout beside the label. |
  | `value_text` | string | `nil` | Overrides the readout (default is a rounded percentage). |
  | `color` | color token / ARGB int | platform default (`:primary`) | Indicator colour. In `render={:box}` it fills the bar. |
  | `height` | number | platform default (~4); `4` under `render={:box}` | Bar thickness. |
  | `render` | `:progress` `:box` | `:progress` | Which primitive draws the bar — Material's indicator, or a track `Box` with a fill `Box` in it. See "Material's bar is Material's bar" below. |
  | `width` | number | `nil` | Bar width in dp/pt. `nil` fills the parent, as before. Honoured in both modes on Android; on iOS only by `:box` (see "Platform note"). |
  | `track_color` | color token / ARGB int | `:surface_raised` | The groove behind the fill. **`:box` only** — the native indicator draws its own track and exposes no prop for it. `:transparent` gives a trackless bar. |
  | `corner_radius` | number / radius token | `nil` (square) | Rounds track and fill alike. **`:box` only.** |
  | `id` | string | `nil` | Test tag. `:box` additionally tags the fill `<id>-fill` — see "A drawn bar has nothing to assert on but its geometry". |

  The web component's `*_class` attrs are not ported: they exist to style DOM
  parts. `id` is ported, but as a test tag rather than an `aria-labelledby`
  anchor.

  ## Material's bar is Material's bar, and `render={:box}` is the way out

  `<Progress>` is not a neutral "draw a bar" node. The Android bridge maps it to
  Material3's `LinearProgressIndicator`, and that widget:

    * **fills whatever width it is handed.** The bridge appends `.fillMaxWidth()`
      after the node's own modifier chain, so on Android a `width` does still
      constrain it — but on iOS a progress node reads neither `width` nor
      `height` (`MobRootView.swift` builds its own `ProgressView` and applies
      only padding and tint), so there it is the parent's full width, always;
    * **draws its own track**, in its own colour. The bridge passes `color` and
      nothing else, so the groove stays `ProgressIndicatorDefaults`'
      `linearTrackColor` — a trackless bar is simply not expressible;
    * **carries Material's geometry, and Material's version of it.** The 4dp
      thickness and butt caps this repo draws today are `material3` 1.2.0's
      (`compose-bom:2024.02.00`); 1.3 redraws the same widget with rounded caps,
      a gap and a stop indicator. A design pinned to specific pixels is pinned
      to a dependency's defaults, and those are not ours to hold still.

  So a design that specifies "a 46 x 6 bar, 3dp corners, no track, filled
  `#FF7A00`" cannot be drawn with it at any combination of `color` and `height`,
  because the geometry lives in the primitive rather than in the values. The
  usual consequence is that screens hand-roll the bar out of two weighted Boxes
  and stop calling this component at all.

  `render={:box}` is that hand-rolled bar, with the arithmetic in one place: a
  track `Box` carrying `width`/`height`/`corner_radius`/`track_color`, and a fill
  `Box` inside it carrying the same height and radius, `color`, and a width that
  is the fraction of the track. A `Box` stacks its children and has no opinions
  about metrics, so what the props say is what is drawn.

  ### Why `:progress` is still the default

  Not inertia. Two reasons:

    1. **It is the only bar that animates.** Mob has no animation primitive — a
       drawn control changes state between renders, it does not tween — so the
       indeterminate bar has no drawn form. `render={:box}` with no `value`
       draws an empty track and nothing moves; keep `:progress` for "we don't
       know how long this will take".
    2. **The two are not pixel-identical, and the difference is not zero.** The
       drawn bar inherits none of Material's metrics — not its track colour, not
       whatever caps and gaps the Material version of the day draws — and it is
       square-cornered until told otherwise. That is a change of appearance, and
       no existing caller's pixels may move — so it is opt-in.

  ### The fill's width, and the weight that must never be zero

  A drawn bar takes one of two shapes, because only one of them can know how
  wide the fill is:

    * **given a `width`**, the fill is arithmetic — `width * fraction` — and
      both boxes carry both dimensions, which is the one `Box` shape iOS sizes
      on both axes (`IOS_TODO.md` item 1). No `weight` is emitted at all;
    * **without one**, the track fills its parent, whose width is not known
      here, so the fill claims its share with `weight` — `weight: fraction`
      against a remainder `Spacer` of `weight: 1 - fraction`, inside a `Row`
      that fills the track.

  Prefer the first where the design allows it: it is portable, and it never goes
  near `weight`, which Compose refuses at zero (`"invalid weight 0.0; must be
  greater than zero"` — a crash, not a warning).

  ### 0% and 100% are ordinary values

  A season fully watched is 100%; a book not started is 0%. Both are drawn, and
  both are the edges where a naive implementation breaks:

    * **at 0% the fill node is omitted entirely**, in both shapes. Not for
      tidiness — a zero `weight` throws, and a zero-width `Box` is *worse* than
      useless on iOS, where `MobBox` sizes on both axes only when
      `fixedWidth > 0` and otherwise falls through to `.frame(maxWidth:
      .infinity)`: a 0%-wide fill would paint the bar **full**. An absent node
      draws nothing on both platforms, which is the one thing 0% means.
      `MishkaMob.Components.MishkaSemiCircleProgress` omits its indicator arc at
      a zero sweep for the same class of reason;
    * **at 100% the fill takes the whole track** — `width * 1.0` in the fixed
      shape; in the fluid one, `weight: 1.0` and *no* remainder `Spacer`, since
      that Spacer's weight would be the zero that throws.

  ## A drawn bar has nothing to assert on but its geometry

  The native bar carries its fraction in a `value` prop, so a test can read it.
  A drawn bar carries nothing: the fraction *is* the fill's width. `id` is
  therefore not decoration here — it tags the track, and `fill_id/1` tags the
  fill `<id>-fill`, so a device test can read both frames (`Mob.Test`'s
  `element_frames`) and check the one thing a drawn bar can get wrong. At 0%
  there is no `<id>-fill` frame at all, which is itself the assertion.

  ## Platform note

  On **Android** both modes are correct.

  On **iOS**, drawn bars are portable only in their fixed-width shape:

    * a progress node reads neither `width` nor `height` (`MobRootView.swift`'s
      `.progress` case builds its own `ProgressView` and applies only padding
      and tint), so under `render={:progress}` both props are Android-only;
    * a **fixed-width** drawn bar hits `MobBox`'s `fixedWidth > 0` branch, which
      is the only one that sizes both axes — track and fill are both correct;
    * a **fill-width** drawn bar is Android-only: `weight` is read nowhere in
      the iOS renderer (`IOS_TODO.md` item 13), so the fill has no width of its
      own and falls through to `.frame(maxWidth: .infinity)` while the remainder
      is an unsized, flexible `Spacer()` — the two split the track on SwiftUI's
      terms, identically at every fraction. Give the bar a `width` on iOS until
      item 13 lands.

  The `<Spacer size={height} />` inside a fill-width drawn track is the same iOS
  workaround `mishka_separator` and `mishka_skeleton` carry: `MobBox` drops a
  Box's `height` unless the Box also has a `width` (item 1), so a childless
  full-width bar measures 0pt tall and draws nothing. On Android it is an
  invisible `height`-square child that the background covers.
  """

  import Mob.Sigil

  # Drawn-mode defaults. The thickness matches Material's own linear indicator,
  # so `render={:box}` lands on the same 4dp bar the native widget would have
  # drawn; the fill matches the `:primary` the renderer injects into every
  # `progress` node (`Mob.Renderer`'s @component_defaults); and the track is the
  # one `MishkaSemiCircleProgress` already paints its groove with, so the two
  # gauges agree.
  @drawn_height 4
  @drawn_fill :primary
  @drawn_track :surface_raised

  @doc "Composite expander (`<MishkaProgress />`). Delegates to `progress/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: progress(props)

  @doc """
  The progress node. Accepts a map or keyword list.

      progress(value: 40)
      progress(value: 3, max: 5, label: "Uploading", show_value: true)
      progress()                      # indeterminate
      progress(value: 40, render: :box, width: 46, height: 6, corner_radius: 3)
  """
  @spec progress(map() | keyword()) :: map()
  def progress(props \\ %{}) do
    props = Map.new(props)
    fraction = fraction(props)
    bar = bar(props, fraction, mode(props))

    case header(props, fraction) do
      nil ->
        bar

      head ->
        ~MOB"""
        <Column fill_width={true}>
          {head}
          <Spacer size={6} />
          {bar}
        </Column>
        """
    end
  end

  @doc """
  The `0.0..1.0` fraction a set of props resolves to, or `nil` when
  indeterminate. Exposed because it is the whole of the range logic.

      iex> MishkaMob.Components.MishkaProgress.fraction(%{value: 50})
      0.5
      iex> MishkaMob.Components.MishkaProgress.fraction(%{value: 3, max: 5})
      0.6
      iex> MishkaMob.Components.MishkaProgress.fraction(%{value: 999})
      1.0
      iex> MishkaMob.Components.MishkaProgress.fraction(%{})
      nil
      iex> MishkaMob.Components.MishkaProgress.fraction(%{value: "72"})
      0.72
  """
  @spec fraction(map() | keyword()) :: float() | nil
  def fraction(props) do
    props = Map.new(props)

    case to_num(Map.get(props, :value)) do
      nil ->
        nil

      value ->
        min = Map.get(props, :min, 0)
        max = Map.get(props, :max, 100)
        span = max - min

        # A zero-width range has no meaningful position; report empty rather
        # than dividing by zero.
        if span == 0, do: 0.0, else: clamp((value - min) / span)
    end
  end

  @doc """
  The test tag on a drawn bar's fill box — the only evidence a `render={:box}`
  bar leaves of its fraction, which is a width rather than a prop.

      iex> MishkaMob.Components.MishkaProgress.fill_id("upload")
      "upload-fill"

  There is no fill node at all at 0%, so the tag is absent there. See
  "0% and 100% are ordinary values".
  """
  @spec fill_id(String.t()) :: String.t()
  def fill_id(id) when is_binary(id), do: id <> "-fill"

  # An explicit `render: nil` lands on `:progress` rather than raising, and the
  # string forms are accepted because an unbraced sigil attr IS a string —
  # `render="box"` is the obvious way to write it, and that exact trap already
  # cost this component a CaseClauseError on `value="72"` (see `to_num/1`).
  # Anything else falls through to the two-clause `bar/3` and raises, which is
  # what a typo should do: a silent fallback to the native bar would show up
  # only as pixels that are subtly wrong.
  defp mode(props) do
    case Map.get(props, :render) do
      nil -> :progress
      "box" -> :box
      "progress" -> :progress
      mode -> mode
    end
  end

  # height is a generic node prop the bridge turns into a Modifier.height, so
  # the native indicator honours it — but only if it is forwarded. It was not,
  # so the one dimension of the bar a caller might reasonably want to change was
  # silently dropped on the way in. `width` is forwarded on the same reasoning:
  # dropping a prop a caller wrote is worse than passing one a platform ignores.
  defp bar(props, fraction, :progress) do
    ~MOB(<Progress />)
    |> put_prop(:value, fraction)
    |> put_prop(:color, Map.get(props, :color))
    |> put_prop(:height, Map.get(props, :height))
    |> put_prop(:width, width(props))
    |> put_prop(:id, Map.get(props, :id))
  end

  # An indeterminate drawn bar is an EMPTY drawn bar: there is no animation
  # primitive to loop with, so `nil` reads as 0.0 rather than pretending. The
  # readout stays suppressed either way — `header/2` still sees the nil.
  defp bar(props, fraction, :box) do
    geometry = %{
      height: Map.get(props, :height, @drawn_height),
      radius: Map.get(props, :corner_radius),
      fill: Map.get(props, :color, @drawn_fill),
      track: Map.get(props, :track_color, @drawn_track),
      id: Map.get(props, :id)
    }

    case width(props) do
      nil -> fluid_bar(fraction || 0.0, geometry)
      width -> fixed_bar(width, fraction || 0.0, geometry)
    end
  end

  # `width` is the one prop this module BRANCHES on, so it is the one worth
  # normalising here: `width="46"` — again, an unbraced attr is a string — would
  # otherwise pick the fluid shape and silently ignore the number the caller
  # wrote. The rest are forwarded as given and coerced by the bridge.
  defp width(props) do
    case Map.get(props, :width) do
      width when is_number(width) ->
        width

      width when is_binary(width) ->
        case Float.parse(width) do
          {parsed, _rest} -> parsed
          :error -> nil
        end

      _other ->
        nil
    end
  end

  # The portable shape: every box carries both dimensions, so iOS's MobBox takes
  # the one branch that sizes both (IOS_TODO 1), and no `weight` is emitted.
  defp fixed_bar(width, fraction, geometry) do
    fill = width * fraction

    ~MOB"""
    <Box width={width} height={geometry.height} background={geometry.track}>
      {fixed_fill(fill, geometry)}
    </Box>
    """
    |> shape(geometry.radius)
    |> tag(geometry.id)
  end

  # Nothing to draw at 0% — and a `width: 0` Box would be read by iOS as "no
  # width", i.e. FULL width. See "0% and 100% are ordinary values".
  defp fixed_fill(width, _geometry) when width <= 0, do: nil

  defp fixed_fill(width, geometry) do
    ~MOB(<Box width={width} height={geometry.height} background={geometry.fill} />)
    |> shape(geometry.radius)
    |> tag(fill_tag(geometry.id))
  end

  # No width to divide here, so the fill claims its share with `weight`. The
  # Spacer is the iOS height workaround, not a design — see "Platform note".
  defp fluid_bar(fraction, geometry) do
    ~MOB"""
    <Box fill_width={true} height={geometry.height} background={geometry.track}>
      <Row fill_width={true}>
        {weighted_fill(fraction, geometry)}
        {remainder(fraction)}
      </Row>
      <Spacer size={geometry.height} />
    </Box>
    """
    |> shape(geometry.radius)
    |> tag(geometry.id)
  end

  # Compose refuses a zero weight — "invalid weight 0.0; must be greater than
  # zero", a crash rather than a warning — so neither child is ever emitted
  # holding one. At 0% the fill goes; at 100% the remainder goes.
  defp weighted_fill(fraction, _geometry) when fraction <= 0, do: nil

  defp weighted_fill(fraction, geometry) do
    ~MOB(<Box height={geometry.height} background={geometry.fill} weight={fraction} />)
    |> shape(geometry.radius)
    |> tag(fill_tag(geometry.id))
  end

  defp remainder(fraction) when fraction >= 1, do: nil
  defp remainder(fraction), do: ~MOB(<Spacer weight={1 - fraction} />)

  defp shape(node, radius), do: put_prop(node, :corner_radius, radius)
  defp tag(node, id), do: put_prop(node, :id, id)

  defp fill_tag(id) when is_binary(id), do: fill_id(id)
  defp fill_tag(_id), do: nil

  # The headless attr is `:any` and parses numeric strings, so `value="72"`
  # reads as 72 rather than raising. That is not a hypothetical: an unbraced
  # sigil attr IS a string, so `<MishkaProgress value="72" />` — the obvious
  # way to write it — used to reach a two-clause case and die with a
  # CaseClauseError. Unparseable input reads as empty, as it does on the web;
  # only a genuinely absent value stays indeterminate.
  defp to_num(nil), do: nil
  defp to_num(value) when is_number(value), do: value

  defp to_num(value) when is_binary(value) do
    case Float.parse(value) do
      {parsed, _rest} -> parsed
      :error -> 0
    end
  end

  defp to_num(_value), do: 0

  defp clamp(fraction) when fraction < 0, do: 0.0
  defp clamp(fraction) when fraction > 1, do: 1.0
  defp clamp(fraction), do: fraction * 1.0

  # Label on the leading edge, readout trailing. Nil when neither is asked for,
  # so a plain bar stays a single node.
  defp header(props, fraction) do
    label = Map.get(props, :label)
    readout = readout(props, fraction)

    cond do
      is_binary(label) and readout -> labelled_row(label, readout)
      is_binary(label) -> ~MOB(<Text text={label} text_size={:sm} text_color={:on_surface} />)
      readout -> ~MOB(<Text text={readout} text_size={:sm} text_color={:muted} />)
      true -> nil
    end
  end

  defp labelled_row(label, readout) do
    ~MOB"""
    <Row fill_width={true}>
      <Text text={label} text_size={:sm} text_color={:on_surface} />
      <Spacer weight={1} />
      <Text text={readout} text_size={:sm} text_color={:muted} />
    </Row>
    """
  end

  # An indeterminate bar has no percentage to report, so the readout is dropped
  # even when show_value is set.
  defp readout(_props, nil), do: nil

  defp readout(props, fraction) do
    cond do
      not truthy?(Map.get(props, :show_value, false)) -> nil
      is_binary(Map.get(props, :value_text)) -> Map.get(props, :value_text)
      true -> "#{round(fraction * 100)}%"
    end
  end

  defp put_prop(node, _key, nil), do: node
  defp put_prop(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
