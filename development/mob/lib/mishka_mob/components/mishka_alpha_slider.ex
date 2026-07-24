defmodule MishkaMob.Components.MishkaAlphaSlider do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Alpha Slider** — pick an
  opacity, 0–100, over a real transparency checkerboard.

  ## The checkerboard is honest

  The web version lays a `transparent → color` gradient over a checkerboard
  background image. Here both are drawn on `Mob.UI.canvas/1`: the checkerboard
  as alternating squares, then the base colour over it as a run of bands whose
  `:opacity` climbs left to right. Because the canvas composites for real, the
  squares genuinely show through the translucent end of the track — the strip is
  not a picture of transparency, it *is* transparency.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | number | `100` | Current opacity, 0–100. |
  | `color` | hex string | `"#000000"` | The base colour the track fades in. |
  | `width` / `height` | number | `300` / `16` | Track size in logical units. |
  | `show_value` | boolean | `false` | Render a `60%` readout. |
  | `label` | string | `nil` | Caption above the track. |
  | `on_change` | event tag (atom) | — | `{:change, tag, float}` while dragging. |

  Not ported: `on_commit`, `step`/`large_step`, `name`/`form`/`id` — see
  `MishkaMob.Components.MishkaSlider` for why.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event}

  @width 300
  @height 16
  @band 4
  @check 8

  @doc "Composite expander (`<MishkaAlphaSlider />`). Delegates to `alpha_slider/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: alpha_slider(props)

  @doc """
  The alpha slider.

      alpha_slider(value: @alpha, color: "#3b82f6", on_change: :alpha)
  """
  @spec alpha_slider(map() | keyword()) :: map()
  def alpha_slider(props \\ %{}) do
    props = Map.new(props)
    alpha = Color.clamp(Map.get(props, :value, 100), 0, 100)
    width = Map.get(props, :width, @width)
    height = Map.get(props, :height, @height)
    rgb = base_rgb(Map.get(props, :color, "#000000"))

    strip = Mob.UI.canvas(width: width, height: height, draw: track(width, height, rgb, alpha))

    control =
      ~MOB(<Slider min={0} max={100} value={alpha} />)
      |> put(:on_change, Event.handler(Map.get(props, :on_change)))

    head = header(props, alpha)

    ~MOB"""
    <Column fill_width={true}>
      {head}
      {strip}
      {control}
    </Column>
    """
  end

  @doc """
  Draw ops for the track: checkerboard, then the colour fading in over it, then
  the position marker.

      iex> ops = MishkaMob.Components.MishkaAlphaSlider.track(32, 16, {255, 0, 0}, 50)
      iex> Enum.any?(ops, &(Map.get(&1, :opacity) == 0.0))
      true
  """
  @spec track(number(), number(), {integer(), integer(), integer()}, number()) :: [map()]
  def track(width, height, rgb, alpha) do
    checkerboard(width, height) ++ fade(width, height, rgb) ++ marker(width, height, alpha)
  end

  defp checkerboard(width, height) do
    for row <- 0..max(trunc(ceil(height / @check)) - 1, 0),
        col <- 0..max(trunc(ceil(width / @check)) - 1, 0) do
      shade = if rem(row + col, 2) == 0, do: 0xFF_FF_FF_FF, else: 0xFF_D1_D5_DB

      Mob.Canvas.rect(col * @check, row * @check, @check, @check, color: shade, fill: true)
    end
  end

  defp fade(width, height, rgb) do
    color = Color.argb(rgb)

    0
    |> Stream.iterate(&(&1 + @band))
    |> Stream.take_while(&(&1 < width))
    |> Enum.map(fn x ->
      Mob.Canvas.rect(x, 0, @band + 1, height,
        color: color,
        fill: true,
        opacity: fraction(x, width, @band)
      )
    end)
  end

  # See MishkaHueSlider.fraction/2 — bands sit at their left edge, so the span
  # the edges cover is one band short of the full width. Without this the
  # colour end of the track never reaches full opacity.
  defp fraction(x, width, band) do
    span = width - band

    if span > 0, do: min(x / span, 1.0), else: 0.0
  end

  defp marker(width, height, alpha) do
    x = Color.clamp(alpha / 100 * width, 2, width - 2)

    [
      Mob.Canvas.line(x, 0, x, height, color: 0xFF_FF_FF_FF, width: 3),
      Mob.Canvas.line(x, 0, x, height, color: 0xFF_11_18_27, width: 1)
    ]
  end

  defp base_rgb(color) do
    case Color.parse(color) do
      {:ok, rgb} -> rgb
      :error -> {0, 0, 0}
    end
  end

  defp header(props, alpha) do
    label = Map.get(props, :label)
    readout = if truthy?(Map.get(props, :show_value, false)), do: "#{round(alpha)}%"

    cond do
      is_binary(label) and readout -> row(label, readout)
      is_binary(label) -> ~MOB(<Text text={label} text_size={:sm} text_color={:on_surface} />)
      readout -> ~MOB(<Text text={readout} text_size={:sm} text_color={:muted} />)
      true -> nil
    end
  end

  defp row(label, readout) do
    ~MOB"""
    <Row fill_width={true}>
      <Text text={label} text_size={:sm} text_color={:on_surface} />
      <Spacer weight={1} />
      <Text text={readout} text_size={:sm} text_color={:muted} />
    </Row>
    """
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
