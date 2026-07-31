defmodule MishkaMob.Components.MishkaSlider do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Slider** — a draggable value
  along a range, wrapping Mob's native `Slider` widget.

  ## Stepping is snapped by the widget

  `step` becomes Compose's `steps` (see `steps/3`), so the native control snaps
  itself. It used to be snapped by the screen instead, which is why a stepped
  slider jumped: the screen snapped the value and wrote it back, and the bridge
  pulled the thumb to the snap point while the finger was still down.

      <MishkaSlider value={@volume} min={0} max={100} step={5} on_change={:volume} />

  `snap/2` is still here for a screen that clamps to rules of its own — the
  widget can only snap to an even division of the range.

  ## Range, and vertical

  Pass `values` (a two-element list) instead of `value` for two thumbs. The pair
  comes back as one `"lo,hi"` string, because the change channel carries a single
  number otherwise — `parse_range/1` decodes it, and `resolve/3` applies the
  minimum gap and the push-or-stop collision rule. Both are pure functions, so
  they behave the same on every platform.

  `orientation={:vertical}` turns the control a quarter turn; `length` sets how
  long the track is, since a rotated slider cannot inherit a width.

  > #### Range and vertical are Android-only for now {: .warning}
  >
  > SwiftUI ships neither a range slider nor a vertical one, so both had to be
  > built — and they were built in the Android bridge, which lives in this repo.
  > The iOS renderer is in the `mob` dependency and cannot be changed from here.
  > On iOS a `values` slider falls back to a single thumb and `orientation` is
  > ignored. See `development/mob/IOS_TODO.md` for what the iOS side needs.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number | `min` | Current value. The widget is controlled — the screen owns it. |
  | `min` | number | `0` | Lower bound. |
  | `max` | number | `100` | Upper bound. |
  | `values` | `[lo, hi]` | `nil` | Two thumbs. Overrides `value`. Android only. |
  | `orientation` | `:horizontal` `:vertical` | `:horizontal` | Android only. |
  | `length` | number | `160` | Track length when vertical. |
  | `label` | string | `nil` | Caption above the track. |
  | `show_value` | boolean | `false` | Render a readout beside the label. |
  | `value_text` | string | `nil` | Overrides the readout (default is the rounded value). |
  | `color` | color token / ARGB int | platform default | Thumb and active track. |
  | `on_change` | event tag (atom) | — | Sent as `{:change, tag, float}` while dragging. |

  `min`/`max` are always sent explicitly: the bridge defaults `max` to `1.0`,
  not the `100` Chelekom users expect.

  ## What is not ported, and why

    * `values` (multi-thumb range), `orientation: "vertical"` and
      `thumb_collision` / `thumb_labels` — the native widget is a single
      horizontal thumb; faking a range would mean rebuilding the control.
    * `on_commit` — the bridge exposes no release/keyup event, only continuous
      change.
    * `large_step`, `min_steps_between_values` — keyboard affordances.
    * `format` / `locale` — number formatting is the caller's job via
      `value_text`.
    * `name` / `form` / `id` — HTML form plumbing and DOM anchoring.

  **`disabled` is deliberately absent.** The Compose slider updates its own
  thumb position on drag *before* consulting the handler, so omitting the
  handler (the trick that makes `MishkaSwitch` inert) would still let the thumb
  move — it would simply snap back on the next render. A control that looks
  draggable but silently reverts is worse than no control, so a slider that
  should not be touched is better left out of the tree or replaced by
  `MishkaMob.Components.MishkaMeter`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaSlider />`). Delegates to `slider/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: slider(props)

  @doc """
  The slider node. Accepts a map or keyword list.

      slider(value: 40, on_change: :volume)
      slider(value: 3, min: 1, max: 5, label: "Rating", show_value: true)
  """
  @spec slider(map() | keyword()) :: map()
  def slider(props \\ %{}) do
    props = Map.new(props)
    min = Map.get(props, :min, 0)
    max = Map.get(props, :max, 100)
    value = Map.get(props, :value, min)

    track =
      ~MOB(<Slider min={min} max={max} value={value} />)
      |> put_prop(:color, Map.get(props, :color))
      |> put_prop(:steps, steps(Map.get(props, :step), min, max))
      |> put_prop(:values, range_values(props))
      |> put_prop(:orientation, orientation(props))
      |> put_prop(:length, Map.get(props, :length))
      |> put_prop(:on_change, Event.handler(Map.get(props, :on_change)))

    case header(props, value) do
      nil ->
        track

      head ->
        ~MOB"""
        <Column fill_width={true}>
          {head}
          <Spacer size={4} />
          {track}
        </Column>
        """
    end
  end

  @doc """
  Clamp a dragged range so the thumbs keep `min_gap` between them.

  `:push` carries the other thumb along; `:stop` holds the dragged one at the
  boundary. `moved` says which thumb the finger has — the other is the one that
  may be pushed.

      iex> alias MishkaMob.Components.MishkaSlider
      ...> MishkaSlider.resolve({40, 45}, :lo, min_gap: 10, collision: :push, min: 0, max: 100)
      {40, 50}

      iex> alias MishkaMob.Components.MishkaSlider
      ...> MishkaSlider.resolve({40, 45}, :lo, min_gap: 10, collision: :stop, min: 0, max: 100)
      {35, 45}
  """
  @spec resolve({number(), number()}, :lo | :hi, keyword()) :: {number(), number()}
  def resolve({lo, hi}, moved, opts \\ []) do
    gap = Keyword.get(opts, :min_gap, 0)
    min = Keyword.get(opts, :min, 0)
    max = Keyword.get(opts, :max, 100)
    collision = Keyword.get(opts, :collision, :push)

    lo = clamp(lo, min, max)
    hi = clamp(hi, min, max)

    cond do
      hi - lo >= gap -> {lo, hi}
      collision == :push and moved == :lo -> push_up(lo, gap, min, max)
      collision == :push -> push_down(hi, gap, min, max)
      moved == :lo -> {clamp(hi - gap, min, max), hi}
      true -> {lo, clamp(lo + gap, min, max)}
    end
  end

  defp push_up(lo, gap, min, max) do
    if lo + gap > max, do: {clamp(max - gap, min, max), max}, else: {lo, lo + gap}
  end

  defp push_down(hi, gap, min, max) do
    if hi - gap < min, do: {min, clamp(min + gap, min, max)}, else: {hi - gap, hi}
  end

  @doc """
  Parse the `"lo,hi"` string a range slider reports back.

      iex> MishkaMob.Components.MishkaSlider.parse_range("12.0,30.5")
      {12.0, 30.5}

      iex> MishkaMob.Components.MishkaSlider.parse_range("nonsense")
      :error
  """
  @spec parse_range(String.t()) :: {float(), float()} | :error
  def parse_range(reported) when is_binary(reported) do
    with [a, b] <- String.split(reported, ",", parts: 2),
         {lo, _} <- Float.parse(a),
         {hi, _} <- Float.parse(b) do
      {lo, hi}
    else
      _ -> :error
    end
  end

  def parse_range(_reported), do: :error

  defp range_values(props) do
    case Map.get(props, :values) do
      [lo, hi | _] when is_number(lo) and is_number(hi) -> [lo, hi]
      _ -> nil
    end
  end

  defp orientation(props) do
    case Map.get(props, :orientation) do
      :vertical -> "vertical"
      "vertical" -> "vertical"
      _ -> nil
    end
  end

  @doc """
  How many discrete positions sit BETWEEN the endpoints — which is what Compose's
  `steps` counts, not how many stops there are.

      iex> alias MishkaMob.Components.MishkaSlider
      ...> {MishkaSlider.steps(1, 1, 5), MishkaSlider.steps(5, 0, 100), MishkaSlider.steps(nil, 0, 1)}
      {3, 19, 0}

  Zero means continuous, which is what a missing, zero or negative `step` gives.
  """
  @spec steps(number() | nil, number(), number()) :: non_neg_integer()
  def steps(step, min, max) when is_number(step) and step > 0 and max > min do
    Kernel.max(round((max - min) / step) - 1, 0)
  end

  def steps(_step, _min, _max), do: 0

  @doc """
  Snap a raw slider value to the nearest `step`, clamped into `[min, max]`.

  Options: `:step` (required to have any effect), `:min` (default `0`),
  `:max` (default `100`).

      iex> MishkaMob.Components.MishkaSlider.snap(42.7, step: 5)
      45
      iex> MishkaMob.Components.MishkaSlider.snap(42.7, step: 1)
      43
      iex> MishkaMob.Components.MishkaSlider.snap(999.0, step: 5)
      100
      iex> MishkaMob.Components.MishkaSlider.snap(42.7, [])
      42.7
  """
  @spec snap(number(), keyword()) :: number()
  def snap(value, opts \\ []) do
    min = Keyword.get(opts, :min, 0)
    max = Keyword.get(opts, :max, 100)

    case Keyword.get(opts, :step) do
      step when is_number(step) and step > 0 ->
        # Snap relative to `min`, so a range like 5..25 steps 5,10,15… rather
        # than landing on multiples of the step that fall outside the range.
        clamp(round((value - min) / step) * step + min, min, max)

      _ ->
        clamp(value, min, max)
    end
  end

  defp clamp(value, min, _max) when value < min, do: min
  defp clamp(value, _min, max) when value > max, do: max
  defp clamp(value, _min, _max), do: value

  defp header(props, value) do
    label = Map.get(props, :label)
    readout = readout(props, value)

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

  defp readout(props, value) do
    cond do
      not truthy?(Map.get(props, :show_value, false)) -> nil
      is_binary(Map.get(props, :value_text)) -> Map.get(props, :value_text)
      true -> value |> round() |> Integer.to_string()
    end
  end

  defp put_prop(node, _key, nil), do: node
  defp put_prop(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
