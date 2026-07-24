defmodule MishkaMob.Showcase.Components.Switch do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSwitch`.

  The first live-input component in the gallery: its examples round-trip through
  `{:change, tag, value}`, which `MishkaMob.Showcase.ComponentScreen` forwards to
  `handle_change/3`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSwitch, only: [switch: 1]
  import MishkaMob.Components.MishkaSeparator, only: [separator: 0]

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
  end

  @impl true
  def examples do
    [
      %Example{
        title: "With a label",
        description: "The label leads; the switch sits at the trailing edge.",
        code: ~S"""
        {switch(label: "Wi-Fi", checked: @wifi, on_change: :wifi_changed)}

        def handle_info({:change, :wifi_changed, on?}, socket) do
          {:noreply, assign(socket, :wifi, on?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {switch(label: "Wi-Fi", checked: @sw_wifi, on_change: :wifi)}
            <Spacer size={4} />
            {switch(label: "Bluetooth", checked: @sw_bluetooth, on_change: :bluetooth)}
            <Spacer size={12} />
            {separator()}
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
        description: "Tint the thumb when the switch is on.",
        code: ~S"""
        {switch(label: "Violet", checked: @on, color: 0xFF7C3AED, on_change: :tint)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {switch(label: "Brand violet", checked: @sw_colored, color: 0xFF7C3AED, on_change: :colored)}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "No handler is wired, so the control cannot move.",
        code: ~S"""
        {switch(label: "Locked on", checked: true, disabled: true)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {switch(label: "Locked on", checked: true, disabled: true)}
            <Spacer size={4} />
            {switch(label: "Locked off", checked: false, disabled: true)}
          </Column>
          """
        end
      },
      %Example{
        title: "Without a label",
        description: "Omit the label to place the switch inside your own row.",
        code: ~S"""
        <Row>
          <Text text="Airplane mode" />
          {switch(checked: @on, on_change: :airplane)}
        </Row>
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Text text="Airplane mode" text_size={:lg} text_color={:on_surface} />
            <Spacer weight={1} />
            {switch(checked: @sw_bluetooth, on_change: :bluetooth)}
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
        description: "Thumb colour when on."
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
