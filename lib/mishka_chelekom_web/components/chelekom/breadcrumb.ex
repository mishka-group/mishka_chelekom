defmodule MishkaChelekom.Breadcrumb do
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

  @doc type: :component
  attr :class, :string, default: nil, doc: ""
  attr :id, :string, default: nil, doc: ""
  attr :separator, :string, default: "hero-chevron-right", doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""

  slot :item, required: false do
    attr :icon, :string
    attr :link, :string
    attr :separator, :string
    attr :class, :string
  end

  attr :rest, :global
  slot :inner_block, required: false, doc: ""

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
    "text-[#1E1E1E] hover:[&>li_a]:text-[#111111]"
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
