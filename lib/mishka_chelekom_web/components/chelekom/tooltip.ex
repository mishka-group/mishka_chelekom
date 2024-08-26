defmodule MishkaChelekom.Tooltip do
  use Phoenix.Component

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
    "shadow"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :position, :string, default: "top", doc: ""
  attr :variant, :string, values: @variants, default: "shadow", doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :size, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :width, :string, default: "fit", doc: ""
  attr :padding, :string, default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :text_position, :string, default: "center", doc: ""
  attr :text, :string, default: "", doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def tooltip(assigns) do
    ~H"""
    <span class="relative w-fit group">
      <%= render_slot(@inner_block) %>
      <span
        role="tooltip"
        id={@id}
        class={[
          "absolute z-10 transition-all ease-in-out delay-100 duratio-500 w-full",
          "invisible opacity-0 group-hover:visible group-hover:opacity-100",
          space_class(@space),
          color_variant(@variant, @color),
          rounded_size(@rounded),
          size_class(@size),
          padding_size(@padding),
          position_class(@position),
          text_position(@text_position),
          width_class(@width),
          @font_weight,
          @class
        ]}
        {@rest}
      >
        <%= @text %>
        <span class={[
          "block absolute size-[8px] bg-inherit rotate-45 tooltip-arrow"
        ]}>
        </span>
      </span>
    </span>
    """
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp position_class("top") do
    [
      "bottom-full left-1/2 -translate-x-1/2 -translate-y-[4px]",
      "[&>.tooltip-arrow]:-bottom-[4px] [&>.tooltip-arrow]:-translate-x-1/2 [&>.tooltip-arrow]:left-1/2"
    ]
  end

  defp position_class("bottom") do
    [
      "top-full left-1/2 -translate-x-1/2 translate-y-[4px]",
      "[&>.tooltip-arrow]:-top-[4px] [&>.tooltip-arrow]:-translate-x-1/2 [&>.tooltip-arrow]:left-1/2"
    ]
  end

  defp position_class("left") do
    [
      "right-full top-1/2 -translate-y-1/2 -translate-x-[6px]",
      "[&>.tooltip-arrow]:-right-[4px] [&>.tooltip-arrow]:translate-y-1/2 [&>.tooltip-arrow]:top-1/3"
    ]
  end

  defp position_class("right") do
    [
      "left-full top-1/2 -translate-y-1/2 translate-x-[6px]",
      "[&>.tooltip-arrow]:-left-[4px] [&>.tooltip-arrow]:translate-y-1/2 [&>.tooltip-arrow]:top-1/3"
    ]
  end

  defp size_class("extra_small"), do: "text-xs max-w-40"
  defp size_class("small"), do: "text-sm max-w-44"
  defp size_class("medium"), do: "text-base max-w-48"
  defp size_class("large"), do: "text-lg max-w-28"
  defp size_class("extra_large"), do: "text-xl max-w-32"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp text_position("left"), do: "text-left"
  defp text_position("right"), do: "text-right"
  defp text_position("center"), do: "text-center"
  defp text_position("justify"), do: "text-justify"
  defp text_position("start"), do: "text-start"
  defp text_position("end"), do: "text-end"
  defp text_position(_), do: text_position("center")

  defp width_class("extra_small"), do: "min-w-28"
  defp width_class("small"), do: "min-w-32"
  defp width_class("medium"), do: "min-w-36"
  defp width_class("large"), do: "min-w-40"
  defp width_class("extra_large"), do: "min-w-44"
  defp width_class("double_large"), do: "min-w-48"
  defp width_class("triple_large"), do: "min-w-52"
  defp width_class("quadruple_large"), do: "min-w-56"
  defp width_class("fit"), do: "min-w-fit"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("fit")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white shadow-md"
  end
end
