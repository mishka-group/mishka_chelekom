defmodule MishkaMob.Showcase.Components.Checkbox do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCheckbox`.

  The "select all" example is the one worth reading: it is the tristate parent
  from the web component, rebuilt as a reducer in the screen with `toggle/1`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaCheckbox, only: [checkbox: 1]

  alias MishkaMob.Showcase.Example

  @items [{:beam, "BEAM"}, {:otp, "OTP"}, {:phoenix, "Phoenix"}]

  @impl true
  def entry do
    %{
      slug: :checkbox,
      name: "Checkbox",
      category: "Forms",
      order: 3,
      description: "A labelled box with checked, unchecked and indeterminate states."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:cb_remember, true)
    |> Mob.Socket.assign(:cb_picked, [:beam])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Checked and unchecked",
        description: "One tappable row: indicator plus label.",
        code: ~S"""
        <MishkaCheckbox label="Remember me" checked={@remember?} on_toggle={:remember} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckbox
              label="Remember me"
              checked={@cb_remember}
              on_toggle={:cb_remember}
              id="cb-remember"
            />
            <Spacer size={12} />
            <MishkaCheckbox label="Unchecked" checked={false} />
          </Column>
          """
        end
      },
      %Example{
        title: "Select all (indeterminate)",
        description: "The parent goes mixed when only some children are checked.",
        code: ~S"""
        <MishkaCheckbox label="All" checked={all?} indeterminate={some?} on_toggle={:all} />

        # tapping a mixed parent selects everything
        {checked?, _} = MishkaCheckbox.toggle(%{indeterminate: true})
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckbox
              label="All languages"
              checked={all?(@cb_picked)}
              indeterminate={some?(@cb_picked)}
              on_toggle={:cb_all}
            />
            <Spacer size={10} />
            <Box fill_width={true} height={1} background={:border} />
            <Spacer size={10} />
            {child_boxes(@cb_picked)}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert, in any state.",
        code: ~S"""
        <MishkaCheckbox label="Locked" checked={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckbox label="Locked on" checked={true} disabled={true} />
            <Spacer size={12} />
            <MishkaCheckbox label="Locked off" disabled={true} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and size",
        description: "color fills the box when checked; size sets its edge.",
        code: ~S"""
        <MishkaCheckbox label="Violet" checked={true} color={0xFF7C3AED} size={26} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckbox
              label="Violet, larger"
              checked={true}
              color={0xFF7C3AED}
              size={26}
              id="cb-large"
            />
            <Spacer size={12} />
            <MishkaCheckbox label="Small" checked={true} size={16} id="cb-small" />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "label", type: "string", default: "nil", description: "Text beside the box."},
      %{
        name: "checked",
        type: "boolean",
        default: "false",
        description: "Checked state. Lives in the screen."
      },
      %{
        name: "indeterminate",
        type: "boolean",
        default: "false",
        description: "Mixed state; overrides checked and draws a dash."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler and mutes the row."
      },
      %{name: "on_toggle", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Fill when checked or mixed."
      },
      %{name: "size", type: "number", default: "22", description: "Indicator edge length."},
      %{
        name: "toggle/1",
        type: "helper",
        default: "—",
        description: "The next {checked?, indeterminate?} a tap should produce."
      }
    ]
  end

  @impl true
  def handle(:cb_remember, socket),
    do: Mob.Socket.assign(socket, :cb_remember, not socket.assigns.cb_remember)

  def handle(:cb_all, socket) do
    picked = socket.assigns.cb_picked
    next = if all?(picked), do: [], else: Enum.map(@items, &elem(&1, 0))
    Mob.Socket.assign(socket, :cb_picked, next)
  end

  def handle({:cb_item, id}, socket) do
    picked = socket.assigns.cb_picked
    next = if id in picked, do: List.delete(picked, id), else: picked ++ [id]
    Mob.Socket.assign(socket, :cb_picked, next)
  end

  def handle(_tag, socket), do: socket

  defp all?(picked), do: length(picked) == length(@items)
  defp some?(picked), do: picked != [] and not all?(picked)

  defp child_boxes(picked) do
    @items
    |> Enum.map(fn {id, label} ->
      checkbox(label: label, checked: id in picked, on_toggle: {:cb_item, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 10}, children: []})
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={16} height={16} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={54} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={16} height={16} background={:surface_raised} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={40} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={16} height={16} background={:surface_raised} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={62} height={9} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
