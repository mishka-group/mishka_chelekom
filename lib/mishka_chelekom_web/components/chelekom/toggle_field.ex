defmodule MishkaChelekom.ToggleField do
  use Phoenix.Component
  import MishkaChelekomComponents

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :description, :string, default: nil, doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :labe_class, :string, default: nil, doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :checked, :boolean, default: false, doc: ""
  attr :ring, :boolean, default: true, doc: ""
  attr :reverse, :boolean, default: false, doc: ""
  attr :error_icon, :string, default: nil, doc: ""
  attr :label, :string, default: nil

  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form indeterminate checked multiple readonly required title autofocus)

  @spec toggle_field(map()) :: Phoenix.LiveView.Rendered.t()
  def toggle_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> toggle_field()
  end

  def toggle_field(assigns) do
    ~H"""
    <div class={[
      size_class(@size),
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>
      <label for={@id} class="flex items-center cursor-pointer select-none w-fit">
        <div class="relative toggle-field-wrapper">
          <input type="checkbox" checked={@checked} id={@id} class="peer sr-only" />
          <div class={[
            "rounded-full bg-[#e6e6e6] transition-all ease-in-out duration-500 toggle-field-base",
            color_class(@color)
          ]}>
          </div>
          <div class={[
            "toggle-field-circle absolute transition-all ease-in-out duration-500 bg-white",
            "rounded-full top-1 peer-checked:translate-x-full left-1"
          ]}>
          </div>
        </div>
      </label>

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
      "[&_.toggle-field-base]:w-10 [&_.toggle-field-base]:h-6 [&_.toggle-field-circle]:size-4"
    ]
  end

  defp size_class("small") do
    [
      "[&_.toggle-field-base]:w-12 [&_.toggle-field-base]:h-7 [&_.toggle-field-circle]:size-5"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.toggle-field-base]:w-14 [&_.toggle-field-base]:h-8 [&_.toggle-field-circle]:size-6"
    ]
  end

  defp size_class("large") do
    [
      "[&_.toggle-field-base]:w-16 [&_.toggle-field-base]:h-9 [&_.toggle-field-circle]:size-7"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.toggle-field-base]:w-[72px] [&_.toggle-field-base]:h-10 [&_.toggle-field-circle]:size-8"
    ]
  end

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp color_class("white") do
    [
      "peer-checked:bg-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "peer-checked:bg-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "peer-checked:bg-[#877C7C]"
    ]
  end

  defp color_class("success") do
    [
      "peer-checked:bg-[#047857]"
    ]
  end

  defp color_class("warning") do
    [
      "peer-checked:bg-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "peer-checked:bg-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "peer-checked:bg-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "peer-checked:bg-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "peer-checked:bg-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "peer-checked:bg-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "peer-checked:bg-[#050404]"
    ]
  end
end
