defmodule MishkaMob.HomeScreen do
  @moduledoc """
  Landing screen. Priority order, top to bottom:

    1. a compact icon theme selector (`MishkaMob.ThemeBar`),
    2. the **Mishka Chelekom** section — component cards, two per row,
    3. a compact **Demos & Device** section for the built-in samples + plugins.
  """
  use Mob.Screen

  alias MishkaMob.{Showcase, ThemeBar}
  alias MishkaMob.Showcase.Kit

  def mount(_params, _session, socket) do
    theme = ThemeBar.current()
    Mob.Theme.set(ThemeBar.module_for(theme))

    {:ok,
     socket
     |> Mob.Socket.assign(:theme, theme)
     |> Mob.Socket.assign(:plugin_screens, Mob.Plugins.screens())}
  end

  def render(assigns) do
    %{
      type: :scroll,
      props: %{background: :background},
      children: [
        %{
          type: :column,
          props: %{background: :background, padding: :space_lg},
          children: [
            ThemeBar.bar(),
            gap(16),
            title_row(assigns.theme),
            gap(22),

            # ── Mishka components (priority) ─────────────────────────────
            Kit.section_header("Mishka Chelekom", "Native component library"),
            gap(14),
            Kit.grid(mishka_cards()),
            gap(28),

            # ── Built-in demos + device plugins (compact) ────────────────
            Kit.section_label("Demos & Device"),
            gap(10),
            Kit.grid(demo_buttons(assigns.plugin_screens))
          ]
        }
      ]
    }
  end

  # Registered components as cards, padded with a few "coming soon" skeletons
  # so the growing catalog reads as a grid from day one.
  defp mishka_cards do
    real =
      Enum.map(Showcase.all(), fn e ->
        Kit.component_card(e.module.card_preview(), e.name, e.category, {:open_component, e.slug})
      end)

    real ++ List.duplicate(Kit.skeleton_card(), max(0, 4 - length(real)))
  end

  defp demo_buttons(plugin_screens) do
    [
      Kit.compact_button("Text Input", :open_text),
      Kit.compact_button("Rock Paper Scissors", :open_list),
      Kit.compact_button("Roll Dice", :open_dice),
      Kit.compact_button("WebView", :open_webview),
      Kit.compact_button("Audio", :open_audio),
      Kit.compact_button("Storage", :open_storage)
    ] ++
      Enum.map(plugin_screens, fn %{default_route: route} ->
        Kit.compact_button(plugin_label(route), route)
      end)
  end

  defp title_row(theme) do
    %{
      type: :row,
      props: %{fill_width: true},
      children: [
        %{
          type: :image,
          props: %{src: logo_src(theme), width: 36, height: 36, content_mode: "fit"},
          children: []
        },
        %{type: :spacer, props: %{size: 10}, children: []},
        %{
          type: :text,
          props: %{text: "Mishka Mob", text_size: :xl, text_color: :on_surface},
          children: []
        }
      ]
    }
  end

  # ── Events ──
  def handle_info({:tap, {:set_theme, key}}, socket) do
    {:noreply, ThemeBar.set(key, socket)}
  end

  def handle_info({:tap, {:open_component, slug}}, socket) do
    {:noreply, Mob.Socket.push_screen(socket, MishkaMob.Showcase.ComponentScreen, %{slug: slug})}
  end

  def handle_info({:tap, :open_text}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.TextScreen)}

  def handle_info({:tap, :open_list}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.ListScreen)}

  def handle_info({:tap, :open_dice}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.DiceScreen)}

  def handle_info({:tap, :open_webview}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.WebViewScreen)}

  def handle_info({:tap, :open_audio}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.AudioScreen)}

  def handle_info({:tap, :open_storage}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, MishkaMob.StorageScreen)}

  # Plugin demo screens are tagged by their route string.
  def handle_info({:tap, route}, socket) when is_binary(route) do
    case Enum.find(socket.assigns.plugin_screens, &(&1.default_route == route)) do
      %{module: mod} -> {:noreply, Mob.Socket.push_screen(socket, mod)}
      nil -> {:noreply, socket}
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  # "/mob_camera/demo" -> "Camera". Falls back gracefully for any route shape.
  defp plugin_label(route) do
    route
    |> String.trim_leading("/")
    |> String.split("/")
    |> List.first()
    |> to_string()
    |> String.replace_prefix("mob_", "")
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}

  # mob_logo_dark.png is the dark-on-light logo (for light backgrounds);
  # mob_logo_light.png is light-on-dark. Material 3's baseline is a light
  # surface, so it uses the dark logo like :light.
  defp logo_src(:light), do: Path.join(rootdir(), "mob_logo_dark.png")
  defp logo_src(:material3), do: Path.join(rootdir(), "mob_logo_dark.png")
  defp logo_src(_), do: Path.join(rootdir(), "mob_logo_light.png")

  defp rootdir do
    case System.get_env("ROOTDIR") do
      nil -> Path.expand("~/.mob/runtime/ios-sim")
      val -> val
    end
  end
end
