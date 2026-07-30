defmodule MishkaMob.Showcase.Components.Switch do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSwitch`.

  The first live-input component in the gallery: its examples round-trip through
  `{:change, tag, value}`, which `MishkaMob.Showcase.ComponentScreen` forwards to
  `handle_change/3`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :switch,
      name: "Switch",
      category: "Forms",
      order: 0,
      description: "An on/off control, mapped onto Mob's native Toggle widget."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sw_wifi, true)
    |> Mob.Socket.assign(:sw_bluetooth, false)
    |> Mob.Socket.assign(:sw_colored, true)
    |> Mob.Socket.assign(:sw_airplane, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "With a label",
        description: "The label leads; the switch sits at the trailing edge.",
        code: ~S"""
        <MishkaSwitch label="Wi-Fi" checked={@wifi} on_change={:wifi_changed} />

        def handle_info({:change, :wifi_changed, on?}, socket) do
          {:noreply, assign(socket, :wifi, on?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSwitch label="Wi-Fi" checked={@sw_wifi} on_change={:wifi} />
            <Spacer size={4} />
            <MishkaSwitch label="Bluetooth" checked={@sw_bluetooth} on_change={:bluetooth} />
            <Spacer size={12} />
            <MishkaSeparator />
            <Spacer size={10} />
            <Text
              text={"Wi-Fi is " <> onoff(@sw_wifi) <> ", Bluetooth is " <> onoff(@sw_bluetooth)}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Custom colour",
        description:
          "color tints the thumb and track_color the track — separately, so " <>
            "you can see which is which. Android only: iOS paints the system accent.",
        code: ~S"""
        <MishkaSwitch
          label="Violet"
          checked={@on}
          color={0xFFFDE68A}
          track_color={0xFF7C3AED}
          on_change={:tint}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSwitch
              label="Brand violet"
              checked={@sw_colored}
              color={0xFFFDE68A}
              track_color={0xFF7C3AED}
              on_change={:colored}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "No handler is wired, so the control cannot move.",
        code: ~S"""
        <MishkaSwitch label="Locked on" checked={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSwitch label="Locked on" checked={true} disabled={true} />
            <Spacer size={4} />
            <MishkaSwitch label="Locked off" checked={false} disabled={true} />
          </Column>
          """
        end
      },
      %Example{
        title: "Without a label",
        description:
          "The built-in label always leads and the switch always trails. Omit it " <>
            "and the switch is just a node — put it first, or anywhere else the " <>
            "row wants it.",
        code: ~S"""
        # Leading switch, which the label prop cannot produce:
        <Row>
          <MishkaSwitch checked={@on} on_change={:airplane} />
          <Text text="Airplane mode" />
        </Row>

        def handle_change(:airplane, on?, socket),
          do: Mob.Socket.assign(socket, :airplane, on?)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true} align={:center}>
              <MishkaSwitch checked={@sw_airplane} on_change={:airplane} />
              <Spacer size={12} />
              <Text text="Airplane mode" text_size={:lg} text_color={:on_surface} />
            </Row>
            <Spacer size={10} />
            <Text
              text="The switch leads here. With label= it can only ever trail, which is the whole difference."
              text_size={:sm}
              text_color={:muted}
            />
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
        name: "checked",
        type: "boolean",
        default: "false",
        description: "The on state. Toggle is controlled — the screen owns it."
      },
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Leading label; the switch sits at the trailing edge."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:change, tag, boolean}. Omit for a read-only switch."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "platform",
        description: "Thumb colour when on. Android only — iOS paints the system accent."
      },
      %{
        name: "track_color",
        type: "color / ARGB",
        default: "platform",
        description: "Track colour when on. Android only, same as color."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler, so the control cannot move."
      }
    ]
  end

  @impl true
  def handle_change(:wifi, on?, socket), do: Mob.Socket.assign(socket, :sw_wifi, on?)
  def handle_change(:bluetooth, on?, socket), do: Mob.Socket.assign(socket, :sw_bluetooth, on?)
  def handle_change(:colored, on?, socket), do: Mob.Socket.assign(socket, :sw_colored, on?)
  def handle_change(:airplane, on?, socket), do: Mob.Socket.assign(socket, :sw_airplane, on?)
  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box
          fill_width={false}
          width={44}
          height={10}
          background={:muted}
          corner_radius={:radius_sm}
        />
        <Spacer weight={1} />
        <Box width={34} height={18} background={:primary} corner_radius={:radius_pill} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box
          fill_width={false}
          width={34}
          height={10}
          background={:muted}
          corner_radius={:radius_sm}
        />
        <Spacer weight={1} />
        <Box width={34} height={18} background={:surface_raised} corner_radius={:radius_pill} />
      </Row>
    </Column>
    """
  end

  defp onoff(true), do: "on"
  defp onoff(_), do: "off"
end
