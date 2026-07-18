defmodule DevelopmentWeb.Components.Headless.Tree do
  @moduledoc """
  Headless **tree** — hierarchical data as an accessible tree view, converted from Mantine's Tree to
  a Phoenix headless component for Mishka Chelekom.

  The whole hierarchy is rendered server-side as nested `<ul role="tree">` / `<li role="treeitem">`
  elements from `nodes` — a nested list of plain maps, so the data can come straight from a database
  or the filesystem. The `Tree` engine owns the interaction: expand/collapse, single and multiple
  selection, shift-range selection, cascading checkboxes with an indeterminate state (or strict
  per-node checks), full keyboard navigation, drag & drop with before/after/inside drop zones, and
  async child loading.

  Every node is a map with `:label` and `:value`, optionally `:children`, `:has_children` (async
  loading), `:icon`, `:disabled` and `:selectable` (default true — set `selectable: false` on a
  category parent to keep it expandable but never selected; clicking or pressing Enter on it
  toggles the branch instead). Headless ships **no icon component**, so a node's `:icon` is
  handed to the `<:node>` slot (as `icon`, alongside the whole `node` map) for the consumer to
  render; the chevron and drag glyphs come from the `<:expand_icon>` / `<:drag_icon>` slots.

  Selection, expansion and checked state are reported back through the `on_expand` / `on_collapse` /
  `on_select` / `on_check` / `on_drag_drop` / `on_load_children` event names, so the server stays the
  source of truth when it wants to be. Answer `on_load_children` by pushing
  `tree:<id>:children` once the subtree is rendered.

  Anatomy: `node`, `label`, `subtree`, `checkbox`, `expand-icon`, `drag-handle`, `label-text`,
  `loader`. Ships **no** colors, spacing or sizing — style via the `chelekom-tree*` classes, the
  `data-part` selectors and the `data-expanded`/`data-selected`/`data-checked`/`data-indeterminate`/
  `data-disabled`/`data-loading`/`data-drag-over` state attributes. Indentation is structural: each
  level offsets by `--level-offset` (per node, as `--label-offset`).

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/treeview/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/tree
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (the engine keys its server events on it)"

  attr :nodes, :list,
    required: true,
    doc:
      "Nested list of node maps: label, value, children, has_children, icon, disabled, selectable"

  attr :level_offset, :string,
    default: "1rem",
    doc:
      "Horizontal indentation of each subtree level; any CSS length (emitted as --level-offset)"

  attr :expanded, :any, default: [], doc: "Values expanded on first render, or `:all`"
  attr :selected, :list, default: [], doc: "Values selected on first render"
  attr :checked, :list, default: [], doc: "Values checked on first render"

  attr :expand_on_click, :boolean, default: true, doc: "Expand a node with children on click"
  attr :expand_on_space, :boolean, default: true, doc: "Expand a node on space key press"
  attr :check_on_space, :boolean, default: false, doc: "Check a node on space key press"
  attr :select_on_click, :boolean, default: false, doc: "Select a node on click"

  attr :multiple, :boolean, default: false, doc: "Allow more than one node to be selected"

  attr :allow_range_selection, :boolean,
    default: true,
    doc: "Select a range of nodes with Shift+click or Shift+arrow"

  attr :clear_selection_on_outside_click, :boolean,
    default: false,
    doc: "Clear the selection when clicking outside of the tree"

  attr :with_checkboxes, :boolean, default: false, doc: "Render a checkbox next to every node"

  attr :name, :string,
    default: nil,
    doc:
      "Form field name for the checkboxes (e.g. `permissions[]`). With it the checked values post natively — no JS glue"

  attr :check_strictly, :boolean,
    default: false,
    doc: "Checking a node does not cascade to its parent or children"

  attr :with_lines, :boolean,
    default: false,
    doc: "Emit `data-with-lines` on the root; the consumer draws the parent/child lines"

  attr :with_expand_icon, :boolean,
    default: true,
    doc: "Render the expand-icon part (filled by `<:expand_icon>` for nodes with children)"

  attr :keep_mounted, :boolean,
    default: true,
    doc:
      "Render collapsed subtrees in the DOM (hidden). Set false to omit them — that needs `on_expand`/`on_collapse` so the server knows to render a subtree once it opens"

  attr :draggable, :boolean, default: false, doc: "Enable drag and drop reordering"
  attr :with_drag_handle, :boolean, default: false, doc: "Drag only from an explicit handle"

  attr :allow_drop, :string,
    default: "any",
    values: ["any", "inside-only", "reorder-only"],
    doc: "Restrict which drop positions are accepted"

  attr :on_expand, :string, default: nil, doc: "Event pushed when a node is expanded"
  attr :on_collapse, :string, default: nil, doc: "Event pushed when a node is collapsed"
  attr :on_select, :string, default: nil, doc: "Event pushed when the selection changes"
  attr :on_check, :string, default: nil, doc: "Event pushed when the checked state changes"
  attr :on_drag_drop, :string, default: nil, doc: "Event pushed when a node is dropped"

  attr :on_load_children, :string,
    default: nil,
    doc: "Event pushed the first time a node with `has_children: true` is expanded"

  attr :on_target, :string, default: nil, doc: "Live component target for the pushed events"

  attr :aria_label, :string,
    default: "Tree",
    doc: "Accessible name for the tree. The APG requires one; override it per usage"

  attr :drag_handle_label, :string,
    default: "Drag handle",
    doc: "Accessible name for each drag handle"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :node_class, :any, default: nil, doc: "Extra classes for each node"
  attr :label_class, :any, default: nil, doc: "Extra classes for each node's label row"
  attr :subtree_class, :any, default: nil, doc: "Extra classes for each subtree"
  attr :checkbox_class, :any, default: nil, doc: "Extra classes for each checkbox"
  attr :expand_icon_class, :any, default: nil, doc: "Extra classes for each expand-icon part"
  attr :drag_handle_class, :any, default: nil, doc: "Extra classes for each drag handle"
  attr :label_text_class, :any, default: nil, doc: "Extra classes for each label text"
  attr :loader_class, :any, default: nil, doc: "Extra classes for each loader"
  attr :rest, :global

  slot :expand_icon,
    doc: "Shared icon rendered inside every parent node's expand-icon (e.g. a chevron)"

  slot :drag_icon, doc: "Shared icon rendered inside every drag handle"
  slot :loader, doc: "Shared busy indicator, revealed on a node's `data-loading`"

  slot :node, doc: "Renders a node label. Receives the node map plus its derived state"

  def tree(assigns) do
    assigns =
      assigns
      |> assign(:expanded_set, expanded_set(assigns.expanded, assigns.nodes))
      |> assign(:selected_set, MapSet.new(assigns.selected))
      |> assign(:checked_set, MapSet.new(assigns.checked))

    ~H"""
    <ul
      id={@id}
      role="tree"
      phx-hook="Tree"
      data-tree-root
      aria-label={@aria_label}
      {%{"aria-multiselectable" => to_string(@multiple)}}
      style={"--level-offset: #{@level_offset};"}
      data-with-lines={@with_lines}
      data-with-checkboxes={to_string(@with_checkboxes)}
      data-expanded-values={Jason.encode!(MapSet.to_list(@expanded_set))}
      data-selected-values={Jason.encode!(MapSet.to_list(@selected_set))}
      data-checked-values={Jason.encode!(MapSet.to_list(@checked_set))}
      data-expand-on-click={to_string(@expand_on_click)}
      data-expand-on-space={to_string(@expand_on_space)}
      data-check-on-space={to_string(@check_on_space)}
      data-select-on-click={to_string(@select_on_click)}
      data-allow-range-selection={to_string(@allow_range_selection)}
      data-clear-selection-on-outside-click={to_string(@clear_selection_on_outside_click)}
      data-keep-mounted={to_string(@keep_mounted)}
      data-check-strictly={to_string(@check_strictly)}
      data-multiple={to_string(@multiple)}
      data-draggable={to_string(@draggable)}
      data-with-drag-handle={to_string(@with_drag_handle)}
      data-allow-drop={@allow_drop}
      data-on-expand={@on_expand}
      data-on-collapse={@on_collapse}
      data-on-select={@on_select}
      data-on-check={@on_check}
      data-on-drag-drop={@on_drag_drop}
      data-on-load-children={@on_load_children}
      data-on-target={@on_target}
      phx-target={@on_target}
      class={["chelekom-tree", @class]}
      {@rest}
    >
      <.tree_node
        :for={{node, index} <- Enum.with_index(@nodes)}
        node={node}
        level={1}
        root_index={index}
        setsize={length(@nodes)}
        posinset={index + 1}
        expanded_set={@expanded_set}
        selected_set={@selected_set}
        checked_set={@checked_set}
        with_checkboxes={@with_checkboxes}
        with_expand_icon={@with_expand_icon}
        keep_mounted={@keep_mounted}
        draggable={@draggable}
        with_drag_handle={@with_drag_handle}
        drag_handle_label={@drag_handle_label}
        node_class={@node_class}
        label_class={@label_class}
        subtree_class={@subtree_class}
        checkbox_class={@checkbox_class}
        expand_icon_class={@expand_icon_class}
        drag_handle_class={@drag_handle_class}
        label_text_class={@label_text_class}
        loader_class={@loader_class}
        node_slot={@node}
        expand_icon={@expand_icon}
        drag_icon={@drag_icon}
        loader={@loader}
        name={@name}
      />
    </ul>
    """
  end

  attr :node, :map, required: true
  attr :level, :integer, required: true
  attr :root_index, :integer, default: nil
  attr :setsize, :integer, required: true
  attr :posinset, :integer, required: true
  attr :expanded_set, :any, required: true
  attr :selected_set, :any, required: true
  attr :checked_set, :any, required: true
  attr :with_checkboxes, :boolean, required: true
  attr :with_expand_icon, :boolean, required: true
  attr :keep_mounted, :boolean, required: true
  attr :draggable, :boolean, required: true
  attr :with_drag_handle, :boolean, required: true
  attr :drag_handle_label, :string, required: true
  attr :node_class, :any, default: nil
  attr :label_class, :any, default: nil
  attr :subtree_class, :any, default: nil
  attr :checkbox_class, :any, default: nil
  attr :expand_icon_class, :any, default: nil
  attr :drag_handle_class, :any, default: nil
  attr :label_text_class, :any, default: nil
  attr :loader_class, :any, default: nil
  attr :node_slot, :any, default: []
  attr :expand_icon, :any, default: []
  attr :drag_icon, :any, default: []
  attr :loader, :any, default: []
  attr :name, :string, default: nil

  defp tree_node(assigns) do
    node = assigns.node
    children = Map.get(node, :children) || []
    has_children = children != [] || Map.get(node, :has_children, false)

    assigns =
      assigns
      |> assign(:children, children)
      |> assign(:has_children, has_children)
      |> assign(:value, node.value)
      |> assign(:expanded, MapSet.member?(assigns.expanded_set, node.value))
      |> assign(:selected, MapSet.member?(assigns.selected_set, node.value))
      |> assign(:checked, checked?(node, children, assigns.checked_set))
      |> assign(:indeterminate, indeterminate?(node, children, assigns.checked_set))
      |> assign(:disabled, Map.get(node, :disabled, false))
      |> assign(:selectable, Map.get(node, :selectable, true))

    ~H"""
    <li
      role="treeitem"
      data-value={@value}
      data-level={@level}
      data-expanded={@has_children && to_string(@expanded)}
      data-has-children={@has_children && "true"}
      data-selected={@selected && "true"}
      data-checked={@with_checkboxes && to_string(@checked)}
      data-indeterminate={@indeterminate && "true"}
      data-disabled={@disabled && "true"}
      data-selectable={!@selectable && "false"}
      aria-disabled={@disabled && "true"}
      aria-level={@level}
      aria-setsize={@setsize}
      aria-posinset={@posinset}
      aria-expanded={@has_children && to_string(@expanded)}
      {aria_state(@with_checkboxes, @selectable, @selected, @checked, @indeterminate)}
      tabindex={if(@root_index == 0, do: "0", else: "-1")}
      style={"--label-offset: calc(var(--level-offset) * #{@level - 1});"}
      class={["chelekom-tree__node", @node_class]}
    >
      <div
        data-part="label"
        data-selected={@selected && "true"}
        draggable={@draggable && !@with_drag_handle && "true"}
        class={["chelekom-tree__label", @label_class]}
      >
        <span
          :if={@draggable && @with_drag_handle}
          data-part="drag-handle"
          draggable="true"
          aria-label={@drag_handle_label}
          class={["chelekom-tree__drag-handle", @drag_handle_class]}
        >
          {render_slot(@drag_icon)}
        </span>

        <input
          :if={@with_checkboxes}
          type="checkbox"
          data-part="checkbox"
          name={@name}
          value={@name && @value}
          checked={@checked}
          disabled={@disabled}
          tabindex="-1"
          aria-hidden="true"
          class={["chelekom-tree__checkbox", @checkbox_class]}
        />

        <span
          :if={@with_expand_icon}
          data-part="expand-icon"
          data-has-children={@has_children && "true"}
          aria-hidden="true"
          class={["chelekom-tree__expand-icon", @expand_icon_class]}
        >
          <%= if @has_children do %>
            {render_slot(@expand_icon)}
          <% end %>
        </span>

        <span data-part="label-text" class={["chelekom-tree__label-text", @label_text_class]}>
          <%= if @node_slot != [] do %>
            {render_slot(@node_slot, %{
              node: @node,
              icon: Map.get(@node, :icon),
              level: @level,
              expanded: @expanded,
              selected: @selected,
              checked: @checked,
              indeterminate: @indeterminate,
              has_children: @has_children,
              is_root: @level == 1
            })}
          <% else %>
            {label_text(@node)}
          <% end %>
        </span>

        <span data-part="loader" class={["chelekom-tree__loader", @loader_class]}>
          {render_slot(@loader)}
        </span>
      </div>

      <ul
        :if={@has_children && (@keep_mounted || @expanded) && @children != []}
        role="group"
        data-part="subtree"
        data-level={@level}
        hidden={!@expanded}
        class={["chelekom-tree__subtree", @subtree_class]}
      >
        <.tree_node
          :for={{child, index} <- Enum.with_index(@children)}
          node={child}
          level={@level + 1}
          setsize={length(@children)}
          posinset={index + 1}
          expanded_set={@expanded_set}
          selected_set={@selected_set}
          checked_set={@checked_set}
          with_checkboxes={@with_checkboxes}
          with_expand_icon={@with_expand_icon}
          keep_mounted={@keep_mounted}
          draggable={@draggable}
          with_drag_handle={@with_drag_handle}
          drag_handle_label={@drag_handle_label}
          node_class={@node_class}
          label_class={@label_class}
          subtree_class={@subtree_class}
          checkbox_class={@checkbox_class}
          expand_icon_class={@expand_icon_class}
          drag_handle_class={@drag_handle_class}
          label_text_class={@label_text_class}
          loader_class={@loader_class}
          node_slot={@node_slot}
          expand_icon={@expand_icon}
          drag_icon={@drag_icon}
          loader={@loader}
          name={@name}
        />
      </ul>
    </li>
    """
  end

  # The APG is explicit that the two selection models are exclusive: "If the selection state is
  # indicated with `aria-selected`, then `aria-checked` is not specified for any nodes." So a
  # checkbox tree reports `aria-checked` (with "mixed" for a partial parent) and nothing else.
  defp aria_state(true, _selectable, _selected, checked, indeterminate) do
    %{"aria-checked" => if(indeterminate, do: "mixed", else: to_string(checked))}
  end

  defp aria_state(false, false, _selected, _checked, _indeterminate), do: %{}

  defp aria_state(false, true, selected, _checked, _indeterminate) do
    %{"aria-selected" => to_string(selected)}
  end

  defp label_text(node), do: Map.get(node, :label) || Map.get(node, :value)

  # `:all` expands every node that has children; a list expands exactly those values.
  defp expanded_set(:all, nodes), do: nodes |> all_parent_values() |> MapSet.new()
  defp expanded_set(values, _nodes) when is_list(values), do: MapSet.new(values)
  defp expanded_set(_other, _nodes), do: MapSet.new()

  defp all_parent_values(nodes) do
    Enum.flat_map(nodes, fn node ->
      case Map.get(node, :children) || [] do
        [] -> if(Map.get(node, :has_children, false), do: [node.value], else: [])
        children -> [node.value | all_parent_values(children)]
      end
    end)
  end

  # A parent's checked state is derived from its leaves so the first render already agrees
  # with what the engine would compute — no flash of a wrong checkbox on mount.
  defp checked?(node, [], checked_set), do: MapSet.member?(checked_set, node.value)

  defp checked?(_node, children, checked_set) do
    Enum.all?(leaf_values(children), &MapSet.member?(checked_set, &1))
  end

  defp indeterminate?(_node, [], _checked_set), do: false

  defp indeterminate?(_node, children, checked_set) do
    leaves = leaf_values(children)
    checked = Enum.count(leaves, &MapSet.member?(checked_set, &1))
    checked > 0 and checked < length(leaves)
  end

  defp leaf_values(nodes) do
    Enum.flat_map(nodes, fn node ->
      case Map.get(node, :children) || [] do
        [] -> [node.value]
        children -> leaf_values(children)
      end
    end)
  end
end
