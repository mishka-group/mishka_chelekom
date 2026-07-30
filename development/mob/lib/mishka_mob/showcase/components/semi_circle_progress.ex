defmodule MishkaMob.Showcase.Components.SemiCircleProgress do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSemiCircleProgress` and
  `MishkaMob.Components.MishkaRollingNumber`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  import MishkaMob.Components.MishkaSemiCircleProgress, only: [semi_circle_progress: 1]

  alias MishkaMob.Components.MishkaRollingNumber
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :semi_circle_progress,
      name: "Semi Circle Progress",
      category: "Feedback",
      order: 4,
      description: "A half-circle gauge drawn on a canvas, plus a counting number."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sc_value, 72)
    |> Mob.Socket.assign(:rn_value, 0)
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
      },
      %Example{
        title: "Rolling number",
        description: "The component renders a number; the screen walks steps/3 on a timer.",
        code: ~S"""
        <MishkaRollingNumber value={@count} />

        # in the handler
        [next | rest] = MishkaRollingNumber.steps(from, to, 20)
        Process.send_after(self(), {:roll, rest}, 16)
        """,
        render: fn assigns ->
          # align on a Column is dead — Mob maps it to a bare Compose Column and
          # a leading VStack, neither of which aligns children. A Box does.
          ~MOB"""
          <Column fill_width={true}>
            <Box fill_width={true} align={:center}>
              <MishkaRollingNumber value={@rn_value} />
            </Box>
            <Spacer size={12} />
            <Row fill_width={true}>
              <Button
                text="Roll to 1,284"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :rn_roll}}
              />
              <Spacer size={8} />
              <Button
                text="Reset"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :rn_reset}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Grouping",
        description:
          "separator groups thousands — a comma by default, a space for the " <>
            "European style, and \"\" turns grouping off. Negatives keep their sign.",
        code: ~S"""
        <MishkaRollingNumber value={1234567} />
        <MishkaRollingNumber value={1234567} separator=" " />
        <MishkaRollingNumber value={1234567} separator="" />
        <MishkaRollingNumber value={-98765} color={0xFFDC2626} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRollingNumber value={1_234_567} text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={1_234_567} separator=" " text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={1_234_567} separator="" text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={-98_765} text_size={:xl} color={0xFFDC2626} />
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
      },
      %{
        name: "RollingNumber: value / separator",
        type: "integer / string",
        default: "0 / \",\"",
        description: "The number and its thousands separator."
      },
      %{
        name: "RollingNumber.steps/3",
        type: "helper",
        default: "—",
        description: "Eased intermediate values for the screen to walk on a timer."
      }
    ]
  end

  @impl true
  def handle(:sc_up, socket), do: nudge(socket, +15)
  def handle(:sc_down, socket), do: nudge(socket, -15)
  def handle(:rn_reset, socket), do: Mob.Socket.assign(socket, :rn_value, 0)

  def handle(:rn_roll, socket) do
    [next | rest] = MishkaRollingNumber.steps(socket.assigns.rn_value, 1_284, 18)
    if rest != [], do: Process.send_after(self(), {:tap, {:rn_step, rest}}, 24)
    Mob.Socket.assign(socket, :rn_value, next)
  end

  def handle({:rn_step, [next | rest]}, socket) do
    if rest != [], do: Process.send_after(self(), {:tap, {:rn_step, rest}}, 24)
    Mob.Socket.assign(socket, :rn_value, next)
  end

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
