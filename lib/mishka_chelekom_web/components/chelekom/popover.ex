defmodule MishkaChelekom.Popover do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

  @sizes [
    "extra_small",
    "small",
    "medium",
    "large",
    "extra_large",
    "double_large",
    "triple_large",
    "quadruple_large"
  ]
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
    "shadow"
  ]

  @positions [
    "start",
    "center",
    "end",
    "between",
    "around"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :position, :string, default: "top", doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :size, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  #TODO: [&:not(.active)]:invisible add this to class
  def popover(assigns) do
    ~H"""
    <div
      role="tooltip"
      id={@id}
      class={[
        "absolute z-10 visible [&.active]:visible",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <div class={[
        "absolute size-[8px] bg-inherit rotate-45",
        position_class(@position)
      ]}>
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :title, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :position, :string, values: @positions, default: "start", doc: ""
  attr :font_weight, :string, default: "font-semibold", doc: ""
  attr :size, :string, values: @sizes, default: "large", doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def popover_title(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "popover-section flex items-center gap-2",
        padding_size(@padding),
        content_position(@position),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div :if={@title || @icon} class="flex gap-2 items-center">
        <.icon :if={@icon} name={@icon} class="popover-title-icon" />
        <h3 :if={@title}><%= @title %></h3>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :space, :string, values: @sizes, default: "extra_small", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def popover_content(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "popover-section",
        space_class(@space),
        padding_size(@padding),
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def popover_footer(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "popover-section",
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def show_popover(js \\ %JS{}, id) do
    js
    |> JS.toggle_class("active", to: "##{id}")
  end

  def hide_popover(js \\ %JS{}, id) do
    js
    |> JS.toggle_class("active", to: "##{id}")
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp position_class("top"), do: "-bottom-[4px] -translate-x-1/2 left-1/2"
  defp position_class("bottom"), do: "-top-[4px] -translate-x-1/2 left-1/2"
  defp position_class("left"), do: "-left-[4px] translate-y-1/2 top-1/3"
  defp position_class("right"), do: "-right-[4px] translate-y-1/2 top-1/3"

  defp size_class("extra_small"),
    do: "text-xs min-h-10 max-w-[12rem] [&_.popover-title-icon]:size-3"

  defp size_class("small"), do: "text-sm min-h-10 max-w-[14rem] [&_.popover-title-icon]:size-3.5"
  defp size_class("medium"), do: "text-base min-h-10 max-w-[16rem] [&_.popover-title-icon]:size-4"
  defp size_class("large"), do: "text-lg min-h-10 max-w-[18rem] [&_.popover-title-icon]:size-5"

  defp size_class("extra_large"),
    do: "text-xl min-h-10 max-w-[20rem] [&_.popover-title-icon]:size-6"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position("between") do
    "justify-between"
  end

  defp content_position("around") do
    "justify-around"
  end

  defp content_position(_), do: content_position("start")

  defp wrapper_padding("extra_small"),
    do: "[&:has(.popover-section)>.popover-section]:p-1 [&:not(:has(.popover-section))]:p-1"

  defp wrapper_padding("small"),
    do: "[&:has(.popover-section)>.popover-section]:p-2 [&:not(:has(.popover-section))]:p-2"

  defp wrapper_padding("medium"),
    do: "[&:has(.popover-section)>.popover-section]:p-3 [&:not(:has(.popover-section))]:p-3"

  defp wrapper_padding("large"),
    do: "[&:has(.popover-section)>.popover-section]:p-4 [&:not(:has(.popover-section))]:p-4"

  defp wrapper_padding("extra_large"),
    do: "[&:has(.popover-section)>.popover-section]:p-5 [&:not(:has(.popover-section))]:p-5"

  defp wrapper_padding("none"), do: "p-0"
  defp wrapper_padding(params) when is_binary(params), do: params
  defp wrapper_padding(_), do: wrapper_padding("none")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("none")

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

  defp color_variant("outline", "white") do
    "bg-transparent text-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC]] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E]"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E]] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52]] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08]] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B]] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4]] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C]] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137]] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483]] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E]"
  end
end
