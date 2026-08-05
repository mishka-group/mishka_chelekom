defmodule MishkaMob.Showcase.Components.Tree do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTree` and
  `MishkaMob.Components.MishkaTreeSelect`.

  Every example keeps its **own** assigns and its **own** `id`. Sharing either
  would make the page untestable: two trees driven by one `expanded` list move
  together, and two trees with one `id` emit the same test tags, so nothing on a
  device could say which one it just touched.

  The first two examples deliberately leave `id` at its default (`"tree"`) —
  that is the pair `TreeTest.kt` addresses by index, and it is also the only
  place the default prefix is exercised.

  Both spellings of a hierarchy are on the page. The first example and the tree
  select write theirs as `<MishkaTreeNode>` markup, which is the form to reach
  for when the shape is known. The rest pass `nodes`, because their reducers
  need the hierarchy as data regardless — `toggle_check/4`, `select_range/4`
  and `toggle_expand/3` all take the node list — and the async example builds
  its nodes from a flag, which is not something markup can do.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

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

  # Two `selectable: false` headers over pickable leaves — the shape a range
  # selection has something to say about, because the headers drop out of the
  # middle of a run rather than joining it, and so does the disabled row.
  @people [
    %{
      label: "DESIGN",
      value: "design",
      selectable: false,
      children: [
        %{label: "Ada", value: "ada"},
        %{label: "Bo", value: "bo"},
        %{label: "Cy", value: "cy"}
      ]
    },
    %{
      label: "ENGINEERING",
      value: "eng",
      selectable: false,
      children: [
        %{label: "Dee", value: "dee"},
        %{label: "Eve", value: "eve", disabled: true},
        %{label: "Fen", value: "fen"}
      ]
    }
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
    |> Mob.Socket.assign(:t1_expanded, ["lib"])
    |> Mob.Socket.assign(:t1_selected, [])
    |> Mob.Socket.assign(:t2_expanded, ["lib"])
    |> Mob.Socket.assign(:t2_checked, [])
    |> Mob.Socket.assign(:t3_selected, [])
    |> Mob.Socket.assign(:t3_anchor, nil)
    |> Mob.Socket.assign(:t4_expanded, ["project"])
    |> Mob.Socket.assign(:t4_loading, [])
    |> Mob.Socket.assign(:t4_loaded, false)
    |> Mob.Socket.assign(:t4_selected, [])
    |> Mob.Socket.assign(:t5_expanded, :all)
    |> Mob.Socket.assign(:t5_checked, [])
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
          "Tapping a folder opens it, tapping a file picks it — one tap does one thing, and " <>
            "the branch wins where there is one.",
        code: ~S"""
        <MishkaTree
          nodes={@nodes}
          expanded={@expanded}
          selected={@selected}
          with_lines={true}
          expand_on_click={true}
          select_on_click={true}
          on_expand={:open}
          on_collapse={:close}
          on_select={:pick}
        />

        def handle_info({:tap, {:open, value}}, socket) do
          {:noreply,
           Mob.Socket.assign(
             socket,
             :expanded,
             MishkaTree.toggle_expand(value, socket.assigns.expanded)
           )}
        end

        def handle_info({:tap, {:pick, value}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :selected, MishkaTree.toggle_select(value, socket.assigns.selected))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              nodes={nodes()}
              expanded={@t1_expanded}
              selected={@t1_selected}
              with_lines={true}
              expand_on_click={true}
              select_on_click={true}
              on_expand={:t1_open}
              on_collapse={:t1_close}
              on_select={:t1_pick}
            />
            <Spacer size={10} />
            <Text text={"Picked: " <> summary(@t1_selected)} text_size={:sm} text_color={:muted} />
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
          checked={@ticked}
          with_checkboxes={true}
          select_on_click={false}
          on_check={:check}
        />

        # Checking a directory checks what is inside it, which is what the web does.
        def handle_info({:tap, {:check, value}}, socket) do
          {:noreply,
           Mob.Socket.assign(socket, :ticked, MishkaTree.toggle_check(@nodes, value, socket.assigns.ticked))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              nodes={nodes()}
              expanded={@t2_expanded}
              checked={@t2_checked}
              with_checkboxes={true}
              with_expand_icon={true}
              select_on_click={false}
              on_expand={:t2_open}
              on_collapse={:t2_close}
              on_check={:t2_check}
            />
            <Spacer size={10} />
            <Text text={"Checked: " <> summary(@t2_checked)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple, and hold for a range",
        description:
          "Shift+click has no finger, so a long press is the range: tap one name, hold " <>
            "another, and everything selectable between them comes with it. The headers and " <>
            "the disabled row drop out of the middle.",
        code: ~S"""
        <MishkaTree
          id="multi"
          nodes={@people}
          expanded={:all}
          selected={@picked}
          with_expand_icon={false}
          expand_on_click={false}
          allow_range_selection={true}
          on_select={:pick}
          on_range_select={:range}
        />

        # multiple: true adds and removes; without it a tap replaces.
        def handle_info({:tap, {:pick, value}}, socket) do
          {:noreply,
           socket
           |> Mob.Socket.assign(:picked, MishkaTree.toggle_select(value, socket.assigns.picked, multiple: true))
           |> Mob.Socket.assign(:anchor, value)}
        end

        # The hold is Shift+click: the run goes from the last tap to here.
        def handle_info({:tap, {:range, value}}, socket) do
          run = MishkaTree.select_range(@people, :all, socket.assigns.anchor, value)
          {:noreply, Mob.Socket.assign(socket, :picked, Enum.uniq(socket.assigns.picked ++ run))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              id="multi"
              nodes={people()}
              expanded={:all}
              selected={@t3_selected}
              with_expand_icon={false}
              expand_on_click={false}
              select_on_click={true}
              allow_range_selection={true}
              on_select={:t3_pick}
              on_range_select={:t3_range}
            />
            <Spacer size={10} />
            <Row fill_width={true} align={:center}>
              <Box weight={1} fill_width={true}>
                <Text
                  text={"Team: " <> summary(@t3_selected)}
                  text_size={:sm}
                  text_color={:muted}
                  max_lines={1}
                />
              </Box>
              <Spacer size={8} />
              <Box
                padding={6}
                fill_width={false}
                corner_radius={:radius_sm}
                background={:surface_raised}
                on_tap={{self(), :t3_clear}}
                id="multi-clear"
              >
                <Text text="Clear" text_size={:sm} text_color={:on_surface} max_lines={1} />
              </Box>
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Headers, and children on demand",
        description:
          "PROJECT is selectable: false — a header that opens its branch instead of pretending " <>
            "to be a destination. assets claims children it has not fetched, so the first tap " <>
            "reports on_load_children and the row shows a loader until they land.",
        code: ~S"""
        <MishkaTree
          id="async"
          nodes={remote_nodes(@loaded?)}
          expanded={@open}
          selected={@picked}
          loading={@loading}
          on_expand={:open_node}
          on_collapse={:close_node}
          loader_icon="⟳"
          on_load_children={:fetch}
          on_select={:pick}
        />

        # has_children: true with no :children — the first tap is a request, not
        # a state change, so it arrives as its own event.
        def handle_info({:tap, {:fetch, value}}, socket) do
          Process.send_after(self(), {:tap, {:arrived, value}}, 1_000)
          {:noreply, Mob.Socket.assign(socket, :loading, [value])}
        end

        def handle_info({:tap, {:arrived, value}}, socket) do
          {:noreply,
           socket
           |> Mob.Socket.assign(:loaded?, true)
           |> Mob.Socket.assign(:loading, [])
           |> Mob.Socket.assign(:open, [value | socket.assigns.open])}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              id="async"
              nodes={remote_nodes(@t4_loaded)}
              expanded={@t4_expanded}
              selected={@t4_selected}
              loading={@t4_loading}
              on_expand={:t4_open}
              on_collapse={:t4_close}
              loader_icon="⟳"
              on_load_children={:t4_fetch}
              on_select={:t4_pick}
            />
            <Spacer size={10} />
            <Row fill_width={true} align={:center}>
              <Box weight={1} fill_width={true}>
                <Text
                  text={fetch_note(@t4_loading, @t4_loaded)}
                  text_size={:sm}
                  text_color={:muted}
                  max_lines={1}
                />
              </Box>
              <Spacer size={8} />
              <Box
                padding={6}
                fill_width={false}
                corner_radius={:radius_sm}
                background={:surface_raised}
                on_tap={{self(), :t4_reset}}
                id="async-reset"
              >
                <Text text="Forget" text_size={:sm} text_color={:on_surface} max_lines={1} />
              </Box>
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Strict checks, everything open",
        description:
          "expanded: :all opens every branch, check_strictly keeps a tick on the row it was " <>
            "made on, and the disclosure glyphs are whatever you say they are.",
        code: ~S"""
        <MishkaTree
          id="strict"
          nodes={@nodes}
          expanded={:all}
          checked={@ticked}
          with_checkboxes={true}
          check_strictly={true}
          expand_icon="+"
          collapse_icon="−"
          level_offset={28}
          on_expand={:open}
          on_collapse={:close}
          on_check={:tick}
        />

        # strictly: true — the tick stays on the row it was made on.
        def handle_info({:tap, {:tick, value}}, socket) do
          next = MishkaTree.toggle_check(@nodes, value, socket.assigns.ticked, strictly: true)
          {:noreply, Mob.Socket.assign(socket, :ticked, next)}
        end

        # :all is a shorthand, not a state — pass the nodes so it can be
        # materialised before the branch is closed.
        def handle_info({:tap, {:close, value}}, socket) do
          next = MishkaTree.toggle_expand(value, socket.assigns.open, @nodes)
          {:noreply, Mob.Socket.assign(socket, :open, next)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTree
              id="strict"
              nodes={nodes()}
              expanded={@t5_expanded}
              checked={@t5_checked}
              with_checkboxes={true}
              check_strictly={true}
              expand_icon="+"
              collapse_icon="−"
              level_offset={28}
              on_expand={:t5_open}
              on_collapse={:t5_close}
              on_check={:t5_check}
            />
            <Spacer size={10} />
            <Text text={"Strictly: " <> summary(@t5_checked)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Tree select",
        description: "A trigger showing the selection, with the tree in a panel beneath it.",
        code: ~S"""
        <MishkaTreeSelect label={@picked} open={@open} on_toggle={:ts_toggle}>
          <MishkaTree id="ts" nodes={@nodes} on_select={:ts_pick} />
        </MishkaTreeSelect>

        # Picking closes the panel, which is the whole point of a select.
        def handle_info({:tap, {:ts_pick, value}}, socket) do
          {:noreply,
           socket
           |> Mob.Socket.assign(:picked, value)
           |> Mob.Socket.assign(:open, false)}
        end
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
              <MishkaTree
                id="ts"
                nodes={nodes()}
                expanded={@ts_expanded}
                select_on_click={true}
                on_expand={:ts_open_node}
                on_collapse={:ts_close_node}
                on_select={:ts_pick}
              />
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
        description:
          "label, value, children, icon, meta, disabled, selectable (a header), has_children (async)."
      },
      %{
        name: "id",
        type: "string",
        default: "\"tree\"",
        description: "Prefix for every test tag — row, toggle, check and the state tags."
      },
      %{
        name: "expanded",
        type: "list of values or :all",
        default: "[]",
        description: ":all opens every branch; expanded_values/1 materialises it."
      },
      %{
        name: "selected / checked / loading",
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
        name: "with_expand_icon / expand_icon / collapse_icon",
        type: "boolean / strings",
        default: "true / ▸ / ▾",
        description: "The disclosure, and the glyphs it draws."
      },
      %{
        name: "loader_icon",
        type: "string",
        default: "…",
        description: "Drawn on a row that is in `loading` — the port of the loader slot."
      },
      %{
        name: "with_lines / level_offset",
        type: "boolean / number",
        default: "false / 18",
        description: "Guide lines per level; indent per depth."
      },
      %{
        name: "expand_on_click / select_on_click",
        type: "boolean",
        default: "true / true",
        description: "What a row tap means. The branch wins where there is one."
      },
      %{
        name: "allow_range_selection",
        type: "boolean",
        default: "true",
        description: "A long press reports on_range_select — the touch Shift+click."
      },
      %{
        name: "on_expand / on_collapse / on_select / on_check",
        type: "event tags",
        default: "—",
        description: "Each fires {:tap, {tag, value}}."
      },
      %{
        name: "on_load_children / on_range_select",
        type: "event tags",
        default: "—",
        description: "First tap on a has_children branch; a long press on a row."
      },
      %{
        name: "visible/2",
        type: "helper",
        default: "—",
        description: "The rows on screen, with depth — the whole layout in one list."
      },
      %{
        name: "check_state/4 · toggle_check/4 · toggle_expand/3",
        type: "helpers",
        default: "—",
        description: "The expand and check transitions, as pure functions."
      },
      %{
        name: "toggle_select/3 · select_range/4",
        type: "helpers",
        default: "—",
        description: "Single, multiple and range selection — the modes the web keeps as attrs."
      },
      %{
        name: "row_tag/2 · toggle_tag/2 · check_tag/2 · state_tag/3",
        type: "helpers",
        default: "—",
        description: "The test tags, so a device suite never hardcodes the shape."
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
  def handle({:t1_open, value}, socket), do: t1_toggle(socket, value)
  def handle({:t1_close, value}, socket), do: t1_toggle(socket, value)

  def handle({:t1_pick, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :t1_selected,
        MishkaTree.toggle_select(value, socket.assigns.t1_selected)
      )

  def handle({:t2_open, value}, socket), do: t2_toggle(socket, value)
  def handle({:t2_close, value}, socket), do: t2_toggle(socket, value)

  def handle({:t2_check, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :t2_checked,
        MishkaTree.toggle_check(@nodes, value, socket.assigns.t2_checked)
      )

  # A tap is also the anchor: the next long press measures its range from here,
  # which is what Shift+click does with the last plain click.
  def handle({:t3_pick, value}, socket) do
    socket
    |> Mob.Socket.assign(
      :t3_selected,
      MishkaTree.toggle_select(value, socket.assigns.t3_selected, multiple: true)
    )
    |> Mob.Socket.assign(:t3_anchor, value)
  end

  def handle({:t3_range, value}, socket) do
    run = MishkaTree.select_range(@people, :all, socket.assigns.t3_anchor, value)

    Mob.Socket.assign(socket, :t3_selected, Enum.uniq(socket.assigns.t3_selected ++ run))
  end

  def handle(:t3_clear, socket) do
    socket
    |> Mob.Socket.assign(:t3_selected, [])
    |> Mob.Socket.assign(:t3_anchor, nil)
  end

  def handle({:t4_open, value}, socket), do: t4_toggle(socket, value)
  def handle({:t4_close, value}, socket), do: t4_toggle(socket, value)

  # The whole point of on_load_children: the branch is not opened here. It sits
  # closed and busy until the data lands, so the loader has something to say.
  def handle({:t4_fetch, value}, socket) do
    # Long enough that the loader is something a person — and a device test —
    # can actually catch sight of, short enough that the page is not annoying.
    Process.send_after(self(), {:tap, {:t4_arrived, value}}, 1_200)

    Mob.Socket.assign(socket, :t4_loading, [value])
  end

  def handle({:t4_arrived, value}, socket) do
    socket
    |> Mob.Socket.assign(:t4_loaded, true)
    |> Mob.Socket.assign(:t4_loading, [])
    |> Mob.Socket.assign(:t4_expanded, Enum.uniq([value | socket.assigns.t4_expanded]))
  end

  def handle({:t4_pick, value}, socket),
    do: Mob.Socket.assign(socket, :t4_selected, [value])

  # Throwing the fetched children away again, so the loading state is something
  # this page can be made to show a second time rather than once per boot.
  def handle(:t4_reset, socket) do
    socket
    |> Mob.Socket.assign(:t4_loaded, false)
    |> Mob.Socket.assign(:t4_loading, [])
    |> Mob.Socket.assign(:t4_selected, [])
    |> Mob.Socket.assign(:t4_expanded, ["project"])
  end

  def handle({:t5_open, value}, socket), do: t5_toggle(socket, value)
  def handle({:t5_close, value}, socket), do: t5_toggle(socket, value)

  def handle({:t5_check, value}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :t5_checked,
        MishkaTree.toggle_check(@nodes, value, socket.assigns.t5_checked, strictly: true)
      )

  def handle(:ts_toggle, socket),
    do: Mob.Socket.assign(socket, :ts_open, not socket.assigns.ts_open)

  def handle({:ts_open_node, value}, socket), do: ts_toggle(socket, value)
  def handle({:ts_close_node, value}, socket), do: ts_toggle(socket, value)

  # Picking closes the panel, which is the whole point of a select.
  def handle({:ts_pick, value}, socket) do
    socket
    |> Mob.Socket.assign(:ts_label, value)
    |> Mob.Socket.assign(:ts_open, false)
  end

  def handle(_tag, socket), do: socket

  defp t1_toggle(socket, value),
    do:
      Mob.Socket.assign(
        socket,
        :t1_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.t1_expanded)
      )

  defp t2_toggle(socket, value),
    do:
      Mob.Socket.assign(
        socket,
        :t2_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.t2_expanded)
      )

  defp t4_toggle(socket, value),
    do:
      Mob.Socket.assign(
        socket,
        :t4_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.t4_expanded)
      )

  # `:all` cannot say "everything except this one", so the nodes come along and
  # the shorthand is materialised before the branch is closed.
  defp t5_toggle(socket, value),
    do:
      Mob.Socket.assign(
        socket,
        :t5_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.t5_expanded, @nodes)
      )

  defp ts_toggle(socket, value),
    do:
      Mob.Socket.assign(
        socket,
        :ts_expanded,
        MishkaTree.toggle_expand(value, socket.assigns.ts_expanded)
      )

  defp nodes, do: @nodes
  defp people, do: @people

  @doc false
  # The async branch is one node in two shapes: a claim, and then the real
  # thing. Building it from the flag rather than mutating a stored tree keeps
  # the example a pure function of its assigns, like the component it shows.
  def remote_nodes(loaded?) do
    assets =
      if loaded? do
        %{
          label: "assets",
          value: "assets",
          icon: "📁",
          children: [
            %{label: "logo.png", value: "assets/logo.png", icon: "🖼", meta: "18 KB"},
            %{label: "app.css", value: "assets/app.css", icon: "🎨", meta: "6 KB"}
          ]
        }
      else
        %{label: "assets", value: "assets", icon: "📁", has_children: true}
      end

    [
      %{
        label: "PROJECT",
        value: "project",
        selectable: false,
        children: [
          %{label: "README.md", value: "readme", icon: "📄", meta: "2 KB"},
          assets
        ]
      }
    ]
  end

  defp fetch_note([_ | _], _loaded?), do: "Fetching assets…"
  defp fetch_note([], true), do: "Fetched: 2 files"
  defp fetch_note([], false), do: "Fetched: nothing yet"

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
