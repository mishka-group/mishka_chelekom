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

  @variants [
    "default",
    "outline",
    "transparent",
    "subtle",
    "shadow",
    "inverted",
    "default_gradient",
    "outline_gradient",
    "inverted_gradient",
    "unbordered"
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
  attr :size, :string, default: "medium", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
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
            color_variant(@variant, @color),
            rounded_size(@rounded),
            size_class(@size),
            border(@color),
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@start_items) %>

      <.item_button
        :if={@rest[:show_edges]}
        on_action={{"first", @on_next}}
        page={{nil, @active}}
        params={@params}
        icon={@first_label}
        disabled={active <= 1}
      />

      <.item_button
        :if={is_nil(@rest[:hide_controls])}
        on_action={{"previous", @on_previous}}
        page={{nil, @active}}
        params={@params}
        icon={@previous_label}
        disabled={active <= 1}
      />

      <div :for={range <- @siblings.range}>
        <%= if is_integer(range) do %>
          <.item_button on_action={{"select", @on_select}} page={{range, @active}} params={@params} />
        <% else %>
          <.icon_or_text name={@separator} />
        <% end %>
      </div>

      <.item_button
        :if={is_nil(@rest[:hide_controls])}
        on_action={{"next", @on_next}}
        page={{nil, @active}}
        params={@params}
        icon={@next_label}
        disabled={@active >= @total}
      />

      <.item_button
        :if={@rest[:show_edges]}
        on_action={{"last", @on_last}}
        page={{nil, @active}}
        params={@params}
        icon={@last_label}
        disabled={@active >= @total}
      />

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
  attr :page, :list, required: true
  attr :on_action, JS, default: %JS{}
  attr :icon, :string, required: false
  attr :rest, :global, include: ~w(disabled), doc: ""

  defp item_button(%{on_action: {"select", on_action}, page: {page, active}} = assigns) do
    ~H"""
    <button
      class={[
        "pagination-button",
        active == page && "[&_.pagination-button]:bg-red-600 text-white"
      ]}
      phx-click={
        on_action
        |> JS.push("pagination", value: Map.merge(%{action: "select", page: page}, @params))
      }
      disabled={page == active}
    >
      <%= page %>
    </button>
    """
  end

  defp item_button(%{on_action: {action, on_action}, page: {_, active}} = assigns) do
    ~H"""
    <button
      phx-click={on_action |> JS.push("pagination", value: Map.merge(%{action: action}, @params))}
      {@rest}
    >
      <.icon_or_text name={@icon} />
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
    "border-[#DADADA] hover:[&_.pagination-button]:border-[#d9d9d9]"
  end

  defp border("transparent") do
    "border-transparent"
  end

  defp border("primary") do
    "border-[#4363EC] hover:[&_.pagination-button]:border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] hover:[&_.pagination-button]:border-[#60636f]"
  end

  defp border("success") do
    "border-[#227A52] hover:[&_.pagination-button]:border-[#d4fde4]"
  end

  defp border("warning") do
    "border-[#FF8B08] hover:[&_.pagination-button]:border-[#fff1cd]"
  end

  defp border("danger") do
    "border-[#E73B3B] hover:[&_.pagination-button]:border-[#ffcdcd]"
  end

  defp border("info") do
    "border-[#004FC4] hover:[&_.pagination-button]:border-[#cce1ff]"
  end

  defp border("misc") do
    "border-[#52059C] hover:[&_.pagination-button]:border-[#ffe0ff]"
  end

  defp border("dawn") do
    "border-[#4D4137] hover:[&_.pagination-button]:border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] hover:[&_.pagination-button]:border-[#d2d8e9]"
  end

  defp border("dark") do
    "border-[#1E1E1E] hover:[&_.pagination-button]:border-[#111111]"
  end

  defp rounded_size("extra_small"), do: " [&_.pagination-button]:rounded-sm"
  defp rounded_size("small"), do: " [&_.pagination-button]:rounded"
  defp rounded_size("medium"), do: " [&_.pagination-button]:rounded-md"
  defp rounded_size("large"), do: " [&_.pagination-button]:rounded-lg"
  defp rounded_size("extra_large"), do: " [&_.pagination-button]:rounded-xl"
  defp rounded_size("full"), do: " [&_.pagination-button]:rounded-full"
  defp rounded_size("none"), do: " [&_.pagination-button]:rounded-none"

  defp size_class("extra_small"), do: " [&_.pagination-button]:size-5"
  defp size_class("small"), do: " [&_.pagination-button]:size-6"
  defp size_class("medium"), do: " [&_.pagination-button]:size-7"
  defp size_class("large"), do: " [&_.pagination-button]:size-8"
  defp size_class("extra_large"), do: " [&_.pagination-button]:size-9"
  defp size_class(params) when is_binary(params), do: params

  defp color_variant("default", "white") do
    "[&_.pagination-button]:bg-white [&_.pagination-button]:text-[#3E3E3E] border-[#DADADA] hover:[&_.pagination-button]:bg-[#E8E8E8] hover:[&_.pagination-button]:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white border-[#2441de] hover:[&_.pagination-button]:bg-[#072ed3] hover:[&_.pagination-button]:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white border-[#877C7C] hover:[&_.pagination-button]:bg-[#60636f] hover:[&_.pagination-button]:border-[#3d3f49]"
  end

  defp color_variant("default", "success") do
    "[&_.pagination-button]:bg-[#ECFEF3] [&_.pagination-button]:text-[#047857] border-[#6EE7B7] hover:[&_.pagination-button]:bg-[#d4fde4] hover:[&_.pagination-button]:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "[&_.pagination-button]:bg-[#FFF8E6] [&_.pagination-button]:text-[#FF8B08] border-[#FF8B08] hover:[&_.pagination-button]:bg-[#fff1cd] hover:[&_.pagination-button]:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "[&_.pagination-button]:bg-[#FFE6E6] [&_.pagination-button]:text-[#E73B3B] border-[#E73B3B] hover:[&_.pagination-button]:bg-[#ffcdcd] hover:[&_.pagination-button]:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "[&_.pagination-button]:bg-[#E5F0FF] [&_.pagination-button]:text-[#004FC4] border-[#004FC4] hover:[&_.pagination-button]:bg-[#cce1ff] hover:[&_.pagination-button]:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "[&_.pagination-button]:bg-[#FFE6FF] [&_.pagination-button]:text-[#52059C] border-[#52059C] hover:[&_.pagination-button]:bg-[#ffe0ff] hover:[&_.pagination-button]:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "[&_.pagination-button]:bg-[#FFECDA] [&_.pagination-button]:text-[#4D4137] border-[#4D4137] hover:[&_.pagination-button]:bg-[#ffdfc1] hover:[&_.pagination-button]:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "[&_.pagination-button]:bg-[#E3E7F1] [&_.pagination-button]:text-[#707483] border-[#707483] hover:[&_.pagination-button]:bg-[#d2d8e9] hover:[&_.pagination-button]:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white border-[#050404] hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "[&_.pagination-button]:bg-transparent [&_.pagination-button]:text-white border-white hover:[&_.pagination-button]:text-[#E8E8E8] hover:[&_.pagination-button]:border-[#E8E8E8]"
  end

  defp color_variant("outline", "primary") do
    "[&_.pagination-button]:bg-transparent text-[#4363EC] border-[#4363EC] hover:text-[#072ed3] hover:[&_.pagination-button]:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "[&_.pagination-button]:bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:text-[#60636f] hover:[&_.pagination-button]:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "[&_.pagination-button]:bg-transparent text-[#227A52] border-[#6EE7B7] hover:text-[#50AF7A] hover:[&_.pagination-button]:border-[#50AF7A]"
  end

  defp color_variant("outline", "warning") do
    "[&_.pagination-button]:bg-transparent text-[#FF8B08] border-[#FF8B08] hover:text-[#FFB045] hover:[&_.pagination-button]:border-[#FFB045]"
  end

  defp color_variant("outline", "danger") do
    "[&_.pagination-button]:bg-transparent text-[#E73B3B] border-[#E73B3B] hover:text-[#F0756A] hover:[&_.pagination-button]:border-[#F0756A]"
  end

  defp color_variant("outline", "info") do
    "[&_.pagination-button]:bg-transparent text-[#004FC4] border-[#004FC4] hover:text-[#3680DB] hover:[&_.pagination-button]:border-[#3680DB]"
  end

  defp color_variant("outline", "misc") do
    "[&_.pagination-button]:bg-transparent text-[#52059C] border-[#52059C] hover:text-[#8535C3] hover:[&_.pagination-button]:border-[#8535C3]"
  end

  defp color_variant("outline", "dawn") do
    "[&_.pagination-button]:bg-transparent text-[#4D4137] border-[#4D4137] hover:text-[#948474] hover:[&_.pagination-button]:border-[#948474]"
  end

  defp color_variant("outline", "light") do
    "[&_.pagination-button]:bg-transparent text-[#707483] border-[#707483] hover:text-[#A0A5B4] hover:[&_.pagination-button]:border-[#A0A5B4]"
  end

  defp color_variant("outline", "dark") do
    "[&_.pagination-button]:bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:text-[#787878] hover:[&_.pagination-button]:border-[#787878]"
  end

  defp color_variant("unbordered", "white") do
    "[&_.pagination-button]:bg-white text-[#3E3E3E] border-transparent hover:[&_.pagination-button]:bg-[#E8E8E8]"
  end

  defp color_variant("unbordered", "primary") do
    "[&_.pagination-button]:bg-[#4363EC] text-white border-transparent hover:[&_.pagination-button]:bg-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "[&_.pagination-button]:bg-[#6B6E7C] text-white border-transparent hover:[&_.pagination-button]:bg-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "[&_.pagination-button]:bg-[#ECFEF3] text-[#047857] border-transparent hover:[&_.pagination-button]:bg-[#d4fde4]"
  end

  defp color_variant("unbordered", "warning") do
    "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] border-transparent hover:[&_.pagination-button]:bg-[#fff1cd]"
  end

  defp color_variant("unbordered", "danger") do
    "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] border-transparent hover:[&_.pagination-button]:bg-[#ffcdcd]"
  end

  defp color_variant("unbordered", "info") do
    "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] border-transparent hover:[&_.pagination-button]:bg-[#cce1ff]"
  end

  defp color_variant("unbordered", "misc") do
    "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] border-transparent hover:[&_.pagination-button]:bg-[#ffe0ff]"
  end

  defp color_variant("unbordered", "dawn") do
    "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] border-transparent hover:[&_.pagination-button]:bg-[#ffdfc1]"
  end

  defp color_variant("unbordered", "light") do
    "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] border-transparent hover:[&_.pagination-button]:bg-[#d2d8e9]"
  end

  defp color_variant("unbordered", "dark") do
    "[&_.pagination-button]:bg-[#1E1E1E] text-white border-transparent hover:[&_.pagination-button]:bg-[#111111]"
  end

  defp color_variant("transparent", "white") do
    "[&_.pagination-button]:bg-transparent text-white border-transparent hover:text-[#E8E8E8]"
  end

  defp color_variant("transparent", "primary") do
    "[&_.pagination-button]:bg-transparent text-[#4363EC] border-transparent hover:text-[#072ed3]"
  end

  defp color_variant("transparent", "secondary") do
    "[&_.pagination-button]:bg-transparent text-[#6B6E7C] border-transparent hover:text-[#60636f]"
  end

  defp color_variant("transparent", "success") do
    "[&_.pagination-button]:bg-transparent text-[#227A52] border-transparent hover:text-[#50AF7A]"
  end

  defp color_variant("transparent", "warning") do
    "[&_.pagination-button]:bg-transparent text-[#FF8B08] border-transparent hover:text-[#FFB045]"
  end

  defp color_variant("transparent", "danger") do
    "[&_.pagination-button]:bg-transparent text-[#E73B3B] border-transparent hover:text-[#F0756A]"
  end

  defp color_variant("transparent", "info") do
    "[&_.pagination-button]:bg-transparent text-[#6663FD] border-transparent hover:text-[#3680DB]"
  end

  defp color_variant("transparent", "misc") do
    "[&_.pagination-button]:bg-transparent text-[#52059C] border-transparent hover:text-[#8535C3]"
  end

  defp color_variant("transparent", "dawn") do
    "[&_.pagination-button]:bg-transparent text-[#4D4137] border-transparent hover:text-[#948474]"
  end

  defp color_variant("transparent", "light") do
    "[&_.pagination-button]:bg-transparent text-[#707483] border-transparent hover:text-[#A0A5B4]"
  end

  defp color_variant("transparent", "dark") do
    "[&_.pagination-button]:bg-transparent text-[#1E1E1E] border-transparent hover:text-[#787878]"
  end

  defp color_variant("subtle", "white") do
    "[&_.pagination-button]:bg-transparent text-white border-transparent hover:[&_.pagination-button]:bg-white hover:text-[#3E3E3E]"
  end

  defp color_variant("subtle", "primary") do
    "[&_.pagination-button]:bg-transparent text-[#4363EC] border-transparent hover:[&_.pagination-button]:bg-[#4363EC] hover:text-white"
  end

  defp color_variant("subtle", "secondary") do
    "[&_.pagination-button]:bg-transparent text-[#6B6E7C] border-transparent hover:[&_.pagination-button]:bg-[#6B6E7C] hover:text-white"
  end

  defp color_variant("subtle", "success") do
    "[&_.pagination-button]:bg-transparent text-[#227A52] border-transparent hover:[&_.pagination-button]:bg-[#AFEAD0] hover:text-[#227A52]"
  end

  defp color_variant("subtle", "warning") do
    "[&_.pagination-button]:bg-transparent text-[#FF8B08] border-transparent hover:[&_.pagination-button]:bg-[#FFF8E6] hover:text-[#FF8B08]"
  end

  defp color_variant("subtle", "danger") do
    "[&_.pagination-button]:bg-transparent text-[#E73B3B] border-transparent hover:[&_.pagination-button]:bg-[#FFE6E6] hover:text-[#E73B3B]"
  end

  defp color_variant("subtle", "info") do
    "[&_.pagination-button]:bg-transparent text-[#6663FD] border-transparent hover:[&_.pagination-button]:bg-[#E5F0FF] hover:text-[#103483]"
  end

  defp color_variant("subtle", "misc") do
    "[&_.pagination-button]:bg-transparent text-[#52059C] border-transparent hover:[&_.pagination-button]:bg-[#FFE6FF] hover:text-[#52059C]"
  end

  defp color_variant("subtle", "dawn") do
    "[&_.pagination-button]:bg-transparent text-[#4D4137] border-transparent hover:[&_.pagination-button]:bg-[#FFECDA] hover:text-[#4D4137]"
  end

  defp color_variant("subtle", "light") do
    "[&_.pagination-button]:bg-transparent text-[#707483] border-transparent hover:[&_.pagination-button]:bg-[#E3E7F1] hover:text-[#707483]"
  end

  defp color_variant("subtle", "dark") do
    "[&_.pagination-button]:bg-transparent text-[#1E1E1E] border-transparent hover:[&_.pagination-button]:bg-[#111111] hover:text-white"
  end

  defp color_variant("shadow", "white") do
    "[&_.pagination-button]:bg-white text-[#3E3E3E] border-[#DADADA] shadow hover:[&_.pagination-button]:bg-[#E8E8E8] hover:[&_.pagination-button]:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "[&_.pagination-button]:bg-[#4363EC] text-white border-[#4363EC] shadow hover:[&_.pagination-button]:bg-[#072ed3] hover:[&_.pagination-button]:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "[&_.pagination-button]:bg-[#6B6E7C] text-white border-[#6B6E7C] shadow hover:[&_.pagination-button]:bg-[#60636f] hover:[&_.pagination-button]:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "[&_.pagination-button]:bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow hover:[&_.pagination-button]:bg-[#d4fde4] hover:[&_.pagination-button]:border-[#d4fde4]"
  end

  defp color_variant("shadow", "warning") do
    "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow hover:[&_.pagination-button]:bg-[#fff1cd] hover:[&_.pagination-button]:border-[#fff1cd]"
  end

  defp color_variant("shadow", "danger") do
    "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow hover:[&_.pagination-button]:bg-[#ffcdcd] hover:[&_.pagination-button]:border-[#ffcdcd]"
  end

  defp color_variant("shadow", "info") do
    "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow hover:[&_.pagination-button]:bg-[#cce1ff] hover:[&_.pagination-button]:border-[#cce1ff]"
  end

  defp color_variant("shadow", "misc") do
    "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow hover:[&_.pagination-button]:bg-[#ffe0ff] hover:[&_.pagination-button]:border-[#ffe0ff]"
  end

  defp color_variant("shadow", "dawn") do
    "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow hover:[&_.pagination-button]:bg-[#ffdfc1] hover:[&_.pagination-button]:border-[#ffdfc1]"
  end

  defp color_variant("shadow", "light") do
    "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow hover:[&_.pagination-button]:bg-[#d2d8e9] hover:[&_.pagination-button]:border-[#d2d8e9]"
  end

  defp color_variant("shadow", "dark") do
    "[&_.pagination-button]:bg-[#1E1E1E] text-white border-[#1E1E1E] shadow hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:border-[#050404]"
  end

  defp color_variant("inverted", "white") do
    "[&_.pagination-button]:bg-transparent text-white border-white hover:[&_.pagination-button]:bg-white hover:text-[#3E3E3E] hover:[&_.pagination-button]:border-[#DADADA]"
  end

  defp color_variant("inverted", "primary") do
    "[&_.pagination-button]:bg-transparent text-[#4363EC] border-[#4363EC] hover:[&_.pagination-button]:bg-[#4363EC] hover:text-white hover:[&_.pagination-button]:border-[#4363EC]"
  end

  defp color_variant("inverted", "secondary") do
    "[&_.pagination-button]:bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:[&_.pagination-button]:bg-[#6B6E7C] hover:text-white hover:[&_.pagination-button]:border-[#6B6E7C]"
  end

  defp color_variant("inverted", "success") do
    "[&_.pagination-button]:bg-transparent text-[#227A52] border-[#227A52] hover:[&_.pagination-button]:bg-[#AFEAD0] hover:text-[#227A52] hover:[&_.pagination-button]:border-[#AFEAD0]"
  end

  defp color_variant("inverted", "warning") do
    "[&_.pagination-button]:bg-transparent text-[#FF8B08] border-[#FF8B08] hover:[&_.pagination-button]:bg-[#FFF8E6] hover:text-[#FF8B08] hover:[&_.pagination-button]:border-[#FFF8E6]"
  end

  defp color_variant("inverted", "danger") do
    "[&_.pagination-button]:bg-transparent text-[#E73B3B] border-[#E73B3B] hover:[&_.pagination-button]:bg-[#FFE6E6] hover:text-[#E73B3B] hover:[&_.pagination-button]:border-[#FFE6E6]"
  end

  defp color_variant("inverted", "info") do
    "[&_.pagination-button]:bg-transparent text-[#004FC4] border-[#004FC4] hover:[&_.pagination-button]:bg-[#E5F0FF] hover:text-[#103483] hover:[&_.pagination-button]:border-[#E5F0FF]"
  end

  defp color_variant("inverted", "misc") do
    "[&_.pagination-button]:bg-transparent text-[#52059C] border-[#52059C] hover:[&_.pagination-button]:bg-[#FFE6FF] hover:text-[#52059C] hover:[&_.pagination-button]:border-[#FFE6FF]"
  end

  defp color_variant("inverted", "dawn") do
    "[&_.pagination-button]:bg-transparent text-[#4D4137] border-[#4D4137] hover:[&_.pagination-button]:bg-[#FFECDA] hover:text-[#4D4137] hover:[&_.pagination-button]:border-[#FFECDA]"
  end

  defp color_variant("inverted", "light") do
    "[&_.pagination-button]:bg-transparent text-[#707483] border-[#707483] hover:[&_.pagination-button]:bg-[#E3E7F1] hover:text-[#707483] hover:[&_.pagination-button]:border-[#E3E7F1]"
  end

  defp color_variant("inverted", "dark") do
    "[&_.pagination-button]:bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:[&_.pagination-button]:bg-[#111111] hover:text-white hover:[&_.pagination-button]:border-[#111111]"
  end

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
