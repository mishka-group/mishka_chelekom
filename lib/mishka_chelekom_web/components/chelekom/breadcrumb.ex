defmodule MishkaChelekom.Breadcrumb do
  use Phoenix.Component

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
  attr :separator, :string, default: "chevron-right", doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :text, :string, values: @sizes, default: "small", doc: ""

  slot :item, required: true do
    attr :text, :string, required: true
    attr :icon, :string
    attr :link, :string
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
            text_class(@text),
            color_class(@color),
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  defp color_class("white") do
    "text-white"
  end

  defp color_class("primary") do
    "text-[#4363EC]"
  end

  defp color_class("secondary") do
    "text-[#6B6E7C]"
  end

  defp color_class("success") do
    "text-[#047857]"
  end

  defp color_class("warning") do
    "text-[#FF8B08]"
  end

  defp color_class("danger") do
    "text-[#E73B3B]"
  end

  defp color_class("info") do
    "text-[#004FC4]"
  end

  defp color_class("misc") do
    "text-[#52059C]"
  end

  defp color_class("dawn") do
    "text-[#4D4137]"
  end

  defp color_class("light") do
    "text-[#707483]"
  end

  defp color_class("dark") do
    "text-[#1E1E1E]"
  end

  defp text_class("extra_small"), do: "text-xs"
  defp text_class("small"), do: "text-sm"
  defp text_class("medium"), do: "text-base"
  defp text_class("large"), do: "text-large"
  defp text_class("extra_large"), do: "text-xl"
  defp text_class(params) when is_binary(params), do: params
  defp text_class(_), do: text_class("small")

  defp default_classes() do
    [
      "flex items-center"
    ]
  end
end
