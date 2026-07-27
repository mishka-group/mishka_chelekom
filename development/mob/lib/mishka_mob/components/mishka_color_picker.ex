defmodule MishkaMob.Components.MishkaColorPicker do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Color Picker** — a
  saturation/value area over a hue slider.

  ## How the area is painted

  The web picker stacks two CSS gradients on one div: white→hue left to right,
  then transparent→black top to bottom. Mob has no gradient fill, but a canvas
  can express the same thing as two runs of translucent bands — vertical strips
  stepping saturation, then horizontal strips stepping black over them. The
  result is a genuine saturation/value field, not an approximation of one, and
  it costs about a hundred draw ops.

  ## Why there are sliders under the area

  On the web you *drag inside* the area, because the browser hands the hook
  pointer coordinates. Mob delivers taps and slider values, never coordinates,
  so nothing here can tell where in the square a finger landed. Rather than
  render a square that ignores touches, the area is the **readout** — it shows
  exactly where the current colour sits — and saturation and value get their own
  sliders. Every control drives the same `{h, s, v}`, so the crosshair always
  agrees with the sliders.

  This is the one place the port visibly differs from the web component, and the
  difference is forced by the platform: a 2D drag needs pointer coordinates that
  Mob does not currently deliver to `render/1`.

  ## State

  The picker is controlled and stateless — it renders the `hue`/`saturation`/
  `value` you hand it and reports changes. `hsv/1` and `hex/1` turn its assigns
  into the two representations a caller usually wants.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `hue` | 0–360 | `210` | Current hue. |
  | `saturation` | 0–100 | `76` | Current saturation. |
  | `value` | 0–100 | `96` | Current value/brightness. |
  | `width` / `height` | number | `280` / `170` | Area size in logical units. |
  | `show_preview` | boolean | `true` | Swatch + hex readout under the sliders. |
  | `on_hue` / `on_saturation` / `on_value` | event tags | — | `{:change, tag, float}`. |
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event, MishkaHueSlider}

  @width 280
  @height 170
  @sat_band 4
  @val_band 4

  @doc "Composite expander (`<MishkaColorPicker />`). Delegates to `color_picker/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: color_picker(props)

  @doc """
  The picker.

      color_picker(hue: @hue, saturation: @sat, value: @val,
                   on_hue: :hue, on_saturation: :sat, on_value: :val)
  """
  @spec color_picker(map() | keyword()) :: map()
  def color_picker(props \\ %{}) do
    props = Map.new(props)
    {h, s, v} = hsv(props)
    width = Map.get(props, :width, @width)
    height = Map.get(props, :height, @height)

    area =
      canvas_node(width, height, area(width, height, h, s, v), Map.get(props, :on_area))

    hue_slider =
      MishkaHueSlider.hue_slider(
        value: h,
        width: width,
        on_change: Map.get(props, :on_hue)
      )

    ~MOB"""
    <Column fill_width={true}>
      {area}
      <Spacer size={10} />
      {hue_slider}
      {preview(props, {h, s, v})}
    </Column>
    """
  end

  @doc """
  Draw ops for the saturation/value field at hue `h`, with the crosshair at
  `{s, v}`.

      iex> ops = MishkaMob.Components.MishkaColorPicker.area(40, 40, 0, 50, 50)
      iex> Enum.any?(ops, &(&1.op == :circle))
      true
  """
  @spec area(number(), number(), number(), number(), number()) :: [map()]
  def area(width, height, h, s, v) do
    saturation_bands(width, height, h) ++
      value_bands(width, height) ++ crosshair(width, height, s, v)
  end

  # White on the left, full hue on the right — saturation across x at value 100.
  defp saturation_bands(width, height, h) do
    0
    |> Stream.iterate(&(&1 + @sat_band))
    |> Stream.take_while(&(&1 < width))
    |> Enum.map(fn x ->
      rgb = Color.hsv_to_rgb(h, fraction(x, width, @sat_band) * 100, 100)

      Mob.Canvas.rect(x, 0, @sat_band + 1, height, color: Color.argb(rgb), fill: true)
    end)
  end

  # Transparent at the top down to black at the bottom — value across y.
  defp value_bands(width, height) do
    0
    |> Stream.iterate(&(&1 + @val_band))
    |> Stream.take_while(&(&1 < height))
    |> Enum.map(fn y ->
      Mob.Canvas.rect(0, y, width, @val_band + 1,
        color: 0xFF_00_00_00,
        fill: true,
        opacity: fraction(y, height, @val_band)
      )
    end)
  end

  # See MishkaHueSlider.fraction/2. Without it the right edge of the field
  # stops just short of the pure hue and the bottom never reaches black.
  defp fraction(pos, extent, band) do
    span = extent - band

    if span > 0, do: min(pos / span, 1.0), else: 0.0
  end

  defp crosshair(width, height, s, v) do
    x = Color.clamp(s / 100 * width, 7, width - 7)
    y = Color.clamp((100 - v) / 100 * height, 7, height - 7)

    [
      Mob.Canvas.circle(x, y, 7, color: 0xFF_FF_FF_FF, width: 3),
      Mob.Canvas.circle(x, y, 7, color: 0xFF_11_18_27, width: 1)
    ]
  end

  @doc """
  The `{saturation, value}` a touch at `{x, y}` selects on an area of `w` x `h`.

  Saturation runs left to right, brightness top to bottom — the inverse of what
  the area paints, so the ring lands under the finger.

      iex> MishkaMob.Components.MishkaColorPicker.sv_at(0, 0, 260, 180)
      {0.0, 100.0}

      iex> MishkaMob.Components.MishkaColorPicker.sv_at(260, 180, 260, 180)
      {100.0, 0.0}

      iex> MishkaMob.Components.MishkaColorPicker.sv_at(130, 90, 260, 180)
      {50.0, 50.0}
  """
  @spec sv_at(number(), number(), number(), number()) :: {float(), float()}
  def sv_at(x, y, w \\ @width, h \\ @height) do
    {
      if(w > 0, do: Color.clamp(x, 0, w) / w * 100, else: 0.0),
      if(h > 0, do: 100 - Color.clamp(y, 0, h) / h * 100, else: 0.0)
    }
  end

  # Mob.UI.canvas/1 drops handlers (Map.take of width/height/draw), so the node
  # is built literally — otherwise the area renders perfectly and does nothing.
  defp canvas_node(width, height, ops, tag) do
    props = %{width: width, height: height, draw: ops}
    handler = Event.handler(tag)
    props = if handler, do: Map.put(props, :on_drag, handler), else: props

    %{type: :canvas, props: props, children: []}
  end

  defp preview(props, {h, s, v}) do
    if truthy?(Map.get(props, :show_preview, true)) do
      rgb = Color.hsv_to_rgb(h, s, v)
      fill = Color.argb(rgb)
      ink = Color.ink_on(rgb)

      ~MOB"""
      <Box fill_width={true} background={fill} corner_radius={:radius_md} padding={:space_md}>
        <Row fill_width={true}>
          <Text text={Color.hex(rgb)} text_size={:base} text_color={ink} weight={:semibold} />
          <Spacer weight={1} />
          <Text text={"H #{round(h)}  S #{round(s)}  B #{round(v)}"} text_size={:sm} text_color={ink} />
        </Row>
      </Box>
      """
    end
  end

  @doc """
  The `{h, s, v}` a props map describes, defaulted and clamped.

      iex> MishkaMob.Components.MishkaColorPicker.hsv(%{hue: 400, saturation: 120, value: -5})
      {40.0, 100, 0}
  """
  @spec hsv(map() | keyword()) :: {number(), number(), number()}
  def hsv(props) do
    props = Map.new(props)

    {
      normalize_hue(Map.get(props, :hue, 210)),
      Color.clamp(Map.get(props, :saturation, 76), 0, 100),
      Color.clamp(Map.get(props, :value, 96), 0, 100)
    }
  end

  @doc """
  The hex the picker currently shows.

      iex> MishkaMob.Components.MishkaColorPicker.hex(%{hue: 0, saturation: 100, value: 100})
      "#ff0000"
  """
  @spec hex(map() | keyword()) :: String.t()
  def hex(props) do
    {h, s, v} = hsv(props)

    Color.hsv_to_hex(h, s, v)
  end

  # fmod(360.0, 360.0) is 0.0, so a hue at the top of the range collapsed to the
  # bottom and the strip's marker teleported. Wrap only what is out of range.
  defp normalize_hue(v) when is_number(v) and v >= 0 and v <= 360, do: v * 1.0
  defp normalize_hue(v), do: Color.wrap_hue(v)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
