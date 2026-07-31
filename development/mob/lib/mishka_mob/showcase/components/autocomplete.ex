defmodule MishkaMob.Showcase.Components.Autocomplete do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAutocomplete` and
  `MishkaMob.Components.MishkaPillsInput`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaPill, only: [pill: 1]

  alias MishkaMob.Showcase.Example

  @cities ["Tehran", "Toronto", "Tokyo", "Berlin", "Bergen", "Lisbon"]

  @impl true
  def entry do
    %{
      slug: :autocomplete,
      name: "Autocomplete",
      category: "Forms",
      order: 16,
      description: "A text field that suggests completions, plus a pills input."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:ac_query, "")
    |> Mob.Socket.assign(:ac_open, false)
    # A second pair for the contains example: sharing one assign made typing in
    # either field rewrite the other, which reads as a bug in the component.
    |> Mob.Socket.assign(:ac_any, "")
    |> Mob.Socket.assign(:ac_any_open, false)
    |> Mob.Socket.assign(:ac_draft, "")
    |> Mob.Socket.assign(:ac_recipients, ["ada", "grace"])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Suggest as you type",
        description:
          "Prefix matching by default — and suggestions vanish once you match exactly.",
        code: ~S"""
        <MishkaAutocomplete
          query={@query}
          suggestions={@cities}
          open={@open?}
          on_query={:query}
          on_select={:choose}
          on_focus={:focus}
        />

        # Typing opens it and is the value; the chosen suggestion IS the text.
        def handle_info({:change, :query, text}, socket) do
          {:noreply, socket |> assign(:query, text) |> assign(:open?, true)}
        end

        def handle_info({:tap, {:choose, text}}, socket) do
          {:noreply, socket |> assign(:query, text) |> assign(:open?, false)}
        end

        # Tapping the field opens it; tapping the container around it closes.
        def handle_info({:focus, :focus}, socket), do: {:noreply, assign(socket, :open?, true)}
        def handle_info({:tap, :close}, socket), do: {:noreply, assign(socket, :open?, false)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :ac_close}}>
            <MishkaAutocomplete
              query={@ac_query}
              suggestions={cities()}
              open={@ac_open}
              clear={true}
              trigger={true}
              placeholder="Type a city…"
              on_query={:ac_query}
              on_select={:ac_choose}
              on_clear={:ac_clear}
              on_focus={:ac_focus}
              on_toggle={:ac_toggle}
              id="ac-city"
            />
            <Spacer size={10} />
            <Text
              text="Tap the field to open it, ▾ to toggle, and anywhere in this card to close.
                    Choosing a suggestion fills the field."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={10} />
            <Text text={"Value: " <> inspect(@ac_query)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Contains matching",
        description: "filter: :contains matches anywhere instead of the prefix.",
        code: ~S"""
        <MishkaAutocomplete query={@query} suggestions={@cities} filter={:contains} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :ac_any_close}}>
            <MishkaAutocomplete
              query={@ac_any}
              suggestions={cities()}
              open={@ac_any_open}
              filter={:contains}
              placeholder="Matches anywhere…"
              on_query={:ac_any}
              on_select={:ac_any_choose}
              on_focus={:ac_any_focus}
              id="ac-any"
            />
            <Spacer size={10} />
            <Text
              text="Its own text, separate from the card above — the two used to share one."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Pills input",
        description: "The caller owns the pills — they can be anything, not just strings.",
        code: ~S"""
        <MishkaPillsInput
          draft={@draft}
          on_draft={:typed}
          on_add={:commit}
        >{recipient_pills()}</MishkaPillsInput>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaPillsInput
              draft={@ac_draft}
              placeholder="Add a recipient…"
              on_draft={:ac_draft}
              on_add={:ac_add}
            >
              {recipient_pills(@ac_recipients)}
            </MishkaPillsInput>
            <Spacer size={10} />
            <Text text="Press return to add; tap a ✕ to remove." text_size={:sm} text_color={:muted} />
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
        name: "query",
        type: "string",
        default: "\"\"",
        description: "The field's text — for an autocomplete this IS the value."
      },
      %{
        name: "suggestions",
        type: "list of strings",
        default: "[]",
        description: "What to offer."
      },
      %{
        name: "filter",
        type: ":starts_with · :contains",
        default: ":starts_with",
        description: "Prefix by default, which is what autocomplete means."
      },
      %{
        name: "on_query / on_select / on_clear",
        type: "event tags",
        default: "—",
        description: "on_select hands back the suggestion's TEXT, not an id."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the panel is shown. Lives in the screen."
      },
      %{
        name: "on_focus / on_toggle / trigger",
        type: "event tags / boolean",
        default: "—",
        description: "Tap the field to open, ▾ to toggle. Close with an on_tap on the container."
      },
      %{
        name: "clear / placeholder / empty_text / disabled",
        type: "see Combobox",
        default: "—",
        description: "Forwarded — this drops only :suggestions and hands the rest over."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tags for the field, the buttons and every suggestion."
      },
      %{
        name: "suggest/3 · exact?/2 · exact_match?/2",
        type: "helpers",
        default: "—",
        description: "Filtered suggestions, and whether the query already names one."
      },
      %{
        name: "PillsInput: draft / on_draft / on_add",
        type: "see MishkaPillsInput",
        default: "—",
        description: "A bordered control whose pills the caller supplies."
      },
      %{
        name: "PillsInput: per_row",
        type: "number",
        default: "3",
        description: "Pills before wrapping. Declared, not measured — Mob reports no geometry."
      }
    ]
  end

  @impl true
  # Choosing fills the field AND closes: there is nothing left to suggest, and a
  # panel that stays open over the answer is the defect this page used to show.
  def handle({:ac_choose, text}, socket) do
    socket |> Mob.Socket.assign(:ac_query, text) |> Mob.Socket.assign(:ac_open, false)
  end

  def handle({:ac_any_choose, text}, socket) do
    socket |> Mob.Socket.assign(:ac_any, text) |> Mob.Socket.assign(:ac_any_open, false)
  end

  def handle(:ac_clear, socket), do: Mob.Socket.assign(socket, :ac_query, "")
  def handle(:ac_focus, socket), do: Mob.Socket.assign(socket, :ac_open, true)
  def handle(:ac_any_focus, socket), do: Mob.Socket.assign(socket, :ac_any_open, true)
  def handle(:ac_close, socket), do: Mob.Socket.assign(socket, :ac_open, false)
  def handle(:ac_any_close, socket), do: Mob.Socket.assign(socket, :ac_any_open, false)

  def handle(:ac_toggle, socket),
    do: Mob.Socket.assign(socket, :ac_open, not socket.assigns.ac_open)

  def handle({:ac_drop, id}, socket),
    do: Mob.Socket.assign(socket, :ac_recipients, List.delete(socket.assigns.ac_recipients, id))

  # A submit carries no payload, so the draft we already hold is what commits.
  def handle(:ac_add, socket) do
    draft = String.trim(socket.assigns.ac_draft)

    if draft == "" or draft in socket.assigns.ac_recipients do
      Mob.Socket.assign(socket, :ac_draft, "")
    else
      socket
      |> Mob.Socket.assign(:ac_recipients, socket.assigns.ac_recipients ++ [draft])
      |> Mob.Socket.assign(:ac_draft, "")
    end
  end

  def handle(_tag, socket), do: socket

  @impl true
  # Typing opens it too, so someone who taps and types before the panel appears
  # does not have to tap again.
  def handle_change(:ac_query, text, socket) do
    socket |> Mob.Socket.assign(:ac_query, text) |> Mob.Socket.assign(:ac_open, true)
  end

  def handle_change(:ac_any, text, socket) do
    socket |> Mob.Socket.assign(:ac_any, text) |> Mob.Socket.assign(:ac_any_open, true)
  end

  def handle_change(:ac_draft, text, socket), do: Mob.Socket.assign(socket, :ac_draft, text)
  def handle_change(_tag, _value, socket), do: socket

  defp cities, do: @cities

  defp recipient_pills(names) do
    Enum.map(names, fn name ->
      pill(label: name, with_remove: true, on_remove: {:ac_drop, name})
    end)
  end

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
          <Box width={62} height={8} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={7} />
          <Box width={48} height={8} background={:muted} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
