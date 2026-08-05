defmodule MishkaMob.Components.MishkaFloatingWindow do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Floating Window** — a titled
  panel that floats over a stage and is dragged by its title bar.

  ## The drag is real

  This port shipped saying "Mob delivers no pointer coordinates to `render/1`,
  so the drag cannot be ported". That was false: `Mob.Renderer` registers
  `on_drag` beside `on_tap` (renderer.ex ~395) and several components in this
  library already drive themselves with it. What *is* true is that only a
  `:canvas` carries `on_drag`, and that a canvas reports coordinates local to
  **itself** — so the drag surface is one STATIC canvas the size of the whole
  stage. A canvas riding on the window would be a ruler sliding under the
  finger: the window moves, the canvas moves with it, the next sample reads the
  same local `x`, and the window creeps a fraction of the gesture. That is not
  a theory — `MishkaSplitter` measured it, moving 10dp for a 60dp drag while
  its arithmetic was provably right.

  Read `x`/`y` from the payload, never `dx`/`dy`: those are cumulative
  translation on iOS and per-sample deltas on Android, so anything built on
  them behaves differently on each platform. `drag/3` reads only `x`/`y`.

  `bounds` is therefore not decoration. It is the stage in dp: it sizes the
  canvas, it is the space the position is clamped inside, and without it there
  is no drag surface at all.

  ## Three layers, and which finger reaches which

  The root is a `Box` — a z-stack on both platforms — holding, in order:

      1. the panel      background, border, title strip, label. No handlers.
      2. the canvas     the whole stage, transparent, carries on_drag.
      3. the controls   the body, the ✕, the nudge arrows — each at its own offset.

  Anything a finger must *tap* has to sit above the canvas: the canvas consumes
  the touch that starts on it, and on iOS a view with a background blocks the
  gesture of the sibling beneath it. Anything the *drag* must reach has to sit
  below it — which is why the title strip and its label carry no handlers, and
  why the ✕ is the only thing in the title bar that does not begin a drag,
  exactly the carve-out the web original words as "interactive controls inside
  the handle don't start a drag".

  Layer 3 is placed by arithmetic rather than by layout, so the window is a
  fixed rectangle: `width` by `height`, with a 48dp title bar and a 48dp nudge
  row. That is the price of a drag surface that cannot move, and it is what
  lets `drag/3` decide whether a touch landed on the handle without asking the
  native side to measure anything.

  ## Moving it

  `on_move` carries both halves of what WCAG 2.5.7 asks for — the pointer drag,
  and the keyboard-style alternative:

      {:drag, tag, payload}     from the canvas   -> fold with drag/3
      {:tap, {tag, :up}}        from an arrow     -> fold with nudge/2

  Both folds read the same prop map, which is what makes `step` and `bounds`
  live props rather than the documentation they used to be:

      def handle_info({:drag, :move, payload}, socket) do
        {position, grab} = MishkaFloatingWindow.drag(payload, socket.assigns.grab, window(socket))
        {:noreply, socket |> assign(:pos, position) |> assign(:grab, grab)}
      end

      def handle_info({:tap, {:move, direction}}, socket) do
        {:noreply, assign(socket, :pos, MishkaFloatingWindow.nudge(window(socket), direction))}
      end

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `x` / `y` | number | `0` | Position inside the stage. |
  | `width` / `height` | number | `260` / `180` | The window is a fixed rectangle. |
  | `bounds` | `{w, h}` | `nil` | The stage in dp. Sizes the drag canvas; clamps the position. |
  | `step` | number | `20` | How far one nudge moves. |
  | `label` | string | `nil` | Title shown in the strip. |
  | `handle` | node(s) | `nil` | Title-bar content instead of `label`. Decoration — it takes no taps. |
  | `dragging` | boolean | `false` | The web's `data-dragging`: tints the strip and lands in its test tag. |
  | `show_nudges` | boolean | `true` | The arrow row, when `on_move` is set. |
  | `on_move` | event tag (atom) | — | Drag payloads *and* `{:tap, {tag, :up}}`. |
  | `on_close` | event tag (atom) | — | `{:tap, tag}` on the ✕. |
  | `id` | string | `nil` | Test tags — see `part_id/2` and `handle_id/2`. |

  ## Slots

  Children are the window's body, except for `<MishkaFloatingWindowHandle>` — the
  web's `<:handle>`, a title bar of your own in place of `label`:

      <MishkaFloatingWindow width={240} height={110} id="custom">
        <MishkaFloatingWindowHandle>
          <Row align={:center}>
            <Box width={8} height={8} background={:primary} corner_radius={:radius_pill} />
            <Spacer size={8} />
            <Text text="build.log" text_size={:sm} max_lines={1} />
          </Row>
        </MishkaFloatingWindowHandle>
        <Text text="The window body goes here." />
      </MishkaFloatingWindow>

  `handle/1` builds the identical node for when the bar comes from data, and the
  `handle:` prop still takes one directly. **A slot wins over the prop**, the
  same way a Dialog's title slot wins over its `title:` string — passing both is
  redundant, not wrong.

  The handle is DECORATION either way: it sits under the drag surface, so the
  whole bar stays draggable and the handle itself takes no taps.

  A slot tag has no module and no expander — it arrives with its subtree intact
  and `floating_window/2` consumes it. One that leaked past would reach the
  renderer as an unknown node and draw nothing at all, silently, because the tag
  name is whitelisted; `slot_types/0` is exported so a test can name it.

  Not ported: `handle_label` (Mob exposes no accessibility semantics to hang a
  role or a label on), `class` / `handle_class` / `body_class` (no CSS), and
  Shift+Arrow's 1px step — there are no modifier keys on a touch screen, so
  `step` is the one increment.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Color, Event}

  @width 260
  @height 180

  # The title bar and every control in it are 48dp: Material's minimum touch
  # target. The arrows used to be 4dp of padding round a glyph — about 20dp of
  # target, which is a miss more often than a tap.
  @handle 48
  @touch 48

  # The web nudges 10px, or 1px with Shift. There is no Shift here, so a step
  # has to be worth taking: 20dp moves the window visibly on a phone.
  @step 20

  @gutter 12

  # The handle slot. A slot tag has no module and no expander — it arrives with
  # its subtree intact and `floating_window/2` consumes it below.
  @handle_slot :mishka_floating_window_handle

  @arrows [{:left, "←"}, {:up, "↑"}, {:down, "↓"}, {:right, "→"}]

  @doc """
  Composite expander (`<MishkaFloatingWindow>`). Children are the window body, plus an
  optional `<MishkaFloatingWindowHandle>` slot tag.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: floating_window(props, children)

  @doc """
  A title bar of your own — the web's `<:handle>`, as a builder as well as a tag.

  `<MishkaFloatingWindowHandle>` builds the identical node, so write the
  tag out when the bar is written out and reach for this when it comes from
  data. Either way it is DECORATION: it sits under the drag surface, so the
  whole bar stays draggable and the handle itself takes no taps.
  """
  @spec handle(map() | [map()]) :: map()
  def handle(content), do: %{type: @handle_slot, props: %{}, children: List.wrap(content)}

  @doc """
  Every node type the window consumes as a slot. Exported so a test can prove
  none of them leaked past `floating_window/2` to the renderer — a leak is
  silent, since the tag name is whitelisted and an unknown node simply draws
  nothing.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: [@handle_slot]

  @doc """
  The window.

      <MishkaFloatingWindow
        x={@x}
        y={@y}
        bounds={{300, 220}}
        label="Inspector"
        on_move={:move}
        id="win"
      >
        <Text text="Anything at all." />
      </MishkaFloatingWindow>
  """
  @spec floating_window(map() | keyword(), [map()]) :: map()
  def floating_window(props \\ %{}, children \\ []) do
    props = Map.new(props)
    {slots, content} = Enum.split_with(children, &match?(%{type: @handle_slot}, &1))

    # A handle slot wins over the `handle:` prop, the same way a Dialog's title
    # slot wins over its `title:` string — passing both is redundant, not wrong.
    props =
      case slots do
        [] -> props
        nodes -> Map.put(props, :handle, Enum.flat_map(nodes, & &1.children))
      end

    layers = [panel(props), surface(props), body(props, content), close(props) | nudges(props)]

    %{type: :box, props: stage(props), children: Enum.reject(layers, &is_nil/1)}
  end

  @doc """
  Fold a drag payload into a new `{x, y}`.

  Returns `{position, grab}` — keep `grab` in an assign and hand it back with
  the next payload. It is `nil` between drags, and `nil` for a touch that began
  anywhere but the title bar.

  The canvas spans the stage and never moves, so `x`/`y` are positions in stage
  coordinates rather than distances. `grab` records where on the title bar the
  finger took hold, so the window does not jump to centre itself under it:

      iex> alias MishkaMob.Components.MishkaFloatingWindow
      iex> props = %{x: 20, y: 10, width: 200, height: 120, bounds: {300, 220}}
      iex> {position, grab} = MishkaFloatingWindow.drag(%{phase: :began, x: 40.0, y: 20.0}, nil, props)
      iex> {position, grab.offset}
      {{20, 10}, {20.0, 10.0}}
      iex> {moved, _} = MishkaFloatingWindow.drag(%{phase: :dragging, x: 90.0, y: 60.0}, grab, props)
      iex> moved
      {70.0, 50.0}

  A touch that misses the title bar engages nothing. The canvas covers the
  whole stage — it has to, to be a stable ruler — so without this every tap
  would teleport the window to the finger:

      iex> alias MishkaMob.Components.MishkaFloatingWindow
      iex> props = %{x: 20, y: 10, width: 200, height: 120, bounds: {300, 220}}
      iex> MishkaFloatingWindow.drag(%{phase: :began, x: 40.0, y: 120.0}, nil, props)
      {{20, 10}, nil}
  """
  @spec drag(map(), map() | nil, map() | keyword()) :: {{number(), number()}, map() | nil}
  def drag(payload, grab, props \\ %{}) do
    props = Map.new(props)
    at = point(payload)

    case phase(payload) do
      :began -> {position(props), take_hold(at, props)}
      :dragging -> {follow(at, grab, props), grab}
      :ended -> {follow(at, grab, props), nil}
    end
  end

  @doc """
  The position after a nudge, clamped inside the stage.

  Reads `x`, `y`, `step` and `bounds` from the same prop map the window renders
  with — which is the point. `step` and `bounds` were documented props that
  nothing read, so a caller who set them got the defaults and no complaint.

  Screen coordinates put y downwards, so `:up` **subtracts** — the sign that is
  easy to get backwards.

      iex> MishkaMob.Components.MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :up)
      {40, 30}

      iex> MishkaMob.Components.MishkaFloatingWindow.nudge(%{x: 40, y: 40, step: 10}, :right)
      {50, 40}

  The clamp is the stage **minus the window**, so it stops with its far edge
  against the far edge of the stage rather than walking half out of view:

      iex> MishkaMob.Components.MishkaFloatingWindow.nudge(
      ...>   %{x: 90, y: 0, step: 20, width: 120, height: 80, bounds: {200, 200}},
      ...>   :right
      ...> )
      {80, 0}

      iex> MishkaMob.Components.MishkaFloatingWindow.nudge(%{x: 0, y: 0, bounds: {200, 200}}, :left)
      {0, 0}
  """
  @spec nudge(map() | keyword(), :up | :down | :left | :right) :: {number(), number()}
  def nudge(props, direction) do
    props = Map.new(props)
    {x, y} = position(props)
    step = Map.get(props, :step, @step)

    moved =
      case direction do
        :up -> {x, y - step}
        :down -> {x, y + step}
        :left -> {x - step, y}
        :right -> {x + step, y}
        _ -> {x, y}
      end

    clamp(moved, props)
  end

  @doc """
  The test tag on one part of the window, given the window's `id`.

  A drag surface is a drawing and a nudge arrow is a glyph — neither carries
  text a device test can query, so this is the only handle it has on them.

      iex> MishkaMob.Components.MishkaFloatingWindow.part_id("win", :close)
      "win-close"

      iex> MishkaMob.Components.MishkaFloatingWindow.part_id("win", {:nudge, :up})
      "win-nudge-up"

      iex> MishkaMob.Components.MishkaFloatingWindow.part_id(nil, :close)
      nil
  """
  @spec part_id(String.t() | nil, atom() | {atom(), atom()}) :: String.t() | nil
  def part_id(id, {part, value}) when is_binary(id), do: "#{id}-#{part}-#{value}"
  def part_id(id, part) when is_binary(id), do: "#{id}-#{part}"
  def part_id(_id, _part), do: nil

  @doc """
  The title strip's test tag, which carries the drag state.

  The web mirrors that state as `data-dragging`; here it has to be in the tag,
  because the only other place it shows is the strip's colour — and a device
  test cannot read a colour.

      iex> MishkaMob.Components.MishkaFloatingWindow.handle_id("win", false)
      "win-handle"

      iex> MishkaMob.Components.MishkaFloatingWindow.handle_id("win", true)
      "win-handle-dragging"
  """
  @spec handle_id(String.t() | nil, boolean()) :: String.t() | nil
  def handle_id(id, true) when is_binary(id), do: "#{id}-handle-dragging"
  def handle_id(id, _dragging) when is_binary(id), do: "#{id}-handle"
  def handle_id(_id, _dragging), do: nil

  @doc """
  The height of everything above the body — the title bar, plus the nudge row
  when there is one. The body starts here, and spends the rest of `height`.

      iex> MishkaMob.Components.MishkaFloatingWindow.chrome_height(%{})
      48

      iex> MishkaMob.Components.MishkaFloatingWindow.chrome_height(%{on_move: :move})
      96
  """
  @spec chrome_height(map() | keyword()) :: number()
  def chrome_height(props) do
    props = Map.new(props)

    if nudges?(props), do: @handle + @touch, else: @handle
  end

  # ── The three layers ───────────────────────────────────────────────────────

  # The stage. Sized to `bounds` when there is one, so the canvas can never be
  # declared wider than the space it gets: MobCanvas SCALES its ops to fit,
  # which would report every coordinate in a different unit from the dp offsets
  # the window is positioned with.
  defp stage(props) do
    base =
      case bounds(props) do
        {w, h} -> %{width: w, height: h}
        nil -> %{fill_width: true}
      end

    case Map.get(props, :id) do
      nil -> base
      id -> Map.put(base, :id, id)
    end
  end

  # Layer 1: everything a finger must be able to drag THROUGH. Nothing here
  # carries a handler, so the touch falls past it to the canvas above.
  defp panel(props) do
    {x, y} = position(props)
    id = Map.get(props, :id)
    w = width(props)
    h = height(props)
    handle = @handle
    gutter = @gutter
    dragging? = dragging?(props)
    strip = if dragging?, do: :primary, else: :surface_raised

    ~MOB"""
    <Box
      offset_x={x}
      offset_y={y}
      width={w}
      height={h}
      background={:surface}
      corner_radius={:radius_md}
      border_color={:border}
      border_width={1}
      id={part_id(id, :window)}
    >
      <Box
        width={w}
        height={handle}
        background={strip}
        align={:leading}
        id={handle_id(id, dragging?)}
      >
        <Row fill_width={true} align={:center}>
          <Box width={gutter} />
          <Box width={title_width(props)}>
            {title(props, dragging?)}
          </Box>
        </Row>
      </Box>
    </Box>
    """
  end

  # The title stops where the ✕ starts. The ✕ is a layer-3 overlay at a computed
  # offset rather than a sibling in this row — it has to be, to sit above the
  # canvas — so nothing here reserves its space unless this does.
  defp title_width(props) do
    reserved = if Map.get(props, :on_close), do: @touch, else: @gutter

    max(width(props) - @gutter - reserved, 0)
  end

  defp title(props, dragging?) do
    ink = if dragging?, do: :on_primary, else: :on_surface

    case Map.get(props, :handle) do
      nil ->
        # max_lines: 1 — a Text squeezed narrower than its content wraps
        # character by character, and this one shares its row with the ✕.
        ~MOB"""
        <Text
          text={Map.get(props, :label) || ""}
          text_size={:sm}
          text_color={ink}
          font_weight={:semibold}
          max_lines={1}
        />
        """

      handle ->
        %{type: :column, props: %{}, children: List.wrap(handle)}
    end
  end

  # Layer 2: the drag surface. One canvas, the size of the stage, transparent,
  # and it never moves — the moduledoc says what a moving one does.
  #
  # `Mob.UI.canvas/1` is `Map.take(props, [:width, :height, :draw])`: it drops
  # every handler, which is the "renders perfectly and does nothing" failure.
  # `Canvas` is not in the ~MOB tag whitelist either, so this is built literally.
  defp surface(props) do
    handler = Event.handler(Map.get(props, :on_move))

    case {bounds(props), handler} do
      {{w, h}, handler} when not is_nil(handler) ->
        # One transparent rect rather than an empty op list: a canvas is
        # hit-tested by its frame on both platforms, but nothing promises how
        # either renderer sizes a canvas that draws literally nothing. `rect`
        # STROKES by default, hence `fill: true` — a stroked transparent rect is
        # no more visible, but this is the op that gets copied.
        %{
          type: :canvas,
          props: %{
            width: w,
            height: h,
            draw: [Mob.Canvas.rect(0, 0, w, h, color: 0x00000000, fill: true)],
            on_drag: handler
          },
          children: []
        }
        |> tag(part_id(Map.get(props, :id), :drag))

      _ ->
        nil
    end
  end

  # Layer 3, placed by arithmetic. The body lives up here rather than inside the
  # panel because the canvas would otherwise swallow every tap meant for it.
  defp body(props, children) do
    {x, y} = position(props)
    chrome = chrome_height(props)

    ~MOB"""
    <Box
      offset_x={x}
      offset_y={y + chrome}
      width={width(props)}
      height={max(height(props) - chrome, 0)}
      id={part_id(Map.get(props, :id), :body)}
    >
      <Column fill_width={true} padding={:space_md}>
        {children}
      </Column>
    </Box>
    """
  end

  defp close(props) do
    case Event.handler(Map.get(props, :on_close)) do
      nil ->
        nil

      handler ->
        {x, y} = position(props)
        touch = @touch

        ~MOB"""
        <Box
          offset_x={x + width(props) - touch}
          offset_y={y}
          width={touch}
          height={touch}
          align={:center}
          on_tap={handler}
          id={part_id(Map.get(props, :id), :close)}
        >
          <Text text="✕" text_size={:sm} text_color={:muted} />
        </Box>
        """
    end
  end

  # Arrows exist only to move the window, so an unwired one is a control that
  # renders perfectly and does nothing. Don't render it at all.
  defp nudges(props) do
    if nudges?(props) do
      {x, y} = position(props)
      id = Map.get(props, :id)
      touch = @touch
      handle = @handle

      @arrows
      |> Enum.with_index()
      |> Enum.map(fn {{direction, glyph}, index} ->
        ~MOB"""
        <Box
          offset_x={x + index * touch}
          offset_y={y + handle}
          width={touch}
          height={touch}
          align={:center}
          on_tap={Event.handler(Map.get(props, :on_move), direction)}
          id={part_id(id, {:nudge, direction})}
        >
          <Text text={glyph} text_size={:sm} text_color={:muted} />
        </Box>
        """
      end)
    else
      []
    end
  end

  # ── The drag fold ──────────────────────────────────────────────────────────

  # Engage only when the touch lands on the title bar. The canvas covers the
  # whole stage — it must, to be a stable ruler — so without this every tap
  # anywhere on the stage would teleport the window to the finger.
  defp take_hold({ax, ay}, props) do
    {x, y} = position(props)

    if ax >= x and ax <= x + width(props) and ay >= y and ay <= y + @handle do
      %{offset: {ax - x, ay - y}}
    end
  end

  defp follow(_at, nil, props), do: position(props)

  defp follow({ax, ay}, %{offset: {ox, oy}}, props), do: clamp({ax - ox, ay - oy}, props)

  defp clamp({x, y}, props) do
    case bounds(props) do
      nil ->
        {x, y}

      {w, h} ->
        {Color.clamp(x, 0, max(w - width(props), 0)),
         Color.clamp(y, 0, max(h - height(props), 0))}
    end
  end

  # The NIF sends `phase` as an ATOM (:began / :dragging / :ended). Comparing it
  # against "began" matches nothing and falls through to the :dragging default,
  # so the anchor is never set and every drag returns the position unchanged —
  # the window looks completely dead while the arithmetic is fine. Strings are
  # accepted too, because a payload that has crossed a wire may be either.
  defp phase(payload) do
    case payload[:phase] || payload["phase"] do
      p when p in [:began, "began"] -> :began
      p when p in [:ended, "ended"] -> :ended
      _ -> :dragging
    end
  end

  # x/y, never dx/dy: those are cumulative translation on iOS and per-sample
  # deltas on Android, so a fold built on them drifts on exactly one platform.
  defp point(payload), do: {coordinate(payload, :x), coordinate(payload, :y)}

  defp coordinate(payload, key), do: (payload[key] || payload[to_string(key)] || 0) * 1.0

  # ── Props ──────────────────────────────────────────────────────────────────

  defp position(props), do: {Map.get(props, :x, 0), Map.get(props, :y, 0)}
  defp width(props), do: Map.get(props, :width, @width)
  defp height(props), do: Map.get(props, :height, @height)

  defp bounds(props) do
    case Map.get(props, :bounds) do
      {w, h} -> {w, h}
      _ -> nil
    end
  end

  defp dragging?(props), do: truthy?(Map.get(props, :dragging, false))

  defp nudges?(props) do
    Map.get(props, :on_move) != nil and truthy?(Map.get(props, :show_nudges, true))
  end

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
