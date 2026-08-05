defmodule MishkaMob.Components.MishkaToast do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Toast** — transient messages
  stacked at an edge of the screen.

  ## What a native toast keeps, and what it hands back

  The web engine owns a queue: it caps the visible count (`limit`), auto-dismisses
  after `duration`, and collapses repeats by `dedup_key`. None of that is
  rendering, and all of it is easier and more honest in the screen, where the
  messages already live. So this component renders a **viewport of the toasts you
  give it**, and `MishkaMob.Components.MishkaToast.Queue` provides the queue
  operations as pure functions:

    * `push/3` — add a message, applying `limit` and `dedup_key`.
    * `dismiss/2` — remove one by id.
    * `expire/3` — drop everything past its `duration`.

  Auto-dismissal needs a timer, and a timer belongs to the screen
  (`Process.send_after/3`), not to a render function — a component that started
  its own timers would fire once per render.

  ## Layout

  Toasts stack in a `Column` pinned to the top or bottom of a fill-height Box, so
  the viewport overlays the screen the same way the Drawer and Dialog do. It is
  meant to be returned from a screen's root `:box`, or from a showcase's
  `overlay/1`.

  **This is the headless component's own layout, not a simplification of it.**
  The headless toast ships no CSS at all — "positioning + the collapsible stack
  are entirely consumer CSS — the engine only writes the layout vars". Unstyled,
  its `<ol>` of `<li>` is a plain vertical list, which is exactly this `Column`
  of cards separated by a `Spacer`. The layered "peek behind + scale down" stack
  people picture is a stylesheet in the *web showcase*, keyed off the
  `--toast-index` / `--toast-offset-y` vars the JS hook writes. That look does
  not port: it needs `transform: scale` and `opacity`, and Mob's renderer has
  neither on ordinary nodes. Nor do its triggers — expansion rides on
  pointerenter/focusin, and Mob has no hover and no focus outside text inputs.

  ## Slots

  Two ways to write a toast, mirroring the web component's static `<:toast>` slot
  and its dynamic `<:template>`:

      <MishkaToast toasts={@toasts} on_dismiss={:drop}>
        <MishkaToastItem title="Welcome" variant={:info}>
          <Text text="Anything you receive lands here." text_size={:sm} />
        </MishkaToastItem>
        <MishkaToastClose>
          <Text text="Dismiss" text_size={:sm} text_color={:muted} />
        </MishkaToastClose>
      </MishkaToast>

    * `<MishkaToastItem>` — one statically-written toast. Its attrs are the same
      keys a queued toast map carries (`id`, `title`, `description`, `variant`,
      `duration`), and its children are the toast's body. A title stays as a
      header above that body; with no title the body is the whole card, which is
      the web `<:toast>` slot's own shape. Static items render before the queued
      ones.
    * `<MishkaToastClose>` — custom content for every toast's dismiss control,
      replacing the `close_icon` glyph.

  A queued toast can carry a body too: put nodes under `:content` in its map and
  they render below its title, which is how a dynamic toast gets buttons in it.

  **A static item cannot dismiss itself.** It lives in the render tree, never in
  the screen's toast list, so `Queue.dismiss/2` has nothing to remove — the
  screen has to track its own flag and stop writing the markup. Queued toasts
  dismiss normally.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `toasts` | list of maps | `[]` | `%{id:, title:, description:, variant:, duration:, content:}`. |
  | `position` | `:top` `:bottom` | `:bottom` | Which edge to stack against. |
  | `on_dismiss` | event tag (atom) | — | Sent as `{:tap, {tag, toast_id}}` from a toast's ✕. |
  | `close_icon` | string | `"✕"` | Glyph for the dismiss control. |
  | `padding` | spacing token / number | `:space_lg` | Padding around the stack. |
  | `space` | number | `10` | Gap between toasts. |

  Variants tint the accent bar: `:info` (default), `:success`, `:warning`,
  `:danger`.

  Not ported: the `*_class` attrs, `close_label` (an `aria-label`), the
  `aria-live` region itself — Mob has no live-region concept to announce into —
  and the `<:trigger>` slot, because this viewport is an overlay stretched over
  the whole page; a button inside it would sit under an invisible fill-size Box.
  Put the trigger on the page instead.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaActionIcon}

  @item_type :mishka_toast_item
  @close_type :mishka_toast_close
  @slot_types [@item_type, @close_type]

  # The keys a `<MishkaToastItem>` shares with a queued toast map.
  @item_keys [:id, :title, :description, :variant, :duration]

  @accents %{
    info: 0xFF3B82F6,
    success: 0xFF10B981,
    warning: 0xFFF59E0B,
    danger: 0xFFDC2626
  }

  @doc """
  Composite expander (`<MishkaToast>`).

  Children are partitioned into the two slots: `<MishkaToastItem>` nodes become
  statically-written toasts rendered ahead of the queued ones, and
  `<MishkaToastClose>` contributes the dismiss control's content. Slot tags are
  ordinary composite children matched on `:type` and consumed here, so no marker
  node ever reaches the renderer — the same shape `MishkaEmptyState` uses.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx) do
    props = Map.new(props)
    statics = children |> Enum.filter(&match?(%{type: @item_type}, &1)) |> Enum.map(&static/1)
    queued = List.wrap(Map.get(props, :toasts, []))

    props
    |> Map.put(:toasts, statics ++ queued)
    |> toast(slot(children, @close_type))
  end

  # A slot tag contributes its OWN children; the tag itself is dropped.
  defp slot(children, type) do
    children
    |> Enum.filter(&match?(%{type: ^type}, &1))
    |> Enum.flat_map(&Map.get(&1, :children, []))
  end

  # A static item IS a toast map — its attrs are the map's keys, its children
  # the body. Anything else the author wrote is ignored rather than leaked into
  # the card as a stray prop.
  defp static(node) do
    node
    |> Map.get(:props, %{})
    |> Map.new()
    |> Map.take(@item_keys)
    |> Map.put(:content, Map.get(node, :children, []))
  end

  @doc "The accent colour for a variant."
  @spec accent(atom()) :: integer()
  def accent(variant), do: Map.get(@accents, variant, @accents.info)

  @doc """
  The toast viewport.

      toast(toasts: @toasts, position: :bottom, on_dismiss: :drop_toast)

  `close_content` replaces the dismiss glyph on every card; it is what
  `<MishkaToastClose>` supplies through `expand/3`.
  """
  @spec toast(map() | keyword(), [map()]) :: map()
  def toast(props \\ %{}, close_content \\ []) do
    props = Map.new(props)
    toasts = List.wrap(Map.get(props, :toasts, []))

    if toasts == [] do
      ~MOB(<Column />)
    else
      viewport(props, toasts, close_content)
    end
  end

  defp viewport(props, toasts, close_content) do
    space = Map.get(props, :space, 10)

    stack =
      toasts
      |> Enum.map(&card(&1, props, close_content))
      |> Enum.intersperse(~MOB(<Spacer size={space} />))

    top? = Map.get(props, :position, :bottom) == :top
    pad = Map.get(props, :padding, :space_lg)

    ~MOB"""
    <Box fill_width={true} fill_height={true} padding={pad}>
      <Column fill_width={true} fill_height={true}>
        <Spacer weight={1} :if={top? == false} />
        <Column fill_width={true}>
          {stack}
        </Column>
        <Spacer weight={1} :if={top?} />
      </Column>
    </Box>
    """
  end

  # The body takes `weight`, not `fill_width`. A Compose Row measures a
  # non-weighted child against the space left over, so a fillMaxWidth body ate
  # the whole row and the trailing ✕ was measured at width 0 — rendered, but
  # zero-wide and untappable on Android. iOS was fine (an HStack serves its
  # fixed-size children first), which is exactly what made it easy to miss.
  # `<Box weight={1}>` around the flexible part is the house idiom for this
  # shape; MishkaCombobox and MishkaNumberField wrap their inputs the same way.
  defp card(toast, props, close_content) do
    bar = accent(Map.get(toast, :variant, :info))

    ~MOB"""
    <Box fill_width={true} background={:surface} corner_radius={:radius_md} padding={:space_md}>
      <Row fill_width={true}>
        <Box width={4} height={34} background={bar} corner_radius={:radius_sm} />
        <Spacer size={12} />
        <Box weight={1}>
          <Column fill_width={true}>
            {body(toast)}
          </Column>
        </Box>
        {close(props, Map.get(toast, :id), close_content)}
      </Row>
    </Box>
    """
  end

  # Content is the body, and title/description stay a header above it — a
  # `<MishkaToastItem title="...">` with children keeps its title rather than
  # silently losing it. Give no title and the content is the whole card, which is
  # the web `<:toast>` slot's own shape.
  defp body(toast) do
    content = List.wrap(Map.get(toast, :content, []))
    titled? = is_binary(Map.get(toast, :title)) or is_binary(Map.get(toast, :description))

    cond do
      content == [] -> [text_block(toast)]
      titled? -> [text_block(toast), ~MOB(<Spacer size={6} />) | content]
      true -> content
    end
  end

  defp text_block(toast) do
    title = Map.get(toast, :title)
    description = Map.get(toast, :description)

    ~MOB"""
    <Column fill_width={true}>
      <Text text={title} text_size={:base} text_color={:on_surface} :if={is_binary(title)} />
      <Spacer size={4} :if={is_binary(title) and is_binary(description)} />
      <Text text={description} text_size={:sm} text_color={:muted} :if={is_binary(description)} />
    </Column>
    """
  end

  defp close(props, id, content) do
    icon = Map.get(props, :close_icon, "✕")

    case Event.handler(Map.get(props, :on_dismiss)) do
      nil ->
        ~MOB(<Row />)

      {pid, tag} when content == [] ->
        MishkaActionIcon.action_icon(icon: icon, size: 32, on_tap: {pid, {tag, id}})

      {pid, tag} ->
        label(content, {pid, {tag, id}})
    end
  end

  # Slot content will not fit an icon. `action_icon` is a `size`×`size` square —
  # right for a glyph, and the reason a "Dismiss" label handed to it renders
  # clipped to "Dis" on a device. A Row is the honest box for arbitrary content:
  # it hugs on BOTH platforms (a Compose Row does not fill by default, and an
  # HStack hugs unless told to fill) and takes `on_tap` on both.
  defp label(content, tap) do
    ~MOB"""
    <Row padding={:space_sm} on_tap={tap}>
      {content}
    </Row>
    """
  end

  @doc false
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types
end
