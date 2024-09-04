defmodule MishkaChelekom.Tabs do
  use Phoenix.Component
  import MishkaChelekomComponents

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
  attr :border, :string, default: "none", doc: ""
  attr :content_border, :string, default: "none", doc: ""
  attr :rounded, :string, default: "none", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :space, :string, default: "none", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :content_position, :string, default: "start", doc: ""
  attr :padding, :string, default: "extra_small", doc: ""
  attr :trigger_padding, :string, default: "extra_small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :icon, :string, default: "hero-quote", doc: ""
  attr :icon_class, :string, default: nil, doc: ""

  slot :inner_block, required: false, doc: ""

  # TODO: js solution find tabpanel and if tab.getAttribute('aria-labelledby') === id then tabPanel.hidden = false
  def tabs(assigns) do
    ~H"""
    <div class={[
      "w-full",
      content_position(@content_position),
      trigger_padding(@trigger_padding),
      color_variant(@variant, @color),
      content_border(@content_border),
      rounded_size(@rounded),
      padding_size(@padding),
      border_class(@border),
      space_class(@space),
      size_class(@size),
      @font_weight,
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :reverse, :boolean, default: false, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def tabs_list(assigns) do
    ~H"""
    <div class={[
      "tab-trigger-list flex flex-row",
      @reverse && "flex-row-reverse"
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_position, :string, default: "start", doc: "start, end"
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""


  slot :inner_block, required: false, doc: ""

  def tab_trigger(assigns) do
    ~H"""
    <button
      class={[
        "tab-trigger flex flex-row glex-nowrap items-center gap-3",
        @icon_position == "end" && "flex-row-reverse",
        @font_weight,
        @class
      ]}
    >
      <span :if={@icon} class="block">
        <.icon name={@icon} class="tab-icon" />
      </span>
      <span>
        <%= render_slot(@inner_block) %>
      </span>
    </button>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def tab_panel(assigns) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  defp content_position("start") do
    "[&_.tab-trigger-list]:justify-start"
  end

  defp content_position("end") do
    "[&_.tab-trigger-list]:justify-end"
  end

  defp content_position("center") do
    "[&_.tab-trigger-list]:justify-center"
  end

  defp content_position("between") do
    "[&_.tab-trigger-list]:justify-between"
  end

  defp content_position("around") do
    "[&_.tab-trigger-list]:justify-around"
  end

  defp content_position(_), do: content_position("start")

  defp space_class("none"), do: "space-y-0"
  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("none")

  defp trigger_padding("none"), do: "p-0"
  defp trigger_padding("extra_small"), do: "py-1 px-2"
  defp trigger_padding("small"), do: "py-1.5 px-3"
  defp trigger_padding("medium"), do: "py-2 px-4"
  defp trigger_padding("large"), do: "py-2.5 px-5"
  defp trigger_padding("extra_large"), do: "py-3 px-5"
  defp trigger_padding(params) when is_binary(params), do: params
  defp trigger_padding(_), do: trigger_padding("small")

  defp padding_size("none"), do: "p-0"
  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "py-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp size_class("extra_small"), do: "text-xs [&_.tab-icon]:size-3"
  defp size_class("small"), do: "text-sm [&_.tab-icon]:size-4"
  defp size_class("medium"), do: "text-base [&_.tab-icon]:size-5"
  defp size_class("large"), do: "text-lg [&_.tab-icon]:size-6"
  defp size_class("extra_large"), do: "text-xl [&_.tab-icon]:size-7"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: [params]
  defp border_class(nil), do: border_class("none")

  defp content_border("none"), do: "border-b-0"
  defp content_border("extra_small"), do: "border-b"
  defp content_border("small"), do: "border-b-2"
  defp content_border("medium"), do: "border-b-[3px]"
  defp content_border("large"), do: "border-b-4"
  defp content_border("extra_large"), do: "border-b-[5px]"
  defp content_border(params) when is_binary(params), do: [params]
  defp content_border(nil), do: content_border("none")

  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(nil), do: rounded_size("none")

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
end
