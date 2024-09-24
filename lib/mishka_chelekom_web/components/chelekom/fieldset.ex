defmodule MishkaChelekom.Fieldset do
  @moduledoc """
  The `MishkaChelekom.FieldsetField` module provides a reusable and customizable
  component for creating styled fieldsets in Phoenix LiveView applications.

  It offers various options for styling, layout, and interaction, including:

  - Customizable color themes, border styles, and sizes.
  - Support for displaying error messages alongside form fields.
  - Flexible layout options using slots for adding controls and content inside the fieldset.
  - Global attributes support for enhanced configurability and integration.

  This component is designed to enhance the user interface of forms by providing consistent
  and visually appealing fieldsets that can be easily integrated into any LiveView application.
  """
  use Phoenix.Component

  @doc """
  Renders a `fieldset` component that groups related form elements visually and semantically.

  ## Examples

  ```elixir
  <.fieldset space="small" color="success" variant="outline">
    <:control>
      <.radio_field name="home" value="Home" space="small" color="success" label="This is label"/>
    </:control>

    <:control>
      <.radio_field
        name="home"
        value="Home"
        space="small"
        color="success"
        label="This is label of radio"
      />
    </:control>

    <:control>
      <.radio_field
        name="home"
        value="Home"
        space="small"
        color="success"
        label="This is label of radio"
      />
    </:control>
  </.fieldset>
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
  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :variant, :string, default: "outline", doc: "Determines the style"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :legend, :string, default: nil, doc: "Determines a caption for the content of its parent"

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :rest, :global,
    include: ~w(disabled form title),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :control, required: false, doc: "Defines a collection of elements inside the fieldset"

  def fieldset(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color),
      rounded_size(@rounded),
      border_class(@border),
      padding_class(@padding),
      size_class(@size),
      space_class(@space),
      @class
    ]}>
      <fieldset class="fieldset-field">
        <legend :if={@legend} for={@id}>{@legend}</legend>

        <div :for={{control, index} <- Enum.with_index(@control, 1)} id={"#{@id}-control-#{index}"}>
          <%= render_slot(control) %>
        </div>
      </fieldset>

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
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" /> <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp size_class("extra_small") do
    [
      "text-xs"
    ]
  end

  defp size_class("small") do
    [
      "text-sm"
    ]
  end

  defp size_class("medium") do
    [
      "text-base"
    ]
  end

  defp size_class("large") do
    [
      "text-lg"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl"
    ]
  end

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.fieldset-field]:rounded-sm"
  defp rounded_size("small"), do: "[&_.fieldset-field]:rounded"
  defp rounded_size("medium"), do: "[&_.fieldset-field]:rounded-md"
  defp rounded_size("large"), do: "[&_.fieldset-field]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.fieldset-field]:rounded-xl"
  defp rounded_size("full"), do: "[&_.fieldset-field]:rounded-full"
  defp rounded_size(_), do: "[&_.fieldset-field]:rounded-none"

  defp border_class("none"), do: "[&_.fieldset-field]:border-0"
  defp border_class("extra_small"), do: "[&_.fieldset-field]:border"
  defp border_class("small"), do: "[&_.fieldset-field]:border-2"
  defp border_class("medium"), do: "[&_.fieldset-field]:border-[3px]"
  defp border_class("large"), do: "[&_.fieldset-field]:border-4"
  defp border_class("extra_large"), do: "[&_.fieldset-field]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp padding_class("extra_small"), do: "[&_.fieldset-field]:p-2"
  defp padding_class("small"), do: "[&_.fieldset-field]:p-3"
  defp padding_class("medium"), do: "[&_.fieldset-field]:p-4"
  defp padding_class("large"), do: "[&_.fieldset-field]:p-5"
  defp padding_class("extra_large"), do: "[&_.fieldset-field]:p-6"
  defp padding_class(params) when is_binary(params), do: params
  defp padding_class(_), do: padding_class("medium")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "white") do
    [
      "text-white [&_.fieldset-field]:border-white"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#afafaf] [&_.fieldset-field]:border-[#afafaf]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#2441de] [&_.fieldset-field]:border-[#2441de]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#877C7C] [&_.fieldset-field]:border-[#877C7C]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#047857] [&_.fieldset-field]:border-[#047857]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#FF8B08] [&_.fieldset-field]:border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#E73B3B] [&_.fieldset-field]:border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#004FC4] [&_.fieldset-field]:border-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#52059C] [&_.fieldset-field]:border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#4D4137] [&_.fieldset-field]:border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "text-[#707483] [&_.fieldset-field]:border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "text-[#1E1E1E] [#1E1E1E] [&_.fieldset-field]:border-[#050404]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_.fieldset-field]:bg-white text-[#3E3E3E] [&_.fieldset-field]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.fieldset-field]:bg-[#4363EC] text-[#4363EC]",
      "[&_.fieldset-field]:text-white [&_.fieldset-field]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.fieldset-field]:bg-[#6B6E7C] text-[#6B6E7C] [&_.fieldset-field]:text-white",
      "[&_.fieldset-field]:border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.fieldset-field]:bg-[#ECFEF3] text-[#047857] [&_.fieldset-field]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.fieldset-field]:bg-[#FFF8E6] text-[#FF8B08] [&_.fieldset-field]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.fieldset-field]:bg-[#FFE6E6] text-[#E73B3B] [&_.fieldset-field]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.fieldset-field]:bg-[#E5F0FF] text-[#004FC4] [&_.fieldset-field]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.fieldset-field]:bg-[#FFE6FF] text-[#52059C] [&_.fieldset-field]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.fieldset-field]:bg-[#FFECDA] text-[#4D4137] [&_.fieldset-field]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&_.fieldset-field]:bg-[#E3E7F1] text-[#707483] [&_.fieldset-field]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.fieldset-field]:bg-[#1E1E1E] text-[#1E1E1E] [&_.fieldset-field]:text-white",
      "[&_.fieldset-field]:border-[#050404]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "[&_.fieldset-field]:bg-white [&_.fieldset-field]:border-transparent text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "[&_.fieldset-field]:bg-[#4363EC] text-[#4363EC] [&_.fieldset-field]:border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "[&_.fieldset-field]:bg-[#6B6E7C] text-[#6B6E7C] [&_.fieldset-field]:border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "[&_.fieldset-field]:bg-[#ECFEF3] [&_.fieldset-field]:border-transparent text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "[&_.fieldset-field]:bg-[#FFF8E6] [&_.fieldset-field]:border-transparent text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "[&_.fieldset-field]:bg-[#FFE6E6] [&_.fieldset-field]:border-transparent text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "[&_.fieldset-field]:bg-[#E5F0FF] [&_.fieldset-field]:border-transparent text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "[&_.fieldset-field]:bg-[#FFE6FF] [&_.fieldset-field]:border-transparent text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "[&_.fieldset-field]:bg-[#FFECDA] [&_.fieldset-field]:border-transparent text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "[&_.fieldset-field]:bg-[#E3E7F1] [&_.fieldset-field]:border-transparent text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "[&_.fieldset-field]:bg-[#1E1E1E] text-[#1E1E1E] [&_.fieldset-field]:border-transparent text-white"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "[&_.fieldset-field]:bg-white text-[#3E3E3E]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.fieldset-field]:bg-[#4363EC] text-[#4363EC]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.fieldset-field]:bg-[#6B6E7C] text-[#6B6E7C]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.fieldset-field]:bg-[#ECFEF3] text-[#227A52]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.fieldset-field]:bg-[#FFF8E6] text-[#FF8B08]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.fieldset-field]:bg-[#FFE6E6] text-[#E73B3B]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.fieldset-field]:bg-[#E5F0FF] text-[#004FC4]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.fieldset-field]:bg-[#FFE6FF] text-[#52059C]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.fieldset-field]:bg-[#FFECDA] text-[#4D4137]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&_.fieldset-field]:bg-[#E3E7F1] text-[#707483]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&_.fieldset-field]:bg-[#1E1E1E] text-[#1E1E1E]",
      "[&_.fieldset-field]:shadow"
    ]
  end

  defp color_variant("transparent", "white") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#DADADA] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#4363EC] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#6B6E7C] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#047857] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#FF8B08] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#E73B3B] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#004FC4] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#52059C] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#4D4137] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#707483] [&_.fieldset-field]:border-transparent"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "[&_.fieldset-field]:bg-transparent text-[#1E1E1E] [&_.fieldset-field]:border-transparent"
    ]
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
