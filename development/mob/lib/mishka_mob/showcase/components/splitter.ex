defmodule MishkaMob.Showcase.Components.Splitter do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSplitter` and
  `MishkaMob.Components.MishkaOverflowList`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaOverflowList, only: [overflow_list: 2]
  import MishkaMob.Components.MishkaPill, only: [pill: 1]
  import MishkaMob.Components.MishkaSplitter, only: [splitter: 2]

  alias MishkaMob.Showcase.Example

  @tags ~w(elixir beam otp nerves phoenix liveview mob)

  @impl true
  def entry do
    %{
      slug: :splitter,
      name: "Splitter",
      category: "Layout",
      order: 6,
      description: "Two panes sharing an extent — plus an overflow list."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:split, 55)
    |> Mob.Socket.assign(:vsplit, 40)
    |> Mob.Socket.assign(:visible, 3)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Side by side",
        description:
          "Panes are sized in dp from the percentage, because weight is Compose-only and " <>
            "would collapse on iOS.",
        code: ~S"""
        {splitter([value: @split, extent: 320, on_change: :split], [left(), right()])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {splitter(
               [value: @split, extent: 300, on_change: :split],
               [pane("Editor", :primary), pane("Preview", :muted)]
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Stacked",
        description: "The same control, dividing height instead of width.",
        code: ~S"""
        {splitter([value: @split, orientation: :vertical, extent: 220], [top(), bottom()])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {splitter(
               [value: @vsplit, orientation: :vertical, extent: 200, on_change: :vsplit],
               [pane("Output", :primary), pane("Console", :muted)]
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Overflow list",
        description:
          "How many fit is declared rather than measured — Mob reports no geometry back " <>
            "to render/1.",
        code: ~S"""
        {overflow_list([visible: 3, on_counter: :show_all], tag_pills())}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {overflow_list([visible: @visible, on_counter: :more], tag_pills())}
            <Spacer size={10} />
            <Text text="Tap +N to reveal one more." text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      }
    ]
  end

  defp pane(label, ink) do
    ~MOB"""
    <Column fill_width={true} padding={:space_md}>
      <Text text={label} text_size={:sm} text_color={ink} weight={:semibold} />
      <Spacer size={6} />
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
      <Spacer size={5} />
      <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end

  defp tag_pills, do: Enum.map(@tags, &pill(label: &1))

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
        description: "Total dp to divide — there is no weight that works on both platforms."
      },
      %{
        name: "min / max",
        type: "0–100",
        default: "10 / 90",
        description: "Bounds; a pane can never vanish."
      },
      %{
        name: "show_control / disabled",
        type: "boolean",
        default: "true / false",
        description: "The resize slider."
      },
      %{
        name: "sizes/1 · split/1",
        type: "helpers",
        default: "—",
        description: "The pane arithmetic, without rendering."
      },
      %{
        name: "OverflowList: visible / min_visible",
        type: "integer",
        default: "3 / 1",
        description: "How many show; min_visible wins."
      },
      %{
        name: "OverflowList: counter_text / on_counter",
        type: "fun · event tag",
        default: "+N",
        description: "The counter's label, and its tap."
      },
      %{
        name: "OverflowList: split/2",
        type: "helper",
        default: "—",
        description: "{shown, hidden} — where a measured count would plug in."
      }
    ]
  end

  @impl true
  def handle(:more, socket),
    do: Mob.Socket.assign(socket, :visible, min(socket.assigns.visible + 1, length(@tags)))

  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:split, value, socket), do: Mob.Socket.assign(socket, :split, value)
  def handle_change(:vsplit, value, socket), do: Mob.Socket.assign(socket, :vsplit, value)
  def handle_change(_tag, _value, socket), do: socket

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
