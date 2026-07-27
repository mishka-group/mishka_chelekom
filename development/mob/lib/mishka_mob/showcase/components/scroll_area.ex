defmodule MishkaMob.Showcase.Components.ScrollArea do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaScrollArea`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :scroll_area,
      name: "Scroll Area",
      category: "Layout",
      order: 1,
      description: "A bounded region whose content scrolls."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Vertical",
        description: "height bounds the viewport — without it, nothing scrolls.",
        code: ~S"""
        <MishkaScrollArea height={200} background={:surface_raised}>{rows()}</MishkaScrollArea>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaScrollArea
              height={200}
              background={:surface_raised}
              corner_radius={:radius_md}
              padding={:space_md}
            >
              {rows(12)}
            </MishkaScrollArea>
          </Column>
          """
        end
      },
      %Example{
        title: "Horizontal",
        description: "orientation: :horizontal scrolls a wide row.",
        code: ~S"""
        <MishkaScrollArea orientation={:horizontal}>{wide_row()}</MishkaScrollArea>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaScrollArea
              orientation={:horizontal}
              background={:surface_raised}
              corner_radius={:radius_md}
              padding={:space_md}
            >
              {[wide_row()]}
            </MishkaScrollArea>
          </Column>
          """
        end
      },
      %Example{
        title: "Undecorated",
        description: "With no height or styling it is a single Scroll node.",
        code: ~S"""
        <MishkaScrollArea>{content}</MishkaScrollArea>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box
            fill_width={true}
            height={120}
            background={:surface_raised}
            corner_radius={:radius_md}
            padding={:space_md}
          >
            <MishkaScrollArea>
              {rows(8)}
            </MishkaScrollArea>
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
        type: ":vertical · :horizontal",
        default: ":vertical",
        description: "Scroll axis. \"both\" is not ported — nest two scrollers."
      },
      %{
        name: "height",
        type: "number",
        default: "nil",
        description: "Viewport height. Required for a vertical scroller to scroll at all."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Registers the scroller so Mob.Test.scroll_to/2 can address it."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: "nil",
        description: "Viewport fill."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: "nil",
        description: "Padding inside the viewport."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: "nil",
        description: "Rounds the viewport."
      }
    ]
  end

  defp rows(n) do
    Enum.flat_map(1..n, fn i ->
      [
        %{
          type: :text,
          props: %{text: "Row #{i}", text_size: :base, text_color: :on_surface},
          children: []
        },
        %{type: :spacer, props: %{size: 12}, children: []}
      ]
    end)
  end

  defp wide_row do
    tiles =
      Enum.flat_map(1..10, fn i ->
        [
          %{
            type: :box,
            props: %{
              width: 90,
              height: 60,
              background: if(rem(i, 2) == 0, do: :primary, else: :muted),
              corner_radius: :radius_md
            },
            children: []
          },
          %{type: :spacer, props: %{size: 8}, children: []}
        ]
      end)

    %{type: :row, props: %{}, children: tiles}
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Box
      fill_width={true}
      height={70}
      background={:surface_raised}
      corner_radius={:radius_md}
      padding={8}
    >
      <Column fill_width={true}>
        <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box fill_width={true} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={60} height={10} background={:muted} corner_radius={:radius_sm} />
      </Column>
    </Box>
    """
  end
end
