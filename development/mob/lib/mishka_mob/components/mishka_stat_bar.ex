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
  | `value` | number | `0` | The fraction of the bar to fill, clamped `0.0..1.0`. |
  | `value_text` | string | `nil` | The reading on the right. |
  | `color` | color token / ARGB int | `:primary` | The filled part of the bar. |
  | `track_color` | color token / ARGB int | `:surface_raised` | The groove. |
  | `height` | number | `6` | The bar's thickness. |
  | `corner_radius` | number | `3` | The bar's rounding. |
  | `gap` | number | `8` | Space between the text row and the bar. |
  | `label_size` | number | `13` | The label's text size. |
  | `label_color` | color token / ARGB int | `:on_surface` | The label's ink. |
  | `value_size` | number | `12` | The reading's text size. |
  | `value_color` | color token / ARGB int | `:muted` | The reading's ink. |
  | `font_family` | string | unset | Applied to both texts. |
  | `value_weight` | weight | unset | The reading's weight, for a figure that should stand out. |
  | `id` | string | unset | TestTag on the block; the bar inside is `<id>-bar`. |

  Children are ignored; the row is data.

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
    label = Map.get(props, :label)
    value_text = Map.get(props, :value_text)

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
        {text(label, setting(props, :label_size, 13), setting(props, :label_color, :on_surface), Map.get(props, :font_family), nil)}
        <Spacer weight={1.0} />
        {text(value_text, setting(props, :value_size, 12), setting(props, :value_color, :muted), Map.get(props, :font_family), Map.get(props, :value_weight))}
      </Row>
      <Spacer size={setting(props, :gap, 8)} />
      {bar}
    </Column>
    """
    |> put_id(id)
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

  defp text(nil, _size, _color, _family, _weight), do: ~MOB"<Spacer size={0} />"

  defp text(value, size, color, family, weight) do
    assigns = %{value: value, size: size, color: color, family: family, weight: weight}

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
  end

  defp setting(props, key, default), do: Map.get(props, key) || default

  defp put_id(node, nil), do: node
  defp put_id(node, id), do: %{node | props: Map.put(node.props, :id, id)}
end
