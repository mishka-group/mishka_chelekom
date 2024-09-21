defmodule MishkaChelekom.RangeField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: "A unique identifier is used to manage state and interaction"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: ""
  attr :space, :string, default: "medium", doc: "Space between items"
  attr :size, :string, default: "extra_small", doc: ""
  attr :appearance, :string, default: "default", doc: "custom"
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
    doc: "a form field struct retrieved from the form for example: @form[:email]"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus)

  slot :range_value, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :position, :any, required: false
  end

  @spec range_field(map()) :: Phoenix.LiveView.Rendered.t()
  def range_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> range_field()
  end

  def range_field(%{appearance: "default"} = assigns) do
    ~H"""
    <div class={[
      width_class(@width),
      @class
    ]}>
      <.label for={@id}><%= @label %></.label>
      <div class="relative mb-8">
        <input type="range" value={@value} name={@name} id={@id} class="w-full" {@rest} />
        <span
          :for={{range_value, index} <- Enum.with_index(@range_value, 1)}
          id={"#{@id}-value-#{index}"}
          class={[
            "absolute block -bottom-6 text-sm",
            value_position(range_value[:position]),
            range_value[:class]
          ]}
        >
          <%= render_slot(range_value) %>
        </span>
      </div>
      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  def range_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      size_class(@size),
      width_class(@width),
      @class
    ]}>
      <.label for={@id}><%= @label %></.label>
      <div class="relative mb-8">
        <input
          type="range"
          value={@value}
          name={@name}
          id={@id}
          class={[
            "range-field bg-transparent cursor-pointer appearance-none disabled:opacity-50",
            "disabled:pointer-events-none focus:outline-none",
            "[&::-webkit-slider-runnable-track]:w-full [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-runnable-track]:bg-[#e6e6e6]",
            "[&::-webkit-slider-thumb]:-mt-0.5 [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:bg-white",
            "[&::-webkit-slider-thumb]:transition-all [&::-webkit-slider-thumb]:duration-200 [&::-webkit-slider-thumb]:ease-in-out",
            "[&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:bg-white",
            "[&::-moz-range-thumb]:border-4 [&::-moz-range-thumb]:rounded-full",
            "[&::-moz-range-thumb]:transition-all [&::-moz-range-thumb]:duration-200 [&::-moz-range-thumb]:ease-in-out",
            "[&::-webkit-slider-runnable-track]:rounded-full [&::-moz-range-track]:w-full",
            "[&::-moz-range-track]:bg-[#e6e6e6] [&::-moz-range-track]:rounded-full"
          ]}
          {@rest}
        />
        <span
          :for={{range_value, index} <- Enum.with_index(@range_value, 1)}
          id={"#{@id}-value-#{index}"}
          class={[
            "absolute block -bottom-6 text-sm",
            value_position(range_value[:position]),
            range_value[:class]
          ]}
        >
          <%= render_slot(range_value) %>
        </span>
      </div>
      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  attr :for, :string, default: nil
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
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

  defp value_position("start"), do: "start-0"
  defp value_position("end"), do: "end-0"
  defp value_position("middle"), do: "start-1/2"
  defp value_position("quarter"), do: "start-1/4"
  defp value_position("three-quarters"), do: "start-3/4"
  defp value_position("two-thirds"), do: "start-2/3 -translate-x-1/2 rtl:translate-x-1/2"
  defp value_position("one-thirds"), do: "start-1/3 -translate-x-1/2 rtl:translate-x-1/2"
  defp value_position(params) when is_binary(params), do: params
  defp value_position(_), do: value_position("start")

  defp width_class("half"), do: "[&_.range-field]:w-1/2"
  defp width_class("full"), do: "[&_.range-field]:w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp size_class("extra_small") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-2 [&_.range-field::-webkit-slider-thumb]:size-2.5",
      "[&_.range-field::-moz-range-track]:h-2 [&_.range-field::-moz-range-thumb]:size-2.5"
    ]
  end

  defp size_class("small") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-2.5 [&_.range-field::-webkit-slider-thumb]:size-3",
      "[&_.range-field::-moz-range-track]:h-2.5 [&_.range-field::-moz-range-thumb]:size-3"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-3 [&_.range-field::-webkit-slider-thumb]:size-3.5",
      "[&_.range-field::-moz-range-track]:h-3 [&_.range-field::-moz-range-thumb]:size-3.5"
    ]
  end

  defp size_class("large") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-3.5 [&_.range-field::-webkit-slider-thumb]:size-4",
      "[&_.range-field::-moz-range-track]:h-3.5 [&_.range-field::-moz-range-thumb]:size-4"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-4 [&_.range-field::-webkit-slider-thumb]:size-5",
      "[&_.range-field::-moz-range-track]:h-4 [&_.range-field::-moz-range-thumb]:size-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp color_class("white") do
    [
      "[&_.range-field::-moz-range-thumb]:border-white",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(255,255,255,1)]"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#2441de]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(36,65,222,1)]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#047857]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(135,124,124,1)]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#047857]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(4,120,87,1)]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#FF8B08]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(255,139,8,1)]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#E73B3B]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(231,59,59,1)]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#004FC4]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(0,79,196,1)]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#52059C]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(82,5,156,1)]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#4D4137]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(77,65,55,1)]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#707483]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(112,116,131,1)]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#050404]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(5,4,4,1)]"
    ]
  end
end
