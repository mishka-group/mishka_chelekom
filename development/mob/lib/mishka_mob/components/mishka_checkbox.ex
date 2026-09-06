defmodule MishkaMob.Components.MishkaCheckbox do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Checkbox** — a labelled box
  with checked, unchecked and **indeterminate** states.

  Mob ships no checkbox widget (its `Toggle` is a switch), so the indicator is
  built here: a small rounded `Box` carrying a glyph, beside a label, in one
  tappable row.

  ## Three states, not two

  `indeterminate` is the state a "select all" parent sits in when only some
  children are checked, and it wins over `checked` while set — matching the web,
  where `aria-checked="mixed"` overrides the input's own checked flag. It draws a
  dash rather than a tick, so the three states are distinguishable at a glance
  and not just by colour.

  `toggle/1` gives the state transition a tap should produce, so a screen does
  not have to rediscover that tapping an indeterminate box selects everything
  rather than clearing it.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | Text beside the box. |
  | `checked` | boolean | `false` | Checked state. Lives in the screen. |
  | `indeterminate` | boolean | `false` | Mixed state; overrides `checked` visually. |
  | `disabled` | boolean | `false` | Wires no handler and mutes the row. |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Fill when checked or mixed. |
  | `size` | number | `22` | Indicator edge length. |
  | `id` | string | — | A native testTag, suffixed with the state: `id-checked`, `id-mixed`, `id-empty`. |

  Not ported: `name`, `value`, `required` (HTML form plumbing), `id` /
  `*_class`, and `parent` — the tristate "select all" behaviour is the screen's
  reducer over its children, and `toggle/1` is the piece of it worth sharing.
  `readonly` collapses into `disabled`: both simply omit the handler.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaCheckbox />`). Delegates to `checkbox/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: checkbox(props)

  @doc """
  The next `{checked?, indeterminate?}` a tap should produce.

  A mixed box resolves to fully checked — the same choice browsers make for a
  tristate parent, because "some are selected" most usefully becomes "all are".

      iex> MishkaMob.Components.MishkaCheckbox.toggle(%{checked: false})
      {true, false}
      iex> MishkaMob.Components.MishkaCheckbox.toggle(%{checked: true})
      {false, false}
      iex> MishkaMob.Components.MishkaCheckbox.toggle(%{indeterminate: true})
      {true, false}
  """
  @spec toggle(map() | keyword()) :: {boolean(), boolean()}
  def toggle(state) do
    state = Map.new(state)

    if truthy?(Map.get(state, :indeterminate, false)) do
      {true, false}
    else
      {not truthy?(Map.get(state, :checked, false)), false}
    end
  end

  @doc """
  The checkbox node.

      checkbox(label: "Remember me", checked: @remember?, on_toggle: :remember)
  """
  @spec checkbox(map() | keyword()) :: map()
  def checkbox(props \\ %{}) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    mixed? = truthy?(Map.get(props, :indeterminate, false))
    checked? = mixed? or truthy?(Map.get(props, :checked, false))
    label = Map.get(props, :label)
    label_color = if disabled?, do: :muted, else: :on_surface

    node = ~MOB"""
    <Row fill_width={true}>
      {indicator(props, checked?, mixed?, disabled?)}
      <Spacer size={10} :if={is_binary(label)} />
      <Text text={label} text_size={:base} text_color={label_color} :if={is_binary(label)} />
    </Row>
    """

    case handler(props, disabled?) do
      nil -> node
      tap -> %{node | props: Map.put(node.props, :on_tap, tap)}
    end
  end

  # A dash for mixed, a tick for checked — the states differ by glyph, not only
  # by colour, so they survive a colourblind reading.
  #
  # The mark is DRAWN, not typed. It was a "✓" Text, and a text glyph sits on its
  # baseline with descent space beneath it, so the mark rode high in its box —
  # invisible at 26dp and obvious at 16dp, where it looked off-centre and
  # cramped. No font size fixes that, because the offset is a property of text
  # metrics rather than of scale. Two canvas lines have no metrics: they land
  # exactly where the arithmetic puts them, at any size, on both platforms.
  defp indicator(props, checked?, mixed?, disabled?) do
    size = Map.get(props, :size) || 22
    fill = fill(props, checked?, disabled?)
    mark = mark(size, checked?, mixed?, glyph_color(props, disabled?))

    node = ~MOB"""
    <Box
      width={size}
      height={size}
      background={fill}
      corner_radius={:radius_sm}
      align={:center}
      border_color={:border}
      border_width={1}
    >
      {mark}
    </Box>
    """

    tag_state(node, Map.get(props, :id), checked?, mixed?)
  end

  # A drawn mark has no text, so nothing in the accessibility tree says whether
  # the box is ticked — which also means a device test cannot see it. Mob turns
  # `:id` into a native testTag, so the STATE goes into the tag: `id-checked`,
  # `id-mixed`, `id-empty`. The same trick MishkaSkeleton uses to let a test
  # address a bar that carries no text.
  defp tag_state(node, nil, _checked?, _mixed?), do: node

  defp tag_state(node, id, checked?, mixed?) do
    state =
      cond do
        mixed? -> "mixed"
        checked? -> "checked"
        true -> "empty"
      end

    %{node | props: Map.put(node.props, :id, "#{id}-#{state}")}
  end

  # Coordinates are fractions of the box, so the mark is centred by construction
  # and scales with `size` without a second thought.
  defp mark(_size, false, false, _ink), do: []

  defp mark(size, _checked?, true, ink) do
    y = size / 2

    [
      Mob.UI.canvas(
        width: size,
        height: size,
        draw: [
          Mob.Canvas.line(size * 0.26, y, size * 0.74, y,
            color: ink,
            width: stroke(size),
            cap: :round
          )
        ]
      )
    ]
  end

  defp mark(size, _checked?, _mixed?, ink) do
    w = stroke(size)

    [
      Mob.UI.canvas(
        width: size,
        height: size,
        draw: [
          Mob.Canvas.line(size * 0.26, size * 0.52, size * 0.44, size * 0.70,
            color: ink,
            width: w,
            cap: :round
          ),
          Mob.Canvas.line(size * 0.44, size * 0.70, size * 0.76, size * 0.32,
            color: ink,
            width: w,
            cap: :round
          )
        ]
      )
    ]
  end

  # Thick enough to read at 14dp, thin enough not to fill the box at 40dp.
  defp stroke(size), do: Kernel.max(size * 0.12, 1.5)

  defp fill(props, true, false), do: Map.get(props, :color) || :primary
  defp fill(_props, _checked, _disabled), do: :surface_raised

  defp glyph_color(_props, true), do: :muted
  defp glyph_color(props, _), do: Map.get(props, :text_color) || :on_primary

  defp handler(_props, true), do: nil
  defp handler(props, _), do: Event.handler(Map.get(props, :on_toggle))

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
