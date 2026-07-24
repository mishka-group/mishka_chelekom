defmodule MishkaMob.Showcase.Components.ColorInput do
  @moduledoc "Gallery entry for `MishkaMob.Components.MishkaColorInput`."
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaColorInput, only: [color_input: 1]

  alias MishkaMob.Components.{Color, MishkaColorInput}
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :color_input,
      name: "Color Input",
      category: "Color",
      order: 5,
      description: "A hex field with a swatch, and a picker that opens beneath it."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:hex, "#3b82f6")
    |> Mob.Socket.assign(:open, false)
    |> Mob.Socket.assign(:ci_hue, 217)
    |> Mob.Socket.assign(:ci_sat, 76)
    |> Mob.Socket.assign(:ci_val, 96)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Type it or pick it",
        description:
          "A half-typed #3b82 is simply not committed — the picker waits rather than " <>
            "rewriting what you are in the middle of typing.",
        code: ~S"""
        {color_input(value: @hex, open: @open, on_change: :hex, on_toggle: :toggle,
                     hue: @hue, saturation: @sat, value_pct: @val)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {color_input(
               value: @hex, open: @open, label: "Brand colour",
               hue: @ci_hue, saturation: @ci_sat, value_pct: @ci_val,
               on_change: :hex, on_toggle: :toggle,
               on_hue: :ci_hue, on_saturation: :ci_sat, on_value: :ci_val
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted trigger, no handlers attached.",
        code: ~S"""
        {color_input(value: "#64748b", disabled: true)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {color_input(value: "#64748b", disabled: true)}
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
        type: "hex string",
        default: "\"#3b82f6\"",
        description: "The field's text."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the panel is shown."
      },
      %{name: "label", type: "string", default: "nil", description: "Caption above the control."},
      %{
        name: "hue / saturation / value_pct",
        type: "numbers",
        default: "derived from value",
        description: "Picker position; falls back to the field's colour."
      },
      %{name: "disabled", type: "boolean", default: "false", description: "Mutes and unwires."},
      %{
        name: "on_change / on_toggle",
        type: "event tags",
        default: "—",
        description: "Typing, and the ▾ trigger."
      },
      %{
        name: "commit/2",
        type: "helper",
        default: "—",
        description: "{:ok, hsv} once the text parses, :incomplete while it does not."
      }
    ]
  end

  @impl true
  def handle(:toggle, socket), do: Mob.Socket.assign(socket, :open, not socket.assigns.open)
  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:hex, text, socket) do
    socket = Mob.Socket.assign(socket, :hex, text)

    case MishkaColorInput.commit(text) do
      {:ok, {h, s, v}} ->
        socket
        |> Mob.Socket.assign(:ci_hue, h)
        |> Mob.Socket.assign(:ci_sat, s)
        |> Mob.Socket.assign(:ci_val, v)

      :incomplete ->
        socket
    end
  end

  # Moving the picker rewrites the field — that direction is unambiguous.
  def handle_change(:ci_hue, value, socket), do: sync(socket, :ci_hue, value)
  def handle_change(:ci_sat, value, socket), do: sync(socket, :ci_sat, value)
  def handle_change(:ci_val, value, socket), do: sync(socket, :ci_val, value)
  def handle_change(_tag, _value, socket), do: socket

  defp sync(socket, key, value) do
    socket = Mob.Socket.assign(socket, key, value)
    %{ci_hue: h, ci_sat: s, ci_val: v} = socket.assigns

    Mob.Socket.assign(socket, :hex, Color.hsv_to_hex(h, s, v))
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <Box width={24} height={24} background={0xFF3B82F6} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box
        fill_width={true}
        height={24}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
    </Row>
    """
  end
end
