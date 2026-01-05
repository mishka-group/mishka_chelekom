defmodule MishkaChelekom.MCP.Tools.SearchComponents do
  @moduledoc """
  Search Mishka Chelekom components by name, category, or functionality.

  Useful for finding components when you're not sure of the exact name.
  Searches component names and categories to find relevant matches.

  ## Search Examples

  - Search by name: "button", "input", "modal"
  - Search by category: "form", "navigation", "feedback"
  - Search by functionality: "date", "file", "password"

  ## Categories

  - **form**: Input components (button, checkbox, input fields, etc.)
  - **navigation**: Menu, navbar, breadcrumb, tabs, pagination
  - **feedback**: Alert, toast, modal, drawer, popover
  - **display**: Card, badge, avatar, table, accordion
  - **layout**: Divider, footer, jumbotron
  - **media**: Image, carousel, gallery, video
  - **typography**: Typography, blockquote, list
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response

  schema do
    field(:query, :string,
      required: true,
      description:
        "Search query - can be component name, category, or functionality (e.g., 'form', 'navigation', 'input', 'date')"
    )
  end

  @component_categories %{
    "form" => ~w(
      button checkbox_field checkbox_card color_field combobox date_time_field
      email_field fieldset file_field form_wrapper input_field native_select
      number_field password_field radio_field radio_card range_field search_field
      tel_field text_field textarea_field toggle_field url_field
    ),
    "navigation" => ~w(
      breadcrumb mega_menu menu navbar pagination sidebar stepper tabs
    ),
    "feedback" => ~w(
      alert banner drawer modal overlay popover toast tooltip
    ),
    "display" => ~w(
      accordion avatar badge card carousel chat clipboard collapse
      device_mockup dropdown indicator keyboard list progress
      rating skeleton speed_dial spinner table table_content timeline
    ),
    "layout" => ~w(
      divider footer jumbotron layout scroll_area
    ),
    "media" => ~w(
      gallery icon image video
    ),
    "typography" => ~w(
      blockquote typography
    )
  }

  @component_keywords %{
    "date" => ~w(date_time_field),
    "time" => ~w(date_time_field timeline),
    "telephone" => ~w(tel_field),
    "select" => ~w(native_select combobox dropdown),
    "dropdown" => ~w(dropdown native_select combobox),
    "text" => ~w(text_field textarea_field input_field typography),
    "email" => ~w(email_field),
    "password" => ~w(password_field),
    "number" => ~w(number_field range_field),
    "file" => ~w(file_field),
    "upload" => ~w(file_field),
    "check" => ~w(checkbox_field checkbox_card toggle_field),
    "toggle" => ~w(toggle_field),
    "switch" => ~w(toggle_field),
    "radio" => ~w(radio_field radio_card),
    "slider" => ~w(range_field),
    "range" => ~w(range_field),
    "color" => ~w(color_field),
    "search" => ~w(search_field combobox),
    "url" => ~w(url_field),
    "link" => ~w(url_field breadcrumb navbar menu),
    "menu" => ~w(menu mega_menu navbar dropdown),
    "nav" => ~w(navbar menu breadcrumb sidebar),
    "header" => ~w(navbar jumbotron),
    "footer" => ~w(footer),
    "sidebar" => ~w(sidebar menu),
    "dialog" => ~w(modal drawer),
    "popup" => ~w(modal popover tooltip),
    "notification" => ~w(toast alert banner),
    "message" => ~w(alert toast chat),
    "error" => ~w(alert toast),
    "warning" => ~w(alert toast),
    "success" => ~w(alert toast),
    "info" => ~w(alert toast),
    "loading" => ~w(spinner skeleton progress),
    "spinner" => ~w(spinner),
    "skeleton" => ~w(skeleton),
    "progress" => ~w(progress stepper),
    "steps" => ~w(stepper timeline),
    "wizard" => ~w(stepper),
    "table" => ~w(table table_content),
    "grid" => ~w(table gallery layout),
    "list" => ~w(list table accordion menu),
    "card" => ~w(card checkbox_card radio_card),
    "image" => ~w(image avatar gallery carousel),
    "photo" => ~w(image gallery carousel),
    "video" => ~w(video device_mockup),
    "media" => ~w(image video gallery carousel),
    "avatar" => ~w(avatar),
    "profile" => ~w(avatar card),
    "user" => ~w(avatar),
    "badge" => ~w(badge indicator),
    "tag" => ~w(badge),
    "label" => ~w(badge),
    "icon" => ~w(icon),
    "tab" => ~w(tabs accordion),
    "accordion" => ~w(accordion collapse),
    "collapse" => ~w(collapse accordion),
    "expand" => ~w(accordion collapse),
    "tooltip" => ~w(tooltip popover),
    "hint" => ~w(tooltip),
    "help" => ~w(tooltip popover),
    "copy" => ~w(clipboard),
    "clipboard" => ~w(clipboard),
    "rating" => ~w(rating),
    "star" => ~w(rating),
    "review" => ~w(rating),
    "keyboard" => ~w(keyboard),
    "shortcut" => ~w(keyboard),
    "hotkey" => ~w(keyboard),
    "device" => ~w(device_mockup),
    "mockup" => ~w(device_mockup),
    "phone" => ~w(device_mockup tel_field),
    "mobile" => ~w(device_mockup),
    "chat" => ~w(chat),
    "comment" => ~w(chat),
    "scroll" => ~w(scroll_area),
    "divider" => ~w(divider),
    "separator" => ~w(divider),
    "line" => ~w(divider),
    "quote" => ~w(blockquote),
    "blockquote" => ~w(blockquote),
    "speed" => ~w(speed_dial),
    "fab" => ~w(speed_dial),
    "action" => ~w(speed_dial button),
    "banner" => ~w(banner jumbotron alert),
    "hero" => ~w(jumbotron banner)
  }

  @impl true
  def execute(%{query: query}, frame) do
    results = search(String.downcase(query))

    response =
      Response.tool()
      |> Response.json(%{
        query: query,
        results: results,
        total: length(results),
        tip:
          "Use get_component_info to get detailed options for a specific component, or generate_component to create one."
      })

    {:reply, response, frame}
  end

  defp search(query) do
    all_components = get_all_component_names()

    # Direct name match
    direct_matches = Enum.filter(all_components, &String.contains?(&1, query))

    # Category match
    category_matches =
      @component_categories
      |> Enum.filter(fn {category, _} -> String.contains?(category, query) end)
      |> Enum.flat_map(fn {_, components} -> components end)

    # Keyword match
    keyword_matches =
      @component_keywords
      |> Enum.filter(fn {keyword, _} -> String.contains?(keyword, query) end)
      |> Enum.flat_map(fn {_, components} -> components end)

    (direct_matches ++ category_matches ++ keyword_matches)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn name ->
      category = find_category(name)

      %{
        name: name,
        category: category,
        generator: "mix mishka.ui.gen.component #{name}",
        docs: "https://mishka.tools/chelekom/docs/#{name}"
      }
    end)
  end

  defp find_category(name) do
    @component_categories
    |> Enum.find_value("other", fn {category, components} ->
      if name in components, do: category
    end)
  end

  defp get_all_component_names do
    @component_categories
    |> Enum.flat_map(fn {_, components} -> components end)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
