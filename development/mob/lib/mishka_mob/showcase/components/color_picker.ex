defmodule MishkaMob.Showcase.Components.ColorPicker do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaColorPicker`."
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event, MishkaColorPicker, MishkaHueSlider}
  alias MishkaMob.Showcase.Example

  # The picker's own default width. The handler converts a touch x back to a
  # hue against the SAME number the strip was drawn at — hard-coding 260 beside
  # a 280-wide strip put the finger and the marker up to 8% apart, which is the
  # exact failure hue_at/2 exists to prevent.
  @picker_width 280

  @impl true
  def entry do
    %{
      slug: :color_picker,
      name: "Color Picker",
      category: "Color",
      order: 4,
      description: "A saturation/value field over a hue slider."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:hue, 210)
    |> Mob.Socket.assign(:sat, 76)
    |> Mob.Socket.assign(:val, 96)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "The field is two runs of bands",
        description:
          "Vertical strips step saturation, horizontal strips lay black over them — the same " <>
            "two gradients the web picker stacks, expressed as draw ops.",
        code: ~S"""
        <MishkaColorPicker
          hue={@hue}
          saturation={@sat}
          value={@val}
          on_hue={:hue}
          on_area={:area}
        />

        # Both controls ARE the drawing, so what arrives is a touch POSITION.
        # Matching on {:change, …} compiles, renders perfectly and never fires.
        # One gesture on the square carries BOTH axes, which is why on_area
        # replaced the old on_saturation / on_value pair.
        def handle_info({:drag, :area, %{x: x, y: y}}, socket) do
          {sat, val} = MishkaColorPicker.sv_at(x, y)
          {:noreply, socket |> assign(:sat, sat) |> assign(:val, val)}
        end

        # Pass the SAME width the strip was drawn at, or the finger and the
        # marker drift apart.
        def handle_info({:drag, :hue, %{x: x}}, socket) do
          {:noreply, assign(socket, :hue, MishkaHueSlider.hue_at(x, 280))}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaColorPicker
              hue={@hue}
              saturation={@sat}
              value={@val}
              on_hue={:hue}
              on_area={:area}
              id="picker"
            />
            <Spacer size={10} />
            {preview(@hue, @sat, @val)}
            <Spacer size={10} />
            {axis("Saturation", @sat, :sat)}
            {axis("Brightness", @val, :val)}
          </Column>
          """
        end
      },
      %Example{
        title: "Reading the value back",
        description: "hex/1 and hsv/1 turn the assigns into whatever the caller stores.",
        code: ~S"""
        MishkaColorPicker.hex(%{hue: 0, saturation: 100, value: 100})
        #=> "#ff0000"
        """,
        render: fn assigns ->
          ~MOB"""
          <Text
            text={"Current: " <> Color.hsv_to_hex(@hue, @sat, @val)}
            text_size={:base}
            text_color={:on_surface}
          />
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "hue", type: "0–360", default: "210", description: "Current hue."},
      %{name: "saturation", type: "0–100", default: "76", description: "Current saturation."},
      %{name: "value", type: "0–100", default: "96", description: "Current brightness."},
      %{name: "width / height", type: "number", default: "280 / 170", description: "Area size."},
      %{
        name: "on_area",
        type: "event tag",
        default: "—",
        description:
          "{:drag, tag, %{x:, y:}} from the square — ONE event for both axes. " <>
            "Convert with sv_at/4."
      },
      %{
        name: "on_hue",
        type: "event tag",
        default: "—",
        description: "{:drag, tag, %{x:}} from the strip. Convert with hue_at/2."
      },
      %{
        name: "sv_at/4 · hue_at/2 · hsv/1 · hex/1",
        type: "helpers",
        default: "—",
        description: "Turn a touch position into values, and read the colour back out."
      }
    ]
  end

  @impl true
  # One gesture, two numbers: a drag on the square sets saturation AND
  # brightness, which is why they arrive together as :area rather than as two
  # events. The sliders below are this PAGE's, not the picker's — they exist to
  # show each axis can also be driven on its own.
  def handle_change(:area, %{x: x, y: y}, socket) do
    {sat, val} = MishkaColorPicker.sv_at(x, y)

    socket |> Mob.Socket.assign(:sat, sat) |> Mob.Socket.assign(:val, val)
  end

  def handle_change(:hue, %{x: x}, socket),
    do: Mob.Socket.assign(socket, :hue, MishkaHueSlider.hue_at(x, @picker_width))

  def handle_change(:hue, value, socket), do: Mob.Socket.assign(socket, :hue, value)
  def handle_change(:sat, value, socket), do: Mob.Socket.assign(socket, :sat, value)
  def handle_change(:val, value, socket), do: Mob.Socket.assign(socket, :val, value)
  def handle_change(_tag, _value, socket), do: socket

  # The swatch and hex live here, not in the picker: the component is the square
  # and the strip, and what you DO with the colour is the screen's business.
  defp preview(h, s, v) do
    rgb = Color.hsv_to_rgb(h, s, v)
    fill = Color.argb(rgb)
    ink = Color.ink_on(rgb)

    ~MOB"""
    <Box fill_width={true} background={fill} corner_radius={:radius_md} padding={:space_md}>
      <Row fill_width={true}>
        <Text text={Color.hex(rgb)} text_size={:base} text_color={ink} font_weight={:semibold} />
        <Spacer weight={1} />
        <Text text={"H #{round(h)}  S #{round(s)}  B #{round(v)}"} text_size={:sm} text_color={ink} />
      </Row>
    </Box>
    """
  end

  # Lives here, not in the picker: a labelled slider per axis is one way to drive
  # the component, not part of what it is. The square already sets both at once.
  defp axis(label, value, tag) do
    slider =
      ~MOB(<Slider min={0} max={100} value={value} />)
      |> put(:on_change, Event.handler(tag))

    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Text text={label} text_size={:sm} text_color={:on_surface} />
        <Spacer weight={1} />
        <Text text={"#{round(value)}%"} text_size={:sm} text_color={:muted} />
      </Row>
      {slider}
    </Column>
    """
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  @impl true
  def card_preview do
    Mob.UI.canvas(
      width: 120,
      height: 74,
      draw: MishkaColorPicker.area(120, 74, 210, 76, 96)
    )
  end
end
