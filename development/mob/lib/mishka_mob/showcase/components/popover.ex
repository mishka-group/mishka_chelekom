defmodule MishkaMob.Showcase.Components.Popover do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaPopover`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaPopover, only: [popover: 2]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :popover,
      name: "Popover",
      category: "Overlays",
      order: 3,
      description: "A small panel of content, placed in flow under its trigger."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pop_open, false)
    |> Mob.Socket.assign(:pop_wide, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Under its trigger",
        description: "Placed in flow — native dropdowns are built by layout, not by floating.",
        code: ~S"""
        <Column>
          <Button text="Details" on_tap={{self(), :toggle}} />
          {popover([open: @open?], content)}
        </Column>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Button
              text={if(@pop_open, do: "Hide details", else: "Show details")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :pop_toggle}}
            />
            <Spacer size={8} />
            {popover([open: @pop_open], body())}
          </Column>
          """
        end
      },
      %Example{
        title: "Fixed width",
        description: "width pins the panel; omit it to fill the parent.",
        code: ~S"""
        {popover([open: @open?, width: 240], content)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Button
              text={if(@pop_wide, do: "Hide", else: "Show a 240dp panel")}
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :pop_wide}}
            />
            <Spacer size={8} />
            {popover([open: @pop_wide, width: 240], body())}
          </Column>
          """
        end
      },
      %Example{
        title: "Chrome",
        description: "background, corner_radius, padding and the border are props.",
        code: ~S"""
        {popover([open: true, background: 0xFF1E1B4B, border_width: 0], content)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {popover([open: true, background: 0xFF1E1B4B, border_width: 0,
                      corner_radius: :radius_lg], tinted_body())}
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the panel is shown. Lives in the screen."
      },
      %{
        name: "width",
        type: "number",
        default: "nil",
        description: "Panel width. Omit to fill the parent."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface",
        description: "Panel fill."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Panel corners."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_md",
        description: "Padding inside the panel."
      },
      %{
        name: "border_color / border_width",
        type: "color / number",
        default: ":border / 1",
        description: "The edge separating it from the content beneath."
      },
      %{
        name: "offset_x / offset_y",
        type: "number",
        default: "nil",
        description: "Static nudge in dp. Not anchoring — see the moduledoc."
      }
    ]
  end

  @impl true
  def handle(:pop_toggle, socket), do: flip(socket, :pop_open)
  def handle(:pop_wide, socket), do: flip(socket, :pop_wide)
  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  defp body do
    [
      %{
        type: :text,
        props: %{text: "Shipped 2 days ago", text_size: :base, text_color: :on_surface},
        children: []
      },
      %{type: :spacer, props: %{size: 4}, children: []},
      %{
        type: :text,
        props: %{text: "Tracking arrives by email.", text_size: :sm, text_color: :muted},
        children: []
      }
    ]
  end

  defp tinted_body do
    [
      %{
        type: :text,
        props: %{text: "Any colour works", text_size: :base, text_color: 0xFFFFFFFF},
        children: []
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box width={70} height={20} background={:primary} corner_radius={:radius_sm} />
      <Spacer size={8} />
      <Box
        fill_width={true}
        background={:surface}
        corner_radius={:radius_md}
        border_color={:border}
        border_width={1}
        padding={8}
      >
        <Column fill_width={true}>
          <Box width={70} height={7} background={:muted} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box fill_width={true} height={6} background={:surface_raised} corner_radius={:radius_sm} />
        </Column>
      </Box>
    </Column>
    """
  end
end
