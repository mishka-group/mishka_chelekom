defmodule MishkaMob.Components.MishkaEmptyState do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Empty State** — the placeholder
  shown when a list has nothing in it: an indicator, a title, supporting text and
  optional actions.

  ## Alignment is the one real prop

  The web component's `align` decides whether the indicator sits above the text
  (centred) or beside it (leading). Both are ported, because they are genuinely
  different layouts rather than a styling nicety: a centred empty state fills a
  blank screen, while a leading one sits inside a card or a section without
  looking like the screen has failed.

  Centring uses `align: :center` on a Box, which Mob maps to `Alignment.Center`
  on Compose and the matching SwiftUI alignment.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `title` | string | `nil` | Heading. |
  | `description` | string | `nil` | Supporting text. |
  | `align` | `:center` `:leading` | `:center` | Indicator above the text, or beside it. |
  | `indicator` | string | `nil` | A glyph or emoji shown above/beside the text. |
  | `padding` | spacing token / number | `:space_xl` | Padding around the block. |

  `indicator_nodes` (second argument) replaces the glyph with any nodes;
  `actions` (third) are laid out in a row beneath the text.

  Not ported: `id` and the `*_class` attrs.
  """

  import Mob.Sigil

  @doc """
  Composite expander (`<MishkaEmptyState>`). Children become the actions row.
  """
  @spec expand(map(), [map()], map()) :: map()
  # Children are the indicator; `actions` is the prop. Mirrors
  # MishkaDialog.expand/3, where a second slot cannot be expressed in markup.
  def expand(props, children, _ctx) do
    {actions, props} = Map.pop(Map.new(props), :actions, [])
    empty_state(props, children, List.wrap(actions))
  end

  @doc """
  The empty-state node.

      empty_state(title: "No messages", description: "Anything you receive lands here.")
  """
  @spec empty_state(map() | keyword(), [map()], [map()]) :: map()
  def empty_state(props \\ %{}, indicator_nodes \\ [], actions \\ []) do
    props = Map.new(props)

    if Map.get(props, :align, :center) == :leading do
      leading(props, indicator_nodes, actions)
    else
      centred(props, indicator_nodes, actions)
    end
  end

  defp centred(props, indicator_nodes, actions) do
    ~MOB"""
    <Box fill_width={true} align={:center} padding={Map.get(props, :padding, :space_xl)}>
      <Column>
        {indicator(props, indicator_nodes)}
        {text_block(props, :center)}
        {actions_row(actions)}
      </Column>
    </Box>
    """
  end

  defp leading(props, indicator_nodes, actions) do
    ~MOB"""
    <Row fill_width={true}>
      {indicator(props, indicator_nodes)}
      <Spacer size={14} />
      <Column fill_width={true}>
        {text_block(props, :leading)}
        {actions_row(actions)}
      </Column>
    </Row>
    """
  end

  defp indicator(props, []) do
    glyph = Map.get(props, :indicator)

    ~MOB"""
    <Column :if={is_binary(glyph)}>
      <Text text={glyph} text_size={:"2xl"} text_color={:muted} />
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

    ~MOB"""
    <Column fill_width={centre? == false}>
      <Text text={title} text_size={:xl} text_color={:on_surface} :if={is_binary(title)} />
      <Spacer size={6} :if={is_binary(title) and is_binary(description)} />
      <Text text={description} text_size={:base} text_color={:muted} :if={is_binary(description)} />
    </Column>
    """
  end

  defp actions_row([]), do: ~MOB(<Column />)

  defp actions_row(actions) do
    ~MOB"""
    <Column>
      <Spacer size={16} />
      <Row>
        {actions}
      </Row>
    </Column>
    """
  end
end
