defmodule MishkaMob.Showcase.Components.Dock do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaDock` and `MishkaDockItem`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :dock,
      name: "Dock",
      category: "Navigation",
      order: 8,
      description: "A floating bar of icon items, with an optional action beside it."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Four items and an action",
        description:
          "Each item takes an equal share of the bar. The active look is props: " <>
            "the well's fill and the glyph's colour and family.",
        code: ~S"""
        <MishkaDock background={:surface_raised} shadow="0 8 16 -12 #801A1917"
                    padding_left={18} padding_right={18} padding_bottom={30}
                    fab={<MishkaActionIcon icon="+" variant={:filled} shape={:circle} size={64} on_tap={:add} />}>
          <MishkaDockItem icon="⌂" active={true} on_tap={:home}
                          active_background={:surface} active_color={:on_surface} />
          <MishkaDockItem icon="▦" on_tap={:library} />
          <MishkaDockItem icon="◔" on_tap={:stats} />
        </MishkaDock>

        def handle_info({:tap, tag}, socket) when tag in [:home, :library, :stats, :add] do
          {:noreply, socket}
        end
        """,
        render: fn _assigns ->
          fab = ~MOB"""
          <Box id="dock-fab" fill_width={false}>
            <MishkaActionIcon icon="+" variant={:filled} shape={:circle} size={56} on_tap={:dock_tap} />
          </Box>
          """

          assigns = %{fab: fab}

          ~MOB"""
          <Column fill_width={true}>
            <MishkaDock
              id="dock-bar"
              background={:surface_raised}
              shadow="0 8 16 -12 #801A1917"
              padding_left={18}
              padding_right={18}
              padding_bottom={30}
              fab={@fab}
            >
              <MishkaDockItem
                id="dock-item-home"
                icon="⌂"
                active={true}
                on_tap={:dock_tap}
                active_background={:surface}
                active_color={:on_surface}
              />
              <MishkaDockItem id="dock-item-library" icon="▦" on_tap={:dock_tap} />
              <MishkaDockItem id="dock-item-stats" icon="◔" on_tap={:dock_tap} />
            </MishkaDock>
            <Spacer size={8} />
            <Text
              text="The bar is a Row; wrap it to pin it to the bottom."
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Items only",
        description: "No action node: the bar takes the whole row. weight moves on the item.",
        code: ~S"""
        <MishkaDock background={:surface_raised}>
          <MishkaDockItem icon="A" on_tap={:a} />
          <MishkaDockItem icon="B" on_tap={:b} weight={2.0} />
        </MishkaDock>

        def handle_info({:tap, tag}, socket) when tag in [:a, :b], do: {:noreply, socket}
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaDock background={:surface_raised}>
            <MishkaDockItem icon="A" on_tap={:dock_tap} />
            <MishkaDockItem icon="B" on_tap={:dock_tap} weight={2.0} />
          </MishkaDock>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "background",
        type: "color token / ARGB int",
        default: ":surface_raised",
        description: "The floating bar's fill."
      },
      %{
        name: "height / corner_radius",
        type: "number / radius token",
        default: "64 / :radius_pill",
        description: "The bar's height and corners."
      },
      %{
        name: "shadow",
        type: "string",
        default: "nil",
        description: "The shadow that makes the bar float."
      },
      %{
        name: "padding_*",
        type: "spacing token / number",
        default: "nil",
        description: "Around the bar row; the bottom number lifts it off the edge."
      },
      %{
        name: "fab",
        type: "node",
        default: "nil",
        description: "Drawn beside the bar in the same row."
      },
      %{
        name: "DockItem: icon",
        type: "string",
        default: "nil",
        description: "The glyph; children override it."
      },
      %{
        name: "DockItem: active",
        type: "boolean",
        default: "false",
        description:
          "Chooses active_background/active_color/active_font_family over their " <>
            "inactive counterparts."
      },
      %{
        name: "DockItem: weight",
        type: "number",
        default: "1.0",
        description: "Share of the dock's row."
      }
    ]
  end
end
