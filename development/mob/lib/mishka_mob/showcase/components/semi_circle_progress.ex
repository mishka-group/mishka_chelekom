defmodule MishkaMob.Showcase.Components.SemiCircleProgress do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSemiCircleProgress`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  import MishkaMob.Components.MishkaSemiCircleProgress, only: [semi_circle_progress: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :semi_circle_progress,
      name: "Semi Circle Progress",
      category: "Feedback",
      order: 4,
      description: "A half-circle gauge drawn as a real arc on a canvas."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sc_value, 72)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A gauge",
        description:
          "A real 180° arc on Mob.UI.canvas/1, at the web component's own " <>
            "proportions — radius and stroke are ratios of size.",
        code: ~S"""
        <MishkaSemiCircleProgress value={@value} label="Battery" />

        # the gauge is a display, so the buttons are the screen's
        def handle(:up, socket), do: nudge(socket, +15)
        def handle(:down, socket), do: nudge(socket, -15)

        # clamp at the call site — the arc clamps, but a runaway assign means
        # several taps do nothing before the needle moves again
        defp nudge(socket, delta) do
          value = min(max(socket.assigns.value + delta, 0), 100)
          Mob.Socket.assign(socket, :value, value)
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSemiCircleProgress value={@sc_value} label="BATTERY" />
            <Spacer size={14} />
            <Row fill_width={true}>
              <Button
                text="− 15"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :sc_down}}
              />
              <Spacer size={8} />
              <Button
                text="+ 15"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :sc_up}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Custom readout",
        description: "value_text replaces the percentage.",
        code: ~S"""
        <MishkaSemiCircleProgress value={3} max={5} value_text="3 / 5" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSemiCircleProgress
              value={3}
              max={5}
              value_text="3 / 5"
              label="STEPS"
              color={0xFF10B981}
            />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "value",
        type: "number or numeric string",
        default: "min",
        description: "The measurement. \"72\" reads as 72, matching the web attr."
      },
      %{name: "min / max", type: "number", default: "0 / 100", description: "The range."},
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Caption under the gauge (the web aria-label)."
      },
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "Overrides the readout."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Indicator colour."
      },
      %{
        name: "size",
        type: "number",
        default: "140",
        description: "Gauge width in dp; the height follows at 0.54 ×, as the web viewBox does."
      },
      %{
        name: "thickness",
        type: "number",
        default: "0.06 × size",
        description: "Arc stroke width — the web's stroke-width: 12 in a w-48 box."
      }
    ]
  end

  @impl true
  def handle(:sc_up, socket), do: nudge(socket, +15)
  def handle(:sc_down, socket), do: nudge(socket, -15)
  def handle(_tag, socket), do: socket

  # Clamp here, not just in the component. The arc clamps its own fraction, so
  # an unbounded assign looks harmless — but it keeps counting past 100, and then
  # several taps of "− 15" do nothing at all before the needle moves again. The
  # progress and meter demos both shipped with exactly this bug.
  defp nudge(socket, delta) do
    value = min(max(socket.assigns.sc_value + delta, 0), 100)
    Mob.Socket.assign(socket, :sc_value, value)
  end

  # The card shows the real component. It used to be a stack of boxes imitating a
  # flat bar, which is what the gauge used to be — the preview lied about the
  # shape as much as the docs did.
  @impl true
  def card_preview do
    semi_circle_progress(value: 68, size: 104)
  end
end
