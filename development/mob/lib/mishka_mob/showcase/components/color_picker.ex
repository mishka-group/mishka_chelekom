defmodule MishkaMob.Showcase.Components.ColorPicker do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaColorPicker`."
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event, MishkaColorPicker, MishkaHueSlider}
  alias MishkaMob.Showcase.Example

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
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaColorPicker hue={@hue} saturation={@sat} value={@val} on_hue={:hue} on_area={:area} />
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
        name: "show_preview",
        type: "boolean",
        default: "true",
        description: "Swatch + hex under the sliders."
      },
      %{
        name: "on_hue / on_saturation / on_value",
        type: "event tags",
        default: "—",
        description: "Each axis has its own slider — Mob delivers no 2D drag coordinates."
      },
      %{
        name: "hsv/1 · hex/1",
        type: "helpers",
        default: "—",
        description: "Read the colour back out."
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
    do: Mob.Socket.assign(socket, :hue, MishkaHueSlider.hue_at(x, 260))

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
        <Text text={Color.hex(rgb)} text_size={:base} text_color={ink} weight={:semibold} />
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
