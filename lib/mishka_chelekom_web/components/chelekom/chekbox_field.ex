defmodule MishkaChelekom.CheckboxField do
  @moduledoc """
  Provides a customizable checkbox component for use in Phoenix LiveView forms.

  This module includes individual checkbox fields as well as grouped
  checkbox fields, each with configurable options such as colors, borders,
  sizes, and more. It allows for easy integration and styling of checkboxes,
  with support for form validation and error handling.

  ### Features:
  - Individual and grouped checkbox fields with flexible styling options.
  - Support for form integration using `Phoenix.HTML.FormField`.
  - Customizable properties like color themes, border styles, sizes, and layout variations.
  - Error handling with customizable icons and messages.
  """

  use Phoenix.Component
  import MishkaChelekomComponents

  @doc """
  The `checkbox_field` component is used to create customizable checkbox input elements with various
  attributes such as `color`, `size`, and `label`.

  It supports form field structures and displays error messages when present, making it suitable
  for form validation.

  ## Examples

  ```elixir
  <.checkbox_field name="home" value="Home" space="small" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="misc" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="dawn" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="large" color="success" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="info" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="light" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="danger" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="warning" label="This is label"/>
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

  @spec checkbox_field(map()) :: Phoenix.LiveView.Rendered.t()
  def checkbox_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> checkbox_field()
  end

  def checkbox_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.checkbox-field-wrapper_input]:focus-within:ring-1",
      @reverse && "[&_.checkbox-field-wrapper]:flex-row-reverse",
      @class
    ]}>
      <.label class={["checkbox-field-wrapper flex items-center w-fit", @label_class]} for={@id}>
        <input
          type="checkbox"
          name={@name}
          id={@id}
          checked={@checked}
          class={[
            "bg-white checkbox-input"
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
  The `group_checkbox` component is used to create a group of checkboxes with customizable attributes
  such as `color`, `size`, and `variation`.

  It supports both horizontal and vertical layouts, and allows for individual styling of each
  checkbox within the group.

  ## Examples

  ```elixir
  <.group_checkbox id="items-2" variation="horizontal" name="items2" space="large" color="danger">
    <:checkbox value="10">Label of item 1 in group</:checkbox>
    <:checkbox value="30">Label of item 2 in group</:checkbox>
    <:checkbox value="50">Label of item 3 in group</:checkbox>
    <:checkbox value="60" checked={true}>Label of item 4 in group</:checkbox>
  </.group_checkbox>
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

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"

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

  slot :checkbox, required: true do
    attr :value, :string, required: true
    attr :checked, :boolean, required: false
    attr :space, :string, required: false, doc: "Space between items"
  end

  slot :inner_block

  def group_checkbox(assigns) do
    ~H"""
    <div class={[
      @variation == "horizontal" && "flex flex-wrap items-center",
      variation_gap(@space, @variation),
      @class
    ]}>
      <%= render_slot(@inner_block) %>
      <div
        :for={{checkbox, index} <- Enum.with_index(@checkbox, 1)}
        class={[
          color_class(@color),
          rounded_size(@rounded),
          border_class(@border),
          size_class(@size),
          space_class(checkbox[:space]),
          @ring && "[&_.checkbox-field-wrapper_input]:focus-within:ring-1",
          @reverse && "[&_.checkbox-field-wrapper]:flex-row-reverse"
        ]}
      >
        <.label
          class={["checkbox-field-wrapper flex items-center w-fit", @label_class]}
          for={"#{@id}-#{index}"}
        >
          <input
            type="checkbox"
            name={@name}
            id={"#{@id}-#{index}"}
            checked={checkbox[:checked]}
            class={[
              "bg-white checkbox-input"
            ]}
            {@rest}
          />
          <span class="block"><%= render_slot(checkbox) %></span>
        </.label>
      </div>
    </div>
    <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    """
  end

  @doc type: :component
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

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

  defp size_class("extra_small"), do: "[&_.checkbox-field-wrapper_input]:size-2.5"
  defp size_class("small"), do: "[&_.checkbox-field-wrapper_input]:size-3"
  defp size_class("medium"), do: "[&_.checkbox-field-wrapper_input]:size-3.5"
  defp size_class("large"), do: "[&_.checkbox-field-wrapper_input]:size-4"
  defp size_class("extra_large"), do: "[&_.checkbox-field-wrapper_input]:size-5"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-sm"
  defp rounded_size("small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded"
  defp rounded_size("medium"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-md"
  defp rounded_size("large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-xl"
  defp rounded_size("full"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-full"
  defp rounded_size(_), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-none"

  defp border_class("none"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-0"
  defp border_class("extra_small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border"
  defp border_class("small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-2"
  defp border_class("medium"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-[3px]"
  defp border_class("large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-4"
  defp border_class("extra_large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "[&_.checkbox-field-wrapper]:space-x-1"
  defp space_class("small"), do: "[&_.checkbox-field-wrapper]:space-x-1.5"
  defp space_class("medium"), do: "[&_.checkbox-field-wrapper]:space-x-2"
  defp space_class("large"), do: "[&_.checkbox-field-wrapper]:space-x-2.5"
  defp space_class("extra_large"), do: "[&_.checkbox-field-wrapper]:space-x-3"
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
      "[&_.checkbox-field-wrapper_.checkbox-input]:bg-white checked:[&_.checkbox-field-wrapper_.checkbox-input]:accent-[#3E3E3E]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#DADADA]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#DADADA]"
    ]
  end

  defp color_class("primary") do
    [
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#4363EC]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#2441de]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#2441de]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#6B6E7C]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#877C7C]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#877C7C]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#047857]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#6EE7B7]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#6EE7B7]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#FF8B08]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#FF8B08]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#FF8B08]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#E73B3B]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#E73B3B]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#E73B3B]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#004FC4]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#004FC4]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#004FC4]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#52059C]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#52059C]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#52059C]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#4D4137]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#4D4137]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#4D4137]"
    ]
  end

  defp color_class("light") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#707483]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#707483]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#707483]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#1E1E1E]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#050404]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#050404]"
    ]
  end
end
