defmodule MishkaMob.Showcase.Components.Separator do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSeparator`.

  The examples are written with the `~MOB` sigil: native widgets as tags, the
  Chelekom component as an interpolated function call — the same split HEEx
  makes between `<div>` and `<.function_component />`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaSeparator, only: [separator: 0, separator: 1]

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
          {separator()}
          <Text text="Section two" />
        </Column>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text text="Section one" text_color={:on_surface} />
            <Spacer size={12} />
            {separator()}
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
        {separator(label: "or continue with")}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {separator(label: "or continue with")}
            <Spacer size={16} />
            {separator(label: "1994")}
          </Column>
          """
        end
      },
      %Example{
        title: "Colour and thickness",
        description: "Any colour token or ARGB int, and a thicker rule.",
        code: ~S"""
        {separator(color: 0xFF7C3AED, thickness: 3)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {separator(color: 0xFF7C3AED, thickness: 3)}
            <Spacer size={14} />
            {separator(color: :primary, thickness: 2)}
            <Spacer size={14} />
            {separator(color: :muted, label: "muted + thick", thickness: 2)}
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
          {separator(orientation: :vertical)}
          <Text text="Right" />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box height={28} fill_width={true}>
            <Row fill_width={true}>
              <Text text="Docs" text_color={:on_surface} />
              <Spacer size={12} />
              {separator(orientation: :vertical)}
              <Spacer size={12} />
              <Text text="Guides" text_color={:on_surface} />
              <Spacer size={12} />
              {separator(orientation: :vertical, color: :primary, thickness: 2)}
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
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      {separator()}
      <Spacer size={10} />
      <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={6} />
      <Box fill_width={true} height={10} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
