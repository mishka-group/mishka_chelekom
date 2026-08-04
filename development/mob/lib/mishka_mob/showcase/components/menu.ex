defmodule MishkaMob.Showcase.Components.Menu do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMenu`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

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
    |> Mob.Socket.assign(:grid?, true)
    |> Mob.Socket.assign(:sort, :name)
    |> Mob.Socket.assign(:submenu, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Every row kind, written as tags",
        description:
          "The same shape as the web original: items, a separator, a checkbox, a section " <>
            "label, a radio group, a disabled row and a nested submenu.",
        code: ~S"""
        <MishkaMenu open={@open?} on_select={:pick} id="full">
          <MishkaMenuItem id={:edit} label="Edit" icon="✎" />
          <MishkaMenuItem id={:dup} label="Duplicate" icon="⧉" />
          <MishkaMenuSeparator />
          <MishkaMenuCheckbox id={:grid} label="Show grid" checked={@grid?} />
          <MishkaMenuItem id={:docs} label="Documentation" icon="↗" />
          <MishkaMenuSeparator />
          <MishkaMenuLabel text="SORT BY" />
          <MishkaMenuRadio id={:name} label="Name" name="sort" checked={@sort == :name} />
          <MishkaMenuRadio id={:date} label="Date" name="sort" checked={@sort == :date} />
          <MishkaMenuSeparator />
          <MishkaMenuItem id={:archive} label="Archive" disabled={true} />
          <MishkaMenuSubmenu id={:share} label="Share" open={@submenu == :share}>
            <MishkaMenuItem id={:copy} label="Copy link" />
            <MishkaMenuItem id={:email} label="Email" />
          </MishkaMenuSubmenu>
        </MishkaMenu>

        # One handler for every row — the message carries the row's own id.
        def handle_info({:tap, {:pick, :grid}}, socket) do
          {:noreply, assign(socket, :grid?, not socket.assigns.grid?)}
        end

        def handle_info({:tap, {:pick, :share}}, socket) do
          # A submenu trigger reports like any row; the screen decides.
          {:noreply, assign(socket, :submenu, toggle(socket.assigns.submenu, :share))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Button
              text={if(@menu_open, do: "Close menu", else: "Options ▾")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :menu_toggle}}
              id="menu-trigger"
            />
            <Spacer size={8} />
            <MishkaMenu open={@menu_open} on_select={:menu_pick}>
              <MishkaMenuItem id={:edit} label="Edit" icon="✎" test_id="row-edit" />
              <MishkaMenuItem id={:dup} label="Duplicate" icon="⧉" test_id="row-dup" />
              <MishkaMenuSeparator />
              <MishkaMenuCheckbox id={:grid} label="Show grid" checked={@grid?} test_id="row-grid" />
              <MishkaMenuItem id={:docs} label="Documentation" icon="↗" test_id="row-docs" />
              <MishkaMenuSeparator />
              <MishkaMenuLabel text="SORT BY" />
              <MishkaMenuRadio
                id={:name}
                label="Name"
                name="sort"
                checked={@sort == :name}
                test_id="row-name"
              />
              <MishkaMenuRadio
                id={:date}
                label="Date"
                name="sort"
                checked={@sort == :date}
                test_id="row-date"
              />
              <MishkaMenuSeparator />
              <MishkaMenuItem id={:archive} label="Archive" disabled={true} test_id="row-archive" />
              <MishkaMenuSubmenu id={:share} label="Share" open={@submenu == :share} test_id="row-share">
                <MishkaMenuItem id={:copy} label="Copy link" test_id="row-copy" />
                <MishkaMenuItem id={:email} label="Email" test_id="row-email" />
              </MishkaMenuSubmenu>
            </MishkaMenu>
            <Spacer size={10} />
            <Text text={picked(@menu_last)} text_size={:sm} text_color={:muted} id="menu-readout" />
          </Column>
          """
        end
      },
      %Example{
        title: "Plain actions",
        description: "No icons, no groups — just rows.",
        code: ~S"""
        <MishkaMenu open={true} on_select={:pick}>
          <MishkaMenuItem id={:a} label="One" />
          <MishkaMenuItem id={:b} label="Two" />
        </MishkaMenu>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMenu open={true} on_select={:menu_pick} width={200}>
              <MishkaMenuItem id={:one} label="First action" />
              <MishkaMenuItem id={:two} label="Second action" />
              <MishkaMenuItem id={:three} label="Third action" />
            </MishkaMenu>
          </Column>
          """
        end
      },
      %Example{
        title: "As a sheet",
        description: "On a phone an action list often belongs in a Drawer instead.",
        code: ~S"""
        # the same menu, rendered inside a bottom Drawer
        <MishkaDrawer side={:bottom}>
          <MishkaMenu open={true} on_select={:pick}>
            <MishkaMenuItem id={:share} label="Share" icon="↗" />
            <MishkaMenuSeparator />
            <MishkaMenuItem id={:report} label="Report" icon="⚑" danger={true} />
          </MishkaMenu>
        </MishkaDrawer>
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
            <MishkaMenu open={true} on_select={:menu_pick}>
              <MishkaMenuItem id={:share} label="Share" icon="↗" />
              <MishkaMenuItem id={:copy} label="Copy link" icon="🔗" />
              <MishkaMenuSeparator />
              <MishkaMenuItem id={:report} label="Report" icon="⚑" danger={true} />
            </MishkaMenu>
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
        name: "<MishkaMenuItem>",
        type: "slot",
        default: "—",
        description: "A row. id (the event tag), label, icon, disabled, danger, test_id."
      },
      %{
        name: "<MishkaMenuSeparator>",
        type: "slot",
        default: "—",
        description: "A divider between groups."
      },
      %{
        name: "<MishkaMenuLabel>",
        type: "slot",
        default: "—",
        description: "A section heading. text."
      },
      %{
        name: "<MishkaMenuCheckbox>",
        type: "slot",
        default: "—",
        description: "A row with a tick. checked; its tag gains -checked / -unchecked."
      },
      %{
        name: "<MishkaMenuRadio>",
        type: "slot",
        default: "—",
        description: "One of a named group. name, checked. Reports like any row."
      },
      %{
        name: "<MishkaMenuSubmenu>",
        type: "slot",
        default: "—",
        description: "Nested rows. open; they appear indented below, not flown out sideways."
      },
      %{
        name: "danger_color",
        type: "color / ARGB",
        default: ":error",
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

  # A checkbox toggles and the menu STAYS OPEN — closing on every tick would
  # make a multi-select menu unusable. A submenu trigger likewise only opens its
  # own rows. Everything else is a command, so it picks and closes.
  def handle({:menu_pick, :grid}, socket),
    do: Mob.Socket.assign(socket, :grid?, not socket.assigns.grid?)

  def handle({:menu_pick, sort}, socket) when sort in [:name, :date],
    do: Mob.Socket.assign(socket, :sort, sort)

  def handle({:menu_pick, :share}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :submenu,
        if(socket.assigns.submenu == :share, do: nil, else: :share)
      )

  def handle({:menu_pick, id}, socket) do
    socket
    |> Mob.Socket.assign(:menu_last, id)
    |> Mob.Socket.assign(:menu_open, false)
    |> Mob.Socket.assign(:submenu, nil)
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
