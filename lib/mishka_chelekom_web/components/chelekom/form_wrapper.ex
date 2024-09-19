defmodule MishkaChelekom.FormWrapper do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, default: nil, doc: ""
  attr :variant, :string, default: nil, doc: ""
  attr :border, :string, default: nil, doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :padding, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :size, :string, default: nil, doc: ""

  attr :for, :any, required: false, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, required: false, doc: "the slot for form actions, such as a submit button"

  def form_wrapper(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@for}
      as={@as}
      {@rest}
      class={[
        color_variant(@variant, @color),
        padding_class(@padding),
        rounded_size(@rounded),
        border_class(@border),
        space_class(@space),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block, f) %>
      <div :for={action <- @actions}>
        <%= render_slot(action, f) %>
      </div>
    </.form>
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

  defp size_class(_), do: nil

  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(_), do: nil

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: nil

  defp padding_class("extra_small"), do: "p-2"
  defp padding_class("small"), do: "p-3"
  defp padding_class("medium"), do: "p-4"
  defp padding_class("large"), do: "p-5"
  defp padding_class("extra_large"), do: "p-6"
  defp padding_class(params) when is_binary(params), do: params
  defp padding_class(_), do: nil

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: nil

  defp color_variant("outline", "white") do
    [
      "text-[@dadada] border-white"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#afafaf] border-[#afafaf]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#2441de] border-[#2441de]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#877C7C] border-[#877C7C]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#047857] border-[#047857]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#FF8B08] border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#E73B3B] border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#004FC4] border-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#52059C] border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#4D4137] border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "text-[#707483] border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "text-[#1E1E1E] border-[#050404]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-[#4363EC] text-white"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#050404]"
    ]
  end

  defp color_variant("unbordered", "white") do
    [
      "bg-white border-transparent text-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    [
      "bg-[#4363EC] text-[#4363EC] border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "secondary") do
    [
      "bg-[#6B6E7C] text-[#6B6E7C] border-transparent text-white"
    ]
  end

  defp color_variant("unbordered", "success") do
    [
      "bg-[#ECFEF3] border-transparent text-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "bg-[#FFF8E6] border-transparent text-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "bg-[#FFE6E6] border-transparent text-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "bg-[#E5F0FF] border-transparent text-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "bg-[#FFE6FF] border-transparent text-[#52059C]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "bg-[#FFECDA] border-transparent text-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "bg-[#E3E7F1] border-transparent text-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    [
      "bg-[#1E1E1E] border-transparent text-white"
    ]
  end

  defp color_variant("shadow", "white") do
    [
      "bg-white text-[#3E3E3E] shadow"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#4363EC] text-[#4363EC] shadow"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#6B6E7C] text-[#6B6E7C] shadow"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#ECFEF3] text-[#227A52] shadow"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] shadow"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] shadow"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] shadow"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] shadow"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] shadow"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] shadow"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "bg-[#1E1E1E] text-[#1E1E1E] shadow"
    ]
  end

  defp color_variant(_, _), do: nil
end
