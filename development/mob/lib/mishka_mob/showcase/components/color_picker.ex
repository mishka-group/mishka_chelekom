defmodule MishkaMob.Showcase.Components.ColorPicker do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaColorPicker`."
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{Color, MishkaColorPicker}
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
          on_saturation={:sat}
          on_value={:val}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaColorPicker
              hue={@hue}
              saturation={@sat}
              value={@val}
              on_hue={:hue}
              on_saturation={:sat}
              on_value={:val}
            />
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
  def handle_change(:hue, value, socket), do: Mob.Socket.assign(socket, :hue, value)
  def handle_change(:sat, value, socket), do: Mob.Socket.assign(socket, :sat, value)
  def handle_change(:val, value, socket), do: Mob.Socket.assign(socket, :val, value)
  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    Mob.UI.canvas(
      width: 120,
      height: 74,
      draw: MishkaColorPicker.area(120, 74, 210, 76, 96)
    )
  end
end
