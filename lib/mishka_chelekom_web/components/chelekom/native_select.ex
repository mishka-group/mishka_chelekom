defmodule MishkaChelekom.NativeSelect do
  @moduledoc """
  The `MishkaChelekom.NativeSelect` module provides a customizable native select component
  for forms in Phoenix LiveView. It supports a variety of styles, colors, and sizes, making
  it adaptable to different design requirements. The module allows for flexible configuration
  of the select element, including options for multi-selection, custom labels, and error handling.

  This component is highly versatile, with extensive theming options such as border styles,
  color variants, and rounded corners. It also provides a convenient way to render select
  options through slots, enabling dynamic rendering of form elements based on the passed data.

  With built-in error handling and custom error messages, `MishkaChelekom.NativeSelect`
  enhances the user experience by providing clear feedback and interaction states,
  ensuring a polished and user-friendly interface for form-based applications.
  """

  use Phoenix.Component
  import MishkaChelekomComponents

  @doc """
  Renders a customizable `native_select` input component with options for single or multiple selections.
  Supports validation and various styling options.

  ## Examples

  ```elixir
  <.native_select name="name" description="This is description" label="This is outline label">
    <:option value="usa">USA</:option>
    <:option value="uae" selected>UAE</:option>
  </.native_select>

  <.native_select
    name="name"
    space="small"
    color="danger"
    variant="default"
    multiple
    min_height="min-h-36"
    size="extra_small"
    description="This is multiple option group"
    label="This is outline label"
  >
    <.select_option_group label="group 1">
      <:option value="usa">USA</:option>
      <:option value="uae" selected>UAE</:option>
    </.select_option_group>

    <.select_option_group label="group 2">
      <:option value="usa">USA</:option>
      <:option value="uae">UAE</:option>
      <:option value="br" selected>Great Britain</:option>
    </.select_option_group>
  </.native_select>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "light", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, default: "native", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"
  attr :min_height, :string, default: nil, doc: "Determines min height style"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  attr :multiple, :boolean,
    default: false,
    doc: "Specifies if the select input allows multiple selections"

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :option, required: false do
    attr :value, :string, doc: "Value of each select option"
    attr :selected, :boolean, required: false, doc: "Specifies this option is seleted"
    attr :disabled, :string, required: false, doc: "Specifies this option is disabled"
  end

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form readonly multiple required title autofocus tabindex),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec native_select(map()) :: Phoenix.LiveView.Rendered.t()
  def native_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> native_select()
  end

  def native_select(assigns) do
    ~H"""
    <div class={[
      @variant != "native" && color_variant(@variant, @color),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.select-field]:focus-within:ring-[0.03rem]"
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>
      <select
        name={@name}
        id={@id}
        multiple={@multiple}
        class={[
          "select-field block w-full",
          @multiple && "select-multiple-option",
          @errors != [] && "select-field-error",
          @min_height,
          @class
        ]}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
        <option
          :for={{option, index} <- Enum.with_index(@option, 1)}
          id={"#{@id}-option-#{index}"}
          value={option[:value]}
          selected={option[:selected]}
          disabled={option[:disabled]}
        >
          <%= render_slot(option) %>
        </option>
      </select>
      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a group (`select_option_group`) of selectable options within a native select input.
  The group can have a label and multiple options, with support for selected and disabled states.

  ## Examples

  ```elixir
  <.select_option_group label="group 2">
    <:option value="usa">USA</:option>
    <:option value="uae">UAE</:option>
    <:option value="br" selected>Great Britain</:option>
  </.select_option_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  # TODO. this is not be used
  attr :separator, :boolean,
    default: nil,
    doc: "Whether separator is active for select option group"

  slot :option, required: false, doc: "Option slot for select" do
    attr :value, :string, doc: "Value of each select option"
    attr :selected, :boolean, required: false, doc: "Specifies this option is seleted"
    attr :disabled, :string, required: false, doc: "Specifies this option is disabled"
  end

  def select_option_group(assigns) do
    ~H"""
    <optgroup label={@label} class={@class}>
      <option
        :for={{option, index} <- Enum.with_index(@option, 1)}
        id={"#{@id}-option-#{index}"}
        value={option[:value]}
        selected={option[:selected]}
        disabled={option[:disabled]}
      >
        <%= render_slot(option) %>
      </option>
    </optgroup>
    <hr />
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

  defp size_class("extra_small") do
    [
      "text-xs [&_.select-field]:text-xs [&_.select-field:not(.select-multiple-option)]:h-9"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.select-field]:text-sm [&_.select-field:not(.select-multiple-option)]:h-10"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.select-field]:text-base [&_.select-field:not(.select-multiple-option)]:h-11"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.select-field]:text-lg [&_.select-field:not(.select-multiple-option)]:h-12"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.select-field]:text-xl [&_.select-field:not(.select-multiple-option)]:h-14"
    ]
  end

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.select-field]:rounded-sm"
  defp rounded_size("small"), do: "[&_.select-field]:rounded"
  defp rounded_size("medium"), do: "[&_.select-field]:rounded-md"
  defp rounded_size("large"), do: "[&_.select-field]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.select-field]:rounded-xl"
  defp rounded_size("full"), do: "[&_.select-field]:rounded-full"
  defp rounded_size(_), do: "[&_.select-field]:rounded-none"

  defp border_class("none"), do: "[&_.select-field]:border-0"
  defp border_class("extra_small"), do: "[&_.select-field]:border"
  defp border_class("small"), do: "[&_.select-field]:border-2"
  defp border_class("medium"), do: "[&_.select-field]:border-[3px]"
  defp border_class("large"), do: "[&_.select-field]:border-4"
  defp border_class("extra_large"), do: "[&_.select-field]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("default", "white") do
    [
      "[&_.select-field]:bg-white text-[#3E3E3E]",
      "focus-within:[&_.select-field]:ring-[#DADADA] [&_.select-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.select-field]:bg-[#4363EC] text-[#4363EC] [&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#2441de] [&_.select-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.select-field]:bg-[#6B6E7C] [&_.select-field]:text-white text-[#6B6E7C]",
      "focus-within:[&_.select-field]:ring-[#877C7C] [&_.select-field]:border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.select-field]:bg-[#ECFEF3] text-[#047857]",
      "focus-within:[&_.select-field]:ring-[#6EE7B7] [&_.select-field]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.select-field]:bg-[#FFF8E6] text-[#FF8B08]",
      "focus-within:[&_.select-field]:ring-[#FF8B08] [&_.select-field]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.select-field]:bg-[#FFE6E6] text-[#E73B3B]",
      "focus-within:[&_.select-field]:ring-[#E73B3B] [&_.select-field]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.select-field]:bg-[#E5F0FF] text-[#004FC4]",
      "[&_.select-field>input]:placeholder:text-[#004FC4] focus-within:[&_.select-field]:ring-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.select-field]:bg-[#FFE6FF] text-[#52059C]",
      "focus-within:[&_.select-field]:ring-[#52059C] [&_.select-field]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.select-field]:bg-[#FFECDA] text-[#4D4137]",
      "focus-within:[&_.select-field]:ring-[#4D4137] [&_.select-field]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&_.select-field]:bg-[#1E1E1E] [&_.select-field]:text-white text-[#707483]",
      "focus-within:[&_.select-field]:ring-[#707483] [&_.select-field]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.select-field]:bg-white text-[#1E1E1E] [&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#050404] [&_.select-field]:border-[#050404]"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "text-[#3E3E3E]",
      "focus-within:[&_.select-field]:ring-[#DADADA] [&_.select-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#4363EC]",
      "[&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#2441de] [&_.select-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#6B6E7C]",
      "[&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#877C7C] [&_.select-field]:border-[#877C7C]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#047857]",
      "focus-within:[&_.select-field]:ring-[#6EE7B7] [&_.select-field]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#FF8B08]",
      "focus-within:[&_.select-field]:ring-[#FF8B08] [&_.select-field]:border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#E73B3B]",
      "focus-within:[&_.select-field]:ring-[#E73B3B] [&_.select-field]:border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#004FC4]",
      "[&_.select-field>input]:placeholder:text-[#004FC4] focus-within:[&_.select-field]:ring-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#52059C]",
      "focus-within:[&_.select-field]:ring-[#52059C] [&_.select-field]:border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#4D4137]",
      "focus-within:[&_.select-field]:ring-[#4D4137] [&_.select-field]:border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "text-[#707483]",
      "focus-within:[&_.select-field]:ring-[#707483] [&_.select-field]:border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "text-[#1E1E1E] [&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#050404] [&_.select-field]:border-[#050404]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "[&_.select-field]:bg-white [&_.select-field]:border-transparent text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "[&_.select-field]:bg-[#4363EC] text-[#4363EC] [&_.select-field]:border-transparent text-white",
      "[&_.select-field>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "[&_.select-field]:bg-[#6B6E7C] text-[#6B6E7C] [&_.select-field]:border-transparent text-white",
      "[&_.select-field>input]:placeholder:text-white"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "[&_.select-field]:bg-[#ECFEF3] [&_.select-field]:border-transparent text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "[&_.select-field]:bg-[#FFF8E6] [&_.select-field]:border-transparent text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "[&_.select-field]:bg-[#FFE6E6] [&_.select-field]:border-transparent text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "[&_.select-field]:bg-[#E5F0FF] [&_.select-field]:border-transparent text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "[&_.select-field]:bg-[#FFE6FF] [&_.select-field]:border-transparent text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "[&_.select-field]:bg-[#FFECDA] [&_.select-field]:border-transparent text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "[&_.select-field]:bg-[#E3E7F1] [&_.select-field]:border-transparent text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "[&_.select-field]:bg-[#1E1E1E] text-[#1E1E1E] [&_.select-field]:border-transparent text-white",
      "[&_.select-field>input]:placeholder:text-white"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-white text-[#3E3E3E] [&_.select-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#4363EC] text-[#4363EC] [&_.select-field]:border-[#4363EC]"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#6B6E7C] text-[#6B6E7C] [&_.select-field]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#ECFEF3] text-[#227A52] [&_.select-field]:border-[#047857]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#FFF8E6] text-[#FF8B08] [&_.select-field]:border-[#FFF8E6]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#FFE6E6] text-[#E73B3B] [&_.select-field]:border-[#FFE6E6]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#E5F0FF] text-[#004FC4] [&_.select-field]:border-[#E5F0FF]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#FFE6FF] text-[#52059C] [&_.select-field]:border-[#FFE6FF]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#FFECDA] text-[#4D4137] [&_.select-field]:border-[#FFECDA]"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#E3E7F1] text-[#707483] [&_.select-field]:border-[#E3E7F1]"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&_.select-field]:shadow [&_.select-field]:bg-[#1E1E1E] [&_.select-field]:text-white text-[#1E1E1E] [&_.select-field]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", "white") do
    [
      "text-[#3E3E3E]",
      "focus-within:[&_.select-field]:ring-[#DADADA] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "text-[#4363EC]",
      "focus-within:[&_.select-field]:ring-[#2441de] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "text-[#6B6E7C]",
      "focus-within:[&_.select-field]:ring-[#877C7C] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "text-[#047857]",
      "focus-within:[&_.select-field]:ring-[#6EE7B7] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "text-[#FF8B08]",
      "focus-within:[&_.select-field]:ring-[#FF8B08] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "text-[#E73B3B]",
      "focus-within:[&_.select-field]:ring-[#E73B3B] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "text-[#004FC4]",
      "focus-within:[&_.select-field]:ring-[#004FC4] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "text-[#52059C]",
      "focus-within:[&_.select-field]:ring-[#52059C] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "text-[#4D4137]",
      "focus-within:[&_.select-field]:ring-[#4D4137] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "text-[#707483]",
      "focus-within:[&_.select-field]:ring-[#707483] [&_.select-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "text-[#1E1E1E] [&_.select-field]:text-white",
      "focus-within:[&_.select-field]:ring-[#050404] [&_.select-field]:border-transparent"
    ]
  end
end
