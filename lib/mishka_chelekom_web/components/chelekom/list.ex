defmodule MishkaChelekom.List do
  @moduledoc """
  The `MishkaChelekom.List` module provides a versatile and customizable list
  component for building both ordered and unordered lists, as well as a list
  group component for more structured content. This module is designed to cater to
  various styles and use cases, such as navigation menus, data presentations, or simple item listings.

  ### Features

  - **Styling Variants:** The component offers multiple variants like `default`,
  `filled`, `outline`, `seperated`, `tinted_split`, and `transparent` to meet diverse design requirements.
  - **Color Customization:** Choose from a variety of colors to style the list according to
  your application's theme.
  - **Flexible Layouts:** Control the size, spacing, and appearance of list items with extensive
  customization options.
  - **Nested Structure:** Easily nest lists and group items together with the list group
  component for more complex layouts.

  This module is ideal for creating well-structured and visually appealing lists in
  your Phoenix LiveView applications.
  """

  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "filled",
    "outline",
    "seperated",
    "tinted_split",
    "transparent"
  ]

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

  @doc """
  Renders a `list` component that supports both ordered and unordered lists with customizable styles,
  sizes, and colors.

  ## Examples

  ```elixir
  <.list font_weight="font-bold" color="light" size="small">
    <:item padding="small" count={1}>list count small</:item>
    <:item padding="small" count={2}>list count small</:item>
    <:item padding="small" count={3}>list count small</:item>
    <:item padding="small" count={23658}>list count small</:item>
  </.list>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "filled", doc: "Determines the style"
  attr :style, :string, default: "list-none", doc: ""
  slot :item, validate_attrs: false, doc: "Specifies item slot of a list"

  attr :rest, :global,
    include: ~w(ordered unordered),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def list(%{rest: %{ordered: true}} = assigns) do
    ~H"""
    <.ol {assigns}>
      <.li :for={item <- @item} {item}>
        <%= render_slot(item) %>
      </.li>
      <%= render_slot(@inner_block) %>
    </.ol>
    """
  end

  def list(assigns) do
    ~H"""
    <.ul {assigns}>
      <.li :for={item <- @item} {item}>
        <%= render_slot(item) %>
      </.li>
      <%= render_slot(@inner_block) %>
    </.ul>
    """
  end

  @doc """
  Renders a list item (`li`) component with optional count, icon, and custom styles.
  This component is versatile and can be used within a list to display content with specific alignment,
  padding, and style.

  ## Examples

  ```elixir
  <MishkaChelekom.List.li>LI 1</MishkaChelekom.List.li>

  <MishkaChelekom.List.li>L2</MishkaChelekom.List.li>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :list, default: nil, doc: "Custom CSS class for additional styling"
  attr :count, :integer, default: nil, doc: "Li counter"
  attr :count_separator, :string, default: ". ", doc: "Li counter separator"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :icon_class, :string,
    default: "list-item-icon",
    doc: "Determines custom class for the icon"

  attr :content_class, :string, default: nil, doc: "Determines custom class for the content"
  attr :padding, :string, default: "none", doc: "Determines padding for items"

  attr :position, :string,
    values: ["start", "end", "center"],
    default: "start",
    doc: "Determines the element position"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  @spec li(map()) :: Phoenix.LiveView.Rendered.t()
  def li(assigns) do
    ~H"""
    <li
      id={@id}
      class={[
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      <div class={[
        "flex items-center gap-2 w-full",
        content_position(@position)
      ]}>
        <.icon :if={!is_nil(@icon)} name={@icon} class={@icon_class} />
        <span :if={is_integer(@count)}><%= @count %><%= @count_separator %></span>
        <div class="w-full">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </li>
    """
  end

  @doc """
  Renders an unordered list (`ul`) component with customizable styles and attributes.
  You can define the appearance of the list using options for color, variant, size, width, and more.

  It supports a variety of styles including `list-disc` for bulleted lists.

  ## Examples

  ```elixir
  <.ul style="list-disc">
    <li>Default background ul list disc</li>
    <li>Default background ul list disc</li>
    <li>Default background ul list disc</li>
  </.ul>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "filled", doc: "Determines the style"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :style, :string, default: "list-none", doc: "Determines the element style"
  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def ul(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "ltr:[&.list-decimal]:pl-5 rtl:[&.list-decimal]:pr-5 ltr:[&.list-disc]:pl-5 rtl:[&.list-disc]:pr-5",
        color_variant(@variant, @color),
        size_class(@size),
        width_class(@width),
        list_space(@space),
        @style,
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  @doc """
  Renders an ordered list (`ol`) component with customizable styles and attributes.
  The list can be styled with different colors, variants, sizes, widths, and spacing to
  fit various design needs.

  ## Examples

  ```elixir
  <.ol style="list-decimal">
    <li>Ordered list item 1</li>
    <li>Ordered list item 2</li>
    <li>Ordered list item 3</li>
  </.ol>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "filled", doc: "Determines the style"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def ol(assigns) do
    ~H"""
    <ol
      id={@id}
      class={[
        "list-decimal ltr:[&.list-decimal]:pl-5 rtl:[&.list-decimal]:pr-5 ltr:[&.list-disc]:pl-5 rtl:[&.list-disc]:pr-5",
        color_variant(@variant, @color),
        size_class(@size),
        width_class(@width),
        list_space(@space),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ol>
    """
  end

  @doc """
  Renders a list group component with customizable styles, borders, and padding. It can be used to group list items with different variants, colors, and sizes.

  ## Examples

  ```elixir
  <.list_group variant="seperated" rounded="extra_small" color="dawn">
    <.li position="end" icon="hero-chat-bubble-left-ellipsis">HBase</.li>
    <.li>PSQL</.li>
    <.li>Sqlight</.li>
  </.list_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :space, :string, values: @sizes ++ [nil], default: "small", doc: "Space between items"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "small",
    doc: "Determines the border radius"

  attr :border, :string,
    values: @sizes ++ [nil],
    default: "extra_small",
    doc: "Determines border style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines padding for items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def list_group(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "overflow-hidden",
        rounded_size(@rounded),
        variant_space(@space, @variant),
        padding_size(@padding),
        width_class(@width),
        border_class(@border, @variant),
        size_class(@size),
        color_variant(@variant, @color),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position(_), do: content_position("start")

  defp border_class(_, variant) when variant in ["seperated", "tinted_split"], do: "border-0"
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class("none", _), do: "border-0"
  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: nil

  defp rounded_size("extra_small"),
    do: "[&:not(.list-items-gap)]:rounded-sm [&.list-items-gap>li]:rounded-sm"

  defp rounded_size("small"), do: "[&:not(.list-items-gap)]:rounded [&.list-items-gap>li]:rounded"

  defp rounded_size("medium"),
    do: "[&:not(.list-items-gap)]:rounded-md [&.list-items-gap>li]:rounded-md"

  defp rounded_size("large"),
    do: "[&:not(.list-items-gap)]:rounded-lg [&.list-items-gap>li]:rounded-lg"

  defp rounded_size("extra_large"),
    do: "[&:not(.list-items-gap)]:rounded-xl [&.list-items-gap>li]:rounded-xl"

  defp rounded_size("full"),
    do: "[&:not(.list-items-gap)]:rounded-full [&.list-items-gap>li]:rounded:full"

  defp rounded_size("none"),
    do: "[&:not(.list-items-gap)]:rounded-none [&.list-items-gap>li]:rounded-none"

  defp variant_space(_, variant) when variant not in ["seperated", "tinted_split"], do: nil
  defp variant_space("extra_small", _), do: "list-items-gap space-y-2"
  defp variant_space("small", _), do: "list-items-gap space-y-3"
  defp variant_space("medium", _), do: "list-items-gap space-y-4"
  defp variant_space("large", _), do: "list-items-gap space-y-5"
  defp variant_space("extra_large", _), do: "list-items-gap space-y-6"
  defp variant_space(params, _) when is_binary(params), do: params
  defp variant_space(_, _), do: nil

  defp list_space("extra_small"), do: "space-y-2"
  defp list_space("small"), do: "space-y-3"
  defp list_space("medium"), do: "space-y-4"
  defp list_space("large"), do: "space-y-5"
  defp list_space("extra_large"), do: "space-y-6"
  defp list_space(params) when is_binary(params), do: params
  defp list_space(_), do: nil

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp size_class("extra_small"), do: "text-xs [&_.list-item-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.list-item-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.list-item-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.list-item-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.list-item-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("none")

  defp color_variant("default", "white") do
    [
      "bg-white border border-[#DADADA] text-[#3E3E3E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border border-[#877C7C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "border border-[#DADADA]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("filled", "white") do
    [
      "bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
    [
      "bg-[#1E1E1E] text-white"
    ]
  end

  defp color_variant("tinted_split", "white") do
    [
      "[&>li]:bg-white text-[#3E3E3E]",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "primary") do
    [
      "[&>li]:bg-[#4363EC] text-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "secondary") do
    [
      "[&>li]:bg-[#6B6E7C] text-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "success") do
    [
      "[&>li]:bg-[#ECFEF3] text-[#047857]",
      "[&>li]:border [&>li]:border-[#227A52]"
    ]
  end

  defp color_variant("tinted_split", "warning") do
    [
      "[&>li]:bg-[#FFF8E6] text-[#FF8B08]",
      "[&>li]:border [&>li]:border-[#FF8B08]"
    ]
  end

  defp color_variant("tinted_split", "danger") do
    [
      "[&>li]:bg-[#FFE6E6] text-[#E73B3B]",
      "[&>li]:border [&>li]:border-[#E73B3B]"
    ]
  end

  defp color_variant("tinted_split", "info") do
    [
      "[&>li]:bg-[#E5F0FF] text-[#004FC4]",
      "[&>li]:border [&>li]:border-[#004FC4]"
    ]
  end

  defp color_variant("tinted_split", "misc") do
    [
      "[&>li]:bg-[#FFE6FF] text-[#52059C]",
      "[&>li]:border [&>li]:border-[#52059C]"
    ]
  end

  defp color_variant("tinted_split", "dawn") do
    [
      "[&>li]:bg-[#FFECDA] text-[#4D4137]",
      "[&>li]:border [&>li]:border-[#4D4137]"
    ]
  end

  defp color_variant("tinted_split", "light") do
    [
      "[&>li]:bg-[#E3E7F1] text-[#707483]",
      "[&>li]:border [&>li]:border-[#707483]"
    ]
  end

  defp color_variant("tinted_split", "dark") do
    [
      "[&>li]:bg-[#1E1E1E] text-white",
      "[&>li]:border [&>li]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("seperated", "white") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#DADADA]"
    ]
  end

  defp color_variant("seperated", "primary") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("seperated", "secondary") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("seperated", "success") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#227A52]"
    ]
  end

  defp color_variant("seperated", "warning") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#FF8B08]"
    ]
  end

  defp color_variant("seperated", "danger") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#E73B3B]"
    ]
  end

  defp color_variant("seperated", "info") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#004FC4]"
    ]
  end

  defp color_variant("seperated", "misc") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#52059C]"
    ]
  end

  defp color_variant("seperated", "dawn") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#4D4137]"
    ]
  end

  defp color_variant("seperated", "light") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#707483]"
    ]
  end

  defp color_variant("seperated", "dark") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", _) do
    [
      "bg-transplant"
    ]
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
