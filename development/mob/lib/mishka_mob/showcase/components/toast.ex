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
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Stack a few",
        description: "The viewport renders whatever list the screen holds.",
        code: ~S"""
        # in overlay/1
        {toast(toasts: @toasts, on_dismiss: :drop)}

        # in the handler
        Queue.push(@toasts, %{id: id, title: "Saved", variant: :success})
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
        {toast(toasts: @toasts, position: :top)}
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
        description: "%{id:, title:, description:, variant:}."
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
        name: "Queue.push/3 · dismiss/2 · expire/3",
        type: "helpers",
        default: "—",
        description: "limit, dedup and auto-dismiss, driven by the screen."
      }
    ]
  end

  @impl true
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

  def handle({:tst_drop, id}, socket),
    do: Mob.Socket.assign(socket, :tst, Queue.dismiss(socket.assigns.tst, id))

  def handle(:tst_clear, socket), do: Mob.Socket.assign(socket, :tst, [])
  def handle(:tst_top, socket), do: Mob.Socket.assign(socket, :tst_position, :top)
  def handle(:tst_bottom, socket), do: Mob.Socket.assign(socket, :tst_position, :bottom)
  def handle(_tag, socket), do: socket

  defp title_for(:success), do: "Saved"
  defp title_for(:warning), do: "Careful"
  defp title_for(:danger), do: "Failed"
  defp title_for(_), do: "Heads up"

  defp btn(label, variant) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :surface_raised,
        text_color: :on_surface,
        padding: :space_sm,
        weight: 1,
        on_tap: {self(), {:tst_add, variant}}
      },
      children: []
    }
  end

  defp plain(label, tag) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :primary,
        text_color: :on_primary,
        padding: :space_sm,
        weight: 1,
        on_tap: {self(), tag}
      },
      children: []
    }
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
