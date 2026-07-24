defmodule MishkaMob.Showcase.ComponentScreen do
  @moduledoc """
  Generic per-component page. Pushed with `%{slug: :drawer}`; it looks the entry
  up in the registry and drives it:

    * calls the component's `mount/1` to seed assigns,
    * renders each example (`title` + `description` + live `render.(assigns)` +
      `code` block),
    * renders the component's root `overlay/1` (for drawers/modals) over the page,
    * forwards tap events to the component's `handle/2`.

  One screen serves all 150+ components — the per-component logic lives in the
  showcase modules, not here.
  """
  use Mob.Screen

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.Kit
  alias MishkaMob.ThemeBar

  def mount(params, _session, socket) do
    entry = Showcase.get(Map.get(params, :slug))
    socket = Mob.Socket.assign(socket, :entry, entry)
    {:ok, if(entry, do: entry.module.mount(socket), else: socket)}
  end

  def render(assigns) do
    case assigns.entry do
      nil -> not_found()
      entry -> component_page(entry, assigns)
    end
  end

  defp component_page(entry, assigns) do
    examples = entry.module.examples()

    page = %{
      type: :scroll,
      props: %{background: :background},
      children: [
        %{
          type: :column,
          props: %{background: :background, padding: :space_lg},
          children:
            [
              ThemeBar.bar(),
              Kit.gap(16),
              Kit.page_header(entry.name, Map.get(entry, :description)),
              Kit.gap(20)
            ] ++
              Enum.flat_map(examples, fn ex ->
                [
                  Kit.example_block(ex.title, ex.description, ex.render.(assigns), ex.code),
                  Kit.gap(16)
                ]
              end) ++
              props_section(entry) ++
              [Kit.gap(8), Kit.back_button()]
        }
      ]
    }

    # A component's overlay (e.g. the Drawer's panel) stacks over the whole page.
    children =
      case entry.module.overlay(assigns) do
        nil -> [page]
        overlay -> [page, overlay]
      end

    %{
      type: :box,
      props: %{fill_width: true, fill_height: true, background: :background},
      children: children
    }
  end

  # A "Props" reference section, when the component declares one.
  defp props_section(entry) do
    case entry.module.props() do
      [] -> []
      props -> [Kit.section_header("Props"), Kit.gap(12), Kit.props_table(props), Kit.gap(8)]
    end
  end

  defp not_found do
    %{
      type: :column,
      props: %{background: :background, padding: :space_lg},
      children: [Kit.page_header("Not found"), Kit.gap(16), Kit.back_button()]
    }
  end

  def handle_info({:tap, {:set_theme, key}}, socket), do: {:noreply, ThemeBar.set(key, socket)}

  def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}

  def handle_info({:tap, tag}, socket) do
    case socket.assigns.entry do
      nil -> {:noreply, socket}
      entry -> {:noreply, entry.module.handle(tag, socket)}
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}
end
