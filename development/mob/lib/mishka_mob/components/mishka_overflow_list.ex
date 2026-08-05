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
  | `id` | string | `nil` | Test tag; items get `<id>-item-<n>`, the counter `<id>-counter`. |

  Children are the items, in priority order.

  Not ported: `on_change` (the web pushes the hidden count to the server on
  every resize; there is no resize here to push, and `split/2` already hands the
  caller the hidden list), and the `*_class` attrs.

  ## The counter is measured first, and never wraps

  Two separate things kept the `+N` from being readable.

  Compose measures a Row's **unweighted** children first, in order, each against
  what is left — so with everything unweighted the items ate the row and the
  counter, being last, got the scraps. The items now sit in a weighted Box, which
  inverts that: the counter takes its natural width and the overflow is what gets
  clipped, which is the whole point of the component.

  And its label carries `max_lines: 1`. A Text squeezed narrower than its content
  wraps CHARACTER BY CHARACTER, so a starved "+3" rendered as a vertical stack of
  "+" and "3" rather than clipping. Every pill in this library sets it for the
  same reason.

  ## The counter must not fill

  The `+N` pill sets `fill_width={false}`. A Box given neither a `width` nor
  `fill_width` **fills its parent**, which turned the counter into a bar
  stretching across the rest of the row instead of a pill hugging its label —
  the same bug `MishkaMob.Components.MishkaPill` documents. iOS's `MobBox` never
  reads `fill_width` at all (`IOS_TODO.md` item 6), so this is an Android fix
  until that lands.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # Calibrated on device for chips in this library: ~7.6dp per character, plus
  # the pill's own horizontal padding. The counter is roughly three characters
  # of chrome plus its digits.
  @char_dp 7.6
  @token_chrome_dp 24
  @counter_dp 46

  @doc "Composite expander (`<MishkaOverflowList>`). Children are the items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: overflow_list(props, children)

  @doc """
  The row.

      <MishkaOverflowList visible={3} on_counter={:show_all}>{tag_pills()}</MishkaOverflowList>
  """
  @spec overflow_list(map() | keyword(), [map()]) :: map()
  def overflow_list(props \\ %{}, items \\ []) do
    props = Map.new(props)
    id = Map.get(props, :id)
    {shown, hidden} = split(items, props)
    space = Map.get(props, :space, 6)

    items =
      shown
      |> Enum.with_index(1)
      |> Enum.map(fn {item, n} -> tag(item, item_id(id, n)) end)
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    # The items go in a WEIGHTED box and the counter does not.
    #
    # Compose measures a Row's unweighted children first, in order, each against
    # what is left. With everything unweighted the items ate the row and the
    # counter — last — got the scraps, so "+3" was squeezed into a column of
    # characters. Weighting the items inverts that: the counter is measured
    # first at its natural width and the items take the remainder, so the count
    # is always readable and it is the overflow that gets clipped, which is the
    # whole point of the component.
    #
    # iOS is unaffected either way (an HStack serves fixed-size children first),
    # and ignores `weight` regardless — IOS_TODO item 13.
    body = %{
      type: :box,
      props: %{weight: 1},
      children: [%{type: :row, props: %{align: :center}, children: items}]
    }

    ~MOB"""
    <Row fill_width={true} align={:center}>
      {[body | counter(hidden, props, space, id)]}
    </Row>
    """
    |> tag(id)
  end

  @doc """
  How many of `labels` fit across `width` dp, leaving room for the counter.

  The component still takes a declared `visible` — it cannot measure anything
  itself. This is for the caller that *does* know its width: a screen that sized
  its own container can ask what that width holds and pass the answer in, which
  is how the web version behaves without the web's `ResizeObserver`.

  The estimate is the one calibrated for chips elsewhere in this library:
  roughly 7.6dp per character plus padding per token.

      iex> alias MishkaMob.Components.MishkaOverflowList
      iex> MishkaOverflowList.fit(~w(Design Phoenix Elixir LiveView), 400)
      4

      iex> alias MishkaMob.Components.MishkaOverflowList
      iex> MishkaOverflowList.fit(~w(Design Phoenix Elixir LiveView), 150)
      1

  Never returns less than one — a row of nothing but a counter says less than a
  row with one item and a bigger counter.
  """
  @spec fit([String.t()], number(), keyword()) :: pos_integer()
  def fit(labels, width, opts \\ []) do
    space = Keyword.get(opts, :space, 6)
    counter = Keyword.get(opts, :counter_width, @counter_dp)

    labels
    |> Enum.reduce_while({0, width - counter - space}, fn label, {count, left} ->
      cost = token_dp(label) + space

      if left - cost >= 0, do: {:cont, {count + 1, left - cost}}, else: {:halt, {count, left}}
    end)
    |> elem(0)
    |> max(1)
  end

  defp token_dp(label), do: String.length(label) * @char_dp + @token_chrome_dp

  @doc """
  The test tag on the "+N" counter, given the list's `id`.

      iex> MishkaMob.Components.MishkaOverflowList.counter_id("langs")
      "langs-counter"
  """
  @spec counter_id(String.t() | nil) :: String.t() | nil
  def counter_id(id) when is_binary(id), do: id <> "-counter"
  def counter_id(_), do: nil

  @doc """
  The test tag on the nth *shown* item — 1-based, and only the shown ones are
  tagged, so counting these tags counts what survived the split.

      iex> MishkaMob.Components.MishkaOverflowList.item_id("langs", 2)
      "langs-item-2"
  """
  @spec item_id(String.t() | nil, pos_integer()) :: String.t() | nil
  def item_id(id, n) when is_binary(id), do: "#{id}-item-#{n}"
  def item_id(_id, _n), do: nil

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

  defp counter([], _props, _space, _id), do: []

  defp counter(hidden, props, space, id) do
    label = counter_label(hidden, props)

    node =
      ~MOB"""
      <Box
        fill_width={false}
        background={:surface_raised}
        corner_radius={:radius_pill}
        padding={:space_sm}
      >
        <Text text={label} text_size={:sm} text_color={:on_surface} max_lines={1} />
      </Box>
      """
      |> put(:on_tap, Event.handler(Map.get(props, :on_counter)))
      |> tag(counter_id(id))

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

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}
end
