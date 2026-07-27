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

  @bounds {120, 90}

  @impl true
  def entry do
    %{
      slug: :floating_window,
      name: "Floating Window",
      category: "Overlay",
      order: 7,
      description: "A positioned panel with nudge controls, plus a floating indicator."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pos, {20, 10})
    |> Mob.Socket.assign(:tab, :day)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Positioned, not dragged",
        description:
          "Mob delivers no pointer coordinates, so the keyboard alternative WCAG asks for " <>
            "becomes the primary interaction. nudge/4 clamps it inside the stage.",
        code: ~S"""
        <MishkaFloatingWindow
          x={@x}
          y={@y}
          label="Inspector"
          on_move={:move}
        >{[body()]}</MishkaFloatingWindow>

        def handle({:move, dir}, socket),
          do: assign(socket, :pos, MishkaFloatingWindow.nudge(socket.assigns.pos, dir, 20, {120, 90}))
        """,
        render: fn assigns ->
          ~MOB"""
          <Box fill_width={true} height={230} background={:surface_raised} corner_radius={:radius_md}>
            {window(@pos)}
          </Box>
          """
        end
      },
      %Example{
        title: "Floating indicator",
        description:
          "The web version measures the active target and slides a box over it. Here the " <>
            "active target draws its own highlight — no measurement needed, and still exactly one.",
        code: ~S"""
        <MishkaFloatingIndicator targets={@tabs} active={@tab} on_change={:pick} />
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

  defp window({x, y}) do
    floating_window(
      [x: x, y: y, label: "Inspector", width: 220, on_move: :move, on_close: :close],
      [
        ~MOB"""
        <Column fill_width={true}>
          <Text text="Tap the arrows to move me." text_size={:sm} text_color={:muted} />
          <Spacer size={8} />
          <Text text={"x #{x}  ·  y #{y}"} text_size={:sm} text_color={:on_surface} />
        </Column>
        """
      ]
    )
  end

  @impl true
  def props do
    [
      %{
        name: "x / y",
        type: "number",
        default: "0",
        description: "Position inside the parent, via offset_x/offset_y."
      },
      %{name: "width", type: "number", default: "260", description: "Window width."},
      %{name: "label", type: "string", default: "nil", description: "Title in the handle."},
      %{
        name: "step / bounds",
        type: "number · {w, h}",
        default: "20 · nil",
        description: "How far a nudge moves, and where it stops."
      },
      %{
        name: "show_nudges",
        type: "boolean",
        default: "true",
        description: "The arrow controls."
      },
      %{
        name: "on_move / on_close",
        type: "event tags",
        default: "—",
        description: "{:tap, {tag, :up}} and the ✕."
      },
      %{
        name: "nudge/4",
        type: "helper",
        default: "—",
        description: "New position, clamped. :up subtracts — y grows downwards."
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
  def handle({:move, direction}, socket) do
    moved = MishkaFloatingWindow.nudge(socket.assigns.pos, direction, 20, @bounds)

    Mob.Socket.assign(socket, :pos, moved)
  end

  def handle(:close, socket), do: Mob.Socket.assign(socket, :pos, {0, 0})
  def handle({:tab, value}, socket), do: Mob.Socket.assign(socket, :tab, value)
  def handle(_tag, socket), do: socket

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
