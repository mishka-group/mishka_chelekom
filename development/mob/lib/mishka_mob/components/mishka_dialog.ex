defmodule MishkaMob.Components.MishkaDialog do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Dialog** — a centred modal
  over a dimmed backdrop.

  Shares the Drawer's overlay mechanics (Mob has no z-index or modal layer, so
  an overlay is a `:box` stacking `[scrim, panel]` that is itself stacked over
  the screen), but centres its panel instead of anchoring it to an edge.

  ## Sizing and corners

  The panel is a **width-locked Box**, not a fill-width Column. That is a
  deliberate repeat of a lesson from the Drawer: `corner_radius` clips on a Box
  on both platforms, while a Compose Column rounds and a SwiftUI VStack does
  not. A dialog with square corners on iOS would be an obvious defect, so the
  panel takes an explicit `width` (default `320`) — which is also how dialogs
  behave on the web, where they are max-width constrained rather than
  edge-to-edge.

  ## Usage

      <MishkaDialog
        open={@open?}
        title="Delete file?"
        description="This cannot be undone."
        on_close={:close_dialog}
        actions={actions}
      >{body}</MishkaDialog>

      def handle_info({:tap, :close_dialog}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, false)}
      end
      # REQUIRED catch-all: the panel routes stray taps to an ignored tag.
      def handle_info(_msg, socket), do: {:noreply, socket}

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `open` | boolean | `false` | Whether the dialog is shown. Lives in the screen. |
  | `title` | string | `nil` | Heading. |
  | `description` | string | `nil` | Supporting line under the heading. |
  | `dismissible` | boolean | `true` | Whether a backdrop tap closes it. `false` forces an explicit choice (what Alert Dialog does). |
  | `on_close` | event tag (atom) | — | Sent on backdrop tap. Without it the backdrop is inert. |
  | `width` | number | `320` | Panel width. |
  | `background` | color token / ARGB int | `:surface` | Panel background. |
  | `corner_radius` | radius token / number | `:radius_lg` | Panel corners. |
  | `padding` | spacing token / number | `:space_lg` | Padding inside the panel. |
  | `scrim_color` | ARGB int / token | `0x99000000` | Backdrop fill. |

  Not ported: `modal`, `close_on_escape`, `initial_focus`, `final_focus`,
  `labelledby`, `describedby` and the `*_class` attrs — focus traps, keyboard
  escape and ARIA anchoring are DOM concerns. A native modal has no focus ring
  to trap and no Escape key.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # Taps on the panel's empty areas must not reach the scrim, or the dialog
  # would dismiss itself. Routing them to a tag the screen ignores absorbs them
  # (the host screen's catch-all handle_info/2 swallows it).
  @absorb :__mishka_dialog_ignore
  @scrim 0x99_00_00_00

  @doc """
  Composite expander (`<MishkaDialog>`). The tag's children are the dialog body.
  """
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  # `actions` arrives as a prop rather than a second slot: a composite's
  # expand/3 is handed ONE children list, so a footer would otherwise be
  # unreachable from markup and `<MishkaDialog>` could never replace a
  # dialog/4 call. Popped before the props reach the widget.
  def expand(props, children, ctx) do
    {actions, props} = Map.pop(Map.new(props), :actions, [])
    dialog(props, children, List.wrap(actions), ctx)
  end

  @doc """
  The dialog node. `body` is the content; `actions` are footer nodes laid out in
  a trailing-aligned row. Renders an empty column when closed.
  """
  @spec dialog(map() | keyword(), [map()], [map()], map()) :: map()
  def dialog(props \\ %{}, body \\ [], actions \\ [], ctx \\ %{}) do
    props = Map.new(props)

    if truthy?(Map.get(props, :open, false)) do
      overlay(props, body, actions, ctx)
    else
      ~MOB(<Column />)
    end
  end

  defp overlay(props, body, actions, ctx) do
    # An alert dialog keeps its backdrop inert so the user must choose. Note the
    # `if` rather than `dismissible? && close`: the latter yields `false`, which
    # would be attached as an on_tap prop instead of omitting the handler.
    close =
      if truthy?(Map.get(props, :dismissible, true)) do
        Event.handler(Map.get(props, :on_close))
      end

    scrim = scrim(Map.get(props, :scrim_color, @scrim), close)

    ~MOB"""
    <Box fill_width={true} fill_height={true}>
      {scrim}
      <Box fill_width={true} fill_height={true} align={:center} padding={:space_lg}>
        {panel(props, body, actions, ctx)}
      </Box>
    </Box>
    """
  end

  defp scrim(color, nil),
    do: ~MOB(<Box fill_width={true} fill_height={true} background={color} />)

  defp scrim(color, close) do
    node = ~MOB(<Box fill_width={true} fill_height={true} background={color} />)
    %{node | props: Map.put(node.props, :on_tap, close)}
  end

  # Width-locked Box so corner_radius clips on BOTH platforms (a Compose Column
  # rounds, a SwiftUI VStack does not).
  defp panel(props, body, actions, ctx) do
    absorb = absorb_tap(ctx)

    node = ~MOB"""
    <Box
      width={Map.get(props, :width, 320)}
      background={Map.get(props, :background, :surface)}
      corner_radius={Map.get(props, :corner_radius, :radius_lg)}
    >
      <Column fill_width={true} padding={Map.get(props, :padding, :space_lg)}>
        {heading(props)}
        {body}
        {footer(actions)}
      </Column>
    </Box>
    """

    %{node | props: Map.put(node.props, :on_tap, absorb)}
  end

  defp heading(props) do
    title = Map.get(props, :title)
    description = Map.get(props, :description)

    ~MOB"""
    <Column fill_width={true}>
      <Text text={title} text_size={:xl} text_color={:on_surface} :if={is_binary(title)} />
      <Spacer size={6} :if={is_binary(title) and is_binary(description)} />
      <Text text={description} text_size={:base} text_color={:muted} :if={is_binary(description)} />
      <Spacer size={16} :if={is_binary(title) or is_binary(description)} />
    </Column>
    """
  end

  defp footer([]), do: ~MOB(<Column />)

  defp footer(actions) do
    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={18} />
      <Row fill_width={true}>
        <Spacer weight={1} />
        {actions}
      </Row>
    </Column>
    """
  end

  # ctx carries the screen pid for composite expansion; when called as a plain
  # function the caller's process (the screen) is already correct.
  defp absorb_tap(%{screen: pid}) when is_pid(pid), do: {pid, @absorb}
  defp absorb_tap(_ctx), do: {self(), @absorb}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
