defmodule MishkaMob.Showcase.Components.EmptyState do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaEmptyState`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :empty_state,
      name: "Empty State",
      category: "Feedback",
      order: 2,
      description: "The placeholder shown when a list has nothing in it."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :es_projects, [])

  @impl true
  def examples do
    [
      %Example{
        title: "Centred",
        description: "Fills a blank screen: indicator above the text.",
        code: ~S"""
        <MishkaEmptyState
          indicator="📭"
          title="No messages"
          description="Anything you receive lands here."
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md}>
            <MishkaEmptyState
              indicator="📭"
              title="No messages"
              description="Anything you receive lands here."
            />
          </Box>
          """
        end
      },
      %Example{
        title: "Leading",
        description: "Sits inside a card without looking like the screen has failed.",
        code: ~S"""
        <MishkaEmptyState align={:leading} indicator="🔍" title="No results" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box
            fill_width={true}
            background={:surface_raised}
            corner_radius={:radius_md}
            padding={:space_md}
          >
            <MishkaEmptyState
              align={:leading}
              indicator="🔍"
              title="No results"
              description="Try a different search term."
            />
          </Box>
          """
        end
      },
      %Example{
        title: "With actions",
        description:
          "Actions sit in a row beneath the text — and they work. Tap one: the " <>
            "empty state is what a list shows when it has nothing, so filling it " <>
            "is what makes the empty state go away.",
        code: ~S"""
        # `actions` is a PROP, not a slot — the tag's children are the indicator,
        # and a second slot cannot be expressed in ~MOB markup.
        <MishkaEmptyState
          indicator="📁"
          title="No projects yet"
          description="Create one to get started."
          actions={[button("New", :es_new), button("Import", :es_import)]}
        />

        # The buttons are yours, so the handlers are the ordinary ones. An empty
        # state carries no events of its own.
        def handle_info({:tap, :es_new}, socket) do
          {:noreply, Mob.Socket.assign(socket, :projects, ["Untitled" | socket.assigns.projects])}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md}>
            {projects_or_empty(@es_projects)}
          </Box>
          """
        end
      },
      %Example{
        title: "Text only",
        description: "Every part is optional.",
        code: ~S"""
        <MishkaEmptyState title="Nothing here" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md}>
            <MishkaEmptyState title="Nothing here" />
          </Box>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "title", type: "string", default: "nil", description: "Heading."},
      %{name: "description", type: "string", default: "nil", description: "Supporting text."},
      %{
        name: "align",
        type: ":center · :leading",
        default: ":center",
        description: "Indicator above the text, or beside it."
      },
      %{
        name: "indicator",
        type: "string",
        default: "nil",
        description: "A glyph or emoji. Pass nodes instead for an illustration."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_xl",
        description: "Padding around the block (centred layout)."
      },
      %{
        name: "actions",
        type: "list of nodes",
        default: "[]",
        description: "A row beneath the text. A PROP, because the children are the indicator."
      }
    ]
  end

  @impl true
  def handle(:es_new, socket),
    do:
      Mob.Socket.assign(socket, :es_projects, [
        "Untitled #{length(socket.assigns.es_projects) + 1}" | socket.assigns.es_projects
      ])

  def handle(:es_import, socket),
    do:
      Mob.Socket.assign(
        socket,
        :es_projects,
        ["Imported A", "Imported B"] ++ socket.assigns.es_projects
      )

  def handle(:es_reset, socket), do: Mob.Socket.assign(socket, :es_projects, [])
  def handle(_tag, socket), do: socket

  # The whole point of the component: it is what a list shows INSTEAD of itself.
  defp projects_or_empty([]) do
    ~MOB"""
    <MishkaEmptyState
      indicator="📁"
      title="No projects yet"
      description="Create one to get started."
      actions={[
        # Short labels on purpose: the actions Row does not wrap, and two wide
        # buttons inside :space_xl padding push the second one off the edge —
        # where it is never laid out and cannot be tapped at all.
        button("New", :primary, :on_primary, :es_new),
        gap(),
        button("Import", :surface, :on_surface, :es_import)
      ]}
    />
    """
  end

  defp projects_or_empty(projects) do
    rows =
      Enum.map(projects, fn name ->
        ~MOB"""
        <Row fill_width={true}>
          <Text text="📁" text_size={:base} text_color={:muted} />
          <Spacer size={10} />
          <Text text={name} text_size={:base} text_color={:on_surface} />
        </Row>
        """
      end)
      |> Enum.intersperse(~MOB(<Spacer size={10} />))

    ~MOB"""
    <Column fill_width={true} padding={:space_md}>
      {rows}
      <Spacer size={16} />
      <Button
        text="Delete them all"
        background={:surface}
        text_color={:on_surface}
        padding={:space_sm}
        fill_width={true}
        on_tap={{self(), :es_reset}}
      />
    </Column>
    """
  end

  defp button(label, background, text_color, tag) do
    %{
      type: :button,
      props: %{
        text: label,
        background: background,
        text_color: text_color,
        padding: :space_sm,
        on_tap: {self(), tag}
      },
      children: []
    }
  end

  defp gap, do: %{type: :spacer, props: %{size: 8}, children: []}

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true} align={:center}>
      <Box width={26} height={26} background={:muted} corner_radius={:radius_md} />
      <Spacer size={10} />
      <Box width={70} height={9} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={6} />
      <Box width={96} height={7} background={:surface_raised} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <Box width={54} height={18} background={:primary} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
