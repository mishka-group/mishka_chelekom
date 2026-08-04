defmodule MishkaMob.Showcase.Components.Select do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSelect`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSelect, only: [option: 2]

  alias MishkaMob.Components.MishkaSelect
  alias MishkaMob.Showcase.Example

  @countries [
    {:uk, "United Kingdom"},
    {:ir, "Iran"},
    {:de, "Germany"},
    {:jp, "Japan"}
  ]

  @impl true
  def entry do
    %{
      slug: :select,
      name: "Select",
      category: "Forms",
      order: 14,
      description: "A trigger showing the current choice, and a list to pick from."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sel_country, nil)
    |> Mob.Socket.assign(:sel_open, false)
    |> Mob.Socket.assign(:sel_langs, [])
    |> Mob.Socket.assign(:sel_multi_open, false)
    |> Mob.Socket.assign(:sel_pizza, [:pepperoni])
    |> Mob.Socket.assign(:sel_pizza_open, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Single choice",
        description: "Picking replaces the value and closes the list.",
        code: ~S"""
        <MishkaSelect value={@country} open={@open?} on_toggle={:open} on_select={:pick}>
          <MishkaSelectOption id={:uk} label="United Kingdom" />
          <MishkaSelectOption id={:ir} label="Iran" />
        </MishkaSelect>

        {value, close?} = MishkaSelect.toggle(@country, id, false)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSelect
              label="COUNTRY"
              value={@sel_country}
              open={@sel_open}
              placeholder="Choose a country…"
              on_toggle={:sel_open}
              on_select={:sel_pick}
              id="sel-country"
            >
              <MishkaSelectOption id={:uk} label="United Kingdom" />
              <MishkaSelectOption id={:ir} label="Iran" />
              <MishkaSelectOption id={:de} label="Germany" />
              <MishkaSelectOption id={:jp} label="Japan" />
            </MishkaSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description: "Picking accumulates and the list stays open — a chosen option is ticked.",
        code: ~S"""
        <MishkaSelect value={@langs} multiple={true} open={@open?} on_select={:pick}>
          <MishkaSelectOption id={:elixir} label="Elixir" />
          <MishkaSelectOption id={:erlang} label="Erlang" />
          <MishkaSelectOption id={:rust} label="Rust" disabled={true} />
        </MishkaSelect>

        {value, close?} = MishkaSelect.toggle(@langs, id, true)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSelect
              label="LANGUAGES"
              value={@sel_langs}
              open={@sel_multi_open}
              multiple={true}
              placeholder="Choose any…"
              on_toggle={:sel_multi_open}
              on_select={:sel_multi_pick}
              id="sel-lang"
            >
              <MishkaSelectOption id={:elixir} label="Elixir" />
              <MishkaSelectOption id={:erlang} label="Erlang" />
              <MishkaSelectOption id={:gleam} label="Gleam" />
              <MishkaSelectOption id={:rust} label="Rust" disabled={true} />
            </MishkaSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Grouped",
        description:
          "A heading above each run of options. Multiple, so the list stays open while you pick.",
        code: ~S"""
        <MishkaSelect value={@toppings} multiple={true} open={@open?} on_select={:pick}>
          <MishkaSelectOption id={:cheese} label="Cheese" group="CLASSIC" />
          <MishkaSelectOption id={:pepperoni} label="Pepperoni" group="CLASSIC" />
          <MishkaSelectOption id={:mushroom} label="Mushroom" group="VEGGIE" />
          <MishkaSelectOption id={:onion} label="Onion" group="VEGGIE" />
        </MishkaSelect>

        # CONSECUTIVE options sharing a group belong to it, so your order is the
        # grouping — nothing is sorted underneath you.
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSelect
              label="TOPPINGS"
              value={@sel_pizza}
              open={@sel_pizza_open}
              multiple={true}
              placeholder="Choose your toppings…"
              on_toggle={:sel_pizza_open}
              on_select={:sel_pizza_pick}
              id="sel-pizza"
            >
              <MishkaSelectOption id={:cheese} label="Cheese" group="CLASSIC" />
              <MishkaSelectOption id={:pepperoni} label="Pepperoni" group="CLASSIC" />
              <MishkaSelectOption id={:mushroom} label="Mushroom" group="VEGGIE" />
              <MishkaSelectOption id={:onion} label="Onion" group="VEGGIE" />
            </MishkaSelect>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled, and options from data",
        description:
          "The trigger is muted and cannot open. Its options come from a list rather than " <>
            "being written out — option/3 builds exactly what <MishkaSelectOption> builds.",
        code: ~S"""
        <MishkaSelect value={:uk} disabled={true}>
          {Enum.map(@countries, fn {id, label} -> MishkaSelect.option(id, label) end)}
        </MishkaSelect>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSelect label="LOCKED" value={:uk} disabled={true} id="sel-off">
              {country_options()}
            </MishkaSelect>
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
        type: "id, list or nil",
        default: "nil",
        description: "The current choice(s). A list in multiple mode."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the list is shown. Lives in the screen."
      },
      %{
        name: "multiple",
        type: "boolean",
        default: "false",
        description: "Allow several choices."
      },
      %{
        name: "placeholder",
        type: "string",
        default: "\"Select…\"",
        description: "Trigger text when nothing is chosen."
      },
      %{name: "label", type: "string", default: "nil", description: "Caption above the trigger."},
      %{
        name: "on_toggle / on_select",
        type: "event tags",
        default: "—",
        description: "{:tap, tag} from the trigger; {:tap, {tag, option_id}} from an option."
      },
      %{
        name: "option/3 :group",
        type: "string",
        default: "nil",
        description: "A heading above the run it starts. Consecutive options group together."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Tags the trigger and each option with its state."
      },
      %{
        name: "toggle/3 · display/3 · group_runs/1",
        type: "helpers",
        default: "—",
        description: "The {value, close?} transition, the trigger's text, and the group runs."
      }
    ]
  end

  @impl true
  def handle(:sel_open, socket), do: flip(socket, :sel_open)
  def handle(:sel_multi_open, socket), do: flip(socket, :sel_multi_open)
  def handle(:sel_pizza_open, socket), do: flip(socket, :sel_pizza_open)

  def handle({:sel_pizza_pick, id}, socket) do
    {value, close?} = MishkaSelect.toggle(socket.assigns.sel_pizza, id, true)

    socket
    |> Mob.Socket.assign(:sel_pizza, value)
    |> Mob.Socket.assign(:sel_pizza_open, not close?)
  end

  def handle({:sel_pick, id}, socket) do
    {value, close?} = MishkaSelect.toggle(socket.assigns.sel_country, id, false)

    socket
    |> Mob.Socket.assign(:sel_country, value)
    |> Mob.Socket.assign(:sel_open, not close?)
  end

  def handle({:sel_multi_pick, id}, socket) do
    {value, close?} = MishkaSelect.toggle(socket.assigns.sel_langs, id, true)

    socket
    |> Mob.Socket.assign(:sel_langs, value)
    |> Mob.Socket.assign(:sel_multi_open, not close?)
  end

  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  # The one example whose options are DATA. Everywhere else on this page they
  # are written out as <MishkaSelectOption> tags — option/3 builds the identical
  # node, so the two forms mix freely inside one select.
  defp country_options, do: Enum.map(@countries, fn {id, label} -> option(id, label) end)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box
        fill_width={true}
        height={30}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
      <Spacer size={6} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_md}
        border_color={:border}
        border_width={1}
        padding={6}
      >
        <Column fill_width={true}>
          <Box width={70} height={8} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={7} />
          <Box width={54} height={8} background={:muted} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
