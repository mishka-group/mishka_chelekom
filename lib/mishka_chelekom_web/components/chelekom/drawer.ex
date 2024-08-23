defmodule MishkaChelekom.Drawer do
  use Phoenix.Component
  import MishkaChelekomComponents

  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn"
  ]

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :title, :string, default: nil
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :position, :string, default: "left", doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  # TODO: -translate-x-full (left), translate-x-full (right), translate-y-full (bottom), -translate-y-full (bottom)
  def drawer(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed z-50 p-2 overflow-y-auto transition-transform transform-none",
        size_class(@size),
        position_class(@position),
        border_class(@border, @position),
        color_variant(@variant, @color)
      ]}
      tabindex="-1"
      aria-labelledby="drawer-label"
    >
      <div class="flex flex-row-reverse justify-between items-center gap-5 mb-2">
        <button
          type="button"
          data-drawer-hide="drawer-example"
          aria-controls="drawer-example"
          class=""
        >
          <.icon name="hero-x-mark" />
          <span class="sr-only">Close menu</span>
        </button>
        <h5 :if={@title} id="drawer-label" class="text-base font-semibold">
          <%= @title %>
        </h5>
      </div>

      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp position_class("left"), do: "top-0 left-0 h-screen"
  defp position_class("right"), do: "top-0 right-0 h-screen"
  defp position_class("top"), do: "top-0 inset-x-0"
  defp position_class("bottom"), do: "bottom-0 inset-x-0"
  defp position_class(params) when is_binary(params), do: params
  defp position_class(_), do: position_class("left")

  defp border_class("none", _), do: "border-0"

  defp border_class("extra_small", "left"), do: "border-r"
  defp border_class("small", "left"), do: "border-r-2"
  defp border_class("medium", "left"), do: "border-r-[3px]"
  defp border_class("large", "left"), do: "border-r-4"
  defp border_class("extra_large", "left"), do: "border-r-[5px]"

  defp border_class("extra_small", "right"), do: "border-l"
  defp border_class("small", "right"), do: "border-l-2"
  defp border_class("medium", "right"), do: "border-l-[3px]"
  defp border_class("large", "right"), do: "border-l-4"
  defp border_class("extra_large", "right"), do: "border-l-[5px]"

  defp border_class("extra_small", "top"), do: "border-b"
  defp border_class("small", "top"), do: "border-b-2"
  defp border_class("medium", "top"), do: "border-b-[3px]"
  defp border_class("large", "top"), do: "border-b-4"
  defp border_class("extra_large", "top"), do: "border-b-[5px]"

  defp border_class("extra_small", "bottom"), do: "border-t"
  defp border_class("small", "bottom"), do: "border-t-2"
  defp border_class("medium", "bottom"), do: "border-t-[3px]"
  defp border_class("large", "bottom"), do: "border-t-4"
  defp border_class("extra_large", "bottom"), do: "border-t-[5px]"

  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: border_class("extra_small", "left")

  defp size_class("extra_small"), do: "w-60"
  defp size_class("small"), do: "w-64"
  defp size_class("medium"), do: "w-72"
  defp size_class("large"), do: "w-80"
  defp size_class("extra_large"), do: "w-96"
  defp size_class(_), do: size_class("large")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end
end
