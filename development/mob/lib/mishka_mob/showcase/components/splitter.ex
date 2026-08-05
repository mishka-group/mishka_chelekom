defmodule MishkaMob.Showcase.Components.Splitter do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSplitter`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaSplitter
  alias MishkaMob.Showcase.Example

  @extent 300
  @vextent 200

  @impl true
  def entry do
    %{
      slug: :splitter,
      name: "Splitter",
      category: "Layout",
      order: 6,
      description: "Two resizable panes with a draggable divider."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:split, 55)
    |> Mob.Socket.assign(:vsplit, 40)
    |> Mob.Socket.assign(:bounded, 50)
    |> Mob.Socket.assign(:grab, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Side by side",
        description: "Drag the divider between the panes. It is the handle — there is no slider.",
        code: ~S"""
        <MishkaSplitter
          value={@split}
          extent={300}
          on_change={:split}
          id="panes"
        >{[left(), right()]}</MishkaSplitter>

        # A canvas reports canvas-LOCAL coordinates, so the arithmetic is
        # relative: drag/3 anchors on the "began" phase and adds the distance
        # travelled since. Keep the anchor in an assign and hand it back.
        def handle_info({:drag, :split, payload}, socket) do
          {value, grab} =
            MishkaSplitter.drag(payload, socket.assigns.grab,
              value: socket.assigns.split,
              extent: 300
            )

          {:noreply, socket |> assign(:split, value) |> assign(:grab, grab)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSplitter value={@split} extent={300} on_change={:split} id="panes">
              {[pane("Editor", :primary), pane("Preview", :muted)]}
            </MishkaSplitter>
            <Spacer size={10} />
            <Text text={"First pane: " <> percent(@split) <> "%"} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Stacked",
        description: "The same grip, dividing height instead of width. Drag it up and down.",
        code: ~S"""
        <MishkaSplitter
          value={@vsplit}
          orientation={:vertical}
          extent={200}
          on_change={:vsplit}
        >{[top(), bottom()]}</MishkaSplitter>

        # orientation: :vertical makes drag/3 read y instead of x.
        def handle_info({:drag, :vsplit, payload}, socket) do
          {value, grab} =
            MishkaSplitter.drag(payload, socket.assigns.grab,
              value: socket.assigns.vsplit,
              extent: 200,
              orientation: :vertical
            )

          {:noreply, socket |> assign(:vsplit, value) |> assign(:grab, grab)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSplitter
              value={@vsplit}
              orientation={:vertical}
              extent={200}
              on_change={:vsplit}
              id="stack"
            >
              {[pane("Output", :primary), pane("Console", :muted)]}
            </MishkaSplitter>
          </Column>
          """
        end
      },
      %Example{
        title: "Bounded, and disabled",
        description: "min/max stop a pane vanishing. Disabled greys the grip and unwires it.",
        code: ~S"""
        <MishkaSplitter value={@bounded} min={30} max={70} extent={300} on_change={:bounded} />
        <MishkaSplitter value={50} extent={300} disabled={true} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSplitter
              value={@bounded}
              min={30}
              max={70}
              extent={300}
              on_change={:bounded}
              id="bounded"
            >
              {[pane("Min 30%", :primary), pane("Max 70%", :muted)]}
            </MishkaSplitter>
            <Spacer size={14} />
            <MishkaSplitter value={50} extent={300} disabled={true} id="frozen">
              {[pane("Frozen", :muted), pane("Inert", :muted)]}
            </MishkaSplitter>
          </Column>
          """
        end
      }
    ]
  end

  defp percent(value), do: value |> round() |> Integer.to_string()

  defp pane(label, ink) do
    ~MOB"""
    <Column fill_width={true} padding={:space_md}>
      <Text text={label} text_size={:sm} text_color={ink} font_weight={:semibold} />
      <Spacer size={6} />
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
      <Spacer size={5} />
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end

  @impl true
  def props do
    [
      %{name: "value", type: "0–100", default: "50", description: "First pane's share."},
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Side by side, or stacked."
      },
      %{
        name: "extent",
        type: "number",
        default: "320",
        description: "Total dp to divide — no weight works on both platforms."
      },
      %{
        name: "min / max",
        type: "0–100",
        default: "10 / 90",
        description: "Bounds; a pane can never vanish."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "{:drag, tag, payload} as the divider moves. Fold it with drag/3."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "The grip greys and stops responding; the panes keep their sizes."
      },
      %{
        name: "grip / grip_color",
        type: "number · ARGB",
        default: "24 · grey",
        description: "The drag target's thickness, and the pill. Canvas ops take ints."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag; panes get <id>-pane-1/2 and the grip <id>-grip."
      },
      %{
        name: "drag/3 · sizes/1 · split/1",
        type: "helpers",
        default: "—",
        description: "Fold a drag; the pane arithmetic without rendering."
      }
    ]
  end

  @impl true
  def handle(_tag, socket), do: socket

  # Every drag arrives here as {:drag, tag, payload}; ComponentScreen routes it
  # to handle_change/3 the same way it routes {:change, tag, value}.
  @impl true
  def handle_change(:split, payload, socket), do: resize(socket, :split, payload, @extent, [])

  # Its own assign, not :split — two examples sharing one would mean dragging
  # either moved both, and no test (or reader) could say which it had touched.
  def handle_change(:bounded, payload, socket),
    do: resize(socket, :bounded, payload, @extent, min: 30, max: 70)

  def handle_change(:vsplit, payload, socket),
    do: resize(socket, :vsplit, payload, @vextent, orientation: :vertical)

  def handle_change(_tag, _value, socket), do: socket

  defp resize(socket, key, payload, extent, opts) do
    opts = Keyword.merge([value: Map.fetch!(socket.assigns, key), extent: extent], opts)
    {value, grab} = MishkaSplitter.drag(payload, socket.assigns.grab, opts)

    socket
    |> Mob.Socket.assign(key, value)
    |> Mob.Socket.assign(:grab, grab)
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <Box width={46} height={44} background={:surface_raised} corner_radius={:radius_sm} />
      <Box width={10} height={44} align={:center}>
        <Box width={3} height={22} background={:muted} corner_radius={:radius_pill} />
      </Box>
      <Box width={30} height={44} background={:surface_raised} corner_radius={:radius_sm} />
    </Row>
    """
  end
end
