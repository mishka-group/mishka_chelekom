defmodule MishkaMob.Showcase.Components.Card do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCard`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :card,
      name: "Card",
      category: "Data display",
      order: 5,
      description: "A surface that holds a figure, a title, content and actions."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :card_taps, 0)

  @impl true
  def handle(:card_tap, socket) do
    Mob.Socket.assign(socket, :card_taps, socket.assigns.card_taps + 1)
  end

  def handle(_tag, socket), do: socket

  @impl true
  def examples do
    [
      %Example{
        title: "A plain surface",
        description:
          "A fill, corners, a shadow and padding. The content is whatever the " <>
            "caller puts inside it.",
        code: ~S"""
        <MishkaCard background={:surface_raised} corner_radius={:radius_md}
                    shadow="0 2 6 0 #141A1917" padding={:space_md}>
          <Text text="A card is a surface, not a layout." />
        </MishkaCard>
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaCard
            id="card-plain"
            background={:surface_raised}
            corner_radius={:radius_md}
            shadow="0 2 6 0 #141A1917"
            padding={:space_md}
          >
            <Text text="A card is a surface, not a layout." text_color={:on_surface} />
          </MishkaCard>
          """
        end
      },
      %Example{
        title: "Title, content and actions, written as slots",
        description:
          "The web card's parts: the title reads first, the content follows and the " <>
            "actions are a row at the end. The figure is optional.",
        code: ~S"""
        <MishkaCard background={:surface_raised} corner_radius={:radius_md} padding={:space_md}>
          <MishkaCardFigure>
            <Box width={72} height={72} corner_radius={:radius_sm} background={:surface} />
          </MishkaCardFigure>
          <MishkaCardTitle>
            <Text text="Reading list" text_size={:lg} font_weight={:bold} />
          </MishkaCardTitle>
          <Text text="Three books, one goal." />
          <MishkaCardActions>
            <Button text="Open" on_tap={:open_list} />
          </MishkaCardActions>
        </MishkaCard>
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaCard
            id="card-slots"
            background={:surface_raised}
            corner_radius={:radius_md}
            padding={:space_md}
          >
            <MishkaCardFigure>
              <Box width={72} height={72} corner_radius={:radius_sm} background={:surface} />
            </MishkaCardFigure>
            <MishkaCardTitle>
              <Text text="Reading list" text_size={:lg} font_weight="bold" text_color={:on_surface} />
            </MishkaCardTitle>
            <Text text="Three books, one goal." text_color={:muted} />
            <Spacer size={10} />
            <MishkaCardActions>
              <Button
                text="Open"
                background={:primary}
                text_color={:on_primary}
                padding={:space_sm}
                on_tap={{self(), :card_open}}
              />
            </MishkaCardActions>
          </MishkaCard>
          """
        end
      },
      %Example{
        title: "A figure before or after the body",
        description:
          "figure_position decides the order. With direction: :row the body takes the " <>
            "space beside the figure.",
        code: ~S"""
        <MishkaCard direction={:row} align={:center} figure={poster} figure_position={:end}
                    background={:surface_raised} corner_radius={:radius_md} padding={:space_md}>
          <Column weight={1.0}>
            <Text text="Dune" text_size={:lg} font_weight={:bold} />
            <Text text="2021" />
          </Column>
        </MishkaCard>
        """,
        render: fn _assigns ->
          figure = %{
            type: :box,
            props: %{width: 84, height: 84, corner_radius: :radius_sm, background: :surface},
            children: []
          }

          ~MOB"""
          <MishkaCard
            id="card-figure"
            direction={:row}
            align={:center}
            figure={figure}
            figure_position={:end}
            background={:surface_raised}
            corner_radius={:radius_md}
            padding={:space_md}
          >
            <Column weight={1.0}>
              <Text text="Dune" text_size={:lg} font_weight="bold" text_color={:on_surface} />
              <Text text="2021" text_color={:muted} />
            </Column>
          </MishkaCard>
          """
        end
      },
      %Example{
        title: "Tappable",
        description:
          "on_tap makes the whole surface one target. In a list, give each card its own " <>
            "tag so the handler can say which one moved.",
        code: ~S"""
        <MishkaCard on_tap={:card_tap} background={:surface_raised}
                    corner_radius={:radius_md} padding={:space_md}>
          <Text text="Tap this card" />
        </MishkaCard>

        def handle_info({:tap, :card_tap}, socket) do
          {:noreply, Mob.Socket.assign(socket, :taps, socket.assigns.taps + 1)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCard
              id="card-tap"
              on_tap={{self(), :card_tap}}
              background={:surface_raised}
              corner_radius={:radius_md}
              padding={:space_md}
            >
              <Text text="Tap this card" text_color={:on_surface} />
            </MishkaCard>
            <Spacer size={8} />
            <Text text={taps_label(@card_taps)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Cards sharing a row",
        description:
          "weight hands the card a share of its parent, exactly as it does for any " <>
            "Mob node — two cards at 1.0 split the row evenly.",
        code: ~S"""
        <Row fill_width={true} align="top">
          <MishkaCard weight={1.0} background={:surface_raised} padding={:space_sm}>
            <Text text="Left" />
          </MishkaCard>
          <Spacer size={12} />
          <MishkaCard weight={1.0} background={:surface_raised} padding={:space_sm}>
            <Text text="Right" />
          </MishkaCard>
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true} align="top">
            <MishkaCard weight={1.0} background={:surface_raised} padding={:space_sm}>
              <Text text="Left" text_color={:on_surface} />
            </MishkaCard>
            <Spacer size={12} />
            <MishkaCard weight={1.0} background={:surface_raised} padding={:space_sm}>
              <Text text="Right" text_color={:on_surface} />
            </MishkaCard>
          </Row>
          """
        end
      }
    ]
  end

  defp taps_label(0), do: "No taps yet."
  defp taps_label(n), do: "Tapped #{n} time(s)."

  @impl true
  def props do
    [
      %{
        name: "direction",
        type: ":column | :row",
        default: ":column",
        description: "Whether the root stacks its children or lays them side by side."
      },
      %{
        name: "title",
        type: "string | node | list of nodes",
        default: "nil",
        description: "Drawn first in the body. A string becomes a bare Text."
      },
      %{
        name: "figure",
        type: "node | list of nodes",
        default: "nil",
        description: "Drawn inside the root, before or after the body."
      },
      %{
        name: "figure_position",
        type: ":start | :end",
        default: ":start",
        description: "Whether the figure comes before or after the body."
      },
      %{
        name: "actions",
        type: "node | list of nodes",
        default: "nil",
        description: "Drawn last in the body."
      },
      %{
        name: "fill_width",
        type: "boolean",
        default: "true",
        description: "Span the parent instead of hugging its content."
      },
      %{
        name: "weight",
        type: "number",
        default: "nil",
        description:
          "Share of a parent Row/Column, as on any Mob node. Two cards at weight 1.0 " <>
            "split their row evenly."
      },
      %{
        name: "background",
        type: "color token / ARGB int",
        default: "nil",
        description: "Surface fill."
      },
      %{
        name: "corner_radius",
        type: "radius token / number",
        default: "nil",
        description: "Corner rounding."
      },
      %{name: "shadow", type: "shadow string", default: "nil", description: "Drop shadow."},
      %{
        name: "padding / padding_top / … / padding_left",
        type: "spacing token / number",
        default: "nil",
        description: "Padding on all four sides, or one edge at a time."
      },
      %{
        name: "border_color / border_width",
        type: "color / number",
        default: "nil",
        description: "An outline; both are needed to draw one."
      },
      %{
        name: "align",
        type: ":center, :leading, …",
        default: "nil",
        description: "Cross-axis alignment when direction: :row."
      },
      %{
        name: "on_tap",
        type: "event tag",
        default: "nil",
        description: "Makes the surface tappable."
      },
      %{name: "id", type: "string", default: "nil", description: "Native testTag."}
    ]
  end
end
