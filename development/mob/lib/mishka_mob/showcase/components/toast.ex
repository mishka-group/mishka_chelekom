defmodule MishkaMob.Showcase.Components.Toast do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToast`.

  The toasts really stack, dedup and cap — the buttons drive the queue functions,
  and `overlay/1` renders the viewport over the whole page.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaToast, only: [toast: 1]

  alias MishkaMob.Components.MishkaToast.Queue
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toast,
      name: "Toast",
      category: "Feedback",
      order: 3,
      description: "Transient messages stacked at an edge of the screen."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tst, [])
    |> Mob.Socket.assign(:tst_next, 1)
    |> Mob.Socket.assign(:tst_position, :bottom)
    |> Mob.Socket.assign(:tst_static, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Stack a few",
        description: "The viewport renders whatever list the screen holds.",
        code: ~S"""
        # in overlay/1 — the viewport overlays the whole page
        <MishkaToast toasts={@toasts} on_dismiss={:drop} />

        def handle({:add, variant}, socket) do
          entry = %{id: socket.assigns.next, title: "Saved", variant: variant}

          socket
          |> Mob.Socket.assign(:toasts, Queue.push(socket.assigns.toasts, entry))
          |> Mob.Socket.assign(:next, socket.assigns.next + 1)
        end

        # the ✕ sends {:tap, {tag, toast_id}}, so one clause serves every card
        def handle({:drop, id}, socket),
          do: Mob.Socket.assign(socket, :toasts, Queue.dismiss(socket.assigns.toasts, id))
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {btn("Info", :info)}
              <Spacer size={8} />
              {btn("Success", :success)}
            </Row>
            <Spacer size={8} />
            <Row fill_width={true}>
              {btn("Warning", :warning)}
              <Spacer size={8} />
              {btn("Danger", :danger)}
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Capped and deduped",
        description: "limit keeps the newest few; dedup_key replaces instead of stacking.",
        code: ~S"""
        Queue.push(toasts, toast, limit: 3, dedup_key: :title)
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="Every push here uses limit: 3 and dedup_key: :title — tapping the same button twice replaces rather than stacks."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={12} />
            <Row fill_width={true}>
              {btn("Repeat me", :info)}
              <Spacer size={8} />
              {plain("Clear all", :tst_clear)}
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Position",
        description: "Stack against the top or the bottom edge.",
        code: ~S"""
        <MishkaToast toasts={@toasts} position={@position} on_dismiss={:drop} />

        def handle(:to_top, socket), do: Mob.Socket.assign(socket, :position, :top)
        def handle(:to_bottom, socket), do: Mob.Socket.assign(socket, :position, :bottom)
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {plain("Top", :tst_top)}
            <Spacer size={8} />
            {plain("Bottom", :tst_bottom)}
          </Row>
          """
        end
      },
      %Example{
        title: "Slots",
        description:
          "A toast written in markup rather than queued, with its own body and " <>
            "a custom dismiss label. Toggle it and watch it stack with the queued ones.",
        code: ~S"""
        <MishkaToast toasts={@toasts} on_dismiss={:drop}>
          <MishkaToastItem id={:welcome} title="Welcome" variant={:info}>
            <Text text="Written in markup, not queued." text_size={:sm} />
          </MishkaToastItem>
          <MishkaToastClose>
            <Text text="Dismiss" text_size={:sm} text_color={:muted} />
          </MishkaToastClose>
        </MishkaToast>

        # A static item is not in @toasts, so Queue.dismiss cannot remove it —
        # the screen drops it by flipping the flag that renders the markup.
        def handle({:drop, :welcome}, socket),
          do: Mob.Socket.assign(socket, :static?, false)

        def handle({:drop, id}, socket),
          do: Mob.Socket.assign(socket, :toasts, Queue.dismiss(socket.assigns.toasts, id))
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="The markup toast carries a body instead of a description, and every card's ✕ becomes a 'Dismiss' label."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={12} />
            <Row fill_width={true}>
              {plain("Toggle markup toast", :tst_toggle_static)}
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Auto-dismiss",
        description:
          "Timers belong to the screen. Stamp each toast with :at, then drive " <>
            "Queue.expire/3 from a tick — per-toast :duration wins, and 0 is sticky.",
        code: ~S"""
        # push with a stamp, and schedule the sweep
        entry = %{id: id, title: "Saved", at: System.monotonic_time(:millisecond)}
        Process.send_after(self(), :sweep, 1_000)

        def handle(:sweep, socket) do
          Process.send_after(self(), :sweep, 1_000)
          Mob.Socket.assign(socket, :toasts, Queue.expire(socket.assigns.toasts, 5_000))
        end

        # this one never expires, matching the web engine's `duration: 0`
        %{id: 9, title: "Sticky", duration: 0, at: now}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Text
            text="Queue.expire/3 is a pure function over the list, so the sweep is testable without waiting on a timer."
            text_size={:sm}
            text_color={:muted}
          />
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "toasts",
        type: "list of maps",
        default: "[]",
        description:
          "%{id:, title:, description:, variant:, duration:, content:}. " <>
            "content is a node list rendered instead of title/description."
      },
      %{
        name: "position",
        type: ":top · :bottom",
        default: ":bottom",
        description: "Which edge to stack against."
      },
      %{
        name: "on_dismiss",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, toast_id}} from a toast's ✕."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_lg",
        description: "Padding around the stack."
      },
      %{name: "space", type: "number", default: "10", description: "Gap between toasts."},
      %{
        name: "close_icon",
        type: "string",
        default: "\"✕\"",
        description: "Glyph for the dismiss control."
      },
      %{
        name: "<MishkaToastItem>",
        type: "slot",
        default: "—",
        description:
          "A toast written in markup. Attrs match a toast map; children are its body. " <>
            "Cannot dismiss itself — it is not in the queue."
      },
      %{
        name: "<MishkaToastClose>",
        type: "slot",
        default: "—",
        description: "Content for every card's dismiss control, replacing close_icon."
      },
      %{
        name: "Queue.push/3 · dismiss/2 · expire/3",
        type: "helpers",
        default: "—",
        description: "limit, dedup and auto-dismiss, driven by the screen."
      }
    ]
  end

  # Two paths on purpose. Without the markup toast this is the plain function
  # call every screen makes; with it, the composite tag — which is the only path
  # that can carry slot children, and the one that widens `on_dismiss` to
  # `{screen_pid, tag}` for us.
  @impl true
  def overlay(%{tst_static: true} = assigns) do
    queued = assigns.tst
    position = assigns.tst_position

    ~MOB"""
    <MishkaToast toasts={queued} position={position} on_dismiss={:tst_drop}>
      <MishkaToastItem id={:welcome} title="Welcome" variant={:info}>
        <Text
          text="Written in markup, not queued — its body is a slot."
          text_size={:sm}
          text_color={:muted}
        />
      </MishkaToastItem>
      <MishkaToastClose>
        <Text text="Dismiss" text_size={:sm} text_color={:muted} />
      </MishkaToastClose>
    </MishkaToast>
    """
  end

  def overlay(assigns) do
    toast(toasts: assigns.tst, position: assigns.tst_position, on_dismiss: :tst_drop)
  end

  @impl true
  def handle({:tst_add, variant}, socket) do
    id = socket.assigns.tst_next

    entry = %{
      id: id,
      title: title_for(variant),
      description: "Toast ##{id} — tap the ✕ to dismiss.",
      variant: variant
    }

    socket
    |> Mob.Socket.assign(:tst, Queue.push(socket.assigns.tst, entry, limit: 3, dedup_key: :title))
    |> Mob.Socket.assign(:tst_next, id + 1)
  end

  # The markup toast is not in the queue, so Queue.dismiss has nothing to remove
  # — dropping it means stopping rendering it.
  def handle({:tst_drop, :welcome}, socket),
    do: Mob.Socket.assign(socket, :tst_static, false)

  def handle({:tst_drop, id}, socket),
    do: Mob.Socket.assign(socket, :tst, Queue.dismiss(socket.assigns.tst, id))

  def handle(:tst_toggle_static, socket),
    do: Mob.Socket.assign(socket, :tst_static, not socket.assigns.tst_static)

  def handle(:tst_clear, socket), do: Mob.Socket.assign(socket, :tst, [])
  def handle(:tst_top, socket), do: Mob.Socket.assign(socket, :tst_position, :top)
  def handle(:tst_bottom, socket), do: Mob.Socket.assign(socket, :tst_position, :bottom)
  def handle(_tag, socket), do: socket

  defp title_for(:success), do: "Saved"
  defp title_for(:warning), do: "Careful"
  defp title_for(:danger), do: "Failed"
  defp title_for(_), do: "Heads up"

  defp btn(label, variant) do
    tap = {self(), {:tst_add, variant}}

    ~MOB"""
    <Button
      text={label}
      background={:surface_raised}
      text_color={:on_surface}
      padding={:space_sm}
      weight={1}
      on_tap={tap}
    />
    """
  end

  defp plain(label, tag) do
    tap = {self(), tag}

    ~MOB"""
    <Button
      text={label}
      background={:primary}
      text_color={:on_primary}
      padding={:space_sm}
      weight={1}
      on_tap={tap}
    />
    """
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} background={:surface} corner_radius={:radius_md} padding={8}>
        <Row fill_width={true}>
          <Box width={4} height={20} background={0xFF10B981} corner_radius={:radius_sm} />
          <Spacer size={8} />
          <Column fill_width={true}>
            <Box width={48} height={7} background={:muted} corner_radius={:radius_sm} />
            <Spacer size={4} />
            <Box width={72} height={6} background={:surface_raised} corner_radius={:radius_sm} />
          </Column>
        </Row>
      </Box>
      <Spacer size={8} />
      <Box fill_width={true} background={:surface} corner_radius={:radius_md} padding={8}>
        <Row fill_width={true}>
          <Box width={4} height={20} background={0xFF3B82F6} corner_radius={:radius_sm} />
          <Spacer size={8} />
          <Box width={56} height={7} background={:muted} corner_radius={:radius_sm} />
        </Row>
      </Box>
    </Column>
    """
  end
end
