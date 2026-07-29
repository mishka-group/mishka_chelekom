defmodule MishkaMob.Showcase.Components.AngleSlider do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaAngleSlider`."
  use MishkaMob.Showcase

  import Mob.Sigil

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
          "Ring, arc and handle are drawn on a canvas — and dragged directly. Touch " <>
            "anywhere on the ring and the knob follows your finger.",
        code: ~S"""
        <MishkaAngleSlider value={@angle} on_change={:angle} />

        # The ring is the control, so the event carries a touch POSITION.
        # :dead means the finger was near the centre, where no angle was meant.
        def handle_info({:drag, :angle, %{x: x, y: y}}, socket) do
          case MishkaAngleSlider.angle_at(x, y) do
            :dead -> {:noreply, socket}
            deg -> {:noreply, Mob.Socket.assign(socket, :angle, deg)}
          end
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAngleSlider value={@angle} label="Direction" on_change={:angle} />
          </Column>
          """
        end
      },
      %Example{
        title: "Snapped to 15°",
        description: "Snapping happens where the value settles — in the screen.",
        code: ~S"""
        # The ring is the control, so the event carries a touch POSITION.
        # angle_at/3 inverts it; :dead means the finger was near the centre,
        # where no angle was meant.
        def handle_info({:drag, :angle, %{x: x, y: y}}, socket) do
          case MishkaAngleSlider.angle_at(x, y, 130) do
            :dead -> {:noreply, socket}
            deg -> {:noreply, assign(socket, :angle, MishkaSlider.snap(deg, step: 15, max: 360))}
          end
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAngleSlider value={@snapped} size={130} color={0xFF16A34A} on_change={:snapped} />
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
        name: "text_color",
        type: "token / ARGB",
        default: ":on_surface",
        description: "Colour of the centre reading."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description:
          "{:drag, tag, %{x:, y:, phase:}} — a touch POSITION, not a number. " <>
            "Matching on {:change, …} compiles and never fires."
      },
      %{
        name: "angle_at/3 · follow/2 · point_on_dial/4",
        type: "helpers",
        default: "—",
        description:
          "Position to angle (:dead near the centre), seam-safe follow, and where " <>
            "an angle lands on the circle — 0° is up, not right."
      }
    ]
  end

  @impl true
  # The ring IS the control now, so what arrives is a touch position in canvas
  # units. angle_at/3 returns :dead near the centre, where no angle was meant —
  # ignoring it is what stops a fingertip in the middle spinning the dial.
  def handle_change(:angle, %{x: x, y: y}, socket) do
    next = MishkaAngleSlider.follow(socket.assigns.angle, MishkaAngleSlider.angle_at(x, y, 160))

    Mob.Socket.assign(socket, :angle, next)
  end

  def handle_change(:angle, value, socket) when is_number(value),
    do: Mob.Socket.assign(socket, :angle, value)

  def handle_change(:snapped, %{x: x, y: y}, socket) do
    next = MishkaAngleSlider.follow(socket.assigns.snapped, MishkaAngleSlider.angle_at(x, y, 130))

    Mob.Socket.assign(socket, :snapped, MishkaSlider.snap(next, step: 15, max: 360))
  end

  def handle_change(:snapped, value, socket) when is_number(value) do
    Mob.Socket.assign(socket, :snapped, MishkaSlider.snap(value, step: 15, min: 0, max: 360))
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
