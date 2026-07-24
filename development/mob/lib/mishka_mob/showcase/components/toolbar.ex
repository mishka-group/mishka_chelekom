defmodule MishkaMob.Showcase.Components.Toolbar do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaToolbar` and
  `MishkaMob.Components.MishkaBurger`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaToolbar, only: [toolbar: 2, separator: 0]
  import MishkaMob.Components.MishkaToggle, only: [toggle: 1]
  import MishkaMob.Components.MishkaActionIcon, only: [action_icon: 1]
  import MishkaMob.Components.MishkaBurger, only: [burger: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :toolbar,
      name: "Toolbar",
      category: "Navigation",
      order: 3,
      description: "A strip of related controls, with separators between groups."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:tb_bold, true)
    |> Mob.Socket.assign(:tb_italic, false)
    |> Mob.Socket.assign(:tb_nav, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A formatting strip",
        description: "It holds your controls — toggles, icons — rather than inventing its own.",
        code: ~S"""
        {toolbar([], [
          toggle(label: "B", pressed: @bold?, on_change: :bold),
          toggle(label: "I", pressed: @italic?, on_change: :italic),
          separator(),
          action_icon(icon: "↺", on_tap: :undo)
        ])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {toolbar([], [
              toggle(label: " B ", pressed: @tb_bold, on_change: :tb_bold),
              toggle(label: " I ", pressed: @tb_italic, on_change: :tb_italic),
              separator(),
              action_icon(icon: "↺", on_tap: :tb_noop),
              action_icon(icon: "↻", on_tap: :tb_noop)
            ])}
          </Column>
          """
        end
      },
      %Example{
        title: "Vertical",
        description: "The separator orients itself to the toolbar's axis.",
        code: ~S"""
        {toolbar([orientation: :vertical], items)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {toolbar([orientation: :vertical], [
              action_icon(icon: "✎", on_tap: :tb_noop),
              action_icon(icon: "⧉", on_tap: :tb_noop),
              separator(),
              action_icon(icon: "🗑", on_tap: :tb_noop)
            ])}
          </Row>
          """
        end
      },
      %Example{
        title: "Burger",
        description: "Three bars, and a ✕ when open — one control, one tap target.",
        code: ~S"""
        {burger(opened: @nav_open?, on_toggle: :toggle_nav)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {burger(opened: @tb_nav, on_toggle: :tb_nav)}
              <Spacer size={12} />
              {burger(opened: @tb_nav, on_toggle: :tb_nav, color: :primary)}
              <Spacer size={12} />
              {burger(disabled: true)}
            </Row>
            <Spacer size={10} />
            <Text
              text={if(@tb_nav, do: "Navigation open", else: "Navigation closed")}
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
  def props do
    [
      %{
        name: "orientation",
        type: ":horizontal · :vertical",
        default: ":horizontal",
        description: "Layout axis. Separators follow it."
      },
      %{name: "space", type: "number", default: "8", description: "Gap between items."},
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Strip fill."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Strip corners."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_sm",
        description: "Padding inside the strip."
      },
      %{
        name: "separator/0",
        type: "builder",
        default: "—",
        description: "A divider that orients itself to the toolbar."
      },
      %{
        name: "Burger: opened / on_toggle / size / color",
        type: "see MishkaBurger",
        default: "—",
        description: "The three-bar nav button, sharing this page."
      }
    ]
  end

  @impl true
  def handle(:tb_bold, socket), do: flip(socket, :tb_bold)
  def handle(:tb_italic, socket), do: flip(socket, :tb_italic)
  def handle(:tb_nav, socket), do: flip(socket, :tb_nav)
  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} background={:surface_raised} corner_radius={:radius_md} padding={6}>
      <Row fill_width={true}>
        <Box width={26} height={22} background={:primary} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={26} height={22} background={:surface} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={1} height={22} background={:border} />
        <Spacer size={6} />
        <Box width={26} height={22} background={:surface} corner_radius={:radius_sm} />
      </Row>
    </Box>
    """
  end
end
