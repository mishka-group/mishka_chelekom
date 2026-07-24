defmodule MishkaMob.Showcase.Components.Progress do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaProgress`.

  The determinate examples are driven by a live value the buttons move, so the
  bar, the readout and the clamping are all visible on device rather than being
  three static screenshots.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaProgress, only: [progress: 0, progress: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :progress,
      name: "Progress",
      category: "Feedback",
      order: 0,
      description: "A determinate or indeterminate progress bar."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :pg_value, 40)

  @impl true
  def examples do
    [
      %Example{
        title: "Determinate",
        description: "A value inside [min, max]. Tap to move it.",
        code: ~S"""
        {progress(value: @value)}
        {progress(value: @value, label: "Uploading", show_value: true)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {progress(value: @pg_value)}
            <Spacer size={16} />
            {progress(value: @pg_value, label: "Uploading", show_value: true)}
            <Spacer size={14} />
            <Row fill_width={true}>
              <Button
                text="− 15"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :pg_down}}
              />
              <Spacer size={8} />
              <Button
                text="+ 15"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :pg_up}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Indeterminate",
        description: "Omit value when the total is unknown — the bar animates itself.",
        code: ~S"""
        {progress()}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {progress()}
            <Spacer size={16} />
            {progress(label: "Connecting…")}
          </Column>
          """
        end
      },
      %Example{
        title: "Custom range and readout",
        description: "min/max map any scale onto the bar; value_text overrides the percentage.",
        code: ~S"""
        {progress(value: 3, max: 5, label: "Step", value_text: "3 of 5", show_value: true)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {progress(value: 3, max: 5, label: "Step", value_text: "3 of 5", show_value: true)}
            <Spacer size={16} />
            {progress(value: 7, min: 5, max: 10, label: "Rating", show_value: true)}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "Tint the indicator.",
        code: ~S"""
        {progress(value: 65, color: 0xFF7C3AED)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {progress(value: 65, color: 0xFF7C3AED, show_value: true)}
            <Spacer size={16} />
            {progress(value: 30, color: :primary, show_value: true)}
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
        type: "number / nil",
        default: "nil",
        description: "Current value in [min, max]. nil renders the indeterminate bar."
      },
      %{name: "min", type: "number", default: "0", description: "Lower bound."},
      %{name: "max", type: "number", default: "100", description: "Upper bound."},
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Caption above the bar."
      },
      %{
        name: "show_value",
        type: "boolean",
        default: "false",
        description: "Render a readout beside the label. Ignored when indeterminate."
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
        description: "Indicator colour."
      }
    ]
  end

  @impl true
  def handle(:pg_up, socket), do: nudge(socket, +15)
  def handle(:pg_down, socket), do: nudge(socket, -15)
  def handle(_tag, socket), do: socket

  # Deliberately allowed past 0/100 so the bar's clamping is visible on device.
  defp nudge(socket, delta),
    do: Mob.Socket.assign(socket, :pg_value, socket.assigns.pg_value + delta)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={false} width={40} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <Box fill_width={true} height={8} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={78} height={8} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={12} />
      <Box fill_width={true} height={8} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={38} height={8} background={:muted} corner_radius={:radius_pill} />
      </Box>
    </Column>
    """
  end
end
