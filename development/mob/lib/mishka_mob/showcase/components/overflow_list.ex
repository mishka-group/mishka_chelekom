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
  @min_width 130
  @max_width 270
  @rail_height 56

  # The drag surface must NEVER be declared wider than the space it is given.
  # MobCanvas scales its ops by measured/declared while a Box merely clips, so a
  # canvas that overflows draws everything squashed inwards — the handle ended
  # up painted on top of the "+N" counter it was supposed to sit beside. 300dp
  # clears a phone's content width (411 screen, less page and card padding).
  @surface_width 300

  # Short labels here so the count visibly swings as you drag, rather than
  # sticking on one long word.
  @rail_tags ~w(Elixir Beam OTP Mob CLI Web API)

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
        title: "Make it bigger — pull the handle",
        description:
          "Put your finger on the grey handle at the right of the box and drag it sideways. " <>
            "A wider box fits more badges; a narrower one folds them into the +N.",
        code: ~S"""
        # The component cannot measure — but a screen that SET its own width
        # already knows it, and fit/3 turns that into a count.
        <MishkaOverflowList
          visible={MishkaOverflowList.fit(@tags, @width)}
          id="rail"
        >{tag_pills()}</MishkaOverflowList>

        # The edge is a canvas over the box, because only a canvas carries
        # on_drag — and it spans the whole width RANGE rather than riding on the
        # edge, so its coordinates do not move with the thing they measure.
        def handle_info({:drag, :width, %{phase: :began, x: x}}, socket) do
          # At or right of the edge grabs the handle; a touch inside the box is
          # a touch on a badge, and is ignored.
          offset = x - socket.assigns.width
          {:noreply, assign(socket, :grab, if(offset >= -16.0, do: offset))}
        end

        def handle_info({:drag, :width, %{x: x}}, socket) when socket.assigns.grab != nil do
          {:noreply, assign(socket, :width, clamp(x - socket.assigns.grab))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="⇤  drag the handle  ⇥"
              text_size={:sm}
              text_color={:primary}
              font_weight={:semibold}
            />
            <Spacer size={8} />
            {rail(@width)}
            <Spacer size={10} />
            <Text
              text={dp(@width) <> "dp wide · showing " <> showing(@width) <> " of " <> total()}
              text_size={:sm}
              text_color={:muted}
              id="rail-readout"
            />
          </Column>
          """
        end
      },
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

  defp fit(width), do: MishkaOverflowList.fit(@rail_tags, width)

  defp rail_pills, do: Enum.map(@rail_tags, &pill(label: &1))

  defp dp(width), do: width |> round() |> Integer.to_string()

  defp showing(width), do: width |> fit() |> Integer.to_string()

  defp total, do: length(@rail_tags) |> Integer.to_string()

  # Grab the box's RIGHT EDGE and pull, exactly like the web original.
  #
  # The edge is drawn on a canvas that spans the full width RANGE and lies over
  # the box in a z-stack. That is the part worth understanding: a handle pinned
  # to the box's trailing edge would MOVE as the box resizes, and a canvas
  # reports coordinates local to itself — so its ruler would slide under the
  # finger and the drag would fight itself. Static and full-range means x maps
  # straight onto a width. MishkaSplitter's moduledoc has the long version; it
  # had to be rebuilt this way for exactly the same reason.
  defp rail(width) do
    %{
      type: :box,
      props: %{width: @surface_width, height: @rail_height},
      children: [
        %{
          type: :box,
          props: %{
            width: width,
            height: @rail_height,
            background: :surface_raised,
            corner_radius: :radius_md,
            padding: :space_sm
          },
          children: [
            MishkaOverflowList.overflow_list(%{visible: fit(width), id: "rail"}, rail_pills())
          ]
        },
        edge(width)
      ]
    }
  end

  defp edge(width) do
    mid = @rail_height / 2

    %{
      type: :canvas,
      props: %{
        width: @surface_width,
        height: @rail_height,
        id: "rail-handle",
        on_drag: MishkaMob.Components.Event.handler(:width),
        draw: [
          # Drawn just OUTSIDE the box, not straddling its edge: at width - 3 it
          # sat on top of the "+N" counter, which lives hard against that edge.
          #
          # Deliberately chunky. The first version was a hairline that read as
          # decoration, and the person using it could not tell there was anything
          # to grab — which is the only thing that matters about a handle.
          Mob.Canvas.rect(width + 4, 0, 22, @rail_height,
            color: 0xFF6B7280,
            radius: 6,
            fill: true
          ),
          Mob.Canvas.rect(width + 12, mid - 11, 3, 3, color: 0xFFFFFFFF, radius: 2, fill: true),
          Mob.Canvas.rect(width + 12, mid - 2, 3, 3, color: 0xFFFFFFFF, radius: 2, fill: true),
          Mob.Canvas.rect(width + 12, mid + 7, 3, 3, color: 0xFFFFFFFF, radius: 2, fill: true)
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
  # Only a drag that STARTS on the edge resizes the box. The canvas covers the
  # badges — it has to, to be a stable ruler — so without this every tap on a
  # badge would snap the width to the finger.
  @impl true
  def handle_change(:width, payload, socket) do
    x = (payload[:x] || payload["x"] || 0) * 1.0

    case {phase(payload), socket.assigns.grab} do
      {:began, _} ->
        # Anything AT or RIGHT OF the box's edge grabs the handle; a touch well
        # inside the box is a touch on a badge and is ignored.
        #
        # A half-open rule rather than a window around the edge: the canvas is
        # declared wider than the space it is given, so its logical x runs a
        # little ahead of the dp the box is laid out in, and a tolerance tuned
        # by eye missed the real grab by about a millimetre.
        offset = x - socket.assigns.width
        Mob.Socket.assign(socket, :grab, if(offset >= -16.0, do: offset))

      {:ended, _} ->
        Mob.Socket.assign(socket, :grab, nil)

      {:dragging, nil} ->
        socket

      {:dragging, offset} ->
        Mob.Socket.assign(socket, :width, clamp_width(x - offset))
    end
  end

  def handle_change(_tag, _value, socket), do: socket

  defp phase(payload) do
    case payload[:phase] || payload["phase"] do
      p when p in [:began, "began"] -> :began
      p when p in [:ended, "ended"] -> :ended
      _ -> :dragging
    end
  end

  defp clamp_width(width), do: width |> max(@min_width) |> min(@max_width)

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
