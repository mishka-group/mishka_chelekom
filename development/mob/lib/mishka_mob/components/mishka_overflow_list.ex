defmodule MishkaMob.Components.MishkaOverflowList do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Overflow List** — items on one
  row, with the ones that do not fit collapsed into a `+N` counter.

  ## The count is declared, not measured

  The web version watches the container with a `ResizeObserver` and hides items
  until they fit. Mob reports no geometry back to `render/1` — there is no
  measurement of a rendered node available to Elixir at all — so nothing here can
  discover how many items fit.

  Rather than pretend to measure, the component takes `visible`: how many items
  to show. That is a real limitation and the moduledoc is the place to say so,
  but it is less of one than it sounds, because the useful cases are the ones
  where you already know the number — "show three tags and a +N", "show the last
  four avatars". `split/2` is the whole policy, pure and testable, and it is
  where a measured count would plug in unchanged if Mob ever reports geometry.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `visible` | integer | `3` | How many items to show. |
  | `min_visible` | integer | `1` | Never show fewer than this, even if `visible` is lower. |
  | `space` | number | `6` | Gap between items. |
  | `counter_text` | function | `&"+\#{&1}"` | Renders the counter's label from the hidden count. |
  | `on_counter` | event tag (atom) | — | `{:tap, tag}` on the counter — open a sheet with the rest. |

  Children are the items, in priority order.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaOverflowList>`). Children are the items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: overflow_list(props, children)

  @doc """
  The row.

      {overflow_list([visible: 3, on_counter: :show_all], tag_pills())}
  """
  @spec overflow_list(map() | keyword(), [map()]) :: map()
  def overflow_list(props \\ %{}, items \\ []) do
    props = Map.new(props)
    {shown, hidden} = split(items, props)
    space = Map.get(props, :space, 6)

    parts =
      shown
      |> Enum.intersperse(~MOB(<Spacer size={space} />))
      |> Kernel.++(counter(hidden, props, space))

    ~MOB"""
    <Row fill_width={true} align={:center}>
      {parts}
    </Row>
    """
  end

  @doc """
  Split items into `{shown, hidden}`.

  `min_visible` wins over `visible`, so a caller cannot accidentally collapse
  the whole list — the web component makes the same guarantee.

      iex> MishkaMob.Components.MishkaOverflowList.split([1, 2, 3, 4, 5], %{visible: 2})
      {[1, 2], [3, 4, 5]}

      iex> MishkaMob.Components.MishkaOverflowList.split([1, 2], %{visible: 5})
      {[1, 2], []}

      iex> MishkaMob.Components.MishkaOverflowList.split([1, 2, 3], %{visible: 0})
      {[1], [2, 3]}
  """
  @spec split([term()], map() | keyword()) :: {[term()], [term()]}
  def split(items, props \\ %{}) do
    props = Map.new(props)
    items = List.wrap(items)
    floor = max(Map.get(props, :min_visible, 1), 0)
    take = items |> length() |> min(max(Map.get(props, :visible, 3), floor))

    Enum.split(items, take)
  end

  defp counter([], _props, _space), do: []

  defp counter(hidden, props, space) do
    label = counter_label(hidden, props)

    node =
      ~MOB"""
      <Box background={:surface_raised} corner_radius={:radius_pill} padding={:space_sm}>
        <Text text={label} text_size={:sm} text_color={:on_surface} />
      </Box>
      """
      |> put(:on_tap, Event.handler(Map.get(props, :on_counter)))

    [~MOB(<Spacer size={space} />), node]
  end

  defp counter_label(hidden, props) do
    count = length(hidden)

    case Map.get(props, :counter_text) do
      formatter when is_function(formatter, 1) -> formatter.(count)
      text when is_binary(text) -> text
      _ -> "+#{count}"
    end
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}
end
