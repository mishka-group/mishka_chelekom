defmodule MishkaMob.Showcase.Components.RadioGroup do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaRadioGroup`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaRadioGroup, only: [option: 2, option: 3]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :radio_group,
      name: "Radio Group",
      category: "Forms",
      order: 5,
      description: "A labelled set of mutually exclusive options."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:rg_plan, :pro)
    |> Mob.Socket.assign(:rg_size, :m)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A labelled group",
        description: "One handler serves every option — the tag carries the id.",
        code: ~S"""
        <MishkaRadioGroup
          label="Plan"
          value={@plan}
          on_change={:plan}
        >{[
          option(:free, "Free"),
          option(:pro, "Pro"),
          option(:team, "Team")
        ]}</MishkaRadioGroup>

        # Every option reports the SAME tag widened with its own id — that is what
        # replaces the browser's shared `name`, and why one clause is enough.
        def handle_info({:tap, {:plan, id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :plan, MishkaRadioGroup.select(socket.assigns.plan, id))}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup label="PLAN" value={@rg_plan} on_change={:rg_plan} id="rg-plan">
              {[
              option(:free, "Free"),
              option(:pro, "Pro"),
              option(:team, "Team — 5 seats")
            ]}
            </MishkaRadioGroup>
            <Spacer size={12} />
            <Text text={"Selected: " <> to_string(@rg_plan)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Horizontal",
        description: "orientation: :horizontal lays the options in a row.",
        code: ~S"""
        <MishkaRadioGroup
          value={@size}
          orientation={:horizontal}
          on_change={:size}
        >{opts}</MishkaRadioGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup
              label="SIZE"
              value={@rg_size}
              orientation={:horizontal}
              space={18}
              on_change={:rg_size}
              id="rg-size"
            >
              {[
              option(:s, "S"),
              option(:m, "M"),
              option(:l, "L")
            ]}
            </MishkaRadioGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled option and group",
        description: "An option can be disabled on its own, or the whole group at once.",
        code: ~S"""
        option(:team, "Team", disabled: true)
        <MishkaRadioGroup disabled={true} value={@plan}>{opts}</MishkaRadioGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup label="ONE OPTION OFF" value={@rg_plan} on_change={:rg_plan}>
              {[
              option(:free, "Free"),
              option(:team, "Team (unavailable)", disabled: true)
            ]}
            </MishkaRadioGroup>
            <Spacer size={16} />
            <MishkaRadioGroup label="WHOLE GROUP OFF" value={@rg_plan} disabled={true} id="rg-off">
              {[
              option(:free, "Free (off)"),
              option(:pro, "Pro (off)")
            ]}
            </MishkaRadioGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and size",
        description: "Passed through to every option.",
        code: ~S"""
        <MishkaRadioGroup value={@plan} color={0xFF7C3AED} size={26}>{opts}</MishkaRadioGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup value={@rg_plan} color={0xFF7C3AED} size={26} on_change={:rg_plan}>
              {[
              option(:free, "Free"),
              option(:pro, "Pro")
            ]}
            </MishkaRadioGroup>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "option id", default: "nil", description: "The selected option."},
      %{name: "label", type: "string", default: "nil", description: "Group heading."},
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every option."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, option_id}} — one handler for the group."
      },
      %{
        name: "orientation",
        type: ":vertical · :horizontal",
        default: ":vertical",
        description: "Layout axis."
      },
      %{name: "space", type: "number", default: "12", description: "Gap between options."},
      %{
        name: "color / size",
        type: "see Radio",
        default: "—",
        description: "Passed to every option."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Prefix for each option's test tag: <id>-<option>-selected."
      },
      %{
        name: "select/2",
        type: "helper",
        default: "—",
        description: "The next value for a tap. Re-tapping the selection keeps it."
      }
    ]
  end

  @impl true
  def handle({:rg_plan, id}, socket), do: Mob.Socket.assign(socket, :rg_plan, id)
  def handle({:rg_size, id}, socket), do: Mob.Socket.assign(socket, :rg_size, id)
  def handle(_tag, socket), do: socket

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box width={30} height={7} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={14} height={14} corner_radius={7} background={:primary} />
        <Spacer size={8} />
        <Box width={44} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={9} />
      <Row fill_width={true}>
        <Box width={14} height={14} corner_radius={7} background={:surface_raised} />
        <Spacer size={8} />
        <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
