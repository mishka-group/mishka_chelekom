defmodule MishkaChelekom.Pagination do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS
  # TODO: ADD gap to parent
  
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

  attr :rest, :global,
    include: ~w(disabled hide_one_page show_edges hide_controls grouped),
    doc: ""

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
          color_variant(@variant, @color, Map.get(@rest, :grouped, false)) ++
          [
            rounded_size(@rounded),
            size_class(@size),
            border(@color),
            @class
          ]
      }
    >
      <%= render_slot(@start_items) %>

      <.item_button
        :if={@rest[:show_edges]}
        on_action={{"first", @on_next}}
        page={{nil, @active}}
        params={@params}
        icon={@first_label}
        disabled={@active <= 1}
      />

      <.item_button
        :if={is_nil(@rest[:hide_controls])}
        on_action={{"previous", @on_previous}}
        page={{nil, @active}}
        params={@params}
        icon={@previous_label}
        disabled={@active <= 1}
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
  attr :disabled, :boolean, required: false

  defp item_button(%{on_action: {"select", _on_action}} = assigns) do
    ~H"""
    <button
      class={[
        "pagination-button border",
        elem(@page, 1) == elem(@page, 0) && "active-pagination-button"
      ]}
      phx-click={
        elem(@on_action, 1)
        |> JS.push("pagination", value: Map.merge(%{action: "select", page: elem(@page, 0)}, @params))
      }
      disabled={elem(@page, 0) == elem(@page, 1)}
    >
      <%= elem(@page, 0) %>
    </button>
    """
  end

  defp item_button(assigns) do
    ~H"""
    <button
      phx-click={
        elem(@on_action, 1)
        |> JS.push("pagination", value: Map.merge(%{action: elem(@on_action, 0)}, @params))
      }
      disabled={@disabled}
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
    "border-[#DADADA] border-[#d9d9d9]"
  end

  defp border("transparent") do
    "border-transparent"
  end

  defp border("primary") do
    "border-[#4363EC] border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] border-[#4c4f59]"
  end

  defp border("success") do
    "border-[#227A52] border-[#c0fad7]"
  end

  defp border("warning") do
    "border-[#FF8B08] border-[#fcebc0]"
  end

  defp border("danger") do
    "border-[#E73B3B] border-[#fcbbbb]"
  end

  defp border("info") do
    "border-[#004FC4] border-[#bdd3f2]"
  end

  defp border("misc") do
    "border-[#52059C] border-[#edcced]"
  end

  defp border("dawn") do
    "border-[#4D4137] border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] border-[#c8cee0]"
  end

  defp border("dark") do
    "border-[#1E1E1E] border-[#111111]"
  end

  defp rounded_size("extra_small"), do: "[&_.pagination-button]:rounded-sm"
  defp rounded_size("small"), do: "[&_.pagination-button]:rounded"
  defp rounded_size("medium"), do: "[&_.pagination-button]:rounded-md"
  defp rounded_size("large"), do: "[&_.pagination-button]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.pagination-button]:rounded-xl"
  defp rounded_size("full"), do: "[&_.pagination-button]:rounded-full"
  defp rounded_size("none"), do: "[&_.pagination-button]:rounded-none"

  defp size_class("extra_small"), do: "[&_.pagination-button]:size-6 text-xs"
  defp size_class("small"), do: "[&_.pagination-button]:size-7 text-sm"
  defp size_class("medium"), do: "[&_.pagination-button]:size-8 text-base"
  defp size_class("large"), do: "[&_.pagination-button]:size-9 text-lg"
  defp size_class("extra_large"), do: "[&_.pagination-button]:size-10 text-xl"
  defp size_class(params) when is_binary(params), do: params

  defp color_variant("default", "white", grouped) do
    [
      "[&_.pagination-button]:bg-white [&_.pagination-button]:text-[#3E3E3E]",
      "[&_.pagination-button]:border-[#DADADA] hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "hover:[&_.pagination-button]:border-[#d9d9d9]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:border-[#d9d9d9]"
    ]
  end

  defp color_variant("default", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#2441de] hover:[&_.pagination-button]:bg-[#072ed3]",
      "hover:[&_.pagination-button]:border-[#2441de]",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]",
      "[&_.pagination-button.active-pagination-button]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#877C7C] hover:[&_.pagination-button]:bg-[#4c4f59]",
      "hover:[&_.pagination-button]:border-[#3d3f49]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]",
      "[&_.pagination-button.active-pagination-button]:border-[#3d3f49]"
    ]
  end

  defp color_variant("default", "success", grouped) do
    [
      "[&_.pagination-button]:bg-[#ECFEF3] [&_.pagination-button]:text-[#047857]",
      "[&_.pagination-button]:border-[#6EE7B7] hover:[&_.pagination-button]:bg-[#c0fad7]",
      "hover:[&_.pagination-button]:border-[#6EE7B7]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c0fad7]",
      "[&_.pagination-button.active-pagination-button]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFF8E6] [&_.pagination-button]:text-[#FF8B08]",
      "[&_.pagination-button]:border-[#FF8B08] hover:[&_.pagination-button]:bg-[#fcebc0]",
      "hover:[&_.pagination-button]:border-[#FF8B08]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcebc0]",
      "[&_.pagination-button.active-pagination-button]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6E6] [&_.pagination-button]:text-[#E73B3B]",
      "[&_.pagination-button]:border-[#E73B3B] hover:[&_.pagination-button]:bg-[#fcbbbb]",
      "hover:[&_.pagination-button]:border-[#E73B3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]",
      "[&_.pagination-button.active-pagination-button]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info", grouped) do
    [
      "[&_.pagination-button]:bg-[#E5F0FF] [&_.pagination-button]:text-[#004FC4]",
      "[&_.pagination-button]:border-[#004FC4] hover:[&_.pagination-button]:bg-[#bdd3f2]",
      "hover:[&_.pagination-button]:border-[#004FC4]",
      "[&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]",
      "[&_.pagination-button.active-pagination-button]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6FF] [&_.pagination-button]:text-[#52059C]",
      "[&_.pagination-button]:border-[#52059C] hover:[&_.pagination-button]:bg-[#edcced]",
      "hover:[&_.pagination-button]:border-[#52059C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#edcced]",
      "[&_.pagination-button.active-pagination-button]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFECDA] [&_.pagination-button]:text-[#4D4137]",
      "[&_.pagination-button]:border-[#4D4137] hover:[&_.pagination-button]:bg-[#ffdfc1]",
      "hover:[&_.pagination-button]:border-[#4D4137]",
      "[&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]",
      "[&_.pagination-button.active-pagination-button]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light", grouped) do
    [
      "[&_.pagination-button]:bg-[#E3E7F1] [&_.pagination-button]:text-[#707483]",
      "[&_.pagination-button]:border-[#707483] hover:[&_.pagination-button]:bg-[#c8cee0]",
      "hover:[&_.pagination-button]:border-[#707483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c8cee0]",
      "[&_.pagination-button.active-pagination-button]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#050404] hover:[&_.pagination-button]:bg-[#4e4e4e]",
      "hover:[&_.pagination-button]:border-[#050404]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4e4e4e]",
      "[&_.pagination-button.active-pagination-button]:border-[#050404]"
    ]
  end

  defp color_variant("outline", "white", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-white [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-white hover:[&_.pagination-button]:text-[#E8E8E8]",
      "hover:[&_.pagination-button]:border-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:bg-[#484747]",
      "[&_.pagination-button.active-pagination-button]:border-[#E8E8E8]"
    ]
  end

  defp color_variant("outline", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&_.pagination-button]:border-[#4363EC]",
      "hover:[&_.pagination-button]:text-[#002cff] hover:[&_.pagination-button]:border-[#002cff]",
      "[&_.pagination-button.active-pagination-button]:text-[#002cff]",
      "[&_.pagination-button.active-pagination-button]:border-[#002cff]"
    ]
  end

  defp color_variant("outline", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&_.pagination-button]:border-[#6B6E7C]",
      "hover:[&_.pagination-button]:text-[#020202] hover:[&_.pagination-button]:border-[#020202]",
      "[&_.pagination-button.active-pagination-button]:text-[#020202]",
      "[&_.pagination-button.active-pagination-button]:border-[#020202]"
    ]
  end

  defp color_variant("outline", "success", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&_.pagination-button]:border-[#6EE7B7]",
      "hover:text-[#126c3a] hover:[&_.pagination-button]:border-[#126c3a]",
      "[&_.pagination-button.active-pagination-button]:text-[#126c3a]",
      "[&_.pagination-button.active-pagination-button]:border-[#126c3a]"
    ]
  end

  defp color_variant("outline", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&_.pagination-button]:border-[#FF8B08]",
      "hover:text-[#9b6112] hover:[&_.pagination-button]:border-[#9b6112]",
      "[&_.pagination-button.active-pagination-button]:text-[#9b6112]",
      "[&_.pagination-button.active-pagination-button]:border-[#9b6112]"
    ]
  end

  defp color_variant("outline", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&_.pagination-button]:border-[#E73B3B]",
      "hover:text-[#a52e23] hover:[&_.pagination-button]:border-[#a52e23]",
      "[&_.pagination-button.active-pagination-button]:text-[#a52e23]",
      "[&_.pagination-button.active-pagination-button]:border-[#a52e23]"
    ]
  end

  defp color_variant("outline", "info", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#004FC4] [&_.pagination-button]:border-[#004FC4]",
      "hover:text-[#132e50] hover:[&_.pagination-button]:border-[#132e50]",
      "[&_.pagination-button.active-pagination-button]:text-[#132e50]",
      "[&_.pagination-button.active-pagination-button]:border-[#132e50]"
    ]
  end

  defp color_variant("outline", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&_.pagination-button]:border-[#52059C]",
      "hover:text-[#491d6a] hover:[&_.pagination-button]:border-[#491d6a]",
      "[&_.pagination-button.active-pagination-button]:text-[#491d6a]",
      "[&_.pagination-button.active-pagination-button]:border-[#491d6a]"
    ]
  end

  defp color_variant("outline", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&_.pagination-button]:border-[#4D4137]",
      "hover:text-[#28231d] hover:[&_.pagination-button]:border-[#28231d]",
      "[&_.pagination-button.active-pagination-button]:text-[#28231d]",
      "[&_.pagination-button.active-pagination-button]:border-[#28231d]"
    ]
  end

  defp color_variant("outline", "light", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#707483] [&_.pagination-button]:border-[#707483]",
      "hover:text-[#42485a] hover:[&_.pagination-button]:border-[#42485a]",
      "[&_.pagination-button.active-pagination-button]:text-[#42485a]",
      "[&_.pagination-button.active-pagination-button]:border-[#42485a]"
    ]
  end

  defp color_variant("outline", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&_.pagination-button]:border-[#1E1E1E]",
      "hover:text-[#787878] hover:[&_.pagination-button]:border-[#787878]",
      "[&_.pagination-button.active-pagination-button]:text-[#787878]",
      "[&_.pagination-button.active-pagination-button]:border-[#787878]"
    ]
  end

  defp color_variant("unbordered", "white", grouped) do
    [
      "[&_.pagination-button]:bg-white text-[#3E3E3E] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#E8E8E8] [&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("unbordered", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#072ed3]",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]"
    ]
  end

  defp color_variant("unbordered", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#4c4f59]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]"
    ]
  end

  defp color_variant("unbordered", "success", grouped) do
    [
      "[&_.pagination-button]:bg-[#ECFEF3] text-[#047857] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#c0fad7] [&_.pagination-button.active-pagination-button]:bg-[#c0fad7]"
    ]
  end

  defp color_variant("unbordered", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#fcebc0] [&_.pagination-button.active-pagination-button]:bg-[#fcebc0]"
    ]
  end

  defp color_variant("unbordered", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#fcbbbb] [&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]"
    ]
  end

  defp color_variant("unbordered", "info", grouped) do
    [
      "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#bdd3f2] [&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]"
    ]
  end

  defp color_variant("unbordered", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#edcced] [&_.pagination-button.active-pagination-button]:bg-[#edcced]"
    ]
  end

  defp color_variant("unbordered", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#ffdfc1] [&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]"
    ]
  end

  defp color_variant("unbordered", "light", grouped) do
    [
      "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#c8cee0] [&_.pagination-button.active-pagination-button]:bg-[#c8cee0]"
    ]
  end

  defp color_variant("unbordered", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]"
    ]
  end

  defp color_variant("transparent", "white", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-white [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#E8E8E8] [&_.pagination-button.active-pagination-button]:bg-[#484747] [&_.pagination-button.active-pagination-button]:text-[#E8E8E8]"
    ]
  end

  defp color_variant("transparent", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#002cff]",
      "[&_.pagination-button.active-pagination-button]:text-[#002cff]"
    ]
  end

  defp color_variant("transparent", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#020202]",
      "[&_.pagination-button.active-pagination-button]:text-[#020202]"
    ]
  end

  defp color_variant("transparent", "success", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#126c3a] [&_.pagination-button.active-pagination-button]:text-[#126c3a]"
    ]
  end

  defp color_variant("transparent", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#9b6112]",
      "[&_.pagination-button.active-pagination-button]:text-[#9b6112]"
    ]
  end

  defp color_variant("transparent", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#a52e23]",
      "[&_.pagination-button.active-pagination-button]:text-[#a52e23]"
    ]
  end

  defp color_variant("transparent", "info", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6663FD] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#132e50]",
      "[&_.pagination-button.active-pagination-button]:text-[#132e50]"
    ]
  end

  defp color_variant("transparent", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#491d6a]",
      "[&_.pagination-button.active-pagination-button]:text-[#491d6a]"
    ]
  end

  defp color_variant("transparent", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#28231d]",
      "[&_.pagination-button.active-pagination-button]:text-[#28231d]"
    ]
  end

  defp color_variant("transparent", "light", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#707483] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#42485a]",
      "[&_.pagination-button.active-pagination-button]:text-[#42485a]"
    ]
  end

  defp color_variant("transparent", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#787878]",
      "[&_.pagination-button.active-pagination-button]:text-[#787878]"
    ]
  end

  defp color_variant("subtle", "white", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-white [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-white hover:[&_.pagination-button]:text-[#3E3E3E]",
      "[&_.pagination-button.active-pagination-button]:bg-white",
      "[&_.pagination-button.active-pagination-button]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("subtle", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#4363EC] hover:[&_.pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#4363EC]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("subtle", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#6B6E7C] hover:[&_.pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("subtle", "success", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#AFEAD0] hover:[&_.pagination-button]:text-[#227A52]",
      "[&_.pagination-button.active-pagination-button]:bg-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:text-[#227A52]"
    ]
  end

  defp color_variant("subtle", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFF8E6] hover:[&_.pagination-button]:text-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#FF8B08]"
    ]
  end

  defp color_variant("subtle", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFE6E6] hover:[&_.pagination-button]:text-[#E73B3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#E73B3B]"
    ]
  end

  defp color_variant("subtle", "info", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6663FD] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#E5F0FF] hover:[&_.pagination-button]:text-[#103483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#103483]"
    ]
  end

  defp color_variant("subtle", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFE6FF] hover:[&_.pagination-button]:text-[#52059C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#52059C]"
    ]
  end

  defp color_variant("subtle", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFECDA] hover:[&_.pagination-button]:text-[#4D4137]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:text-[#4D4137]"
    ]
  end

  defp color_variant("subtle", "light", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#707483] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#E3E7F1] hover:[&_.pagination-button]:text-[#707483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:text-[#707483]"
    ]
  end

  defp color_variant("subtle", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("shadow", "white", grouped) do
    [
      "[&_.pagination-button]:bg-white text-[#3E3E3E] [&_.pagination-button]:border-[#DADADA]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "hover:[&_.pagination-button]:border-[#d9d9d9]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:border-[#d9d9d9]"
    ]
  end

  defp color_variant("shadow", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#4363EC] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#072ed3] hover:[&_.pagination-button]:border-[#072ed3]",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]",
      "[&_.pagination-button.active-pagination-button]:border-[#072ed3]"
    ]
  end

  defp color_variant("shadow", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#6B6E7C] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#4c4f59] hover:[&_.pagination-button]:border-[#4c4f59]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]",
      "[&_.pagination-button.active-pagination-button]:border-[#4c4f59]"
    ]
  end

  defp color_variant("shadow", "success", grouped) do
    [
      "[&_.pagination-button]:bg-[#AFEAD0] text-[#227A52] [&_.pagination-button]:border-[#AFEAD0]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#c0fad7]",
      "hover:[&_.pagination-button]:border-[#c0fad7]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c0fad7]",
      "[&_.pagination-button.active-pagination-button]:border-[#c0fad7]"
    ]
  end

  defp color_variant("shadow", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] [&_.pagination-button]:border-[#FFF8E6]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#fcebc0]",
      "hover:[&_.pagination-button]:border-[#fcebc0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcebc0]",
      "[&_.pagination-button.active-pagination-button]:border-[#fcebc0]"
    ]
  end

  defp color_variant("shadow", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] [&_.pagination-button]:border-[#FFE6E6]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#fcbbbb]",
      "hover:[&_.pagination-button]:border-[#fcbbbb]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]",
      "[&_.pagination-button.active-pagination-button]:border-[#fcbbbb]"
    ]
  end

  defp color_variant("shadow", "info", grouped) do
    [
      "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] [&_.pagination-button]:border-[#E5F0FF]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#bdd3f2]",
      "hover:[&_.pagination-button]:border-[#bdd3f2]",
      "[&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]",
      "[&_.pagination-button.active-pagination-button]:border-[#bdd3f2]"
    ]
  end

  defp color_variant("shadow", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] [&_.pagination-button]:border-[#FFE6FF]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#edcced]",
      "hover:[&_.pagination-button]:border-[#edcced]",
      "[&_.pagination-button.active-pagination-button]:bg-[#edcced]",
      "[&_.pagination-button.active-pagination-button]:border-[#edcced]"
    ]
  end

  defp color_variant("shadow", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] [&_.pagination-button]:border-[#FFECDA]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#ffdfc1]",
      "hover:[&_.pagination-button]:border-[#ffdfc1]",
      "[&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]",
      "[&_.pagination-button.active-pagination-button]:border-[#ffdfc1]"
    ]
  end

  defp color_variant("shadow", "light", grouped) do
    [
      "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] [&_.pagination-button]:border-[#E3E7F1]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#c8cee0]",
      "hover:[&_.pagination-button]:border-[#c8cee0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c8cee0]",
      "[&_.pagination-button.active-pagination-button]:border-[#c8cee0]"
    ]
  end

  defp color_variant("shadow", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&_.pagination-button]:border-[#1E1E1E] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:border-[#050404]",
      "[&_.pagination-button.active-pagination-button]:bg-[#050404]",
      "[&_.pagination-button.active-pagination-button]:border-[#050404]"
    ]
  end

  defp color_variant("inverted", "white", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-white [&_.pagination-button]:border-white",
      "hover:[&_.pagination-button]:bg-white hover:[&_.pagination-button]:text-[#3E3E3E]",
      "hover:[&_.pagination-button]:border-[#DADADA] [&_.pagination-button.active-pagination-button]:bg-white",
      "[&_.pagination-button.active-pagination-button]:text-[#3E3E3E]",
      "[&_.pagination-button.active-pagination-button]:border-[#DADADA]"
    ]
  end

  defp color_variant("inverted", "primary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&_.pagination-button]:border-[#4363EC]",
      "hover:[&_.pagination-button]:bg-[#4363EC] hover:[&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:border-[#4363EC] [&_.pagination-button.active-pagination-button]:bg-[#4363EC]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:border-[#4363EC]"
    ]
  end

  defp color_variant("inverted", "secondary", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&_.pagination-button]:border-[#6B6E7C]",
      "hover:[&_.pagination-button]:bg-[#6B6E7C] hover:[&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:border-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("inverted", "success", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&_.pagination-button]:border-[#227A52]",
      "hover:[&_.pagination-button]:bg-[#AFEAD0] hover:[&_.pagination-button]:text-[#227A52]",
      "hover:[&_.pagination-button]:border-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:text-[#227A52]",
      "[&_.pagination-button.active-pagination-button]:border-[#AFEAD0]"
    ]
  end

  defp color_variant("inverted", "warning", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&_.pagination-button]:border-[#FF8B08]",
      "hover:[&_.pagination-button]:bg-[#FFF8E6] hover:[&_.pagination-button]:text-[#FF8B08]",
      "hover:[&_.pagination-button]:border-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#FF8B08]",
      "[&_.pagination-button.active-pagination-button]:border-[#FFF8E6]"
    ]
  end

  defp color_variant("inverted", "danger", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&_.pagination-button]:border-[#E73B3B]",
      "hover:[&_.pagination-button]:bg-[#FFE6E6] hover:[&_.pagination-button]:text-[#E73B3B]",
      "hover:[&_.pagination-button]:border-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#E73B3B]",
      "[&_.pagination-button.active-pagination-button]:border-[#FFE6E6]"
    ]
  end

  defp color_variant("inverted", "info", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#004FC4] [&_.pagination-button]:border-[#004FC4]",
      "hover:[&_.pagination-button]:bg-[#E5F0FF] hover:[&_.pagination-button]:text-[#103483]",
      "hover:[&_.pagination-button]:border-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#103483]",
      "[&_.pagination-button.active-pagination-button]:border-[#E5F0FF]"
    ]
  end

  defp color_variant("inverted", "misc", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&_.pagination-button]:border-[#52059C]",
      "hover:[&_.pagination-button]:bg-[#FFE6FF] hover:[&_.pagination-button]:text-[#52059C]",
      "hover:[&_.pagination-button]:border-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#52059C]",
      "[&_.pagination-button.active-pagination-button]:border-[#FFE6FF]"
    ]
  end

  defp color_variant("inverted", "dawn", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&_.pagination-button]:border-[#4D4137]",
      "hover:[&_.pagination-button]:bg-[#FFECDA] hover:[&_.pagination-button]:text-[#4D4137]",
      "hover:[&_.pagination-button]:border-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:text-[#4D4137]",
      "[&_.pagination-button.active-pagination-button]:border-[#FFECDA]"
    ]
  end

  defp color_variant("inverted", "light", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#707483] [&_.pagination-button]:border-[#707483]",
      "hover:[&_.pagination-button]:bg-[#E3E7F1] hover:[&_.pagination-button]:text-[#707483]",
      "hover:[&_.pagination-button]:border-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:text-[#707483]",
      "[&_.pagination-button.active-pagination-button]:border-[#E3E7F1]"
    ]
  end

  defp color_variant("inverted", "dark", grouped) do
    [
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&_.pagination-button]:border-[#1E1E1E]",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:border-[#111111]",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&_.pagination-button.active-pagination-button]:border-[#111111]"
    ]
  end

  defp default_classes() do
    [
      "flex items-center [&_.pagination-button.active-pagination-button]:font-medium"
    ]
  end

  defp show_pagination?(nil, _total), do: true
  defp show_pagination?(true, total) when total <= 1, do: false
  defp show_pagination?(_, total) when total > 1, do: true
  defp show_pagination?(_, _), do: false
end
