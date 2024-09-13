defmodule MishkaChelekom.TextField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "light", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :variant, :string, default: "default", doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_large", doc: ""
  attr :input_icon, :string, default: nil, doc: ""
  attr :icon_position, :string, default: nil, doc: "start, end"
  attr :ring, :boolean, default: true, doc: ""
  attr :label, :string, default: nil
  attr :errors, :list, default: [""]
  attr :name, :any
  attr :value, :any
  attr :rest, :global, doc: ""
  slot :inner_block

  #TODO: How add success status to text field

  def text_field(assigns) do
    ~H"""
    <div
      class={[
        color_variant(@variant, @color),
        rounded_size(@rounded),
        border_class(@border),
        size_class(@size),
        space_class(@space),
        @ring && "[&_.input-text-wrapper]:focus-within:ring-[0.02rem]",
        @icon_position == "start" && "[&_.input-text-wrapper]:flex-row-reverse",
        @class
      ]}
    >
      <.label for={@id}><%= @label %></.label>

      <div
        class={[
          "input-text-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
          @errors != [] && "text-input-error"
        ]}
      >
        <input
          type="text"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:neutral-200 block w-full border-0 bg-transparent",
            "focus:outline-none focus:ring-0"
          ]}
          {@rest}
        />
        <div class="flex items-center justify-center shrink-0 px-2 h-[inherit]">
          <.icon :if={!is_nil(@input_icon)} name={@input_icon} class="text-input-icon" />
        </div>
      </div>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  attr :icon, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-600">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp size_class("extra_small"), do: "[&_.input-text-wrapper>input]:h-5 [&_.input-text-wrapper>.text-input-icon]:size-2"
  defp size_class("small"), do: "[&_.input-text-wrapper>input]:h-6 [&_.input-text-wrapper>.text-input-icon]:size-2.5"
  defp size_class("medium"), do: "[&_.input-text-wrapper>input]:h-7 [&_.input-text-wrapper>.text-input-icon]:size-3"
  defp size_class("large"), do: "[&_.input-text-wrapper>input]:h-8 [&_.input-text-wrapper>.text-input-icon]:size-3.5"
  defp size_class("extra_large"), do: "[&_.input-text-wrapper>input]:h-9 [&_.input-text-wrapper>.text-input-icon]:size-4"
  defp size_class(_), do: size_class("extra_large")

  defp rounded_size("extra_small"), do: "[&_.input-text-wrapper]:rounded-sm"
  defp rounded_size("small"), do: "[&_.input-text-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.input-text-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.input-text-wrapper]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.input-text-wrapper]:rounded-xl"
  defp rounded_size("full"), do: "[&_.input-text-wrapper]:rounded-full"
  defp rounded_size(_), do: "[&_.input-text-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.input-text-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.input-text-wrapper]:border"
  defp border_class("small"), do: "[&_.input-text-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.input-text-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.input-text-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.input-text-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("default", "white") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#DADADA] [&_.input-text-wrapper]:border-[#DADADA]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#DADADA] focus-within:[&_.input-text-wrapper]:ring-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#2441de] [&_.input-text-wrapper]:border-[#2441de]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.input-text-wrapper]:ring-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#877C7C] [&_.input-text-wrapper]:border-[#877C7C]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.input-text-wrapper]:ring-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#6EE7B7] [&_.input-text-wrapper]:border-[#6EE7B7]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#6EE7B7] focus-within:[&_.input-text-wrapper]:ring-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#FF8B08] [&_.input-text-wrapper]:border-[#FF8B08]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.input-text-wrapper]:ring-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#E73B3B] [&_.input-text-wrapper]:border-[#E73B3B]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.input-text-wrapper]:ring-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#004FC4] [&_.input-text-wrapper]:border-[#004FC4]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.input-text-wrapper]:ring-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#52059C] [&_.input-text-wrapper]:border-[#52059C]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.input-text-wrapper]:ring-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#4D4137] [&_.input-text-wrapper]:border-[#4D4137]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.input-text-wrapper]:ring-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#707483] [&_.input-text-wrapper]:border-[#707483]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.input-text-wrapper]:ring-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
   [
      "[&_.input-text-wrapper]:bg-white text-[#1E1E1E] [&_.input-text-wrapper]:text-white [&_.input-text-wrapper]:border-[#050404]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.input-text-wrapper]:ring-[#050404]"
   ]
  end

  defp color_variant("filled", "white") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#3E3E3E] [&_.input-text-wrapper]:border-[#DADADA]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.input-text-wrapper]:ring-[#DADADA]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "[&_.input-text-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.input-text-wrapper]:border-[#2441de]",
      "[&_.input-text-wrapper>input]:placeholder:text-white focus-within:[&_.input-text-wrapper]:ring-[#2441de]"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "[&_.input-text-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.input-text-wrapper]:border-[#877C7C]",
      "[&_.input-text-wrapper>input]:placeholder:text-white focus-within:[&_.input-text-wrapper]:ring-[#877C7C]"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "[&_.input-text-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.input-text-wrapper]:border-[#6EE7B7]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.input-text-wrapper]:ring-[#6EE7B7]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "[&_.input-text-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.input-text-wrapper]:border-[#FF8B08]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.input-text-wrapper]:ring-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.input-text-wrapper]:border-[#E73B3B]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.input-text-wrapper]:ring-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "[&_.input-text-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.input-text-wrapper]:border-[#004FC4]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.input-text-wrapper]:ring-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.input-text-wrapper]:border-[#52059C]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.input-text-wrapper]:ring-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "[&_.input-text-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.input-text-wrapper]:border-[#4D4137]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.input-text-wrapper]:ring-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "[&_.input-text-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.input-text-wrapper]:border-[#707483]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.input-text-wrapper]:ring-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
   [
      "[&_.input-text-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.input-text-wrapper]:text-white [&_.input-text-wrapper]:border-[#050404]",
      "[&_.input-text-wrapper>input]:placeholder:text-white focus-within:[&_.input-text-wrapper]:ring-[#050404]"
   ]
  end

  defp color_variant("unbordered", "white") do
    [
      "[&_.input-text-wrapper]:bg-white [&_.input-text-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "[&_.input-text-wrapper]:bg-[#4363EC] [&_.input-text-wrapper]:border-transparent text-white",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "[&_.input-text-wrapper]:bg-[#6B6E7C] [&_.input-text-wrapper]:border-transparent text-white",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "[&_.input-text-wrapper]:bg-[#ECFEF3] [&_.input-text-wrapper]:border-transparent text-[#047857]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "[&_.input-text-wrapper]:bg-[#FFF8E6] [&_.input-text-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6E6] [&_.input-text-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "[&_.input-text-wrapper]:bg-[#E5F0FF] [&_.input-text-wrapper]:border-transparent text-[#004FC4]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6FF] [&_.input-text-wrapper]:border-transparent text-[#52059C]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "[&_.input-text-wrapper]:bg-[#FFECDA] [&_.input-text-wrapper]:border-transparent text-[#4D4137]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "[&_.input-text-wrapper]:bg-[#E3E7F1] [&_.input-text-wrapper]:border-transparent text-[#707483]",
      "[&_.input-text-wrapper>input]:placeholder:text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "[&_.input-text-wrapper]:bg-[#1E1E1E] [&_.input-text-wrapper]:border-transparent text-white",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "[&_.input-text-wrapper]:bg-white text-[#3E3E3E] [&_.input-text-wrapper]:border-[#DADADA] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.input-text-wrapper]:bg-[#4363EC] text-white [&_.input-text-wrapper]:border-[#4363EC] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.input-text-wrapper]:bg-[#6B6E7C] text-white [&_.input-text-wrapper]:border-[#6B6E7C] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.input-text-wrapper]:bg-[#AFEAD0] text-[#227A52] [&_.input-text-wrapper]:border-[#AFEAD0] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#047857]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.input-text-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.input-text-wrapper]:border-[#FFF8E6] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#FF8B08]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.input-text-wrapper]:border-[#FFE6E6] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#E73B3B]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.input-text-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.input-text-wrapper]:border-[#E5F0FF] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#004FC4]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.input-text-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.input-text-wrapper]:border-[#FFE6FF] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#52059C]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.input-text-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.input-text-wrapper]:border-[#FFECDA] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4D4137]"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&_.input-text-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.input-text-wrapper]:border-[#E3E7F1] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-[#707483]"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&_.input-text-wrapper]:bg-[#1E1E1E] text-white [&_.input-text-wrapper]:border-[#1E1E1E] [&_.input-text-wrapper]:shadow",
      "[&_.input-text-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("transparent", "white") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#DADADA] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#DADADA]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#4363EC] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4363EC]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#6B6E7C] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#6B6E7C]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#047857] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#047857]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#FF8B08] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#FF8B08]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#E73B3B] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#E73B3B]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#004FC4] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#004FC4]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#52059C] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#52059C]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#4D4137] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#4D4137]"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#707483] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#707483]"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "[&_.input-text-wrapper]:bg-transparent text-[#1E1E1E] [&_.input-text-wrapper]:border-transparent",
      "[&_.input-text-wrapper>input]:placeholder:text-[#1E1E1E]"
    ]
  end
end
