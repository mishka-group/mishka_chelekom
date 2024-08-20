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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def progress(assigns) do
    ~H"""
    <div
      class={[
        "w-full bg-gray-100 rounded-full",
        size_class(@size),
        @class
      ]}
    >
      <div
        class={[
          "rounded-full w-10",
          color_class(@color),
        ]}
      ></div>
    </div>
    """
  end

  defp size_class("extra_small"), do: "text-xs h-1.5 [&>*]:h-1.5"
  defp size_class("small"), do: "text-sm h-2 [&>*]:h-2"
  defp size_class("medium"), do: "text-base h-2.5 [&>*]:h-2.5"
  defp size_class("large"), do: "text-lg h-3 [&>*]:h-3"
  defp size_class("extra_large"), do: "text-xl h-4 [&>*]:h-4"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp color_class("white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_class("primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_class("secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_class("success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_class("warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_class("danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_class("info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_class("misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_class("dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_class("light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_class("dark") do
    "bg-[#1E1E1E] text-white"
  end
end
