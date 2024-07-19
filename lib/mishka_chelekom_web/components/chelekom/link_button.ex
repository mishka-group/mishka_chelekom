defmodule MishkaChelekom.LinkButton do
  use Phoenix.Component
  import MishkaChelekomComponents

  # TODO: We need Gradient
  # TODO: We need Button with label (number, pils , badge and etc)
  # TODO: We need Loader for Button, after creating spinner module

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants ["default", "outline", "transparent", "subtle", "shadow", "inverted"]
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
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["button", "submit", "reset", nil], default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full"], default: "large", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global, include: ~w(disabled form name value right_icon left_icon), doc: ""
  slot :inner_block, required: true, doc: ""

  def link_button(assigns) do
    ~H"""
    <button
      type={@type}
      id={@id}
      class={[
        "phx-submit-loading:opacity-75 inline-flex gap-2 items-center justify-center border",
        "transition-all ease-in-ou duration-100",
        "disabled:bg-opacity-60 disabled:border-opacity-60 disabled:cursor-not-allowed",
        "disabled:cursor-not-allowed",
        "focus:outline-none",
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
    </button>
    """
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] hover:bg-[#fafafa] hover:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#ECFEF3] hover:bg-[#d4fde4] hover:border-[#d4fde4]"
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
    "bg-transparent text-white border-white hover:text-[#fafafa] hover:border-[#d9d9d9]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] hover:text-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:text-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#227A52] hover:text-[#d4fde4] hover:border-[#d4fde4]"
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
    "bg-transparent text-white border-transparent hover:text-[#fafafa]"
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
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md hover:bg-[#fafafa] hover:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md hover:bg-[#d4fde4] hover:border-[#d4fde4]"
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

  defp color_variant(_, _), do: color_variant("default", "white")

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

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"
end
