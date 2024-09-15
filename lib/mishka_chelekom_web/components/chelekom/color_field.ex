defmodule MishkaChelekom.ColorField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "white", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :variant, :string, default: "transparent", doc: ""
  attr :description, :string, default: nil, doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_large", doc: ""
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

  attr :rest, :global, include: ~w(autocomplete disabled form list min max pattern placeholder
        readonly required size inputmode inputmode step title autofocus)

  @spec color_field(map()) :: Phoenix.LiveView.Rendered.t()
  def color_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> color_field()
  end

  def color_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "number-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "number-field-error"
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
          type="color"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0",
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

  defp size_class("extra_small"),
    do:
      "[&_.number-field-wrapper_input]:h-7 [&_.number-field-wrapper_.password-field-icon]:size-3"

  defp size_class("small"),
    do:
      "[&_.number-field-wrapper_input]:h-8 [&_.number-field-wrapper_.password-field-icon]:size-3.5"

  defp size_class("medium"),
    do:
      "[&_.number-field-wrapper_input]:h-9 [&_.number-field-wrapper_.password-field-icon]:size-4"

  defp size_class("large"),
    do:
      "[&_.number-field-wrapper_input]:h-10 [&_.number-field-wrapper_.password-field-icon]:size-5"

  defp size_class("extra_large"),
    do:
      "[&_.number-field-wrapper_input]:h-11 [&_.number-field-wrapper_.password-field-icon]:size-6"

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.number-field-wrapper]:rounded-sm"
  defp rounded_size("small"), do: "[&_.number-field-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.number-field-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.number-field-wrapper]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.number-field-wrapper]:rounded-xl"
  defp rounded_size("full"), do: "[&_.number-field-wrapper]:rounded-full"
  defp rounded_size(_), do: "[&_.number-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.number-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.number-field-wrapper]:border"
  defp border_class("small"), do: "[&_.number-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.number-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.number-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.number-field-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "white") do
    [
      "text-white [&_.number-field-wrapper:not(:has(.number-field-error))]:border-white",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white focus-within:[&_.number-field-wrapper]:ring-white",
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#afafaf] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#afafaf]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#afafaf] focus-within:[&_.number-field-wrapper]:ring-[#afafaf]",
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#2441de] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#2441de]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.number-field-wrapper]:ring-[#2441de]",
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#877C7C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#877C7C]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.number-field-wrapper]:ring-[#877C7C]",
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#047857] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#047857]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.number-field-wrapper]:ring-[#047857]",
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#FF8B08] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FF8B08]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.number-field-wrapper]:ring-[#FF8B08]",
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#E73B3B] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#E73B3B]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.number-field-wrapper]:ring-[#E73B3B]",
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#004FC4] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#004FC4]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.number-field-wrapper]:ring-[#004FC4]",
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#52059C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#52059C]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.number-field-wrapper]:ring-[#52059C]",
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#4D4137] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#4D4137]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.number-field-wrapper]:ring-[#4D4137]",
    ]
  end

  defp color_variant("outline", "light") do
    [
      "text-[#707483] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#707483]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.number-field-wrapper]:ring-[#707483]",
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "text-[#1E1E1E] [&_.number-field-wrapper]:text-text-[#1E1E1E] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#050404]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.number-field-wrapper]:ring-[#050404]",
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_.number-field-wrapper]:bg-white text-[#3E3E3E] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#DADADA]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.number-field-wrapper]:ring-[#DADADA]",
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.number-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#2441de]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700 [&_.number-field-wrapper]:text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white focus-within:[&_.number-field-wrapper]:ring-[#2441de]",
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.number-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#877C7C]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700 [&_.number-field-wrapper]:text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white focus-within:[&_.number-field-wrapper]:ring-[#877C7C]",
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.number-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#6EE7B7]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.number-field-wrapper]:ring-[#6EE7B7]",
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.number-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FF8B08]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.number-field-wrapper]:ring-[#FF8B08]",
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#E73B3B]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.number-field-wrapper]:ring-[#E73B3B]",
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.number-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#004FC4]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.number-field-wrapper]:ring-[#004FC4]",
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#52059C]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.number-field-wrapper]:ring-[#52059C]",
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.number-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#4D4137]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.number-field-wrapper]:ring-[#4D4137]",
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&_.number-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#707483]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.number-field-wrapper]:ring-[#707483]",
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.number-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.number-field-wrapper]:text-white [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#050404]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white focus-within:[&_.number-field-wrapper]:ring-[#050404]",
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "[&_.number-field-wrapper]:bg-white [&_.number-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#3E3E3E]",
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "[&_.number-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.number-field-wrapper]:border-transparent text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "[&_.number-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.number-field-wrapper]:border-transparent text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "[&_.number-field-wrapper]:bg-[#ECFEF3] [&_.number-field-wrapper]:border-transparent text-[#047857]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#047857]",
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "[&_.number-field-wrapper]:bg-[#FFF8E6] [&_.number-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#FF8B08]",
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6E6] [&_.number-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#E73B3B]",
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "[&_.number-field-wrapper]:bg-[#E5F0FF] [&_.number-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#004FC4]",
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6FF] [&_.number-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#52059C]",
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "[&_.number-field-wrapper]:bg-[#FFECDA] [&_.number-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4D4137]",
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "[&_.number-field-wrapper]:bg-[#E3E7F1] [&_.number-field-wrapper]:border-transparent text-[#707483]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#707483]",
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "[&_.number-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.number-field-wrapper]:border-transparent text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "[&_.number-field-wrapper]:bg-white text-[#3E3E3E] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#DADADA]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#3E3E3E]",
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.number-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#4363EC]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.number-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#6B6E7C]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.number-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#047857]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#047857]",
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.number-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FFF8E6]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#FF8B08]",
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FFE6E6]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#E73B3B]",
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.number-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#E5F0FF]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#004FC4]",
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.number-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FFE6FF]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#52059C]",
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.number-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#FFECDA]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#4D4137]",
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&_.number-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#E3E7F1]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-[#707483]",
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&_.number-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#1E1E1E]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper]:shadow [&_.number-field-wrapper>input]:placeholder:text-white",
    ]
  end

  defp color_variant("transparent", "white") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#DADADA] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#DADADA]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#4363EC] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#047857] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#047857]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#FF8B08] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#E73B3B] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#004FC4] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#004FC4]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#52059C] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#52059C]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#4D4137] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4D4137]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#707483] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#707483]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "[&_.number-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.number-field-wrapper]:border-transparent",
      "[&_.number-field-wrapper>input]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end
end
