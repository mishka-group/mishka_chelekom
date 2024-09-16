defmodule MishkaChelekom.RangeField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :label_class, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :ring, :boolean, default: true, doc: ""
  attr :reverse, :boolean, default: false, doc: ""
  attr :checked, :boolean, default: false, doc: ""
  attr :error_icon, :string, default: nil, doc: ""
  attr :label, :string, default: nil

  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include: ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus)

  @spec range_field(map()) :: Phoenix.LiveView.Rendered.t()
  def range_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> range_field()
  end


  def range_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      size_class(@size),
      width_class(@width),
      @class
    ]}>
    <input
        type="range"
        class={[
          "range-field bg-transparent cursor-pointer appearance-none disabled:opacity-50",
          "disabled:pointer-events-none focus:outline-none [&::-webkit-slider-thumb]:size-2.5",
          "[&::-webkit-slider-runnable-track]:w-full [&::-webkit-slider-runnable-track]:bg-[#e6e6e6]",
          "[&::-webkit-slider-thumb]:-mt-0.5 [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:bg-white",
          "[&::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(37,99,235,1)] [&::-webkit-slider-thumb]:rounded-full",
          "[&::-webkit-slider-thumb]:transition-all [&::-webkit-slider-thumb]:duration-200 [&::-webkit-slider-thumb]:ease-in-out",
          "[&::-moz-range-thumb]:size-2.5 [&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:bg-white",
          "[&::-moz-range-thumb]:border-4 [&::-moz-range-thumb]:rounded-full",
          "[&::-moz-range-thumb]:transition-all [&::-moz-range-thumb]:duration-200 [&::-moz-range-thumb]:ease-in-out",
          "[&::-webkit-slider-runnable-track]:rounded-full [&::-moz-range-track]:w-full [&::-moz-range-track]:h-2",
          "[&::-moz-range-track]:bg-gray-100 [&::-moz-range-track]:rounded-full"
        ]}
        min="0"
        max="5"
        step="0.5"
      />
      <%!-- <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error> --%>
    </div>
    """
  end

  defp width_class("half"), do: "[&_.range-field]:w-1/2"
  defp width_class("full"), do: "[&_.range-field]:w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp size_class("extra_small"), do: "[&_.range-field::-webkit-slider-runnable-track]:h-2"
  defp size_class("small"), do: "[&_.range-field::-webkit-slider-runnable-track]:h-2.5"
  defp size_class("medium"), do: "[&_.range-field::-webkit-slider-runnable-track]:h-3"
  defp size_class("large"), do: "[&_.range-field::-webkit-slider-runnable-track]:h-3.5"
  defp size_class("extra_large"), do: "[&_.range-field::-webkit-slider-runnable-track]::h-4"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

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
      "[&_.range-field::-moz-range-thumb]:border-[#E73B3B]"
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
