defmodule MishkaMob.Showcase.Components.Highlight do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaHighlight`.

  The first example is live: type-free, but the query cycles through buttons so
  the matching is visible rather than described.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaHighlight, only: [highlight: 1]

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
        title: "Matching a query",
        description: "Case-insensitive; the match renders as it appears in the text.",
        code: ~S"""
        {highlight(text: "Mishka Chelekom", highlight: @query)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {highlight(text: "Mishka Chelekom", highlight: @hl_query)}
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
        {highlight(text: "one two three", highlight: ["one", "three"])}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {highlight(text: "one two three", highlight: ["one", "three"])}
            <Spacer size={10} />
            {highlight(text: "BEAM on iOS and Android", highlight: ["iOS", "Android"])}
          </Column>
          """
        end
      },
      %Example{
        title: "No match, no marks",
        description: "An empty, nil or unmatched query leaves the text plain.",
        code: ~S"""
        {highlight(text: "nothing to mark", highlight: "")}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {highlight(text: "nothing to mark here", highlight: "")}
            <Spacer size={10} />
            {highlight(text: "nothing to mark here", highlight: "zzz")}
          </Column>
          """
        end
      },
      %Example{
        title: "Colours",
        description: "background and color tint the marks; text_color the rest.",
        code: ~S"""
        {highlight(text: "…", highlight: "beam", background: 0xFFBBF7D0)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {highlight(text: "green on the BEAM", highlight: "beam", background: 0xFFBBF7D0)}
            <Spacer size={10} />
            {highlight(text: "violet on the BEAM", highlight: "beam", background: 0xFFDDD6FE)}
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
        description: "Substring(s) to mark. Case-insensitive; blank and nil are ignored."
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
