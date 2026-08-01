defmodule MishkaMob.Showcase.Components.Combobox do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCombobox`.

  Fully live: type to filter, tap to choose, ✕ to clear.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaCombobox, only: [option: 2, option: 3]

  alias MishkaMob.Components.{MishkaCombobox, MishkaSelect}
  alias MishkaMob.Showcase.Example

  @countries [
    {:ir, "Iran"},
    {:uk, "United Kingdom"},
    {:de, "Germany"},
    {:jp, "Japan"},
    {:br, "Brazil"},
    {:se, "Sweden"},
    # An accented label on purpose: the description claims matching ignores
    # accents, and without one on the page nothing demonstrates it. Typing
    # "turkiye" on a phone keyboard has to find this.
    {:tr, "Türkiye"}
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
    |> Mob.Socket.assign(:cb_multi, [:uk, :de])
    |> Mob.Socket.assign(:cb_multi_query, "")
    |> Mob.Socket.assign(:cb_open, false)
    |> Mob.Socket.assign(:cb_food, [:apple, :carrot])
    |> Mob.Socket.assign(:cb_multi_open, false)
    |> Mob.Socket.assign(:cb_food_query, "")
    |> Mob.Socket.assign(:cb_food_open, false)
    |> Mob.Socket.assign(:cb_created, [])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Filter and choose",
        description:
          "Type to narrow the list — matching ignores case AND accents. ▾ opens and closes it.",
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
        # `empty_text` here names this list's empty row rather than taking the
        # default. "No matches" is on the page from mount — it is the fourth
        # example's title, and the props table prints it as this prop's default
        # — so a test looking for that string could not tell THIS list's empty
        # state from two nodes it never touches. The row below has one renderer.
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :cb_close}}>
            <MishkaCombobox
              query={@cb_query}
              value={@cb_value}
              open={@cb_open}
              clear={true}
              trigger={true}
              placeholder="Search countries…"
              empty_text="No country by that name."
              on_query={:cb_query}
              on_select={:cb_pick}
              on_clear={:cb_clear}
              on_toggle={:cb_open}
              on_press={:cb_focus}
              id="cb-one"
            >
              {country_options()}
            </MishkaCombobox>
            <Spacer size={10} />
            <Text text={chosen(@cb_value)} text_size={:sm} text_color={:muted} />
            <Spacer size={20} />
            <Text
              text="Tap the field to open it, type to keep it open, and tap anywhere in this
                    card to close it."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Multiple",
        description:
          "Chips share the line with the field, as on the web. ▾ opens the list; picking keeps it open.",
        code: ~S"""
        <MishkaCombobox multiple={true} value={@values} …>{options}</MishkaCombobox>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :cb_multi_close}}>
            <MishkaCombobox
              query={@cb_multi_query}
              value={@cb_multi}
              open={@cb_multi_open}
              multiple={true}
              trigger={true}
              placeholder="Pick several…"
              on_query={:cb_multi_query}
              on_select={:cb_multi_pick}
              on_remove={:cb_multi_remove}
              on_toggle={:cb_multi_open}
              on_press={:cb_multi_focus}
              id="cb-multi"
            >
              {country_options()}
            </MishkaCombobox>
          </Column>
          """
        end
      },
      %Example{
        title: "Grouped, creatable, with a disabled item",
        description:
          "Headings per run, an out-of-stock option that cannot be picked, and a Create row for anything that does not match.",
        code: ~S"""
        <MishkaCombobox multiple={true} creatable={true} on_create={:create} …>{[
          option(:apple, "Apple", group: "FRUIT"),
          option(:durian, "Durian (out of stock)", group: "FRUIT", disabled: true),
          option(:carrot, "Carrot", group: "VEGETABLE")
        ]}</MishkaCombobox>

        # The component only OFFERS; adding to the list is the screen's job, and
        # the screen already holds the query.
        def handle_info({:tap, {:pick, :__create__}}, socket), do: create(socket)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :cb_food_close}}>
            <MishkaCombobox
              query={@cb_food_query}
              value={@cb_food}
              open={@cb_food_open}
              multiple={true}
              clear={true}
              trigger={true}
              creatable={true}
              placeholder="Add items…"
              on_query={:cb_food_query}
              on_select={:cb_food_pick}
              on_remove={:cb_food_remove}
              on_clear={:cb_food_clear}
              on_toggle={:cb_food_open}
              on_press={:cb_food_focus}
              id="cb-food"
            >
              {food_options(@cb_created)}
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
  def handle(:cb_open, socket), do: flip(socket, :cb_open)
  def handle(:cb_multi_open, socket), do: flip(socket, :cb_multi_open)

  # Tapping the field opens the list; tapping the card around it closes.
  # A child's handler consumes the tap, so the control and its options are
  # unaffected — only the surrounding space closes anything.
  def handle(:cb_focus, socket), do: Mob.Socket.assign(socket, :cb_open, true)
  def handle(:cb_multi_focus, socket), do: Mob.Socket.assign(socket, :cb_multi_open, true)
  def handle(:cb_food_focus, socket), do: Mob.Socket.assign(socket, :cb_food_open, true)
  def handle(:cb_close, socket), do: Mob.Socket.assign(socket, :cb_open, false)
  def handle(:cb_multi_close, socket), do: Mob.Socket.assign(socket, :cb_multi_open, false)
  def handle(:cb_food_close, socket), do: Mob.Socket.assign(socket, :cb_food_open, false)
  def handle(:cb_food_open, socket), do: flip(socket, :cb_food_open)
  def handle(:cb_food_clear, socket), do: Mob.Socket.assign(socket, :cb_food_query, "")

  def handle({:cb_multi_remove, id}, socket),
    do: Mob.Socket.assign(socket, :cb_multi, List.delete(socket.assigns.cb_multi, id))

  def handle({:cb_food_remove, id}, socket),
    do: Mob.Socket.assign(socket, :cb_food, List.delete(socket.assigns.cb_food, id))

  # The create row reports the same tag as any option, with the id :__create__ —
  # so one clause handles picking, and one branch inside it handles creating.
  def handle({:cb_food_pick, :__create__}, socket) do
    name = String.trim(socket.assigns.cb_food_query)
    id = name |> String.downcase() |> String.to_atom()

    socket
    |> Mob.Socket.assign(:cb_created, socket.assigns.cb_created ++ [{id, name}])
    |> Mob.Socket.assign(:cb_food, socket.assigns.cb_food ++ [id])
    |> Mob.Socket.assign(:cb_food_query, "")
  end

  def handle({:cb_food_pick, id}, socket) do
    {value, _close?} = MishkaSelect.toggle(socket.assigns.cb_food, id, true)
    Mob.Socket.assign(socket, :cb_food, value)
  end

  def handle(_tag, socket), do: socket

  defp flip(socket, key),
    do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  @impl true
  # Typing opens it too: a user who taps and types before the list appears must
  # not have to tap again.
  def handle_change(:cb_query, text, socket) do
    socket |> Mob.Socket.assign(:cb_query, text) |> Mob.Socket.assign(:cb_open, true)
  end

  def handle_change(:cb_food_query, text, socket) do
    socket
    |> Mob.Socket.assign(:cb_food_query, text)
    |> Mob.Socket.assign(:cb_food_open, true)
  end

  def handle_change(:cb_multi_query, text, socket) do
    socket
    |> Mob.Socket.assign(:cb_multi_query, text)
    |> Mob.Socket.assign(:cb_multi_open, true)
  end

  def handle_change(_tag, _value, socket), do: socket

  defp country_options, do: Enum.map(@countries, fn {id, label} -> option(id, label) end)

  # Order IS the grouping: consecutive options sharing a group get one heading.
  # Anything the user creates is appended, so it appears under its own run.
  defp food_options(created) do
    [
      option(:apple, "Apple", group: "FRUIT"),
      option(:banana, "Banana", group: "FRUIT"),
      option(:cherry, "Cherry", group: "FRUIT"),
      option(:durian, "Durian (out of stock)", group: "FRUIT", disabled: true),
      option(:carrot, "Carrot", group: "VEGETABLE"),
      option(:potato, "Potato", group: "VEGETABLE")
    ] ++ Enum.map(created, fn {id, label} -> option(id, label, group: "CREATED") end)
  end

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
