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

  @variants ["default", "gradient"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["horizontal", "vertical"], default: "horizontal", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def progress(assigns) do
    ~H"""
    <div
      class={[
        "bg-[#e9ecef] rounded-full",
        size_class(@size, @type),
      ]}
    >
      <div
        class={[
          "rounded-full w-full",
          color_variant(@variant, @color),
          @class
        ]}
      ></div>
    </div>
    """
  end

  defp size_class("extra_small", "horizontal"), do: "text-xs h-1.5 [&>*]:h-1.5"
  defp size_class("small", "horizontal"), do: "text-sm h-2 [&>*]:h-2"
  defp size_class("medium", "horizontal"), do: "text-base h-2.5 [&>*]:h-2.5"
  defp size_class("large", "horizontal"), do: "text-lg h-3 [&>*]:h-3"
  defp size_class("extra_large", "horizontal"), do: "text-xl h-4 [&>*]:h-4"

  defp size_class("extra_small", "vertical"), do: "text-xs w-1 h-[5rem]"
  defp size_class("small", "vertical"), do: "text-sm w-2 h-[6rem]"
  defp size_class("medium", "vertical"), do: "text-base w-3 h-[7rem]"
  defp size_class("large", "vertical"), do: "text-lg w-4 h-[8rem]"
  defp size_class("extra_large", "vertical"), do: "text-xl w-5 h-[9rem]"

  defp size_class(params,_) when is_binary(params), do: params
  defp size_class(_,_), do: size_class("small", "horizontal")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("default", "primary") do
    "bg-[#2441de] text-white"
  end

  defp color_variant("default", "secondary") do
    "bg-[#877C7C] text-white"
  end

  defp color_variant("default", "success") do
    "bg-[#6EE7B7] text-[#047857]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FF8B08] text-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#E73B3B] text-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#004FC4] text-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#52059C] text-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#4D4137] text-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#707483] text-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white"
  end

  defp color_variant("gradient", "white") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-white to-[#e9ecef] text-[#3E3E3E]"
  end

  defp color_variant("gradient", "primary") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#2441de] to-[#e9ecef] text-white"
  end

  defp color_variant("gradient", "secondary") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#877C7C] to-[#e9ecef] text-white"
  end

  defp color_variant("gradient", "success") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#6EE7B7] to-[#e9ecef] text-[#047857]"
  end

  defp color_variant("gradient", "warning") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#FF8B08] to-[#e9ecef] text-[#FF8B08]"
  end

  defp color_variant("gradient", "danger") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#E73B3B] to-[#e9ecef] text-[#E73B3B]"
  end

  defp color_variant("gradient", "info") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#004FC4] to-[#e9ecef] text-[#004FC4]"
  end

  defp color_variant("gradient", "misc") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#52059C] to-[#e9ecef] text-[#52059C]"
  end

  defp color_variant("gradient", "dawn") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#4D4137] to-[#e9ecef] text-[#4D4137]"
  end

  defp color_variant("gradient", "light") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#707483] to-[#e9ecef] text-[#707483]"
  end

  defp color_variant("gradient", "dark") do
    "ltr:bg-gradient-to-r rtl:bg-gradient-to-l from-[#1E1E1E] to-[#e9ecef text-white"
  end
end
