defmodule MishkaChelekom.Keyboard do
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
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :font_weight, :string, default: "font-semibold", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def keyboard(assigns) do
    ~H"""
    <kbd
      id={@id}
      class={[
        "px-2 py-1.5",
        color_variant(@variant, @color),
        size_class(@size),
        rounded_size(@rounded),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </kbd>
    """
  end

  defp size_class("extra_small"), do: "text-xs"
  defp size_class("small"), do: "text-sm"
  defp size_class("medium"), do: "text-base"
  defp size_class("large"), do: "text-lg"
  defp size_class("extra_large"), do: "text-xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border border-[#1E1E1E]"
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
    "bg-white text-[#3E3E3E] border border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border border-[#1E1E1E] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end
end
