defmodule MishkaMob.Showcase.Components.ListItem do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaListItem`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :list_item,
      name: "List Item",
      category: "Data display",
      order: 7,
      description: "A row with a leading node, a body and a trailing node."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A row with a leading and a trailing slot",
        description:
          "The body takes the space between the two slots. There is no background " <>
            "and no rule — put it in a MishkaCard and separate rows with MishkaSeparator.",
        code: ~S"""
        <MishkaListItem
          leading={avatar_node}
          trailing={<Text text="›" />}
          padding_top={14}
          padding_bottom={14}
          on_tap={:open_profile}
        >
          <Text text="Ada Lovelace" font_weight={:bold} />
          <Text text="Mathematician" text_color={:muted} />
        </MishkaListItem>

        def handle_info({:tap, :open_profile}, socket) do
          {:noreply, Mob.Socket.push_screen(socket, Profile)}
        end
        """,
        render: fn _assigns ->
          avatar = ~MOB"""
          <Box id="li-avatar" width={40} height={40} corner_radius={20} background={:surface_raised} />
          """

          chevron = ~MOB"""
          <Box id="li-chevron" fill_width={false}>
            <Text text="›" text_size={:lg} text_color={:muted} />
          </Box>
          """

          assigns = %{avatar: avatar, chevron: chevron}

          ~MOB"""
          <MishkaCard
            background={:surface_raised}
            corner_radius={:radius_md}
            padding_left={15}
            padding_right={15}
          >
            <MishkaListItem
              id="li-row"
              leading={@avatar}
              trailing={@chevron}
              padding_top={14}
              padding_bottom={14}
              on_tap={:list_item_tap}
            >
              <Text text="Ada Lovelace" font_weight={:bold} text_color={:on_surface} />
              <Text text="Mathematician" text_size={:sm} text_color={:muted} />
            </MishkaListItem>
          </MishkaCard>
          """
        end
      },
      %Example{
        title: "Slots are optional",
        description:
          "A row with no leading slot starts at the body; no trailing slot ends it. " <>
            "The gap belongs to the slot, so neither leaves an empty spacer.",
        code: ~S"""
        <MishkaListItem padding_top={12} padding_bottom={12}>
          <Text text="A row that is only a body" />
        </MishkaListItem>
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaCard
            background={:surface_raised}
            corner_radius={:radius_md}
            padding_left={15}
            padding_right={15}
          >
            <MishkaListItem padding_top={14} padding_bottom={14}>
              <Text text="A row that is only a body" text_color={:on_surface} />
            </MishkaListItem>
          </MishkaCard>
          """
        end
      },
      %Example{
        title: "At different row paddings",
        description:
          "The leading gap is 13 by default and the trailing gap 12; gap and " <>
            "trailing_gap move them without touching the slots.",
        code: ~S"""
        <MishkaListItem leading={icon} trailing={chevron} gap={16} trailing_gap={8}
                        padding_top={10} padding_bottom={10}>
          <Text text="Line one" />
          <Text text="Line two" text_color={:muted} />
        </MishkaListItem>
        """,
        render: fn _assigns ->
          icon = ~MOB"""
          <Box width={30} height={30} corner_radius={:radius_sm} background={:surface} />
          """

          chevron = ~MOB"""
          <Text text="›" text_size={:lg} text_color={:muted} />
          """

          assigns = %{icon: icon, chevron: chevron}

          ~MOB"""
          <MishkaCard
            background={:surface_raised}
            corner_radius={:radius_md}
            padding_left={15}
            padding_right={15}
          >
            <MishkaListItem
              leading={@icon}
              trailing={@chevron}
              gap={16}
              trailing_gap={8}
              padding_top={10}
              padding_bottom={10}
            >
              <Text text="Line one" text_color={:on_surface} />
              <Text text="Line two" text_size={:sm} text_color={:muted} />
            </MishkaListItem>
          </MishkaCard>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "leading",
        type: "node | list of nodes",
        default: "nil",
        description: "Drawn before the body. Omitted with no gap."
      },
      %{
        name: "trailing",
        type: "node | list of nodes",
        default: "nil",
        description: "Drawn after the body. Omitted with no gap."
      },
      %{
        name: "gap / trailing_gap",
        type: "number",
        default: "13 / 12",
        description: "Space between the body and each slot."
      },
      %{
        name: "padding_top / padding_bottom",
        type: "spacing token / number",
        default: "nil",
        description: "The row's vertical padding; padding and per-edge props all apply."
      },
      %{
        name: "on_tap / on_long_press",
        type: "event tag",
        default: "—",
        description: "Makes the whole row one target."
      },
      %{
        name: "align",
        type: ":center | :leading | …",
        default: ":center",
        description: "Cross-axis alignment of the row."
      }
    ]
  end
end
