defmodule MishkaMob.Showcase.Components.Tooltip do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTooltip`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :tooltip,
      name: "Tooltip",
      category: "Overlays",
      order: 4,
      description: "A short hint about the control beside it."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :tip, nil)

  @impl true
  def examples do
    [
      %Example{
        title: "Tap to reveal",
        description: "There is no hover on a phone, so the trigger is a tap you wire.",
        code: ~S"""
        <Row>
          <MishkaActionIcon icon="⧉" on_tap={:hint_copy} />
          <MishkaTooltip text="Copy" open={@tip == :copy} />
        </Row>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              <MishkaActionIcon icon="⧉" variant={:filled} on_tap={{:tip, :copy}} />
              <Spacer size={8} />
              <MishkaActionIcon icon="↗" variant={:filled} on_tap={{:tip, :share}} />
              <Spacer size={8} />
              <MishkaActionIcon icon="🗑" variant={:filled} on_tap={{:tip, :delete}} />
            </Row>
            <Spacer size={10} />
            <MishkaTooltip text={hint(@tip)} open={@tip != nil} />
          </Column>
          """
        end
      },
      %Example{
        title: "Dark by default",
        description: "A hint, not a panel — it reads over any surface.",
        code: ~S"""
        <MishkaTooltip text="Saved to your library" open={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTooltip text="Saved to your library" open={true} />
            <Spacer size={10} />
            <MishkaTooltip text="Custom colours" open={true} background={0xFF7C3AED} />
          </Column>
          """
        end
      },
      %Example{
        title: "Closed",
        description: "Renders nothing at all, so it takes no space in the layout.",
        code: ~S"""
        <MishkaTooltip text="Hidden" open={false} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="A closed tooltip contributes no node — the row below is unaffected."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={8} />
            <MishkaTooltip text="You cannot see me" open={false} />
            <Box fill_width={true} height={28} background={:surface_raised} corner_radius={:radius_sm} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "text", type: "string", default: "nil", description: "The hint."},
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether it is shown. Lives in the screen."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: "0xFF111827",
        description: "Bubble fill — dark so it reads over any surface."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "0xFFFFFFFF",
        description: "Hint colour."
      },
      %{name: "text_size", type: "size token", default: ":sm", description: "Hint size."},
      %{
        name: "offset_x / offset_y",
        type: "number",
        default: "nil",
        description: "Static nudge in dp. Not anchoring."
      }
    ]
  end

  @impl true
  def handle({:tip, which}, socket) do
    next = if socket.assigns.tip == which, do: nil, else: which
    Mob.Socket.assign(socket, :tip, next)
  end

  def handle(_tag, socket), do: socket

  defp hint(:copy), do: "Copy to clipboard"
  defp hint(:share), do: "Share a link"
  defp hint(:delete), do: "Delete for everyone"
  defp hint(_), do: ""

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={28} height={28} background={:surface_raised} corner_radius={:radius_md} />
        <Spacer size={8} />
        <Box width={28} height={28} background={:surface_raised} corner_radius={:radius_md} />
      </Row>
      <Spacer size={10} />
      <Box width={104} height={22} background={0xFF111827} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
