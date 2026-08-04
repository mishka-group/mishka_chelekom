defmodule MishkaMob.Showcase.Components.FloatingWindow do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaFloatingWindow` and
  `MishkaMob.Components.MishkaFloatingIndicator`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaFloatingWindow, only: [floating_window: 2]

  alias MishkaMob.Components.MishkaFloatingWindow
  alias MishkaMob.Showcase.Example

  # The stage the draggable examples live in, and the size their drag canvas is
  # declared at. It has to fit inside the example card on a 360dp phone: a
  # canvas declared wider than the space it gets SCALES its ops, and then every
  # coordinate it reports is in a different unit from the dp the window is
  # positioned with. 24dp of page padding plus 16dp of card padding, on both
  # sides, is 80dp of the narrowest phone's 360 — and a theme with a spacing
  # scale takes more, so 240 rather than the 280 that would just fit.
  @stage {240, 200}

  # Where the draggable window goes home to. The e2e resets to it before
  # measuring, because the BEAM outlives the Activity and the last test's drag
  # is still on screen.
  @home {20, 12}

  @impl true
  def entry do
    %{
      slug: :floating_window,
      name: "Floating Window",
      # "Overlays", not "Overlay" — by_category/0 groups on the raw string, so a
      # singular here gave the gallery a second, one-item overlay section.
      category: "Overlays",
      order: 7,
      description: "A window you drag by its title bar, plus a floating indicator."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:drag_pos, @home)
    |> Mob.Socket.assign(:grab, nil)
    |> Mob.Socket.assign(:step_pos, {0, 0})
    |> Mob.Socket.assign(:step_grab, nil)
    |> Mob.Socket.assign(:open?, true)
    |> Mob.Socket.assign(:pings, 0)
    |> Mob.Socket.assign(:tab, :day)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Drag it by the title bar",
        description:
          "A real finger drag. The drag surface is one static canvas the size of the stage — " <>
            "which is what bounds is for — and it engages only when the touch starts on the bar.",
        code: ~S"""
        <MishkaFloatingWindow
          x={@x}
          y={@y}
          bounds={{240, 200}}
          width={160}
          height={100}
          label="Inspector"
          dragging={@grab != nil}
          show_nudges={false}
          on_move={:move}
          id="win"
        >{[body()]}</MishkaFloatingWindow>

        # The canvas never moves, so x/y are POSITIONS in stage coordinates.
        # drag/3 anchors on the :began phase — keep that anchor in an assign and
        # hand it back; it comes back nil when the finger lifts.
        def handle_info({:drag, :move, payload}, socket) do
          {position, grab} =
            MishkaFloatingWindow.drag(payload, socket.assigns.grab,
              x: elem(socket.assigns.drag_pos, 0),
              y: elem(socket.assigns.drag_pos, 1),
              width: 160,
              height: 100,
              bounds: {240, 200}
            )

          {:noreply, socket |> assign(:drag_pos, position) |> assign(:grab, grab)}
        end
        """,
        render: fn assigns -> drag_example(assigns) end
      },
      %Example{
        title: "Nudge, for precision",
        description:
          "The arrows are the alternative WCAG 2.5.7 asks for, at 48dp each. They read step " <>
            "and bounds from the same props the window drew with, so the clamp is the stage " <>
            "minus the window — tap past the edge and it stops rather than walking out of view.",
        code: ~S"""
        <MishkaFloatingWindow
          x={@x}
          y={@y}
          bounds={{240, 200}}
          width={200}
          height={140}
          step={20}
          label="Layers"
          on_move={:step_move}
          id="step"
        >{[body()]}</MishkaFloatingWindow>

        # One tap, one step. nudge/2 takes the window's own props, so it clamps
        # against the geometry that was actually drawn.
        def handle_info({:tap, {:step_move, direction}}, socket) do
          moved = MishkaFloatingWindow.nudge(window(socket.assigns), direction)

          {:noreply, assign(socket, :step_pos, moved)}
        end
        """,
        render: fn assigns -> nudge_example(assigns) end
      },
      %Example{
        title: "A window that closes",
        description:
          "No on_move means no drag surface — and then the body takes taps again, because " <>
            "nothing is laid over it. The ✕ is the one control that lives in the title bar.",
        code: ~S"""
        <MishkaFloatingWindow label="Console" width={220} height={130} on_close={:close} id="closable">
          {[ping_button()]}
        </MishkaFloatingWindow>

        def handle_info({:tap, :close}, socket), do: {:noreply, assign(socket, :open?, false)}

        def handle_info({:tap, :ping}, socket),
          do: {:noreply, assign(socket, :pings, socket.assigns.pings + 1)}
        """,
        render: fn assigns -> closable_example(assigns) end
      },
      %Example{
        title: "Its own title bar",
        description:
          "handle replaces the label with your own node. It is decoration: it sits under the " <>
            "drag surface so the whole bar stays draggable, which also means it takes no taps.",
        code: ~S"""
        <MishkaFloatingWindow
          handle={custom_bar()}
          width={240}
          height={110}
          id="custom"
        >{[body()]}</MishkaFloatingWindow>
        """,
        render: fn _assigns -> custom_example() end
      },
      %Example{
        title: "Floating indicator",
        description:
          "The web version measures the active target and slides a box over it. Here the " <>
            "active target draws its own highlight — no measurement needed, and still exactly one.",
        code: ~S"""
        <MishkaFloatingIndicator targets={@tabs} active={@tab} on_change={:pick} />

        def handle_info({:tap, {:pick, value}}, socket), do: {:noreply, assign(socket, :tab, value)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaFloatingIndicator
              targets={[ %{label: "Day", value: :day}, %{label: "Week", value: :week}, %{label: "Month", value: :month} ]}
              active={@tab}
              on_change={:tab}
            />
            <Spacer size={10} />
            <Text text={"Showing: " <> to_string(@tab)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Stacked indicator",
        description: "The same component as a vertical group.",
        code: ~S"""
        <MishkaFloatingIndicator targets={@targets} active={@tab} orientation={:vertical} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaFloatingIndicator
              targets={[ %{label: "Day", value: :day}, %{label: "Week", value: :week}, %{label: "Archived", value: :archived, disabled: true} ]}
              active={@tab}
              orientation={:vertical}
              on_change={:tab}
            />
          </Column>
          """
        end
      }
    ]
  end

  # ── The examples ───────────────────────────────────────────────────────────
  #
  # Each one owns its assigns and its id. Sharing either would mean a gesture on
  # one moved the other, and no test (or reader) could say which it had touched.

  defp drag_example(assigns) do
    window = floating_window(drag_window(assigns), [drag_body(assigns)])

    ~MOB"""
    <Column fill_width={true}>
      {stage_box(window)}
      <Spacer size={10} />
      <Row fill_width={true} align={:center}>
        {readout("win", assigns.drag_pos)}
        <Spacer weight={1} />
        {button("Reset", :reset, "win-reset")}
      </Row>
    </Column>
    """
  end

  defp nudge_example(assigns) do
    window = floating_window(step_window(assigns), [nudge_body(assigns)])

    ~MOB"""
    <Column fill_width={true}>
      {stage_box(window)}
      <Spacer size={10} />
      <Row fill_width={true} align={:center}>
        {readout("step", assigns.step_pos)}
        <Spacer weight={1} />
        {button("Reset", :step_reset, "step-reset")}
      </Row>
    </Column>
    """
  end

  defp closable_example(assigns) do
    window =
      if assigns.open? do
        floating_window(
          [
            x: 10,
            y: 10,
            width: 220,
            height: 130,
            label: "Console",
            on_close: :close,
            id: "closable"
          ],
          [ping_body(assigns)]
        )
      end

    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} height={160} background={:surface_raised} corner_radius={:radius_md}>
        {window}
      </Box>
      <Spacer size={10} />
      <Row fill_width={true} align={:center}>
        <Text
          text={"Pings: #{assigns.pings}"}
          text_size={:sm}
          text_color={:muted}
          max_lines={1}
          id={"closable-pings-#{assigns.pings}"}
        />
        <Spacer weight={1} />
        {button("Reopen", :open, "closable-open")}
      </Row>
    </Column>
    """
  end

  defp custom_example do
    bar = ~MOB"""
    <Row align={:center}>
      <Box width={8} height={8} background={:primary} corner_radius={:radius_pill} />
      <Spacer size={8} />
      <Text text="build.log" text_size={:sm} text_color={:on_surface} max_lines={1} />
    </Row>
    """

    body = ~MOB"""
    <Text text="No on_move, so no arrows and no drag surface." text_size={:sm} text_color={:muted} />
    """

    window =
      floating_window([x: 8, y: 10, width: 240, height: 110, handle: bar, id: "custom"], [body])

    ~MOB"""
    <Box fill_width={true} height={140} background={:surface_raised} corner_radius={:radius_md}>
      {window}
    </Box>
    """
  end

  # ── The props each example renders AND folds with ──────────────────────────
  #
  # One function per example, read by `render` and by the handlers below. They
  # have to agree: `drag/3` decides whether a touch landed on the title bar by
  # arithmetic, so folding against a width the window was not drawn at is a
  # window that ignores the grab, or stops where nothing looks like an edge.

  defp drag_window(assigns) do
    {x, y} = assigns.drag_pos

    [
      x: x,
      y: y,
      width: 160,
      height: 100,
      bounds: @stage,
      label: "Inspector",
      dragging: assigns.grab != nil,
      show_nudges: false,
      on_move: :move,
      id: "win"
    ]
  end

  defp step_window(assigns) do
    {x, y} = assigns.step_pos

    [
      x: x,
      y: y,
      width: 200,
      height: 140,
      bounds: @stage,
      step: 20,
      label: "Layers",
      dragging: assigns.step_grab != nil,
      on_move: :step_move,
      id: "step"
    ]
  end

  # ── Pieces ─────────────────────────────────────────────────────────────────

  defp stage_box(window) do
    {w, h} = @stage

    ~MOB"""
    <Box width={w} height={h} background={:surface_raised} corner_radius={:radius_md}>
      {window}
    </Box>
    """
  end

  defp drag_body(assigns) do
    {x, y} = assigns.drag_pos

    ~MOB"""
    <Text
      text={"x #{round(x)} · y #{round(y)}"}
      text_size={:sm}
      text_color={:on_surface}
      max_lines={1}
    />
    """
  end

  defp nudge_body(assigns) do
    {x, y} = assigns.step_pos

    ~MOB"""
    <Column fill_width={true}>
      <Text text="Tap an arrow. It stops at the stage edge." text_size={:sm} text_color={:muted} />
      <Spacer size={6} />
      <Text
        text={"x #{round(x)} · y #{round(y)}"}
        text_size={:sm}
        text_color={:on_surface}
        max_lines={1}
      />
    </Column>
    """
  end

  defp ping_body(assigns) do
    ~MOB"""
    <Column fill_width={true}>
      <Text text="This body still takes taps." text_size={:sm} text_color={:muted} />
      <Spacer size={8} />
      {button("Ping (#{assigns.pings})", :ping, "closable-ping")}
    </Column>
    """
  end

  # The position goes in the test tag as well as in the text. A device test can
  # read neither an offset nor a colour, and every example on this page renders
  # into one scrolling page — so a page-wide text query is answered by whichever
  # example happens to contain the string.
  defp readout(id, {x, y}) do
    ~MOB"""
    <Text
      text={"#{id}: #{round(x)}, #{round(y)}"}
      text_size={:sm}
      text_color={:muted}
      max_lines={1}
      id={"#{id}-pos-#{round(x)}-#{round(y)}"}
    />
    """
  end

  # A Box with neither width nor fill_width FILLS its parent, so this one is
  # sized — otherwise "Reset" is a full-width bar.
  defp button(label, tag, id) do
    ~MOB"""
    <Box
      width={104}
      background={:surface}
      corner_radius={:radius_sm}
      padding={:space_sm}
      align={:center}
      border_color={:border}
      border_width={1}
      on_tap={{self(), tag}}
      id={id}
    >
      <Text text={label} text_size={:sm} text_color={:on_surface} max_lines={1} />
    </Box>
    """
  end

  @impl true
  def props do
    [
      %{
        name: "x / y",
        type: "number",
        default: "0",
        description: "Position inside the stage, applied as offset_x/offset_y."
      },
      %{
        name: "width / height",
        type: "number",
        default: "260 / 180",
        description: "A fixed rectangle — the drag surface's geometry is arithmetic."
      },
      %{
        name: "bounds",
        type: "{w, h}",
        default: "nil",
        description:
          "The stage in dp. Sizes the canvas and clamps the position. No bounds, no drag."
      },
      %{name: "step", type: "number", default: "20", description: "How far one nudge moves."},
      %{
        name: "label / handle",
        type: "string · node",
        default: "nil",
        description: "The title bar's content. handle wins; both are decoration under the canvas."
      },
      %{
        name: "dragging",
        type: "boolean",
        default: "false",
        description: "The web's data-dragging: tints the strip and lands in its test tag."
      },
      %{
        name: "show_nudges",
        type: "boolean",
        default: "true",
        description: "The arrow row. Only when on_move is set — an unwired arrow does nothing."
      },
      %{
        name: "on_move",
        type: "event tag",
        default: "—",
        description: "{:drag, tag, payload} from the bar, {:tap, {tag, :up}} from an arrow."
      },
      %{
        name: "on_close",
        type: "event tag",
        default: "—",
        description: "{:tap, tag} on the ✕ — the one control in the bar that is not a drag."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description:
          "Test tags: <id>-window, -handle(-dragging), -drag, -body, -close, -nudge-up."
      },
      %{
        name: "drag/3 · nudge/2",
        type: "helpers",
        default: "—",
        description: "The two folds. Both read the window's own props; :up subtracts."
      },
      %{
        name: "Indicator: targets / active",
        type: "list · value",
        default: "[] · nil",
        description: "Exactly one is highlighted."
      },
      %{
        name: "Indicator: orientation / color",
        type: "—",
        default: ":horizontal · :surface_raised",
        description: "Row or stack; the highlight."
      },
      %{
        name: "Indicator: active?/2",
        type: "helper",
        default: "—",
        description: "The component's whole semantics."
      }
    ]
  end

  @impl true
  def handle({:step_move, direction}, socket) do
    moved = MishkaFloatingWindow.nudge(step_window(socket.assigns), direction)

    Mob.Socket.assign(socket, :step_pos, moved)
  end

  def handle(:reset, socket) do
    socket
    |> Mob.Socket.assign(:drag_pos, @home)
    |> Mob.Socket.assign(:grab, nil)
  end

  def handle(:step_reset, socket) do
    socket
    |> Mob.Socket.assign(:step_pos, {0, 0})
    |> Mob.Socket.assign(:step_grab, nil)
  end

  def handle(:close, socket), do: Mob.Socket.assign(socket, :open?, false)

  # Reopening clears the counter — a fresh console, and a known number for the
  # e2e to count up from, since the BEAM outlives the Activity.
  def handle(:open, socket) do
    socket
    |> Mob.Socket.assign(:open?, true)
    |> Mob.Socket.assign(:pings, 0)
  end

  def handle(:ping, socket), do: Mob.Socket.assign(socket, :pings, socket.assigns.pings + 1)
  def handle({:tab, value}, socket), do: Mob.Socket.assign(socket, :tab, value)
  def handle(_tag, socket), do: socket

  # Every drag arrives as {:drag, tag, payload}; ComponentScreen routes it to
  # handle_change/3 the same way it routes {:change, tag, value}.
  @impl true
  def handle_change(:move, payload, socket) do
    {position, grab} =
      MishkaFloatingWindow.drag(payload, socket.assigns.grab, drag_window(socket.assigns))

    socket
    |> Mob.Socket.assign(:drag_pos, position)
    |> Mob.Socket.assign(:grab, grab)
  end

  # Its own grab, not :grab — two windows sharing one anchor would each start
  # their next drag from wherever the other left off.
  def handle_change(:step_move, payload, socket) do
    {position, grab} =
      MishkaFloatingWindow.drag(payload, socket.assigns.step_grab, step_window(socket.assigns))

    socket
    |> Mob.Socket.assign(:step_pos, position)
    |> Mob.Socket.assign(:step_grab, grab)
  end

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} height={64} background={:surface_raised} corner_radius={:radius_sm}>
      <Box
        offset_x={16}
        offset_y={10}
        width={72}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      >
        <Column fill_width={true}>
          <Box fill_width={true} height={12} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={6} />
          <Box width={40} height={6} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={6} />
        </Column>
      </Box>
    </Box>
    """
  end
end
