defmodule MishkaMob.Components.MishkaMeter do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Meter** — a scalar gauge for a
  measurement inside a known range (disk usage, battery level), as distinct from
  a progress bar, which tracks how far a *task* has got.

  ## Why it draws the same bar as Progress

  On the web the two differ mainly in semantics: `role="meter"` versus
  `role="progressbar"`, which is what a screen reader announces. Mob exposes no
  such role, and both are "a proportional fill along a track", so this port
  renders the same native `Progress` widget and shares
  `MishkaMob.Components.MishkaProgress.fraction/1` for the range maths rather
  than duplicating clamping logic that would then drift.

  Drawing the fill by hand — a `Row` of two weighted boxes — was the alternative,
  and it was rejected: `weight` is a Compose concept that Mob's iOS mapping does
  not implement, so the gauge would be proportional on Android and broken on
  iOS. The native widget is proportional on both.

  The real differences the port keeps:

    * `value` is **required** — a meter always reads *something*. A missing value
      renders an empty gauge rather than the animated indeterminate bar, because
      "we don't know how full the disk is" is not a thing a meter says.
    * The default readout is a percentage of the range, matching `aria-valuetext`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number | `min` | The measurement. Clamped into `[min, max]`. |
  | `min` | number | `0` | Lower bound. |
  | `max` | number | `100` | Upper bound. |
  | `label` | string | `nil` | Caption above the gauge. |
  | `show_value` | boolean | `false` | Render a readout beside the label. |
  | `value_text` | string | `nil` | Overrides the readout (default is a rounded percentage). |
  | `color` | color token / ARGB int | platform default | Fill colour. |

  `id` and the `*_class` attrs are not ported — they anchor `aria-*`
  relationships and style DOM parts.
  """

  alias MishkaMob.Components.MishkaProgress

  @doc "Composite expander (`<MishkaMeter />`). Delegates to `meter/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: meter(props)

  @doc """
  The meter node. Accepts a map or keyword list.

      meter(value: 72, label: "Disk", show_value: true)
      meter(value: 3, max: 5, value_text: "3 of 5 bars", show_value: true)
  """
  @spec meter(map() | keyword()) :: map()
  def meter(props \\ %{}) do
    props = Map.new(props)

    # A meter always reads something: an absent value is an empty gauge, never
    # the indeterminate bar Progress would render for the same input.
    props
    |> Map.put(:value, Map.get(props, :value) || Map.get(props, :min, 0))
    |> MishkaProgress.progress()
  end

  @doc """
  The `0.0..1.0` fill ratio for a set of props — the native equivalent of the
  web component's `--chelekom-meter` custom property.

      iex> MishkaMob.Components.MishkaMeter.ratio(%{value: 72})
      0.72
      iex> MishkaMob.Components.MishkaMeter.ratio(%{})
      0.0
  """
  @spec ratio(map() | keyword()) :: float()
  def ratio(props) do
    props
    |> Map.new()
    |> meter_value()
    |> MishkaProgress.fraction()
  end

  defp meter_value(props),
    do: Map.put(props, :value, Map.get(props, :value) || Map.get(props, :min, 0))
end
