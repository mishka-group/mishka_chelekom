defmodule MishkaMob.Showcase.Components.Separator do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSeparator`.

  The examples are written with the `~MOB` sigil: native widgets as tags, the
  Chelekom component as an interpolated function call — the same split HEEx
  makes between `<div>` and `<.function_component />`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :separator,
      name: "Separator",
      category: "Layout",
      order: 0,
      description: "A thematic rule between groups of content, with an optional label."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Plain rule",
        description: "A horizontal divider between two blocks.",
        code: ~S"""
        <Column fill_width={true}>
          <Text text="Section one" />
          <MishkaSeparator />
          <Text text="Section two" />
        </Column>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Section one" text_color={:on_surface} />
            <Spacer size={12} />
            <MishkaSeparator id="sep-plain" />
            <Spacer size={12} />
            <Text text="Section two" text_color={:on_surface} />
          </Column>
          """
        end
      },
      %Example{
        title: "Labelled",
        description: "A label centred between two rules — line — label — line.",
        code: ~S"""
        <MishkaSeparator label="or continue with" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSeparator label="or continue with" id="sep-or" />
            <Spacer size={16} />
            <MishkaSeparator label="1994" id="sep-year" />
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and thickness",
        description: "Any colour token or ARGB int, and a thicker rule.",
        code: ~S"""
        <MishkaSeparator color={0xFF7C3AED} thickness={3} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSeparator color={0xFF7C3AED} thickness={3} id="sep-thick" />
            <Spacer size={14} />
            <MishkaSeparator color={:primary} thickness={2} id="sep-primary" />
            <Spacer size={14} />
            <MishkaSeparator color={:muted} label="muted + thick" thickness={2} id="sep-muted" />
          </Column>
          """
        end
      },
      %Example{
        title: "Vertical",
        description: "Set orientation to :vertical inside a Row. Needs a parent with height.",
        code: ~S"""
        <Row>
          <Text text="Left" />
          <MishkaSeparator orientation={:vertical} />
          <Text text="Right" />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box height={28} fill_width={true}>
            <Row fill_width={true}>
              <Text text="Docs" text_color={:on_surface} />
              <Spacer size={12} />
              <MishkaSeparator orientation={:vertical} id="sep-vert" />
              <Spacer size={12} />
              <Text text="Guides" text_color={:on_surface} />
              <Spacer size={12} />
              <MishkaSeparator orientation={:vertical} color={:primary} thickness={2} id="sep-vert-thick" />
              <Spacer size={12} />
              <Text text="API" text_color={:on_surface} />
            </Row>
          </Box>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Rule axis. A vertical rule needs a parent that gives it height."
      },
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Renders line — label — line. Horizontal only."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":border",
        description: "Rule colour."
      },
      %{
        name: "thickness",
        type: "number",
        default: "1",
        description: "Rule thickness in dp/pt."
      },
      %{
        name: "space",
        type: "number",
        default: "12",
        description: "Gap between the label and the lines."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Test tag. A labelled rule also tags each line <id>-line-start / -line-end."
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <MishkaSeparator />
      <Spacer size={10} />
      <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={6} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
