defmodule MishkaMob.Showcase.Components.SegmentedControl do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSegmentedControl`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  import MishkaMob.Components.MishkaSegmentedControl,
    only: [segmented_control: 2, option: 2, option: 3]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :segmented_control,
      name: "Segmented Control",
      category: "Forms",
      order: 9,
      description: "A joined strip where exactly one option is always selected."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sc_view, :day)
    |> Mob.Socket.assign(:sc_theme, :system)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Always one selected",
        description: "Re-tapping the selected segment is a no-op — it cannot be cleared.",
        code: ~S"""
        {segmented_control([value: @view, on_change: :view], [
          option(:day, "Day"), option(:week, "Week"), option(:month, "Month")
        ])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {segmented_control([value: @sc_view, on_change: :sc_view], [
              option(:day, "Day"),
              option(:week, "Week"),
              option(:month, "Month")
            ])}
            <Spacer size={12} />
            <Text text={"Value: " <> to_string(@sc_view)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "With a label",
        description: "A heading above the strip.",
        code: ~S"""
        {segmented_control([label: "THEME", value: @theme, on_change: :theme], opts)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {segmented_control([label: "THEME", value: @sc_theme, on_change: :sc_theme], [
              option(:light, "Light"),
              option(:dark, "Dark"),
              option(:system, "System")
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "One segment, or the whole control.",
        code: ~S"""
        option(:month, "Month", disabled: true)
        {segmented_control([disabled: true], opts)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {segmented_control([value: @sc_view, on_change: :sc_view], [
              option(:day, "Day"),
              option(:month, "Month (off)", disabled: true)
            ])}
            <Spacer size={16} />
            {segmented_control([value: @sc_view, disabled: true], [
              option(:day, "Whole"),
              option(:week, "control off")
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "color fills the selection; background is the track.",
        code: ~S"""
        {segmented_control([value: @v, color: 0xFF7C3AED, text_color: 0xFFFFFFFF], opts)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {segmented_control([value: @sc_view, color: 0xFF7C3AED, text_color: 0xFFFFFFFF,
                                on_change: :sc_view], [
              option(:day, "Day"),
              option(:week, "Week")
            ])}
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
        type: "option id",
        default: "first option",
        description: "The selected segment. An unknown id falls back to the first."
      },
      %{name: "label", type: "string", default: "nil", description: "Heading above the strip."},
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every segment."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, option_id}}."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Selected segment fill."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "Selected segment label."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "The track behind the segments."
      }
    ]
  end

  @impl true
  def handle({:sc_view, id}, socket), do: Mob.Socket.assign(socket, :sc_view, id)
  def handle({:sc_theme, id}, socket), do: Mob.Socket.assign(socket, :sc_theme, id)
  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md} padding={4}>
      <Row fill_width={true}>
        <Box width={46} height={22} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={4} />
        <Box width={46} height={22} corner_radius={:radius_sm} />
        <Spacer size={4} />
        <Box width={46} height={22} corner_radius={:radius_sm} />
      </Row>
    </Box>
    """
  end
end
