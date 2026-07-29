defmodule MishkaMob.Components.MishkaToggleGroup do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Toggle Group** — a row of
  toggle buttons sharing one selection, in single or multiple mode.

  Composes `MishkaMob.Components.MishkaToggle`, so a lone toggle and a grouped
  one are the same button. The group contributes the selection rule.

  ## Single and multiple are one reducer

  `press/3` is the whole behaviour, and it is worth stating rather than
  reimplementing per screen:

    * **multiple** — a set: pressing adds, pressing again removes.
    * **single** — one value, and pressing the pressed button **clears** it back
      to `nil`. That is the difference from a radio group, which cannot be
      cleared, and from a segmented control, which always keeps a selection.

  `value` is a list in multiple mode and a bare value in single mode, matching
  the web component's `value` attr.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | id, list of ids, or `nil` | `nil` | The pressed item(s). |
  | `multiple` | boolean | `false` | Allow several pressed at once. |
  | `disabled` | boolean | `false` | Disables every item. |
  | `on_change` | event tag (atom) | — | Sent as `{:tap, {tag, item_id}}`. |
  | `orientation` | `:horizontal` `:vertical` | `:horizontal` | Layout axis. |
  | `space` | number | `8` | Gap between items. |
  | `color` / `text_color` | see Toggle | — | Passed to every item. |

  Items are children built with `item/3`.

  Not ported: `name`, `form` (form plumbing), `loop` (arrow-key focus) and
  `id` / `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event
  alias MishkaMob.Components.MishkaToggle

  @item_type :mishka_toggle_item

  @doc "Composite expander (`<MishkaToggleGroup>`). Children are items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: toggle_group(props, children)

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
  The next value after pressing `id`.

  In single mode pressing the pressed button clears the group — unlike a radio
  group, which keeps its selection.

      iex> MishkaMob.Components.MishkaToggleGroup.press(nil, :a, false)
      :a
      iex> MishkaMob.Components.MishkaToggleGroup.press(:a, :a, false)
      nil
      iex> MishkaMob.Components.MishkaToggleGroup.press(:a, :b, false)
      :b
      iex> MishkaMob.Components.MishkaToggleGroup.press([:a], :b, true)
      [:a, :b]
      iex> MishkaMob.Components.MishkaToggleGroup.press([:a, :b], :a, true)
      [:b]
  """
  @spec press(term(), term(), boolean()) :: term()
  def press(value, id, true) do
    list = List.wrap(value)
    if id in list, do: List.delete(list, id), else: list ++ [id]
  end

  def press(value, id, _single), do: if(value == id, do: nil, else: id)

  @doc "The group node."
  @spec toggle_group(map() | keyword(), [map()]) :: map()
  def toggle_group(props \\ %{}, children \\ []) do
    props = Map.new(props)
    space = Map.get(props, :space, 8)

    buttons =
      children
      |> Enum.filter(&match?(%{type: @item_type}, &1))
      |> Enum.map(&button(&1.props, props))
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    if Map.get(props, :orientation, :horizontal) == :vertical do
      ~MOB(<Column fill_width={true}>
  {buttons}
</Column>)
    else
      ~MOB(<Row fill_width={true}>
  {buttons}
</Row>)
    end
  end

  @doc """
  Whether `id` is pressed for a given value, in either mode.

      iex> MishkaMob.Components.MishkaToggleGroup.pressed?(:a, :a)
      true
      iex> MishkaMob.Components.MishkaToggleGroup.pressed?([:a, :b], :b)
      true
      iex> MishkaMob.Components.MishkaToggleGroup.pressed?(nil, :a)
      false
  """
  @spec pressed?(term(), term()) :: boolean()
  def pressed?(value, id) when is_list(value), do: id in value
  def pressed?(value, id), do: value == id

  defp button(item, props) do
    MishkaToggle.toggle(
      label: Map.get(item, :label),
      pressed: pressed?(Map.get(props, :value), Map.get(item, :id)),
      disabled:
        truthy?(Map.get(props, :disabled, false)) or truthy?(Map.get(item, :disabled, false)),
      on_change: item_tag(props, Map.get(item, :id)),
      color: Map.get(props, :color, :primary),
      text_color: Map.get(props, :text_color, :on_primary)
    )
  end

  # Event.handler/2, not a hand-built {tag, id}: reached as a composite tag
  # this group's :on_change has ALREADY been widened to {screen_pid, tag}, and
  # pairing that with an id gives {{pid, tag}, id} — which the renderer
  # registers and no handle_info clause matches.
  defp item_tag(props, id), do: Event.handler(Map.get(props, :on_change), id)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
