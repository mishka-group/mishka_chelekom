defmodule MishkaMob.Showcase.Components.Highlight do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaHighlight`.

  The first example is live: type-free, but the query cycles through buttons so
  the matching is visible rather than described.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @sentence "Mishka Chelekom components, now running natively on the BEAM."
  @queries ["che", "beam", "nativ", "o"]

  @impl true
  def entry do
    %{
      slug: :highlight,
      name: "Highlight",
      category: "Data display",
      order: 3,
      description: "Text with matching substrings marked, as in search results."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :hl_query, "che")

  @impl true
  def examples do
    [
      %Example{
        title: "Every occurrence, whatever its casing",
        description:
          "One query marks all three, and each renders with the casing it has in " <>
            "the text — not the casing that was searched for.",
        code: ~S"""
        <MishkaHighlight
          text="Highlight This, definitely THIS and also this!"
          highlight="this"
          wrap_at={34}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaHighlight
            text="Highlight This, definitely THIS and also this!"
            highlight="this"
            wrap_at={34}
          />
          """
        end
      },
      %Example{
        title: "Case sensitivity",
        description:
          "Insensitive by default. case_sensitive={true} marks only the exact casing " <>
            "— here just the lowercase one.",
        code: ~S"""
        <MishkaHighlight text="Highlight This, definitely THIS and also this!" highlight="this" />

        <MishkaHighlight
          text="Highlight This, definitely THIS and also this!"
          highlight="this"
          case_sensitive={true}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Insensitive (default)" text_size={:sm} text_color={:muted} />
            <Spacer size={6} />
            <MishkaHighlight
              text="Highlight This, definitely THIS and also this!"
              highlight="this"
              wrap_at={34}
            />
            <Spacer size={14} />
            <Text text="case_sensitive={true}" text_size={:sm} text_color={:muted} />
            <Spacer size={6} />
            <MishkaHighlight
              text="Highlight This, definitely THIS and also this!"
              highlight="this"
              case_sensitive={true}
              wrap_at={34}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Matching a query",
        description: "Tap a query — the marks follow it.",
        code: ~S"""
        <MishkaHighlight text="Mishka Chelekom" highlight={@query} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHighlight text="Mishka Chelekom" highlight={@hl_query} />
            <Spacer size={14} />
            <Row fill_width={true}>
              {query_buttons(@hl_query)}
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Several queries",
        description: "Pass a list to mark more than one substring.",
        code: ~S"""
        <MishkaHighlight text="one two three" highlight={["one", "three"]} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHighlight text="one two three" highlight={["one", "three"]} />
            <Spacer size={10} />
            <MishkaHighlight text="BEAM on iOS and Android" highlight={["iOS", "Android"]} />
          </Column>
          """
        end
      },
      %Example{
        title: "Wrapping a sentence",
        description:
          "A Row does not wrap and no geometry comes back, so wrap_at is a character " <>
            "budget per line. Without it a sentence runs off the edge.",
        code: ~S"""
        # Breaks land after whitespace, and a mark is never split across lines.
        <MishkaHighlight text={@sentence} highlight={["BEAM", "natively"]} wrap_at={30} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHighlight
              text="Mishka Chelekom components, now running natively on the BEAM."
              highlight={["BEAM", "natively"]}
              wrap_at={30}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "No match, no marks",
        description: "An empty, nil or unmatched query leaves the text plain.",
        code: ~S"""
        <MishkaHighlight text="nothing to mark" highlight="" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHighlight text="nothing to mark here" highlight="" />
            <Spacer size={10} />
            <MishkaHighlight text="nothing to mark here" highlight="zzz" />
          </Column>
          """
        end
      },
      %Example{
        title: "Colours",
        description: "background and color tint the marks; text_color the rest.",
        code: ~S"""
        <MishkaHighlight text="…" highlight="beam" background={0xFFBBF7D0} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaHighlight text="green on the BEAM" highlight="beam" background={0xFFBBF7D0} />
            <Spacer size={10} />
            <MishkaHighlight text="violet on the BEAM" highlight="beam" background={0xFFDDD6FE} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "text", type: "string", default: "\"\"", description: "The full text."},
      %{
        name: "highlight",
        type: "string or list",
        default: "[]",
        description: "Substring(s) to mark. Blank and nil are ignored."
      },
      %{
        name: "case_sensitive",
        type: "boolean",
        default: "false",
        description: "Match casing exactly. Mantine spells this caseInsensitive={false}."
      },
      %{
        name: "wrap_at",
        type: "integer or nil",
        default: "nil",
        description: "Characters per line. Unset is one Row, which cannot wrap."
      },
      %{
        name: "line_space",
        type: "number",
        default: "4",
        description: "Gap between wrapped lines."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: "Mark's amber",
        description: "Highlight fill."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "Mark's ink",
        description: "Marked text colour."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Unmarked text colour."
      },
      %{name: "text_size", type: "size token", default: ":base", description: "Size for both."}
    ]
  end

  @impl true
  def handle({:hl_query, q}, socket), do: Mob.Socket.assign(socket, :hl_query, q)
  def handle(_tag, socket), do: socket

  defp query_buttons(current) do
    @queries
    |> Enum.map(fn q ->
      %{
        type: :button,
        props: %{
          text: q,
          background: if(q == current, do: :primary, else: :surface_raised),
          text_color: if(q == current, do: :on_primary, else: :on_surface),
          padding: :space_sm,
          on_tap: {self(), {:hl_query, q}}
        },
        children: []
      }
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 6}, children: []})
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={26} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={5} />
        <Box width={34} height={14} background={0xFFFDE68A} corner_radius={:radius_sm} />
        <Spacer size={5} />
        <Box width={30} height={10} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={20} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={5} />
        <Box width={28} height={14} background={0xFFFDE68A} corner_radius={:radius_sm} />
        <Spacer size={5} />
        <Box width={40} height={10} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end

  @doc false
  def sentence, do: @sentence
end
