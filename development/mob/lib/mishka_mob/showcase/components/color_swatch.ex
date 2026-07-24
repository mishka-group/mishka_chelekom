defmodule MishkaMob.Showcase.Components.ColorSwatch do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaColorSwatch` and
  `MishkaMob.Components.MishkaLoadingOverlay`, which share a page as the two
  small "surface" utilities.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaColorSwatch, only: [color_swatch: 1]
  import MishkaMob.Components.MishkaLoadingOverlay, only: [loading_overlay: 1]

  alias MishkaMob.Showcase.Example

  @palette [
    {:violet, 0xFF7C3AED},
    {:blue, 0xFF3B82F6},
    {:green, 0xFF10B981},
    {:amber, 0xFFF59E0B},
    {:red, 0xFFDC2626}
  ]

  @impl true
  def entry do
    %{
      slug: :color_swatch,
      name: "Color Swatch",
      category: "Data display",
      order: 6,
      description: "A block of a single colour, with a transparency checkerboard."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sw_picked, :violet)
    |> Mob.Socket.assign(:sw_busy, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A palette",
        description: "Selection draws a ring and a ✓.",
        code: ~S"""
        {color_swatch(color: 0xFF7C3AED, selected: @picked == :violet, on_tap: {:pick, :violet})}
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {swatches(@sw_picked)}
          </Row>
          """
        end
      },
      %Example{
        title: "Transparency",
        description: "A translucent colour is drawn over a checkerboard — otherwise it lies.",
        code: ~S"""
        {color_swatch(color: 0x807C3AED)}   # checkerboard appears automatically
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {color_swatch(color: 0xFF7C3AED)}
            <Spacer size={10} />
            {color_swatch(color: 0xCC7C3AED)}
            <Spacer size={10} />
            {color_swatch(color: 0x807C3AED)}
            <Spacer size={10} />
            {color_swatch(color: 0x337C3AED)}
            <Spacer size={10} />
            {color_swatch(color: 0x00000000)}
          </Row>
          """
        end
      },
      %Example{
        title: "Shapes and sizes",
        description: "A circle uses an exact size/2 radius.",
        code: ~S"""
        {color_swatch(color: 0xFF10B981, shape: :circle, size: 48)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {color_swatch(color: 0xFF10B981, shape: :circle, size: 48)}
            <Spacer size={10} />
            {color_swatch(color: 0xFF10B981, shape: :rounded)}
            <Spacer size={10} />
            {color_swatch(color: 0xFF10B981, shape: :square, size: 28)}
          </Row>
          """
        end
      },
      %Example{
        title: "Loading overlay",
        description: "Covers its region AND absorbs taps, so a double submit is impossible.",
        code: ~S"""
        <Box>
          {content}
          {loading_overlay(visible: @saving?, label: "Saving…")}
        </Box>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box fill_width={true} height={120} background={:surface_raised} corner_radius={:radius_md}>
              <Column fill_width={true} padding={:space_md}>
                <Text text="Order #1042" text_size={:lg} text_color={:on_surface} />
                <Spacer size={6} />
                <Text text="Tap Save to see the overlay cover this." text_size={:sm} text_color={:muted} />
              </Column>
              {loading_overlay(visible: @sw_busy, label: "Saving…", corner_radius: :radius_md)}
            </Box>
            <Spacer size={12} />
            <Button
              text={if(@sw_busy, do: "Finish", else: "Save")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :sw_busy}}
            />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "color", type: "ARGB / token", default: "nil", description: "The colour shown."},
      %{name: "size", type: "number", default: "36", description: "Swatch edge."},
      %{
        name: "shape",
        type: ":rounded · :circle · :square",
        default: ":rounded",
        description: "Swatch shape."
      },
      %{
        name: "selected",
        type: "boolean",
        default: "false",
        description: "Draws a ring and a ✓."
      },
      %{name: "on_tap", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "checkerboard",
        type: "boolean",
        default: "auto",
        description: "Force the transparency backdrop. Auto-on below full alpha."
      },
      %{
        name: "LoadingOverlay: visible / label / scrim_color / color",
        type: "see MishkaLoadingOverlay",
        default: "—",
        description: "A scrim that covers a region and absorbs taps while it is busy."
      }
    ]
  end

  @impl true
  def handle({:sw_pick, id}, socket), do: Mob.Socket.assign(socket, :sw_picked, id)

  def handle(:sw_busy, socket),
    do: Mob.Socket.assign(socket, :sw_busy, not socket.assigns.sw_busy)

  def handle(_tag, socket), do: socket

  defp swatches(picked) do
    @palette
    |> Enum.map(fn {id, color} ->
      color_swatch(color: color, selected: id == picked, on_tap: {:sw_pick, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 10}, children: []})
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box width={28} height={28} background={0xFF7C3AED} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box width={28} height={28} background={0xFF3B82F6} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box width={28} height={28} background={0xFF10B981} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box width={28} height={28} background={0xFFF59E0B} corner_radius={:radius_sm} />
    </Row>
    """
  end
end
