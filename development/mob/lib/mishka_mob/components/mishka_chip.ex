defmodule MishkaMob.Components.MishkaChip do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Chip** — a compact, selectable
  label (a filter chip).

  On the web a chip is a `<label>` wrapping a hidden checkbox or radio, so the
  browser handles selection and form submission. Natively there is no hidden
  input and no form post: the chip is a tappable pill whose `checked` state
  comes from the screen, exactly like every other controlled Mob widget.

  That also means `type: "checkbox" | "radio"` does not port as a prop. The
  difference between the two is entirely in how the *screen* updates state —
  toggle one id, or replace the selection — so it belongs in the handler. Both
  shapes are one line:

      # checkbox chips: toggle membership
      selected = if id in selected, do: List.delete(selected, id), else: [id | selected]

      # radio chips: replace
      selected = [id]

  ## Headless means the caller sizes it

  Everything below the first six props exists because a chip in a real design is
  a *measured* thing — 32 tall, 15 of horizontal padding, a 12pt label — and a
  component that bakes those into theme tokens cannot build it. Every one is
  optional and every default is what the chip rendered before it existed, so
  adding them changed no existing chip: unset, the node is byte-for-byte the
  Box-plus-Text it always was.

  Each takes **a theme token or a raw value**, the same way `color` already took
  `:primary` or `0xFF7C3AED`. `padding_x={:space_md}` and `padding_x={15}` are
  both valid; the renderer resolves the atom through the active theme and passes
  the number through untouched.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The chip's text. |
  | `checked` | boolean | `false` | Whether it reads as selected. |
  | `disabled` | boolean | `false` | Wires no handler and mutes the chip. |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `color` | color token / ARGB int | `:primary` | Fill when checked. |
  | `text_color` | color token / ARGB int | `:on_primary` | Label colour when checked. |
  | `unchecked_color` | color token / ARGB int | `:surface_raised` | Fill when unchecked. |
  | `unchecked_text_color` | color token / ARGB int | `:on_surface` | Label colour when unchecked. |
  | `disabled_color` | color token / ARGB int | `:muted` checked, `unchecked_color` otherwise | Fill while disabled. |
  | `disabled_text_color` | color token / ARGB int | `text_color` checked, `:muted` otherwise | Label colour while disabled. |
  | `width` | number (dp) | `nil` — hugs its label | Declared width. |
  | `height` | number (dp) | `nil` — intrinsic | Declared height. |
  | `padding` | spacing token / number | `:space_sm` | All four sides. |
  | `padding_x` | spacing token / number | `padding` | Left and right, overriding `padding`. |
  | `padding_y` | spacing token / number | `padding` | Top and bottom, overriding `padding`. |
  | `corner_radius` | radius token / number | `:radius_pill` | Corner rounding. |
  | `text_size` | text-size token / number | `:base` | Label size. |
  | `font_weight` | `:medium` `:semibold` `:bold` `:light` `:thin` | `nil` — regular | Label weight. |
  | `max_lines` | integer | `nil` — unbounded | Caps the label. |
  | `align` | `:center` `:leading` `:trailing` … | `nil`, `:center` when sized | Where content sits in the box. |
  | `trailing` | string, node, or list | `nil` | Content after the label — a count, a ✕, an icon. |
  | `trailing_gap` | number (dp) | `0` | Space between label and `trailing`. |

  Not ported: `name`, `value` and `type` (HTML form plumbing) and the `id` /
  `*_class` attrs.

  ## Padding is applied before width and height

  The bridge pads first and sizes second, so a declared size is the size of the
  content box, not of the chip: `height={32}` with the default `:space_sm`
  padding measures **48**. Pin a design height by pinning the padding on that
  axis too — `height={32} padding_y={0}` — and keep the axis you did not pin:
  `padding_x={15}` alone leaves top and bottom on `padding`.

  A **negative** padding is not clamped here and throws inside the Compose
  bridge, taking the activity with it. Subtract in the value you pass, never in
  the prop.

  ## `align` follows the size

  A Box aligns its content top-start, which is invisible while the chip hugs its
  label — the label *is* the box. Declare a `width` or a `height` and it stops
  being invisible: the label pins to the top-left of a box now bigger than it.
  So a sized chip centres unless the caller says otherwise, and an unsized one
  emits no `align` at all, exactly as before.

  ## The trailing slot

  `trailing` is a slot in the nav-link sense: a string becomes a Text in the
  chip's own ink and size, a node or list of nodes is placed as given. It sits
  in a Row beside the label, which is what a count after a filter name wants —
  a Box would stack it *under* the label instead, since a Box stacks.

  Without `trailing` the chip is still a Box holding one Text, unchanged.

  The composite tag ignores its children, as it always has; `trailing={…}` is
  how content gets in.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc """
  Composite expander (`<MishkaChip />`). Delegates to `chip/1`.

  Children are ignored — the chip's content is `label` and `trailing`.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: chip(props)

  @doc """
  The chip node.

      chip(label: "Elixir", checked: true, on_toggle: :pick_elixir)
      chip(label: "Unread", trailing: "12", trailing_gap: 6, height: 32, padding_y: 0)
  """
  @spec chip(map() | keyword()) :: map()
  def chip(props \\ %{}) do
    props = Map.new(props)
    checked? = truthy?(Map.get(props, :checked, false))
    disabled? = truthy?(Map.get(props, :disabled, false))

    ink = text_color(props, checked?, disabled?)
    fill = background(props, checked?, disabled?)

    # A Box with `fill_width={false}`, NOT a Button.
    #
    # A Box with neither `width` nor `fill_width` fills its parent — that was
    # the original full-width chip. `fill_width={false}` says "hug", but saying
    # it is not the same as being heard: the generated bridge never READ the
    # prop for a box on either platform, branching on width alone, so a Box hugs
    # only when `width` is a number. Android's box case reads it now
    # (`MobBridge.kt`, the "box" branch); iOS's `MobBox` still does not
    # (development/mob/IOS_TODO.md §6), and a vendored bridge hugs only once the
    # same one-line change lands in it.
    #
    # So the prop stays — it is correct the moment a bridge reads it and inert
    # when one does not — and `width` is the escape hatch until then. A Button
    # would read `fill_width` everywhere today, but Material3 gives a Button its
    # own minimum size and content padding: the chips came out oversized,
    # overflowed their row, and the last one was squeezed until its label
    # vanished. Wrong size on every platform is worse than wrong width on one.
    node = ~MOB"""
    <Box
      fill_width={false}
      background={fill}
      corner_radius={Map.get(props, :corner_radius) || :radius_pill}
    >
      {body(props, ink)}
    </Box>
    """

    node
    |> pad(props)
    |> put(:width, Map.get(props, :width))
    |> put(:height, Map.get(props, :height))
    |> put(:align, align(props))
    |> put(:on_tap, handler(props, disabled?))
  end

  # One padding shape or the other, never both: the uniform `padding` while
  # neither axis is overridden — the node the chip has always built — and four
  # explicit edges as soon as either is, with the un-overridden axis carrying
  # the uniform value itself. Compose does resolve a missing edge against the
  # uniform, so sending both would work there, but a node that says exactly
  # what it means does not have to know that, and cannot be double-padded by a
  # bridge that adds the two instead of choosing between them.
  defp pad(node, props) do
    pad = Map.get(props, :padding) || :space_sm

    case {Map.get(props, :padding_x), Map.get(props, :padding_y)} do
      {nil, nil} ->
        put(node, :padding, pad)

      {x, y} ->
        node
        |> put(:padding_left, x || pad)
        |> put(:padding_right, x || pad)
        |> put(:padding_top, y || pad)
        |> put(:padding_bottom, y || pad)
    end
  end

  # A Box stacks, so the label and the trailing slot need a Row between them —
  # but only when there IS a trailing slot. Otherwise the Box holds the single
  # Text it has always held, and a chip that never asked for the feature does
  # not pay a node for it.
  defp body(props, ink) do
    label = label(props, ink)

    case trailing(props, ink) do
      nil ->
        label

      node ->
        ~MOB"""
        <Row align={:center}>
          {label}
          {gap(props)}
          {node}
        </Row>
        """
    end
  end

  # `font_weight`, not `weight`: a bare `weight` on a Text is read by the PARENT
  # Row as a layout weight and does nothing to the font. Both stay off the node
  # unless asked for — an absent `max_lines` is an unbounded label, which is
  # what the chip rendered before the prop existed.
  defp label(props, ink) do
    ~MOB"""
    <Text
      text={Map.get(props, :label) || ""}
      text_size={Map.get(props, :text_size) || :base}
      text_color={ink}
    />
    """
    |> put(:font_weight, Map.get(props, :font_weight))
    |> put(:max_lines, Map.get(props, :max_lines))
  end

  # `trailing` is a slot, so it takes a node as readily as a glyph string — a
  # count after a filter name is the ordinary case, and a caller who wants that
  # count in its own colour passes a node instead of a string. An empty slot is
  # nothing at all, which is what the web's `:if={@slot != []}` says too.
  defp trailing(props, ink) do
    case Map.get(props, :trailing) do
      nil ->
        nil

      [] ->
        nil

      nodes when is_list(nodes) ->
        ~MOB"""
        <Row>
          {nodes}
        </Row>
        """

      %{type: _type} = node ->
        node

      text ->
        ~MOB"""
        <Text text={to_string(text)} text_size={Map.get(props, :text_size) || :base} text_color={ink} />
        """
    end
  end

  # A Spacer's `size` is not a spacing prop the renderer resolves, so this one
  # is dp only — and zero means no Spacer rather than a Spacer of nothing.
  defp gap(props) do
    case Map.get(props, :trailing_gap) || 0 do
      size when is_number(size) and size > 0 -> ~MOB(<Spacer size={size} />)
      _zero_or_junk -> nil
    end
  end

  # An unsized chip emits no `align`, which is the node it always built; a sized
  # one centres, because top-start content in a declared box is never what a
  # chip meant. An explicit `align` wins over both.
  defp align(props) do
    case {Map.get(props, :align), Map.get(props, :width), Map.get(props, :height)} do
      {nil, nil, nil} -> nil
      {nil, _width, _height} -> :center
      {given, _width, _height} -> given
    end
  end

  # `disabled` must not erase `checked`. It used to: both fell to
  # `:surface_raised`, so a locked-ON chip was pixel-identical to a locked-OFF
  # one and the user could not see what was selected. The web keeps them
  # orthogonal — `data-disabled` on the root, `:checked` still on the input — so
  # a disabled selection stays visibly selected, just muted.
  #
  # `disabled_color` covers BOTH disabled states, so setting it collapses them
  # back into one look. That is the caller's call — a design whose disabled chip
  # is transparent needs it — but it is the bug above, so give the two states
  # different `disabled_text_color`s or leave one of them defaulted.
  defp background(props, checked?, disabled?) do
    cond do
      checked? and disabled? -> Map.get(props, :disabled_color) || :muted
      disabled? -> Map.get(props, :disabled_color) || unchecked_color(props)
      checked? -> Map.get(props, :color) || :primary
      true -> unchecked_color(props)
    end
  end

  # A checked+disabled chip keeps a light label: its fill is `:muted`, and a
  # `:muted` label on a `:muted` fill is invisible — which is exactly how the
  # locked-on chip rendered as a blank dark blob.
  defp text_color(props, checked?, disabled?) do
    cond do
      checked? and disabled? -> Map.get(props, :disabled_text_color) || checked_text_color(props)
      disabled? -> Map.get(props, :disabled_text_color) || :muted
      checked? -> checked_text_color(props)
      true -> Map.get(props, :unchecked_text_color) || :on_surface
    end
  end

  defp unchecked_color(props), do: Map.get(props, :unchecked_color) || :surface_raised
  defp checked_text_color(props), do: Map.get(props, :text_color) || :on_primary

  defp handler(_props, true), do: nil
  defp handler(props, _disabled), do: Event.handler(Map.get(props, :on_toggle))

  # A prop left out is a prop the node never carries: `nil` is not "default", it
  # serialises as JSON null and the bridge reads it as a value.
  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
