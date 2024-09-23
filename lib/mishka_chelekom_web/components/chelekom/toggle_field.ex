defmodule MishkaChelekom.ToggleField do
  @moduledoc """
  A component that renders a toggle field with customizable options.

  This module provides functionality for creating a toggle switch UI element
  that can be integrated into forms. It supports various attributes to tailor
  the appearance and behavior of the toggle, including size, color, and error handling.

  The toggle field includes support for accessibility features and can display
  error messages when validation fails. It is designed to be used within
  Phoenix LiveView applications, enabling dynamic interactions.
  """
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc """
  The `toggle_field` component is a customizable toggle switch input, often used for binary on/off
  choices like enabling or disabling a feature.

  ## Examples

  ```elixir
  <.toggle_field id="name1" color="danger" label="This is label" />

  <.toggle_field id="name2" color="dark" label="This is label" size="extra_large"/>

  <.toggle_field id="name3" color="warning" label="This is label" size="extra_small" checked={true} />

  <.toggle_field id="name4" color="success" label="This is label" size="small"/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :space, :string, default: "medium", doc: "Space between items"
  attr :labe_class, :string, default: nil, doc: "Determines the labe class"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :checked, :boolean, default: false, doc: ""

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form indeterminate checked multiple readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

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
