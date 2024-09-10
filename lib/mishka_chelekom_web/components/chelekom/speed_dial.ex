defmodule MishkaChelekom.SpeedDial do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :action_position, :string, default: "bottom_end", doc: ""
  attr :position_size, :string, default: "medium", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rest, :global, doc: ""

  def speed_dial(assigns) do
    ~H"""
    <div class={[
      "fixed group",
      action_position(@position_size, @action_position),
      border_class(@border)
    ]}>
      <div id="speed-dial-menu-default" class="flex flex-col items-center hidden mb-4 space-y-2">
        <%= render_slot(@inner_block) %>
      </div>

      <button
        type="button"
        aria-controls="speed-dial-menu-default"
        aria-expanded="false"
        class="action-button flex items-center justify-center"
      >
        <.icon name="hero-plus" class="size-5 transition-transform group-hover:rotate-45" />
        <span class="sr-only">Open actions menu</span>
      </button>
    </div>
    """
  end

  defp action_position("none", "top_start"), do: "top-0 start-0 ml-0"
  defp action_position("extra_small", "top_start"), do: "top-1 start-1 ml-1"
  defp action_position("small", "top_start"), do: "top-2 start-2 ml-2"
  defp action_position("medium", "top_start"), do: "top-3 start-3 ml-3"
  defp action_position("large", "top_start"), do: "top-4 start-4 ml-4"
  defp action_position("extra_large", "top_start"), do: "top-5 start-5 ml-5"

  defp action_position("none", "top_end"), do: "top-0 end-0 ml-0"
  defp action_position("extra_small", "top_end"), do: "top-1 end-1 ml-1"
  defp action_position("small", "top_end"), do: "top-2 end-2 ml-2"
  defp action_position("medium", "top_end"), do: "top-3 end-3 ml-3"
  defp action_position("large", "top_end"), do: "top-4 end-4 ml-4"
  defp action_position("extra_large", "top_end"), do: "top-5 end-5 ml-5"

  defp action_position("none", "bottom_start"), do: "bottom-0 start-0 ml-0"
  defp action_position("extra_small", "bottom_start"), do: "bottom-1 start-1 ml-1"
  defp action_position("small", "bottom_start"), do: "bottom-2 start-2 ml-2"
  defp action_position("medium", "bottom_start"), do: "bottom-3 start-3 ml-3"
  defp action_position("large", "bottom_start"), do: "bottom-4 start-4 ml-4"
  defp action_position("extra_large", "bottom_start"), do: "bottom-5 start-5 ml-5"

  defp action_position("none", "bottom_end"), do: "bottom-0 end-0 ml-0"
  defp action_position("extra_small", "bottom_end"), do: "bottom-1 end-1 ml-1"
  defp action_position("small", "bottom_end"), do: "bottom-2 end-2 ml-2"
  defp action_position("medium", "bottom_end"), do: "bottom-3 end-3 ml-3"
  defp action_position("large", "bottom_end"), do: "bottom-4 end-4 ml-4"
  defp action_position("extra_large", "bottom_end"), do: "bottom-5 end-5 ml-5"

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(_), do: rounded_size("full")

  defp size_class("extra_small"), do: "mx-auto max-w-xs"
  defp size_class("small"), do: "mx-auto max-w-sm"
  defp size_class("medium"), do: "mx-auto max-w-md"
  defp size_class("large"), do: "mx-auto max-w-lg"
  defp size_class("extra_large"), do: "mx-auto max-w-xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_large")

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

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
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white"
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

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow"
  end

  defp color_variant(_, _), do: color_variant("default", "white")
end
