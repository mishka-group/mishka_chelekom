defmodule MishkaChelekom.FileField do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :label_class, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :rounded, :string, default: "small", doc: ""
  attr :space, :string, default: "medium", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :error_icon, :string, default: nil, doc: ""
  attr :dropzone, :boolean, default: false, doc: ""
  attr :label, :string, default: nil
  attr :errors, :list, default: []
  attr :name, :any
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form for example: @form[:email]"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus)

  @spec file_field(map()) :: Phoenix.LiveView.Rendered.t()
  def file_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> file_field()
  end

  def file_field(%{dropzone: true} = assigns) do
    ~H"""

    """
  end

  def file_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      rounded_size(@rounded),
      space_class(@space),
      @class
    ]}>
      <.label for={@id}><%= @label %></.label>

      <input
        class="file-input block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
        type="file"
        {@rest}
      />
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

  defp rounded_size("extra_small"), do: "[&_.file-input]:rounded-sm"
  defp rounded_size("small"), do: "[&_.file-input]:rounded"
  defp rounded_size("medium"), do: "[&_.file-input]:rounded-md"
  defp rounded_size("large"), do: "[&_.file-input]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.file-input]:rounded-xl"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")


  defp color_class("white") do
    [
      "[&_.file-input]:bg-white file:[&_.file-input]:text-[#DADADA] file:[&_.file-input]:bg-[#DADADA]",
    ]
  end

  defp color_class("primary") do
    [
      "[&_.file-input]:bg-[#4363EC] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#2441de]",

    ]
  end

  defp color_class("secondary") do
    [
      "[&_.file-input]:bg-[#877C7C] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#6B6E7C]",
    ]
  end

  defp color_class("success") do
    [
      "[&_.file-input]:bg-[#ECFEF3] file:[&_.file-input]:text-white [&_.file-input]:text-[#047857] file:[&_.file-input]:bg-[#047857]",
    ]
  end

  defp color_class("warning") do
    [
      "[&_.file-input]:bg-[#FFF8E6] file:[&_.file-input]:text-white [&_.file-input]:text-[#FF8B08] file:[&_.file-input]:bg-[#FF8B08]",
    ]
  end

  defp color_class("danger") do
    [
      "[&_.file-input]:bg-[#FFE6E6] [&_.file-input]:text-[#E73B3B] file:[&_.file-input]:text-white file:[&_.file-input]:bg-[#E73B3B]",
    ]
  end

  defp color_class("info") do
    [
      "[&_.file-input]:bg-[#E5F0FF] file:[&_.file-input]:text-white [&_.file-input]:text-[#004FC4] file:[&_.file-input]:bg-[#004FC4]",
    ]
  end

  defp color_class("misc") do
    [
      "[&_.file-input]:bg-[#FFE6FF] file:[&_.file-input]:text-white [&_.file-input]:text-[#52059C] file:[&_.file-input]:bg-[#52059C]",

    ]
  end

  defp color_class("dawn") do
    [
      "[&_.file-input]:bg-[#FFECDA] file:[&_.file-input]:text-white [&_.file-input]:text-[#4D4137] file:[&_.file-input]:bg-[#4D4137]",
    ]
  end

  defp color_class("light") do
    [
      "[&_.file-input]:bg-[#E3E7F1] file:[&_.file-input]:text-white [&_.file-input]:text-[#707483] file:[&_.file-input]:bg-[#707483]",

    ]
  end

  defp color_class("dark") do
    [
      "[&_.file-input]:bg-[#383838] file:[&_.file-input]:text-white [&_.file-input]:text-white file:[&_.file-input]:bg-[#1E1E1E]",
    ]
  end
end
