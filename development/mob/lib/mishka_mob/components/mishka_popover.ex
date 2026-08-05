defmodule MishkaMob.Components.MishkaPopover do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Popover** — a trigger that
  toggles a panel of arbitrary content beside it.

  ## The panel floats, in a window of its own

  The web floats its panel over the page from the trigger's measured rectangle.
  Mob reports no geometry back to `render/1`, so this port used to do the only
  other thing available: make the panel the trigger's **sibling**. `:bottom` and
  `:top` stacked the two in a `Column`, `:left` and `:right` put them in a `Row`,
  `side_offset` was a `:spacer` between them and `align` was an aligned Box. That
  is layout, not floating — opening pushed every sibling below the popover down
  the page, and `side: :top` was a lie, because a panel "above" its trigger still
  ate the same vertical space. It read as an accordion.

  `MishkaMob.Components.Anchored` is what replaced it. The trigger is child `[0]`
  of an `:anchored` node and the panel is child `[1]`, in that order **for every
  side**; the anchor renders in flow, and the panel renders in its own window
  over the page. So the panel takes no room, it can genuinely sit above or left
  of its trigger, and no ancestor can clip it — which matters, because a `:box`
  with a `corner_radius` clips and a vertical `:scroll` clips its main axis, and
  the showcase is made of both.

  Positioning is the web's `positionPopup()`, transliterated:

    * `side` decides which side of the trigger the panel takes, and `side_offset`
      is the gap, in dp rather than px. It is a prop on the anchor now, not a
      spacer — a spacer cannot express a gap between things that share no layout.
    * `align` places the panel across that side, against the trigger's own box,
      and `align_offset` nudges it along the same axis. A positive `align_offset`
      pushes **inward** on `:end`, matching the web's sign.
    * The side **flips** to its opposite when the requested one has no room and
      the opposite one does — main axis only, exactly as the web engines do.
    * Then the panel is clamped into the window, keeping 8dp of edge padding plus
      the safe-area inset clear, so it can neither run off-screen nor land under
      the status bar.

  `align` still defaults to `:start` rather than the web's `center`, because the
  leading edge is where a native dropdown opens. What changed is that the value
  now *bites*: alignment used to be nearly decorative, since a panel filling its
  parent looks identical at every setting. Both halves hug now, so `:center` and
  `:end` really do move the panel against the trigger.

  ## Both halves hug their content

  The **trigger** hugs on every side. It used to fill the width when stacked,
  because it shared a Column with the panel and a narrow trigger looked stranded
  above a wide one. Under real anchoring that is harmful: a full-width trigger
  turns `align: :end` into "the screen's right edge" instead of "the trigger's",
  and the web anchors to a content-sized `<button>`.

  The **panel** hugs too. Inside a popup window `fill_width` means the whole
  SCREEN, after which the clamp pins the panel to the leading edge whatever
  `side` or `align` asked for. Popover and preview_card get that
  by putting `fill_width: false` on the way in; `panel/2` itself still FILLS by
  default, which is how `MishkaMob.Components.MishkaMenu` — passing none, and
  placing its own control — keeps the full-width shell it always had. Pass
  `fill_width: true` explicitly to get the old filling panel back.

  ## Open and closed are still the screen's

  The panel's window never dismisses itself: no back-press, no outside tap. The
  screen owns `open` exactly as it did in flow, so the tree cannot desynchronise
  from the assign that produced it, nor from the `<id>-trigger-open` /
  `<id>-panel` tag pair a device test reads.

  ## A long press is the hover

  `open_on_hover` means nothing on a phone, but its intent — a second, softer way
  to summon the panel — does. `open_on_hold` puts that open on the trigger's
  **long press**, the same touch equivalent
  `MishkaMob.Components.MishkaContextMenu` uses for the web's right-click. The
  ordinary tap still toggles, so the two do not fight. `delay` and `close_delay`
  are hover timings and the system owns how long a press lasts, so they are
  dropped rather than accepted and ignored.

  ## Every part is addressable

  `id` tags the root, and each part derives its own tag from it: `<id>-trigger-open`
  / `<id>-trigger-closed`, `<id>-panel`, `<id>-title`, `<id>-desc`, `<id>-close`,
  `<id>-arrow`. The trigger's state goes in the tag because that state is
  otherwise carried only by its fill, and a device test cannot read a colour.

  ## Slots

  Every part the web declares as a slot is a **tag** here, so the markup reads
  the way the Chelekom component does rather than as a list of props:

      <MishkaPopover id="details" open={@open?} on_open_change={:details}>
        <MishkaPopoverTrigger text="Order details" />
        <MishkaPopoverTitle text="Shipped 2 days ago" />
        <MishkaPopoverDescription text="Tracking arrives by email." />
        <MishkaPopoverArrow />
        <Text text="Two of three parcels have left the warehouse." />
        <MishkaPopoverClose text="Got it" />
      </MishkaPopover>

  | Slot | Chelekom | Function | Takes | Shorthand prop |
  |------|----------|----------|-------|----------------|
  | `<MishkaPopoverTrigger>` | `<:trigger>` | `trigger/1` | a label, or markup | `trigger` |
  | `<MishkaPopoverTitle>` | `<:title>` | `title/1` | a line, or markup | `title` |
  | `<MishkaPopoverDescription>` | `<:description>` | `description/1` | a line, or markup | `description` |
  | `<MishkaPopoverClose>` | `<:close>` | `close/1` | a label, or your own controls | `close` |
  | `<MishkaPopoverArrow>` | `<:arrow>` | `arrow/0` | nothing, a glyph, or markup | `arrow` |
  | bare children | `<:inner_block>` | — | the panel's body | — |

  Write `text="…"` and the part is styled by this module, exactly as the
  shorthand prop is; write markup inside the tag and it is yours, wrapped in a
  Column that wears the part's testTag. A slot wins over its shorthand, so
  passing both is redundant rather than an error, and **order does not matter**:
  the slots are taken out of the children by `:type` and each is placed where
  the anatomy says, not where it was written.

  Tag and function build the identical node, which is what makes the function
  the right form when the parts come from **data** — a comprehension can return
  `trigger/1` and a tag cannot be produced by one:

      popover(%{open: @open?}, [trigger(@order.name) | Enum.map(@parcels, &line/1)])

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `id` | string | `nil` | Root testTag; every part derives its own from it. |
  | `open` | boolean | `false` | Whether the panel is shown. Lives in the screen. |
  | `trigger` | string / node / nodes | `nil` | Shorthand for `<MishkaPopoverTrigger>`. Omit both and you place your own. |
  | `on_open_change` | event tag | — | Sent as `{:tap, {tag, next_open?}}`. |
  | `open_on_hold` | boolean | `false` | A long press on the trigger also opens it. |
  | `disabled` | boolean | `false` | Wires no handler, so the trigger is inert. |
  | `chevron` | boolean | `true` | Show the ▾/▴ indicator on the trigger. |
  | `side` | `:top` `:right` `:bottom` `:left` | `:bottom` | Which side of the trigger the panel takes. |
  | `align` | `:start` `:center` `:end` | `:start` | Where the panel sits across that side, against the trigger's box. |
  | `side_offset` | number | `8` | Gap between trigger and panel, in dp. |
  | `align_offset` | number | `nil` | Nudge along the alignment axis, in dp. Positive pushes *inward* on `:end`. |
  | `flip` | boolean | `true` | Turn to the opposite side when the requested one has no room and that one does. |
  | `clamp` | boolean | `true` | Keep the panel inside the window. |
  | `edge_padding` | number | `8` | Kept clear of the window edges, on top of the safe-area inset. |
  | `title` | string | `nil` | Shorthand for `<MishkaPopoverTitle>`. |
  | `description` | string | `nil` | Shorthand for `<MishkaPopoverDescription>`. |
  | `close` | string | `nil` | Shorthand for `<MishkaPopoverClose>`. |
  | `arrow` | boolean | `false` | Shorthand for `<MishkaPopoverArrow>` — a beak pointing back at the trigger. |
  | `width` | number | `nil` | Panel width. Omit and the panel hugs its content. |
  | `background` | color token / ARGB int | `:surface` | Panel fill. |
  | `color` / `muted_color` | color token / ARGB int | `:on_surface` / `:muted` | Title ink, and the description's. |
  | `corner_radius` | radius token / number | `:radius_md` | Panel corners. |
  | `padding` | spacing token / number | `:space_md` | Padding inside the panel. |
  | `border_color` / `border_width` | color / number | `:border` / `1` | The edge that separates it from the content beneath. |
  | `offset_x` / `offset_y` | number | `nil` | Raw nudge in dp, applied last — on top of `side_offset` and `align_offset` rather than instead of either. |

  The two offsets reach the anchored node as `panel_offset_x` / `panel_offset_y`,
  because `Mob.Renderer` wraps any node carrying `offset_x` / `offset_y` in an
  offset Box — which on the anchor would move the TRIGGER rather than the panel.

  Not ported: `modal` and the backdrop it draws (the panel's window is sized to
  the panel, so there is nothing there to dim the page with; a scrim belongs to
  whatever owns the screen root — use `MishkaMob.Components.MishkaDialog` or
  `MishkaMob.Components.MishkaDrawer` when the page must be blocked),
  `dismissible` and `close_on_escape` (the panel's window is deliberately not
  self-dismissing, so it cannot drift out of step with the screen's `open`, and a
  phone has no Escape), `initial_focus` / `final_focus` (Mob exposes no focus
  model for a panel), `labelledby` / `describedby` (no accessibility semantics on
  any node — the `title` and `description` are rendered instead of merely
  referenced), `open_on_hover` / `delay` / `close_delay`, and the `*_class`
  attrs.

  ## iOS

  There is no anchored primitive on iOS: `deps/mob/ios` is a checksum-locked hex
  dependency and cannot be edited from this repo. An unknown node type there
  falls through to `MobNodeTypeColumn`, so an anchored panel degrades to the old
  stacked accordion — it neither errors nor blanks. Floating is Android-only for
  now, and `IOS_TODO.md` §17 records it.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Anchored
  alias MishkaMob.Components.Event

  @sides [:top, :right, :bottom, :left]
  @aligns [:start, :center, :end]

  # The web's gap between trigger and panel, read as dp instead of px.
  @side_offset 8

  @trigger_slot :mishka_popover_trigger
  @title_slot :mishka_popover_title
  @description_slot :mishka_popover_description
  @close_slot :mishka_popover_close
  @arrow_slot :mishka_popover_arrow

  @slot_types [@trigger_slot, @title_slot, @description_slot, @close_slot, @arrow_slot]

  @doc """
  Composite expander (`<MishkaPopover>`). Children are the panel content, plus
  any slot tags among them.

  The slot tags are consumed one level down, in `popover/2`, rather than here:
  a slot tag has no module and no expander of its own, so `title/1` builds the
  very same node the markup does, and a caller who reaches for the function
  form has to get the same tree out. Consuming them in one place is what
  guarantees that. Whatever a parent fails to take reaches the renderer, which
  has no case for the type and draws nothing at all — silently.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: popover(props, children)

  @doc """
  The control that toggles the panel — the web's `<:trigger>`.

  Takes a label, one node, or a list of them; `<MishkaPopoverTrigger>` and the
  `trigger` prop build the same thing.

      trigger("Order details")
      trigger([icon(), label()])
  """
  @spec trigger(String.t() | map() | [map()]) :: map()
  def trigger(content), do: slot(@trigger_slot, content)

  @doc "The panel's heading — the web's `<:title>`. A line of text, or markup."
  @spec title(String.t() | map() | [map()]) :: map()
  def title(content), do: slot(@title_slot, content)

  @doc "The line under the heading — the web's `<:description>`. Text, or markup."
  @spec description(String.t() | map() | [map()]) :: map()
  def description(content), do: slot(@description_slot, content)

  @doc """
  The footer action — the web's `<:close>`.

  A label builds the button this module styles and wires, which reports the
  panel closed through the popover's own `on_open_change`. Markup instead puts
  your own controls in the footer row, and their handlers stay yours.
  """
  @spec close(String.t() | map() | [map()]) :: map()
  def close(content), do: slot(@close_slot, content)

  @doc """
  The beak pointing back at the trigger — the web's `<:arrow>`.

  Written bare it draws the glyph the `side` calls for, tinted like the panel.
  Give it a character or markup of your own and that is drawn instead.
  """
  @spec arrow(String.t() | map() | [map()] | nil) :: map()
  def arrow(content \\ nil)
  def arrow(nil), do: %{type: @arrow_slot, props: %{}, children: []}
  def arrow(content), do: slot(@arrow_slot, content)

  @doc """
  Every node type the popover consumes as a slot. Exported so a test can prove
  none of them leaked past `popover/2` to the renderer.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  # A slot written as a string keeps its text in props, so how it is styled
  # stays this module's decision rather than the caller's; one written as
  # markup contributes its children and is styled by whoever wrote it.
  defp slot(type, content) when is_binary(content),
    do: %{type: type, props: %{text: content}, children: []}

  defp slot(type, content) when is_list(content),
    do: %{type: type, props: %{}, children: content}

  defp slot(type, content) when is_map(content),
    do: %{type: type, props: %{}, children: [content]}

  @doc """
  The popover node — its trigger, and the panel while `open`.

      <MishkaPopover id="details" open={@open?} on_open_change={:details}>
        <MishkaPopoverTrigger text="Details" />
        <MishkaPopoverTitle text="Shipped" />
        {content}
      </MishkaPopover>

      def handle_info({:tap, {:details, open?}}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, open?)}
      end

  Slot children among `content` are consumed rather than drawn where they
  stand, so `[trigger("Details"), title("Shipped") | content]` builds exactly
  what that markup does.

  With no trigger at all it is the panel alone, which is how `MishkaMenu` and
  the select-style components use it: they place their own control. There is
  nothing to anchor to in that case, so the panel renders in place rather than
  in a window of its own.
  """
  @spec popover(map() | keyword(), [map()]) :: map()
  def popover(props \\ %{}, content \\ []) do
    {slots, content} = take_slots(content)
    props = props |> Map.new() |> merge_slots(slots)
    id = Map.get(props, :id)
    open? = truthy?(Map.get(props, :open, false))
    side = one_of(Map.get(props, :side), @sides, :bottom)
    align = one_of(Map.get(props, :align), @aligns, :start)

    trigger = trigger_part(props, id, open?, side)
    panel = if open?, do: [revealed(props, content, id, side, align)], else: []

    # The panel is not a sibling of the trigger — it is the second child of an
    # :anchored node, which draws it in its own window over the page. In flow it
    # pushed everything below it down, which is what "side: :top" could never
    # honestly mean and what made an open popover read as an accordion.
    inner =
      case {trigger, panel} do
        {[t], [p]} -> [Anchored.anchor(t, p, anchor_opts(props, side, align))]
        {[t], []} -> [Anchored.closed(t, anchor_opts(props, side, align))]
        # Pinned open with no trigger: there is nothing to anchor TO, so the
        # panel simply renders in place. This is the `menu`-in-a-drawer case.
        {[], [p]} -> [p]
        {[], []} -> []
      end

    put(%{type: :column, props: %{fill_width: true}, children: inner}, :id, id)
  end

  # side/align go to the anchored node; the two offsets change name because
  # Mob.Renderer wraps any node carrying offset_x/offset_y in an offset Box,
  # which here would move the TRIGGER rather than the panel.
  defp anchor_opts(props, side, align) do
    [
      side: side,
      align: align,
      side_offset: Map.get(props, :side_offset, @side_offset),
      align_offset: Map.get(props, :align_offset),
      panel_offset_x: Map.get(props, :offset_x),
      panel_offset_y: Map.get(props, :offset_y),
      flip: Map.get(props, :flip),
      clamp: Map.get(props, :clamp),
      edge_padding: Map.get(props, :edge_padding)
    ]
  end

  @doc """
  The panel shell without the `open` gate — the surface `MishkaMenu` and
  `MishkaPreviewCard` build on, so they all agree on radius, border and padding.

  Reads `:id` verbatim rather than deriving one, so a caller that already owns a
  tagging scheme keeps it.
  """
  @spec panel(map() | keyword(), [map()]) :: map()
  def panel(props \\ %{}, content \\ []) do
    props = Map.new(props)
    fill? = Map.get(props, :fill_width, if(Map.get(props, :width), do: nil, else: true))

    # The inner Column follows the outer Box. A filling child forces its Box to
    # the maximum constraint in Compose, so a Column pinned to `true` made a
    # hugging panel span the whole width anyway — which inside a popup window
    # means the whole SCREEN, and the position clamp then pinned it to the
    # leading edge no matter what `side` or `align` asked for.
    node =
      ~MOB"""
      <Box
        background={Map.get(props, :background, :surface)}
        corner_radius={Map.get(props, :corner_radius, :radius_md)}
        padding={Map.get(props, :padding, :space_md)}
        border_color={Map.get(props, :border_color, :border)}
        border_width={Map.get(props, :border_width, 1)}
      >
        <Column fill_width={fill? != false}>
          {content}
        </Column>
      </Box>
      """

    node
    |> put(:id, Map.get(props, :id))
    |> put(:width, Map.get(props, :width))
    |> put(:fill_width, fill?)
    |> put(:offset_x, Map.get(props, :offset_x))
    |> put(:offset_y, Map.get(props, :offset_y))
  end

  @doc """
  The trigger's tag, which carries its own open state.

  The trigger says whether its panel is up by changing fill, and a device test
  can read a tag but not a colour — so the state rides in the tag, exactly as a
  `MishkaMenu` checkbox appends `-checked`.
  """
  @spec trigger_id(String.t() | nil, boolean()) :: String.t() | nil
  def trigger_id(nil, _open?), do: nil
  def trigger_id(id, true) when is_binary(id), do: id <> "-trigger-open"
  def trigger_id(id, false) when is_binary(id), do: id <> "-trigger-closed"

  @doc "The panel's tag. It exists only while the popover is open."
  @spec panel_id(String.t() | nil) :: String.t() | nil
  def panel_id(nil), do: nil
  def panel_id(id) when is_binary(id), do: id <> "-panel"

  @doc "The title's tag."
  @spec title_id(String.t() | nil) :: String.t() | nil
  def title_id(nil), do: nil
  def title_id(id) when is_binary(id), do: id <> "-title"

  @doc "The description's tag. `-desc`, matching the web's `aria-describedby` target."
  @spec description_id(String.t() | nil) :: String.t() | nil
  def description_id(nil), do: nil
  def description_id(id) when is_binary(id), do: id <> "-desc"

  @doc "The footer close action's tag."
  @spec close_id(String.t() | nil) :: String.t() | nil
  def close_id(nil), do: nil
  def close_id(id) when is_binary(id), do: id <> "-close"

  @doc "The beak's tag."
  @spec arrow_id(String.t() | nil) :: String.t() | nil
  def arrow_id(nil), do: nil
  def arrow_id(id) when is_binary(id), do: id <> "-arrow"

  # ── The slots ───────────────────────────────────────────────────────────────

  # A slot tag has no module and no expander, so it arrives with its subtree
  # intact and nothing else will ever touch it: whatever is not taken out here
  # travels on to the renderer, which has no case for the type and draws
  # nothing — no crash, no warning, just a part that never appears. So they come
  # out of the children first, by :type, before anything else reads the list.
  defp take_slots(content) do
    {slots, content} = Enum.split_with(content, &slot?/1)
    {Enum.group_by(slots, & &1.type), content}
  end

  defp slot?(node), do: is_map(node) and Map.get(node, :type) in @slot_types

  # Each slot resolves to the same shape its shorthand prop already took — a
  # string, or nodes — and is written to the same key, so everything downstream
  # reads one prop and never learns which form the caller wrote. The slot wins
  # because it is the more specific of the two.
  defp merge_slots(props, slots) do
    props
    |> put_slot(slots, @trigger_slot, :trigger)
    |> put_slot(slots, @title_slot, :title)
    |> put_slot(slots, @description_slot, :description)
    |> put_slot(slots, @close_slot, :close)
    |> put_arrow(slots)
  end

  defp put_slot(props, slots, type, key) do
    case content_of(Map.get(slots, type, [])) do
      nil -> props
      content -> Map.put(props, key, content)
    end
  end

  # The arrow is the one slot whose EMPTY form still says something: writing
  # `<MishkaPopoverArrow />` is how markup says what `arrow={true}` says, and
  # the side's own glyph is what gets drawn.
  defp put_arrow(props, slots) do
    case Map.get(slots, @arrow_slot, []) do
      [] -> props
      nodes -> Map.put(props, :arrow, content_of(nodes) || true)
    end
  end

  defp content_of([]), do: nil
  defp content_of([%{props: %{text: text}}]) when is_binary(text), do: text

  defp content_of(nodes) do
    case Enum.flat_map(nodes, &Map.get(&1, :children, [])) do
      [] -> nil
      children -> children
    end
  end

  # ── The trigger ─────────────────────────────────────────────────────────────

  defp trigger_part(props, id, open?, side) do
    case Map.get(props, :trigger) do
      nil -> []
      trigger -> [trigger_box(props, trigger, id, open?, side)]
    end
  end

  defp trigger_box(props, trigger, id, open?, side) do
    disabled? = truthy?(Map.get(props, :disabled, false))
    # The trigger HUGS, on every side. It used to fill when stacked, because the
    # panel shared its Column and a narrow trigger looked stranded. Now the panel
    # is anchored to the trigger's own box, so a full-width trigger would make
    # `align: :end` mean "the screen's right edge" instead of "the trigger's" —
    # and the web anchors to a content-sized <button>.
    fill? = false
    _ = side
    {background, ink} = trigger_chrome(open?, disabled?)

    ~MOB"""
    <Box fill_width={fill?} background={background} corner_radius={:radius_md} padding={:space_sm}>
      {trigger_content(props, trigger, ink, open?, fill?)}
    </Box>
    """
    |> put(:id, trigger_id(id, open?))
    |> wire(props, open?, disabled?)
  end

  # An open popover leaves its trigger looking pressed — the web's `data-pressed`
  # / `data-popup-open`, which is a fill here because there is no CSS to hand.
  defp trigger_chrome(_open?, true), do: {:surface_raised, :muted}
  defp trigger_chrome(true, _disabled?), do: {:primary, :on_primary}
  defp trigger_chrome(false, _disabled?), do: {:surface_raised, :on_surface}

  defp trigger_content(props, trigger, ink, open?, fill?) do
    label =
      case trigger do
        text when is_binary(text) ->
          # max_lines: 1 — a Text squeezed narrower than its content wraps
          # character by character rather than clipping, and a trigger squeezed
          # by its own chevron is exactly that case.
          [~MOB"<Text text={text} text_size={:base} text_color={ink} max_lines={1} />"]

        nodes when is_list(nodes) ->
          nodes

        node ->
          [node]
      end

    if truthy?(Map.get(props, :chevron, true)) do
      glyph = if open?, do: "▴", else: "▾"

      [
        ~MOB"""
        <Row fill_width={fill?}>
          {label}
          <Spacer weight={1} :if={fill?} />
          <Spacer size={8} :if={not fill?} />
          <Text text={glyph} text_size={:sm} text_color={ink} />
        </Row>
        """
      ]
    else
      label
    end
  end

  # A disabled trigger gets no handler at all, so it cannot fire. The tap always
  # toggles; the hold only ever opens, because that is what the hover it stands
  # in for did.
  defp wire(node, _props, _open?, true), do: node

  defp wire(node, props, open?, false) do
    change = Map.get(props, :on_open_change)
    hold? = truthy?(Map.get(props, :open_on_hold, false))

    node
    |> put(:on_tap, Event.handler(change, not open?))
    |> put(:on_long_press, if(hold?, do: Event.handler(change, true)))
  end

  # ── The panel and what sits between it and the trigger ──────────────────────

  # The panel and its beak, as ONE node — the anchored node takes exactly two
  # children, and the gap between panel and trigger is now `side_offset` on the
  # anchor rather than a :spacer sibling.
  defp revealed(props, content, id, side, align) do
    surface =
      props
      |> Map.put(:id, panel_id(id))
      |> Map.put_new(:fill_width, false)
      |> panel(body(props, content, id))

    case beak(props, id, side, align) do
      [] ->
        surface

      beak ->
        # The beak faces the trigger, so it leads on :bottom/:right and trails on
        # :top/:left. The web centres its arrow on the POPUP (`left: 50%`), never
        # on the trigger, which is what `aligned(_, :center)` says here.
        parts = if side in [:top, :left], do: [surface] ++ beak, else: beak ++ [surface]
        axis = if side in [:left, :right], do: :row, else: :column

        %{type: axis, props: %{}, children: parts}
    end
  end

  # The web's arrow is a styled span the positioner rotates to face the trigger.
  # With the side known up front a glyph says the same thing, tinted like the
  # panel so it reads as the panel's own beak rather than a character.
  defp beak(props, id, side, _align) do
    if truthy?(Map.get(props, :arrow, false)) do
      node = beak_node(Map.get(props, :arrow), props, id, side)

      # Centred on the PANEL, which is what the web does (`left: 50%` on the
      # arrow, never an offset from the trigger). Before anchoring existed the
      # panel shared a full-width parent with the trigger, so the arrow had to
      # be aligned the same way the panel was; now it belongs to the panel.
      [if(side in [:top, :bottom], do: aligned(node, :center), else: node)]
    else
      []
    end
  end

  defp beak_node(glyph, props, id, _side) when is_binary(glyph) do
    fill = Map.get(props, :background, :surface)

    put(~MOB"<Text text={glyph} text_size={:sm} text_color={fill} />", :id, arrow_id(id))
  end

  defp beak_node([_ | _] = nodes, _props, id, _side) do
    put(
      ~MOB"""
      <Column>
        {nodes}
      </Column>
      """,
      :id,
      arrow_id(id)
    )
  end

  # `arrow={true}`, or a bare `<MishkaPopoverArrow />`: the side decides.
  defp beak_node(_content, props, id, side), do: beak_node(beak_glyph(side), props, id, side)

  defp beak_glyph(:bottom), do: "▲"
  defp beak_glyph(:top), do: "▼"
  defp beak_glyph(:right), do: "◀"
  defp beak_glyph(:left), do: "▶"

  defp body(props, content, id) do
    ink = Map.get(props, :color, :on_surface)
    muted = Map.get(props, :muted_color, :muted)

    [title_part(props, id, ink), description_part(props, id, muted), content, footer(props, id)]
    |> Enum.reject(&(&1 == []))
    |> Enum.intersperse([spacer(6)])
    |> List.flatten()
  end

  defp title_part(props, id, ink) do
    case Map.get(props, :title) do
      nil ->
        []

      text when is_binary(text) ->
        [put(~MOB"<Text text={text} text_size={:lg} text_color={ink} />", :id, title_id(id))]

      nodes ->
        [put(block(nodes), :id, title_id(id))]
    end
  end

  defp description_part(props, id, muted) do
    case Map.get(props, :description) do
      nil ->
        []

      text when is_binary(text) ->
        node = ~MOB"<Text text={text} text_size={:sm} text_color={muted} />"
        [put(node, :id, description_id(id))]

      nodes ->
        [put(block(nodes), :id, description_id(id))]
    end
  end

  # A part written as markup still has to be addressable, so its own Column
  # wears the tag the styled Text would have worn.
  defp block(nodes) do
    ~MOB"""
    <Column fill_width={true}>
      {nodes}
    </Column>
    """
  end

  # The web's `close` slot is a footer of actions, dismissed via `data-close`.
  # A label here is one such action, reporting the same open change the trigger
  # does with `false` — so a screen keeps a single clause for both.
  defp footer(props, id) do
    case Map.get(props, :close) do
      nil ->
        []

      label when is_binary(label) ->
        [footer_row([close_button(props, label, id)])]

      nodes ->
        # Your own controls carry their own handlers, so the tag goes on the row
        # rather than on a button this module did not build and cannot wire.
        [put(footer_row(nodes), :id, close_id(id))]
    end
  end

  defp close_button(props, label, id) do
    ~MOB"""
    <Box
      fill_width={false}
      background={:surface_raised}
      corner_radius={:radius_sm}
      padding={:space_sm}
    >
      <Text text={label} text_size={:sm} text_color={:on_surface} max_lines={1} />
    </Box>
    """
    |> put(:id, close_id(id))
    |> put(:on_tap, Event.handler(Map.get(props, :on_open_change), false))
  end

  defp footer_row(nodes) do
    ~MOB"""
    <Row fill_width={true}>
      <Spacer weight={1} />
      {nodes}
    </Row>
    """
  end

  # ── Layout plumbing ─────────────────────────────────────────────────────────

  # The beak sits inside the panel's own stack, so the only alignment left is
  # centring it across that stack — the web's `left: 50%` on the arrow. A Column
  # has no horizontal alignment on either platform, hence the Box.
  defp aligned(node, align) do
    %{type: :box, props: %{fill_width: true, align: box_align(align)}, children: [node]}
  end

  defp box_align(:center), do: :top_center

  defp spacer(size), do: %{type: :spacer, props: %{size: size}, children: []}

  defp one_of(value, allowed, default) when is_atom(value) and not is_nil(value) do
    if value in allowed, do: value, else: default
  end

  defp one_of(value, allowed, default) when is_binary(value) do
    Enum.find(allowed, default, &(Atom.to_string(&1) == value))
  end

  defp one_of(_value, _allowed, default), do: default

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
