defmodule MishkaMob.Showcase.Components.SemiCircleProgress do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSemiCircleProgress` and
  `MishkaMob.Components.MishkaRollingNumber`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSemiCircleProgress, only: [semi_circle_progress: 1]
  import MishkaMob.Components.MishkaRollingNumber, only: [rolling_number: 1]

  alias MishkaMob.Components.MishkaRollingNumber
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :semi_circle_progress,
      name: "Semi Circle Progress",
      category: "Feedback",
      order: 4,
      description: "A gauge with a large readout, plus a counting number."
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
          "Mob has no canvas, so the arc is a track with a big readout — see the docs.",
        code: ~S"""
        {semi_circle_progress(value: @value, label: "Battery")}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {semi_circle_progress(value: @sc_value, label: "BATTERY")}
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
        {semi_circle_progress(value: 3, max: 5, value_text: "3 / 5")}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {semi_circle_progress(value: 3, max: 5, value_text: "3 / 5", label: "STEPS",
                                  color: 0xFF10B981)}
          </Column>
          """
        end
      },
      %Example{
        title: "Rolling number",
        description: "The component renders a number; the screen walks steps/3 on a timer.",
        code: ~S"""
        {rolling_number(value: @count)}

        # in the handler
        [next | rest] = MishkaRollingNumber.steps(from, to, 20)
        Process.send_after(self(), {:roll, rest}, 16)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} align={:center}>
            {rolling_number(value: @rn_value)}
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
        description: "separator groups thousands; \"\" turns it off.",
        code: ~S"""
        {rolling_number(value: 1234567)}
        {rolling_number(value: 1234567, separator: "")}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {rolling_number(value: 1_234_567, text_size: :xl)}
            <Spacer size={8} />
            {rolling_number(value: 1_234_567, separator: " ", text_size: :xl)}
            <Spacer size={8} />
            {rolling_number(value: -98_765, text_size: :xl, color: 0xFFDC2626)}
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "number", default: "min", description: "The measurement."},
      %{name: "min / max", type: "number", default: "0 / 100", description: "The range."},
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Caption under the readout."
      },
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "Overrides the readout."
      },
      %{name: "color", type: "color / ARGB", default: ":primary", description: "Fill colour."},
      %{name: "size", type: "number", default: "140", description: "Track width."},
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

  defp nudge(socket, delta),
    do: Mob.Socket.assign(socket, :sc_value, socket.assigns.sc_value + delta)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true} align={:center}>
      <Box width={54} height={14} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box width={104} height={8} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={72} height={8} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={8} />
      <Box width={40} height={6} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
