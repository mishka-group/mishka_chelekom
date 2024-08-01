defmodule MishkaChelekom.Pagination do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn",
    "transparent"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :total, :integer, required: true, doc: ""
  attr :active, :integer, default: 1, doc: ""
  attr :siblings, :integer, default: 1, doc: ""
  attr :boundaries, :integer, default: 1, doc: ""
  attr :on_select, JS, default: %JS{}
  attr :on_first, JS, default: %JS{}
  attr :on_last, JS, default: %JS{}
  attr :on_next, JS, default: %JS{}
  attr :on_previous, JS, default: %JS{}
  attr :color, :string, values: @colors, default: "transparent", doc: ""
  attr :rounded, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :separator, :string, default: "hero-ellipsis-horizontal", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def pagination(
        %{siblings: siblings, boundaries: boundaries, total: total, active: active} = assigns
      ) do
    assigns = assign(assigns, %{siblings: build_pagination(total, active, siblings, boundaries)})

    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            rounded_size(@rounded),
            border(@color),
            @class
          ]
      }
      {@rest}
    >
      <button>
        <.icon name="hero-chevron-left" />
      </button>

      <div :for={range <- @siblings.range}>
        <%= if is_integer(range) do %>
          <button class={[
            "bg-neutral-200 flex justify-center items-center",
            "w-8 h-8 hover:bg-neutral-400 hover:text-white rounded",
            @active == range && "bg-red-600 text-white"
          ]}>
            <%= range %>
          </button>
        <% else %>
          <.separator name={@separator} />
        <% end %>
      </div>
      <button>
        <.icon name="hero-chevron-right" />
      </button>
    </div>
    """
  end

  attr :name, :string
  attr :class, :string, default: nil, doc: ""

  defp separator(%{name: "hero-" <> _icon_name} = assigns) do
    ~H"""
    <.icon name={@name} class={@class || "separator-icon"} />
    """
  end

  defp separator(assigns) do
    ~H"""
    <span class={@class || "separator-text"}><%= @name %></span>
    """
  end

  # We got the original code from mantine.dev pagination hook and changed some numbers
  defp build_pagination(total, current_page, siblings, boundaries) do
    total_pages = max(total, 0)

    total_page_numbers = siblings * 2 + 3 + boundaries * 2

    pagination_range =
      if total_page_numbers >= total_pages do
        range(1, total_pages)
      else
        left_sibling_index = max(current_page - siblings, boundaries + 1)
        right_sibling_index = min(current_page + siblings, total_pages - boundaries)

        should_show_left_dots = left_sibling_index > boundaries + 2
        should_show_right_dots = right_sibling_index < total_pages - boundaries - 1

        dots = :dots

        cond do
          !should_show_left_dots and should_show_right_dots ->
            left_item_count = siblings * 2 + boundaries + 2

            range(1, left_item_count) ++
              [dots] ++ range(total_pages - boundaries + 1, total_pages)

          should_show_left_dots and not should_show_right_dots ->
            right_item_count = boundaries + 1 + 2 * siblings

            range(1, boundaries) ++
              [dots] ++ range(total_pages - right_item_count + 1, total_pages)

          true ->
            range(1, boundaries) ++
              [dots] ++
              range(left_sibling_index, right_sibling_index) ++
              [dots] ++ range(total_pages - boundaries + 1, total_pages)
        end
      end

    %{range: pagination_range, active: current_page}
  end

  defp range(start, stop) when start > stop, do: []
  defp range(start, stop), do: Enum.to_list(start..stop)

  defp border("white") do
    "border-[#DADADA] hover:border-[#d9d9d9]"
  end

  defp border("transparent") do
    "border-transparent"
  end

  defp border("primary") do
    "border-[#4363EC] hover:border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] hover:border-[#60636f]"
  end

  defp border("success") do
    "border-[#227A52] hover:border-[#d4fde4]"
  end

  defp border("warning") do
    "border-[#FF8B08] hover:border-[#fff1cd]"
  end

  defp border("danger") do
    "border-[#E73B3B] hover:border-[#ffcdcd]"
  end

  defp border("info") do
    "border-[#004FC4] hover:border-[#cce1ff]"
  end

  defp border("misc") do
    "border-[#52059C] hover:border-[#ffe0ff]"
  end

  defp border("dawn") do
    "border-[#4D4137] hover:border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] hover:border-[#d2d8e9]"
  end

  defp border("dark") do
    "border-[#1E1E1E] hover:border-[#111111]"
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp default_classes() do
    [
      "flex items-center gap-3"
    ]
  end
end
