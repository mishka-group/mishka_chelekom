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
  attr :variant, :string, default: "outline", doc: ""
  attr :description, :string, default: nil, doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_large", doc: ""
  attr :ring, :boolean, default: true, doc: ""
  attr :floating_label, :boolean, default: false, doc: ""
  attr :label, :string, default: nil
  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any
  attr :rest, :global, doc: ""
  slot :inner_block

  slot :start_section, required: false do
    attr :class, :string
    attr :icon, :string
  end

  slot :end_section, required: false do
    attr :class, :string
    attr :icon, :string
  end

  # TODO: How add success status to text field

  def text_field(%{floating_label: true} = assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, true),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.text-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        <%= @description %>
      </div>
      <div class={[
        "text-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "text-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>
        <div class="relative w-full z-[2]">
          <input
            type="text"
            name={@name}
            id={@id}
            value={@value}
            class={[
              "block disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent py-1 px-2",
              "text-sm disabled:opacity-80 w-full appearance-none bg-transparent border-0 focus:outline-none peer"
            ]}
            placeholder=" "
            {@rest}
          />

          <label
            class={[
              "floating-label p-1 start-1 -z-[1] absolute text-xs duration-300 transform scale-75 origin-[0]",
              variant_label_position(@variant)
            ]}
            for={@id}
          >
            <%= @label %>
          </label>
        </div>

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
      </div>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def text_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, false),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.text-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "text-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "text-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>

        <input
          type="text"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:neutral-200 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0"
          ]}
          {@rest}
        />

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
      </div>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  attr :for, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  attr :icon, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp variant_label_position("outline") do
    [
      "-translate-y-4 top-2",
      "peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-3",
      "peer-focus:scale-75 peer-focus:-translate-y-7"
    ]
  end

  defp variant_label_position("default") do
    [
      "-translate-y-4 top-2 peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2",
      "peer-focus:scale-75 peer-focus:-translate-y-4"
    ]
  end

  defp variant_label_position("transparent") do
    [
      "transform -translate-y-4 top-2 peer-focus:start-0 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-6"
    ]
  end

  defp variant_label_position("unbordered") do
    [
      "-translate-y-4 top-2",
      "peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-5",
      "peer-focus:scale-75 peer-focus:-translate-y-6"
    ]
  end

  defp variant_label_position("shadow") do
    [
      "-translate-y-4 top-2",
      "peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-5",
      "peer-focus:scale-75 peer-focus:-translate-y-6"
    ]
  end


  defp size_class("extra_small"),
    do: "[&_.text-field-wrapper_input]:h-7 [&_.text-field-wrapper>.text-field-icon]:size-3.5"

  defp size_class("small"),
    do: "[&_.text-field-wrapper_input]:h-8 [&_.text-field-wrapper>.text-field-icon]:size-4"

  defp size_class("medium"),
    do: "[&_.text-field-wrapper_input]:h-9 [&_.text-field-wrapper>.text-field-icon]:size-5"

  defp size_class("large"),
    do: "[&_.text-field-wrapper_input]:h-10 [&_.text-field-wrapper>.text-field-icon]:size-6"

  defp size_class("extra_large"),
    do: "[&_.text-field-wrapper_input]:h-12 [&_.text-field-wrapper>.text-field-icon]:size-7"

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.text-field-wrapper]:rounded-sm"
  defp rounded_size("small"), do: "[&_.text-field-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.text-field-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.text-field-wrapper]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.text-field-wrapper]:rounded-xl"
  defp rounded_size("full"), do: "[&_.text-field-wrapper]:rounded-full"
  defp rounded_size(_), do: "[&_.text-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.text-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.text-field-wrapper]:border"
  defp border_class("small"), do: "[&_.text-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.text-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.text-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.text-field-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "white", floating) do
    [
      "text-white [&_.text-field-wrapper:not(:has(.text-field-error))]:border-white",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-white focus-within:[&_.text-field-wrapper]:ring-white",
      floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#afafaf] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#afafaf]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#afafaf] focus-within:[&_.text-field-wrapper]:ring-[#afafaf]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#2441de] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#2441de]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.text-field-wrapper]:ring-[#2441de]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#877C7C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#877C7C]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.text-field-wrapper]:ring-[#877C7C]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#047857] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#047857]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.text-field-wrapper]:ring-[#047857]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#FF8B08] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FF8B08]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.text-field-wrapper]:ring-[#FF8B08]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#E73B3B] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#E73B3B]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.text-field-wrapper]:ring-[#E73B3B]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#004FC4] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#004FC4]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.text-field-wrapper]:ring-[#004FC4]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#52059C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#52059C]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.text-field-wrapper]:ring-[#52059C]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#4D4137] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#4D4137]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.text-field-wrapper]:ring-[#4D4137]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "light", floating) do
    [
      "text-[#707483] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#707483]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.text-field-wrapper]:ring-[#707483]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dark", floating) do
    [
      "text-[#1E1E1E] [&_.text-field-wrapper]:text-text-[#1E1E1E] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#050404]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.text-field-wrapper]:ring-[#050404]",
       floating && "[&_.text-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "white", _) do
    [
      "[&_.text-field-wrapper]:bg-white text-[#3E3E3E] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#DADADA]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.text-field-wrapper]:ring-[#DADADA]",
    ]
  end

  defp color_variant("default", "primary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#2441de]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700 [&_.text-field-wrapper]:text-white",
      "[&_.text-field-wrapper>input]:placeholder:text-white focus-within:[&_.text-field-wrapper]:ring-[#2441de]",
    ]
  end

  defp color_variant("default", "secondary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#877C7C]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700 [&_.text-field-wrapper]:text-white",
      "[&_.text-field-wrapper>input]:placeholder:text-white focus-within:[&_.text-field-wrapper]:ring-[#877C7C]",
    ]
  end

  defp color_variant("default", "success", _) do
    [
      "[&_.text-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#6EE7B7]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.text-field-wrapper]:ring-[#6EE7B7]",
    ]
  end

  defp color_variant("default", "warning", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FF8B08]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.text-field-wrapper]:ring-[#FF8B08]",
    ]
  end

  defp color_variant("default", "danger", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#E73B3B]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.text-field-wrapper]:ring-[#E73B3B]",
    ]
  end

  defp color_variant("default", "info", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#004FC4]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.text-field-wrapper]:ring-[#004FC4]",
    ]
  end

  defp color_variant("default", "misc", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#52059C]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.text-field-wrapper]:ring-[#52059C]",
    ]
  end

  defp color_variant("default", "dawn", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#4D4137]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.text-field-wrapper]:ring-[#4D4137]",
    ]
  end

  defp color_variant("default", "light", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#707483]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.text-field-wrapper]:ring-[#707483]",
    ]
  end

  defp color_variant("default", "dark", _) do
    [
      "[&_.text-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.text-field-wrapper]:text-white [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#050404]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper>input]:placeholder:text-white focus-within:[&_.text-field-wrapper]:ring-[#050404]",
    ]
  end

  defp color_variant("unbordered", "white", _) do
    [
      "[&_.text-field-wrapper]:bg-white [&_.text-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.text-field-wrapper]:border-transparent text-white",
      "[&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "secondary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.text-field-wrapper]:border-transparent text-white",
      "[&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "success", _) do
    [
      "[&_.text-field-wrapper]:bg-[#ECFEF3] [&_.text-field-wrapper]:border-transparent text-[#047857]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFF8E6] [&_.text-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6E6] [&_.text-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E5F0FF] [&_.text-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6FF] [&_.text-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFECDA] [&_.text-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E3E7F1] [&_.text-field-wrapper]:border-transparent text-[#707483]",
      "[&_.text-field-wrapper>input]:placeholder:text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark", _) do
    [
      "[&_.text-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.text-field-wrapper]:border-transparent text-white",
      "[&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "white", _) do
    [
      "[&_.text-field-wrapper]:bg-white text-[#3E3E3E] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#DADADA]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#4363EC]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "secondary", _) do
    [
      "[&_.text-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#6B6E7C]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "success", _) do
    [
      "[&_.text-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#047857]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#047857]"
    ]
  end

  defp color_variant("shadow", "warning", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FFF8E6]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#FF8B08]"
    ]
  end

  defp color_variant("shadow", "danger", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FFE6E6]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#E73B3B]"
    ]
  end

  defp color_variant("shadow", "info", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#E5F0FF]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#004FC4]"
    ]
  end

  defp color_variant("shadow", "misc", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FFE6FF]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#52059C]"
    ]
  end

  defp color_variant("shadow", "dawn", _) do
    [
      "[&_.text-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#FFECDA]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#4D4137]"
    ]
  end

  defp color_variant("shadow", "light", _) do
    [
      "[&_.text-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#E3E7F1]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-[#707483]"
    ]
  end

  defp color_variant("shadow", "dark", _) do
    [
      "[&_.text-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.text-field-wrapper:not(:has(.text-field-error))]:border-[#1E1E1E]",
      "[&_.text-field-wrapper.text-field-error]:border-rose-700",
      "[&_.text-field-wrapper]:shadow [&_.text-field-wrapper>input]:placeholder:text-white"
    ]
  end

  defp color_variant("transparent", "white", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#DADADA] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#DADADA]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#4363EC] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#047857] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#047857]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#FF8B08] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#E73B3B] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#004FC4] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#004FC4]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#52059C] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#52059C]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#4D4137] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#4D4137]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#707483] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#707483]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark", _) do
    [
      "[&_.text-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.text-field-wrapper]:border-transparent",
      "[&_.text-field-wrapper>input]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.text-field-wrapper]:ring-transparent"
    ]
  end
end
