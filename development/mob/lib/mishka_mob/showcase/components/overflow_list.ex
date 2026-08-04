defmodule MishkaMob.Showcase.Components.OverflowList do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaOverflowList`.

  The web version watches its container and hides whatever will not fit. Mob
  cannot measure, so `visible` is declared — which makes the *counter* the
  interesting surface here, not the layout.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaPill, only: [pill: 1]

  alias MishkaMob.Components.MishkaOverflowList
  alias MishkaMob.Showcase.Example

  @tags ~w(Design Phoenix Elixir LiveView Tailwind Headless Accessibility)

  # The resizable example's rail, in dp. Narrow enough that the first drag
  # visibly drops items, wide enough that everything fits at the far end.
  @min_width 140
  @max_width 340

  @impl true
  def entry do
    %{
      slug: :overflow_list,
      name: "Overflow List",
      category: "Layout",
      order: 7,
      description: "Items on one row, with the rest collapsed into a +N counter."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:visible, 3)
    |> Mob.Socket.assign(:width, 240)
    |> Mob.Socket.assign(:grab, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Three fit, four do not",
        description: "The same shape the web version lands on: items, then +N for the remainder.",
        code: ~S"""
        <MishkaOverflowList visible={3} id="langs">{tag_pills()}</MishkaOverflowList>

        # split/2 is the whole policy, and it is public — a screen can ask what
        # would be hidden without rendering anything.
        {shown, hidden} = MishkaOverflowList.split(tags, visible: 3)
        length(hidden)
        #=> 4
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOverflowList visible={3} id="langs">
              {tag_pills()}
            </MishkaOverflowList>
          </Column>
          """
        end
      },
      %Example{
        title: "Tap the counter",
        description: "on_counter makes +N a control — reveal the rest, or open a sheet.",
        code: ~S"""
        <MishkaOverflowList
          visible={@visible}
          on_counter={:more}
        >{tag_pills()}</MishkaOverflowList>

        def handle_info({:tap, :more}, socket) do
          {:noreply, Mob.Socket.assign(socket, :visible, socket.assigns.visible + 1)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOverflowList visible={@visible} on_counter={:more} id="more">
              {tag_pills()}
            </MishkaOverflowList>
            <Spacer size={10} />
            <Text text="Tap +N to reveal one more." text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "min_visible is a floor",
        description: "visible={0} still shows one — the web makes the same guarantee.",
        code: ~S"""
        <MishkaOverflowList visible={0} min_visible={2}>{tag_pills()}</MishkaOverflowList>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOverflowList visible={0} id="floor-one">
              {tag_pills()}
            </MishkaOverflowList>
            <Spacer size={10} />
            <MishkaOverflowList visible={0} min_visible={2} id="floor-two">
              {tag_pills()}
            </MishkaOverflowList>
          </Column>
          """
        end
      },
      %Example{
        title: "Resizable — drag the handle, the count follows",
        description:
          "What the web gets from a ResizeObserver. The screen owns the width, so it can ask " <>
            "fit/3 what that width holds.",
        code: ~S"""
        # The component cannot measure — but a screen that SET its own width
        # already knows it, and fit/3 turns that into a count.
        <MishkaOverflowList
          visible={MishkaOverflowList.fit(@tags, @width)}
          id="rail"
        >{tag_pills()}</MishkaOverflowList>

        # The handle is a canvas, because only a canvas carries on_drag.
        def handle_info({:drag, :width, payload}, socket) do
          {width, grab} = drag_width(payload, socket.assigns.grab, socket.assigns.width)
          {:noreply, socket |> assign(:width, width) |> assign(:grab, grab)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box width={@width} background={:surface_raised} corner_radius={:radius_md} padding={:space_sm}>
              <MishkaOverflowList visible={fit(@width)} id="rail">
                {tag_pills()}
              </MishkaOverflowList>
            </Box>
            <Spacer size={8} />
            {handle(@width)}
            <Spacer size={10} />
            <Text
              text={"Width " <> dp(@width) <> "dp · hidden: " <> hidden(@width)}
              text_size={:sm}
              text_color={:muted}
              id="rail-readout"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "A counter that says something else",
        description: "counter_text takes the hidden count and returns whatever label you want.",
        code: ~S"""
        <MishkaOverflowList
          visible={2}
          counter_text={&"#{&1} more"}
        >{tag_pills()}</MishkaOverflowList>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOverflowList visible={2} counter_text={&more_label/1} id="worded">
              {tag_pills()}
            </MishkaOverflowList>
          </Column>
          """
        end
      }
    ]
  end

  defp more_label(count), do: "#{count} more"

  defp fit(width), do: MishkaOverflowList.fit(@tags, width)

  defp dp(width), do: width |> round() |> Integer.to_string()

  defp hidden(width), do: (length(@tags) - fit(width)) |> Integer.to_string()

  # The drag track.
  #
  # It sits BELOW the rail and spans the full width range, and both of those are
  # load-bearing. Beside the rail it competed for room in an unweighted Row and
  # was starved to zero width — the very bug this page's component just had. And
  # a handle pinned to the rail's trailing edge would MOVE as the rail resizes,
  # making its own canvas-local coordinates a ruler that slides under the finger
  # (see MishkaSplitter's moduledoc for the version of that which had to be
  # undone). Static and full-range means x maps straight onto a width.
  defp handle(width) do
    span = @max_width
    at = width - @min_width

    %{
      type: :canvas,
      props: %{
        width: span,
        height: 36,
        id: "rail-handle",
        on_drag: MishkaMob.Components.Event.handler(:width),
        draw: [
          Mob.Canvas.rect(0, 16, span, 4, color: 0x22000000, radius: 2),
          Mob.Canvas.rect(0, 16, at, 4, color: 0x556B7280, radius: 2),
          Mob.Canvas.rect(max(at - 7, 0), 6, 14, 24, color: 0xFF6B7280, radius: 4)
        ]
      },
      children: []
    }
  end

  defp tag_pills, do: Enum.map(@tags, &pill(label: &1))

  @impl true
  def props do
    [
      %{
        name: "visible",
        type: "integer",
        default: "3",
        description: "How many items to show. Declared, not measured — Mob reports no geometry."
      },
      %{
        name: "min_visible",
        type: "integer",
        default: "1",
        description: "Never show fewer than this, even if visible is lower."
      },
      %{
        name: "space",
        type: "number",
        default: "6",
        description: "Gap between items, and before the counter."
      },
      %{
        name: "counter_text",
        type: "fun/1 · string",
        default: "+N",
        description: "The counter's label, from the hidden count."
      },
      %{
        name: "on_counter",
        type: "event tag",
        default: "—",
        description: "{:tap, tag} on the counter. Without it the +N is inert."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag; items get <id>-item-<n>, the counter <id>-counter."
      },
      %{
        name: "fit/3",
        type: "helper",
        default: "—",
        description: "labels + a width you know -> a count. The stand-in for a ResizeObserver."
      },
      %{
        name: "split/2",
        type: "helper",
        default: "—",
        description: "{shown, hidden} — where a measured count would plug in unchanged."
      }
    ]
  end

  @impl true
  def handle(:more, socket),
    do: Mob.Socket.assign(socket, :visible, min(socket.assigns.visible + 1, length(@tags)))

  def handle(_tag, socket), do: socket

  # The handle canvas spans exactly the width RANGE, so x maps straight onto it:
  # absolute, no anchor arithmetic, no ruler that moves with what it measures.
  @impl true
  def handle_change(:width, payload, socket) do
    x = payload[:x] || payload["x"] || 0
    width = (@min_width + x) |> max(@min_width) |> min(@max_width)

    Mob.Socket.assign(socket, :width, width)
  end

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <Box width={38} height={18} background={:surface_raised} corner_radius={:radius_pill} />
      <Spacer size={6} />
      <Box width={30} height={18} background={:surface_raised} corner_radius={:radius_pill} />
      <Spacer size={6} />
      <Box width={22} height={18} background={:muted} corner_radius={:radius_pill} />
    </Row>
    """
  end
end
