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
    * `expire/2` — drop everything older than `duration`.

  Auto-dismissal needs a timer, and a timer belongs to the screen
  (`Process.send_after/3`), not to a render function — a component that started
  its own timers would fire once per render.

  ## Layout

  Toasts stack in a `Column` pinned to the top or bottom of a fill-height Box, so
  the viewport overlays the screen the same way the Drawer and Dialog do. It is
  meant to be returned from a screen's root `:box`, or from a showcase's
  `overlay/1`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `toasts` | list of maps | `[]` | `%{id:, title:, description:, variant:}`. |
  | `position` | `:top` `:bottom` | `:bottom` | Which edge to stack against. |
  | `on_dismiss` | event tag (atom) | — | Sent as `{:tap, {tag, toast_id}}` from a toast's ✕. |
  | `padding` | spacing token / number | `:space_lg` | Padding around the stack. |
  | `space` | number | `10` | Gap between toasts. |

  Variants tint the accent bar: `:info` (default), `:success`, `:warning`,
  `:danger`.

  Not ported: the `*_class` attrs, `close_label` (an `aria-label`), and the
  `aria-live` region itself — Mob has no live-region concept to announce into.
  """

  import Mob.Sigil

  alias MishkaMob.Components.{Event, MishkaActionIcon}

  @accents %{
    info: 0xFF3B82F6,
    success: 0xFF10B981,
    warning: 0xFFF59E0B,
    danger: 0xFFDC2626
  }

  @doc "Composite expander (`<MishkaToast />`). Delegates to `toast/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: toast(props)

  @doc "The accent colour for a variant."
  @spec accent(atom()) :: integer()
  def accent(variant), do: Map.get(@accents, variant, @accents.info)

  @doc """
  The toast viewport.

      toast(toasts: @toasts, position: :bottom, on_dismiss: :drop_toast)
  """
  @spec toast(map() | keyword()) :: map()
  def toast(props \\ %{}) do
    props = Map.new(props)
    toasts = List.wrap(Map.get(props, :toasts, []))

    if toasts == [] do
      ~MOB(<Column />)
    else
      viewport(props, toasts)
    end
  end

  defp viewport(props, toasts) do
    space = Map.get(props, :space, 10)

    stack =
      toasts |> Enum.map(&card(&1, props)) |> Enum.intersperse(~MOB(<Spacer size={space} />))

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

  defp card(toast, props) do
    title = Map.get(toast, :title)
    description = Map.get(toast, :description)
    bar = accent(Map.get(toast, :variant, :info))

    ~MOB"""
    <Box fill_width={true} background={:surface} corner_radius={:radius_md} padding={:space_md}>
      <Row fill_width={true}>
        <Box width={4} height={34} background={bar} corner_radius={:radius_sm} />
        <Spacer size={12} />
        <Column fill_width={true}>
          <Text text={title} text_size={:base} text_color={:on_surface} :if={is_binary(title)} />
          <Spacer size={4} :if={is_binary(title) and is_binary(description)} />
          <Text text={description} text_size={:sm} text_color={:muted} :if={is_binary(description)} />
        </Column>
        {close(props, Map.get(toast, :id))}
      </Row>
    </Box>
    """
  end

  defp close(props, id) do
    case Event.handler(Map.get(props, :on_dismiss)) do
      nil ->
        ~MOB(<Row />)

      {pid, tag} ->
        MishkaActionIcon.action_icon(icon: "✕", size: 32, on_tap: {pid, {tag, id}})
    end
  end
end
