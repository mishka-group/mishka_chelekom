defmodule MishkaMob.Showcase.Components.Autocomplete do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAutocomplete` and
  `MishkaMob.Components.MishkaPillsInput`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaPill, only: [pill: 1]

  alias MishkaMob.Components.{MishkaCombobox, MishkaMenu}
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
    |> Mob.Socket.assign(:ac_recipients, ["Ada Lovelace"])
    |> Mob.Socket.assign(:ac_pick_open, false)
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
          on_press={:open}
        />

        # Typing opens it and is the value; the chosen suggestion IS the text.
        def handle_info({:change, :query, text}, socket) do
          {:noreply, socket |> assign(:query, text) |> assign(:open?, true)}
        end

        def handle_info({:tap, {:choose, text}}, socket) do
          {:noreply, socket |> assign(:query, text) |> assign(:open?, false)}
        end

        # on_press, NOT on_focus: focus is an edge, so a field that already has
        # the caret reports nothing when you tap it again — and closing the list
        # does not take the caret away, so the obvious way to reopen it did
        # nothing at all.
        def handle_info({:tap, :open}, socket), do: {:noreply, assign(socket, :open?, true)}
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
              on_press={:ac_focus}
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
              on_press={:ac_any_focus}
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
        title: "Pills input — a picker, not just a text box",
        description:
          "Tap the field for the list, type to filter, tap a name to add it. Tapping a name you already have removes it, so the same person cannot be added twice.",
        code: ~S"""
        <MishkaPillsInput draft={@draft} on_draft={:typed} on_add={:commit} on_focus={:open}>
          {pills(@chosen)}
        </MishkaPillsInput>
        {suggestions_menu(@chosen, @draft)}

        # ONE clause does add and remove: a tap on a name you already have is a
        # request to drop it, which is also what stops duplicates existing.
        def handle_info({:tap, {:pick, name}}, socket) do
          chosen = socket.assigns.chosen

          next =
            if name in chosen, do: List.delete(chosen, name), else: chosen ++ [name]

          {:noreply, socket |> assign(:chosen, next) |> assign(:draft, "")}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true} on_tap={{self(), :ac_pick_close}}>
            <MishkaPillsInput
              draft={@ac_draft}
              placeholder="Add a recipient…"
              on_draft={:ac_draft}
              on_add={:ac_add}
              on_press={:ac_pick_focus}
              id="ac-pills"
            >
              {recipient_pills(@ac_recipients)}
            </MishkaPillsInput>
            {recipient_menu(@ac_recipients, @ac_draft, @ac_pick_open)}
            <Spacer size={10} />
            <Text
              text="A ✓ marks someone already added — tap them again to remove. Return still
                    commits whatever you typed."
              text_size={:sm}
              text_color={:muted}
            />
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
        name: "on_press / on_toggle / trigger",
        type: "event tags / boolean",
        default: "—",
        description: "on_press fires on EVERY tap of the field; on_focus only on the first."
      },
      %{
        name: "trigger_icon / clear_icon",
        type: "string or {closed, open}",
        default: "▾ ▴ / ✕",
        description: "The buttons' glyphs, for callers who want their own."
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

  def handle(:ac_pick_focus, socket), do: Mob.Socket.assign(socket, :ac_pick_open, true)
  def handle(:ac_pick_close, socket), do: Mob.Socket.assign(socket, :ac_pick_open, false)

  # ONE clause does add and remove. A tap on someone already added is a request
  # to drop them — which is also what makes a duplicate impossible, rather than
  # a rule enforced separately and forgotten on one of the two paths.
  def handle({:ac_pick, name}, socket) do
    chosen = socket.assigns.ac_recipients
    next = if name in chosen, do: List.delete(chosen, name), else: chosen ++ [name]

    socket
    |> Mob.Socket.assign(:ac_recipients, next)
    |> Mob.Socket.assign(:ac_draft, "")
  end

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

  def handle_change(:ac_draft, text, socket) do
    socket |> Mob.Socket.assign(:ac_draft, text) |> Mob.Socket.assign(:ac_pick_open, true)
  end

  def handle_change(_tag, _value, socket), do: socket

  defp cities, do: @cities

  defp recipient_pills(names) do
    Enum.map(names, fn name ->
      pill(label: name, with_remove: true, on_remove: {:ac_drop, name})
    end)
  end

  @roster [
    "Ada Lovelace",
    "Grace Hopper",
    "Alan Turing",
    "Katherine Johnson",
    "Barbara Liskov"
  ]

  # A pills input owns no list, so the picker's list is the screen's — built on
  # the same Menu surface the combobox and select use, from the same filter.
  # Everyone stays on the list, chosen or not: a ✓ says who is already in, and
  # tapping them again is how you take them out.
  defp recipient_menu(_chosen, _draft, false), do: %{type: :column, props: %{}, children: []}

  defp recipient_menu(chosen, draft, true) do
    matches =
      @roster
      |> Enum.map(&{&1, &1})
      |> MishkaCombobox.filter(draft)

    case matches do
      [] ->
        MishkaMenu.menu(%{open: true}, [
          MishkaMenu.item(:__none__, "Nobody by that name", disabled: true)
        ])

      matches ->
        items =
          Enum.map(matches, fn {name, _} ->
            picked? = name in chosen

            MishkaMenu.item(name, name,
              icon: if(picked?, do: "✓", else: nil),
              test_id: "ac-pick-#{name}-#{if picked?, do: "selected", else: "idle"}"
            )
          end)

        MishkaMenu.menu(%{open: true, on_select: :ac_pick}, items)
    end
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
