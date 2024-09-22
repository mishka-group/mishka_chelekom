defmodule MishkaChelekom.Breadcrumb do
  @moduledoc """
  Provides a flexible and customizable `MishkaChelekom.Breadcrumb` component for displaying
  breadcrumb navigation in your Phoenix LiveView applications.

  ## Features

  - **Customizable Appearance**: Choose from various color themes and sizes to match your design needs.
  - **Icon and Separator Support**: Easily add icons and separators between breadcrumb items
  for improved navigation.
  - **Flexible Structure**: Use slots to define breadcrumb items, each with optional icons,
  links, and custom separators.
  - **Global Attributes**: Utilize global attributes to customize and extend the component's
  behavior and appearance.

  ## Available Attributes

  ### Breadcrumb

  The main component for rendering a breadcrumb navigation.

  #### Attributes

  - `class`: Custom CSS class for additional styling.
  - `id`: Unique identifier for the breadcrumb component.
  - `separator`: Determines the default separator between breadcrumb items.
  Can be customized at the item level.
  - `color`: Specifies the color theme for the breadcrumb.
  - `size`: Sets the overall size, including padding, font size, and other elements.

  ### Item Slot

  Defines individual breadcrumb items within the breadcrumb component.

  #### Attributes

  - `icon`: Icon displayed alongside the breadcrumb item.
  - `link`: Specifies the navigation link for the item. Can be a path, live patch, or standard link.
  - `separator`: Custom separator for this specific item, overriding the default separator.
  - `class`: Custom CSS class for additional styling.

  ### Inner Block Slot

  Allows for the inclusion of additional custom HEEx content within the breadcrumb component.

  ## Example Usage

  ```elixir
  ...example
  ```

  This will render a breadcrumb navigation with the items "Home", "Products", and "Electronics",
  where "Home" and "Products" are clickable links.
  """
  use Phoenix.Component
  import MishkaChelekomComponents

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
    "dawn"
  ]

  @doc """
  The `breadcrumb` component is used to display a navigational path with customizable
  attributes such as `color`, `size`, and `separator`.

  It supports defining individual items with optional icons and links, allowing for flexible
  breadcrumb trails.

  ## Examples

  ```elixir
  <.breadcrumb>
    <:item icon="hero-academic-cap" link="/">Route1</:item>
    <:item icon="hero-beaker" link="/">Route2</:item>
    <:item icon="hero-computer-desktop" link="/">Route3</:item>
    <:item>Route3</:item>
  </.breadcrumb>

  <.breadcrumb color="info" size="medium">
    <:item icon="hero-academic-cap">Route1</:item>
    <:item icon="hero-beaker">Route2</:item>
    <:item icon="hero-computer-desktop">Route3</:item>
    <:item>Route3</:item>
  </.breadcrumb>

  <.breadcrumb color="secondary" size="small">
    <:item link="/">Route1</:item>
    <:item link="/">Route2</:item>
    <:item link="/">Route3</:item>
    <:item link="/">Route3</:item>
  </.breadcrumb>
  ```
  """
  @doc type: :component
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :separator, :string,
    default: "hero-chevron-right",
    doc: "Determines a separator for items of an element"

  attr :color, :string, values: @colors, default: "dark", doc: "Determines color theme"

  attr :size, :string,
    values: @sizes,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  slot :item, required: false, doc: "Specifies item slot of a breadcrumb" do
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :link, :string, doc: "Renders a navigation, patch link or normal link"
    attr :separator, :string, doc: "Determines a separator for items of an element"
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def breadcrumb(assigns) do
    ~H"""
    <ul
      id={@id}
      class={
        default_classes() ++
          [
            color_class(@color),
            size_class(@size),
            @class
          ]
      }
      {@rest}
    >
      <li
        :for={{item, index} <- Enum.with_index(@item, 1)}
        class={["flex items-center", item[:class]]}
      >
        <.icon :if={!is_nil(item[:icon])} name={item[:icon]} class="breadcrumb-icon" />
        <div :if={!is_nil(item[:link])}>
          <.link navigate={item[:link]}><%= render_slot(item) %></.link>
        </div>

        <div :if={is_nil(item[:link])}><%= render_slot(item) %></div>
        <.separator :if={index != length(@item)} name={item[:separator] || @separator} />
      </li>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  @doc type: :component
  attr :name, :string, doc: "Specifies the name of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

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

  defp color_class("white") do
    "text-white hover:[&>li_a]:text-[#ededed]"
  end

  defp color_class("primary") do
    "text-[#4363EC] hover:[&>li_a]:text-[#072ed3]"
  end

  defp color_class("secondary") do
    "text-[#6B6E7C] hover:[&>li_a]:text-[#60636f]"
  end

  defp color_class("success") do
    "text-[#047857] hover:[&>li_a]:text-[#d4fde4] "
  end

  defp color_class("warning") do
    "text-[#FF8B08] hover:[&>li_a]:text-[#fff1cd]"
  end

  defp color_class("danger") do
    "text-[#E73B3B] hover:[&>li_a]:text-[#ffcdcd]"
  end

  defp color_class("info") do
    "text-[#004FC4] hover:[&>li_a]:text-[#cce1ff]"
  end

  defp color_class("misc") do
    "text-[#52059C] hover:[&>li_a]:text-[#ffe0ff]"
  end

  defp color_class("dawn") do
    "text-[#4D4137] hover:[&>li_a]:text-[#FFECDA]"
  end

  defp color_class("light") do
    "text-[#707483] hover:[&>li_a]:text-[#d2d8e9]"
  end

  defp color_class("dark") do
    "text-[#1E1E1E] hover:[&>li_a]:text-[#869093]"
  end

  defp size_class("extra_small"),
    do:
      "text-xs gap-1.5 [&>li]:gap-1.5 [&>li>.separator-icon]:size-3 [&>li>.breadcrumb-icon]:size-4"

  defp size_class("small"),
    do:
      "text-sm gap-2 [&>li]:gap-2 [&>li>.separator-icon]:size-3.5 [&>li>.breadcrumb-icon]:size-5"

  defp size_class("medium"),
    do:
      "text-base gap-2.5 [&>li]:gap-2.5 [&>li>.separator-icon]:size-4 [&>li>.breadcrumb-icon]:size-6"

  defp size_class("large"),
    do: "text-lg gap-3 [&>li]:gap-3 [&>li>.separator-icon]:size-5 [&>li>.breadcrumb-icon]:size-7"

  defp size_class("extra_large"),
    do:
      "text-xl gap-3.5 [&>li]:gap-3.5 [&>li>.separator-icon]:size-6 [&>li>.breadcrumb-icon]:size-8"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp default_classes() do
    [
      "flex items-center transition-all ease-in-ou duration-100 group"
    ]
  end
end
