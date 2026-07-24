defmodule MishkaMob.Showcase.Components.Select do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSelect`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSelect, only: [select: 2, option: 2, option: 3]

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
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Single choice",
        description: "Picking replaces the value and closes the list.",
        code: ~S"""
        {select([value: @country, open: @open?, on_toggle: :open, on_select: :pick], [
          option(:uk, "United Kingdom"),
          option(:ir, "Iran")
        ])}

        {value, close?} = MishkaSelect.toggle(@country, id, false)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {select(
               [label: "COUNTRY", value: @sel_country, open: @sel_open,
                placeholder: "Choose a country…",
                on_toggle: :sel_open, on_select: :sel_pick],
               country_options()
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description: "Picking accumulates and the list stays open — a chosen option is ticked.",
        code: ~S"""
        {select([value: @langs, multiple: true, open: @open?, …], options)}

        {value, close?} = MishkaSelect.toggle(@langs, id, true)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {select(
               [label: "LANGUAGES", value: @sel_langs, open: @sel_multi_open, multiple: true,
                placeholder: "Choose any…",
                on_toggle: :sel_multi_open, on_select: :sel_multi_pick],
               lang_options()
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "The trigger is muted and cannot open.",
        code: ~S"""
        {select([value: :uk, disabled: true], options)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {select([label: "LOCKED", value: :uk, disabled: true], country_options())}
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
        name: "toggle/3 · display/3",
        type: "helpers",
        default: "—",
        description: "The {value, close?} transition, and the trigger's text."
      }
    ]
  end

  @impl true
  def handle(:sel_open, socket), do: flip(socket, :sel_open)
  def handle(:sel_multi_open, socket), do: flip(socket, :sel_multi_open)

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

  defp country_options, do: Enum.map(@countries, fn {id, label} -> option(id, label) end)

  defp lang_options do
    [
      option(:elixir, "Elixir"),
      option(:erlang, "Erlang"),
      option(:gleam, "Gleam"),
      option(:rust, "Rust", disabled: true)
    ]
  end

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
