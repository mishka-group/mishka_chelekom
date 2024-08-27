defmodule MishkaChelekom.Overlay do
  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
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

  @opacities [
    "transparent",
    "translucent",
    "semi_transparent",
    "lightly_tinted",
    "tinted",
    "semi_opaque",
    "opaque",
    "heavily_tinted",
    "almost_solid"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :opacity, :string, values: @opacities ++ [nil], default: nil, doc: ""
  attr :blur, :string, values: @sizes ++ ["none", nil], default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  @spec overlay(map()) :: Phoenix.LiveView.Rendered.t()
  def overlay(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "absolute inset-0 z-50",
        color_class(@color),
        opacity_class(@opacity),
        blur_class(@blur),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp color_class("white") do
    "bg-white"
  end

  defp color_class("primary") do
    "bg-[#2441de]"
  end

  defp color_class("secondary") do
    "bg-[#877C7C]"
  end

  defp color_class("success") do
    "bg-[#6EE7B7]"
  end

  defp color_class("warning") do
    "bg-[#FF8B08]"
  end

  defp color_class("danger") do
    "bg-[#E73B3B]"
  end

  defp color_class("info") do
    "bg-[#004FC4]"
  end

  defp color_class("misc") do
    "bg-[#52059C]"
  end

  defp color_class("dawn") do
    "bg-[#4D4137]"
  end

  defp color_class("light") do
    "bg-[#707483]"
  end

  defp color_class("dark") do
    "bg-[#050404]"
  end

  defp color_class(params) when is_binary(params), do: params

  defp opacity_class("transparent") do
    "bg-opacity-10"
  end

  defp opacity_class("translucent") do
    "bg-opacity-20"
  end

  defp opacity_class("semi_transparent") do
    "bg-opacity-30"
  end

  defp opacity_class("lightly_tinted") do
    "bg-opacity-40"
  end

  defp opacity_class("tinted") do
    "bg-opacity-50"
  end

  defp opacity_class("semi_opaque") do
    "bg-opacity-60"
  end

  defp opacity_class("opaque") do
    "bg-opacity-70"
  end

  defp opacity_class("heavily_tinted") do
    "bg-opacity-80"
  end

  defp opacity_class("almost_solid") do
    "bg-opacity-90"
  end

  defp opacity_class("solid") do
    "bg-opacity-100"
  end

  defp opacity_class(params) when is_binary(params), do: params
  defp opacity_class(_), do: nil

  defp blur_class("extra_small") do
    "backdrop-blur-[1px]"
  end

  defp blur_class("small") do
    "backdrop-blur-[2px]"
  end

  defp blur_class("medium") do
    "backdrop-blur-[3px]"
  end

  defp blur_class("large") do
    "backdrop-blur-[4px]"
  end

  defp blur_class("extra_large") do
    "backdrop-blur-[5px]"
  end

  defp blur_class(params) when is_binary(params), do: params
  defp blur_class(_), do: nil
end
