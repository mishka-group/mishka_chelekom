defmodule MishkaChelekom.TableContent do
  @moduledoc """
  `MishkaChelekom.TableContent` is a component module designed to create flexible and dynamic
  content within a table. This module allows for a variety of customizations, including styles,
  colors, borders, padding, and animations. It is composed of several subcomponents such as
  `table_content/1`, `content_wrapper/1`, and `content_item/1`, each providing specific
  roles for content display and interaction.

  The `table_content/1` function creates a container with customizable styles and an optional title.
  `content_wrapper/1` and `content_item/1` allow further structuring of content, including icons,
  font weights, and active states, making it easy to build interactive and visually appealing
  layouts within tables. The module leverages slots to enable dynamic content rendering,
  offering high flexibility in the design of complex table layouts.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  The `table_content` component is used to display organized content with customizable styling
  options such as color, padding, and animation.

  It supports nested content items and wrappers for better content management and display.

  ## Examples

  ```elixir
  <.table_content color="primary" animated>
    <.content_item icon="hero-hashtag">
      <.link href="#prag">Content 1</.link>
    </.content_item>

    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 2</.link>
    </.content_item>

    <.content_item title="Wrapper Content">
      <.content_wrapper>
        <.content_item icon="hero-hashtag">
          <.link href="#home">Content 1</.link>
        </.content_item>

        <.content_item icon="hero-hashtag">
          <.link href="#home">Content 2</.link>
        </.content_item>

        <.content_item icon="hero-hashtag" active>
          <.link href="#home">Content 3</.link>
        </.content_item>
      </.content_wrapper>
    </.content_item>
  </.table_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :color, :string, default: "white", doc: "Determines color theme"
  attr :variant, :string, default: "default", doc: "Determines the style"
  attr :space, :string, default: nil, doc: "Space between items"
  attr :animated, :boolean, default: false, doc: "Determines whether element's icon has animation"
  attr :padding, :string, default: nil, doc: "Determines padding for items"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def table_content(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@animated && JS.add_class("scroll-smooth", to: "html")}
      class={[
        color_variant(@variant, @color),
        padding_size(@padding),
        rounded_size(@rounded),
        border_class(@border),
        space_size(@space),
        size_class(@size)
      ]}
      {@rest}
    >
      <h5 class="font-semibold text-sm leading-6"><%= @title %></h5>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `content_wrapper` component is used to wrap multiple content items, allowing for grouped
  and structured presentation of content. It provides options for custom styling and font
  weight, making it versatile for various use cases.

  ## Examples

  ```elixir
  <.content_wrapper>
    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 1</.link>
    </.content_item>

    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 2</.link>
    </.content_item>

    <.content_item icon="hero-hashtag" active>
      <.link href="#home">Content 3</.link>
    </.content_item>
  </.content_wrapper>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def content_wrapper(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "content-wrapper",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `content_item` component is used to represent a single content item with an optional
  icon and custom styling.

  It allows for active state management and supports various configurations such as font
  weight and additional CSS classes.

  ## Examples

  ```elixir
  <.content_item icon="hero-hashtag">
    <.link href="#prag">Content 1</.link>
  </.content_item>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"

  attr :font_weight, :string,
    default: "font-noraml",
    doc: "Determines custom class for the font weight"

  attr :active, :boolean,
    default: false,
    doc: "Indicates whether the element is currently active and visible"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def content_item(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "content-item",
        @active && "font-bold",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div :if={!is_nil(@title)}><%= @title %></div>
      <div class="flex items-center transition-all hover:font-bold hover:opacity-90">
        <.icon
          :if={!is_nil(@icon)}
          name={@icon}
          class={["content-icon me-2 inline-block", @icon_class]}
        />
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp size_class("extra_small") do
    [
      "text-xs [&_.content-item]:py-1 [&_.content-item]:px-1.5 [&_.content-icon]:size-2.5"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.content-item]:py-1.5 [&_.content-item]:px-2 [&_.content-icon]:size-3"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.content-item]:py-2 [&_.content-item]:px-2.5 [&_.content-icon]:size-3.5"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.content-item]:py-2.5 [&_.content-item]:px-3 [&_.content-icon]:size-4"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.content-item]:py-3 [&_.content-item]:px-3.5 [&_.content-icon]:size-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp space_size("extra_small"), do: "space-y-1"
  defp space_size("small"), do: "space-y-2"
  defp space_size("medium"), do: "space-y-3"
  defp space_size("large"), do: "space-y-4"
  defp space_size("extra_large"), do: "space-y-5"
  defp space_size(params) when is_binary(params), do: params
  defp space_size(_), do: nil

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp padding_size("extra_small"), do: "p-5"
  defp padding_size("small"), do: "p-6"
  defp padding_size("medium"), do: "p-7"
  defp padding_size("large"), do: "p-8"
  defp padding_size("extra_large"), do: "p-9"
  defp padding_size("double_large"), do: "p-10"
  defp padding_size("triple_large"), do: "p-12"
  defp padding_size("quadruple_large"), do: "p-16"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: nil

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("none")

  defp color_variant("default", "white") do
    [
      "bg-white border-[#DADADA] text-[#3E3E3E]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] border-[#227A52]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#1E1E1E]"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "text-[#DADADA] border border-[#DADADA]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#2441de] border border-[#2441de]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#877C7C] border border-[#877C7C]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#227A52] border border-[#227A52]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#FF8B08] border border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#E73B3B] border border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#004FC4] border border-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#52059C] border border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#4D4137] border border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "text-[#707483] border border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "text-[#1E1E1E] border border-[#1E1E1E]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "bg-white border-transparent text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "bg-[#4363EC] border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "bg-[#6B6E7C] border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "bg-[#ECFEF3] border-transparent text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "bg-[#FFF8E6] border-transparent text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "bg-[#FFE6E6] border-transparent text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "bg-[#E5F0FF] border-transparent text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "bg-[#FFE6FF] border-transparent text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "bg-[#FFECDA] border-transparent text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "bg-[#E3E7F1] border-transparent text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "bg-[#1E1E1E] border-transparent text-white"
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
