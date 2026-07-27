defmodule MishkaMob.Showcase.Components.Combobox do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCombobox`.

  Fully live: type to filter, tap to choose, ✕ to clear.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaCombobox, only: [option: 2]

  alias MishkaMob.Components.{MishkaCombobox, MishkaSelect}
  alias MishkaMob.Showcase.Example

  @countries [
    {:ir, "Iran"},
    {:uk, "United Kingdom"},
    {:de, "Germany"},
    {:jp, "Japan"},
    {:br, "Brazil"},
    {:se, "Sweden"}
  ]

  @impl true
  def entry do
    %{
      slug: :combobox,
      name: "Combobox",
      category: "Forms",
      order: 15,
      description: "A text field that filters a list of options."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:cb_query, "")
    |> Mob.Socket.assign(:cb_value, nil)
    |> Mob.Socket.assign(:cb_multi, [])
    |> Mob.Socket.assign(:cb_multi_query, "")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Filter and choose",
        description: "Type to narrow the list — matching ignores case AND accents.",
        code: ~S"""
        <MishkaCombobox
          query={@query}
          value={@value}
          open={true}
          clear={true}
          on_query={:query}
          on_select={:pick}
          on_clear={:clear}
        >{options}</MishkaCombobox>

        MishkaCombobox.filter(pairs, query)   # "cafe" finds "Café"
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCombobox
              query={@cb_query}
              value={@cb_value}
              open={true}
              clear={true}
              placeholder="Search countries…"
              on_query={:cb_query}
              on_select={:cb_pick}
              on_clear={:cb_clear}
            >
              {country_options()}
            </MishkaCombobox>
            <Spacer size={10} />
            <Text text={chosen(@cb_value)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description: "Chosen options are ticked and the list stays open.",
        code: ~S"""
        <MishkaCombobox multiple={true} value={@values} …>{options}</MishkaCombobox>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCombobox
              query={@cb_multi_query}
              value={@cb_multi}
              open={true}
              multiple={true}
              placeholder="Pick several…"
              on_query={:cb_multi_query}
              on_select={:cb_multi_pick}
            >
              {country_options()}
            </MishkaCombobox>
          </Column>
          """
        end
      },
      %Example{
        title: "No matches",
        description: "An empty result says so rather than collapsing to nothing.",
        code: ~S"""
        <MishkaCombobox
          query="zzz"
          open={true}
          empty_text="Nothing found"
        >{options}</MishkaCombobox>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCombobox query="zzz" open={true} empty_text="No country matches that.">
              {country_options()}
            </MishkaCombobox>
          </Column>
          """
        end
      },
      %Example{
        title: "starts_with",
        description: "The other filter mode the web component names.",
        code: ~S"""
        <MishkaCombobox filter={:starts_with} query="u" open={true}>{options}</MishkaCombobox>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCombobox filter={:starts_with} query="u" open={true} placeholder={"starts_with \"u\""}>
              {country_options()}
            </MishkaCombobox>
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
        description: "The current choice(s)."
      },
      %{name: "query", type: "string", default: "\"\"", description: "The field's contents."},
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the list is shown."
      },
      %{
        name: "multiple",
        type: "boolean",
        default: "false",
        description: "Allow several choices."
      },
      %{
        name: "filter",
        type: ":contains · :starts_with",
        default: ":contains",
        description: "Match mode."
      },
      %{
        name: "clear",
        type: "boolean",
        default: "false",
        description: "Render a ✕ that clears the query."
      },
      %{
        name: "empty_text",
        type: "string",
        default: "\"No matches\"",
        description: "Shown when nothing matches."
      },
      %{
        name: "on_query / on_select / on_clear",
        type: "event tags",
        default: "—",
        description: "Typing, choosing, and clearing."
      },
      %{
        name: "filter/3 · fold/1",
        type: "helpers",
        default: "—",
        description: "Case- and accent-insensitive matching, callable from your handler."
      }
    ]
  end

  @impl true
  def handle({:cb_pick, id}, socket) do
    {value, _close?} = MishkaSelect.toggle(socket.assigns.cb_value, id, false)
    Mob.Socket.assign(socket, :cb_value, value)
  end

  def handle({:cb_multi_pick, id}, socket) do
    {value, _close?} = MishkaSelect.toggle(socket.assigns.cb_multi, id, true)
    Mob.Socket.assign(socket, :cb_multi, value)
  end

  def handle(:cb_clear, socket), do: Mob.Socket.assign(socket, :cb_query, "")
  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:cb_query, text, socket), do: Mob.Socket.assign(socket, :cb_query, text)

  def handle_change(:cb_multi_query, text, socket),
    do: Mob.Socket.assign(socket, :cb_multi_query, text)

  def handle_change(_tag, _value, socket), do: socket

  defp country_options, do: Enum.map(@countries, fn {id, label} -> option(id, label) end)

  defp chosen(nil), do: "Nothing chosen"
  defp chosen(id), do: "Chosen: " <> MishkaCombobox.fold(to_string(id))

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box
        fill_width={true}
        height={28}
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
          <Box width={56} height={8} background={:primary} corner_radius={:radius_sm} />
          <Spacer size={7} />
          <Box width={72} height={8} background={:muted} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
