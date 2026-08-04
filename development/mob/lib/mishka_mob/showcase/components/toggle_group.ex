defmodule MishkaMob.Showcase.Components.ToggleGroup do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToggleGroup`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaToggleGroup
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toggle_group,
      name: "Toggle Group",
      category: "Forms",
      order: 8,
      description: "A row of toggle buttons sharing one selection."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tgg_align, :center)
    |> Mob.Socket.assign(:tgg_style, [:bold, :italic])
    |> Mob.Socket.assign(:tgg_view, :grid)
  end

  # The component ships no look, exactly like the headless original — every
  # style below is the SHOWCASE's, passed as ordinary props.
  #
  # A segmented bar is a group with no gap and borderless items, sitting in a
  # rounded track. The items are INSET (the track has 3dp of padding) rather
  # than flush to its corners: a flush item would need per-corner rounding to
  # follow the track, and corner_radius is a single number on both renderers, so
  # the first and last segments would square off the rounded ends.

  # The props that make a group look segmented — written out on each bar below
  # rather than merged in by a helper, because the whole point of this page is
  # that the styling is ordinary markup a reader can copy:
  #
  #   space={0} corner_radius={6} padding={10} border_width={0}
  #   background={:transparent} fill_width={false}
  #
  # `fill_width={false}` is on the GROUP, not just its items — otherwise the
  # track wraps a Row that fills, and the bar stretches to the screen edge
  # around three short buttons.

  @impl true
  def examples do
    [
      %Example{
        title: "Single",
        description: "Pressing the pressed button clears the group — unlike a radio group.",
        code: ~S"""
        <MishkaToggleGroup value={@align} on_change={:align} space={0} border_width={0}>
          <MishkaToggleGroupItem id={:left} label="Left" />
          <MishkaToggleGroupItem id={:center} label="Center" />
          <MishkaToggleGroupItem id={:right} label="Right" />
        </MishkaToggleGroup>

        # press/3 is the reducer: in single mode, pressing the pressed one clears.
        def handle_info({:tap, {:align, id}}, socket) do
          next = MishkaToggleGroup.press(socket.assigns.align, id, false)
          {:noreply, Mob.Socket.assign(socket, :align, next)}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <Box
                fill_width={false}
                border_width={1}
                border_color={:border}
                corner_radius={9}
                padding={3}
                background={:surface_raised}
              >
                <MishkaToggleGroup
                  value={@tgg_align}
                  on_change={:tgg_align}
                  id="tgg-align"
                  space={0}
                  corner_radius={6}
                  padding={10}
                  border_width={0}
                  background={:transparent}
                  fill_width={false}
                >
                  <MishkaToggleGroupItem id={:left} label="Left" />
                  <MishkaToggleGroupItem id={:center} label="Center" />
                  <MishkaToggleGroupItem id={:right} label="Right" />
                </MishkaToggleGroup>
              </Box>
            </Row>
            <Spacer size={12} />
            <Text text={"Value: " <> inspect(@tgg_align)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description: "multiple: true makes the value a set — several pressed at once.",
        code: ~S"""
        <MishkaToggleGroup value={@style} multiple={true} on_change={:style}>
          <MishkaToggleGroupItem id={:bold} label="Bold" />
          <MishkaToggleGroupItem id={:italic} label="Italic" />
          <MishkaToggleGroupItem id={:under} label="Underline" />
        </MishkaToggleGroup>

        def handle_info({:tap, {:style, id}}, socket) do
          next = MishkaToggleGroup.press(socket.assigns.style, id, true)
          {:noreply, Mob.Socket.assign(socket, :style, next)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <Box
                fill_width={false}
                border_width={1}
                border_color={:border}
                corner_radius={9}
                padding={3}
                background={:surface_raised}
              >
                <MishkaToggleGroup
                  value={@tgg_style}
                  multiple={true}
                  on_change={:tgg_style}
                  id="tgg-style"
                  space={0}
                  corner_radius={6}
                  padding={10}
                  border_width={0}
                  background={:transparent}
                  fill_width={false}
                >
                  <MishkaToggleGroupItem id={:bold} label="Bold" />
                  <MishkaToggleGroupItem id={:italic} label="Italic" />
                  <MishkaToggleGroupItem id={:under} label="Underline" />
                </MishkaToggleGroup>
              </Box>
            </Row>
            <Spacer size={12} />
            <Text text={"Value: " <> inspect(@tgg_style)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Vertical",
        description: "orientation stacks them, and stacked items share one width.",
        code: ~S"""
        <MishkaToggleGroup orientation={:vertical} value={@view} on_change={:view}>
          <MishkaToggleGroupItem id={:list} label="List" />
          <MishkaToggleGroupItem id={:grid} label="Grid" />
          <MishkaToggleGroupItem id={:cards} label="Cards" />
        </MishkaToggleGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Box width={150}>
              <Box
                fill_width={false}
                border_width={1}
                border_color={:border}
                corner_radius={9}
                padding={3}
                background={:surface_raised}
              >
                <MishkaToggleGroup
                  value={@tgg_view}
                  orientation={:vertical}
                  on_change={:tgg_view}
                  id="tgg-view"
                  space={0}
                  corner_radius={6}
                  padding={10}
                  border_width={0}
                  background={:transparent}
                  fill_width={false}
                >
                  <MishkaToggleGroupItem id={:list} label="List" />
                  <MishkaToggleGroupItem id={:grid} label="Grid" />
                  <MishkaToggleGroupItem id={:cards} label="Cards" />
                </MishkaToggleGroup>
              </Box>
            </Box>
          </Row>
          """
        end
      },
      %Example{
        title: "Styled by props, not by a stylesheet",
        description: "The component ships no look. Same group, two different styles.",
        code: ~S"""
        # Spaced pills
        <MishkaToggleGroup space={8} corner_radius={20} padding={12} color={0xFF7C3AED} />

        # Joined and square
        <MishkaToggleGroup space={0} corner_radius={2} border_width={1} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggleGroup
                value={@tgg_align}
                on_change={:tgg_align}
                space={8}
                corner_radius={20}
                padding={12}
                border_width={0}
                color={0xFF7C3AED}
                background={0xFFEFEDF7}
                text_size={:sm}
              >
                <MishkaToggleGroupItem id={:left} label="Left" />
                <MishkaToggleGroupItem id={:center} label="Center" />
                <MishkaToggleGroupItem id={:right} label="Right" />
              </MishkaToggleGroup>
            </Row>
            <Spacer size={14} />
            <Row fill_width={true}>
              <MishkaToggleGroup
                value={@tgg_align}
                on_change={:tgg_align}
                space={0}
                corner_radius={2}
                padding={10}
                border_width={1}
                color={0xFF111111}
                text_size={:sm}
              >
                <MishkaToggleGroupItem id={:left} label="Left" />
                <MishkaToggleGroupItem id={:center} label="Center" />
                <MishkaToggleGroupItem id={:right} label="Right" />
              </MishkaToggleGroup>
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description:
          "One item, or the whole group. A disabled item still shows if it is pressed.",
        code: ~S"""
        # One item off:
        <MishkaToggleGroupItem id={:right} label="Right" disabled={true} />

        # The whole group off — it cascades to every item:
        <MishkaToggleGroup disabled={true} value={@align}>
          <MishkaToggleGroupItem id={:left} label="Left" />
          <MishkaToggleGroupItem id={:right} label="Right" />
        </MishkaToggleGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="ONE ITEM OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <Box
                fill_width={false}
                border_width={1}
                border_color={:border}
                corner_radius={9}
                padding={3}
                background={:surface_raised}
              >
                <MishkaToggleGroup
                  value={@tgg_align}
                  on_change={:tgg_align}
                  id="tgg-one"
                  space={0}
                  corner_radius={6}
                  padding={10}
                  border_width={0}
                  background={:transparent}
                  fill_width={false}
                >
                  <MishkaToggleGroupItem id={:left} label="Left" />
                  <MishkaToggleGroupItem id={:right} label="Right (off)" disabled={true} />
                </MishkaToggleGroup>
              </Box>
            </Row>
            <Spacer size={16} />
            <Text text="WHOLE GROUP OFF" text_size={:sm} text_color={:muted} />
            <Spacer size={8} />
            <Row fill_width={true}>
              <Box
                fill_width={false}
                border_width={1}
                border_color={:border}
                corner_radius={9}
                padding={3}
                background={:surface_raised}
              >
                <MishkaToggleGroup
                  value={:on}
                  disabled={true}
                  id="tgg-off"
                  space={0}
                  corner_radius={6}
                  padding={10}
                  border_width={0}
                  background={:transparent}
                  fill_width={false}
                >
                  <MishkaToggleGroupItem id={:off} label="A (off)" />
                  <MishkaToggleGroupItem id={:on} label="B (off)" />
                </MishkaToggleGroup>
              </Box>
            </Row>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "value",
        type: "id, list or nil",
        default: "nil",
        description: "The pressed item(s). A list in multiple mode."
      },
      %{
        name: "multiple",
        type: "boolean",
        default: "false",
        description: "Allow several pressed at once."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every item."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}."
      },
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Layout axis."
      },
      %{
        name: "space",
        type: "number",
        default: "8",
        description: "Gap between items. 0 joins them into one bar."
      },
      %{
        name: "color · text_color · background · label_color",
        type: "see Toggle",
        default: "—",
        description: "Forwarded to every item. Pressed pair, then idle pair."
      },
      %{
        name: "padding · corner_radius",
        type: "see Toggle",
        default: "—",
        description: "Also forwarded. The group has no look of its own."
      },
      %{
        name: "border_color · border_width · text_size",
        type: "see Toggle",
        default: "—",
        description: "Forwarded too. border_width: 0 gives a segmented bar's inner buttons."
      },
      %{
        name: "fill_width",
        type: "boolean",
        default: "true",
        description: "The container's width. false lets it hug, for a segmented bar."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Prefix for each item's test tag: <id>-<item>-pressed."
      },
      %{
        name: "press/3 · pressed?/2",
        type: "helpers",
        default: "—",
        description: "The selection reducer and the pressed test, for both modes."
      }
    ]
  end

  @impl true
  def handle({:tgg_align, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :tgg_align,
        MishkaToggleGroup.press(socket.assigns.tgg_align, id, false)
      )

  def handle({:tgg_style, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :tgg_style,
        MishkaToggleGroup.press(socket.assigns.tgg_style, id, true)
      )

  def handle({:tgg_view, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :tgg_view,
        MishkaToggleGroup.press(socket.assigns.tgg_view, id, false)
      )

  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={40} height={24} background={:primary} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={40} height={24} background={:surface_raised} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={40} height={24} background={:surface_raised} corner_radius={:radius_md} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={28} height={24} background={:primary} corner_radius={:radius_md} />
        <Spacer size={6} />
        <Box width={28} height={24} background={:primary} corner_radius={:radius_md} />
      </Row>
    </Column>
    """
  end
end
