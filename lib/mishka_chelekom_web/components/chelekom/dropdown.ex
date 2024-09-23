defmodule MishkaChelekom.Dropdown do
  @moduledoc """
  The `MishkaChelekom.Dropdown` module provides a customizable dropdown component
  built using Phoenix LiveView. It allows you to create dropdown menus with different styles,
  positions, and behaviors, supporting various customization options through attributes and slots.

  This module facilitates creating and managing dropdown components in a
  Phoenix LiveView application with flexible customization options.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

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
    "dawn"
  ]

  @variants [
    "default",
    "shadow"
  ]

  @doc """
  A `dropdown` component that displays a list of options or content when triggered.
  It can be activated by a click or hover, and positioned in various directions relative to its parent.

  ## Examples

  ```elixir
  <.dropdown relative="relative" position="right">
    <.dropdown_trigger>
      <.button color="primary" icon="hero-chevron-down" right_icon>
        Dropdown Right
      </.button>
    </.dropdown_trigger>

    <.dropdown_content space="small" rounded="large" width="full" padding="extra_small">
      <.list size="small">
        <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
        <:item padding="extra_small" icon="hero-camera">Settings</:item>
        <:item padding="extra_small" icon="hero-camera">Earning</:item>
        <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
      </.list>
    </.dropdown_content>
  </.dropdown>

  <.dropdown relative="relative" clickable>
    <.dropdown_trigger trigger_id="test-1">
      <.button color="primary" icon="hero-chevron-down" right_icon>
        Dropdown Button
      </.button>
    </.dropdown_trigger>

    <.dropdown_content id="test-1" space="small" rounded="large" width="full" padding="extra_small">
      <.list size="small">
        <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
        <:item padding="extra_small" icon="hero-camera">Settings</:item>
        <:item padding="extra_small" icon="hero-camera">Earning</:item>
        <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
      </.list>
    </.dropdown_content>
  </.dropdown>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :width, :string, default: "w-fit", doc: "Determines the element width"
  attr :position, :string, default: "bottom", doc: "Determines the element position"
  attr :relative, :string, default: nil, doc: "Custom relative position for the dropdown"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :nomobile, :boolean,
    default: false,
    doc: "Controls whether the dropdown is disabled on mobile devices"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def dropdown(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "[&>.dropdown-content]:invisible [&>.dropdown-content]:opacity-0",
        "[&>.dropdown-content.show-dropdown]:visible [&>.dropdown-content.show-dropdown]:opacity-100",
        !@clickable && tirgger_dropdown(),
        !@nomobile && dropdown_position(@position),
        (!@nomobile && @position == "left") ||
          (@position == "right" && dropdown_mobile_position(@position)),
        @relative,
        @width,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Defines a trigger for the dropdown component. When the element is clicked,
  it toggles the visibility of the associated dropdown content.

  ## Examples

  ```elixir
  <.dropdown_trigger>
    <.button color="primary" icon="hero-chevron-down" right_icon>Dropdown Right</.button>
  </.dropdown_trigger>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :trigger_id, :string, default: nil, doc: "Identifies what is the triggered element id"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def dropdown_trigger(assigns) do
    ~H"""
    <div
      id={@id}
      phx-click={
        @trigger_id &&
          JS.toggle_class("show-dropdown",
            to: "##{@trigger_id}-dropdown-content",
            transition: "duration-100"
          )
      }
      class={["cursor-pointer dropdown-trigger", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Defines the content area of a dropdown component. The content appears when the dropdown trigger
  is activated and can be customized with various styles such as size, color, padding, and border.

  ## Examples

  ```elixir
  <.dropdown_content space="small" rounded="large" width="full" padding="extra_small">
    <.list size="small">
      <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
      <:item padding="extra_small" icon="hero-camera">Settings</:item>
      <:item padding="extra_small" icon="hero-camera">Earning</:item>
      <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
    </.list>
  </.dropdown_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "shadow", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"

  attr :size, :string,
    default: nil,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: nil, doc: "Space between items"
  attr :width, :string, default: "extra_large", doc: "Determines the element width"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "none", doc: "Determines padding for items"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  # TODO: Add max-height and scroll

  def dropdown_content(assigns) do
    ~H"""
    <div
      id={@id && "#{@id}-dropdown-content"}
      phx-click-away={
        @id &&
          JS.remove_class("show-dropdown", to: "##{@id}-dropdown-content", transition: "duration-300")
      }
      class={[
        "dropdown-content absolute z-20 transition-all ease-in-out delay-100 duratio-500 w-full",
        "invisible opacity-0",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size, @width),
        width_class(@width),
        border_class(@border),
        padding_size(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp tirgger_dropdown(),
    do: "[&>.dropdown-content]:hover:visible [&>.dropdown-content]:hover:opacity-100"

  defp dropdown_position("bottom") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_position("left") do
    [
      "[&>.dropdown-content]:right-full [&>.dropdown-content]:top-0",
      "[&>.dropdown-content]:-translate-x-[5%]"
    ]
  end

  defp dropdown_position("right") do
    [
      "[&>.dropdown-content]:left-full [&>.dropdown-content]:top-0",
      "[&>.dropdown-content]:translate-x-[5%]"
    ]
  end

  defp dropdown_position("top") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("top-left") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:right-0",
      "[&>.dropdown-content]:translate-x-0 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("top-right") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:left-0",
      "[&>.dropdown-content]:translate-x-0 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("bottom-left") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:right-0",
      "[&>.dropdown-content]:-translate-x-0 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_position("bottom-right") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-0",
      "[&>.dropdown-content]:-translate-x-0 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_mobile_position("left") do
    [
      "md:[&>.dropdown-content]:right-full md:[&>.dropdown-content]:top-0",
      "md:[&>.dropdown-content]:-translate-x-[5%]",
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_mobile_position("right") do
    [
      "md:[&>.dropdown-content]:left-full md:[&>.dropdown-content]:top-0",
      "md:[&>.dropdown-content]:translate-x-[5%]",
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp size_class("extra_small", "extra_small"), do: "text-xs max-w-60"
  defp size_class("small", "small"), do: "text-sm max-w-64"
  defp size_class("medium", "medium"), do: "text-base max-w-72"
  defp size_class("large", "large"), do: "text-lg max-w-80"
  defp size_class("extra_large", "extra_large"), do: "text-xl max-w-96"
  defp size_class(_, "full"), do: "max-w-full"
  defp size_class(params, _) when is_binary(params), do: params
  defp size_class(_, _), do: size_class("medium", "extra_large")

  defp padding_size("extra_small"), do: "p-2"
  defp padding_size("small"), do: "p-3"
  defp padding_size("medium"), do: "p-4"
  defp padding_size("large"), do: "p-5"
  defp padding_size("extra_large"), do: "p-6"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("extra_small")

  defp width_class("extra_small"), do: "min-w-48"
  defp width_class("small"), do: "min-w-52"
  defp width_class("medium"), do: "min-w-56"
  defp width_class("large"), do: "min-w-60"
  defp width_class("extra_large"), do: "min-w-64"
  defp width_class("double_large"), do: "min-w-72"
  defp width_class("triple_large"), do: "min-w-80"
  defp width_class("quadruple_large"), do: "min-w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("extra_large")

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow"
  end
end
