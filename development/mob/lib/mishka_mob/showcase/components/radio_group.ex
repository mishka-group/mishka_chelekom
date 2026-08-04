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
    |> Mob.Socket.assign(:rg_tier, :growth)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A labelled group",
        description: "One handler serves every option — the tag carries the id.",
        code: ~S"""
        <MishkaRadioGroup label="Plan" value={@plan} on_change={:plan} id="plan">
          <MishkaRadioGroupOption id={:free} label="Free" />
          <MishkaRadioGroupOption id={:pro} label="Pro" />
          <MishkaRadioGroupOption id={:team} label="Team" />
        </MishkaRadioGroup>

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
              <MishkaRadioGroupOption id={:free} label="Free" />
              <MishkaRadioGroupOption id={:pro} label="Pro" />
              <MishkaRadioGroupOption id={:team} label="Team — 5 seats" />
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
        <MishkaRadioGroup value={@size} orientation={:horizontal} space={18} on_change={:size}>
          <MishkaRadioGroupOption id={:s} label="S" />
          <MishkaRadioGroupOption id={:m} label="M" />
          <MishkaRadioGroupOption id={:l} label="L" />
        </MishkaRadioGroup>
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
              <MishkaRadioGroupOption id={:s} label="S" />
              <MishkaRadioGroupOption id={:m} label="M" />
              <MishkaRadioGroupOption id={:l} label="L" />
            </MishkaRadioGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled option and group",
        description: "An option can be disabled on its own, or the whole group at once.",
        code: ~S"""
        <MishkaRadioGroup value={@plan} on_change={:plan}>
          <MishkaRadioGroupOption id={:free} label="Free" />
          <MishkaRadioGroupOption id={:team} label="Team" disabled={true} />
        </MishkaRadioGroup>

        <MishkaRadioGroup disabled={true} value={@plan} on_change={:plan}>
          <MishkaRadioGroupOption id={:free} label="Free" />
        </MishkaRadioGroup>
        """,
        # The OFF group below wires on_change even though nothing can ever fire
        # it: a disabled group with no handler is inert for the wrong reason, and
        # a test tapping it would only be observing the missing on_change —
        # deleting `disabled={true}` would leave that test green. With the handler
        # present, the cascade is the single thing standing between a tap and a
        # selection, which is what the example claims to demonstrate.
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup label="ONE OPTION OFF" value={@rg_plan} on_change={:rg_plan}>
              <MishkaRadioGroupOption id={:free} label="Free" />
              <MishkaRadioGroupOption id={:team} label="Team (unavailable)" disabled={true} />
            </MishkaRadioGroup>
            <Spacer size={16} />
            <MishkaRadioGroup
              label="WHOLE GROUP OFF"
              value={@rg_plan}
              disabled={true}
              on_change={:rg_plan}
              id="rg-off"
            >
              <MishkaRadioGroupOption id={:free} label="Free (off)" />
              <MishkaRadioGroupOption id={:pro} label="Pro (off)" />
            </MishkaRadioGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and size",
        description: "Passed through to every option.",
        code: ~S"""
        <MishkaRadioGroup value={@plan} color={0xFF7C3AED} size={26} on_change={:plan}>
          <MishkaRadioGroupOption id={:free} label="Free" />
          <MishkaRadioGroupOption id={:pro} label="Pro" />
        </MishkaRadioGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup value={@rg_plan} color={0xFF7C3AED} size={26} on_change={:rg_plan}>
              <MishkaRadioGroupOption id={:free} label="Free" />
              <MishkaRadioGroupOption id={:pro} label="Pro" />
            </MishkaRadioGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Options from a list",
        description:
          "Written out, an option is a tag. Built from data, it is option/3 — the same node, " <>
            "so the two forms mix freely.",
        code: ~S"""
        # option/3 builds exactly what <MishkaRadioGroupOption> builds:
        # %{type: :mishka_radio_group_option, props: %{id:, label:, disabled:}}.
        # Use the tag when you are listing the options out, the function when
        # they come from data — a comprehension over tiers cannot be markup.
        <MishkaRadioGroup label="Tier" value={@tier} on_change={:tier}>
          {Enum.map(@tiers, fn {id, label} -> option(id, label) end)}
        </MishkaRadioGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRadioGroup label="TIER" value={@rg_tier} on_change={:rg_tier} id="rg-tier">
              {Enum.map(tiers(), &tier_option/1)}
            </MishkaRadioGroup>
          </Column>
          """
        end
      }
    ]
  end

  # Stand-in for whatever a real screen would have loaded — the point of the
  # example is that the options are DATA here, so there is no markup to write.
  defp tiers do
    [
      {:starter, "Starter — free forever"},
      {:growth, "Growth — $12 a month"},
      {:scale, "Scale — waitlisted", :unavailable}
    ]
  end

  defp tier_option({id, label}), do: option(id, label)
  defp tier_option({id, label, :unavailable}), do: option(id, label, disabled: true)

  @impl true
  def props do
    [
      %{name: "value", type: "option id", default: "nil", description: "The selected option."},
      %{name: "label", type: "string", default: "nil", description: "Group heading."},
      %{
        name: "<MishkaRadioGroupOption>",
        type: "slot",
        default: "—",
        description: "One option: id, label, disabled. option/3 builds the same node."
      },
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
  def handle({:rg_tier, id}, socket), do: Mob.Socket.assign(socket, :rg_tier, id)
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
