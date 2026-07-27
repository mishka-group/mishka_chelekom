defmodule MishkaMob.Showcase.Components.Radio do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaRadio`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaRadio, only: [radio: 1]

  alias MishkaMob.Showcase.Example

  @plans [{:free, "Free"}, {:pro, "Pro"}, {:team, "Team"}]

  @impl true
  def entry do
    %{
      slug: :radio,
      name: "Radio",
      category: "Forms",
      order: 4,
      description: "One option in a mutually exclusive set."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :rd_plan, :pro)

  @impl true
  def examples do
    [
      %Example{
        title: "Pick one",
        description: "Exclusivity is one line in the handler — assign the tapped id.",
        code: ~S"""
        <MishkaRadio label="Pro" checked={@plan == :pro} on_select={{:plan, :pro}} />

        def handle_info({:tap, {:plan, id}}, socket) do
          {:noreply, assign(socket, :plan, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {plan_radios(@rd_plan)}
            <Spacer size={12} />
            <Text text={"Selected: " <> to_string(@rd_plan)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Circle, not a tick",
        description: "The shape carries the meaning: pick one, versus a checkbox's pick any.",
        code: ~S"""
        <MishkaRadio label="Selected" checked={true} />
        <MishkaRadio label="Not selected" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadio label="Selected" checked={true} />
            <Spacer size={12} />
            <MishkaRadio label="Not selected" />
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert, selected or not.",
        code: ~S"""
        <MishkaRadio label="Locked" checked={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadio label="Locked on" checked={true} disabled={true} />
            <Spacer size={12} />
            <MishkaRadio label="Locked off" disabled={true} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and size",
        description: "The dot scales with size, and the circle stays round at any size.",
        code: ~S"""
        <MishkaRadio label="Violet" checked={true} color={0xFF7C3AED} size={28} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadio label="Large violet" checked={true} color={0xFF7C3AED} size={28} />
            <Spacer size={12} />
            <MishkaRadio label="Small" checked={true} size={16} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "label", type: "string", default: "nil", description: "Text beside the dot."},
      %{
        name: "checked",
        type: "boolean",
        default: "false",
        description: "Whether this option is selected. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler and mutes the row."
      },
      %{name: "on_select", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Ring and dot when selected."
      },
      %{name: "size", type: "number", default: "22", description: "Outer circle diameter."}
    ]
  end

  @impl true
  def handle({:rd_plan, id}, socket), do: Mob.Socket.assign(socket, :rd_plan, id)
  def handle(_tag, socket), do: socket

  defp plan_radios(selected) do
    @plans
    |> Enum.map(fn {id, label} ->
      radio(label: label, checked: id == selected, on_select: {:rd_plan, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 12}, children: []})
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={16} height={16} corner_radius={8} background={:primary} />
        <Spacer size={8} />
        <Box width={48} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={16} height={16} corner_radius={8} background={:surface_raised} />
        <Spacer size={8} />
        <Box width={38} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={16} height={16} corner_radius={8} background={:surface_raised} />
        <Spacer size={8} />
        <Box width={56} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
