defmodule MishkaChelekom.Navbar do
  @moduledoc """
  The `MishkaChelekom.Navbar` module provides a flexible and customizable navigation
  bar component for Phoenix LiveView applications. It allows for a variety of styles,
  colors, and configurations to fit different design needs, including border styles,
  content alignment, and text positioning.

  This component supports nested elements through slots, enabling complex navigation structures.

  It also offers extensive theming options, such as rounded corners, shadow effects,
  and maximum width settings.

  With built-in support for icons and images, the `Navbar` module makes it easy to create
  visually appealing and interactive navigation bars that enhance the user experience.
  """
  use Phoenix.Component
  import MishkaChelekomComponents

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
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc """
  Renders a customizable navigation bar (`navbar` component) that can include links,
  dropdowns, and other components.

  The navigation bar is designed to handle various styles, colors, and layouts.

  ## Examples

  ```elixir
  <.navbar id="nav-11" color="success" variant="shadow">
    <:list><.link navigate="/">Home</.link></:list>
    <:list><.link navigate="/examples/sidebar">List</.link></:list>

    <:list>
      <.dropdown relative="md:relative" width="w-full" clickable>
        <.dropdown_trigger width="full" trigger_id="test-31">
          <button class="text-start w-full block">Dropdown</button>
        </.dropdown_trigger>

        <.dropdown_content space="small" id="test-31" rounded="large" width="large" padding="extra_small">
          <ul class="space-y-5">
            <li>
              <.dropdown width="w-full" position="right" clickable>
                <.dropdown_trigger trigger_id="test-19">
                  <button class={[
                    "py-1 px-2 text-start w-full flex items-center justify-between hover:bg-gray-200"
                  ]}
                  >
                    Nested Dropdown <.icon name="hero-chevron-right" />
                  </button>
                </.dropdown_trigger>

                <.dropdown_content id="test-19" rounded="large" width="large" padding="extra_small">
                  <ul class="space-y-5">
                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/list">
                        Security
                      </.link>
                    </li>

                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/dropdown">
                        Memory
                      </.link>
                    </li>

                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/image">
                        Design
                      </.link>
                    </li>
                  </ul>
                </.dropdown_content>
              </.dropdown>
            </li>

            <li>
              <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/dropdown">
                Memory
              </.link>
            </li>

            <li>
              <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/image">
                Design
              </.link>
            </li>
          </ul>
        </.dropdown_content>
      </.dropdown>
    </:list>

    <:list><.link navigate="/examples/rating">Blog</.link></:list>
    <:list><.link navigate="/examples/sidebar">Calendar</.link></:list>
    <:list><.link navigate="/examples/rating">Booking</.link></:list>
    <:list><.link navigate="/examples/sidebar">Partners</.link></:list>
    <:list><.link navigate="/examples/rating">About</.link></:list>
  </.navbar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :text_position, :string, default: nil, doc: "Determines the element' text position"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"
  attr :max_width, :string, default: nil, doc: "Determines the style of element max width"

  attr :content_position, :string,
    default: "between",
    doc: "Determines the alignment of the element's content"

  attr :image, :string, default: nil, doc: "Image displayed alongside of an item"
  attr :image_class, :string, default: nil, doc: "Determines custom class for the image"
  attr :name, :string, default: nil, doc: "Specifies the name of the element"
  attr :relative, :boolean, default: false, doc: ""
  attr :link, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :list, required: true do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :padding, :string, doc: "Determines padding for items"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :icon_position, :string, doc: "Determines icon position"
  end

  def navbar(assigns) do
    ~H"""
    <nav
      id={@id}
      class={[
        "relative",
        "[&.show-nav-menu_.nav-menu]:block [&.show-nav-menu_.nav-menu]:opacity-100",
        border_class(@border),
        content_position(@content_position),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        padding_size(@padding),
        text_position(@text_position),
        maximum_width(@max_width),
        space_class(@space),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class="nav-wrapper md:flex items-center gap-2 gap-5">
        <.link
          :if={!is_nil(@link)}
          navigate={@link}
          class="flex items-center space-x-3 rtl:space-x-reverse mb-5 md:mb-0"
        >
          <img :if={!is_nil(@image)} src={@image} class={@image_class} />
          <h1 class="text-xl font-semibold">
            <%= @name %>
          </h1>
        </.link>

        <div class={[
          "w-auto"
        ]}>
          <ul class={[
            "flex flex-wrap md:flex-nowrap gap-4",
            @relative && "relative"
          ]}>
            <li
              :for={list <- @list}
              class={[
                "inline-flex",
                list[:icon_position] == "end" && "flex-row-reverse",
                list[:class]
              ]}
            >
              <.icon :if={list[:icon]} name={list[:icon]} class="list-icon" />
              <%= render_slot(list) %>
            </li>
          </ul>
        </div>
        <%= render_slot(@inner_block) %>
      </div>
    </nav>
    """
  end

  defp content_position("start") do
    "[&_.nav-wrapper]:justify-start"
  end

  defp content_position("end") do
    "[&_.nav-wrapper]:justify-end"
  end

  defp content_position("center") do
    "[&_.nav-wrapper]:justify-center"
  end

  defp content_position("between") do
    "[&_.nav-wrapper]:justify-between"
  end

  defp content_position("around") do
    "[&_.nav-wrapper]:justify-around"
  end

  defp content_position(_), do: content_position("between")

  defp text_position("left"), do: "text-left"
  defp text_position("right"), do: "text-right"
  defp text_position("center"), do: "text-center"
  defp text_position(_), do: nil

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"

  defp maximum_width("extra_small"), do: "[&_.nav-wrapper]:max-w-3xl	[&_.nav-wrapper]:mx-auto"
  defp maximum_width("small"), do: "[&_.nav-wrapper]:max-w-4xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("medium"), do: "[&_.nav-wrapper]:max-w-5xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("large"), do: "[&_.nav-wrapper]:max-w-6xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("extra_large"), do: "[&_.nav-wrapper]:max-w-7xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width(params) when is_binary(params), do: params
  defp maximum_width(_), do: nil

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("none")

  defp border_class("none"), do: "border-b-0"
  defp border_class("extra_small"), do: "border-b"
  defp border_class("small"), do: "border-b-2"
  defp border_class("medium"), do: "border-b-[3px]"
  defp border_class("large"), do: "border-b-4"
  defp border_class("extra_large"), do: "border-b-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp rounded_size("extra_small"), do: "rounded-t-sm"
  defp rounded_size("small"), do: "rounded-t"
  defp rounded_size("medium"), do: "rounded-t-md"
  defp rounded_size("large"), do: "rounded-t-lg"
  defp rounded_size("extra_large"), do: "rounded-t-xl"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: "rounded-t-none"

  defp color_variant("default", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA]",
      "[&_.navbar-button]:bg-white [&_.navbar-button]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border-[#2441de]",
      "[&_.navbar-button]:bg-[#4363EC] [&_.navbar-button]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#877C7C]",
      "[&_.navbar-button]:bg-[#6B6E7C] [&_.navbar-button]:border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]",
      "[&_.navbar-button]:bg-[#ECFEF3] [&_.navbar-button]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]",
      "[&_.navbar-button]:bg-[#FFF8E6] [&_.navbar-button]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]",
      "[&_.navbar-button]:bg-[#FFE6E6] [&_.navbar-button]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]",
      "[&_.navbar-button]:bg-[#E5F0FF] [&_.navbar-button]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#52059C]",
      "[&_.navbar-button]:bg-[#FFE6FF] [&_.navbar-button]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]",
      "[&_.navbar-button]:bg-[#FFECDA] [&_.navbar-button]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#707483]",
      "[&_.navbar-button]:bg-[#E3E7F1] [&_.navbar-button]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#050404]",
      "[&_.navbar-button]:bg-[#1E1E1E] [&_.navbar-button]:border-[#050404]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "bg-white text-[#3E3E3E] border-transparent",
      "[&_.navbar-button]:bg-white [&_.navbar-button]:border-[#DADADA]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "bg-[#4363EC] text-white border-transparent",
      "[&_.navbar-button]:bg-[#4363EC] [&_.navbar-button]:border-[#2441de]"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-transparent",
      "[&_.navbar-button]:bg-[#6B6E7C] [&_.navbar-button]:border-[#877C7C]"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-transparent",
      "[&_.navbar-button]:bg-[#ECFEF3] [&_.navbar-button]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-transparent",
      "[&_.navbar-button]:bg-[#FFF8E6] [&_.navbar-button]:border-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-transparent",
      "[&_.navbar-button]:bg-[#FFE6E6] [&_.navbar-button]:border-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-transparent",
      "[&_.navbar-button]:bg-[#E5F0FF] [&_.navbar-button]:border-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-transparent",
      "[&_.navbar-button]:bg-[#FFE6FF] [&_.navbar-button]:border-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-transparent",
      "[&_.navbar-button]:bg-[#FFECDA] [&_.navbar-button]:border-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-transparent",
      "[&_.navbar-button]:bg-[#E3E7F1] [&_.navbar-button]:border-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "bg-[#1E1E1E] text-white border-transparent",
      "[&_.navbar-button]:bg-[#1E1E1E] [&_.navbar-button]:border-[#050404]"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md",
      "[&_.navbar-button]:bg-white [&_.navbar-button]:border-[#DADADA]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#4363EC] text-white border-[#4363EC] shadow-md",
      "[&_.navbar-button]:bg-[#4363EC] [&_.navbar-button]:border-[#2441de]"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md",
      "[&_.navbar-button]:bg-[#6B6E7C] [&_.navbar-button]:border-[#877C7C]"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md",
      "[&_.navbar-button]:bg-[#ECFEF3] [&_.navbar-button]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md",
      "[&_.navbar-button]:bg-[#FFF8E6] [&_.navbar-button]:border-[#FF8B08]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md",
      "[&_.navbar-button]:bg-[#FFE6E6] [&_.navbar-button]:border-[#E73B3B]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md",
      "[&_.navbar-button]:bg-[#E5F0FF] [&_.navbar-button]:border-[#004FC4]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md",
      "[&_.navbar-button]:bg-[#FFE6FF] [&_.navbar-button]:border-[#52059C]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md",
      "[&_.navbar-button]:bg-[#FFECDA] [&_.navbar-button]:border-[#4D4137]"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md",
      "[&_.navbar-button]:bg-[#E3E7F1] [&_.navbar-button]:border-[#707483]"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md",
      "[&_.navbar-button]:bg-[#1E1E1E] [&_.navbar-button]:border-[#050404]"
    ]
  end
end
