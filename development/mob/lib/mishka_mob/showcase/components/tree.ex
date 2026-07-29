defmodule MishkaMob.Showcase.Components.Tree do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTree` and
  `MishkaMob.Components.MishkaTreeSelect`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaTree, only: [tree: 1]

  alias MishkaMob.Components.MishkaTree
  alias MishkaMob.Showcase.Example

  @nodes [
    %{
      label: "lib",
      value: "lib",
      icon: "📁",
      children: [
        %{
          label: "mishka_mob",
          value: "lib/mishka_mob",
          icon: "📁",
          children: [
            %{label: "app.ex", value: "lib/mishka_mob/app.ex", icon: "📄", meta: "12 KB"},
            %{label: "showcase.ex", value: "lib/mishka_mob/showcase.ex", icon: "📄", meta: "8 KB"}
          ]
        },
        %{label: "mishka_mob.ex", value: "lib/mishka_mob.ex", icon: "📄", meta: "2.4 MB"}
      ]
    },
    %{
      label: "test",
      value: "test",
      icon: "📁",
      children: [%{label: "test_helper.exs", value: "test/test_helper.exs", icon: "📄"}]
    },
    %{label: "mix.exs", value: "mix.exs", icon: "📄", meta: "4 KB", disabled: true}
  ]

  @impl true
  def entry do
    %{
      slug: :tree,
      name: "Tree",
      category: "Navigation",
      order: 8,
      description: "Hierarchical data, expandable and checkable — plus a tree select."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:expanded, ["lib"])
    |> Mob.Socket.assign(:selected, [])
    |> Mob.Socket.assign(:checked, [])
    |> Mob.Socket.assign(:ts_open, false)
    |> Mob.Socket.assign(:ts_expanded, ["lib"])
    |> Mob.Socket.assign(:ts_label, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Expand and select",
        description:
          "Only the rows on screen are built — a collapsed branch costs one row, not a " <>
            "hidden layout tree.",
        code: ~S"""
        <MishkaTree
          nodes={@nodes}
          expanded={@expanded}
          selected={@selected}
          on_expand={:open}
          on_collapse={:close}
          on_select={:pick}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              nodes={nodes()}
              expanded={@expanded}
              selected={@selected}
              with_lines={true}
              on_expand={:open}
              on_collapse={:close}
              on_select={:pick}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Checkboxes cascade",
        description: "A parent is indeterminate when only some of its descendants are checked.",
        code: ~S"""
        <MishkaTree
          nodes={@nodes}
          checked={@checked}
          with_checkboxes={true}
          on_check={:check}
        />

        def handle({:check, value}, socket),
          do: assign(socket, :checked, MishkaTree.toggle_check(nodes(), value, socket.assigns.checked))
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              nodes={nodes()}
              expanded={@expanded}
              checked={@checked}
              with_checkboxes={true}
              with_expand_icon={true}
              on_expand={:open}
              on_collapse={:close}
              on_check={:check}
            />
            <Spacer size={10} />
            <Text text={"Checked: " <> summary(@checked)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Tree select",
        description: "A trigger showing the selection, with the tree in a panel beneath it.",
        code: ~S"""
        <MishkaTreeSelect
          label={@picked}
          open={@open}
          on_toggle={:ts_toggle}
        >{[tree(nodes: @nodes, on_select: :ts_pick)]}</MishkaTreeSelect>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect
              label={@ts_label}
              placeholder="Choose a file…"
              open={@ts_open}
              on_toggle={:ts_toggle}
            >
              {[
                 tree(
                   nodes: nodes(), expanded: @ts_expanded,
                   on_expand: :ts_open_node, on_collapse: :ts_close_node, on_select: :ts_pick
                 )
               ]}
            </MishkaTreeSelect>
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
        name: "nodes",
        type: "list of node maps",
        default: "[]",
        description: "label, value, children, icon, meta (a trailing note), disabled."
      },
      %{
        name: "expanded / selected / checked",
        type: "lists of values",
        default: "[]",
        description: "The tree is controlled; the screen owns state."
      },
      %{
        name: "with_checkboxes",
        type: "boolean",
        default: "false",
        description: "Checkbox per node, with indeterminate parents."
      },
      %{
        name: "check_strictly",
        type: "boolean",
        default: "false",
        description: "Do not cascade a check to descendants."
      },
      %{
        name: "with_expand_icon / with_lines",
        type: "boolean",
        default: "true / false",
        description: "Disclosure arrow; guide lines per level."
      },
      %{name: "level_offset", type: "number", default: "18", description: "Indent per depth."},
      %{
        name: "on_expand / on_collapse / on_select / on_check",
        type: "event tags",
        default: "—",
        description: "Each fires {:tap, {tag, value}}."
      },
      %{
        name: "visible/2",
        type: "helper",
        default: "—",
        description: "The rows on screen, with depth — the whole layout in one list."
      },
      %{
        name: "check_state/3 · toggle_check/4 · toggle_expand/2",
        type: "helpers",
        default: "—",
        description: "The state transitions, as pure functions."
      },
      %{
        name: "TreeSelect: label / placeholder / open / on_toggle",
        type: "see MishkaTreeSelect",
        default: "—",
        description: "Trigger plus an in-flow panel."
      }
    ]
  end

  @impl true
  def handle({:open, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :expanded,
        MishkaTree.toggle_expand(value, socket.assigns.expanded)
      )

  def handle({:close, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :expanded,
        MishkaTree.toggle_expand(value, socket.assigns.expanded)
      )

  def handle({:pick, value}, socket), do: Mob.Socket.assign(socket, :selected, [value])

  def handle({:check, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :checked,
        MishkaTree.toggle_check(@nodes, value, socket.assigns.checked)
      )

  def handle(:ts_toggle, socket),
    do: Mob.Socket.assign(socket, :ts_open, not socket.assigns.ts_open)

  def handle({:ts_open_node, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :ts_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.ts_expanded)
      )

  def handle({:ts_close_node, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :ts_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.ts_expanded)
      )

  # Picking closes the panel, which is the whole point of a select.
  def handle({:ts_pick, value}, socket) do
    socket
    |> Mob.Socket.assign(:ts_label, value)
    |> Mob.Socket.assign(:ts_open, false)
  end

  def handle(_tag, socket), do: socket

  defp nodes, do: @nodes

  defp summary([]), do: "nothing"
  defp summary(values), do: Enum.join(values, ", ")

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row align={:center}>
        <Text text="▾" text_size={:sm} text_color={:muted} />
        <Spacer size={6} />
        <Box width={44} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={7} />
      <Row align={:center}>
        <Spacer size={18} />
        <Text text="▸" text_size={:sm} text_color={:muted} />
        <Spacer size={6} />
        <Box width={34} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={7} />
      <Row align={:center}>
        <Spacer size={18} />
        <Spacer size={14} />
        <Box width={40} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
