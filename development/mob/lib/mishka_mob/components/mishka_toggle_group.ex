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
  | `space` | number | `8` | Gap between items. `0` joins them into a bar. |
  | `fill_width` | boolean | `true` | The container's width, not the items'. |
  | `id` | string | `nil` | Prefix for each item's test tag. |

  Every styling prop `MishkaMob.Components.MishkaToggle` takes — `color`,
  `text_color`, `background`, `label_color`, `padding`, `corner_radius`,
  `border_color`, `border_width`, `text_size` — is passed straight through to
  each item, so the group is styled by styling its buttons. Nothing here has a
  look of its own.

  Items are children built with `item/3`, carrying `id`, `label` and an optional
  `disabled`.

  ## Orientation decides whether an item hugs

  Horizontally, each item must hug its label: an item that fills would take the
  whole row and push its siblings off the screen. Stacked, filling is what makes
  the buttons a uniform width instead of a ragged staircase, so a vertical group
  passes `fill_width: true`. Row and Box disagree about this prop on iOS — see
  the note in `MishkaMob.Components.MishkaToggle`.

  Not ported: `name`, `form` (form plumbing), `loop` (arrow-key focus — there is
  no focus ring to move) and the `*_class` attrs.
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
    vertical? = Map.get(props, :orientation, :horizontal) == :vertical

    buttons =
      children
      |> Enum.filter(&match?(%{type: @item_type}, &1))
      |> Enum.map(&button(&1.props, props, vertical?))
      |> gaps(space)

    # The CONTAINER's own width, distinct from each item's. A group that fills
    # cannot be wrapped in a hugging track: the track would stretch to the screen
    # edge around three short buttons, which is what a segmented bar must not do.
    fill? = truthy?(Map.get(props, :fill_width, true))

    if vertical? do
      ~MOB(<Column fill_width={fill?}>
  {buttons}
</Column>)
    else
      ~MOB(<Row fill_width={fill?}>
  {buttons}
</Row>)
    end
  end

  # space: 0 emits NO spacer rather than a zero-sized one. A Spacer whose size is
  # 0 is not a 0pt gap on iOS — `fixedSize == 0` means "fill the available
  # space", so the buttons would be flung apart instead of joined. Joining them
  # into one segmented bar is exactly what space: 0 is for.
  defp gaps(buttons, 0), do: buttons
  defp gaps(buttons, space), do: Enum.intersperse(buttons, ~MOB(<Spacer size={space} />))

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

  # Every styling prop the Toggle understands, forwarded untouched when the group
  # was given one. Map.take rather than a Map.get per prop: the list is the
  # Toggle's to grow, and a group that has to be edited for every new style prop
  # silently falls behind the component it composes.
  @styling [
    :color,
    :text_color,
    :background,
    :label_color,
    :padding,
    :corner_radius,
    :border_color,
    :border_width,
    :text_size
  ]

  defp button(item, props, fill?) do
    props
    |> Map.take(@styling)
    |> Map.merge(%{
      label: Map.get(item, :label),
      pressed: pressed?(Map.get(props, :value), Map.get(item, :id)),
      disabled:
        truthy?(Map.get(props, :disabled, false)) or truthy?(Map.get(item, :disabled, false)),
      on_change: item_tag(props, Map.get(item, :id)),
      fill_width: fill?,
      id: item_id(Map.get(props, :id), Map.get(item, :id))
    })
    |> MishkaToggle.toggle()
  end

  # `<group-id>-<item-id>`, which the Toggle then suffixes with -pressed / -idle.
  # A pressed button differs by fill colour alone, and colour is not in the
  # accessibility tree, so these tags are all a device test has to read.
  defp item_id(nil, _item_id), do: nil
  defp item_id(group_id, item_id), do: "#{group_id}-#{item_id}"

  # Event.handler/2, not a hand-built {tag, id}: reached as a composite tag
  # this group's :on_change has ALREADY been widened to {screen_pid, tag}, and
  # pairing that with an id gives {{pid, tag}, id} — which the renderer
  # registers and no handle_info clause matches.
  defp item_tag(props, id), do: Event.handler(Map.get(props, :on_change), id)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
