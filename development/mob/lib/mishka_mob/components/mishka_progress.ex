defmodule MishkaMob.Components.MishkaProgress do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Progress** — a determinate or
  indeterminate progress bar, optionally labelled and showing its own readout.

  Wraps Mob's native `Progress` widget (a Compose `LinearProgressIndicator` /
  SwiftUI `ProgressView`), so the indeterminate state animates on its own and
  the bar follows platform metrics.

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
  | `color` | color token / ARGB int | platform default | Indicator colour. |

  The web component's `id` and the `*_class` attrs are not ported: they exist to
  anchor `aria-labelledby` and to style DOM parts.
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaProgress />`). Delegates to `progress/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: progress(props)

  @doc """
  The progress node. Accepts a map or keyword list.

      progress(value: 40)
      progress(value: 3, max: 5, label: "Uploading", show_value: true)
      progress()                      # indeterminate
  """
  @spec progress(map() | keyword()) :: map()
  def progress(props \\ %{}) do
    props = Map.new(props)
    fraction = fraction(props)

    bar =
      ~MOB(<Progress />)
      |> put_prop(:value, fraction)
      |> put_prop(:color, Map.get(props, :color))

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
  """
  @spec fraction(map() | keyword()) :: float() | nil
  def fraction(props) do
    props = Map.new(props)

    case Map.get(props, :value) do
      nil ->
        nil

      value when is_number(value) ->
        min = Map.get(props, :min, 0)
        max = Map.get(props, :max, 100)
        span = max - min

        # A zero-width range has no meaningful position; report empty rather
        # than dividing by zero.
        if span == 0, do: 0.0, else: clamp((value - min) / span)
    end
  end

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
