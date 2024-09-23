defmodule MishkaChelekom.Pagination do
  @moduledoc """
  The `MishkaChelekom.Pagination` module provides a comprehensive and highly customizable
  pagination component for Phoenix LiveView applications.

  It is designed to handle complex pagination scenarios, supporting various styles,
  sizes, colors, and interaction patterns.

  This module offers several options to tailor the pagination component's appearance and behavior,
  such as custom icons, separators, and control buttons.

  It allows for fine-tuning of the pagination layout, including sibling and boundary
  controls, as well as different visual variants like outlined, shadowed, and inverted styles.

  These features enable developers to integrate pagination seamlessly into their UI,
  enhancing user experience and interaction.
  """

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
    "unbordered"
  ]

  @doc """
  Renders a `pagination` component that allows users to navigate through pages.

  The component supports various configurations such as setting the total number of pages,
  current active page, and the number of sibling and boundary pages to display.

  Custom icons or labels can be used for navigation controls, and slots are available
  for additional start and end items.

  ## Examples

  ```elixir
  <.pagination
    total={200}
    active={@posts.active}
    siblings={3}
    show_edges
    grouped
    next_label="next"
    previous_label="prev"
    first_label="first"
    last_label="last"
  />

  <.pagination total={@posts.total} active={@posts.active} siblings={3} variant="outline" show_edges grouped/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :total, :integer, required: true, doc: ""
  attr :active, :integer, default: 1, doc: ""
  attr :siblings, :integer, default: 1, doc: ""
  attr :boundaries, :integer, default: 1, doc: ""
  attr :on_select, JS, default: %JS{}, doc: "Custom JS module for on_select action"
  attr :on_first, JS, default: %JS{}, doc: "Custom JS module for on_first action"
  attr :on_last, JS, default: %JS{}, doc: "Custom JS module for on_last action"
  attr :on_next, JS, default: %JS{}, doc: "Custom JS module for on_next action"
  attr :on_previous, JS, default: %JS{}, doc: "Custom JS module for on_previous action"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "gap-3", doc: "Space between items"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "small",
    doc: "Determines the border radius"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"

  attr :separator, :string,
    default: "hero-ellipsis-horizontal",
    doc: "Determines a separator for items of an element"

  attr :next_label, :string,
    default: "hero-chevron-right",
    doc: "Determines the next icon or label"

  attr :previous_label, :string,
    default: "hero-chevron-left",
    doc: "Determines the previous icon or label"

  attr :first_label, :string,
    default: "hero-chevron-double-left",
    doc: "Determines the first icon or label"

  attr :last_label, :string,
    default: "hero-chevron-double-right",
    doc: "Determines the last icon or label"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :params, :map,
    default: %{},
    doc: "A map of additional parameters used for element configuration"

  slot :start_items, required: false, doc: "Determines the start items which accept heex"
  slot :end_items, required: false, doc: "Determines the end items which accept heex"

  attr :rest, :global,
    include: ~w(disabled hide_one_page show_edges hide_controls grouped),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

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
          color_variant(@variant, @color) ++
          [
            rounded_size(@rounded),
            size_class(@size),
            border(@color),
            if(is_nil(@rest[:grouped]), do: @space, else: "gap-0 grouped-pagination"),
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
          <div class="pagination-seperator flex justify-center items-center">
            <.icon_or_text name={@separator} />
          </div>
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

  @doc type: :component
  attr :name, :string, doc: "Specifies the name of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

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

  @doc type: :component
  attr :params, :map,
    default: %{},
    doc: "A map of additional parameters used for element configuration"

  attr :page, :list, required: true, doc: "Specifies pagination pages"
  attr :on_action, JS, default: %JS{}, doc: "Custom JS module for on_action action"
  attr :icon, :string, required: false, doc: "Icon displayed alongside of an item"
  attr :disabled, :boolean, required: false, doc: "Specifies whether the element is disabled"

  defp item_button(%{on_action: {"select", _on_action}} = assigns) do
    ~H"""
    <button
      class={[
        "pagination-button",
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
      class="pagination-control flex items-center justify-center"
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

  defp border("transparent") do
    ["[&.grouped-pagination]:border border-transparent"]
  end

  defp border("white") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#DADADA] [&.grouped-pagination_.pagination-button]:border-[#DADADA]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#DADADA]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#DADADA]"
    ]
  end

  defp border("primary") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#4363EC] [&.grouped-pagination_.pagination-button]:border-[#2441de]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#2441de]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#2441de]"
    ]
  end

  defp border("secondary") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#6B6E7C] [&.grouped-pagination_.pagination-button]:border-[#3d3f49]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#3d3f49]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#3d3f49]"
    ]
  end

  defp border("success") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#227A52] [&.grouped-pagination_.pagination-button]:border-[#227A52]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#227A52]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#227A52]"
    ]
  end

  defp border("warning") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#FF8B08] [&.grouped-pagination_.pagination-button]:border-[#FF8B08]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#FF8B08]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#FF8B08]"
    ]
  end

  defp border("danger") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#E73B3B] [&.grouped-pagination_.pagination-button]:border-[#E73B3B]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#E73B3B]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#E73B3B]"
    ]
  end

  defp border("info") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#004FC4] [&.grouped-pagination_.pagination-button]:border-[#004FC4]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#004FC4]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#004FC4]"
    ]
  end

  defp border("misc") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#52059C] [&.grouped-pagination_.pagination-button]:border-[#52059C]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#52059C]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#52059C]"
    ]
  end

  defp border("dawn") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#4D4137] [&.grouped-pagination_.pagination-button]:border-[#4D4137]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#4D4137]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#4D4137]"
    ]
  end

  defp border("light") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#707483] [&.grouped-pagination_.pagination-button]:border-[#707483]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#707483]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#707483]"
    ]
  end

  defp border("dark") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#1E1E1E] [&.grouped-pagination_.pagination-button]:border-[#1E1E1E]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#1E1E1E]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#1E1E1E]"
    ]
  end

  defp rounded_size("extra_small"),
    do:
      "[&.grouped-pagination]:rounded-sm [&:not(.grouped-pagination)_.pagination-button]:rounded-sm"

  defp rounded_size("small"),
    do: "[&.grouped-pagination]:rounded [&:not(.grouped-pagination)_.pagination-button]:rounded"

  defp rounded_size("medium"),
    do:
      "[&.grouped-pagination]:rounded-md [&:not(.grouped-pagination)_.pagination-button]:rounded-md"

  defp rounded_size("large"),
    do:
      "[&.grouped-pagination]:rounded-lg [&:not(.grouped-pagination)_.pagination-button]:rounded-lg"

  defp rounded_size("extra_large"),
    do:
      "[&.grouped-pagination]:rounded-xl [&:not(.grouped-pagination)_.pagination-button]:rounded-xl"

  defp rounded_size("full"),
    do:
      "[&.grouped-pagination]:rounded-full [&:not(.grouped-pagination)_.pagination-button]:rounded-full"

  defp rounded_size("none"),
    do:
      "[&.grouped-pagination]:rounded-none [&:not(.grouped-pagination)_.pagination-button]:rounded-none"

  defp size_class("extra_small") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-6",
      "[&.grouped-pagination_.pagination-button]:min-w-6 [&.grouped-pagination_.pagination-control]:min-w-6",
      "[&_.pagination-button]:h-6 [&_.pagination-control>.pagination-icon]:h-6",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-seperator]:h-6 text-xs",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-3.5"
    ]
  end

  defp size_class("small") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-7",
      "[&.grouped-pagination_.pagination-button]:min-w-7 [&.grouped-pagination_.pagination-control]:min-w-7",
      "[&_.pagination-button]:h-7 [&_.pagination-control>.pagination-icon]:h-7",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-7 text-sm",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-4"
    ]
  end

  defp size_class("medium") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-8",
      "[&.grouped-pagination_.pagination-button]:min-w-8 [&.grouped-pagination_.pagination-control]:min-w-8",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-8 [&_.pagination-control>.pagination-icon]:h-8",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-8 text-base",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-5"
    ]
  end

  defp size_class("large") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-9",
      "[&.grouped-pagination_.pagination-button]:min-w-9 [&.grouped-pagination_.pagination-control]:min-w-9",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-9 [&_.pagination-control>.pagination-icon]:h-9",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-9 text-lg",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-6"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-10",
      "[&.grouped-pagination_.pagination-button]:min-w-10 [&.grouped-pagination_.pagination-control]:min-w-10",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-10 [&_.pagination-control>.pagination-icon]:h-10",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-10 text-xl",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-7"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp color_variant("default", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-white [&_.pagination-button]:text-[#3E3E3E]",
      "[&.grouped-pagination_.pagination-control]:bg-white [&.grouped-pagination_.pagination-control]:text-[#3E3E3E]",
      "[&.grouped-pagination_.pagination-seperator]:bg-white [&.grouped-pagination_.pagination-seperator]:text-[#3E3E3E]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#DADADA] hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E8E8E8]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#d9d9d9]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#d9d9d9]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-[#4363EC] [&.grouped-pagination_.pagination-control]:text-white",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#4363EC] [&.grouped-pagination_.pagination-seperator]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#2441de] hover:[&_.pagination-button]:bg-[#072ed3]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#072ed3]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#2441de]",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-[#6B6E7C] [&.grouped-pagination_.pagination-control]:text-white",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#6B6E7C] [&.grouped-pagination_.pagination-seperator]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#877C7C] hover:[&_.pagination-button]:bg-[#4c4f59]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4c4f59]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#3d3f49]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#3d3f49]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#ECFEF3] [&_.pagination-button]:text-[#047857]",
      "[&.grouped-pagination_.pagination-control]:bg-[#ECFEF3] [&.grouped-pagination_.pagination-control]:text-[#047857]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#ECFEF3] [&.grouped-pagination_.pagination-seperator]:text-[#047857]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#6EE7B7] hover:[&_.pagination-button]:bg-[#c0fad7]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c0fad7]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#6EE7B7]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c0fad7]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFF8E6] [&_.pagination-button]:text-[#FF8B08]",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFF8E6] [&.grouped-pagination_.pagination-control]:text-[#FF8B08]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFF8E6] [&.grouped-pagination_.pagination-seperator]:text-[#FF8B08]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#FF8B08] hover:[&_.pagination-button]:bg-[#fcebc0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcebc0]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#FF8B08]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcebc0]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6E6] [&_.pagination-button]:text-[#E73B3B]",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFE6E6] [&.grouped-pagination_.pagination-control]:text-[#E73B3B]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFE6E6] [&.grouped-pagination_.pagination-seperator]:text-[#E73B3B]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#E73B3B] hover:[&_.pagination-button]:bg-[#fcbbbb]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcbbbb]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#E73B3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E5F0FF] [&_.pagination-button]:text-[#004FC4]",
      "[&.grouped-pagination_.pagination-control]:bg-[#E5F0FF] [&.grouped-pagination_.pagination-control]:text-[#004FC4]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#E5F0FF] [&.grouped-pagination_.pagination-seperator]:text-[#004FC4]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#004FC4] hover:[&_.pagination-button]:bg-[#bdd3f2]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#bdd3f2]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#004FC4]",
      "[&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6FF] [&_.pagination-button]:text-[#52059C]",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFE6FF] [&.grouped-pagination_.pagination-control]:text-[#52059C]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFE6FF] [&.grouped-pagination_.pagination-seperator]:text-[#52059C]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#52059C] hover:[&_.pagination-button]:bg-[#edcced]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#edcced]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#52059C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#edcced]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFECDA] [&_.pagination-button]:text-[#4D4137]",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFECDA] [&.grouped-pagination_.pagination-control]:text-[#4D4137]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFECDA] [&.grouped-pagination_.pagination-seperator]:text-[#4D4137]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#4D4137] hover:[&_.pagination-button]:bg-[#ffdfc1]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#ffdfc1]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#4D4137]",
      "[&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E3E7F1] [&_.pagination-button]:text-[#707483]",
      "[&.grouped-pagination_.pagination-control]:bg-[#E3E7F1] [&.grouped-pagination_.pagination-control]:text-[#707483]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#E3E7F1] [&.grouped-pagination_.pagination-seperator]:text-[#707483]",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#707483] hover:[&_.pagination-button]:bg-[#c8cee0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c8cee0]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#707483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c8cee0]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-[#1E1E1E] [&.grouped-pagination_.pagination-control]:text-white",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#1E1E1E] [&.grouped-pagination_.pagination-seperator]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#050404] hover:[&_.pagination-button]:bg-[#4e4e4e]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4e4e4e]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#050404]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4e4e4e]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#050404]"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-white [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-transparent [&.grouped-pagination_.pagination-control]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-white hover:[&_.pagination-button]:text-[#E8E8E8]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:bg-[#484747]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#E8E8E8]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&:not(.grouped-pagination)_.pagination-button]:border-[#4363EC]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:[&_.pagination-button]:text-[#002cff] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#002cff]",
      "[&_.pagination-button.active-pagination-button]:text-[#002cff]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#002cff]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&:not(.grouped-pagination)_.pagination-button]:border-[#6B6E7C]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:[&_.pagination-button]:text-[#020202] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#020202]",
      "[&_.pagination-button.active-pagination-button]:text-[#020202]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#020202]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&:not(.grouped-pagination)_.pagination-button]:border-[#6EE7B7]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#126c3a] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#126c3a]",
      "[&_.pagination-button.active-pagination-button]:text-[#126c3a]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#126c3a]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-[#FF8B08]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#9b6112] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#9b6112]",
      "[&_.pagination-button.active-pagination-button]:text-[#9b6112]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#9b6112]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-[#E73B3B]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#a52e23] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#a52e23]",
      "[&_.pagination-button.active-pagination-button]:text-[#a52e23]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#a52e23]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#004FC4] [&:not(.grouped-pagination)_.pagination-button]:border-[#004FC4]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#132e50] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#132e50]",
      "[&_.pagination-button.active-pagination-button]:text-[#132e50]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#132e50]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-[#52059C]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#491d6a] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#491d6a]",
      "[&_.pagination-button.active-pagination-button]:text-[#491d6a]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#491d6a]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-[#4D4137]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#28231d] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#28231d]",
      "[&_.pagination-button.active-pagination-button]:text-[#28231d]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#28231d]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-[#707483]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#42485a] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#42485a]",
      "[&_.pagination-button.active-pagination-button]:text-[#42485a]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#42485a]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&:not(.grouped-pagination)_.pagination-button]:border-[#1E1E1E]",
      "[&.grouped-pagination_.pagination-control]:bg-transparent",
      "hover:text-[#787878] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#787878]",
      "[&_.pagination-button.active-pagination-button]:text-[#787878]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#787878]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-white text-[#3E3E3E] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-white",
      "[&.grouped-pagination_.pagination-seperator]:bg-white",
      "hover:[&_.pagination-button]:bg-[#E8E8E8] [&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-[#4363EC]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#4363EC] [&.grouped-pagination_.pagination-seperator]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#072ed3]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#072ed3] [&.grouped-pagination_.pagination-control]:text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&.grouped-pagination_.pagination-control]:bg-[#6B6E7C]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#6B6E7C] [&.grouped-pagination_.pagination-seperator]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#4c4f59]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4c4f59] [&.grouped-pagination_.pagination-control]:text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#ECFEF3] text-[#047857] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#ECFEF3]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#ECFEF3]",
      "hover:[&_.pagination-button]:bg-[#c0fad7] [&_.pagination-button.active-pagination-button]:bg-[#c0fad7]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c0fad7]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFF8E6]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFF8E6]",
      "hover:[&_.pagination-button]:bg-[#fcebc0] [&_.pagination-button.active-pagination-button]:bg-[#fcebc0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcebc0]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFE6E6]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFE6E6]",
      "hover:[&_.pagination-button]:bg-[#fcbbbb] [&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcbbbb]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#E5F0FF]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#E5F0FF]",
      "hover:[&_.pagination-button]:bg-[#bdd3f2] [&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#bdd3f2]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFE6FF]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFE6FF]",
      "hover:[&_.pagination-button]:bg-[#edcced] [&_.pagination-button.active-pagination-button]:bg-[#edcced]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#edcced]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#FFECDA]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#FFECDA]",
      "hover:[&_.pagination-button]:bg-[#ffdfc1] [&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#ffdfc1]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "[&.grouped-pagination_.pagination-control]:bg-[#E3E7F1]",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#E3E7F1]",
      "hover:[&_.pagination-button]:bg-[#c8cee0] [&_.pagination-button.active-pagination-button]:bg-[#c8cee0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c8cee0]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-transparent hover:[&_.pagination-button]:bg-[#111111]",
      "[&.grouped-pagination_.pagination-control]:bg-[#1E1E1E] [&.grouped-pagination_.pagination-control]:text-white",
      "[&.grouped-pagination_.pagination-seperator]:bg-[#1E1E1E] [&.grouped-pagination_.pagination-seperator]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]"
    ]
  end

  defp color_variant("transparent", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-white [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#E8E8E8] [&_.pagination-button.active-pagination-button]:bg-[#484747] [&_.pagination-button.active-pagination-button]:text-[#E8E8E8]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#002cff]",
      "[&_.pagination-button.active-pagination-button]:text-[#002cff]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#020202]",
      "[&_.pagination-button.active-pagination-button]:text-[#020202]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#126c3a] [&_.pagination-button.active-pagination-button]:text-[#126c3a]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#9b6112]",
      "[&_.pagination-button.active-pagination-button]:text-[#9b6112]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#a52e23]",
      "[&_.pagination-button.active-pagination-button]:text-[#a52e23]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6663FD] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#132e50]",
      "[&_.pagination-button.active-pagination-button]:text-[#132e50]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#491d6a]",
      "[&_.pagination-button.active-pagination-button]:text-[#491d6a]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#28231d]",
      "[&_.pagination-button.active-pagination-button]:text-[#28231d]"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#42485a]",
      "[&_.pagination-button.active-pagination-button]:text-[#42485a]"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:text-[#787878]",
      "[&_.pagination-button.active-pagination-button]:text-[#787878]"
    ]
  end

  defp color_variant("subtle", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-white [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-white hover:[&_.pagination-button]:text-[#3E3E3E]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-white hover:[&.grouped-pagination_.pagination-control]::text-[#3E3E3E]",
      "[&_.pagination-button.active-pagination-button]:bg-white",
      "[&_.pagination-button.active-pagination-button]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("subtle", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#4363EC] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4363EC] hover:[&.grouped-pagination_.pagination-control]::text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#4363EC]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("subtle", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#6B6E7C] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#6B6E7C] hover:[&.grouped-pagination_.pagination-control]::text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("subtle", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#AFEAD0] hover:[&_.pagination-button]:text-[#227A52]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#AFEAD0] hover:[&.grouped-pagination_.pagination-control]::text-[#227A52]",
      "[&_.pagination-button.active-pagination-button]:bg-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:text-[#227A52]"
    ]
  end

  defp color_variant("subtle", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFF8E6] hover:[&_.pagination-button]:text-[#FFF8E6]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFF8E6] hover:[&.grouped-pagination_.pagination-control]::text-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#FF8B08]"
    ]
  end

  defp color_variant("subtle", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFE6E6] hover:[&_.pagination-button]:text-[#E73B3B]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFE6E6] hover:[&.grouped-pagination_.pagination-control]::text-[#E73B3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#E73B3B]"
    ]
  end

  defp color_variant("subtle", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6663FD] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#E5F0FF] hover:[&_.pagination-button]:text-[#103483]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E5F0FF] hover:[&.grouped-pagination_.pagination-control]::text-[#103483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#103483]"
    ]
  end

  defp color_variant("subtle", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFE6FF] hover:[&_.pagination-button]:text-[#52059C]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFE6FF] hover:[&.grouped-pagination_.pagination-control]::text-[#52059C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#52059C]"
    ]
  end

  defp color_variant("subtle", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#FFECDA] hover:[&_.pagination-button]:text-[#4D4137]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFECDA] hover:[&.grouped-pagination_.pagination-control]::text-[#4D4137]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:text-[#4D4137]"
    ]
  end

  defp color_variant("subtle", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#E3E7F1] hover:[&_.pagination-button]:text-[#707483]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E3E7F1] hover:[&.grouped-pagination_.pagination-control]::text-[#707483]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:text-[#707483]"
    ]
  end

  defp color_variant("subtle", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&:not(.grouped-pagination)_.pagination-button]:border-transparent",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#111111] hover:[&.grouped-pagination_.pagination-control]::text-white",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:text-white"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-white text-[#3E3E3E] [&:not(.grouped-pagination)_.pagination-button]:border-[#DADADA]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E8E8E8]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#d9d9d9]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#d9d9d9]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#4363EC] [&_.pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#4363EC] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#072ed3] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#072ed3]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#072ed3]",
      "[&_.pagination-button.active-pagination-button]:bg-[#072ed3]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#072ed3]"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#6B6E7C] [&_.pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#6B6E7C] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#4c4f59] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#4c4f59]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4c4f59]",
      "[&_.pagination-button.active-pagination-button]:bg-[#4c4f59]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#4c4f59]"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#AFEAD0] text-[#227A52] [&:not(.grouped-pagination)_.pagination-button]:border-[#AFEAD0]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#c0fad7]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#c0fad7]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c0fad7]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c0fad7]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#c0fad7]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFF8E6] text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-[#FFF8E6]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#fcebc0]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#fcebc0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcebc0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcebc0]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#fcebc0]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6E6] text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-[#FFE6E6]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#fcbbbb]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#fcbbbb]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#fcbbbb]",
      "[&_.pagination-button.active-pagination-button]:bg-[#fcbbbb]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#fcbbbb]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E5F0FF] text-[#004FC4] [&:not(.grouped-pagination)_.pagination-button]:border-[#E5F0FF]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#bdd3f2]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#bdd3f2]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#bdd3f2]",
      "[&_.pagination-button.active-pagination-button]:bg-[#bdd3f2]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#bdd3f2]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFE6FF] text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-[#FFE6FF]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#edcced]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#edcced]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#edcced]",
      "[&_.pagination-button.active-pagination-button]:bg-[#edcced]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#edcced]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#FFECDA] text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-[#FFECDA]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#ffdfc1]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#ffdfc1]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#ffdfc1]",
      "[&_.pagination-button.active-pagination-button]:bg-[#ffdfc1]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#ffdfc1]"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#E3E7F1] text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-[#E3E7F1]",
      "[&_.pagination-button]:shadow hover:[&_.pagination-button]:bg-[#c8cee0]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#c8cee0]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#c8cee0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#c8cee0]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#c8cee0]"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-[#1E1E1E] [&_.pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button]:border-[#1E1E1E] [&_.pagination-button]:shadow",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#050404]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:bg-[#050404]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#050404]"
    ]
  end

  defp color_variant("inverted", "white") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-white [&:not(.grouped-pagination)_.pagination-button]:border-white",
      "hover:[&_.pagination-button]:bg-white hover:[&_.pagination-button]:text-[#3E3E3E]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-white hover:[&.grouped-pagination_.pagination-control]:text-[#3E3E3E]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#DADADA] [&_.pagination-button.active-pagination-button]:bg-white",
      "[&_.pagination-button.active-pagination-button]:text-[#3E3E3E]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#DADADA]"
    ]
  end

  defp color_variant("inverted", "primary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4363EC] [&:not(.grouped-pagination)_.pagination-button]:border-[#4363EC]",
      "hover:[&_.pagination-button]:bg-[#4363EC] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#4363EC] hover:[&.grouped-pagination_.pagination-control]:text-white",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#4363EC] [&_.pagination-button.active-pagination-button]:bg-[#4363EC]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#4363EC]"
    ]
  end

  defp color_variant("inverted", "secondary") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#6B6E7C] [&:not(.grouped-pagination)_.pagination-button]:border-[#6B6E7C]",
      "hover:[&_.pagination-button]:bg-[#6B6E7C] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#6B6E7C] hover:[&.grouped-pagination_.pagination-control]:text-white",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#6B6E7C]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("inverted", "success") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#227A52] [&:not(.grouped-pagination)_.pagination-button]:border-[#227A52]",
      "hover:[&_.pagination-button]:bg-[#AFEAD0] hover:[&_.pagination-button]:text-[#227A52]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#AFEAD0] hover:[&.grouped-pagination_.pagination-control]:text-[#227A52]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:bg-[#AFEAD0]",
      "[&_.pagination-button.active-pagination-button]:text-[#227A52]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#AFEAD0]"
    ]
  end

  defp color_variant("inverted", "warning") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#FF8B08] [&:not(.grouped-pagination)_.pagination-button]:border-[#FF8B08]",
      "hover:[&_.pagination-button]:bg-[#FFF8E6] hover:[&_.pagination-button]:text-[#FF8B08]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFF8E6] hover:[&.grouped-pagination_.pagination-control]:text-[#FF8B08]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF8E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#FF8B08]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#FFF8E6]"
    ]
  end

  defp color_variant("inverted", "danger") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#E73B3B] [&:not(.grouped-pagination)_.pagination-button]:border-[#E73B3B]",
      "hover:[&_.pagination-button]:bg-[#FFE6E6] hover:[&_.pagination-button]:text-[#E73B3B]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFE6E6] hover:[&.grouped-pagination_.pagination-control]:text-[#E73B3B]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6E6]",
      "[&_.pagination-button.active-pagination-button]:text-[#E73B3B]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#FFE6E6]"
    ]
  end

  defp color_variant("inverted", "info") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#004FC4] [&:not(.grouped-pagination)_.pagination-button]:border-[#004FC4]",
      "hover:[&_.pagination-button]:bg-[#E5F0FF] hover:[&_.pagination-button]:text-[#103483]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E5F0FF] hover:[&.grouped-pagination_.pagination-control]:text-[#103483]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E5F0FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#103483]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#E5F0FF]"
    ]
  end

  defp color_variant("inverted", "misc") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#52059C] [&:not(.grouped-pagination)_.pagination-button]:border-[#52059C]",
      "hover:[&_.pagination-button]:bg-[#FFE6FF] hover:[&_.pagination-button]:text-[#52059C]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFE6FF] hover:[&.grouped-pagination_.pagination-control]:text-[#52059C]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFE6FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#52059C]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#FFE6FF]"
    ]
  end

  defp color_variant("inverted", "dawn") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#4D4137] [&:not(.grouped-pagination)_.pagination-button]:border-[#4D4137]",
      "hover:[&_.pagination-button]:bg-[#FFECDA] hover:[&_.pagination-button]:text-[#4D4137]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#FFECDA] hover:[&.grouped-pagination_.pagination-control]:text-[#4D4137]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFECDA]",
      "[&_.pagination-button.active-pagination-button]:text-[#4D4137]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#FFECDA]"
    ]
  end

  defp color_variant("inverted", "light") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#707483] [&:not(.grouped-pagination)_.pagination-button]:border-[#707483]",
      "hover:[&_.pagination-button]:bg-[#E3E7F1] hover:[&_.pagination-button]:text-[#707483]",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#E3E7F1] hover:[&.grouped-pagination_.pagination-control]:text-[#707483]",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E3E7F1]",
      "[&_.pagination-button.active-pagination-button]:text-[#707483]",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#E3E7F1]"
    ]
  end

  defp color_variant("inverted", "dark") do
    [
      "[&:not(.grouped-pagination)_.pagination-button]:border",
      "[&_.pagination-button]:bg-transparent text-[#1E1E1E] [&:not(.grouped-pagination)_.pagination-button]:border-[#1E1E1E]",
      "hover:[&_.pagination-button]:bg-[#111111] hover:[&_.pagination-button]:text-white",
      "hover:[&.grouped-pagination_.pagination-control]:bg-[#111111] hover:[&.grouped-pagination_.pagination-control]:text-white",
      "hover:[&:not(.grouped-pagination)_.pagination-button]:border-[#111111]",
      "[&_.pagination-button.active-pagination-button]:bg-[#111111]",
      "[&_.pagination-button.active-pagination-button]:text-white",
      "[&:not(.grouped-pagination)_.pagination-button.active-pagination-button]:border-[#111111]"
    ]
  end

  defp default_classes() do
    [
      "w-fit flex [&.grouped-pagination>*]::flex-1 [&:not(.grouped-pagination)]:justify-start [&:not(.grouped-pagination)]:items-center [&:not(.grouped-pagination)]:flex-wrap  [&_.pagination-button.active-pagination-button]:font-medium [&.grouped-pagination]:overflow-hidden"
    ]
  end

  defp show_pagination?(nil, _total), do: true
  defp show_pagination?(true, total) when total <= 1, do: false
  defp show_pagination?(_, total) when total > 1, do: true
  defp show_pagination?(_, _), do: false
end
