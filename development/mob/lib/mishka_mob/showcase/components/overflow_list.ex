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

  alias MishkaMob.Showcase.Example

  @tags ~w(Design Phoenix Elixir LiveView Tailwind Headless Accessibility)

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
    |> Mob.Socket.assign(:visible, 4)
    |> Mob.Socket.assign(:expanded, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Four fit, three do not",
        description: "The same shape the web version lands on: items, then +N for the remainder.",
        code: ~S"""
        <MishkaOverflowList visible={4} id="langs">{tag_pills()}</MishkaOverflowList>

        # split/2 is the whole policy, and it is public — a screen can ask what
        # would be hidden without rendering anything.
        {shown, hidden} = MishkaOverflowList.split(tags, visible: 4)
        length(hidden)
        #=> 3
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOverflowList visible={4} id="langs">
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
