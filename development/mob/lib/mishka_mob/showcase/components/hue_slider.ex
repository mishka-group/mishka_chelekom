defmodule MishkaMob.Showcase.Components.HueSlider do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaHueSlider`."
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{Color, MishkaHueSlider}
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :hue_slider,
      name: "Hue Slider",
      category: "Color",
      order: 1,
      description: "Pick a hue, 0–360°, against a rainbow drawn on a canvas."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :hue, 210)

  @impl true
  def examples do
    [
      %Example{
        title: "The spectrum is drawn, not faked",
        description: "150 canvas bands, one per two units of width — a real gradient.",
        code: ~S"""
        <MishkaHueSlider value={@hue} label="Hue" show_value={true} on_change={:hue} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHueSlider value={@hue} label="Hue" show_value={true} on_change={:hue} />
            <Spacer size={12} />
            {swatch(@hue)}
          </Column>
          """
        end
      }
    ]
  end

  defp swatch(hue) do
    rgb = Color.hue_rgb(hue)
    fill = Color.argb(rgb)
    ink = Color.ink_on(rgb)

    ~MOB"""
    <Box fill_width={true} background={fill} corner_radius={:radius_md} padding={:space_md}>
      <Text text={Color.hex(rgb)} text_size={:base} text_color={ink} weight={:semibold} />
    </Box>
    """
  end

  @impl true
  def props do
    [
      %{name: "value", type: "0–360", default: "0", description: "Current hue. Wraps."},
      %{name: "width / height", type: "number", default: "300 / 16", description: "Track size."},
      %{name: "label", type: "string", default: "nil", description: "Caption above the track."},
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a 210° readout."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "{:change, tag, float} while dragging."
      },
      %{
        name: "spectrum/3",
        type: "helper",
        default: "—",
        description: "The draw ops, so the picker can paint the same strip."
      }
    ]
  end

  @impl true
  # The strip IS the control now, so what arrives is a touch position in canvas
  # units, not a number. hue_at/2 is the inverse of the marker, so the colour
  # under the finger is the colour selected.
  def handle_change(:hue, %{x: x}, socket),
    do: Mob.Socket.assign(socket, :hue, MishkaHueSlider.hue_at(x))

  def handle_change(:hue, value, socket) when is_number(value),
    do: Mob.Socket.assign(socket, :hue, value)

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    Mob.UI.canvas(
      width: 120,
      height: 26,
      draw: MishkaHueSlider.spectrum(120, 26, 210)
    )
  end
end
