defmodule MishkaChelekom.RadioField do
  @moduledoc """
  The `MishkaChelekom.RadioField` module provides a highly customizable radio button
  component for Phoenix LiveView applications. This module supports various styling options,
  including different colors, sizes, and border styles, allowing developers to
  integrate radio buttons seamlessly into their design system.

  The component offers attributes and slots to control layout, appearance, and behavior,
  making it versatile for use cases ranging from simple forms to complex UI elements.
  With features such as error handling and custom labels, it enhances the usability and
  accessibility of forms, ensuring a cohesive user experience across the application.

  In addition, the module includes support for grouped radio buttons with the `group_radio`
  component, enabling the creation of sets of related radio inputs. This facilitates the
  development of dynamic and interactive form elements in a clean and organized manner.
  """
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc """
  Renders a `radio_field` component. This component allows users to select a single option from
  a list of options, and provides various customization options for appearance and behavior.

  ## Examples

  ```elixir
  <.radio_field name="option" value="Option 1" space="small" label="Option 1 Label"/>

  <.radio_field
    name="option"
    value="Option 2"
    space="medium"
    color="secondary"
    label="Option 2 Label"
    checked
  />

  <.radio_field name="option" value="Option 3" color="dawn" label="Option 3 Label" reverse/>

  <.radio_field
    name="option"
    value="Option 4"
    space="medium"
    color="danger"
    label="Option 4 Label"
    errors={["Error message for Option 4"]}
  />

  <.radio_field name="option" value="Option 5" space="small" color="info" label="Option 5 Label"/>
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
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

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
    include: ~w(autocomplete disabled form checked multiple readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec radio_field(map()) :: Phoenix.LiveView.Rendered.t()
  def radio_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> radio_field()
  end

  def radio_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.radio-field-wrapper_input]:focus-within:ring-1",
      @reverse && "[&_.radio-field-wrapper]:flex-row-reverse",
      @class
    ]}>
      <.label class={["radio-field-wrapper flex items-center w-fit", @label_class]} for={@id}>
        <input
          type="radio"
          name={@name}
          id={@id}
          checked={@checked}
          class={[
            "bg-white radio-input rounded-full"
          ]}
          {@rest}
        />
        <span class="block"><%= @label %></span>
      </.label>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a `group_radio` component, allowing users to select a single option from a list of
  grouped options. This component provides flexibility in layout, appearance, and behavior.

  ## Examples

  ```elixir
  <.group_radio name="items_group_1" space="small">
    <:radio value="option1">Option 1</:radio>
    <:radio value="option2">Option 2</:radio>
    <:radio value="option3">Option 3</:radio>
    <:radio value="option4" checked>Option 4</:radio>
  </.group_radio>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :variation, :string,
    default: "vetrical",
    doc: "Defines the layout orientation of the component"

  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form indeterminate multiple readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :radio, required: true do
    attr :value, :string, required: true
    attr :checked, :boolean, required: false
    attr :space, :any, required: false, doc: "Space between items"
  end

  slot :inner_block

  def group_radio(assigns) do
    ~H"""
    <div class={[
      @variation == "horizontal" && "flex flex-wrap items-center",
      variation_gap(@space, @variation),
      @class
    ]}>
      <%= render_slot(@inner_block) %>
      <div
        :for={{radio, index} <- Enum.with_index(@radio, 1)}
        class={[
          color_class(@color),
          border_class(@border),
          size_class(@size),
          space_class(radio[:space]),
          @ring && "[&_.radio-field-wrapper_input]:focus-within:ring-1",
          @reverse && "[&_.radio-field-wrapper]:flex-row-reverse"
        ]}
      >
        <.label
          class={["radio-field-wrapper flex items-center w-fit", @label_class]}
          for={"#{@id}-#{index}"}
        >
          <input
            type="radio"
            name={@name}
            id={"#{@id}-#{index}"}
            checked={radio[:checked]}
            class={[
              "bg-white radio-input rounded-full"
            ]}
            {@rest}
          />
          <span class="block"><%= render_slot(radio) %></span>
        </.label>
      </div>
    </div>
    <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
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

  defp size_class("extra_small"), do: "[&_.radio-field-wrapper_input]:size-2.5"
  defp size_class("small"), do: "[&_.radio-field-wrapper_input]:size-3"
  defp size_class("medium"), do: "[&_.radio-field-wrapper_input]:size-3.5"
  defp size_class("large"), do: "[&_.radio-field-wrapper_input]:size-4"
  defp size_class("extra_large"), do: "[&_.radio-field-wrapper_input]:size-5"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp border_class("none"), do: "[&_.radio-field-wrapper_.radio-input]:border-0"
  defp border_class("extra_small"), do: "[&_.radio-field-wrapper_.radio-input]:border"
  defp border_class("small"), do: "[&_.radio-field-wrapper_.radio-input]:border-2"
  defp border_class("medium"), do: "[&_.radio-field-wrapper_.radio-input]:border-[3px]"
  defp border_class("large"), do: "[&_.radio-field-wrapper_.radio-input]:border-4"
  defp border_class("extra_large"), do: "[&_.radio-field-wrapper_.radio-input]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "[&_.radio-field-wrapper]:space-x-1"
  defp space_class("small"), do: "[&_.radio-field-wrapper]:space-x-1.5"
  defp space_class("medium"), do: "[&_.radio-field-wrapper]:space-x-2"
  defp space_class("large"), do: "[&_.radio-field-wrapper]:space-x-2.5"
  defp space_class("extra_large"), do: "[&_.radio-field-wrapper]:space-x-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp variation_gap("extra_small", "vertical"), do: "space-y-1"
  defp variation_gap("small", "vertical"), do: "space-y-2"
  defp variation_gap("medium", "vertical"), do: "space-y-3"
  defp variation_gap("large", "vertical"), do: "space-y-4"
  defp variation_gap("extra_large", "vertical"), do: "space-y-5"

  defp variation_gap("extra_small", "horizontal"), do: "space-x-1"
  defp variation_gap("small", "horizontal"), do: "space-x-2"
  defp variation_gap("medium", "horizontal"), do: "space-x-3"
  defp variation_gap("large", "horizontal"), do: "space-x-4"
  defp variation_gap("extra_large", "horizontal"), do: "space-x-5"

  defp variation_gap(_, params) when is_binary(params), do: params
  defp variation_gap(_, _), do: variation_gap("medium", "vertical")

  defp color_class("white") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-white text-[#DADADA]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#DADADA]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#4363EC] text-[#4363EC]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#2441de]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#6B6E7C] text-[#6B6E7C]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#877C7C]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#877C7C]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#047857] text-[#047857]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#6EE7B7]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#6EE7B7]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#FF8B08] text-[#FF8B08]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#FF8B08]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#E73B3B] text-[#E73B3B]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#E73B3B]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#004FC4] text-[#004FC4]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#004FC4]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#52059C] text-[#52059C]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#52059C]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#4D4137] text-[#4D4137]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#4D4137]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#707483] text-[#707483]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#707483]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#1E1E1E] text-[#1E1E1E]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#050404]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#050404]"
    ]
  end
end
