defmodule MishkaChelekom.SpeedDial do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :action_position, :string, default: "bottom_end", doc: ""
  attr :position_size, :string, default: "large", doc: ""
  attr :rounded, :string, default: "full", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :variant, :string, default: "default", doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_animated, :boolean, default: false, doc: ""
  attr :rest, :global, doc: ""

  slot :trigger_content, required: false do
    attr :class, :string
  end

  def speed_dial(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed group",
        action_position(@position_size, @action_position),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        border_class(@border),
        size_class(@size),
        space_class(@space),
      ]}
      {@rest}
    >
      <div class="speed-dial-menu-wrapper flex flex-col items-center hidden mb-4 space-y-2">
        <%= render_slot(@inner_block) %>
      </div>

      <button
        type="button"
        class="peed-dial-trigger flex items-center justify-center"
      >
        <.icon :if={!is_nil(@icon)} name={@icon} class={@icon_animated && "transition-transform group-hover:rotate-45"} />
        <span :if={is_nil(@icon)} class={@trigger_content[:class]}><%= @trigger_content %></span>
        <span class="sr-only">Open actions menu</span>
      </button>
    </div>
    """
  end

  defp space_class("extra_small"), do: "[&_.speed-dial-menu-wrapper]:space-y-2"
  defp space_class("small"), do: "[&_.speed-dial-menu-wrapper]:space-y-3"
  defp space_class("medium"), do: "[&_.speed-dial-menu-wrapper]:space-y-4"
  defp space_class("large"), do: "[&_.speed-dial-menu-wrapper]:space-y-5"
  defp space_class("extra_large"), do: "[&_.speed-dial-menu-wrapper]:space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("extra_small")

  defp rounded_size("extra_small"), do: "[&_.peed-dial-trigger]:rounded-sm"
  defp rounded_size("small"), do: "[&_.peed-dial-trigger]:rounded"
  defp rounded_size("medium"), do: "[&_.peed-dial-trigger]:rounded-md"
  defp rounded_size("large"), do: "[&_.peed-dial-trigger]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.peed-dial-trigger]:rounded-xl"
  defp rounded_size("full"), do: "[&_.peed-dial-trigger]:rounded-full"
  defp rounded_size(_), do: rounded_size("full")

  defp size_class("extra_small"), do: "[&_.peed-dial-trigger]:size-9"
  defp size_class("small"), do: "[&_.peed-dial-trigger]:size-10"
  defp size_class("medium"), do: "[&_.peed-dial-trigger]:size-12"
  defp size_class("large"), do: "[&_.peed-dial-trigger]:size-14"
  defp size_class("extra_large"), do: "[&_.peed-dial-trigger]:size-18"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_large")

  defp border_class("none"), do: "[&_.peed-dial-trigger]:border-0"
  defp border_class("extra_small"), do: "[&_.peed-dial-trigger]:border"
  defp border_class("small"), do: "[&_.peed-dial-trigger]:border-2"
  defp border_class("medium"), do: "[&_.peed-dial-trigger]:[&_.peed-dial-trigger]:border-[3px]"
  defp border_class("large"), do: "[&_.peed-dial-trigger]:border-4"
  defp border_class("extra_large"), do: "[&_.peed-dial-trigger]:[&_.peed-dial-trigger]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp action_position("none", "top_start"), do: "top-0 start-0"
  defp action_position("extra_small", "top_start"), do: "top-1 4tart-4"
  defp action_position("small", "top_start"), do: "top-2 5tart-5"
  defp action_position("medium", "top_start"), do: "top-3 6tart-6"
  defp action_position("large", "top_start"), do: "top-4 7tart-7"
  defp action_position("extra_large", "top_start"), do: "top-8 star8-5"

  defp action_position("none", "top_end"), do: "top-0 end-0"
  defp action_position("extra_small", "top_end"), do: "top-4 end-4"
  defp action_position("small", "top_end"), do: "top-5 end-5"
  defp action_position("medium", "top_end"), do: "top-6 end-6"
  defp action_position("large", "top_end"), do: "top-7 end-7"
  defp action_position("extra_large", "top_end"), do: "top-8 end-8"

  defp action_position("none", "bottom_start"), do: "bottom-0 start-0"
  defp action_position("extra_small", "bottom_start"), do: "bottom-4 start-4"
  defp action_position("small", "bottom_start"), do: "bottom-5 start-5"
  defp action_position("medium", "bottom_start"), do: "bottom-6 start-6"
  defp action_position("large", "bottom_start"), do: "bottom-8 start-8"
  defp action_position("extra_large", "bottom_start"), do: "bottom-9 start-9"

  defp action_position("none", "bottom_end"), do: "bottom-0 end-0"
  defp action_position("extra_small", "bottom_end"), do: "bottom-4 end-4"
  defp action_position("small", "bottom_end"), do: "bottom-5 end-5"
  defp action_position("medium", "bottom_end"), do: "bottom-6 end-6"
  defp action_position("large", "bottom_end"), do: "bottom-8 end-8"
  defp action_position("extra_large", "bottom_end"), do: "bottom-9 end-9"

  defp color_variant("default", "white") do
    "[&_.peed-dial-trigger]:bg-white [&_.peed-dial-trigger]:text-[#3E3E3E] [&_.peed-dial-trigger]:border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "[&_.peed-dial-trigger]:bg-[#4363EC] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "[&_.peed-dial-trigger]:bg-[#6B6E7C] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "[&_.peed-dial-trigger]:bg-[#ECFEF3] [&_.peed-dial-trigger]:text-[#047857] [&_.peed-dial-trigger]:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "[&_.peed-dial-trigger]:bg-[#FFF8E6] [&_.peed-dial-trigger]:text-[#FF8B08] [&_.peed-dial-trigger]:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "[&_.peed-dial-trigger]:bg-[#FFE6E6] [&_.peed-dial-trigger]:text-[#E73B3B] [&_.peed-dial-trigger]:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "[&_.peed-dial-trigger]:bg-[#E5F0FF] [&_.peed-dial-trigger]:text-[#004FC4] [&_.peed-dial-trigger]:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "[&_.peed-dial-trigger]:bg-[#FFE6FF] [&_.peed-dial-trigger]:text-[#52059C] [&_.peed-dial-trigger]:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "[&_.peed-dial-trigger]:bg-[#FFECDA] [&_.peed-dial-trigger]:text-[#4D4137] [&_.peed-dial-trigger]:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "[&_.peed-dial-trigger]:bg-[#E3E7F1] [&_.peed-dial-trigger]:text-[#707483] [&_.peed-dial-trigger]:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "[&_.peed-dial-trigger]:bg-[#1E1E1E] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#050404]"
  end

  defp color_variant("unbordered", "white") do
    "[&_.peed-dial-trigger]:bg-white [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#3E3E3E]"
  end

  defp color_variant("unbordered", "primary") do
    "[&_.peed-dial-trigger]:bg-[#4363EC] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-white"
  end

  defp color_variant("unbordered", "secondary") do
    "[&_.peed-dial-trigger]:bg-[#6B6E7C] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-white"
  end

  defp color_variant("unbordered", "success") do
    "[&_.peed-dial-trigger]:bg-[#ECFEF3] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#047857]"
  end

  defp color_variant("unbordered", "warning") do
    "[&_.peed-dial-trigger]:bg-[#FFF8E6] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#FF8B08]"
  end

  defp color_variant("unbordered", "danger") do
    "[&_.peed-dial-trigger]:bg-[#FFE6E6] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#E73B3B]"
  end

  defp color_variant("unbordered", "info") do
    "[&_.peed-dial-trigger]:bg-[#E5F0FF] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#004FC4]"
  end

  defp color_variant("unbordered", "misc") do
    "[&_.peed-dial-trigger]:bg-[#FFE6FF] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#52059C]"
  end

  defp color_variant("unbordered", "dawn") do
    "[&_.peed-dial-trigger]:bg-[#FFECDA] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#4D4137]"
  end

  defp color_variant("unbordered", "light") do
    "[&_.peed-dial-trigger]:bg-[#E3E7F1] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-[#707483]"
  end

  defp color_variant("unbordered", "dark") do
    "[&_.peed-dial-trigger]:bg-[#1E1E1E] [&_.peed-dial-trigger]:border-transparent [&_.peed-dial-trigger]:text-white"
  end

  defp color_variant("shadow", "white") do
    "[&_.peed-dial-trigger]:bg-white [&_.peed-dial-trigger]:text-[#3E3E3E] [&_.peed-dial-trigger]:border-[#DADADA] shadow"
  end

  defp color_variant("shadow", "primary") do
    "[&_.peed-dial-trigger]:bg-[#4363EC] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#4363EC] shadow"
  end

  defp color_variant("shadow", "secondary") do
    "[&_.peed-dial-trigger]:bg-[#6B6E7C] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#6B6E7C] shadow"
  end

  defp color_variant("shadow", "success") do
    "[&_.peed-dial-trigger]:bg-[#AFEAD0] [&_.peed-dial-trigger]:text-[#227A52] [&_.peed-dial-trigger]:border-[#AFEAD0] shadow"
  end

  defp color_variant("shadow", "warning") do
    "[&_.peed-dial-trigger]:bg-[#FFF8E6] [&_.peed-dial-trigger]:text-[#FF8B08] [&_.peed-dial-trigger]:border-[#FFF8E6] shadow"
  end

  defp color_variant("shadow", "danger") do
    "[&_.peed-dial-trigger]:bg-[#FFE6E6] [&_.peed-dial-trigger]:text-[#E73B3B] [&_.peed-dial-trigger]:border-[#FFE6E6] shadow"
  end

  defp color_variant("shadow", "info") do
    "[&_.peed-dial-trigger]:bg-[#E5F0FF] [&_.peed-dial-trigger]:text-[#004FC4] [&_.peed-dial-trigger]:border-[#E5F0FF] shadow"
  end

  defp color_variant("shadow", "misc") do
    "[&_.peed-dial-trigger]:bg-[#FFE6FF] [&_.peed-dial-trigger]:text-[#52059C] [&_.peed-dial-trigger]:border-[#FFE6FF] shadow"
  end

  defp color_variant("shadow", "dawn") do
    "[&_.peed-dial-trigger]:bg-[#FFECDA] [&_.peed-dial-trigger]:text-[#4D4137] [&_.peed-dial-trigger]:border-[#FFECDA] shadow"
  end

  defp color_variant("shadow", "light") do
    "[&_.peed-dial-trigger]:bg-[#E3E7F1] [&_.peed-dial-trigger]:text-[#707483] [&_.peed-dial-trigger]:border-[#E3E7F1] shadow"
  end

  defp color_variant("shadow", "dark") do
    "[&_.peed-dial-trigger]:bg-[#1E1E1E] [&_.peed-dial-trigger]:text-white [&_.peed-dial-trigger]:border-[#1E1E1E] shadow"
  end

  defp color_variant(_, _), do: color_variant("default", "white")
end
