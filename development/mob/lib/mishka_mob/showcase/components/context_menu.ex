defmodule MishkaMob.Showcase.Components.ContextMenu do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaContextMenu`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaMenu, only: [item: 3, separator: 0]

  alias MishkaMob.Components.MishkaContextMenu
  alias MishkaMob.Showcase.Example

  @files [{:report, "report.pdf"}, {:notes, "notes.md"}]

  @impl true
  def entry do
    %{
      slug: :context_menu,
      name: "Context Menu",
      category: "Navigation",
      order: 2,
      description: "The actions for a particular row or object."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:cm_for, nil)
    |> Mob.Socket.assign(:cm_last, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Hold a row — the touch right-click",
        description:
          "Press and hold any row to open its actions, exactly as the web opens on right-click. " <>
            "The ⋯ does the same, because a long press is invisible unless something says so.",
        code: ~S"""
        # trigger/3 wraps the object; holding it fires on_long_press. A plain
        # tap passes straight through, so the row keeps whatever it already did.
        {MishkaContextMenu.trigger(id, [row_content()], on_hold: :open_for)}

        <MishkaContextMenu
          open={@open_for == id}
          for_label={name}
          on_select={:act}
        >
          <MishkaMenuItem id={:rename} label="Rename" icon="✎" />
          <MishkaMenuItem id={:delete} label="Delete" icon="🗑" danger={true} />
        </MishkaContextMenu>

        def handle_info({:tap, {:open_for, id}}, socket) do
          {:noreply, assign(socket, :open_for, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {rows(@cm_for)}
            <Spacer size={10} />
            <Text text={acted(@cm_last)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Without a subject",
        description: "Drop for_label and it is exactly a Menu.",
        code: ~S"""
        <MishkaContextMenu open={true} on_select={:act}>{items}</MishkaContextMenu>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaContextMenu open={true} on_select={:cm_pick} width={220}>
              {[
              item(:open, "Open", icon: "↗"),
              item(:rename, "Rename", icon: "✎"),
              separator(),
              item(:delete, "Delete", icon: "🗑", danger: true)
            ]}
            </MishkaContextMenu>
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
        name: "for_label",
        type: "string",
        default: "nil",
        description: "The object these actions apply to, shown as a heading."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the menu is shown."
      },
      %{
        name: "on_select",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}."
      },
      %{
        name: "everything else",
        type: "see Menu",
        default: "—",
        description: "It renders through MishkaMenu."
      }
    ]
  end

  @impl true
  def handle({:cm_open, id}, socket) do
    next = if socket.assigns.cm_for == id, do: nil, else: id
    Mob.Socket.assign(socket, :cm_for, next)
  end

  def handle({:cm_pick, action}, socket) do
    socket
    |> Mob.Socket.assign(:cm_last, {socket.assigns.cm_for, action})
    |> Mob.Socket.assign(:cm_for, nil)
  end

  def handle(_tag, socket), do: socket

  defp rows(open_for) do
    @files
    |> Enum.map(fn {id, name} -> file_row(id, name, open_for) end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 8}, children: []})
  end

  defp file_row(id, name, open_for) do
    # The row itself is the trigger: hold it and the menu opens, which is the
    # touch equivalent of the web's right-click. The ⋯ stays as the discoverable
    # alternative — a long press is invisible unless something tells you.
    row =
      MishkaContextMenu.trigger(
        id,
        [
          ~MOB"""
          <Row fill_width={true}>
            <Text text={name} text_size={:base} text_color={:on_surface} />
            <Spacer weight={1} />
            <MishkaActionIcon icon="⋯" on_tap={{:cm_open, id}} />
          </Row>
          """
        ],
        on_hold: :cm_open,
        test_id: "row-#{id}"
      )

    ~MOB"""
    <Column fill_width={true}>
      {row}
      <Spacer size={6} :if={open_for == id} />
      <MishkaContextMenu open={open_for == id} for_label={name} on_select={:cm_pick}>
        {[
           item(:rename, "Rename", icon: "✎", test_id: "act-#{id}-rename"),
           item(:duplicate, "Duplicate", icon: "⧉", test_id: "act-#{id}-duplicate"),
           separator(),
           item(:delete, "Delete", icon: "🗑", danger: true, test_id: "act-#{id}-delete")
         ]}
      </MishkaContextMenu>
    </Column>
    """
  end

  defp acted(nil), do: "No action yet"
  defp acted({file, action}), do: "#{action} on #{file}"

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Box width={16} height={16} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_md}
        border_color={:border}
        border_width={1}
        padding={6}
      >
        <Column fill_width={true}>
          <Box width={40} height={6} background={:surface_raised} corner_radius={:radius_sm} />
          <Spacer size={7} />
          <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={7} />
          <Box width={44} height={8} background={0xFFDC2626} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
