defmodule MishkaChelekom.Progress do
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

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def progress(assigns) do
    ~H"""
    <div class={[
      "w-full bg-gray-200 rounded-full",
      color_variant(@color),
      size_class(@size),
      @class
    ]}>
      <div class="bg-blue-600 h-2.5 rounded-full" style="width: 45%"></div>
    </div>
    """
  end

  defp size_class("extra_small"), do: "text-xs"
  defp size_class("small"), do: "text-sm"
  defp size_class("medium"), do: "text-base"
  defp size_class("large"), do: "text-lg"
  defp size_class("extra_large"), do: "text-xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp color_variant("white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_variant("secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_variant("success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_variant("warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_variant("danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_variant("info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_variant("misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_variant("dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_variant("light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_variant("dark") do
    "bg-[#1E1E1E] text-white"
  end
end
