defmodule MishkaMob.Components.MishkaDrawer do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Drawer** — an edge-anchored
  panel that slides in over a dimmed backdrop, with the gestures the web version
  is built around: a drag handle, swipe-to-dismiss, snap points, and an edge
  area you can swipe in from.

  Built as a pure-Elixir `Mob.Composite` (a custom `<MishkaDrawer>` tag), so it
  ships **no native Swift/Kotlin** — it expands into Mob's built-in `Box` /
  `Row` / `Column` / `Canvas` widgets at render time.

  ## How Mob draws an overlay

  Mob has no z-index, absolute positioning, or modal slot. The single stacking
  primitive is `:box`, which is a SwiftUI `ZStack` / Compose `Box`: its children
  draw on top of each other, last child on top. A drawer is therefore a `Box`
  that holds `[scrim, panel]` and is itself stacked over the screen's own
  content. The backdrop is just a `Box` with a semi-transparent ARGB fill
  (`0xAARRGGBB`, alpha first).

  ## The gestures

  `on_drag` is a first-class Mob handler and **only a `:canvas` carries it**, so
  the drag handle is a canvas that draws its own pill. Drag it toward the
  drawer's edge to dismiss, or along the axis to move between `snap_points`.
  While the drawer is closed, `swipe_area` puts the same kind of canvas on the
  screen edge, so a drag inwards opens it.

  A composite is stateless, so the **screen** folds the drag: pass `on_swipe`
  and hand every payload to `swipe/3`.

      <MishkaDrawer id="sheet" open={@open?} side={:bottom} handle={true}
                    snap_points={[180, 300, 440]} snap={@snap}
                    on_swipe={:sheet} on_close={:close} title="Filters" />

      def handle_info({:drag, :sheet, payload}, socket) do
        {sheet, grab} =
          MishkaDrawer.swipe(payload, socket.assigns.grab,
            open: socket.assigns.open?,
            side: :bottom,
            snap_points: [180, 300, 440],
            snap: socket.assigns.snap
          )

        {:noreply,
         socket
         |> Mob.Socket.assign(:open?, sheet.open?)
         |> Mob.Socket.assign(:snap, sheet.snap)
         |> Mob.Socket.assign(:grab, grab)}
      end

  ### The panel does not follow the finger

  The web sheet tracks the drag and settles on release. Here it settles on
  release only, and that is deliberate rather than lazy: a canvas reports
  **canvas-local** coordinates, so re-rendering the panel at a new height on
  every sample would move the handle canvas under the finger — a ruler sliding
  along with what it is measuring, which converges the whole gesture into a
  fraction of its travel. Nothing moves mid-gesture, so `swipe/3` anchors on the
  `began` phase and the arithmetic is exact. Mob has no animation either, so
  there is nothing to interpolate even if it did track.

  ## Usage

  Registered once at boot (see `MishkaMob.App.on_start/0`):

      Mob.Composite.register(:mishka_drawer, {#{inspect(__MODULE__)}, :expand})

  In a screen, make the root a `:box` that stacks your content and the drawer,
  and drive `open` from an assign:

      def render(assigns) do
        %{type: :box, props: %{fill_width: true, fill_height: true}, children: [
          my_content(assigns),
          %{type: :mishka_drawer,
            props: %{id: "menu", open: assigns.drawer_open?, side: :right,
                     title: "Menu", on_close: :close_drawer},
            children: [ menu_item("Profile", :profile), ... ]}
        ]}
      end

      def handle_info({:tap, :open_menu},    s), do: {:noreply, Mob.Socket.assign(s, :drawer_open?, true)}
      def handle_info({:tap, :close_drawer}, s), do: {:noreply, Mob.Socket.assign(s, :drawer_open?, false)}
      # REQUIRED catch-all — see "Host requirement" below.
      def handle_info(_msg, s), do: {:noreply, s}

  `on_close` fires when the backdrop **or** the ✕ button is tapped; the
  composite auto-wires the tuple, so you pass a bare atom.

  ## Slots

  Two of the web component's slots are ported as tags, so markup reads the way
  the Phoenix component does instead of being assembled in an expression child:

      <MishkaDrawer id="menu" open={@open?} side={:left} title="Account"
                    on_close={:close_menu}>
        <MishkaDrawerTrigger label="Account" on_open={:open_menu} id="menu-open" />
        {menu_rows(assigns)}
        <MishkaDrawerFooter>
          <Button text="Sign out" on_tap={{self(), :sign_out}} />
        </MishkaDrawerFooter>
      </MishkaDrawer>

  | Slot | Phoenix | Takes | The function that builds the same node |
  |------|---------|-------|----------------------------------------|
  | `<MishkaDrawerTrigger>` | `<:trigger>` | `label` (or children), `on_open`, `id`, `weight`, `fill_width` | `trigger/2` |
  | `<MishkaDrawerFooter>` | `<:footer>` | children, or a bare string | `footer/1` |
  | bare children | `<:inner_block>` | — | — the drawer body, as before |

  A slot tag has no module and no expander, so it arrives with its subtree
  intact and `expand/3` consumes it. Anything it did not claim would reach the
  renderer as an unknown node and draw nothing at all — silently, because the
  tag name is whitelisted.

  ### The trigger slot is what a CLOSED drawer draws

  A closed drawer renders nothing, so the trigger has somewhere to be: it takes
  the drawer's own place in the layout, and when the drawer opens the overlay
  takes that place instead. That makes `<MishkaDrawer>` a self-contained
  control you drop in flow — but it also means the node has to sit somewhere
  that can hand the overlay the whole screen (the screen's root `Box`, or a
  root `Column` that is not scrolling), because the overlay is a fill node and
  a fill node inside a scroll has no bounded height to fill.

  When the button must sit deep in a scrolling page and the panel still has to
  cover it — the usual case, and what this library's own gallery does — keep
  the two apart: `trigger/2` builds **exactly** the node the tag builds, you
  place it where it belongs, and `id` ties the two together. That is also what
  lets one drawer be opened from three places, which no slot can express.

  `swipe_area` does not combine with a trigger slot: the patch wants the screen
  edge and the trigger wants the flow, so a closed drawer given both draws the
  trigger.

  ## Host requirement — a catch-all `handle_info/2`

  The panel routes stray taps (on its empty areas) to an ignored tag so they
  don't leak through to the backdrop and dismiss the drawer. That message
  reaches the host screen's `handle_info/2`, so **the screen must have a
  catch-all clause** `def handle_info(_msg, s), do: {:noreply, s}` — without it
  an unmatched message raises `FunctionClauseError` and crashes the screen.
  Every screen generated by `mix mob.new` already has this clause; if you
  hand-write a screen, add it.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `open` | boolean | `false` | Whether the drawer is shown. Lives in the screen (composites are stateless). |
  | `id` | string | `nil` | Test tag. Every part gets one — see "Test tags" below. |
  | `side` | `:left` `:right` `:top` `:bottom` | `:right` | Edge the panel is pinned to. |
  | `size` | `:xs` `:sm` `:md` `:lg` `:xl` | `:lg` | Panel **width** for `:left`/`:right` (240–384 pt/dp). Ignored for `:top`/`:bottom`. |
  | `title` | string | `nil` | Header title (only when `header` is on). |
  | `description` | string | `nil` | A muted line under the title. |
  | `header` | boolean | `true` | Render the built-in title + description + ✕. Set `false` to supply your own chrome. |
  | `handle` | boolean | `false` | Render the drag-handle pill. It is the swipe surface — without it there is nothing to drag. |
  | `handle_color` | ARGB int | grey | The pill. An **int**, not a token: canvas ops take ints. |
  | `scrim` | boolean | `true` | Dim the background. `false` = a non-blocking panel with no backdrop (the web's `modal={false}`). |
  | `scrim_color` | color token / ARGB int | `0x99000000` | Backdrop fill (60% black by default). |
  | `dismissible` | boolean | `true` | Whether a backdrop tap dismisses. `false` keeps the backdrop blocking but inert; the ✕ still closes. |
  | `background` | color token / ARGB int | `:surface` | Panel background. |
  | `padding` | spacing token / number | `:space_lg` | Padding inside the panel around your content. |
  | `corner_radius` | radius token / number | none | Rounds the panel corners (e.g. `:radius_lg` for a rounded bottom sheet). |
  | `snap_points` | list | `[]` | Sheet heights in dp, or fractions of `extent`. Vertical sides only. |
  | `snap` | number | first point | The active snap point — the panel's height. |
  | `extent` | number | `nil` | What a fractional snap point is a fraction OF. |
  | `snap_sequential` | boolean | `false` | One snap point per flick, and no dismissal until the smallest. |
  | `threshold` | number | `64` | How far a swipe must travel (dp) to dismiss or open. |
  | `swipe_direction` | `:up` `:down` `:left` `:right` | from `side` | Which way a dismissing swipe goes. |
  | `swipe_area` | boolean | `false` | While CLOSED, put a drag patch on the screen edge that opens the drawer. |
  | `on_close` | event tag (atom) | — | `{:tap, tag}` on backdrop / ✕ tap. Without it the ✕ is omitted and only `open` can close the drawer (a warning is logged). |
  | `on_swipe` | event tag (atom) | — | `{:drag, tag, payload}` from the handle or the swipe area. Fold it with `swipe/3`. |

  Children of the tag that are not slots become the drawer body (below the
  header). Build any interactive children with an explicit `{self(), tag}` on
  their `on_tap` — only the tag's *own* `on_*` props are auto-wired, not its
  children's, and a slot tag's are not auto-wired either (see `trigger/2`).

  ## Test tags

  With `id="sheet"` the parts are addressable as `sheet` (the whole overlay,
  present only while open), `sheet-scrim`, `sheet-panel`, `sheet-title`,
  `sheet-description`, `sheet-close`, `sheet-footer`, `sheet-handle`,
  `sheet-swipe-area`, and `sheet-snap-<n>` — the 1-based index of the active
  snap point, on the handle's row. That last one exists because the active snap
  is otherwise only a panel height, and a device test that measures a height in
  px cannot say which snap point produced it.

  ## Custom design without a new composite

  Most bespoke designs need no fork: the body is entirely yours, and the chrome
  is prop-driven. For a fully custom look, suppress the built-in header and
  style the panel via props:

      %{type: :mishka_drawer,
        props: %{open: @open, side: :bottom, header: false,
                 background: :surface_raised, corner_radius: :radius_lg,
                 scrim_color: 0x66000000, padding: :space_xl,
                 on_close: :close_sheet},
        children: [ my_custom_header(assigns), my_rows(assigns) ]}

  Only reach for your own composite when you need to change the overlay /
  positioning / dismiss *mechanics* — the visual layer is all props + children.

  ## Platform status

  **Verified on Android (Samsung A55, One UI / Android 15)** — all four sides
  anchor correctly, side panels fill height, top/bottom sheets are
  content-height, backdrop taps dismiss (hit-test fall-through works on Compose)
  and panel taps are absorbed. Also source-verified against the iOS renderer
  (`MobRootView.swift`).

  The edge-push filler is a `Spacer` carrying `weight: 1`: iOS `Spacer()` fills
  on its own (weight ignored), while Android's `Spacer` is a fixed-size box that
  needs `weight` to flex — without it, right/bottom drawers render at the wrong
  edge on Android. See `flex_spacer/0`.

  Note the overlay sits inside the top safe-area inset (the framework doesn't
  opt nodes out of it), so the panel starts just below the status bar rather
  than under it — standard mobile drawer behaviour.

  ## Not ported

  `close_on_escape` has no equivalent: a phone's Escape is the system back
  gesture, and `Mob.Screen` intercepts `{:mob, :back}` before any screen's
  `handle_info/2` to pop the navigation stack, so a drawer cannot claim it.
  Back closes the whole screen, drawer and all.

  Also absent: focus trapping and `modal="trap-focus"` (there is no focus ring
  to trap), the iOS-style page indent behind an open drawer (it would mean
  wrapping the host's whole content tree), `aria-*` wiring, and `*_class`.
  """

  require Logger

  alias MishkaMob.Components.Event

  # The slot tags. They have no expander of their own — a slot tag is a marker
  # that arrives with its subtree intact and is consumed by the parent's
  # expand/3, exactly as MishkaMenu consumes its six row kinds.
  @trigger :mishka_drawer_trigger
  @footer :mishka_drawer_footer

  @slot_types [@trigger, @footer]

  # Panel width per size token, for left/right drawers (matches Mishka's
  # w-60..w-96 scale). Top/bottom drawers are content-height instead.
  @sizes %{xs: 240, sm: 256, md: 288, lg: 320, xl: 384}

  # ~60% black backdrop — the native equivalent of Mishka's `bg-black/60`.
  @scrim 0x99_00_00_00

  # A benign event the panel uses to swallow taps: a filled Box with no
  # on_tap gets no hit-test shape natively, so taps in the panel's empty
  # areas would fall through to the scrim and close the drawer. Routing them
  # to a tag the screen ignores (its catch-all `handle_info/2`) absorbs them.
  @absorb_tag :__mishka_drawer_ignore

  # The handle's canvas. Fixed dp on BOTH axes, because a canvas must declare
  # its size: the bridge converts a touch from px into logical units by
  # `declared / measured`, and a canvas with no declared height reports raw
  # pixels — which would make the dp `threshold` meaningless. 160 also fits
  # inside the narrowest panel (`:xs` is 240dp, less 24dp of padding a side),
  # and a canvas declared wider than the space it gets SCALES its ops.
  @handle_w 160
  @handle_h 40

  # The edge swipe-area, drawn while the drawer is closed. Same reasoning, and
  # the same reason it is a patch rather than the full edge the web uses: the
  # screen's size is not knowable from Elixir, so the only honest cross-axis
  # length is a constant that fits every phone.
  @area_thickness 16
  @area_length 320

  # Canvas ops take ARGB ints — the renderer resolves colour TOKENS for node
  # props only, never for the contents of `draw`. So the pill cannot be `:muted`
  # the way a boxed divider would be, and its default has to be a literal;
  # `handle_color` exists so a caller is not stuck with this grey.
  @pill_ink 0xFF_9C_A3_AF
  @area_ink 0x33_9C_A3_AF

  # How far a swipe must travel, in dp, before it dismisses (or opens).
  @threshold 64

  @doc """
  Composite expander. `props` arrive with `on_*` targets already resolved to
  `{screen_pid, tag}` tuples; `ctx` is `%{screen: pid}` (only `:screen` — the
  framework moduledoc's `:platform` key does not exist in the code, so don't
  read it). Returns a Mob node map — the overlay tree when open, the trigger
  slot or the edge swipe-area when closed, and an empty column otherwise.

  `children` are read once and split three ways: the `<MishkaDrawerTrigger>`
  slot, the `<MishkaDrawerFooter>` slot, and everything else, which is the body.
  """
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  def expand(props, children, ctx) do
    {triggers, footer, body} = slots(children)

    cond do
      truthy?(Map.get(props, :open, false)) ->
        warn(props)
        overlay(props, body, footer, ctx)

      # A closed drawer draws nothing, which is precisely the room the trigger
      # slot needs: it takes the drawer's own place until the overlay wants it.
      triggers != [] ->
        opener(triggers, ctx)

      truthy?(Map.get(props, :swipe_area, false)) ->
        edge_area(props, ctx)

      true ->
        empty()
    end
  end

  @doc """
  The thing that opens the drawer — the port of the web's `<:trigger>` slot, as
  a builder rather than only a tag.

  Given a string it is a button; given a list of nodes it is a tappable Box
  wrapped round them, for a trigger that is a row or a card rather than a label.

      trigger("Open menu", on_open: :open_drawer, test_id: "menu-trigger")
      trigger([avatar(), name()], on_open: :open_drawer)

  Options: `on_open` (the event tag), `test_id` (its native test tag), `weight`
  (for a trigger sharing a Row), and `fill_width` (defaults to true).

  `<MishkaDrawerTrigger>` is built **through this function**, so the two forms
  cannot drift: the tag's `label` is this first argument, and its `id`,
  `on_open`, `weight` and `fill_width` are these options. Reach for the builder
  when the trigger cannot live inside the drawer tag — because it belongs in a
  scrolling page while the panel has to cover one, or because the same drawer is
  opened from more than one place, which no slot can express.
  """
  @spec trigger(String.t() | [map()], keyword()) :: map()
  def trigger(label, opts \\ [])

  def trigger(label, opts) when is_binary(label) do
    props =
      %{
        text: label,
        background: :primary,
        text_color: :on_primary,
        text_size: :base,
        padding: :space_sm,
        fill_width: Keyword.get(opts, :fill_width, true)
      }
      |> maybe_put(:weight, Keyword.get(opts, :weight))
      |> maybe_put(:on_tap, Event.handler(Keyword.get(opts, :on_open)))
      |> maybe_put(:id, Keyword.get(opts, :test_id))

    %{type: :button, props: props, children: []}
  end

  def trigger(children, opts) when is_list(children) do
    props =
      %{fill_width: Keyword.get(opts, :fill_width, true)}
      |> maybe_put(:weight, Keyword.get(opts, :weight))
      |> maybe_put(:on_tap, Event.handler(Keyword.get(opts, :on_open)))
      |> maybe_put(:id, Keyword.get(opts, :test_id))

    %{type: :box, props: props, children: children}
  end

  @doc """
  The panel's footer — the block that sits below the body, and on a panel with a
  determined height, at its floor.

  This returns the same marker node `<MishkaDrawerFooter>` produces, the way
  `MishkaMob.Components.MishkaMenu.item/3` returns a `<MishkaMenuItem>`: pass it
  among the drawer's children and `expand/3` consumes it. A string is styled
  here rather than by the caller, so a one-line footer needs no `<Text>`.

      footer([cancel_button(), confirm_button()])
      footer("Signed in as shahryar@mishka.tools")

  Before this existed a footer was merely the last body child, which meant it
  could not be tagged, could not be pushed to the panel's floor, and read as one
  more row.
  """
  @spec footer(String.t() | map() | [map()]) :: map()
  def footer(content) when is_binary(content),
    do: %{type: @footer, props: %{text: content}, children: []}

  def footer(content) when is_list(content), do: %{type: @footer, props: %{}, children: content}
  def footer(content) when is_map(content), do: %{type: @footer, props: %{}, children: [content]}

  @doc """
  Every node type the drawer consumes as a slot. Exported so a test can prove
  none of them leaked past `expand/3` to the renderer — a leak is silent, since
  the tag names are whitelisted and an unknown node simply draws nothing.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  @doc """
  Fold one drag payload into the drawer's next state.

  Returns `{%{open?: boolean, snap: number | nil}, grab}`. Keep `grab` in an
  assign and hand it back on the next payload; it is `nil` between gestures.
  Pass the drawer's own props (`open`, `side`, `snap_points`, `snap`, `extent`,
  `threshold`, `snap_sequential`, `swipe_direction`) so the fold knows which way
  "away" is.

  Nothing changes until the finger lifts — see "The panel does not follow the
  finger" above. A drag shorter than `threshold` therefore leaves the drawer
  exactly as it was:

      iex> alias MishkaMob.Components.MishkaDrawer
      iex> {_, grab} = MishkaDrawer.swipe(%{phase: :began, y: 10.0}, nil, open: true, side: :bottom)
      iex> {state, after_gesture} = MishkaDrawer.swipe(%{phase: :ended, y: 40.0}, grab, open: true, side: :bottom)
      iex> {state.open?, after_gesture}
      {true, nil}

  Drag it far enough toward the drawer's own edge and it dismisses:

      iex> alias MishkaMob.Components.MishkaDrawer
      iex> {_, grab} = MishkaDrawer.swipe(%{phase: :began, y: 10.0}, nil, open: true, side: :bottom)
      iex> {state, _} = MishkaDrawer.swipe(%{phase: :ended, y: 120.0}, grab, open: true, side: :bottom)
      iex> state.open?
      false

  With snap points the gesture moves between them instead, and only dismisses
  from below the smallest:

      iex> alias MishkaMob.Components.MishkaDrawer
      iex> sheet = [open: true, side: :bottom, snap_points: [180, 300, 440], snap: 440]
      iex> {_, grab} = MishkaDrawer.swipe(%{phase: :began, y: 0.0}, nil, sheet)
      iex> {state, _} = MishkaDrawer.swipe(%{phase: :ended, y: 150.0}, grab, sheet)
      iex> {state.open?, state.snap}
      {true, 300}

  While the drawer is CLOSED the same fold reads the edge swipe-area, where a
  drag *inwards* opens it:

      iex> alias MishkaMob.Components.MishkaDrawer
      iex> edge = [open: false, side: :left]
      iex> {_, grab} = MishkaDrawer.swipe(%{phase: :began, x: 4.0}, nil, edge)
      iex> {state, _} = MishkaDrawer.swipe(%{phase: :ended, x: 90.0}, grab, edge)
      iex> state.open?
      true
  """
  @spec swipe(map(), map() | nil, map() | keyword()) ::
          {%{open?: boolean(), snap: number() | nil}, map() | nil}
  def swipe(payload, grab, props \\ %{}) do
    props = Map.new(props)
    at = coordinate(payload, axis(props))

    case phase(payload) do
      :began -> {state(props), %{at: at, snap: active_snap(props)}}
      :dragging -> {state(props), grab}
      :ended -> {settle(at, grab, props), nil}
    end
  end

  @doc """
  The snap points as dp heights, smallest first.

  A number above 1 is already dp; a fraction is resolved against `extent`, which
  is the port of the web's "fraction of the viewport" — a composite cannot
  measure the viewport, so the caller states what the fraction is of.

      iex> MishkaMob.Components.MishkaDrawer.snap_heights(%{snap_points: [440, 180]})
      [180, 440]

      iex> MishkaMob.Components.MishkaDrawer.snap_heights(%{snap_points: [0.4, 0.76], extent: 500})
      [200.0, 380.0]

  A fraction with no `extent` cannot be resolved, so it is dropped (and
  `expand/3` logs it) rather than silently rendering a 0.4dp sheet:

      iex> MishkaMob.Components.MishkaDrawer.snap_heights(%{snap_points: [0.4, 300]})
      [300]
  """
  @spec snap_heights(map() | keyword()) :: [number()]
  def snap_heights(props) do
    props = Map.new(props)
    extent = Map.get(props, :extent)

    props
    |> Map.get(:snap_points, [])
    |> List.wrap()
    |> Enum.map(&resolve_point(&1, extent))
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
  end

  @doc """
  The 1-based index of the active snap point, or `nil` when there are none.

  This is what the `<id>-snap-<n>` test tag carries. The active snap is
  otherwise only a panel height, and a device test measuring a height in pixels
  cannot say which snap point produced it.

      iex> MishkaMob.Components.MishkaDrawer.snap_index(%{snap_points: [180, 300], snap: 300})
      2

      iex> MishkaMob.Components.MishkaDrawer.snap_index(%{snap_points: [180, 300]})
      1
  """
  @spec snap_index(map() | keyword()) :: pos_integer() | nil
  def snap_index(props) do
    props = Map.new(props)
    points = snap_heights(props)

    case active_snap(props) do
      nil -> nil
      snap -> points |> Enum.find_index(&(&1 == snap)) |> then(&(&1 && &1 + 1))
    end
  end

  # ── The slots ──
  #
  # One pass over the children, the way MishkaMenu reads its rows: split the
  # markers out, group them by kind, and hand the rest on as the body. A marker
  # left in the body would travel all the way to the renderer, which has no
  # widget for it and draws nothing — and says nothing either, because the tag
  # name is whitelisted.
  defp slots(children) do
    {markers, body} = Enum.split_with(List.wrap(children), &slot?/1)
    grouped = Enum.group_by(markers, & &1.type)

    {Map.get(grouped, @trigger, []), Map.get(grouped, @footer, []), body}
  end

  defp slot?(node), do: is_map(node) and Map.get(node, :type) in @slot_types

  # ── The trigger slot ──
  #
  # Built THROUGH trigger/2, so the tag and the builder cannot drift: whatever
  # the markup renders is the node the function returns, and a test can assert
  # that with `==`.
  #
  # Two triggers share a Column rather than the first one winning: dropping a
  # node the caller wrote is the silent failure this whole slot exists to avoid.
  defp opener(triggers, ctx) do
    case Enum.map(triggers, &built_trigger(&1, ctx)) do
      [one] -> one
      many -> %{type: :column, props: %{fill_width: true}, children: many}
    end
  end

  defp built_trigger(node, ctx) do
    props = Map.get(node, :props, %{})

    opts =
      []
      # A slot tag's `on_*` props are NOT auto-wired the way the composite's own
      # are — Mob.Composite widens the tag it dispatches on, and a marker has no
      # expander to dispatch to. So the parent wires it, from ctx.
      |> maybe_opt(:on_open, handler(props, :on_open, ctx))
      |> maybe_opt(:test_id, Map.get(props, :test_id) || Map.get(props, :id))
      |> maybe_opt(:weight, Map.get(props, :weight))
      |> maybe_opt(:fill_width, Map.get(props, :fill_width))

    case Map.get(node, :children, []) do
      # `text` as well as `label`, because `<Button text={…} />` is the muscle
      # memory and a trigger that silently renders blank is worse than an alias.
      [] -> trigger(Map.get(props, :label) || Map.get(props, :text) || "", opts)
      children -> trigger(children, opts)
    end
  end

  # ── The footer slot ──
  #
  # A tagged block below the body. On a panel whose height is determined — every
  # side drawer, and a sheet parked on a snap point — a weighted Spacer pushes it
  # to the floor, which is where a "Sign out" row belongs. A content-height sheet
  # has no floor to push against, so the footer simply follows the body: an
  # iOS `Spacer()` fills whatever room it is in, and in a hugging sheet that room
  # is the sheet, so pushing unconditionally would stretch it open.
  defp footer_block(_props, []), do: []

  defp footer_block(props, markers) do
    case Enum.flat_map(markers, &footer_content/1) do
      [] ->
        []

      content ->
        block =
          %{type: :column, props: %{fill_width: true}, children: content}
          |> put(:id, part(props, "footer"))

        push = if floored?(props), do: [flex_spacer()], else: []

        push ++ [gap(16), block]
    end
  end

  # A string footer keeps its text in the marker's props so the styling stays
  # this module's decision, exactly as MishkaDialog's slots do.
  defp footer_content(%{props: props, children: children}) do
    case Map.get(props, :text) do
      text when is_binary(text) ->
        [%{type: :text, props: %{text: text, text_size: :sm, text_color: :muted}, children: []}]

      _ ->
        children
    end
  end

  defp footer_content(_node), do: []

  defp floored?(props), do: side(props) in [:left, :right] or sheet_height(props) != nil

  # ── Overlay: scrim (bottom) + edge-anchored panel (top) inside a fill Box ──
  defp overlay(props, children, footer, ctx) do
    positioner = positioner(side(props), panel(props, children, footer, ctx))
    root = %{fill_width: true, fill_height: true} |> maybe_put(:id, part(props, nil))

    %{
      type: :box,
      props: root,
      children: Enum.reject([scrim(props, ctx), positioner], &is_nil/1)
    }
  end

  # The backdrop. `dismissible: false` keeps it — the web's `dismissible` only
  # governs the outside click — but an inert backdrop still has to ABSORB the
  # tap, or a "modal" drawer would let taps through to the page behind it.
  defp scrim(props, ctx) do
    if truthy?(Map.get(props, :scrim, true)) do
      target =
        if truthy?(Map.get(props, :dismissible, true)) do
          handler(props, :on_close, ctx)
        else
          {ctx.screen, @absorb_tag}
        end

      node = %{
        type: :box,
        props:
          %{fill_width: true, fill_height: true, background: Map.get(props, :scrim_color, @scrim)}
          |> maybe_put(:id, part(props, "scrim")),
        children: []
      }

      put(node, :on_tap, target)
    end
  end

  # Push the panel to its edge with a flex Spacer. Left/right split a Row;
  # top/bottom split a fill-height Column. The positioner sits on top of the
  # scrim; its Spacer half has no fill/handler, so taps there fall through to
  # the scrim (dismiss). The panel half absorbs its own taps.
  defp positioner(:left, panel), do: row([panel, flex_spacer()])
  defp positioner(:right, panel), do: row([flex_spacer(), panel])
  defp positioner(:top, panel), do: fill_column([panel, flex_spacer()])
  defp positioner(:bottom, panel), do: fill_column([flex_spacer(), panel])

  # ── The panel: an outer node carrying the skin (background / corner_radius /
  # tap-absorb / snap height) and an inner Column carrying the padding, so the
  # outer size is exactly what was asked for — a fixed-width Box applies padding
  # OUTSIDE its width frame, and a snap point that meant "height plus whatever
  # padding happens to be" would be untestable.
  #
  # Left/right are width-locked and full-height (the inner column's fill_height
  # is what stretches the width-locked box); top/bottom fill width and hug their
  # content unless a snap point sets the height.
  #
  # `children` are the tag's RAW children (Mob.Composite passes them un-expanded
  # and re-expands this output to a fixpoint, so nested composites still
  # resolve) — splicing them in directly is correct.
  defp panel(props, children, footer, ctx) do
    body = body(props, children, footer, ctx)
    padding = Map.get(props, :padding, :space_lg)

    skin =
      %{background: Map.get(props, :background, :surface), on_tap: {ctx.screen, @absorb_tag}}
      |> maybe_put(:corner_radius, Map.get(props, :corner_radius))
      |> maybe_put(:id, part(props, "panel"))

    if side(props) in [:left, :right] do
      inner = %{
        type: :column,
        props: %{fill_width: true, fill_height: true, padding: padding},
        children: body
      }

      %{type: :box, props: Map.put(skin, :width, size_px(props)), children: [inner]}
    else
      # A Column fills width on BOTH platforms (a Box wraps its content on
      # Compose, collapsing the sheet). corner_radius clips on Android's Column;
      # iOS VStack doesn't round — acceptable.
      height = sheet_height(props)
      inner = %{fill_width: true, padding: padding}
      inner = if height, do: Map.put(inner, :fill_height, true), else: inner

      outer = skin |> Map.put(:fill_width, true) |> maybe_put(:height, height)

      %{
        type: :column,
        props: outer,
        children: [%{type: :column, props: inner, children: body}]
      }
    end
  end

  # Handle, header, the caller's children, footer. The handle sits at the
  # panel's free edge — the top for a bottom sheet or a side drawer, the bottom
  # for a top sheet — which is the edge a thumb reaches for.
  defp body(props, children, footer, ctx) do
    content = header(props, ctx) ++ children ++ footer_block(props, footer)

    case {handle(props, ctx), side(props)} do
      {nil, _side} -> content
      {strip, :top} -> content ++ [gap(8), strip]
      {strip, _side} -> [strip, gap(8) | content]
    end
  end

  # Header row: title + description on the leading side, a ✕ on the trailing
  # side ONLY when on_close is set (a ✕ with no handler would be a dead
  # control). Returns [] when there is nothing to show.
  defp header(props, ctx) do
    if truthy?(Map.get(props, :header, true)) do
      lead = titles(props)

      trail =
        if close = handler(props, :on_close, ctx), do: [close_button(props, close)], else: []

      case {lead, trail} do
        {[], []} -> []
        {[], trail} -> [row([flex_spacer() | trail]), gap(16)]
        {lead, trail} -> [row([weighted(lead) | trail]), gap(16)]
      end
    else
      []
    end
  end

  defp titles(props) do
    title = Map.get(props, :title)
    description = Map.get(props, :description)

    text = fn value, extra ->
      if is_binary(value) and value != "" do
        [%{type: :text, props: Map.put(extra, :text, value), children: []}]
      else
        []
      end
    end

    # max_lines: 1 on the title because it shares the row with the ✕ and a Text
    # squeezed narrower than its content wraps character by character.
    head =
      text.(title, %{
        text_size: :xl,
        text_color: :on_surface,
        max_lines: 1
      })
      |> tag(part(props, "title"))

    body =
      text.(description, %{text_size: :sm, text_color: :muted})
      |> tag(part(props, "description"))

    case {head, body} do
      {[], []} -> []
      {head, []} -> head
      {[], body} -> body
      {head, body} -> head ++ [gap(4)] ++ body
    end
  end

  defp close_button(props, close) do
    %{
      type: :button,
      props:
        %{
          text: "✕",
          background: :transparent,
          text_color: :on_surface,
          text_size: :xl,
          padding: :space_xs,
          fill_width: false,
          on_tap: close
        }
        |> maybe_put(:id, part(props, "close")),
      children: []
    }
  end

  # ── The drag handle ──
  #
  # A canvas, because a canvas is the only node that carries `on_drag`, and it
  # draws its own pill because a canvas has no children. It is centred by two
  # weighted Spacers rather than by `align`, which is the filler idiom already
  # verified on both platforms.
  #
  # The row around it carries the snap tag: the pill is what a device test grabs
  # and its tag must stay stable, so the changing state rides one node out.
  defp handle(props, ctx) do
    if truthy?(Map.get(props, :handle, false)) do
      ink = Map.get(props, :handle_color, @pill_ink)

      canvas =
        %{
          type: :canvas,
          props: %{
            width: @handle_w,
            height: @handle_h,
            draw: pill(@handle_w, @handle_h, axis(props), ink)
          },
          children: []
        }
        |> put(:on_drag, handler(props, :on_swipe, ctx))
        |> put(:id, part(props, "handle"))

      strip = %{
        type: :row,
        props: %{fill_width: true},
        children: [flex_spacer(), canvas, flex_spacer()]
      }

      put(strip, :id, snap_tag(props))
    end
  end

  # ── The edge swipe-area, drawn INSTEAD of the drawer while it is closed ──
  #
  # A patch pinned to the drawer's own edge and centred along it; dragging
  # inwards opens the drawer. It is the one part of a closed drawer that
  # renders, and it intercepts touches inside its own bounds — which is what it
  # is for, and why it is opt-in.
  defp edge_area(props, ctx) do
    side = side(props)

    {w, h} =
      if side in [:left, :right],
        do: {@area_thickness, @area_length},
        else: {@area_length, @area_thickness}

    canvas =
      %{
        type: :canvas,
        props: %{width: w, height: h, draw: pill(w, h, axis(props), @area_ink)},
        children: []
      }
      |> put(:on_drag, handler(props, :on_swipe, ctx))
      |> put(:id, part(props, "swipe-area"))

    %{
      type: :box,
      props: %{fill_width: true, fill_height: true},
      children: [pinned(side, canvas)]
    }
  end

  # Pin to an edge and centre along it. The unweighted node is measured first on
  # Compose, so the canvas keeps its declared size and the Spacers share what is
  # left.
  defp pinned(:left, canvas), do: row([centred_column(canvas), flex_spacer()])
  defp pinned(:right, canvas), do: row([flex_spacer(), centred_column(canvas)])
  defp pinned(:top, canvas), do: fill_column([centred_row(canvas), flex_spacer()])
  defp pinned(:bottom, canvas), do: fill_column([flex_spacer(), centred_row(canvas)])

  defp centred_column(child) do
    %{
      type: :column,
      props: %{fill_height: true},
      children: [flex_spacer(), child, flex_spacer()]
    }
  end

  defp centred_row(child),
    do: %{type: :row, props: %{fill_width: true}, children: [flex_spacer(), child, flex_spacer()]}

  # The pill, drawn across the drag axis: a wide bar is dragged up and down, a
  # tall one left and right, and saying so is the only affordance a drawn
  # control has. `fill: true` on every rect — Mob.Canvas.rect STROKES by
  # default, so without it the pill draws as a hollow outline.
  defp pill(width, height, :y, ink) do
    w = min(44, width / 2)
    h = 5

    [
      Mob.Canvas.rect((width - w) / 2, (height - h) / 2, w, h,
        color: ink,
        radius: 2.5,
        fill: true
      )
    ]
  end

  defp pill(width, height, :x, ink) do
    w = 5
    h = min(44, height / 2)

    [
      Mob.Canvas.rect((width - w) / 2, (height - h) / 2, w, h,
        color: ink,
        radius: 2.5,
        fill: true
      )
    ]
  end

  # ── The swipe fold ──

  defp state(props), do: %{open?: open?(props), snap: active_snap(props)}

  defp settle(_at, nil, props), do: state(props)

  defp settle(at, %{at: from, snap: snap}, props) do
    # Positive progress is travel TOWARD the dismissing edge, whichever edge
    # that is — so one arithmetic serves all four sides.
    progress = (at - from) * dismiss_sign(props)
    points = snap_heights(props)
    threshold = Map.get(props, :threshold, @threshold)
    snap = snap || List.first(points)

    cond do
      # Closed: this payload came from the edge swipe-area, where the gesture
      # runs the other way — inwards opens.
      not open?(props) -> %{open?: -progress >= threshold, snap: snap}
      points == [] -> %{open?: progress < threshold, snap: snap}
      dismiss?(snap - progress, snap, points, threshold, props) -> %{open?: false, snap: snap}
      true -> %{open?: true, snap: next_snap(snap - progress, snap, points, props)}
    end
  end

  # A sheet is dismissed by dragging it below its smallest snap point — and with
  # `snap_sequential`, only once it is already there. That is what "one snap
  # point per flick" has to mean at the bottom of the list, or a long flick from
  # the top would skip every point on its way out.
  defp dismiss?(target, snap, points, threshold, props) do
    smallest = List.first(points)

    target < smallest - threshold and
      (not truthy?(Map.get(props, :snap_sequential, false)) or snap == smallest)
  end

  defp next_snap(target, from, points, props) do
    nearest = Enum.min_by(points, &abs(&1 - target))

    if truthy?(Map.get(props, :snap_sequential, false)) do
      at = Enum.find_index(points, &(&1 == from)) || 0
      to = Enum.find_index(points, &(&1 == nearest))
      Enum.at(points, to |> max(at - 1) |> min(at + 1))
    else
      nearest
    end
  end

  # The NIF sends `phase` as an ATOM (:began / :dragging / :ended). Comparing it
  # against "began" matches nothing and falls through to the :dragging default,
  # so the anchor is never set and every gesture returns the state unchanged —
  # the drawer looks completely dead while the arithmetic is fine. Strings are
  # accepted too, because a payload that has crossed a wire may be either.
  defp phase(payload) do
    case payload[:phase] || payload["phase"] do
      p when p in [:began, "began"] -> :began
      p when p in [:ended, "ended"] -> :ended
      _ -> :dragging
    end
  end

  # Read x/y only, never dx/dy: on iOS those are cumulative translation and on
  # Android per-sample deltas, so anything built on them behaves differently on
  # each platform.
  defp coordinate(payload, axis) do
    (payload[axis] || payload[to_string(axis)] || 0) * 1.0
  end

  defp axis(props) do
    case dismiss_direction(props) do
      dir when dir in [:up, :down] -> :y
      _ -> :x
    end
  end

  defp dismiss_sign(props) do
    case dismiss_direction(props) do
      dir when dir in [:down, :right] -> 1
      _ -> -1
    end
  end

  @doc """
  Which way a dismissing swipe goes — `swipe_direction`, or the drawer's own
  edge when it is not given.

      iex> MishkaMob.Components.MishkaDrawer.dismiss_direction(%{side: :bottom})
      :down

      iex> MishkaMob.Components.MishkaDrawer.dismiss_direction(%{side: :bottom, swipe_direction: :right})
      :right
  """
  @spec dismiss_direction(map() | keyword()) :: :up | :down | :left | :right
  def dismiss_direction(props) do
    props = Map.new(props)

    case Map.get(props, :swipe_direction) do
      dir when dir in [:up, :down, :left, :right] -> dir
      dir when dir in ["up", "down", "left", "right"] -> String.to_existing_atom(dir)
      _ -> edge_direction(side(props))
    end
  end

  defp edge_direction(:left), do: :left
  defp edge_direction(:right), do: :right
  defp edge_direction(:top), do: :up
  defp edge_direction(:bottom), do: :down

  defp resolve_point(point, extent) when is_number(point) and point > 0 and point <= 1,
    do: extent && point * extent

  defp resolve_point(point, _extent) when is_number(point) and point > 1, do: point
  defp resolve_point(_point, _extent), do: nil

  defp active_snap(props) do
    Map.get(props, :snap) || List.first(snap_heights(props))
  end

  # Snap points size the sheet; a left/right drawer is sized by `size` instead,
  # exactly as the web restricts them to vertical sides.
  defp sheet_height(props) do
    if side(props) in [:top, :bottom], do: active_snap(props)
  end

  defp snap_tag(props) do
    case {part(props, nil), snap_index(props)} do
      {nil, _} -> nil
      {_id, nil} -> nil
      {id, index} -> "#{id}-snap-#{index}"
    end
  end

  defp open?(props), do: truthy?(Map.get(props, :open, false))

  defp side(props) do
    case Map.get(props, :side, :right) do
      side when side in [:left, :right, :top, :bottom] -> side
      side when side in ["left", "right", "top", "bottom"] -> String.to_existing_atom(side)
      _ -> :right
    end
  end

  # ── Warnings for the two ways a drawer can be quietly unusable ──
  defp warn(props) do
    unless Map.get(props, :on_close) || Map.get(props, :on_swipe) do
      Logger.warning(
        "[MishkaDrawer] open with no `on_close` or `on_swipe` — the backdrop, the ✕ and a " <>
          "swipe cannot dismiss it; it can only be closed by flipping the `open` prop."
      )
    end

    points = Map.get(props, :snap_points, [])

    if points != [] and snap_heights(props) == [] do
      Logger.warning(
        "[MishkaDrawer] every snap point in #{inspect(points)} is a fraction and no `extent` " <>
          "was given, so none could be resolved — the sheet falls back to its content height."
      )
    end
  end

  # ── Small node helpers ──
  defp row(children), do: %{type: :row, props: %{fill_width: true}, children: children}

  defp fill_column(children),
    do: %{type: :column, props: %{fill_width: true, fill_height: true}, children: children}

  # A weighted slot for the flexible half of a Row. Compose measures a Row's
  # UNWEIGHTED children first, so an unweighted title next to the ✕ would claim
  # the whole row and starve it; and a Box with neither width nor fill_width
  # fills its parent, which is exactly what the slot wants.
  defp weighted(children),
    do: %{
      type: :box,
      props: %{weight: 1},
      children: [%{type: :column, props: %{fill_width: true}, children: children}]
    }

  # A flex filler that pushes the panel to the far edge. It must fill remaining
  # space on BOTH platforms, and the mechanism differs: iOS `Spacer()` (size-less)
  # already fills but ignores `weight`; Android's Spacer is a FIXED-size box
  # (size-less = zero) and needs `weight` to flex. Carrying both makes one filler
  # work everywhere. Without this, right/bottom drawers render at the wrong edge
  # on Android (the panel collapses to the start).
  defp flex_spacer, do: %{type: :spacer, props: %{weight: 1}, children: []}
  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
  defp empty, do: %{type: :column, props: %{}, children: []}

  defp size_px(props), do: Map.get(@sizes, Map.get(props, :size, :lg), 320)

  # The test tag for one part, or nil when the caller gave no id. `nil` as the
  # part name asks for the id itself.
  defp part(props, suffix) do
    case Map.get(props, :id) do
      nil -> nil
      id when suffix == nil -> to_string(id)
      id -> "#{id}-#{suffix}"
    end
  end

  defp handler(props, key, ctx) do
    case Map.get(props, key) do
      nil -> nil
      {pid, _tag} = wired when is_pid(pid) -> wired
      tag -> {ctx.screen, tag}
    end
  end

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  # Tag the single node in a one-element list, so `titles/1` can stay a list.
  defp tag([node], id) when not is_nil(id), do: [put(node, :id, id)]
  defp tag(nodes, _id), do: nodes

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  # The keyword-list twin of maybe_put/3: an option left out is an option
  # trigger/2 defaults, which is not the same as one passed as nil.
  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, key, value), do: Keyword.put(opts, key, value)

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
