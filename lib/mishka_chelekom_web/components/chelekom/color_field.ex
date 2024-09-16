defmodule MishkaChelekom.ColorField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "white", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :description, :string, default: nil, doc: ""
  attr :size, :string, default: "extra_large", doc: ""
  attr :circle, :boolean, default: false, doc: ""
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
  attr :value, :any, default: "#000000"

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
      "w-fit",
      color_class(@color),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      @class
    ]}>
      <div class="mb-2">
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>
      <div class="color-field-wrapper">
        <input
          type="color"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "color-input"
          ]}
          {@rest}
        />
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

  defp size_class("extra_small") do
    [
      "[&_.color-field-wrapper_.color-input]:w-7 [&_.color-field-wrapper_.color-input]:h-4"
    ]
  end

  defp size_class("small") do
    [
      "[&_.color-field-wrapper_.color-input]:w-8 [&_.color-field-wrapper_.color-input]:h-5"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.color-field-wrapper_.color-input]:w-9 [&_.color-field-wrapper_.color-input]:h-6"
    ]
  end

  defp size_class("large") do
    [
      "[&_.color-field-wrapper_.color-input]:w-10 [&_.color-field-wrapper_.color-input]:h-7"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.color-field-wrapper_.color-input]:w-11 [&_.color-field-wrapper_.color-input]:h-8"
    ]
  end

  defp size_class("full"), do: "[&_.color-field-wrapper_.color-input]:w-full h-4"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.color-field-wrapper_.color-input]:rounded-sm"
  defp rounded_size("small"), do: "[&_.color-field-wrapper_.color-input]:rounded"
  defp rounded_size("medium"), do: "[&_.color-field-wrapper_.color-input]:rounded-md"
  defp rounded_size("large"), do: "[&_.color-field-wrapper_.color-input]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.color-field-wrapper_.color-input]:rounded-xl"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: "[&_.color-field-wrapper_.color-input]:rounded-none"

  defp border_class("none"), do: "[&_.color-field-wrapper_.color-input]:border-0"
  defp border_class("extra_small"), do: "[&_.color-field-wrapper_.color-input]:border"
  defp border_class("small"), do: "[&_.color-field-wrapper_.color-input]:border-2"
  defp border_class("medium"), do: "[&_.color-field-wrapper_.color-input]:border-[3px]"
  defp border_class("large"), do: "[&_.color-field-wrapper_.color-input]:border-4"
  defp border_class("extra_large"), do: "[&_.color-field-wrapper_.color-input]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp color_class("white") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#877C7C]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#6EE7B7]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.color-field-wrapper_.color-input]:border-[#050404]"
    ]
  end
end
