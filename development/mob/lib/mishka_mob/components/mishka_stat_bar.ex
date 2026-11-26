defmodule MishkaMob.Components.MishkaStatBar do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Stat Bar** — a labelled
  measurement: a name, a figure, and a bar showing that figure against a scale.

  It is the shape every "where the hours went" or "how full is it" row takes:
  the label on the left, the reading on the right, the proportion underneath.
  Every app writes that row by hand and every one of them gets one of the three
  alignments slightly wrong; this draws it once.

  ## The reading is the caller's

  `value` is a `0.0..1.0` fraction, and `value_text` is the string a person
  reads. Kati's own screens print `6h`, another app prints `63%` or `3 of 5`;
  the component never formats a number, because the unit is a property of the
  data rather than of a bar.

  ## Headless

  Nothing is coloured or sized unless the caller says so: no default
  background, no palette token, no type scale beyond plain numbers. Kati passes
  its own card fill, ink and mono face; a web-styled app passes its own.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The name on the left. |
  | `leading` | string, node, or list of nodes | `nil` | Drawn before the label — a rank, a glyph, a dot. |
  | `leading_gap` | number | `10` | Space between the leading mark and the label. |
  | `leading_size` | number | `12` | A string leading's size. |
  | `leading_color` | color token / ARGB int | unset | A string leading's ink. |
  | `leading_weight` | weight | unset | A string leading's weight. |
  | `value` | number | `0` | The fraction of the bar to fill, clamped `0.0..1.0`. |
  | `value_text` | string | `nil` | The reading on the right. |
  | `color` | color token / ARGB int | `:primary` | The filled part of the bar. |
  | `track_color` | color token / ARGB int | `:surface_raised` | The groove. |
  | `height` | number | `6` | The bar's thickness. |
  | `corner_radius` | number | `3` | The bar's rounding. |
  | `gap` | number | `8` | Space between the text row and the bar. |
  | `label_size` | number | `13` | The label's text size. |
  | `label_color` | color token / ARGB int | `:on_surface` | The label's ink. |
  | `label_font_weight` | weight | unset | The label's weight. |
  | `label_flex` | number | unset | The label takes this flex weight, so a long name truncates instead of moving the reading. |
  | `label_gap` | number | `8` | Under `label_flex` only: the fixed space before the reading. |
  | `value_size` | number | `12` | The reading's text size. |
  | `value_color` | color token / ARGB int | `:muted` | The reading's ink. |
  | `font_family` | string | unset | Applied to both texts. |
  | `value_weight` | weight | unset | The reading's weight, for a figure that should stand out. |
  | `id` | string | unset | TestTag on the block; the bar inside is `<id>-bar`. |

  Children are ignored; the row is data.

  ## A ranked row is the same row

  A "watched most" list is this component with a `leading`: the rank before the
  name, the name as the label, the count as the reading. `label_flex` is what
  keeps the count pinned to the right edge when the name is long — without it
  the label hugs its text and a title can push the figure off the row, so a
  list that must stay aligned passes it.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/stat-bar
  """

  import Mob.Sigil

  alias MishkaMob.Components.MishkaProgress

  @doc "Composite expander (`<MishkaStatBar />`). Delegates to `stat_bar/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: stat_bar(props)

  @doc """
  The row.

      stat_bar(label: "Action", value: 0.6, value_text: "6h")
  """
  @spec stat_bar(map() | keyword()) :: map()
  def stat_bar(props \\ %{}) do
    props = Map.new(props)
    id = Map.get(props, :id)
    row = row_nodes(props)

    bar =
      MishkaProgress.progress(%{
        value: fraction(Map.get(props, :value)),
        max: 1,
        render: :box,
        height: setting(props, :height, 6),
        corner_radius: setting(props, :corner_radius, 3),
        color: setting(props, :color, :primary),
        track_color: setting(props, :track_color, :surface_raised),
        id: if(id, do: "#{id}-bar")
      })

    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true} align="center">
        {row}
      </Row>
      <Spacer size={setting(props, :gap, 8)} />
      {bar}
    </Column>
    """
    |> put_id(id)
  end

  # The text row, as a list so an optional leading mark and an optional fixed
  # gap are nodes the template never has to branch on.
  defp row_nodes(props) do
    leading = Map.get(props, :leading)
    flex = Map.get(props, :label_flex)

    [
      leading_nodes(props, leading),
      text(
        Map.get(props, :label),
        setting(props, :label_size, 13),
        setting(props, :label_color, :on_surface),
        Map.get(props, :font_family),
        Map.get(props, :label_font_weight),
        flex
      ),
      between_nodes(props, flex),
      text(
        Map.get(props, :value_text),
        setting(props, :value_size, 12),
        setting(props, :value_color, :muted),
        Map.get(props, :font_family),
        Map.get(props, :value_weight),
        nil
      )
    ]
    |> List.flatten()
  end

  defp leading_nodes(_props, nil), do: []

  defp leading_nodes(props, leading) when is_binary(leading) do
    assigns = %{
      leading: leading,
      size: setting(props, :leading_size, 12),
      color: Map.get(props, :leading_color),
      weight: Map.get(props, :leading_weight),
      family: Map.get(props, :font_family)
    }

    [
      ~MOB"""
      <Text
        text={@leading}
        text_size={@size}
        text_color={@color}
        font_weight={@weight}
        font_family={@family}
        max_lines={1}
      />
      """
      |> drop_unset(:font_family, assigns.family),
      gap_node(setting(props, :leading_gap, 10))
    ]
  end

  defp leading_nodes(props, leading) do
    [leading, gap_node(setting(props, :leading_gap, 10))]
  end

  defp text(nil, _size, _color, _family, _weight, _flex), do: []

  defp text(value, size, color, family, weight, flex) do
    assigns = %{
      value: value,
      size: size,
      color: color,
      family: family,
      weight: weight,
      flex: flex
    }

    node =
      ~MOB"""
      <Text
        text={@value}
        text_size={@size}
        text_color={@color}
        font_family={@family}
        font_weight={@weight}
        max_lines={1}
      />
      """
      |> drop_unset(:font_family, family)

    # The flex lives on a Box, not on the Text: a `weight` prop on a Text is read
    # by the parent Row, and iOS has no layout weight at all, so a Text-weighted
    # label would pin the reading on Android and not on iOS.
    if flex, do: flex_box(node, flex), else: node
  end

  defp flex_box(node, flex) do
    assigns = %{flex: flex, node: node}

    ~MOB"""
    <Box weight={@flex}>
      {@node}
    </Box>
    """
  end

  # A prop that is present but nil is not the same node as one that is absent:
  # the bridge cannot tell the two apart and neither can an ancestor's face.
  # Omitting the key leaves the app's own face in charge, which is what "no
  # family given" means.
  defp drop_unset(node, _key, value) when not is_nil(value), do: node
  defp drop_unset(node, key, _value), do: %{node | props: Map.delete(node.props, key)}

  # A flexed label pins the reading with a fixed gap; an unflexed one lets the
  # reading float to the right edge behind a flexible spacer.
  defp between_nodes(_props, nil), do: [~MOB"<Spacer weight={1.0} />"]

  defp between_nodes(props, _flex), do: [gap_node(setting(props, :label_gap, 8))]

  defp gap_node(0), do: []
  defp gap_node(size) when is_number(size), do: [spacer(size)]
  defp gap_node(_size), do: []

  defp spacer(size) do
    assigns = %{size: size}
    ~MOB"<Spacer size={@size} />"
  end

  @doc """
  The clamped fraction, so a caller's arithmetic cannot overflow the groove.

      iex> MishkaMob.Components.MishkaStatBar.fraction(1.4)
      1.0
      iex> MishkaMob.Components.MishkaStatBar.fraction(nil)
      0.0
  """
  @spec fraction(number() | nil) :: float()
  def fraction(value) when is_number(value), do: value |> max(0) |> min(1) |> Kernel.*(1.0)
  def fraction(_none), do: 0.0

  defp setting(props, key, default), do: Map.get(props, key) || default

  defp put_id(node, nil), do: node
  defp put_id(node, id), do: %{node | props: Map.put(node.props, :id, id)}
end
