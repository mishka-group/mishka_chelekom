defmodule MishkaMob.Showcase.Components.Menu do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMenu`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  import MishkaMob.Components.MishkaMenu,
    only: [menu: 2, item: 2, item: 3, separator: 0, label: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :menu,
      name: "Menu",
      category: "Navigation",
      order: 1,
      description: "A list of actions revealed from a trigger."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:menu_open, false)
    |> Mob.Socket.assign(:menu_last, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A dropdown",
        description: "Placed under its trigger — labels, separators and a destructive item.",
        code: ~S"""
        {menu([open: @open?, on_select: :pick], [
          label("MANAGE"),
          item(:edit, "Edit", icon: "✎"),
          item(:dup, "Duplicate", icon: "⧉"),
          separator(),
          item(:delete, "Delete", icon: "🗑", danger: true)
        ])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Button
              text={if(@menu_open, do: "Close menu", else: "Open menu")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :menu_toggle}}
            />
            <Spacer size={8} />
            {menu([open: @menu_open, on_select: :menu_pick], [
              label("MANAGE"),
              item(:edit, "Edit", icon: "✎"),
              item(:dup, "Duplicate", icon: "⧉"),
              item(:archive, "Archive", icon: "📦", disabled: true),
              separator(),
              item(:delete, "Delete", icon: "🗑", danger: true)
            ])}
            <Spacer size={10} />
            <Text text={picked(@menu_last)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Plain actions",
        description: "No icons, no groups — just rows.",
        code: ~S"""
        {menu([open: true, on_select: :pick], [item(:a, "One"), item(:b, "Two")])}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {menu([open: true, on_select: :menu_pick, width: 200], [
              item(:one, "First action"),
              item(:two, "Second action"),
              item(:three, "Third action")
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "As a sheet",
        description: "On a phone an action list often belongs in a Drawer instead.",
        code: ~S"""
        # the same menu, rendered inside a bottom Drawer
        <MishkaDrawer side={:bottom}>{menu(...)}</MishkaDrawer>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="Menu is placed by the caller, so the same item list works as a dropdown or inside a bottom sheet."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={10} />
            {menu([open: true, on_select: :menu_pick], [
              item(:share, "Share", icon: "↗"),
              item(:copy, "Copy link", icon: "🔗"),
              separator(),
              item(:report, "Report", icon: "⚑", danger: true)
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
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the menu is shown. Lives in the screen."
      },
      %{
        name: "on_select",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}."
      },
      %{name: "width", type: "number", default: "nil", description: "Panel width."},
      %{
        name: "danger_color",
        type: "color / ARGB",
        default: "0xFFDC2626",
        description: "Destructive item colour."
      },
      %{
        name: "item/3",
        type: "builder",
        default: "—",
        description: "id, label, plus :icon, :disabled, :danger."
      },
      %{
        name: "separator/0 · label/1",
        type: "builders",
        default: "—",
        description: "A divider, and a small heading above a group."
      },
      %{
        name: "background / corner_radius / padding / border_*",
        type: "see Popover",
        default: "—",
        description: "The panel shell is the Popover's."
      }
    ]
  end

  @impl true
  def handle(:menu_toggle, socket),
    do: Mob.Socket.assign(socket, :menu_open, not socket.assigns.menu_open)

  def handle({:menu_pick, id}, socket) do
    socket
    |> Mob.Socket.assign(:menu_last, id)
    |> Mob.Socket.assign(:menu_open, false)
  end

  def handle(_tag, socket), do: socket

  defp picked(nil), do: "Nothing picked yet"
  defp picked(id), do: "Picked: " <> to_string(id)

  @impl true
  def card_preview do
    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      border_color={:border}
      border_width={1}
      padding={6}
    >
      <Column fill_width={true}>
        <Box width={30} height={6} background={:surface_raised} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={62} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box fill_width={true} height={1} background={:border} />
        <Spacer size={8} />
        <Box width={46} height={8} background={0xFFDC2626} corner_radius={:radius_sm} />
      </Column>
    </Box>
    """
  end
end
