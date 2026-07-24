defmodule MishkaMob.Components.MishkaCheckboxGroup do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Checkbox Group** — a labelled
  set of checkboxes with an optional tristate "select all" parent.

  Composes `MishkaMob.Components.MishkaCheckbox` for both the children and the
  parent, so the parent is not a special widget — it is a checkbox whose
  `indeterminate` state is derived from its children.

  ## The reducers are the component

  A checkbox group is mostly bookkeeping, and the bookkeeping is where bugs
  live, so it is exposed and tested rather than left in each caller's handler:

    * `toggle/2` — add or remove one id from the selection.
    * `select_all/2` — what the parent's tap should produce: **all**, unless
      everything is already selected, in which case **none**. A partially
      selected group fills up rather than clearing, which is what the mixed
      state is asking for.
    * `parent_state/2` — the `{checked?, indeterminate?}` the parent should
      render.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | list of ids | `[]` | The selected ids. |
  | `label` | string | `nil` | Group heading. |
  | `select_all` | boolean | `false` | Render the tristate parent. |
  | `select_all_label` | string | `"Select all"` | Parent's label. |
  | `disabled` | boolean | `false` | Disables every row, parent included. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, {tag, item_id}}`. |
  | `on_select_all` | event tag (atom) | — | Sent as `{:tap, tag}` for the parent. |
  | `space` | number | `12` | Gap between rows. |
  | `color` / `size` | see Checkbox | — | Passed to every row. |

  Items are children built with `item/3`.

  Not ported: `name` (form plumbing), `id` / `*_class`, and the
  `indicator_icon` slot — the tick and dash are drawn by the Checkbox.
  """

  import Mob.Sigil

  alias MishkaMob.Components.MishkaCheckbox

  @item_type :mishka_checkbox_item

  @doc "Composite expander (`<MishkaCheckboxGroup>`). Children are items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: checkbox_group(props, children)

  @doc "Build one item node."
  @spec item(term(), String.t(), keyword()) :: map()
  def item(id, label, opts \\ []) do
    %{
      type: @item_type,
      props: %{id: id, label: label, disabled: Keyword.get(opts, :disabled, false)},
      children: []
    }
  end

  @doc """
  Add or remove `id` from the selection, preserving order.

      iex> MishkaMob.Components.MishkaCheckboxGroup.toggle([:a], :b)
      [:a, :b]
      iex> MishkaMob.Components.MishkaCheckboxGroup.toggle([:a, :b], :a)
      [:b]
  """
  @spec toggle([term()], term()) :: [term()]
  def toggle(value, id) do
    if id in value, do: List.delete(value, id), else: value ++ [id]
  end

  @doc """
  What the parent's tap produces: everything, unless everything is already
  selected, in which case nothing.

  A partially selected group fills up rather than clearing — the mixed state is
  asking to be completed, not emptied.

      iex> MishkaMob.Components.MishkaCheckboxGroup.select_all([], [:a, :b])
      [:a, :b]
      iex> MishkaMob.Components.MishkaCheckboxGroup.select_all([:a], [:a, :b])
      [:a, :b]
      iex> MishkaMob.Components.MishkaCheckboxGroup.select_all([:a, :b], [:a, :b])
      []
  """
  @spec select_all([term()], [term()]) :: [term()]
  def select_all(value, all_ids) do
    if Enum.all?(all_ids, &(&1 in value)) and all_ids != [], do: [], else: all_ids
  end

  @doc """
  The `{checked?, indeterminate?}` the parent should render for a selection.

      iex> MishkaMob.Components.MishkaCheckboxGroup.parent_state([], [:a, :b])
      {false, false}
      iex> MishkaMob.Components.MishkaCheckboxGroup.parent_state([:a], [:a, :b])
      {false, true}
      iex> MishkaMob.Components.MishkaCheckboxGroup.parent_state([:a, :b], [:a, :b])
      {true, false}
  """
  @spec parent_state([term()], [term()]) :: {boolean(), boolean()}
  def parent_state(value, all_ids) do
    selected = Enum.count(all_ids, &(&1 in value))

    cond do
      all_ids == [] -> {false, false}
      selected == length(all_ids) -> {true, false}
      selected > 0 -> {false, true}
      true -> {false, false}
    end
  end

  @doc "The group node."
  @spec checkbox_group(map() | keyword(), [map()]) :: map()
  def checkbox_group(props \\ %{}, children \\ []) do
    props = Map.new(props)
    label = Map.get(props, :label)
    items = items(children)
    rows = Enum.map(items, &row(&1, props))
    space = Map.get(props, :space, 12)
    spaced = Enum.intersperse(rows, ~MOB(<Spacer size={space} />))

    ~MOB"""
    <Column fill_width={true}>
      <Text text={label} text_size={:sm} text_color={:muted} :if={is_binary(label)} />
      <Spacer size={10} :if={is_binary(label)} />
      {parent(props, items)}
      <Column fill_width={true}>
        {spaced}
      </Column>
    </Column>
    """
  end

  defp items(children) do
    children
    |> Enum.filter(&match?(%{type: @item_type}, &1))
    |> Enum.map(fn %{props: p} ->
      %{
        id: Map.get(p, :id),
        label: Map.get(p, :label),
        disabled: truthy?(Map.get(p, :disabled, false))
      }
    end)
  end

  defp row(item, props) do
    MishkaCheckbox.checkbox(
      label: item.label,
      checked: item.id in List.wrap(Map.get(props, :value, [])),
      disabled: truthy?(Map.get(props, :disabled, false)) or item.disabled,
      on_toggle: item_tag(props, item.id),
      color: Map.get(props, :color, :primary),
      size: Map.get(props, :size, 22)
    )
  end

  # The parent is an ordinary Checkbox whose mixed state is DERIVED from the
  # children — nothing about it is a special widget.
  defp parent(props, items) do
    if truthy?(Map.get(props, :select_all, false)) and items != [] do
      {checked?, mixed?} =
        parent_state(List.wrap(Map.get(props, :value, [])), Enum.map(items, & &1.id))

      box =
        MishkaCheckbox.checkbox(
          label: Map.get(props, :select_all_label, "Select all"),
          checked: checked?,
          indeterminate: mixed?,
          disabled: truthy?(Map.get(props, :disabled, false)),
          on_toggle: Map.get(props, :on_select_all),
          color: Map.get(props, :color, :primary),
          size: Map.get(props, :size, 22)
        )

      ~MOB"""
      <Column fill_width={true}>
        {box}
        <Spacer size={10} />
        <Box fill_width={true} height={1} background={:border} />
        <Spacer size={12} />
      </Column>
      """
    else
      ~MOB(<Column />)
    end
  end

  defp item_tag(props, id) do
    case Map.get(props, :on_change) do
      nil -> nil
      tag -> {tag, id}
    end
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
