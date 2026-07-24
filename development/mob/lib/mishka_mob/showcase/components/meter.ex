defmodule MishkaMob.Showcase.Components.Meter do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMeter`.

  Examples lean on gauge-shaped data (storage, battery, signal) to make the
  distinction from Progress concrete: a meter reads a measurement, a progress bar
  tracks a task.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaMeter, only: [meter: 1]
  import MishkaMob.Components.MishkaSeparator, only: [separator: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :meter,
      name: "Meter",
      category: "Feedback",
      order: 1,
      description: "A scalar gauge for a measurement inside a known range."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :mt_used, 72)

  @impl true
  def examples do
    [
      %Example{
        title: "A gauge",
        description: "A measurement with its own readout. Tap to fill it.",
        code: ~S"""
        {meter(value: @used, label: "Storage", show_value: true)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {meter(value: @mt_used, label: "Storage used", show_value: true)}
            <Spacer size={14} />
            <Row fill_width={true}>
              <Button
                text="Free up"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :mt_down}}
              />
              <Spacer size={8} />
              <Button
                text="Fill up"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :mt_up}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Any range",
        description: "min/max map the scale; value_text replaces the percentage.",
        code: ~S"""
        {meter(value: 3, max: 5, label: "Signal", value_text: "3 of 5 bars", show_value: true)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {meter(value: 3, max: 5, label: "Signal", value_text: "3 of 5 bars", show_value: true)}
            <Spacer size={16} />
            {meter(value: 37, min: 20, max: 40, label: "Temperature", value_text: "37 °C", show_value: true)}
          </Column>
          """
        end
      },
      %Example{
        title: "Clamped, never overshooting",
        description: "Values outside the range read as full or empty.",
        code: ~S"""
        {meter(value: 250)}   # renders full
        {meter(value: -40)}   # renders empty
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {meter(value: 250, label: "Over the top", show_value: true)}
            <Spacer size={16} />
            {meter(value: -40, label: "Below the floor", show_value: true)}
            <Spacer size={16} />
            {separator(label: "a meter with no value reads empty")}
            <Spacer size={16} />
            {meter(label: "Unknown", show_value: true)}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "Tint the fill, e.g. to warn as a gauge approaches its limit.",
        code: ~S"""
        {meter(value: 91, color: 0xFFDC2626)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {meter(value: 22, label: "Comfortable", color: :primary, show_value: true)}
            <Spacer size={16} />
            {meter(value: 91, label: "Nearly full", color: 0xFFDC2626, show_value: true)}
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
        type: "number",
        default: "min",
        description: "The measurement. Clamped into [min, max]; absent reads empty."
      },
      %{name: "min", type: "number", default: "0", description: "Lower bound."},
      %{name: "max", type: "number", default: "100", description: "Upper bound."},
      %{name: "label", type: "string", default: "nil", description: "Caption above the gauge."},
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a readout beside the label."
      },
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "Overrides the readout; the default is a rounded percentage."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "platform",
        description: "Fill colour."
      }
    ]
  end

  @impl true
  def handle(:mt_up, socket), do: nudge(socket, +12)
  def handle(:mt_down, socket), do: nudge(socket, -12)
  def handle(_tag, socket), do: socket

  defp nudge(socket, delta),
    do: Mob.Socket.assign(socket, :mt_used, socket.assigns.mt_used + delta)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={36} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Box width={20} height={8} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={92} height={10} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={12} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={54} height={10} background={:muted} corner_radius={:radius_pill} />
      </Box>
    </Column>
    """
  end
end
