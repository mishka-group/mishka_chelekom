defmodule MishkaMob.Showcase.Components.Toggle do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToggle`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toggle,
      name: "Toggle",
      category: "Forms",
      order: 7,
      description: "A button that stays pressed, as in a formatting toolbar."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tg_bold, true)
    |> Mob.Socket.assign(:tg_italic, false)
    |> Mob.Socket.assign(:tg_under, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A toolbar",
        description: "Each button holds its own pressed state.",
        code: ~S"""
        <MishkaToggle label="B" pressed={@bold?} on_change={:bold} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaToggle label=" B " pressed={@tg_bold} on_change={:tg_bold} />
              <Spacer size={8} />
              <MishkaToggle label=" I " pressed={@tg_italic} on_change={:tg_italic} />
              <Spacer size={8} />
              <MishkaToggle label=" U " pressed={@tg_under} on_change={:tg_under} />
            </Row>
            <Spacer size={12} />
            <Text text={summary(@tg_bold, @tg_italic, @tg_under)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Not a switch, not a chip",
        description: "A switch is a setting, a chip is a filter, a toggle is a pressed button.",
        code: ~S"""
        <MishkaToggle label="Pressed" pressed={true} />
        <MishkaToggle label="Not pressed" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaToggle label="Pressed" pressed={true} />
            <Spacer size={8} />
            <MishkaToggle label="Not pressed" />
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert, pressed or not.",
        code: ~S"""
        <MishkaToggle label="Locked" pressed={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaToggle label="Locked on" pressed={true} disabled={true} />
            <Spacer size={8} />
            <MishkaToggle label="Locked off" disabled={true} />
          </Row>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "color fills it when pressed.",
        code: ~S"""
        <MishkaToggle
          label="Violet"
          pressed={true}
          color={0xFF7C3AED}
          text_color={0xFFFFFFFF}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaToggle label="Violet" pressed={true} color={0xFF7C3AED} text_color={0xFFFFFFFF} />
            <Spacer size={8} />
            <MishkaToggle label="Default" pressed={true} />
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
        name: "label",
        type: "string",
        default: "nil",
        description: "Button text. Children override it."
      },
      %{
        name: "pressed",
        type: "boolean",
        default: "false",
        description: "Whether it reads as pushed in. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler and mutes it."
      },
      %{name: "on_change", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Fill when pressed."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "Label colour when pressed."
      }
    ]
  end

  @impl true
  def handle(:tg_bold, socket), do: flip(socket, :tg_bold)
  def handle(:tg_italic, socket), do: flip(socket, :tg_italic)
  def handle(:tg_under, socket), do: flip(socket, :tg_under)
  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  defp summary(b, i, u) do
    on =
      [{b, "bold"}, {i, "italic"}, {u, "underline"}]
      |> Enum.filter(&elem(&1, 0))
      |> Enum.map_join(", ", &elem(&1, 1))

    if on == "", do: "Nothing pressed", else: "Pressed: " <> on
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box width={30} height={26} background={:primary} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box width={30} height={26} background={:surface_raised} corner_radius={:radius_md} />
      <Spacer size={8} />
      <Box width={30} height={26} background={:surface_raised} corner_radius={:radius_md} />
    </Row>
    """
  end
end
