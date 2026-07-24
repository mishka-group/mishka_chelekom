defmodule MishkaMob.Components.MishkaTree do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tree** — hierarchical data as
  an expandable, selectable, optionally checkable tree.

  ## Nodes

  A node is a map with `:label` and `:value`, optionally `:children`, `:icon`
  and `:disabled`. Nesting is arbitrary:

      [
        %{label: "lib", value: "lib", children: [
          %{label: "mishka_mob", value: "lib/mishka_mob", children: [
            %{label: "app.ex", value: "lib/mishka_mob/app.ex"}
          ]}
        ]},
        %{label: "mix.exs", value: "mix.exs"}
      ]

  ## The layout is flat, and that is deliberate

  The web component nests `<ul>` inside `<li>`, and the obvious port is nested
  `Column`s. Nested columns are the wrong shape here: every level adds a layout
  node whether or not it is expanded, and a deep tree pays for branches nobody
  can see.

  Instead `visible/2` flattens the hierarchy into exactly the rows that are on
  screen — each with its depth — and the component renders one flat `Column` of
  indented rows. Collapsed subtrees cost nothing, the row list is trivial to
  assert on, and it is the same structure `LazyList` would need if a tree ever
  grows large enough to want virtualising.

  ## Checkbox state

  With `with_checkboxes`, a parent reflects its descendants: checked when they
  all are, indeterminate when only some are. `check_state/3` computes that, and
  `toggle_check/3` applies a tap the way the web engine does — cascading to
  descendants unless `check_strictly` is set.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `nodes` | list of node maps | `[]` | The hierarchy. |
  | `expanded` | list of values | `[]` | Which nodes are open. |
  | `selected` | list of values | `[]` | Which are selected. |
  | `checked` | list of values | `[]` | Which are checked. |
  | `with_checkboxes` | boolean | `false` | Render a checkbox per node. |
  | `check_strictly` | boolean | `false` | Do not cascade a check to children. |
  | `with_expand_icon` | boolean | `true` | Render the ▸/▾ disclosure. |
  | `with_lines` | boolean | `false` | Draw guide lines at each level. |
  | `level_offset` | number | `18` | Indent per depth. |
  | `on_expand` / `on_collapse` | event tags | — | `{:tap, {tag, value}}`. |
  | `on_select` / `on_check` | event tags | — | `{:tap, {tag, value}}`. |

  Not ported: `draggable` / `with_drag_handle` / `allow_drop` (no drag gesture),
  `allow_range_selection` and the `*_on_space` / keyboard attrs, `has_children`
  async loading, `keep_mounted`, `clear_selection_on_outside_click`, and
  `name`/`id`/`*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @indent 18

  @doc "Composite expander (`<MishkaTree />`). Delegates to `tree/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: tree(props)

  @doc """
  The tree.

      tree(nodes: @nodes, expanded: @open, on_expand: :open, on_select: :pick)
  """
  @spec tree(map() | keyword()) :: map()
  def tree(props \\ %{}) do
    props = Map.new(props)
    rows = props |> Map.get(:nodes, []) |> visible(Map.get(props, :expanded, []))
    nodes = Enum.map(rows, &row(&1, props))

    ~MOB"""
    <Column fill_width={true}>
      {nodes}
    </Column>
    """
  end

  @doc """
  The rows actually on screen, as `{node, depth, expandable?, expanded?}`.

  A subtree that is not expanded contributes nothing but its own parent, so the
  cost of a collapsed branch is one row rather than a hidden layout tree.

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.visible(nodes, [])
      [{%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}, 0, true, false}]

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.visible(nodes, ["a"]) |> Enum.map(&elem(&1, 0).value)
      ["a", "b"]
  """
  @spec visible([map()], [term()], non_neg_integer()) :: [
          {map(), non_neg_integer(), boolean(), boolean()}
        ]
  def visible(nodes, expanded, depth \\ 0) do
    open = MapSet.new(List.wrap(expanded))

    Enum.flat_map(List.wrap(nodes), fn node ->
      children = children(node)
      expandable? = children != []
      expanded? = expandable? and MapSet.member?(open, node.value)
      rest = if expanded?, do: visible(children, expanded, depth + 1), else: []

      [{node, depth, expandable?, expanded?} | rest]
    end)
  end

  @doc """
  Every value at or under `value`, itself included — the set a cascading check
  applies to.

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.subtree_values(nodes, "a")
      ["a", "b"]

      iex> MishkaMob.Components.MishkaTree.subtree_values([], "a")
      []
  """
  @spec subtree_values([map()], term()) :: [term()]
  def subtree_values(nodes, value) do
    case find_node(nodes, value) do
      nil -> []
      node -> all_values([node])
    end
  end

  @doc """
  A node's checkbox state: `:checked`, `:unchecked`, or `:indeterminate` when
  only some of its descendants are checked.

      iex> nodes = [%{label: "a", value: "a", children: [
      ...>   %{label: "b", value: "b"}, %{label: "c", value: "c"}]}]
      iex> MishkaMob.Components.MishkaTree.check_state(nodes, "a", ["b"])
      :indeterminate

      iex> nodes = [%{label: "a", value: "a", children: [
      ...>   %{label: "b", value: "b"}, %{label: "c", value: "c"}]}]
      iex> MishkaMob.Components.MishkaTree.check_state(nodes, "a", ["b", "c"])
      :checked

  A leaf is simply checked or not:

      iex> MishkaMob.Components.MishkaTree.check_state([%{label: "b", value: "b"}], "b", ["b"])
      :checked
  """
  @spec check_state([map()], term(), [term()]) :: :checked | :unchecked | :indeterminate
  def check_state(nodes, value, checked) do
    set = MapSet.new(List.wrap(checked))

    nodes |> find_node(value) |> node_state(value, set)
  end

  defp node_state(nil, _value, _set), do: :unchecked

  defp node_state(node, value, set) do
    case children(node) do
      [] -> if MapSet.member?(set, value), do: :checked, else: :unchecked
      kids -> parent_state(all_values(kids), set)
    end
  end

  defp parent_state(values, set) do
    checked = Enum.count(values, &MapSet.member?(set, &1))

    cond do
      checked == 0 -> :unchecked
      checked == length(values) -> :checked
      true -> :indeterminate
    end
  end

  @doc """
  Apply a checkbox tap, returning the new checked list.

  Cascades to descendants, which is what the web engine does — checking a
  directory checks what is in it. `check_strictly: true` restricts it to the one
  node.

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.toggle_check(nodes, "a", [])
      ["a", "b"]

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.toggle_check(nodes, "a", ["a", "b"])
      []

      iex> nodes = [%{label: "a", value: "a", children: [%{label: "b", value: "b"}]}]
      iex> MishkaMob.Components.MishkaTree.toggle_check(nodes, "a", [], strictly: true)
      ["a"]
  """
  @spec toggle_check([map()], term(), [term()], keyword()) :: [term()]
  def toggle_check(nodes, value, checked, opts \\ []) do
    affected =
      if Keyword.get(opts, :strictly, false),
        do: [value],
        else: subtree_values(nodes, value)

    affected = if affected == [], do: [value], else: affected
    current = List.wrap(checked)
    on? = check_state(nodes, value, current) != :checked

    if on? do
      Enum.uniq(current ++ affected)
    else
      current -- affected
    end
  end

  @doc """
  Expand or collapse `value` in an expanded list.

      iex> MishkaMob.Components.MishkaTree.toggle_expand("a", [])
      ["a"]

      iex> MishkaMob.Components.MishkaTree.toggle_expand("a", ["a", "b"])
      ["b"]
  """
  @spec toggle_expand(term(), [term()]) :: [term()]
  def toggle_expand(value, expanded) do
    expanded = List.wrap(expanded)

    if value in expanded, do: expanded -- [value], else: expanded ++ [value]
  end

  defp find_node(nodes, value) do
    Enum.find_value(List.wrap(nodes), fn node ->
      if node.value == value, do: node, else: find_node(children(node), value)
    end)
  end

  defp all_values(nodes) do
    Enum.flat_map(List.wrap(nodes), fn node -> [node.value | all_values(children(node))] end)
  end

  defp children(node), do: node |> Map.get(:children) |> List.wrap()

  # ── Rendering ───────────────────────────────────────────────────────────────

  defp row({node, depth, expandable?, expanded?}, props) do
    disabled? = truthy?(Map.get(node, :disabled, false))
    selected? = node.value in List.wrap(Map.get(props, :selected, []))
    offset = Map.get(props, :level_offset, @indent) * depth

    parts =
      guides(depth, props) ++
        [disclosure(node, expandable?, expanded?, props, disabled?)] ++
        checkbox(node, props, disabled?) ++
        [icon(node), label(node, selected?, disabled?)]

    ~MOB"""
    <Box
      fill_width={true}
      background={if(selected?, do: :surface_raised, else: :transparent)}
      corner_radius={:radius_sm}
      padding={6}
    >
      <Row fill_width={true} align={:center}>
        <Spacer size={offset} />
        {parts}
      </Row>
    </Box>
    """
    |> put(:on_tap, select_handler(node, props, disabled?))
  end

  # Guide lines are drawn per level so they line up with the indent.
  defp guides(depth, props) do
    if truthy?(Map.get(props, :with_lines, false)) and depth > 0 do
      step = Map.get(props, :level_offset, @indent)

      Enum.map(1..depth, fn _ ->
        ~MOB"""
        <Row>
          <Box width={1} height={20} background={:border} />
          <Spacer size={step - 1} />
        </Row>
        """
      end)
    else
      []
    end
  end

  defp disclosure(node, expandable?, expanded?, props, disabled?) do
    cond do
      not truthy?(Map.get(props, :with_expand_icon, true)) ->
        ~MOB(<Spacer size={0} />)

      not expandable? ->
        # A leaf still reserves the arrow's width, so labels line up.
        ~MOB(<Spacer size={20} />)

      true ->
        glyph = if expanded?, do: "▾", else: "▸"
        tag = if expanded?, do: :on_collapse, else: :on_expand
        ink = if disabled?, do: :muted, else: :on_surface

        ~MOB"""
        <Box padding={2}>
          <Text text={glyph} text_size={:sm} text_color={ink} />
        </Box>
        """
        |> put(:on_tap, tag_handler(props, tag, node.value, disabled?))
    end
  end

  defp checkbox(node, props, disabled?) do
    if truthy?(Map.get(props, :with_checkboxes, false)) do
      state = check_state(Map.get(props, :nodes, []), node.value, Map.get(props, :checked, []))

      glyph =
        case state do
          :checked -> "☑"
          :indeterminate -> "⊟"
          :unchecked -> "☐"
        end

      ink = if disabled?, do: :muted, else: :on_surface

      box =
        ~MOB"""
        <Box padding={2}>
          <Text text={glyph} text_size={:base} text_color={ink} />
        </Box>
        """
        |> put(:on_tap, tag_handler(props, :on_check, node.value, disabled?))

      [box, ~MOB(<Spacer size={4} />)]
    else
      []
    end
  end

  defp icon(node) do
    case Map.get(node, :icon) do
      nil ->
        ~MOB(<Spacer size={0} />)

      glyph ->
        ~MOB"""
        <Row>
          <Text text={glyph} text_size={:sm} text_color={:muted} />
          <Spacer size={6} />
        </Row>
        """
    end
  end

  defp label(node, selected?, disabled?) do
    ink =
      cond do
        disabled? -> :muted
        selected? -> :primary
        true -> :on_surface
      end

    weight = if selected?, do: :semibold, else: :regular

    ~MOB(<Text text={node.label} text_size={:base} text_color={ink} weight={weight} />)
  end

  defp select_handler(node, props, disabled?),
    do: tag_handler(props, :on_select, node.value, disabled?)

  defp tag_handler(_props, _key, _value, true), do: nil

  defp tag_handler(props, key, value, _disabled?) do
    case Map.get(props, key) do
      nil -> nil
      tag -> Event.handler({tag, value})
    end
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
