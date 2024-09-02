defmodule MishkaChelekom.Stepper do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :margin, :string, default: "medium", doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :max_width, :string, default: nil, doc: ""
  attr :seperator_size, :string, default: "extra_small", doc: ""
  attr :vertical, :boolean, default: false, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  @spec stepper(map()) :: Phoenix.LiveView.Rendered.t()
  def stepper(%{vertical: true} = assigns) do
    ~H"""
    <div class={[
      "vertical-stepper relative",
      step_visibility(),
      size_class(@size),
      color_class(@color),
      @font_weight,
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def stepper(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex items-center w-full [&_.stepper-seperator:last-child]:hidden",
        step_visibility(),
        wrapper_width(@max_width),
        seperator_size(@seperator_size),
        seperator_margin(@margin),
        size_class(@size),
        color_class(@color),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :size, :string, default: "small"
  attr :rounded, :string, default: "full"
  attr :icon, :string, default: nil, doc: ""
  attr :color, :string, default: "white"
  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :step, :integer, default: 1
  attr :vertical, :boolean, default: false, doc: ""
  attr :border, :string, default: "none"

  slot :inner_block, required: false, doc: ""

  def stepper_section(%{vertical: true} = assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "vertical-step  text-start flex items-center justify-center shrink-0",
        @class
      ]}
    >
      <div :if={@icon} class="flex items-center justify-center shrink-0">
        <.icon name={@icon} class="stepper-icon" />
      </div>

      <div :if={!@icon}>
        <%= render_slot(@inner_block) %>
      </div>
    </button>
    <div class="stepper-seperator w-full"></div>
    """
  end

  def stepper_section(assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "stepper-section text-start flex flex-nowrap justify-center items-center shrink-0 gap-5",
        @class
      ]}
    >
      <span :if={@icon} class={[
        "stepper-step rounded-full flex justify-center items-center shrink-0",
        "transition-all ease-in-out duration-400 delay-100"
      ]}>
        <.icon name={@icon} class="step-symbol stepper-icon" />
        <.icon
          name="hero-check-solid"
          class={[
            "stepper-icon stepper-compeleted-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

      <span :if={!@icon} class={[
        "stepper-step rounded-full flex justify-center items-center shrink-0",
        "transition-all ease-in-out duration-400 delay-100"
      ]}>
        <span class="step-symbol"><%= @step %></span>
        <.icon
          name="hero-check-solid"
          class={[
            "stepper-icon stepper-compeleted-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

     <span class="block text-nowrap">
      <span :if={@title} class="block font-bold">
          <%= @title %>
        </span>

        <span :if={@description} class="block text-xs">
          <%= @description %>
        </span>

        <%= render_slot(@inner_block) %>
     </span>
    </button>
    <div class="stepper-seperator w-full"></div>
    """
  end

  defp step_visibility() do
    [
      "[&_.stepper-compeleted-icon]:hidden",
      "[&_.stepper-compeleted-icon]:invisible",
      "[&_.stepper-compeleted-icon]:opacity-0",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:block",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:visible",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:opacity-100",
      "[&_.stepper-compeleted-step_.step-symbol]:hidden",
      "[&_.stepper-compeleted-step_.step-symbol]:invisible",
      "[&_.stepper-compeleted-step_.step-symbol]:opacity-0"
    ]
  end

  defp seperator_margin("none") do
    [
      "[&_.stepper-seperator]:mx-0"
    ]
  end

  defp seperator_margin("extra_small") do
    [
      "[&_.stepper-seperator]:mx-2",
      "xl:[&_.stepper-seperator]:mx-6"
    ]
  end

  defp seperator_margin("small") do
    [
      "[&_.stepper-seperator]:mx-3",
      "xl:[&_.stepper-seperator]:mx-7"
    ]
  end

  defp seperator_margin("medium") do
    [
      "[&_.stepper-seperator]:mx-4",
      "xl:[&_.stepper-seperator]:mx-8"
    ]
  end

  defp seperator_margin("large") do
    [
      "[&_.stepper-seperator]:mx-5",
      "xl:[&_.stepper-seperator]:mx-9"
    ]
  end

  defp seperator_margin("extra_large") do
    [
      "[&_.stepper-seperator]:mx-6",
      "xl:[&_.stepper-seperator]:mx-10"
    ]
  end

  defp seperator_margin(params) when is_binary(params), do: params
  defp seperator_margin(_), do: seperator_margin("medium")

  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp wrapper_width("extra_small"), do: "max-w-1/4"
  defp wrapper_width("small"), do: "max-w-2/4"
  defp wrapper_width("medium"), do: "max-w-3/4"
  defp wrapper_width("large"), do: "max-w-11/12"
  defp wrapper_width("extra_large"), do: ""
  defp wrapper_width(params) when is_binary(params), do: params
  defp wrapper_width(_), do: nil

  defp size_class("extra_small"), do: "text-xs [&_.stepper-step]:size-7 [&_.stepper-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.stepper-step]:size-8 [&_.stepper-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.stepper-step]:size-9 [&_.stepper-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.stepper-step]:size-10 [&_.stepper-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.stepper-step]:size-11 [&_.stepper-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp seperator_size("extra_small"), do: "[&_.stepper-seperator]:h-px"
  defp seperator_size("small"), do: "[&_.stepper-seperator]:h-0.5"
  defp seperator_size("medium"), do: "[&_.stepper-seperator]:h-1"
  defp seperator_size("large"), do: "[&_.stepper-seperator]:h-1.5"
  defp seperator_size("extra_large"), do: "[&_.stepper-seperator]:h-2"
  defp seperator_size(params) when is_binary(params), do: params
  defp seperator_size(_), do: seperator_size("extra_small")


  # defp size_class("extra_small"), do: "size-5 text-xs [&.vertical-step]:-start-2.5"
  # defp size_class("small"), do: "size-6 text-sm [&.vertical-step]:-start-3"
  # defp size_class("medium"), do: "size-7 text-base [&.vertical-step]:-start-3.5"
  # defp size_class("large"), do: "size-8 text-lg [&.vertical-step]:-start-4"
  # defp size_class("extra_large"), do: "size-9 text-xl [&.vertical-step]:-start-[18px]"
  # defp size_class(params) when is_binary(params), do: params
  # defp size_class(_), do: size_class("small")

  # colors
# stepper-loading-step, stepper-active-step, stepper-compeleted-step, stepper-canceled-step
  defp color_class("white") do
    [
      "[&_.stepper-step]:bg-[#DADADA] [&_.stepper-step]:text-[#3E3E3E]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-white",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-white [&_.stepper-compeleted-step_.stepper-step]:border-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#DADADA] [&_.stepper-compeleted-step_.stepper-seperator]:border-white"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.stepper-step]:bg-[#5573f2] [&_.stepper-step]:text-white",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#162da8]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#162da8] [&_.stepper-compeleted-step_.stepper-step]:border-[#162da8]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#5573f2] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#162da8]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.stepper-step]:bg-[#6B6E7C] [&_.stepper-step]:text-white",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#434652]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#434652] [&_.stepper-compeleted-step_.stepper-step]:border-[#434652]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#6B6E7C] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#434652]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.stepper-step]:bg-[#ECFEF3] [&_.stepper-step]:text-[#047857]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#047857]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#047857] [&_.stepper-compeleted-step_.stepper-step]:border-[#047857]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#ECFEF3] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#047857]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.stepper-step]:bg-[#FFF8E6] [&_.stepper-step]:text-[#FF8B08]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#FF8B08]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#FF8B08] [&_.stepper-compeleted-step_.stepper-step]:border-[#FF8B08]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#FFF8E6] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.stepper-step]:bg-[#FFE6E6] [&_.stepper-step]:text-[#E73B3B]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#E73B3B]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#E73B3B] [&_.stepper-compeleted-step_.stepper-step]:border-[#E73B3B]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#FFE6E6] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.stepper-step]:bg-[#E5F0FF] [&_.stepper-step]:text-[#004FC4]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#004FC4]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#004FC4] [&_.stepper-compeleted-step_.stepper-step]:border-[#004FC4]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#E5F0FF] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.stepper-step]:bg-[#FFE6FF] [&_.stepper-step]:text-[#52059C]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#52059C]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#52059C] [&_.stepper-compeleted-step_.stepper-step]:border-[#52059C]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#FFE6FF] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.stepper-step]:bg-[#FFECDA] [&_.stepper-step]:text-[#4D4137]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#4D4137]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#4D4137] [&_.stepper-compeleted-step_.stepper-step]:border-[#4D4137]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#FFECDA] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.stepper-step]:bg-[#E3E7F1] [&_.stepper-step]:text-[#707483]",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#707483]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#707483] [&_.stepper-compeleted-step_.stepper-step]:border-[#707483]",
      "[&_.stepper-compeleted-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#E3E7F1] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.stepper-step]:bg-[#1E1E1E] [&_.stepper-step]:text-white",
      "[&_.stepper-step]:border-transparent [&_.stepper-active-step_.stepper-step]:border-[#050404]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#050404] [&_.stepper-compeleted-step_.stepper-step]:border-[#050404]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#fa2d2d] [&_.stepper-canceled-step_.stepper-step]:border-[#fa2d2d]",
      "[&_.stepper-seperator]:bg-[#1E1E1E] [&_.stepper-compeleted-step_.stepper-seperator]:border-[#050404]"
    ]
  end

  defp color_class(params) when is_binary(params), do: params
  defp color_class(_), do: color_class("primary")
end
