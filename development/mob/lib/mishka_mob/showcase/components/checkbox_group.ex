defmodule MishkaMob.Showcase.Components.CheckboxGroup do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCheckboxGroup`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaCheckboxGroup, only: [item: 2, item: 3]

  alias MishkaMob.Components.MishkaCheckboxGroup
  alias MishkaMob.Showcase.Example

  @langs [{:beam, "BEAM"}, {:otp, "OTP"}, {:phoenix, "Phoenix"}, {:ecto, "Ecto"}]

  @impl true
  def entry do
    %{
      slug: :checkbox_group,
      name: "Checkbox Group",
      category: "Forms",
      order: 6,
      description: "A labelled set of checkboxes with a tristate select-all parent."
    }
  end

  @notify [{:email, "Email"}, {:sms, "SMS"}, {:push, "Push"}]

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:cg_value, [:beam])
    |> Mob.Socket.assign(:cg_notify, [:email])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Select all",
        description: "The parent is an ordinary checkbox whose mixed state is derived.",
        code: ~S"""
        <MishkaCheckboxGroup
          value={@value}
          select_all={true}
          on_change={:item}
          on_select_all={:all}
          id="langs"
        >{items}</MishkaCheckboxGroup>

        # An item tap carries its id; the parent's does not need to, because
        # there is only one parent. Both reducers live in the component so a
        # screen never re-derives them.
        def handle_info({:tap, {:item, id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :value,
            MishkaCheckboxGroup.toggle(socket.assigns.value, id))}
        end

        def handle_info({:tap, :all}, socket) do
          {:noreply, Mob.Socket.assign(socket, :value,
            MishkaCheckboxGroup.select_all(socket.assigns.value, @all_ids))}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckboxGroup
              label="LIBRARIES"
              value={@cg_value}
              select_all={true}
              select_all_label="Select all libraries"
              on_change={:cg_item}
              on_select_all={:cg_all}
              id="cg-langs"
            >
              {lang_items()}
            </MishkaCheckboxGroup>
            <Spacer size={12} />
            <Text text={summary(@cg_value)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Without a parent",
        description: "Leave select_all off for a plain group — no parent, no divider.",
        code: ~S"""
        <MishkaCheckboxGroup value={@value} on_change={:item}>{items}</MishkaCheckboxGroup>

        def handle_info({:tap, {:item, id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :value,
            MishkaCheckboxGroup.toggle(socket.assigns.value, id))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckboxGroup
              label="NOTIFY ME BY"
              value={@cg_notify}
              on_change={:cg_notify}
              id="cg-notify"
            >
              {notify_items()}
            </MishkaCheckboxGroup>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "One item, or the whole group including its parent.",
        code: ~S"""
        item(:ecto, "Ecto", disabled: true)
        <MishkaCheckboxGroup disabled={true} select_all={true}>{items}</MishkaCheckboxGroup>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCheckboxGroup label="ONE ITEM OFF" value={@cg_value} on_change={:cg_item} id="cg-one">
              {[
              item(:beam, "BEAM"),
              item(:ecto, "Ecto (unavailable)", disabled: true)
            ]}
            </MishkaCheckboxGroup>
            <Spacer size={16} />
            <MishkaCheckboxGroup
              label="WHOLE GROUP OFF"
              value={@cg_value}
              select_all={true}
              disabled={true}
              select_all_label="Select all (off)"
              id="cg-off"
            >
              {off_items()}
            </MishkaCheckboxGroup>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "value", type: "list of ids", default: "[]", description: "The selected ids."},
      %{name: "label", type: "string", default: "nil", description: "Group heading."},
      %{
        name: "select_all",
        type: "boolean",
        default: "false",
        description: "Render the tristate parent."
      },
      %{
        name: "select_all_label",
        type: "string",
        default: "\"Select all\"",
        description: "Parent's label."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disables every row, parent included."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}."
      },
      %{
        name: "on_select_all",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, tag} for the parent."
      },
      %{name: "space", type: "number", default: "12", description: "Gap between rows."},
      %{
        name: "color / size",
        type: "see Checkbox",
        default: ":primary / 22",
        description: "Passed to every row, parent included."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Prefix for each row's test tag: <id>-<item>-checked."
      },
      %{
        name: "toggle/2 · select_all/2 · parent_state/2",
        type: "helpers",
        default: "—",
        description: "The selection reducers, so each screen does not re-derive them."
      }
    ]
  end

  @impl true
  def handle({:cg_item, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :cg_value,
        MishkaCheckboxGroup.toggle(socket.assigns.cg_value, id)
      )

  def handle(:cg_all, socket) do
    ids = Enum.map(@langs, &elem(&1, 0))

    Mob.Socket.assign(
      socket,
      :cg_value,
      MishkaCheckboxGroup.select_all(socket.assigns.cg_value, ids)
    )
  end

  def handle({:cg_notify, id}, socket),
    do:
      Mob.Socket.assign(
        socket,
        :cg_notify,
        MishkaCheckboxGroup.toggle(socket.assigns.cg_notify, id)
      )

  def handle(_tag, socket), do: socket

  defp lang_items, do: Enum.map(@langs, fn {id, label} -> item(id, label) end)

  # Distinct labels, because three groups on this page read the same @cg_value
  # and an exact-text lookup finds the FIRST match — which is the tappable one.
  # A test aimed at the disabled group would otherwise exercise the live one and
  # pass. It also stops the page reading as the same list printed three times.
  defp off_items, do: Enum.map(@langs, fn {id, label} -> item(id, "#{label} (off)") end)

  defp notify_items, do: Enum.map(@notify, fn {id, label} -> item(id, label) end)

  defp summary([]), do: "Nothing selected"
  defp summary(ids), do: "Selected: " <> Enum.map_join(ids, ", ", &to_string/1)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={15} height={15} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={46} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Box fill_width={true} height={1} background={:border} />
      <Spacer size={8} />
      <Row fill_width={true}>
        <Box width={15} height={15} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={34} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Row fill_width={true}>
        <Box width={15} height={15} background={:surface_raised} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={50} height={8} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
