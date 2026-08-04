defmodule MishkaMob.Components.MishkaTooltip do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Tooltip** — a short hint about
  the control it wraps.

  ## A long press is the hover

  The web tooltip is revealed by pointer-enter or focus, and a phone has
  neither. That was read here as "a tooltip has no trigger on touch", so the
  port shipped a bare bubble and left the reveal to the caller entirely.

  The touch equivalent of hover-to-reveal is the gesture the platform already
  uses for reveal-more everywhere else: **press and hold**. `Mob.Renderer` has
  always registered `on_long_press`, iOS has always implemented it, and the
  Android bridge now wires `combinedClickable` — so holding a control works on
  both platforms. A tooltip's children are therefore its trigger, and holding
  one pushes `on_open_change` with the state it wants next.

  Note the inversion against the web: there the default slot is the *content*
  and `<:trigger>` is a named slot; here the children are the *trigger*, because
  a native hint is one short string (`text`) while a trigger is a whole control.

  ## Placement is flow, not anchoring

  `side` and `align` do port, but they position the bubble **in the layout**
  rather than floating it over one. `side` decides which side of the trigger the
  bubble is stacked on and which way the arrow points; `align` places it across
  that side; `side_offset` is the gap between the two and `align_offset` nudges
  along the alignment axis. What does not port is edge-flip and viewport
  clamping — both need a measured on-screen rectangle, which a Mob render
  function is never given (see `MishkaMob.Components.MishkaPopover`).

  Opening therefore *displaces* the surrounding content instead of floating over
  it. That is the honest native shape, and it is why `side_offset` is a real gap
  rather than a fudge factor.

  ## It is deliberately not the Popover shell

  A tooltip is a *hint*, not a panel: dark, tight, no border, small text, one
  line. Using the Popover's surface would make it read as a menu. It is small
  enough to draw directly.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `text` | string | `nil` | The hint. |
  | `open` | boolean | `false` | Whether it is shown. Lives in the screen. |
  | `side` | `:top` `:bottom` `:left` `:right` | `:top` | Which side of the trigger the bubble sits on. |
  | `align` | `:start` `:center` `:end` | `:center` | Placement across that side. |
  | `side_offset` | number | `6` | Gap between trigger and bubble, in dp. |
  | `align_offset` | number | `0` | Nudge along the alignment axis, in dp. |
  | `arrow` | boolean | `false` | Draw a triangle pointing back at the trigger. |
  | `disabled` | boolean | `false` | Never opens, and wires no handler. |
  | `on_open_change` | event tag | — | Sent as `{:tap, {tag, next_open?}}`. |
  | `on_tap` | event tag | — | The wrapped control's own tap, sent as `{:tap, tag}`. |
  | `close_on_tap` | boolean | `true` | Tapping the bubble dismisses it. |
  | `background` | color token / ARGB int | `0xFF111827` | Bubble fill — dark by default so it reads over any surface. |
  | `color` | color token / ARGB int | `0xFFFFFFFF` | Hint colour. |
  | `text_size` | size token | `:sm` | Hint size. |
  | `offset_x` / `offset_y` | number | `nil` | Static nudge in dp. |
  | `fill_width` | boolean | `true` | The stack fills its parent so `align` has room to work. |
  | `id` | string | — | Native testTags: `id-trigger`, `id-open`, `id-arrow-<side>`. |

  `fill_width` is the one prop with no web counterpart, and it exists because a
  Row measures its unweighted children first: a filling stack would take the
  whole row and starve its siblings, so several tooltips side by side need
  `fill_width={false}`. Turning it off also gives `align` nothing to align
  against, which is the honest trade — a stack that hugs its trigger has no
  spare width to place the bubble in.

  Not ported: `delay`, `close_delay`, `hoverable` and `track_cursor_axis` (all
  describe a pointer that does not exist), `group` (a shared *hover* delay), and
  `trigger_label` — Mob exposes no accessible name on a node, only a testTag.
  `close_on_escape` becomes `close_on_tap`: a phone has no Escape key, and the
  one dismissal a finger can reach is the bubble itself.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @fill 0xFF_11_18_27
  @ink 0xFF_FF_FF_FF
  @gap 6

  # The arrow is 12dp across its base and 6dp deep, which is small enough that a
  # `:radius_sm` corner never eats it.
  @span 12
  @depth 6

  # Both spellings, so a caller porting `side="top"` straight off the web page
  # gets the same node an atom would build. A lookup rather than
  # String.to_atom/1: the value set is closed, and an unknown one should fall
  # back to the default instead of minting an atom nothing reads.
  @sides %{
    :top => :top,
    :bottom => :bottom,
    :left => :left,
    :right => :right,
    "top" => :top,
    "bottom" => :bottom,
    "left" => :left,
    "right" => :right
  }

  @aligns %{
    :start => :start,
    :center => :center,
    :end => :end,
    "start" => :start,
    "center" => :center,
    "end" => :end
  }

  @doc "Composite expander (`<MishkaTooltip>`). Children are the trigger."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: tooltip(props, children)

  @doc """
  The tooltip node. Children are the control the hint describes; hold one to
  reveal it. With no children you get the bare bubble, for a screen that places
  its own.

      <MishkaTooltip
        text="Copy to clipboard"
        open={@tip == :copy}
        side={:bottom}
        arrow={true}
        on_open_change={{:tip, :copy}}
      >
        <MishkaActionIcon icon="⧉" />
      </MishkaTooltip>

      def handle_info({:tap, {{:tip, which}, open?}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :tip, if(open?, do: which, else: nil))}
      end
  """
  @spec tooltip(map() | keyword(), [map()]) :: map()
  def tooltip(props \\ %{}, children \\ []) do
    props = Map.new(props)
    side = side(props)
    open? = truthy?(Map.get(props, :open, false)) and not disabled?(props)

    case children do
      [] -> if open?, do: bubble(props, side), else: ~MOB(<Column />)
      _ -> anchored(props, children, side, open?)
    end
  end

  # Trigger and bubble in one stack. The bubble comes first for `:top` / `:left`
  # and last for `:bottom` / `:right`, so `side` is literally the side of the
  # trigger it lands on. Closed, only the trigger is emitted — the gap goes with
  # the bubble, or every tooltip on the page would reserve 6dp forever.
  defp anchored(props, children, :top, open?) do
    lead = if open?, do: [aligned(props, :top), spacer(gap(props))], else: []
    column(props, lead ++ [trigger(props, children)])
  end

  defp anchored(props, children, :bottom, open?) do
    trail = if open?, do: [spacer(gap(props)), aligned(props, :bottom)], else: []
    column(props, [trigger(props, children) | trail])
  end

  defp anchored(props, children, :left, open?) do
    lead = if open?, do: [bubble(props, :left), spacer(gap(props))], else: []
    beside(props, lead ++ [trigger(props, children)])
  end

  defp anchored(props, children, :right, open?) do
    trail = if open?, do: [spacer(gap(props)), bubble(props, :right)], else: []
    beside(props, [trigger(props, children) | trail])
  end

  # `align` across a vertical side is horizontal placement, and a flexible
  # Spacer on the free side is what produces it. Compose measures the unweighted
  # children of a Row first, so the bubble takes exactly its content width and
  # the spacers divide whatever is left. A stack that is not filling has no
  # "left" to divide, so it gets the bubble alone.
  defp aligned(props, side) do
    fill? = fill?(props)

    parts =
      case {fill?, align(props)} do
        {false, _} -> [bubble(props, side)]
        {true, :start} -> [bubble(props, side), flex()]
        {true, :end} -> [flex(), bubble(props, side)]
        {true, _} -> [flex(), bubble(props, side), flex()]
      end

    ~MOB"""
    <Row fill_width={fill?}>
      {parts}
    </Row>
    """
  end

  # Across a horizontal side the same alignment is vertical, which a Row already
  # expresses — so it is the Row's own `align`, not a pair of spacers.
  defp beside(props, children) do
    cross = cross(props)
    fill? = fill?(props)
    children = if fill?, do: children ++ [flex()], else: children

    ~MOB"""
    <Row fill_width={fill?} align={cross}>
      {children}
    </Row>
    """
  end

  defp bubble(props, side) do
    body = body(props)

    node =
      if truthy?(Map.get(props, :arrow, false)) do
        pointed(props, body, side)
      else
        body
      end

    {x, y} = offsets(props, side)

    node
    |> put(:offset_x, x)
    |> put(:offset_y, y)
  end

  defp body(props) do
    text = Map.get(props, :text)
    fill = Map.get(props, :background, @fill)
    ink = Map.get(props, :color, @ink)
    size = Map.get(props, :text_size, :sm)

    # `fill_width={false}` is what makes this a hint rather than a bar: a Box
    # with neither a width nor the flag fills its parent, which is how this used
    # to render the full width of the screen. `max_lines` guards the other end —
    # a Text squeezed narrower than its content wraps one character per line.
    node = ~MOB"""
    <Box background={fill} corner_radius={:radius_sm} padding={8} fill_width={false}>
      <Text text={text} text_size={size} text_color={ink} max_lines={1} />
    </Box>
    """

    node
    |> put(:id, tag(props, "open"))
    |> put(:on_tap, dismiss(props))
  end

  # The arrow rides in a stacking Box aligned to the edge that faces the
  # trigger, over a sibling that reserves exactly its depth. Nothing here
  # measures the bubble, so alignment is the only way to centre the triangle on
  # an edge whose length is decided by the text.
  defp pointed(props, body, side) do
    fill = Map.get(props, :background, @fill)
    head = put(arrow(fill, side), :id, tag(props, "arrow-#{side}"))
    room = spacer(@depth)

    case side do
      :top -> stack(:bottom_center, [pile([body, room]), head])
      :bottom -> stack(:top_center, [pile([room, body]), head])
      :left -> stack(:trailing, [middle([body, room]), head])
      :right -> stack(:leading, [middle([room, body]), head])
    end
  end

  # A filled triangle whose apex points back at the trigger. Drawn rather than
  # typed: a "▾" glyph sits on a baseline with descent space under it, so it
  # never lands on the edge it is supposed to touch.
  defp arrow(fill, side) do
    {w, h, points} = triangle(side)

    Mob.UI.canvas(
      width: w,
      height: h,
      draw: [Mob.Canvas.path(points, color: fill, fill: true, closed: true)]
    )
  end

  defp triangle(:top), do: {@span, @depth, [{0, 0}, {@span, 0}, {@span / 2, @depth}]}
  defp triangle(:bottom), do: {@span, @depth, [{0, @depth}, {@span, @depth}, {@span / 2, 0}]}
  defp triangle(:left), do: {@depth, @span, [{0, 0}, {@depth, @span / 2}, {0, @span}]}
  defp triangle(:right), do: {@depth, @span, [{@depth, 0}, {0, @span / 2}, {@depth, @span}]}

  # `align_offset` is the web's nudge along the alignment axis, and which axis
  # that is depends on the side. It adds to whatever `offset_x` / `offset_y` the
  # caller set rather than replacing it, so neither silently wins.
  defp offsets(props, side) do
    nudge = Map.get(props, :align_offset, 0)
    x = Map.get(props, :offset_x)
    y = Map.get(props, :offset_y)

    if side in [:top, :bottom], do: {sum(x, nudge), y}, else: {x, sum(y, nudge)}
  end

  defp sum(nil, 0), do: nil
  defp sum(nil, nudge), do: nudge
  defp sum(offset, nudge), do: offset + nudge

  # The trigger hugs the control it wraps, so the long press covers the control
  # and not the whole row it happens to sit in.
  #
  # `on_tap` rides on the same Box because a clickable CHILD would eat the hold:
  # Compose gives the gesture to the innermost clickable, so an ActionIcon with
  # its own `on_tap` inside a tooltip means the tooltip never opens. One
  # combinedClickable carries both, which is why the trigger owns the tap.
  defp trigger(props, children) do
    %{type: :box, props: %{fill_width: false}, children: children}
    |> put(:id, tag(props, "trigger"))
    |> put(:on_long_press, hold(props))
    |> put(:on_tap, Event.handler(Map.get(props, :on_tap)))
  end

  # The event carries the state the tooltip wants NEXT, which is what the web's
  # on_open_change reports — so holding an open tooltip closes it again, and one
  # clause in the screen serves both directions.
  defp hold(props) do
    if disabled?(props) do
      nil
    else
      Event.handler(Map.get(props, :on_open_change), not truthy?(Map.get(props, :open, false)))
    end
  end

  # The web closes on blur, pointer-leave or Escape. A phone has none of the
  # three; the bubble is the one part of a dismissal a finger can reach.
  defp dismiss(props) do
    if truthy?(Map.get(props, :close_on_tap, true)) do
      Event.handler(Map.get(props, :on_open_change), false)
    end
  end

  defp tag(props, suffix) do
    case Map.get(props, :id) do
      nil -> nil
      id -> "#{id}-#{suffix}"
    end
  end

  defp side(props), do: Map.get(@sides, Map.get(props, :side, :top), :top)
  defp align(props), do: Map.get(@aligns, Map.get(props, :align, :center), :center)
  defp gap(props), do: Map.get(props, :side_offset, @gap)
  defp disabled?(props), do: truthy?(Map.get(props, :disabled, false))
  defp fill?(props), do: Map.get(props, :fill_width, true) != false

  defp cross(props) do
    case align(props) do
      :start -> :top
      :end -> :bottom
      _ -> :center
    end
  end

  defp column(props, children),
    do: %{type: :column, props: %{fill_width: fill?(props)}, children: children}

  # Unlike `column/1` this one carries no `fill_width`, so it hugs the bubble it
  # holds — the arrow's stacking Box has to size to the bubble for `align` to
  # land the triangle on the bubble's edge rather than the screen's.
  defp pile(children), do: %{type: :column, props: %{}, children: children}
  defp middle(children), do: %{type: :row, props: %{align: :center}, children: children}
  defp spacer(size), do: %{type: :spacer, props: %{size: size}, children: []}
  defp flex, do: %{type: :spacer, props: %{weight: 1}, children: []}

  defp stack(align, children),
    do: %{type: :box, props: %{fill_width: false, align: align}, children: children}

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
