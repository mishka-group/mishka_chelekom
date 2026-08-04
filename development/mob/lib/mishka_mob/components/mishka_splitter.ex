defmodule MishkaMob.Components.MishkaSplitter do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Splitter** — two panes sharing
  an extent, with a control that changes the split.

  ## Panes are sized, not weighted

  Compose has `weight` and SwiftUI does not, so a proportional split built from
  weighted boxes would work on Android and collapse on iOS. Instead the splitter
  takes an explicit `extent` — the total width (or height) it has to divide —
  and computes each pane in dp from the percentage. `sizes/1` does that
  arithmetic and is public, so a screen that knows its own dimensions can ask
  for the numbers without rendering.

  ## The divider IS the handle

  Grab the bar between the panes and slide it, exactly as on the web. This
  component used to ship a `Slider` bolted under the panes instead, on the
  stated grounds that "Mob delivers no pointer coordinates to `render/1`" —
  which was simply not true. `Mob.Renderer` registers `on_drag` as a
  first-class handler alongside `on_tap` and `on_change`, and four components
  in this library already use it.

  The catch is that only a `:canvas` node carries `on_drag`, and a canvas
  reports **canvas-local** coordinates. The grip is a small canvas, so its `x`
  is meaningless as an absolute position — but it keeps reporting while the
  finger travels outside its bounds, so the *movement* is exact. `drag/3` folds
  that into a percentage by anchoring on the `"began"` phase:

      def handle_change(:split, payload, socket) do
        {value, grab} =
          MishkaSplitter.drag(payload, socket.assigns.grab, value: socket.assigns.split)

        {:noreply, socket |> assign(:split, value) |> assign(:grab, grab)}
      end

  Use `x`/`y`, never `dx`/`dy`: on iOS those are cumulative translation and on
  Android they are per-sample deltas, so anything built on them behaves
  differently on each platform. `drag/3` reads only `x`/`y`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | 0–100 | `50` | First pane's share, as a percentage. |
  | `orientation` | `:horizontal` · `:vertical` | `:horizontal` | Side by side, or stacked. |
  | `extent` | number | `320` | Total dp to divide. |
  | `min` / `max` | 0–100 | `10` / `90` | Bounds the split. |
  | `disabled` | boolean | `false` | The grip stops responding and greys. |
  | `grip` | number | `24` | Thickness of the drag target across the divider. |
  | `grip_color` | ARGB int | grey | The pill. An **int**, not a token — see `grip_ops/4`. |
  | `on_change` | event tag (atom) | — | `{:drag, tag, payload}` as the divider moves. |
  | `id` | string | `nil` | Test tag; the grip gets `<id>-grip`. |

  Children are the two panes; anything past the second is ignored.

  Not ported: keyboard resizing (`Arrow`/`Home`/`End` — there is no focus ring
  on a Mob canvas to receive the keys) and `*_class`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event}

  @extent 320

  # The drag target across the divider, and how far it reaches along it. 24dp is
  # a compromise: the web resizer is a hairline, but a hairline is not a touch
  # target, and Material asks for 48.
  @grip 24
  @reach 48

  # Canvas draw ops take ARGB ints — the renderer resolves colour TOKENS only
  # for node props, never for the contents of `draw`. So the grip cannot be
  # `:muted` the way the old boxed divider was, and its default has to be a
  # literal. `grip_color` exists so a caller is not stuck with this grey.
  @grip_on 0xFF6B7280
  @grip_off 0xFFB6BCC6
  @grip_band 0x14000000

  @doc "Composite expander (`<MishkaSplitter>`). The first two children are the panes."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: splitter(props, children)

  @doc """
  The splitter.

      <MishkaSplitter
        value={@split}
        extent={340}
        on_change={:split}
      >{[left_pane(), right_pane()]}</MishkaSplitter>
  """
  @spec splitter(map() | keyword(), [map()]) :: map()
  def splitter(props \\ %{}, panes \\ []) do
    props = Map.new(props)
    {first_size, second_size} = sizes(props)
    [first, second] = two(panes)

    axis = orientation(props)

    panes =
      case axis do
        :vertical -> stacked(first, second, first_size, second_size, props)
        :horizontal -> side_by_side(first, second, first_size, second_size, props)
      end

    # A Box is a z-stack on both platforms, so the drag surface lies OVER the
    # panes rather than beside them. It has to: see `overlay/2`.
    %{
      type: :box,
      props: %{fill_width: true},
      children: [panes, overlay(props, axis)]
    }
    |> tag(Map.get(props, :id))
  end

  @doc """
  Fold a drag payload into a new split percentage.

  Returns `{value, grab}` — keep `grab` in an assign and hand it back on the
  next payload; it is `nil` between drags, and `nil` for a touch that missed the
  divider.

  The drag surface is a canvas spanning the whole extent, which makes `x` a
  position rather than a distance — so this maps absolutely. It has to be that
  way round: a canvas reports coordinates local to *itself*, so a small canvas
  riding on the divider would be a ruler sliding under the finger.

      iex> alias MishkaMob.Components.MishkaSplitter
      iex> {value, grab} = MishkaSplitter.drag(%{phase: "began", x: 100.0}, nil, value: 50, extent: 200)
      iex> {value, grab.offset}
      {50, 0.0}
      iex> {moved, _} = MishkaSplitter.drag(%{phase: "dragging", x: 140.0}, grab, value: 50, extent: 200)
      iex> moved
      70.0

  A touch that misses the divider engages nothing — the canvas covers both
  panes, so without this every tap would teleport the split to the finger:

      iex> alias MishkaMob.Components.MishkaSplitter
      iex> MishkaSplitter.drag(%{phase: "began", x: 10.0}, nil, value: 50, extent: 200)
      {50, nil}
  """
  @spec drag(map(), map() | nil, map() | keyword()) :: {number(), map() | nil}
  def drag(payload, grab, props \\ %{}) do
    props = Map.new(props)
    axis = if orientation(props) == :vertical, do: :y, else: :x
    at = coordinate(payload, axis)

    case phase(payload) do
      :began -> begin_drag(at, props)
      :ended -> {follow(at, grab, props), nil}
      :dragging -> {follow(at, grab, props), grab}
    end
  end

  # Engage only when the touch lands ON the divider. The canvas covers the whole
  # splitter — it must, to be a stable ruler — so without this every tap
  # anywhere in either pane would teleport the split to the finger.
  defp begin_drag(at, props) do
    extent = Map.get(props, :extent, @extent)
    grip = Map.get(props, :grip, @grip)
    divider = extent * split(props) / 100

    if abs(at - divider) <= grip do
      # Remember where on the grip they took hold, so the divider does not jump
      # to centre itself under the finger.
      {split(props), %{offset: at - divider}}
    else
      {split(props), nil}
    end
  end

  defp follow(_at, nil, props), do: split(props)

  defp follow(at, %{offset: offset}, props) do
    extent = Map.get(props, :extent, @extent)
    percent = (at - offset) / max(extent, 1) * 100

    Color.clamp(percent * 1.0, Map.get(props, :min, 10) * 1.0, Map.get(props, :max, 90) * 1.0)
  end

  # The NIF sends `phase` as an ATOM (:began / :dragging / :ended). Comparing it
  # against "began" matched nothing and fell through to the :dragging default,
  # so the anchor was never set and every drag returned the split unchanged —
  # the divider looked completely dead while the arithmetic was fine. Strings
  # are accepted too, because a payload that has crossed a wire may be either.
  defp phase(payload) do
    case payload[:phase] || payload["phase"] do
      p when p in [:began, "began"] -> :began
      p when p in [:ended, "ended"] -> :ended
      _ -> :dragging
    end
  end

  defp coordinate(payload, axis) do
    key = if axis == :y, do: :y, else: :x
    value = payload[key] || payload[to_string(key)] || 0
    value * 1.0
  end

  @doc """
  The two pane sizes in dp, clamped into `min..max` so a pane can never vanish.

      iex> MishkaMob.Components.MishkaSplitter.sizes(%{value: 50, extent: 300})
      {150.0, 150.0}

      iex> MishkaMob.Components.MishkaSplitter.sizes(%{value: 25, extent: 400})
      {100.0, 300.0}

  A value outside the bounds is pulled back inside them, not honoured:

      iex> MishkaMob.Components.MishkaSplitter.sizes(%{value: 0, extent: 300, min: 20})
      {60.0, 240.0}
  """
  @spec sizes(map() | keyword()) :: {float(), float()}
  def sizes(props) do
    props = Map.new(props)
    extent = Map.get(props, :extent, @extent)
    percent = split(props)
    first = extent * percent / 100

    {first * 1.0, (extent - first) * 1.0}
  end

  @doc """
  The split percentage after clamping — what the control and the panes agree on.

      iex> MishkaMob.Components.MishkaSplitter.split(%{value: 95, max: 90})
      90
  """
  @spec split(map() | keyword()) :: number()
  def split(props) do
    props = Map.new(props)

    Color.clamp(
      Map.get(props, :value, 50),
      Map.get(props, :min, 10),
      Map.get(props, :max, 90)
    )
  end

  defp side_by_side(first, second, first_size, second_size, props) do
    id = Map.get(props, :id)

    ~MOB"""
    <Row fill_width={true}>
      {tag(pane(first, %{width: first_size}), pane_id(id, 1))}
      {divider(props, :vertical)}
      {tag(pane(second, %{width: second_size}), pane_id(id, 2))}
    </Row>
    """
  end

  defp stacked(first, second, first_size, second_size, props) do
    id = Map.get(props, :id)

    ~MOB"""
    <Column fill_width={true}>
      {tag(pane(first, %{fill_width: true, height: first_size}), pane_id(id, 1))}
      {divider(props, :horizontal)}
      {tag(pane(second, %{fill_width: true, height: second_size}), pane_id(id, 2))}
    </Column>
    """
  end

  defp pane(content, size) do
    props = Map.merge(%{background: :surface, corner_radius: :radius_sm}, size)

    %{type: :box, props: props, children: [content]}
  end

  @doc """
  The test tag on a pane, given the splitter's `id` and the pane's number.

  The panes are what a device test measures — the split is a ratio between two
  widths, and neither is readable without a handle.

      iex> MishkaMob.Components.MishkaSplitter.pane_id("panes", 1)
      "panes-pane-1"
  """
  @spec pane_id(String.t() | nil, 1 | 2) :: String.t() | nil
  def pane_id(id, n) when is_binary(id), do: "#{id}-pane-#{n}"
  def pane_id(_id, _n), do: nil

  # The divider is a canvas, because a canvas is the only node that carries
  # on_drag. It is deliberately small — the touch target, not the whole splitter
  # — so a drag cannot swallow taps meant for the panes underneath.
  # An inert spacer where the divider sits, so the panes leave a gutter. The
  # thing you actually drag is the STATIC overlay below.
  defp divider(props, axis) do
    grip = Map.get(props, :grip, @grip)

    if axis == :vertical do
      ~MOB(<Box width={grip} fill_height={true} />)
    else
      ~MOB(<Box fill_width={true} height={grip} />)
    end
  end

  # The drag surface: ONE canvas spanning the whole extent, laid over the panes.
  #
  # It has to be this way round. A canvas reports coordinates local to ITSELF,
  # so a canvas that moves with the split is measuring against a ruler that
  # slides under the finger — each processed sample shifts the origin, the next
  # sample reads almost no movement, and the drag converges to a fraction of the
  # gesture. That is not a theory; it is what the device did, moving 10dp for a
  # 60dp drag while the arithmetic was provably right.
  #
  # Static and full-extent means `x` maps straight to a percentage, the way
  # MishkaHueSlider maps x to a hue.
  defp overlay(props, axis) do
    extent = Map.get(props, :extent, @extent)
    grip = Map.get(props, :grip, @grip)
    {w, h} = if axis == :vertical, do: {@reach, extent}, else: {extent, @reach}

    canvas_node(w, h, grip_ops(w, h, axis, props, extent, grip), props)
  end

  # `Mob.UI.canvas/1` is `Map.take(props, [:width, :height, :draw])` — it drops
  # every handler, which is the "renders perfectly and does nothing" failure.
  # `Canvas` is not in the ~MOB tag whitelist either, so this is built literally.
  defp canvas_node(width, height, ops, props) do
    handler = if disabled?(props), do: nil, else: Event.handler(Map.get(props, :on_change))

    canvas = %{type: :canvas, props: %{width: width, height: height, draw: ops}, children: []}

    canvas
    |> put(:on_drag, handler)
    |> tag(grip_id(Map.get(props, :id)))
  end

  # `fill: true` on every rect — Mob.Canvas.rect STROKES by default, so without
  # it the grip drew as a hollow outline and read as a broken box rather than a
  # handle.
  #
  # The pill, drawn at the split rather than centred: the canvas spans the whole
  # extent, so where the grip appears IS the split. A canvas has no children, so
  # this is drawn rather than boxed.
  defp grip_ops(width, height, axis, props, extent, grip) do
    ink = Map.get(props, :grip_color, if(disabled?(props), do: @grip_off, else: @grip_on))
    at = extent * split(props) / 100

    if axis == :vertical do
      [
        Mob.Canvas.rect(0, at - grip / 2, width, grip, color: @grip_band, radius: 2, fill: true),
        Mob.Canvas.rect(width / 2 - 14, at - 1.5, 28, 3, color: ink, radius: 2, fill: true)
      ]
    else
      [
        Mob.Canvas.rect(at - grip / 2, 0, grip, height, color: @grip_band, radius: 2, fill: true),
        Mob.Canvas.rect(at - 1.5, height / 2 - 14, 3, 28, color: ink, radius: 2, fill: true)
      ]
    end
  end

  @doc """
  The test tag on the drag grip, given the splitter's `id`.

  A canvas is a drawing — no text, no label — so this is the only handle a
  device test has on the thing it needs to drag.

      iex> MishkaMob.Components.MishkaSplitter.grip_id("panes")
      "panes-grip"
  """
  @spec grip_id(String.t()) :: String.t()
  def grip_id(id) when is_binary(id), do: id <> "-grip"
  def grip_id(_), do: nil

  defp orientation(props) do
    case Map.get(props, :orientation, :horizontal) do
      :vertical -> :vertical
      "vertical" -> :vertical
      _ -> :horizontal
    end
  end

  # Missing panes render as empty boxes rather than crashing a screen mid-edit.
  defp two(panes) do
    case List.wrap(panes) do
      [first, second | _] -> [first, second]
      [first] -> [first, blank()]
      [] -> [blank(), blank()]
    end
  end

  defp blank, do: ~MOB(<Spacer size={0} />)

  defp disabled?(props), do: truthy?(Map.get(props, :disabled, false))

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
