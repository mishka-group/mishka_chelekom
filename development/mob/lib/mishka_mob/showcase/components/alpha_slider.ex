defmodule MishkaMob.Showcase.Components.AlphaSlider do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaAlphaSlider`."
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaAlphaSlider
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :alpha_slider,
      name: "Alpha Slider",
      category: "Color",
      order: 2,
      description: "Pick an opacity over a checkerboard that really shows through."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :alpha, 60)

  @impl true
  def examples do
    [
      %Example{
        title: "Real transparency",
        description:
          "The canvas composites for real, so the squares show through the translucent end.",
        code: ~S"""
        <MishkaAlphaSlider
          value={@alpha}
          color={"#3b82f6"}
          show_value={true}
          on_change={:alpha}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAlphaSlider
              value={@alpha}
              color={"#3b82f6"}
              label="Opacity"
              show_value={true}
              on_change={:alpha}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Any base colour",
        description: "The track fades in whatever colour you hand it.",
        code: ~S"""
        <MishkaAlphaSlider value={@alpha} color={"#dc2626"} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAlphaSlider value={@alpha} color={"#dc2626"} on_change={:alpha} />
            <Spacer size={8} />
            <MishkaAlphaSlider value={@alpha} color={"#16a34a"} on_change={:alpha} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "0–100", default: "100", description: "Current opacity."},
      %{
        name: "color",
        type: "hex string",
        default: "\"#000000\"",
        description: "Base colour the track fades in."
      },
      %{name: "width / height", type: "number", default: "300 / 16", description: "Track size."},
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a 60% readout."
      },
      %{name: "label", type: "string", default: "nil", description: "Caption above the track."},
      %{name: "on_change", type: "event tag", default: "—", description: "{:change, tag, float}."}
    ]
  end

  @impl true
  # The track IS the control now, so what arrives is a touch position in canvas
  # units, not a number. alpha_at/2 is the inverse of the marker, so the opacity
  # under the finger is the opacity selected.
  def handle_change(:alpha, %{x: x}, socket),
    do: Mob.Socket.assign(socket, :alpha, MishkaAlphaSlider.alpha_at(x))

  def handle_change(:alpha, value, socket) when is_number(value),
    do: Mob.Socket.assign(socket, :alpha, value)

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    Mob.UI.canvas(
      width: 120,
      height: 26,
      draw: MishkaAlphaSlider.track(120, 26, {59, 130, 246}, 60)
    )
  end
end
