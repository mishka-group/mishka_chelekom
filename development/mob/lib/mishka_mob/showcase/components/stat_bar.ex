defmodule MishkaMob.Showcase.Components.StatBar do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaStatBar`.

  A labelled measurement: name, reading, and the bar that shows the reading
  against its scale. The reading is always the caller's string — the component
  never formats a number.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :stat_bar,
      name: "Stat Bar",
      category: "Data display",
      order: 900,
      description: "A label, a reading, and a bar showing that reading against a scale."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Where the hours went",
        description: "One row per name; the reading is the caller's own unit.",
        code: ~S"""
        <MishkaStatBar label="Action" value={0.52} value_text="52%" color={0xFF4E9A73} />
        <MishkaStatBar label="Adventure" value={0.3} value_text="30%" color={0xFFB08E55} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaStatBar label="Action" value={0.52} value_text="52%" color={0xFF4E9A73} />
            <Spacer size={14} />
            <MishkaStatBar label="Adventure" value={0.3} value_text="30%" color={0xFFB08E55} />
            <Spacer size={14} />
            <MishkaStatBar label="Science fiction" value={1.0} value_text="100%" color={0xFF4E9A73} />
            <Spacer size={14} />
            <MishkaStatBar label="Everything else" value={0.52} value_text="52%" />
          </Column>
          """
        end
      },
      %Example{
        title: "A percentage, a thin bar, no reading",
        description: "The unit and the type are props; nothing is assumed.",
        code: ~S"""
        <MishkaStatBar value={0.72} value_text="72%" height={4} corner_radius={2} />
        <MishkaStatBar label="Storage" value={0.9} height={10} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaStatBar label="Progress" value={0.72} value_text="72%" height={4} corner_radius={2} />
            <Spacer size={16} />
            <MishkaStatBar label="Storage" value={1.4} height={10} corner_radius={5} />
            <Spacer size={8} />
            <Text
              text="1.4 clamps to a full bar; a missing value reads empty."
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
  def card_preview do
    ~MOB"""
    <Column fill_width={true} padding_top={6} padding_bottom={6}>
      <Row fill_width={true} align="center">
        <Box width={40} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
        <Box width={22} height={8} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={9} />
      <Box fill_width={true} height={9} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={112} height={9} background={:primary} corner_radius={:radius_pill} />
      </Box>
      <Spacer size={9} />
      <Row fill_width={true} align="center">
        <Box width={52} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer weight={1} />
      </Row>
      <Spacer size={7} />
      <Box fill_width={true} height={7} background={:surface_raised} corner_radius={:radius_pill}>
        <Box width={64} height={7} background={:primary} corner_radius={:radius_pill} />
      </Box>
    </Column>
    """
  end

  @impl true
  def props do
    [
      %{name: "label", type: "string", default: "nil", description: "The name on the left."},
      %{name: "value", type: "number", default: "0", description: "Fraction 0.0..1.0, clamped."},
      %{
        name: "value_text",
        type: "string",
        default: "nil",
        description: "The reading on the right."
      },
      %{name: "color", type: "color / ARGB", default: ":primary", description: "The fill."},
      %{
        name: "track_color",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "The groove."
      },
      %{name: "height", type: "number", default: "6", description: "Bar thickness."},
      %{name: "corner_radius", type: "number", default: "3", description: "Bar rounding."},
      %{name: "gap", type: "number", default: "8", description: "Space above the bar."},
      %{
        name: "font_family",
        type: "string",
        default: "unset",
        description: "Applied to both texts."
      },
      %{name: "id", type: "string", default: "nil", description: "TestTag; the bar is id-bar."}
    ]
  end
end
