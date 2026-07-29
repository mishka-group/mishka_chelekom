defmodule MishkaMob.Showcase.Components.ColorSwatch do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaColorSwatch`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaColorSwatch, only: [color_swatch: 1]

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
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A palette",
        description:
          "Selection draws a ring and a ✓. The name below comes back from the " <>
            "screen, so the tap really made the round trip.",
        code: ~S"""
        # A swatch carries no value — the TAG is what identifies it, so put the
        # colour's id in there. One handler then serves the whole palette.
        swatches =
          Enum.map(@palette, fn {id, color} ->
            ~MOB"<MishkaColorSwatch color={color} selected={@picked == id} on_tap={{:pick, id}} />"
          end)

        def handle_info({:tap, {:pick, id}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :picked, id)}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {swatches(@sw_picked)}
            </Row>
            <Spacer size={12} />
            <Row fill_width={true} align={:center}>
              <Text text="Picked:" text_size={:sm} text_color={:muted} />
              <Spacer size={8} />
              <MishkaColorSwatch color={picked_color(@sw_picked)} size={20} />
              <Spacer size={8} />
              <Text text={picked_label(@sw_picked)} text_size={:sm} text_color={:on_surface} />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted intent: the swatch still shows its colour, but wires no handler.",
        code: ~S"""
        # on_tap is given and never wired — disabled drops the handler rather
        # than guarding it, so nothing is sent and nothing needs ignoring.
        <MishkaColorSwatch color={0xFF3B82F6} disabled={true} on_tap={{:pick, :blue}} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaColorSwatch color={0xFF64748B} disabled={true} on_tap={{:sw_pick, :slate}} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0x8064748B} disabled={true} on_tap={{:sw_pick, :slate_soft}} />
          </Row>
          """
        end
      },
      %Example{
        title: "Transparency",
        description: "A translucent colour is drawn over a checkerboard — otherwise it lies.",
        code: ~S"""
        # The checkerboard appears on its own below full alpha. checkerboard={true}
        # forces it on an opaque colour; false turns it off.
        <MishkaColorSwatch color={0x807C3AED} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaColorSwatch color={0xFF7C3AED} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0xCC7C3AED} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0x807C3AED} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0x337C3AED} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0x00000000} />
          </Row>
          """
        end
      },
      %Example{
        title: "Shapes and sizes",
        description: "A circle uses an exact size/2 radius.",
        code: ~S"""
        <MishkaColorSwatch color={0xFF10B981} shape={:circle} size={48} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaColorSwatch color={0xFF10B981} shape={:circle} size={48} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0xFF10B981} shape={:rounded} />
            <Spacer size={10} />
            <MishkaColorSwatch color={0xFF10B981} shape={:square} size={28} />
          </Row>
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
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler. The colour still shows."
      },
      %{
        name: "id",
        type: "string",
        default: "—",
        description: "Becomes a native testTag. A swatch has no text to find it by."
      }
    ]
  end

  @impl true
  def handle({:sw_pick, id}, socket), do: Mob.Socket.assign(socket, :sw_picked, id)

  def handle(_tag, socket), do: socket

  defp picked_color(id), do: Keyword.get(@palette, id, 0x00000000)
  defp picked_label(id), do: id |> Atom.to_string() |> String.capitalize()

  defp swatches(picked) do
    @palette
    |> Enum.map(fn {id, color} ->
      color_swatch(
        color: color,
        selected: id == picked,
        on_tap: {:sw_pick, id},
        id: "swatch-#{id}"
      )
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
