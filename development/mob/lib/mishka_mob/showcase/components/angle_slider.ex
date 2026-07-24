defmodule MishkaMob.Showcase.Components.AngleSlider do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaAngleSlider`."
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaAngleSlider, only: [angle_slider: 1]

  alias MishkaMob.Components.{MishkaAngleSlider, MishkaSlider}
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :angle_slider,
      name: "Angle Slider",
      category: "Color",
      order: 3,
      description: "A circular dial for an angle — 0° up, increasing clockwise."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:angle, 45)
    |> Mob.Socket.assign(:snapped, 120)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A real dial",
        description:
          "Ring, arc and handle are drawn on a canvas. The slider turns it, because Mob " <>
            "delivers no pointer coordinates to hit-test the ring with.",
        code: ~S"""
        {angle_slider(value: @angle, on_change: :angle)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {angle_slider(value: @angle, label: "Direction", on_change: :angle)}
          </Column>
          """
        end
      },
      %Example{
        title: "Snapped to 15°",
        description: "Snapping happens where the value settles — in the screen.",
        code: ~S"""
        def handle_change(:angle, raw, socket),
          do: assign(socket, :angle, MishkaSlider.snap(raw, step: 15, max: 360))
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {angle_slider(value: @snapped, size: 130, color: 0xFF16A34A, on_change: :snapped)}
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "0–360", default: "0", description: "Angle in degrees. Wraps."},
      %{name: "size", type: "number", default: "160", description: "Dial diameter."},
      %{
        name: "show_value",
        type: "boolean",
        default: "true",
        description: "Draw the reading in the centre."
      },
      %{name: "color", type: "ARGB int", default: "blue", description: "Arc and handle colour."},
      %{name: "label", type: "string", default: "nil", description: "Caption above the dial."},
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "{:change, tag, float}."
      },
      %{
        name: "point_on_dial/4",
        type: "helper",
        default: "—",
        description: "Where an angle lands on the circle — 0° is up, not right."
      }
    ]
  end

  @impl true
  def handle_change(:angle, value, socket), do: Mob.Socket.assign(socket, :angle, value)

  def handle_change(:snapped, value, socket) do
    snapped = MishkaSlider.snap(value, step: 15, min: 0, max: 360)

    Mob.Socket.assign(socket, :snapped, snapped)
  end

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    Mob.UI.canvas(
      width: 74,
      height: 74,
      draw: MishkaAngleSlider.dial(74, 120, %{show_value: false})
    )
  end
end
