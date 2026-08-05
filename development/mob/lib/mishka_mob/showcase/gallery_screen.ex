defmodule MishkaMob.Showcase.GalleryScreen do
  @moduledoc """
  The gallery index: every registered component grouped by category. Tapping a
  component pushes the generic `ComponentScreen` for its slug.

  Scales by construction — this screen only renders lightweight rows, and each
  component's (heavier) examples mount on their own screen, one at a time. When
  the catalog grows past a few dozen, swap the `Scroll`+`Column` here for a
  `:list`/`:lazy_list` to virtualize the rows.
  """
  use Mob.Screen

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.Kit
  alias MishkaMob.ThemeBar

  def mount(_params, _session, socket), do: {:ok, socket}

  def render(_assigns) do
    groups = Showcase.by_category()
    count = groups |> Enum.flat_map(fn {_, entries} -> entries end) |> length()

    body =
      [
        ThemeBar.bar(),
        Kit.gap(16),
        Kit.page_header("🧩  Components", "#{count} component#{if count == 1, do: "", else: "s"}")
      ] ++
        Enum.flat_map(groups, &category_block/1) ++
        [Kit.gap(24), Kit.back_button()]

    %{
      type: :scroll,
      props: %{background: :background},
      children: [
        %{type: :column, props: %{background: :background, padding: :space_lg}, children: body}
      ]
    }
  end

  defp category_block({category, entries}) do
    [Kit.gap(20), Kit.section_label(category)] ++
      Enum.flat_map(entries, fn e ->
        [Kit.gap(8), Kit.component_row(e.name, Map.get(e, :description), {:open, e.slug})]
      end)
  end

  def handle_info({:tap, {:set_theme, key}}, socket), do: {:noreply, ThemeBar.set(key, socket)}

  def handle_info({:tap, {:open, slug}}, socket) do
    {:noreply, Mob.Socket.push_screen(socket, MishkaMob.Showcase.ComponentScreen, %{slug: slug})}
  end

  def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}
  def handle_info(_message, socket), do: {:noreply, socket}
end
