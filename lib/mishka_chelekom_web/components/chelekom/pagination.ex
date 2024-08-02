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
  attr :next_label, :string, default: "hero-chevron-right", doc: ""
  attr :previous_label, :string, default: "hero-chevron-left", doc: ""
  attr :first_label, :string, default: "hero-chevron-double-left", doc: ""
  attr :last_label, :string, default: "hero-chevron-double-right", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :params, :map, default: %{}
  slot :start_items, required: false
  slot :end_items, required: false
  attr :rest, :global, include: ~w(disabled hide_one_page show_edges hide_controls), doc: ""

  def pagination(
        %{siblings: siblings, boundaries: boundaries, total: total, active: active} = assigns
      ) do
    assigns = assign(assigns, %{siblings: build_pagination(total, active, siblings, boundaries)})

    ~H"""
    <div
      :if={show_pagination?(@rest[:hide_one_page], @total)}
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
      <%= render_slot(@start_items) %>
      <button
        :if={@rest[:show_edges]}
        phx-click={@on_next |> JS.push("pagination", value: Map.merge(%{action: "first"}, @params))}
        disabled={@active <= 1}
      >
        <.icon_or_text name={@first_label} />
      </button>
      <button
        :if={is_nil(@rest[:hide_controls])}
        phx-click={
          @on_previous |> JS.push("pagination", value: Map.merge(%{action: "previous"}, @params))
        }
        disabled={@active <= 1}
      >
        <.icon_or_text name={@previous_label} />
      </button>

      <div :for={range <- @siblings.range}>
        <%= if is_integer(range) do %>
          <.pagination_button params={@params} range={range} active={@active} on_select={@on_select} />
        <% else %>
          <.icon_or_text name={@separator} />
        <% end %>
      </div>
      <button
        :if={is_nil(@rest[:hide_controls])}
        phx-click={@on_next |> JS.push("pagination", value: Map.merge(%{action: "next"}, @params))}
        disabled={@active >= @total}
      >
        <.icon_or_text name={@next_label} />
      </button>
      <button
        :if={@rest[:show_edges]}
        phx-click={@on_next |> JS.push("pagination", value: Map.merge(%{action: "last"}, @params))}
        disabled={@active >= @total}
      >
        <.icon_or_text name={@last_label} />
      </button>
      <%= render_slot(@end_items) %>
    </div>
    """
  end

  attr :name, :string
  attr :class, :string, default: nil, doc: ""

  defp icon_or_text(%{name: "hero-" <> _icon_name} = assigns) do
    ~H"""
    <.icon name={@name} class={@class || "pagination-icon"} />
    """
  end

  defp icon_or_text(assigns) do
    ~H"""
    <span class={@class || "pagination-text"}><%= @name %></span>
    """
  end

  attr :params, :map, default: %{}
  attr :range, :list, required: true
  attr :active, :integer, required: true
  attr :on_select, JS, default: %JS{}

  defp pagination_button(assigns) do
    ~H"""
    <button
      class={[
        "bg-neutral-200 flex justify-center items-center",
        "w-8 h-8 hover:bg-neutral-400 hover:text-white rounded",
        @active == @range && "bg-red-600 text-white"
      ]}
      phx-click={
        @on_select
        |> JS.push("pagination", value: Map.merge(%{action: "select", page: @range}, @params))
      }
      disabled={@range == @active}
    >
      <%= @range %>
    </button>
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

    %{range: pagination_range(current_page, pagination_range), active: current_page}
  end

  defp pagination_range(active, range) do
    if active != 1 and (active - 1) not in range do
      index = Enum.find_index(range, &(&1 == active))
      List.insert_at(range, index, active - 1)
    else
      range
    end
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

  defp show_pagination?(nil, _total), do: true
  defp show_pagination?(true, total) when total <= 1, do: false
  defp show_pagination?(_, total) when total > 1, do: true
  defp show_pagination?(_, _), do: false
end
