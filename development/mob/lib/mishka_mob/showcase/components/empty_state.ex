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
        description: "Actions are laid out in a row beneath the text.",
        code: ~S"""
        <MishkaEmptyState actions={[primary_button(), secondary_button()]} … />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md}>
            <MishkaEmptyState
              indicator="📁"
              title="No projects yet"
              description="Create one to get started."
              actions={[
                button("New project", :primary, :on_primary),
                gap(),
                button("Import", :surface, :on_surface)
              ]}
            />
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
      }
    ]
  end

  defp button(label, background, text_color) do
    %{
      type: :button,
      props: %{
        text: label,
        background: background,
        text_color: text_color,
        padding: :space_sm,
        on_tap: {self(), :es_noop}
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
