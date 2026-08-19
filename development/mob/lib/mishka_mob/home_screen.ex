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
     |> Mob.Socket.assign(:plugin_screens, Mob.Plugins.screens())
     |> Mob.List.put_renderer(:home, &home_item/1)}
  end

  # The whole screen is one `:list` (see Mob.List) rather than a `:scroll` +
  # `:column` wrapping an inner grid — Compose's LazyColumn (what `:list`
  # becomes) cannot be nested inside an already-vertically-scrolling Column
  # ("measured with an infinity maximum height constraints" crash), so the
  # list has to own the screen's scrolling outright. The header and the demos
  # section ride along as two more items rather than surrounding wrapper
  # content — matches the pattern the framework's own docs describe (a header
  # as a plain item before the main items).
  #
  # This is also what fixes the app's slow cold boot: the eager version built
  # and native-inflated all 60 component preview cards before first paint;
  # the native LazyColumn this produces only realizes the rows on screen.
  def render(assigns) do
    %{
      type: :list,
      props: %{
        id: :home,
        items: home_items(assigns),
        background: :background,
        padding: :space_lg,
        fill_width: true,
        fill_height: true
      },
      children: []
    }
  end

  defp home_items(assigns) do
    [{:header, assigns.theme}] ++
      Enum.map(mishka_card_pairs(), &{:pair, &1}) ++
      [{:demos, assigns.plugin_screens}]
  end

  defp home_item({:header, theme}) do
    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        ThemeBar.bar(),
        gap(16),
        title_row(theme),
        gap(22),
        Kit.section_header("Mishka Chelekom", "Native component library"),
        gap(14)
      ]
    }
  end

  defp home_item({:pair, pair}), do: card_pair_row(pair)

  defp home_item({:demos, plugin_screens}) do
    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        gap(28),
        Kit.section_label("Demos & Device"),
        gap(10),
        Kit.grid(demo_buttons(plugin_screens))
      ]
    }
  end

  # Registered components, padded with a few "coming soon" skeletons so the
  # growing catalog reads as a grid from day one, chunked into row-pairs —
  # the pairing (not the cards themselves) is what needs to happen up front,
  # since :list/:lazy_list virtualizes by row.
  defp mishka_card_pairs do
    real = Showcase.all()
    padded = real ++ List.duplicate(:skeleton, max(0, 4 - length(real)))
    Enum.chunk_every(padded, 2)
  end

  defp card_pair_row(pair) do
    cells =
      case Enum.map(pair, &card_cell/1) do
        [a, b] -> [a, gap(12), b]
        # Odd final row: pad with a `weight: 1` spacer so the lone card stays
        # half-width instead of stretching to fill the row (matches Kit.grid/1).
        [a] -> [a, gap(12), %{type: :spacer, props: %{weight: 1}, children: []}]
      end

    # `:lazy_list` has no item-spacing prop (see MobLazyList in MobBridge.kt) —
    # bake the gap into the row itself, same convention ListScreen's
    # history_row/1 uses.
    %{type: :row, props: %{fill_width: true, padding_bottom: 12}, children: cells}
  end

  defp card_cell(:skeleton), do: Kit.skeleton_card()

  defp card_cell(e),
    do: Kit.component_card(e.module.card_preview(), e.name, e.category, {:open_component, e.slug})

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
        logo(theme),
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

  defp logo(theme) do
    %{
      type: :image,
      props: %{src: logo_src(theme), width: 36, height: 36, content_mode: "fit"},
      children: []
    }
  end

  # The Mishka mark ships as a transparent PNG in two tints, so it reads on
  # whatever surface the active theme paints: the dark mark on light surfaces
  # (:light, and Material 3 whose baseline is light), the light one on dark
  # surfaces (:dark, :glass).
  defp logo_src(:light), do: priv_image("mishka_logo_dark.png")
  defp logo_src(:material3), do: priv_image("mishka_logo_dark.png")
  defp logo_src(_), do: priv_image("mishka_logo_light.png")

  defp priv_image(name) do
    case :code.priv_dir(:mishka_mob) do
      {:error, _} -> name
      dir -> Path.join([to_string(dir), "images", name])
    end
  end
end
