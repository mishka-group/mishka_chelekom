defmodule MishkaMob.Showcase.Components.Drawer do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaDrawer`.

  Interactive: the example cards show inline "Open" buttons; the actual drawer
  is rendered by `overlay/1` at the screen root so it stacks over the page. A
  single shared drawer takes on the props of whichever example opened it
  (tracked by `:drawer_variant`).
  """
  use MishkaMob.Showcase

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :drawer,
      name: "Drawer",
      category: "Overlays",
      order: 0,
      description: "An edge-anchored panel that slides in over a dimmed backdrop."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:drawer_open?, false)
    |> Mob.Socket.assign(:drawer_side, :right)
    |> Mob.Socket.assign(:drawer_variant, :default)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Open from any side",
        description: "Set `side` to :left, :right, :top, or :bottom.",
        code: ~S"""
        <MishkaDrawer open={@open} side={:right} title="Menu" on_close={:close}>
          {menu_item("Profile")}
          {menu_item("Settings")}
        </MishkaDrawer>
        """,
        render: fn _assigns -> sides_preview() end
      },
      %Example{
        title: "Rounded bottom sheet",
        description: "A bottom drawer with corner_radius — a native-style sheet.",
        code: ~S"""
        <MishkaDrawer open={@open} side={:bottom} title="Menu"
                      corner_radius={:radius_lg} on_close={:close} />
        """,
        render: fn _assigns -> full_button("Open bottom sheet", {:open, :bottom, :sheet}) end
      },
      %Example{
        title: "Custom chrome (header: false)",
        description: "Suppress the built-in title/✕ and style the panel via props.",
        code: ~S"""
        <MishkaDrawer open={@open} side={:left} header={false}
                      background={:surface_raised} scrim_color={0x66000000}
                      on_close={:close} />
        """,
        render: fn _assigns -> full_button("Open custom drawer", {:open, :left, :custom}) end
      }
    ]
  end

  @impl true
  def card_preview do
    # A mini "drawer face": a window frame with a side panel (a few lines) and a
    # content area — so the card reads as a drawer at a glance.
    dots = %{type: :row, props: %{}, children: [dot(), sp_h(4), dot(), sp_h(4), dot()]}

    panel = %{
      type: :box,
      props: %{width: 66, height: 56, background: :muted, corner_radius: :radius_sm, padding: :space_xs},
      children: [%{type: :column, props: %{}, children: [line(30), gap(5), line(22), gap(5), line(26)]}]
    }

    content = %{
      type: :box,
      props: %{weight: 1, height: 56, background: :surface_raised, corner_radius: :radius_sm},
      children: []
    }

    layout = %{type: :row, props: %{fill_width: true}, children: [panel, sp_h(6), content]}
    %{type: :column, props: %{fill_width: true}, children: [dots, gap(8), layout]}
  end

  @impl true
  def overlay(assigns) do
    %{
      type: :mishka_drawer,
      props: drawer_props(assigns.drawer_variant, assigns.drawer_side, assigns.drawer_open?),
      children: menu_items()
    }
  end

  @impl true
  def handle({:open, side, variant}, socket) do
    socket
    |> Mob.Socket.assign(:drawer_side, side)
    |> Mob.Socket.assign(:drawer_variant, variant)
    |> Mob.Socket.assign(:drawer_open?, true)
  end

  def handle(:close_drawer, socket), do: Mob.Socket.assign(socket, :drawer_open?, false)
  def handle(_tag, socket), do: socket

  # ── drawer props per opened variant ──
  defp drawer_props(:sheet, _side, open?) do
    %{open: open?, side: :bottom, title: "Menu", corner_radius: :radius_lg, on_close: :close_drawer}
  end

  defp drawer_props(:custom, _side, open?) do
    %{
      open: open?,
      side: :left,
      header: false,
      background: :surface_raised,
      scrim_color: 0x66_00_00_00,
      on_close: :close_drawer
    }
  end

  defp drawer_props(_default, side, open?) do
    %{open: open?, side: side, title: "Menu", on_close: :close_drawer}
  end

  # ── inline previews (rendered inside the example card) ──
  defp sides_preview do
    column([
      row([
        open_button("Left", {:open, :left, :default}),
        gap(8),
        open_button("Right", {:open, :right, :default})
      ]),
      gap(8),
      row([
        open_button("Top", {:open, :top, :default}),
        gap(8),
        open_button("Bottom", {:open, :bottom, :default})
      ])
    ])
  end

  defp open_button(label, tag) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :primary,
        text_color: :on_primary,
        text_size: :base,
        padding: :space_sm,
        weight: 1,
        on_tap: {self(), tag}
      },
      children: []
    }
  end

  # ── drawer body ──
  defp menu_items do
    [menu_item("👤  Profile"), gap(8), menu_item("⚙️  Settings"), gap(8), menu_item("ℹ️  About")]
  end

  defp menu_item(label) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :surface_raised,
        text_color: :on_surface,
        text_size: :lg,
        padding: :space_md,
        fill_width: true,
        on_tap: {self(), :close_drawer}
      },
      children: []
    }
  end

  # A full-width trigger — use for a standalone example button. (A `weight: 1`
  # button alone in the card column would take *vertical* weight and collapse.)
  defp full_button(label, tag) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :primary,
        text_color: :on_primary,
        text_size: :base,
        padding: :space_sm,
        fill_width: true,
        on_tap: {self(), tag}
      },
      children: []
    }
  end

  # ── card-face pieces ──
  defp dot,
    do: %{type: :box, props: %{width: 6, height: 6, background: :muted, corner_radius: :radius_pill}, children: []}

  defp line(width) do
    %{
      type: :box,
      props: %{width: width, height: 4, background: :surface_raised, corner_radius: :radius_sm},
      children: []
    }
  end

  defp sp_h(n), do: gap(n)

  defp row(children), do: %{type: :row, props: %{fill_width: true}, children: children}
  defp column(children), do: %{type: :column, props: %{fill_width: true}, children: children}
  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}
end
