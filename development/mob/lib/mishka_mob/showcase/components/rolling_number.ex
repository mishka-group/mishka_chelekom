defmodule MishkaMob.Showcase.Components.RollingNumber do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaRollingNumber`.

  The number really counts: the buttons hand `steps/3` to the screen, which walks
  the sequence on a timer. That round trip is the component's whole story, so the
  page drives it rather than describing it.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaRollingNumber
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :rolling_number,
      name: "Rolling Number",
      category: "Data display",
      order: 7,
      description: "A number that counts to its value, eased by the screen."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :rn_value, 0)

  @impl true
  def examples do
    [
      %Example{
        title: "Counting up",
        description:
          "The component renders whatever number it is given. steps/3 produces " <>
            "the eased sequence and the screen walks it — a component cannot " <>
            "animate itself, and one that started a timer would start a fresh " <>
            "one every render.",
        code: ~S"""
        <MishkaRollingNumber value={@count} />

        # kick it off
        def handle(:roll, socket) do
          [next | rest] = MishkaRollingNumber.steps(socket.assigns.count, 1_284, 18)
          if rest != [], do: Process.send_after(self(), {:tap, {:step, rest}}, 24)
          Mob.Socket.assign(socket, :count, next)
        end

        # and walk it
        def handle({:step, [next | rest]}, socket) do
          if rest != [], do: Process.send_after(self(), {:tap, {:step, rest}}, 24)
          Mob.Socket.assign(socket, :count, next)
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box fill_width={true} align={:center}>
              <MishkaRollingNumber value={@rn_value} />
            </Box>
            <Spacer size={12} />
            <Row fill_width={true}>
              <Button
                text="Roll to 1,284"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :rn_roll}}
              />
              <Spacer size={8} />
              <Button
                text="Reset"
                background={:surface_raised}
                text_color={:on_surface}
                padding={:space_sm}
                weight={1}
                on_tap={{self(), :rn_reset}}
              />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Counting down",
        description: "steps/3 counts down as happily as up, and lands exactly on the target.",
        code: ~S"""
        MishkaRollingNumber.steps(500, 10, 7) |> List.last()
        #=> 10
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Button
              text="Roll down to 42"
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              weight={1}
              on_tap={{self(), :rn_down}}
            />
          </Row>
          """
        end
      },
      %Example{
        title: "Grouping",
        description:
          "separator groups thousands — a comma by default, a space for the " <>
            "European style, and \"\" turns grouping off. Negatives keep their sign.",
        code: ~S"""
        <MishkaRollingNumber value={1234567} />
        <MishkaRollingNumber value={1234567} separator=" " />
        <MishkaRollingNumber value={1234567} separator="" />
        <MishkaRollingNumber value={-98765} color={0xFFDC2626} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRollingNumber value={1_234_567} text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={1_234_567} separator=" " text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={1_234_567} separator="" text_size={:xl} />
            <Spacer size={8} />
            <MishkaRollingNumber value={-98_765} text_size={:xl} color={0xFFDC2626} />
          </Column>
          """
        end
      },
      %Example{
        title: "Size and colour",
        description: "It is one Text node, so it takes the same size and colour tokens.",
        code: ~S"""
        <MishkaRollingNumber value={1234} text_size={:"4xl"} color={:primary} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRollingNumber value={1_234} text_size={:"4xl"} color={:primary} />
            <Spacer size={8} />
            <MishkaRollingNumber value={1_234} text_size={:base} color={:muted} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "integer", default: "0", description: "The number shown."},
      %{
        name: "separator",
        type: "string",
        default: "\",\"",
        description: "Thousands separator. \"\" disables grouping."
      },
      %{
        name: "text_size",
        type: "size token",
        default: ":\"2xl\"",
        description: "Number size."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Number colour."
      },
      %{
        name: "steps/3",
        type: "helper",
        default: "—",
        description: "from, to, count → eased intermediate values for the screen to walk."
      }
    ]
  end

  @impl true
  def handle(:rn_reset, socket), do: Mob.Socket.assign(socket, :rn_value, 0)
  def handle(:rn_roll, socket), do: roll(socket, 1_284)
  def handle(:rn_down, socket), do: roll(socket, 42)

  def handle({:rn_step, [next | rest]}, socket) do
    if rest != [], do: Process.send_after(self(), {:tap, {:rn_step, rest}}, 24)
    Mob.Socket.assign(socket, :rn_value, next)
  end

  def handle(_tag, socket), do: socket

  defp roll(socket, target) do
    [next | rest] = MishkaRollingNumber.steps(socket.assigns.rn_value, target, 18)
    if rest != [], do: Process.send_after(self(), {:tap, {:rn_step, rest}}, 24)
    Mob.Socket.assign(socket, :rn_value, next)
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} align={:center}>
        <MishkaRollingNumber value={1_284} text_size={:"2xl"} color={:primary} />
      </Box>
      <Spacer size={8} />
      <Box fill_width={true} align={:center}>
        <MishkaRollingNumber value={1_234_567} text_size={:sm} color={:muted} />
      </Box>
    </Column>
    """
  end
end
