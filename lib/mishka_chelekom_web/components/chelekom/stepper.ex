defmodule MishkaChelekom.Stepper do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :gap, :string, default: "small", doc: ""
  attr :color, :string, default: "silver", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def stepper(assigns) do
    ~H"""
    <div id={@id}
      class={[
        "flex items-center w-full text-center",
        border_class(@border),
        stepper_color(@color),
        size_class(@size),
        gap_class(@gap),
        seperator_after(),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def stepper_section(assigns) do
    ~H"""
    <div class={[
      "stepper-section flex items-center",
    ]}>
      <div :if={@icon}>
        <.icon
          name={@icon}
          class="stepper-icon shrink-0"
        />
      </div>
        <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :size, :string, default: "small"
  attr :rounded, :string, default: "full"
  attr :color, :string, default: "transparent"
  attr :border, :string, default: "none"

  slot :inner_block, required: false, doc: ""

  def stepper_number(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "step_number inline-flex justify-center items-center shrink-0",
        step_size(@size),
        step_border(@border),
        rounded_size(@rounded),
        step_background(@color),
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp seperator_after() do
    [
      "sm:[&_.stepper-section:not(:last-child)]:w-full [&_.stepper-section:not(:last-child)]:after:h-1",
      "sm:[&_.stepper-section:not(:last-child)]:after:content-[''] [&_.stepper-section:not(:last-child)]:after:w-full",
      "[&_.stepper-section:not(:last-child)]:after:hidden sm:[&_.stepper-section:not(:last-child)]:after:inline-block",
      "[&_.stepper-section:not(:last-child)]:after:mx-6 xl:[&_.stepper-section:not(:last-child)]:after:mx-10",
    ]
  end

  defp border_class("extra_small"), do: "[&_.stepper-section:not(:last-child)]:after:border-b"
  defp border_class("small"), do: "[&_.stepper-section:not(:last-child)]:after:border-b-2"
  defp border_class("medium"), do: "[&_.stepper-section:not(:last-child)]:after:border-b-[3px]"
  defp border_class("large"), do: "[&_.stepper-section:not(:last-child)]:after:border-b-4"
  defp border_class("extra_large"), do: "[&_.stepper-section:not(:last-child)]:after:border-b-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp size_class("extra_small"), do: "text-xs [&_.stepper-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.stepper-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.stepper-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.stepper-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.stepper-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp gap_class("extra_small"), do: "[&_.stepper-section]:gap-1"
  defp gap_class("small"), do: "[&_.stepper-section]:gap-2"
  defp gap_class("medium"), do: "[&_.stepper-section]:gap-3"
  defp gap_class("large"), do: "[&_.stepper-section]:gap-4"
  defp gap_class("extra_large"), do: "[&_.stepper-section]:gap-5"
  defp gap_class(params) when is_binary(params), do: params
  defp gap_class(_), do: gap_class("small")


  defp step_border("none"), do: "border-none"
  defp step_border("extra_small"), do: "border"
  defp step_border("small"), do: "border-2"
  defp step_border("medium"), do: "border-[3px]"
  defp step_border("large"), do: "border-4"
  defp step_border("extra_large"), do: "border-[5px]"
  defp step_border(params) when is_binary(params), do: params
  defp step_border(_), do: step_border("none")

  defp step_size("extra_small"), do: "size-5 text-xs"
  defp step_size("small"), do: "size-6 text-sm"
  defp step_size("medium"), do: "size-7 text-base"
  defp step_size("large"), do: "size-8 text-lg"
  defp step_size("extra_large"), do: "size-9 text-xl"
  defp step_size(params) when is_binary(params), do: params
  defp step_size(_), do: step_size("small")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("full")

  defp step_background("transparent") do
    "bg-transparent"
  end

  defp step_background("white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp step_background("primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp step_background("secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp step_background("success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp step_background("warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp step_background("danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp step_background("info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp step_background("misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp step_background("dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp step_background("light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp step_background("dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp step_background(params) when is_binary(params), do: params
  defp step_background(_), do: step_background("transparent")

  defp stepper_color("white") do
    "text-white [&_.stepper-section:not(:last-child)]:after:border-white"
  end

  defp stepper_color("silver") do
    "text-[#3E3E3E] [&_.stepper-section:not(:last-child)]:after:border-[#DADADA]"
  end

  defp stepper_color("primary") do
    "text-[#2441de] [&_.stepper-section:not(:last-child)]:after:border-[#2441de]"
  end

  defp stepper_color("secondary") do
    "text-[#2441de] [&_.stepper-section:not(:last-child)]:after:border-[#877C7C]"
  end

  defp stepper_color("success") do
    "text-[#6EE7B7] [&_.stepper-section:not(:last-child)]:after:border-[#6EE7B7]"
  end

  defp stepper_color("warning") do
    "text-[#FF8B08] [&_.stepper-section:not(:last-child)]:after:border-[#FF8B08]"
  end

  defp stepper_color("danger") do
    "text-[#E73B3B] [&_.stepper-section:not(:last-child)]:after:border-[#E73B3B]"
  end

  defp stepper_color("info") do
    "text-[#004FC4] [&_.stepper-section:not(:last-child)]:after:border-[#004FC4]"
  end

  defp stepper_color("misc") do
    "text-[#52059C] [&_.stepper-section:not(:last-child)]:after:border-[#52059C]"
  end

  defp stepper_color("dawn") do
    "text-[#4D4137] [&_.stepper-section:not(:last-child)]:after:border-[#4D4137]"
  end

  defp stepper_color("light") do
    "text-[#707483] [&_.stepper-section:not(:last-child)]:after:border-[#707483]"
  end

  defp stepper_color("dark") do
    "text-white [&_.stepper-section:not(:last-child)]:after:border-[#050404]"
  end

end
