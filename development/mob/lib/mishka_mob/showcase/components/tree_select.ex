defmodule MishkaMob.Showcase.Components.TreeSelect do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTreeSelect`.

  Every example carries its own `id` and its own assigns, so a device test can
  say which trigger it tapped and which panel answered.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaTree, only: [tree: 1]

  alias MishkaMob.Components.MishkaTree
  alias MishkaMob.Showcase.Example

  @files [
    %{
      label: "lib",
      value: "lib",
      icon: "📁",
      children: [
        %{
          label: "components",
          value: "lib/components",
          icon: "📁",
          children: [
            %{
              label: "tree_select.ex",
              value: "lib/components/tree_select.ex",
              icon: "📄",
              meta: "3 KB"
            }
          ]
        },
        %{label: "app.ex", value: "lib/app.ex", icon: "📄", meta: "12 KB"}
      ]
    },
    %{label: "mix.exs", value: "mix.exs", icon: "📄", meta: "1 KB"}
  ]

  @owners [
    %{label: "Ana", value: "ana", icon: "👤"},
    %{label: "Bo", value: "bo", icon: "👤"},
    %{label: "Cy", value: "cy", icon: "👤", disabled: true}
  ]

  @regions [
    %{
      label: "Europe",
      value: "eu",
      icon: "🌍",
      children: [%{label: "Berlin", value: "eu/berlin", icon: "📍"}]
    },
    %{label: "Asia Pacific", value: "apac", icon: "🌏"}
  ]

  @long_label "lib/mishka_mob/components/mishka_tree_select.ex"

  @impl true
  def entry do
    %{
      slug: :tree_select,
      name: "Tree Select",
      category: "Forms",
      order: 18,
      description: "A trigger showing the selection, with a tree in a panel beneath it."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:ts_file_open, false)
    |> Mob.Socket.assign(:ts_file_expanded, ["lib"])
    |> Mob.Socket.assign(:ts_file_label, nil)
    |> Mob.Socket.assign(:ts_team_open, false)
    |> Mob.Socket.assign(:ts_team_label, nil)
    |> Mob.Socket.assign(:ts_long_open, false)
    |> Mob.Socket.assign(:ts_off_open, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Trigger and panel",
        description:
          "Tap the trigger to open the tree, tap a file to choose it. Expanding a branch is " <>
            "not a choice, so the panel stays open until something is picked.",
        code: ~S"""
        <MishkaTreeSelect
          label={@picked}
          open={@open?}
          on_toggle={:toggle}
          id="ts-file"
        >
          {[tree(nodes: @nodes, id: "ts-file-tree", expanded: @expanded,
                 on_expand: :open_node, on_collapse: :close_node, on_select: :pick)]}
        </MishkaTreeSelect>

        def handle_info({:tap, :toggle}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
        end

        # The tree owns the selection; the screen shows it and closes the panel,
        # which is the whole point of a select.
        def handle_info({:tap, {:pick, value}}, socket) do
          {:noreply,
           socket
           |> Mob.Socket.assign(:picked, value)
           |> Mob.Socket.assign(:open?, false)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect
              label={@ts_file_label}
              placeholder="Choose a file…"
              open={@ts_file_open}
              on_toggle={:ts_file_toggle}
              id="ts-file"
            >
              {[
                 tree(
                   nodes: files(),
                   id: "ts-file-tree",
                   expanded: @ts_file_expanded,
                   with_lines: true,
                   on_expand: :ts_file_expand,
                   on_collapse: :ts_file_collapse,
                   on_select: :ts_file_pick
                 )
               ]}
            </MishkaTreeSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Placeholder",
        description:
          "With nothing selected the trigger shows `placeholder`, muted. Picking replaces it " <>
            "with the label — the tag flips from ts-team-placeholder to ts-team-value.",
        code: ~S"""
        <MishkaTreeSelect
          label={@owner}
          placeholder="Choose an owner…"
          open={@open?}
          on_toggle={:toggle}
          id="ts-team"
        >{[tree(nodes: @people, id: "ts-team-tree", on_select: :pick)]}</MishkaTreeSelect>

        # A tree reports its node's VALUE; what the trigger shows is the label,
        # so the screen maps one to the other.
        def handle_info({:tap, {:pick, value}}, socket) do
          {:noreply,
           socket
           |> Mob.Socket.assign(:owner, name_of(value))
           |> Mob.Socket.assign(:open?, false)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect
              label={@ts_team_label}
              placeholder="Choose an owner…"
              open={@ts_team_open}
              on_toggle={:ts_team_toggle}
              id="ts-team"
            >
              {[tree(nodes: owners(), id: "ts-team-tree", on_select: :ts_team_pick)]}
            </MishkaTreeSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Open from the start",
        description:
          "`open` is a plain prop, so a panel can be rendered expanded. This one has no " <>
            "on_toggle at all, which is what an inline picker looks like: it never closes.",
        code: ~S"""
        <MishkaTreeSelect label="Europe" open={true} id="ts-pinned">
          {[tree(nodes: @regions, id: "ts-pinned-tree", expanded: ["eu"])]}
        </MishkaTreeSelect>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect label="Europe" open={true} id="ts-pinned">
              {[tree(nodes: regions(), id: "ts-pinned-tree", expanded: ["eu"])]}
            </MishkaTreeSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "A long selection",
        description:
          "A whole path in a phone-width trigger. It is ellipsised on one line, and the caret " <>
            "keeps its place at the end of the row.",
        code: ~S"""
        # No prop for this: the value sits in a weighted Box with max_lines: 1,
        # because a Text squeezed narrower than its content wraps CHARACTER BY
        # CHARACTER, and an unweighted sibling would have starved the caret.
        <MishkaTreeSelect
          label="lib/mishka_mob/components/mishka_tree_select.ex"
          open={@open?}
          on_toggle={:toggle}
          id="ts-long"
        >{[tree(nodes: @nodes, id: "ts-long-tree")]}</MishkaTreeSelect>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect
              label={long_label()}
              open={@ts_long_open}
              on_toggle={:ts_long_toggle}
              id="ts-long"
            >
              {[tree(nodes: long_nodes(), id: "ts-long-tree")]}
            </MishkaTreeSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted, and the trigger is unwired — tapping it cannot open the panel.",
        code: ~S"""
        <MishkaTreeSelect label="mix.exs" disabled={true} on_toggle={:toggle} id="ts-off">
          {[tree(nodes: @nodes, id: "ts-off-tree")]}
        </MishkaTreeSelect>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTreeSelect
              label="mix.exs"
              open={@ts_off_open}
              disabled={true}
              on_toggle={:ts_off_toggle}
              id="ts-off"
            >
              {[tree(nodes: archive(), id: "ts-off-tree")]}
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
        name: "label",
        type: "string",
        default: "nil",
        description: "The current selection. Empty or nil falls back to the placeholder."
      },
      %{
        name: "placeholder",
        type: "string",
        default: "\"Select…\"",
        description: "Trigger text when nothing is selected."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the panel is shown. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes the trigger and unwires it."
      },
      %{
        name: "on_toggle",
        type: "event tag",
        default: "—",
        description: "{:tap, tag} from the trigger. The panel has no dismissal of its own."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description:
          "Tags <id>-trigger-open/-closed/-disabled, <id>-value or -placeholder, " <>
            "<id>-caret and <id>-panel."
      },
      %{
        name: "children",
        type: "nodes",
        default: "[]",
        description: "The panel's content — normally a MishkaTree, but anything renders."
      },
      %{
        name: "display/2",
        type: "helper",
        default: "—",
        description: "The trigger's text: the label, or the placeholder when it is nil or \"\"."
      }
    ]
  end

  @impl true
  def handle(:ts_file_toggle, socket), do: flip(socket, :ts_file_open)
  def handle({:ts_file_expand, value}, socket), do: expand_file(socket, value)
  def handle({:ts_file_collapse, value}, socket), do: expand_file(socket, value)

  # Picking closes the panel, which is what separates a select from a tree.
  def handle({:ts_file_pick, value}, socket) do
    socket
    |> Mob.Socket.assign(:ts_file_label, value)
    |> Mob.Socket.assign(:ts_file_open, false)
  end

  def handle(:ts_team_toggle, socket), do: flip(socket, :ts_team_open)

  # A tree reports the node's VALUE; the trigger shows a human label, so the
  # screen is where the two meet.
  def handle({:ts_team_pick, value}, socket) do
    socket
    |> Mob.Socket.assign(:ts_team_label, owner_name(value))
    |> Mob.Socket.assign(:ts_team_open, false)
  end

  def handle(:ts_long_toggle, socket), do: flip(socket, :ts_long_open)

  # Wired, and never delivered: a disabled trigger drops its handler, so this
  # clause is what proves it rather than an example that simply omitted one.
  def handle(:ts_off_toggle, socket), do: flip(socket, :ts_off_open)

  def handle(_tag, socket), do: socket

  defp expand_file(socket, value) do
    Mob.Socket.assign(
      socket,
      :ts_file_expanded,
      MishkaTree.toggle_expand(value, socket.assigns.ts_file_expanded)
    )
  end

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  defp files, do: @files
  defp owners, do: @owners
  defp regions, do: @regions
  defp archive, do: [%{label: "archive.zip", value: "archive.zip", icon: "🗜"}]
  defp long_label, do: @long_label

  # The one file the long label names, so the panel is about the same thing the
  # trigger is.
  defp long_nodes,
    do: [%{label: "mishka_tree_select.ex", value: @long_label, icon: "📄", meta: "6 KB"}]

  defp owner_name(value) do
    case Enum.find(@owners, &(&1.value == value)) do
      nil -> value
      owner -> owner.label
    end
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
        padding={6}
      >
        <Row fill_width={true} align={:center}>
          <Box width={46} height={8} background={:muted} corner_radius={:radius_sm} />
          <Spacer weight={1} />
          <Text text="▴" text_size={:sm} text_color={:muted} />
        </Row>
      </Box>
      <Spacer size={6} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
        padding={6}
      >
        <Column fill_width={true}>
          <Row align={:center}>
            <Text text="▾" text_size={:sm} text_color={:muted} />
            <Spacer size={6} />
            <Box width={38} height={8} background={:muted} corner_radius={:radius_sm} />
          </Row>
          <Spacer size={7} />
          <Row align={:center}>
            <Spacer size={18} />
            <Box width={30} height={8} background={:muted} corner_radius={:radius_sm} />
          </Row>
        </Column>
      </Box>
    </Column>
    """
  end
end
