defmodule MishkaChelekom.Card do
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
  attr :border, :string, values: @sizes ++ [nil], default: "medium", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :space, :string, values: @sizes, default: "small", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :caption, required: false do
    attr :image, :string
    attr :image_class, :string
    attr :position, :string, values: ["right", "left", "center"]
  end

  def card(assigns) do
    ~H"""
    <div class={[
      space_class(@space),
      border_class(@border, border_position(@rest)),
      color_variant(@variant, @color),
      rounded_size(@rounded),
      padding_size(@padding),
      size_class(@size),
      @font_weight,
      @class
    ]}>
      <div class="border-b rounded-t-xl py-3 px-4 md:py-4 md:px-5">
        <div class="title mt-1 text-sm text-gray-500">
          Featured
        </div>
      </div>
      <div class="bg-gray-100 border-b border-gray-200 text-sm text-gray-800 p-4"></div>
      <div class="p-4 md:p-5">
        <h3 class="text-lg font-bold text-gray-800">
          Card title
        </h3>
        <p class="mt-2 text-gray-500 dark:text-neutral-400">
          With supporting text below as a natural lead-in to additional content.
        </p>
        <a
          class="mt-3 inline-flex items-center gap-x-1 text-sm font-semibold rounded-lg border border-transparent text-blue-600 decoration-2 hover:text-blue-700 hover:underline focus:underline focus:outline-none focus:text-blue-700 disabled:opacity-50 disabled:pointer-events-none"
          href="#"
        >
          Card link
          <svg
            class="shrink-0 size-4"
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="m9 18 6-6-6-6"></path>
          </svg>
        </a>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params

  defp border_class(_, "none") do
    ["border-0"]
  end

  defp border_class("extra_small", position) do
    [
      position == "left" && "border-s",
      position == "right" && "border-e",
      position == "full" && "border"
    ]
  end

  defp border_class("small", position) do
    [
      position == "left" && "border-s-2",
      position == "right" && "border-s-2",
      position == "full" && "border-2"
    ]
  end

  defp border_class("medium", position) do
    [
      position == "left" && "border-s-[3px]",
      position == "right" && "border-e-[3px]",
      position == "full" && "border-[3px]"
    ]
  end

  defp border_class("large", position) do
    [
      position == "left" && "border-s-4",
      position == "right" && "border-e-4",
      position == "full" && "border-4"
    ]
  end

  defp border_class("extra_large", position) do
    [
      position == "left" && "border-s-[5px]",
      position == "right" && "border-e-[5px]",
      position == "full" && "border-[5px]"
    ]
  end

  defp border_class(params, _) when is_binary(params), do: [params]
  defp border_class(nil, _), do: nil

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(nil), do: "rounded-none"

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp size_class("extra_small"), do: "text-xs [&>.quote-icon]:size-7"
  defp size_class("small"), do: "text-sm [&>.quote-icon]:size-8"
  defp size_class("medium"), do: "text-base [&>.quote-icon]:size-9"
  defp size_class("large"), do: "text-lg [&>.quote-icon]:size-10"
  defp size_class("extra_large"), do: "text-xl [&>.quote-icon]:size-12"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp caption_position("right") do
    "ltr:justify-end rtl:justify-start"
  end

  defp caption_position("left") do
    "ltr:justify-start rtl:justify-end"
  end

  defp caption_position("center") do
    "justify-center"
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
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
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md"
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

  defp border_position(%{hide_border: true}), do: "none"
  defp border_position(%{left_border: true}), do: "left"
  defp border_position(%{right_border: true}), do: "right"
  defp border_position(%{full_border: true}), do: "full"
  defp border_position(_), do: "left"
end
