defmodule MishkaChelekom.Breadcrumb do
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :separator, :string, default: "chevron-right", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :space, :string, default: "extra_small", doc: ""

  slot :item, required: true do
    attr :text, :string, required: true
    attr :icon, :string
    attr :link, :string
  end

  attr :rest, :global
  slot :inner_block, required: false, doc: ""

  def breadcrumb(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            space_class(@space),
            @class
          ]
      }
      {@rest}
    >
      <button class="inline-flex items-center justify-center bg-[#4363EC] text-white border border-[#4363EC] w-8 h-8 rounded hover:bg-[#4363EC] hover:text-white">
        1
      </button>

      <button class="inline-flex items-center justify-center bg-white text-[#1E1E1E] border border-[#EDEDED] w-8 h-8 rounded hover:bg-[#4363EC] hover:text-white">
        2
      </button>

      <button class="inline-flex items-center justify-center bg-white text-[#1E1E1E] border border-[#EDEDED] w-8 h-8 rounded hover:bg-[#4363EC] hover:text-white">
        3
      </button>

      <div>...</div>

      <button class="inline-flex items-center justify-center bg-white text-[#1E1E1E] border border-[#EDEDED] w-8 h-8 rounded hover:bg-[#4363EC] hover:text-white">
        4
      </button>

      <button class="inline-flex items-center justify-center bg-white text-[#1E1E1E] border border-[#EDEDED] w-8 h-8 rounded hover:bg-[#4363EC] hover:text-white">
        5
      </button>
    </div>
    """
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] hover:bg-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] hover:bg-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] hover:bg-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] hover:bg-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] hover:bg-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] hover:bg-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] hover:bg-[#ffdfc1] hover:border-[#ffdfc1]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] hover:bg-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] hover:bg-[#111111] hover:border-[#111111]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white hover:text-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] hover:text-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:text-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7] hover:text-[#d4fde4] hover:border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] hover:text-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B] hover:text-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] hover:text-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] hover:text-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] hover:text-[#FFECDA] hover:border-[#FFECDA]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483] hover:text-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:text-[#111111] hover:border-[#111111]"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent hover:text-[#ededed]"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent hover:text-[#072ed3]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent hover:text-[#60636f]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent hover:text-[#d4fde4]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent hover:text-[#fff1cd]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent hover:text-[#ffcdcd]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent hover:text-[#cce1ff]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent hover:text-[#ffe0ff]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent hover:text-[#FFECDA]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent hover:text-[#d2d8e9]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent hover:text-[#111111]"
  end

  defp color_variant("subtle", "white") do
    "bg-transparent text-white border-transparent hover:bg-white hover:text-[#3E3E3E]"
  end

  defp color_variant("subtle", "primary") do
    "bg-transparent text-[#4363EC] border-transparent hover:bg-[#4363EC] hover:text-white"
  end

  defp color_variant("subtle", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent hover:bg-[#6B6E7C] hover:text-white"
  end

  defp color_variant("subtle", "success") do
    "bg-transparent text-[#227A52] border-transparent hover:bg-[#AFEAD0] hover:text-[#227A52]"
  end

  defp color_variant("subtle", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent hover:bg-[#FFF8E6] hover:text-[#FF8B08]"
  end

  defp color_variant("subtle", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent hover:bg-[#FFE6E6] hover:text-[#E73B3B]"
  end

  defp color_variant("subtle", "info") do
    "bg-transparent text-[#6663FD] border-transparent hover:bg-[#6663FD] hover:text-[#103483]"
  end

  defp color_variant("subtle", "misc") do
    "bg-transparent text-[#52059C] border-transparent hover:bg-[#FFE6FF] hover:text-[#52059C]"
  end

  defp color_variant("subtle", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent hover:bg-[#FFECDA] hover:text-[#4D4137]"
  end

  defp color_variant("subtle", "light") do
    "bg-transparent text-[#707483] border-transparent hover:bg-[#E3E7F1] hover:text-[#707483]"
  end

  defp color_variant("subtle", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent hover:bg-[#111111] hover:text-white"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md hover:bg-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#6EE7B7] shadow-md hover:bg-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md hover:bg-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md hover:bg-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md hover:bg-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md hover:bg-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md hover:bg-[#ffdfc1] hover:border-[#ffdfc1]"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md hover:bg-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md hover:bg-[#111111] hover:border-[#111111]"
  end

  defp color_variant("inverted", "white") do
    "bg-transparent text-white border-white hover:bg-white hover:text-[#3E3E3E] hover:border-[#DADADA]"
  end

  defp color_variant("inverted", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] hover:bg-[#4363EC] hover:text-white hover:border-[#4363EC]"
  end

  defp color_variant("inverted", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:bg-[#6B6E7C] hover:text-white hover:border-[#6B6E7C]"
  end

  defp color_variant("inverted", "success") do
    "bg-transparent text-[#227A52] border-[#227A52] hover:bg-[#AFEAD0] hover:text-[#227A52] hover:border-[#AFEAD0]"
  end

  defp color_variant("inverted", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] hover:bg-[#FFF8E6] hover:text-[#FF8B08] hover:border-[#FFF8E6]"
  end

  defp color_variant("inverted", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]  hover:bg-[#FFE6E6] hover:text-[#E73B3B] hover:border-[#FFE6E6]"
  end

  defp color_variant("inverted", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] hover:bg-[#E5F0FF] hover:text-[#103483] hover:border-[#E5F0FF]"
  end

  defp color_variant("inverted", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] hover:bg-[#FFE6FF] hover:text-[#52059C] hover:border-[#FFE6FF]"
  end

  defp color_variant("inverted", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] hover:bg-[#FFECDA] hover:text-[#4D4137] hover:border-[#FFECDA]"
  end

  defp color_variant("inverted", "light") do
    "bg-transparent text-[#707483] border-[#707483] hover:bg-[#E3E7F1] hover:text-[#707483] hover:border-[#E3E7F1]"
  end

  defp color_variant("inverted", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:bg-[#111111] hover:text-white hover:border-[#111111]"
  end

  defp color_variant("default_gradient", "primary") do
    "text-white bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "secondary") do
    "text-white bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "success") do
    "text-gray-900 bg-gradient-to-r from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "warning") do
    "text-gray-900 bg-gradient-to-r from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "danger") do
    "text-white bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "info") do
    "text-white bg-gradient-to-r from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "primary") do
    "relative overflow-hidden bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "secondary") do
    "relative overflow-hidden bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "success") do
    "relative overflow-hidden text-gray-900 bg-gradient-to-br from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "warning") do
    "relative overflow-hidden text-gray-900 bg-gradient-to-br from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "danger") do
    "relative overflow-hidden bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "info") do
    "relative overflow-hidden bg-gradient-to-br from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "primary") do
    "relative overflow-hidden bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "secondary") do
    "relative overflow-hidden bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "success") do
    "relative overflow-hidden bg-gradient-to-r from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "warning") do
    "relative overflow-hidden bg-gradient-to-r from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "danger") do
    "relative overflow-hidden bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "info") do
    "relative overflow-hidden bg-gradient-to-r from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent hover:bg-[#ededed]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent hover:bg-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent hover:bg-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent hover:bg-[#d4fde4]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent hover:bg-[#fff1cd]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent hover:bg-[#ffcdcd]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent hover:bg-[#cce1ff]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent hover:bg-[#ffe0ff]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent hover:bg-[#ffdfc1]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent hover:bg-[#d2d8e9]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent hover:bg-[#111111]"
  end

  defp color_variant(_, _), do: color_variant("default", "white")

  defp border("white") do
    "border-[#DADADA] hover:border-[#d9d9d9]"
  end

  defp border("transparent") do
    "border-transparent"
  end

  defp border("primary") do
    "border-[#4363EC] hover:border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] hover:border-[#60636f]"
  end

  defp border("success") do
    "border-[#227A52] hover:border-[#d4fde4]"
  end

  defp border("warning") do
    "border-[#FF8B08] hover:border-[#fff1cd]"
  end

  defp border("danger") do
    "border-[#E73B3B] hover:border-[#ffcdcd]"
  end

  defp border("info") do
    "border-[#004FC4] hover:border-[#cce1ff]"
  end

  defp border("misc") do
    "border-[#52059C] hover:border-[#ffe0ff]"
  end

  defp border("dawn") do
    "border-[#4D4137] hover:border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] hover:border-[#d2d8e9]"
  end

  defp border("dark") do
    "border-[#1E1E1E] hover:border-[#111111]"
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp size_class("extra_small"), do: "py-1 px-2 text-xs"
  defp size_class("small"), do: "py-1.5 px-3 text-sm"
  defp size_class("medium"), do: "py-2 px-4 text-base"
  defp size_class("large"), do: "py-2.5 px-5 text-lg"
  defp size_class("extra_large"), do: "py-3 px-5 text-xl"
  defp size_class("full_width"), do: "py-2 px-4 w-full text-base"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("large")

  defp space_class("extra_small"), do: "gap-1"
  defp space_class("small"), do: "gap-1.5"
  defp space_class("medium"), do: "gap-2"
  defp space_class("large"), do: "gap-2.5"
  defp space_class("extra_large"), do: "gap-3"
  defp space_class("none"), do: "gap-0"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("extra_small")

  defp default_classes() do
    [
      "flex items-center gap-1"
    ]
  end
end
