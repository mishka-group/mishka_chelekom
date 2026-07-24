defmodule MishkaMob.Showcase.Components.ToggleGroup do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToggleGroup`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaToggleGroup, only: [toggle_group: 2, item: 2, item: 3]

  alias MishkaMob.Components.MishkaToggleGroup
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toggle_group,
      name: "Toggle Group",
      category: "Forms",
      order: 8,
      description: "A row of toggle buttons sharing one selection."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tgg_align, :left)
    |> Mob.Socket.assign(:tgg_style, [:bold])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Single",
        description: "Pressing the pressed button clears the group — unlike a radio group.",
        code: ~S"""
        {toggle_group([value: @align, on_change: :align], [
          item(:left, "Left"), item(:center, "Center"), item(:right, "Right")
        ])}

        MishkaToggleGroup.press(@align, id, false)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {toggle_group([value: @tgg_align, on_change: :tgg_align], [
              item(:left, " Left "),
              item(:center, " Center "),
              item(:right, " Right ")
            ])}
            <Spacer size={12} />
            <Text text={"Value: " <> inspect(@tgg_align)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description: "multiple: true makes the value a set.",
        code: ~S"""
        {toggle_group([value: @style, multiple: true, on_change: :style], items)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {toggle_group([value: @tgg_style, multiple: true, on_change: :tgg_style], [
              item(:bold, "  B  "),
              item(:italic, "  I  "),
              item(:under, "  U  ")
            ])}
            <Spacer size={12} />
            <Text text={"Value: " <> inspect(@tgg_style)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Vertical and disabled",
        description: "orientation stacks them; an item or the group can be disabled.",
        code: ~S"""
        {toggle_group([orientation: :vertical, value: @align], items)}
        item(:right, "Right", disabled: true)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {toggle_group([value: @tgg_align, orientation: :vertical, on_change: :tgg_align], [
              item(:left, " Left "),
              item(:right, " Right (off) ", disabled: true)
            ])}
            <Spacer size={16} />
            {toggle_group([value: @tgg_align, disabled: true], [
              item(:left, " Whole "),
              item(:center, " group off ")
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
        type: "id, list or nil",
        default: "nil",
        description: "The pressed item(s). A list in multiple mode."
      },
      %{
        name: "multiple",
        type: "boolean",
        default: "false",
        description: "Allow several pressed at once."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every item."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}."
      },
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Layout axis."
      },
      %{name: "space", type: "number", default: "8", description: "Gap between items."},
      %{
        name: "press/3 · pressed?/2",
        type: "helpers",
        default: "—",
        description: "The selection reducer and the pressed test, for both modes."
      }
    ]
  end

  @impl true
  def handle({:tgg_align, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :tgg_align,
        MishkaToggleGroup.press(socket.assigns.tgg_align, id, false)
      )

  def handle({:tgg_style, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :tgg_style,
        MishkaToggleGroup.press(socket.assigns.tgg_style, id, true)
      )

  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={40} height={24} background={:primary} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={40} height={24} background={:surface_raised} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={40} height={24} background={:surface_raised} corner_radius={:radius_md} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={28} height={24} background={:primary} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={28} height={24} background={:primary} corner_radius={:radius_md} />
      </Row>
    </Column>
    """
  end
end
