defmodule MishkaMob.Components.MishkaEmptyState do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Empty State** — the placeholder
  shown when a list has nothing in it: an indicator, a title, supporting text and
  optional actions.

  ## Alignment is the one real prop

  The web component's `align` decides the reading alignment, and its own
  anatomy already puts the indicator above the body. Three layouts are ported:

    * `:center` — indicator above the text, all centred. Fills a blank screen.
    * `:leading` — indicator beside the text. Sits inside a card or a section.
    * `:left` — indicator above the text, the block left-aligned. This is the
      web component's own default anatomy with `data-align="left"`.

  Centring uses `align: :center` on a Box, which Mob maps to `Alignment.Center`
  on Compose and the matching SwiftUI alignment. `:left` is a plain `Column`,
  so the block keeps the caller's own leading edge and padding.

  ## The title carries type when the caller says so

  `title_size`, `title_weight` and `title_line_height` exist because a heading
  copied from a drawing is often not the component's `:xl` regular text — a
  page's gone or empty block often wants 22pt bold at 1.25 leading. Each is
  absent unless asked for, so an empty state that sets none of them draws the
  same `Text` it always did.

  ## Padding

  `padding` sets all four sides as it always has. `padding_top`,
  `padding_right`, `padding_bottom` and `padding_left` override one edge each;
  an edge-only call writes no uniform `padding` key at all, which is what lets
  a page pass its own 21/21/140 as the block's geometry rather than wrapping
  it in another container.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `title` | string | `nil` | Heading. |
  | `title_size` | text token / number | `:xl` | Heading size. |
  | `title_weight` | `:regular`, `:medium`, `:semibold`, `:bold`, … | unset | Heading weight. |
  | `title_line_height` | number | unset | Multiplier of `title_size`. |
  | `description` | string | `nil` | Supporting text. |
  | `align` | `:center` `:leading` `:left` | `:center` | Indicator above and centred, beside, or above and left-aligned. |
  | `indicator` | string | `nil` | A glyph or emoji shown above/beside the text. |
  | `padding` | spacing token / number | `:space_xl` | Padding around the block. |
  | `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | unset | One edge, overriding `padding`. |
  | `id` | string | — | A native testTag on the block, fanned out to its parts: `<id>-indicator`, `<id>-title`, `<id>-description`. |

  ## Slots

  All three of the web component's slots are ported as tags, so markup reads the
  way the Phoenix component does:

      <MishkaEmptyState title="No projects yet" description="Create one to get started.">
        <MishkaEmptyStateIndicator>
          <Text text="📁" text_size={:"2xl"} />
        </MishkaEmptyStateIndicator>
        <MishkaEmptyStateActions>
          <Button text="New" on_tap={:new_project} />
        </MishkaEmptyStateActions>
      </MishkaEmptyState>

  | Slot | Phoenix | Falls back to |
  |------|---------|---------------|
  | `<MishkaEmptyStateIndicator>` | `<:indicator>` | the `indicator` glyph prop |
  | `<MishkaEmptyStateActions>` | `<:actions>` | the `actions` prop (list of nodes) |
  | bare children | `<:inner_block>` | — rendered after the description |

  The `actions` prop is kept because assembling actions from data is common and
  a list comprehension is easier to write than generated markup; the slot wins
  when both are given.

  Not ported: the `*_class` attrs.

  ## Why `id` fans out

  Centred stacks the indicator above the text and leading puts it beside, which
  is a claim about where two nodes are in relation to each other. The parts are
  bare `Text` nodes, so without a tag each there is nothing for a device test to
  measure. An `indicator` slot brings its own nodes and keeps its own tags.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/empty-state
  """

  import Mob.Sigil

  @indicator_type :mishka_empty_state_indicator
  @actions_type :mishka_empty_state_actions

  @slot_types [@indicator_type, @actions_type]

  @doc """
  Composite expander (`<MishkaEmptyState>`).

  Children are partitioned into the three slots the web component declares —
  `<MishkaEmptyStateIndicator>`, `<MishkaEmptyStateActions>`, and everything
  else, which is the inner block rendered after the description.

  Slot tags are ordinary composite children matched on `:type`, the same shape
  `MishkaAccordion` uses for `<MishkaAccordionItem>`. They are consumed here, so
  no marker node ever reaches the renderer.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx) do
    {actions_prop, props} = Map.pop(Map.new(props), :actions, [])

    actions =
      case slot(children, @actions_type) do
        [] -> List.wrap(actions_prop)
        nodes -> nodes
      end

    empty_state(props, slot(children, @indicator_type), actions, inner_block(children))
  end

  # A slot tag contributes its OWN children; the tag itself is dropped.
  defp slot(children, type) do
    children
    |> Enum.filter(&match?(%{type: ^type}, &1))
    |> Enum.flat_map(&Map.get(&1, :children, []))
  end

  defp inner_block(children) do
    Enum.reject(children, &match?(%{type: type} when type in @slot_types, &1))
  end

  @doc """
  The empty-state node.

      empty_state(title: "No messages", description: "Anything you receive lands here.")
  """
  @spec empty_state(map() | keyword(), [map()], [map()], [map()]) :: map()
  def empty_state(props \\ %{}, indicator_nodes \\ [], actions \\ [], body \\ []) do
    props = Map.new(props)

    case layout(props) do
      :leading -> leading(props, indicator_nodes, actions, body)
      :left -> left(props, indicator_nodes, actions, body)
      :center -> centred(props, indicator_nodes, actions, body)
    end
  end

  defp layout(%{align: align}) when align in [:leading, "leading"], do: :leading
  defp layout(%{align: align}) when align in [:left, "left"], do: :left
  defp layout(_props), do: :center

  # Every part gets its OWN centring Box. Centring the block as a whole is not
  # the same thing and looks wrong the moment the parts differ in width: a
  # Column cannot align its children (Mob maps it to a bare Compose Column with
  # no horizontalAlignment), so the widest part sets the block width and every
  # narrower part left-aligns inside it. A title under a wide actions row then
  # sits visibly off-centre on a layout whose entire job is centring.
  defp centred(props, indicator_nodes, actions, body) do
    ~MOB"""
    <Box fill_width={true} align={:center}>
      <Column fill_width={true}>
        {centre(indicator(props, indicator_nodes))}
        {centre(text_block(props, :center))}
        {centre(body)}
        {centre(actions_row(actions))}
      </Column>
    </Box>
    """
    |> with_props(padding(props))
    |> with_id(Map.get(props, :id))
  end

  # The web component's own anatomy at `data-align="left"`: indicator above,
  # body below, everything on the caller's leading edge. No centring Box, so
  # the block keeps the page's own width and padding.
  defp left(props, indicator_nodes, actions, body) do
    ~MOB"""
    <Column fill_width={true}>
      {indicator(props, indicator_nodes)}
      {text_block(props, :left)}
      {body}
      {actions_or_none(actions)}
    </Column>
    """
    |> with_props(padding(props))
    |> with_id(Map.get(props, :id))
  end

  defp actions_or_none([]), do: []
  defp actions_or_none(actions), do: actions_row(actions)

  defp centre(nodes) do
    ~MOB"""
    <Box fill_width={true} align={:center}>
      {nodes}
    </Box>
    """
  end

  defp leading(props, indicator_nodes, actions, body) do
    ~MOB"""
    <Row fill_width={true}>
      {indicator(props, indicator_nodes)}
      <Spacer size={14} />
      <Column fill_width={true}>
        {text_block(props, :leading)}
        {body}
        {actions_row(actions)}
      </Column>
    </Row>
    """
    |> with_id(Map.get(props, :id))
  end

  defp indicator(props, []) do
    glyph = Map.get(props, :indicator)

    mark =
      with_id(
        ~MOB(<Text text={glyph} text_size={:"2xl"} text_color={:muted} />),
        part(props, "indicator")
      )

    ~MOB"""
    <Column :if={is_binary(glyph)}>
      {mark}
      <Spacer size={10} />
    </Column>
    """
  end

  defp indicator(_props, nodes), do: ~MOB(<Column>
  {nodes}
</Column>)

  defp text_block(props, align) do
    title = Map.get(props, :title)
    description = Map.get(props, :description)
    centre? = align == :center

    # text_align centres the LINES within a wrapped paragraph; the Box around
    # this block centres the block. A long description needs both.
    align = if centre?, do: :center, else: nil

    heading =
      ~MOB"""
      <Text
        text={title}
        text_size={Map.get(props, :title_size) || :xl}
        text_color={:on_surface}
        :if={is_binary(title)}
      />
      """
      |> with_props(align_prop(align))
      |> with_props(title_type(props))
      |> with_id(part(props, "title"))

    supporting =
      ~MOB"""
      <Text text={description} text_size={:base} text_color={:muted} :if={is_binary(description)} />
      """
      |> with_props(align_prop(align))
      |> with_id(part(props, "description"))

    ~MOB"""
    <Column fill_width={centre? == false}>
      {heading}
      <Spacer size={6} :if={is_binary(title) and is_binary(description)} />
      {supporting}
    </Column>
    """
  end

  # Mob turns :id into a native testTag. `nil` passes through twice over: no id
  # asked for, and a part that was not rendered (the sigil's `:if` leaves nil).
  defp with_id(node, nil), do: node
  defp with_id(nil, _id), do: nil
  defp with_id(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp with_props(nil, _props), do: nil
  defp with_props(node, props), do: %{node | props: Map.merge(node.props, props)}

  # A nil alignment is left OFF the node, not written as a null the bridge has
  # to interpret — a left-aligned block has no `text_align` key at all.
  defp align_prop(nil), do: %{}
  defp align_prop(align), do: %{text_align: align}

  # Type overrides stay ABSENT when unset, so a caller that names none builds
  # the same Text it built before these props existed.
  defp title_type(props) do
    %{}
    |> maybe(:font_weight, Map.get(props, :title_weight))
    |> maybe(:line_height, Map.get(props, :title_line_height))
  end

  # Uniform padding unless the caller names an edge. An edge-only call writes
  # no `padding` key at all — `0` and "absent" are different to the bridge,
  # and the page that passes its own geometry should get exactly that key set.
  defp padding(props) do
    uniform = Map.get(props, :padding)

    edges =
      %{}
      |> maybe(:padding_top, Map.get(props, :padding_top))
      |> maybe(:padding_right, Map.get(props, :padding_right))
      |> maybe(:padding_bottom, Map.get(props, :padding_bottom))
      |> maybe(:padding_left, Map.get(props, :padding_left))

    cond do
      uniform != nil -> Map.merge(%{padding: uniform}, edges)
      edges != %{} -> edges
      true -> %{padding: :space_xl}
    end
  end

  defp maybe(map, _key, nil), do: map
  defp maybe(map, key, value), do: Map.put(map, key, value)

  defp part(props, name) do
    case Map.get(props, :id) do
      nil -> nil
      id -> "#{id}-#{name}"
    end
  end

  defp actions_row([]), do: ~MOB(<Column />)

  # Owning the slot means owning the layout, and the layout needs owning.
  #
  # A Row hands the first child every pixel it asks for, and a control that has
  # not been told to hug asks for all of them: the first action filled the row
  # and the second was measured to ZERO width, parked past the right edge. It
  # stayed in the node tree with a working handler, so every unit test passed and
  # the test harness would happily "click" it — only a finger could tell.
  #
  # `fill_width: false` is the fix rather than a weight. Both place the buttons,
  # but weight is `Modifier.weight`, which SwiftUI has no equivalent for and Mob's
  # iOS renderer does not implement — the row would divide evenly on Android and
  # not on iOS. Hugging is honoured on both, and it is also what an HStack does
  # natively, so the two platforms agree. `put_new` leaves a caller free to say
  # otherwise.
  #
  # Nothing here fills: the centred layout centres by having this Row hug inside
  # an aligned Box, and a Column cannot align its own children (Mob maps it to a
  # bare Compose Column, no horizontalAlignment). Fill the Row and the actions
  # silently move to the left edge.
  defp actions_row(actions) do
    spaced =
      actions
      |> Enum.map(&hug/1)
      |> Enum.intersperse(~MOB(<Spacer size={8} />))

    ~MOB"""
    <Column>
      <Spacer size={16} />
      <Row>
        {spaced}
      </Row>
    </Column>
    """
  end

  defp hug(%{props: props} = node), do: %{node | props: Map.put_new(props, :fill_width, false)}
  defp hug(node), do: node
end
