defmodule MishkaChelekom.RangeField do
  @moduledoc """
  The `MishkaChelekom.RangeField` module provides a comprehensive range input field
  component for Phoenix LiveView applications. This component is designed with flexibility and
  customization in mind, allowing developers to configure various aspects such as size, color, and
  styling options.

  With attributes for managing state, interaction, and layout, the `RangeField` component can be
  easily adapted to different use cases, from simple form inputs to more complex data-driven interfaces.
  The module supports custom labels, error handling, and a range value slot for displaying dynamic
  content based on the input value.

  This component is particularly useful for scenarios that require user input in a defined range,
  such as sliders for adjusting numerical values or settings. It ensures a visually consistent
  and user-friendly experience across different parts of the application, while maintaining a
  high level of customization and control.
  """
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc """
  Renders a customizable range field, which allows users to select a numeric value from a defined range.
  The component can be styled in different ways and supports additional labels or values at specified positions.

  ## Examples

  ```elixir
  <.range_field
    appearance="custom"
    value="40"
    color="warning"
    size="small"
    min="10"
    id="custom-range-1"
    max="100"
    name="custom-range"
    step="5"
  >
    <:range_value position="start">Min ($100)</:range_value>
    <:range_value position="middle">$700</:range_value>
    <:range_value position="end">Max ($1500)</:range_value>
  </.range_field>

  <.range_field
    value="60"
    size="medium"
    color="primary"
    id="default-range-2"
    name="default-range-2"
    label="Primary Range"
  >
    <:range_value position="end">60%</:range_value>
  </.range_field>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :appearance, :string, default: "default", doc: "custom"
  attr :width, :string, default: "full", doc: "Determines the element width"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :checked, :boolean, default: false, doc: "Specifies if the element is checked by default"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :range_value, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :position, :any, required: false, doc: "Determines the element position"
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

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
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
