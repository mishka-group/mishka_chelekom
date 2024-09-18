defmodule MishkaChelekom.DateTimeField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "light", doc: ""

  attr :type, :string,
    values: ["date", "datetime-local", "time", "week", "month"],
    default: "date",
    doc: "date, datetime-local, time, week, month"

  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :variant, :string, default: "outline", doc: ""
  attr :description, :string, default: nil, doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_large", doc: ""
  attr :ring, :boolean, default: true, doc: ""
  attr :floating, :string, default: "none", doc: "none, inner, outer"
  attr :error_icon, :string, default: nil, doc: ""
  attr :label, :string, default: nil

  slot :start_section, required: false do
    attr :class, :string
    attr :icon, :string
  end

  slot :end_section, required: false do
    attr :class, :string
    attr :icon, :string
  end

  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global, include: ~w(disabled form min max readonly required step autofocus)

  @spec date_time_field(map()) :: Phoenix.LiveView.Rendered.t()
  def date_time_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> date_time_field()
  end

  def date_time_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.date-time-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        <%= @description %>
      </div>
      <div class={[
        "date-time-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "date-time-field-error"
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
            type={@type}
            name={@name}
            id={@id}
            value={@value}
            class={[
              "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-2.5 px-2",
              "text-sm appearance-none bg-transparent border-0 focus:outline-none peer"
            ]}
            placeholder="select a date "
            {@rest}
          />

          <label
            class={[
              "floating-label px-1 start-1 -z-[1] absolute text-xs duration-300 transform scale-75 origin-[0]",
              variant_label_position(@floating)
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

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  def date_time_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.date-time-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "date-time-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "date-time-field-error"
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
          type={@type}
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
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

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
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

  defp variant_label_position("outer") do
    [
      "-translate-y-4 top-2 origin-[0] peer-focus:px-1 peer-placeholder-shown:scale-100",
      "peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4",
      "rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp variant_label_position("inner") do
    [
      "-translate-y-4 scale-75 top-4 origin-[0] peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-4 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp size_class("extra_small") do
    [
      "[&_.date-time-field-wrapper_input]:h-7 [&_.date-time-field-wrapper>.date-time-field-icon]:size-3.5"
    ]
  end

  defp size_class("small") do
    [
      "[&_.date-time-field-wrapper_input]:h-8 [&_.date-time-field-wrapper>.date-time-field-icon]:size-4"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.date-time-field-wrapper_input]:h-9 [&_.date-time-field-wrapper>.date-time-field-icon]:size-5"
    ]
  end

  defp size_class("large") do
    [
      "[&_.date-time-field-wrapper_input]:h-10 [&_.date-time-field-wrapper>.date-time-field-icon]:size-6"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.date-time-field-wrapper_input]:h-12 [&_.date-time-field-wrapper>.date-time-field-icon]:size-7"
    ]
  end

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.date-time-field-wrapper]:rounded-sm"
  defp rounded_size("small"), do: "[&_.date-time-field-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.date-time-field-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.date-time-field-wrapper]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.date-time-field-wrapper]:rounded-xl"
  defp rounded_size("full"), do: "[&_.date-time-field-wrapper]:rounded-full"
  defp rounded_size(_), do: "[&_.date-time-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.date-time-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.date-time-field-wrapper]:border"
  defp border_class("small"), do: "[&_.date-time-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.date-time-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.date-time-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.date-time-field-wrapper]:border-[5px]"
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
      "text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-white",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#afafaf] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#afafaf]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#afafaf] focus-within:[&_.date-time-field-wrapper]:ring-[#afafaf]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#2441de] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#2441de]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.date-time-field-wrapper]:ring-[#2441de]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#877C7C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#877C7C]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.date-time-field-wrapper]:ring-[#877C7C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#047857] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#047857]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.date-time-field-wrapper]:ring-[#047857]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#FF8B08] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FF8B08]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.date-time-field-wrapper]:ring-[#FF8B08]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#E73B3B] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#E73B3B]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.date-time-field-wrapper]:ring-[#E73B3B]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#004FC4] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#004FC4]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.date-time-field-wrapper]:ring-[#004FC4]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#52059C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#52059C]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.date-time-field-wrapper]:ring-[#52059C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#4D4137] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#4D4137]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.date-time-field-wrapper]:ring-[#4D4137]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "light", floating) do
    [
      "text-[#707483] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#707483]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.date-time-field-wrapper]:ring-[#707483]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dark", floating) do
    [
      "text-[#1E1E1E] [&_.date-time-field-wrapper]:text-text-[#1E1E1E] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#050404]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.date-time-field-wrapper]:ring-[#050404]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-white text-[#3E3E3E] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#DADADA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.date-time-field-wrapper]:ring-[#DADADA]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#2441de]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700 [&_.date-time-field-wrapper]:text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-[#2441de]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#877C7C]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700 [&_.date-time-field-wrapper]:text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-[#877C7C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#6EE7B7]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.date-time-field-wrapper]:ring-[#6EE7B7]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FF8B08]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.date-time-field-wrapper]:ring-[#FF8B08]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#E73B3B]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.date-time-field-wrapper]:ring-[#E73B3B]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#004FC4]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.date-time-field-wrapper]:ring-[#004FC4]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#52059C]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.date-time-field-wrapper]:ring-[#52059C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#4D4137]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.date-time-field-wrapper]:ring-[#4D4137]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("default", "light", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#707483]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.date-time-field-wrapper]:ring-[#707483]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.date-time-field-wrapper]:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#050404]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-[#050404]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("unbordered", "white", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-white [&_.date-time-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("unbordered", "primary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.date-time-field-wrapper]:border-transparent text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("unbordered", "secondary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.date-time-field-wrapper]:border-transparent text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("unbordered", "success", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#ECFEF3] [&_.date-time-field-wrapper]:border-transparent text-[#047857]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("unbordered", "warning", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFF8E6] [&_.date-time-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("unbordered", "danger", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6E6] [&_.date-time-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("unbordered", "info", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E5F0FF] [&_.date-time-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("unbordered", "misc", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6FF] [&_.date-time-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("unbordered", "dawn", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFECDA] [&_.date-time-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("unbordered", "light", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E3E7F1] [&_.date-time-field-wrapper]:border-transparent text-[#707483]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("unbordered", "dark", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.date-time-field-wrapper]:border-transparent text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("shadow", "white", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-white text-[#3E3E3E] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#DADADA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#4363EC]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#6B6E7C]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#047857]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FFF8E6]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FFE6E6]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#E5F0FF]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FFE6FF]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FFECDA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("shadow", "light", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#E3E7F1]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("shadow", "dark", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#1E1E1E]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper]:shadow [&_.date-time-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", "white", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#DADADA] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#DADADA]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#4363EC] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#047857] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#047857]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#FF8B08] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#E73B3B] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#004FC4] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#004FC4]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#52059C] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#52059C]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#4D4137] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4D4137]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#707483] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#707483]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark", _) do
    [
      "[&_.date-time-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.date-time-field-wrapper]:border-transparent",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end
end