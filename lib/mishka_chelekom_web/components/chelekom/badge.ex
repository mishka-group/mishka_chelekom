defmodule MishkaChelekom.Badge do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import MishkaChelekomComponents

  # TODO: Add text hover for links?
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

  @icon_positions [
    "right_icon",
    "left_icon",
    "top_left_icon",
    "top_center_icon",
    "top_right_icon",
    "middle_left_icon",
    "middle_right_icon",
    "bottom_left_icon",
    "bottom_center_icon",
    "bottom_right_icon"
  ]

  @indicator_positions [
    "indicator",
    "right_indicator",
    "left_indicator",
    "top_left_indicator",
    "top_center_indicator",
    "top_right_indicator",
    "middle_left_indicator",
    "middle_right_indicator",
    "bottom_left_indicator",
    "bottom_center_indicator",
    "bottom_right_indicator"
  ]

  @dismiss_positions ["dismiss", "right_dismiss", "left_dismiss"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :variant, :string,
    values: ["default", "outline", "transparent", "unbordered", "shadow"],
    default: "default",
    doc: ""

  attr :size, :string, default: "extra_small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""

  attr :rest, :global,
    include: ["is_pinging"] ++ @dismiss_positions ++ @indicator_positions ++ @icon_positions,
    doc: ""

  slot :inner_block, required: false, doc: ""

  def badge(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes(@rest[:is_pinging]) ++
          [
            color_variant(@variant, @color),
            rounded_size(@rounded),
            size_class(@size),
            @font_weight,
            @class
          ]
      }
      {@rest}
    >
      <.badge_dismiss :if={dismiss_position(@rest) == "left"} id={@id} />
      <span :if={indicator_position(@rest) == "left"} class="indicator" />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <span :if={indicator_position(@rest) == "right"} class="indicator" />
      <.badge_dismiss :if={dismiss_position(@rest) == "right"} id={@id} />
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :dismiss, :boolean, default: false
  attr :icon_class, :string, default: "size-4"

  defp badge_dismiss(assigns) do
    ~H"""
    <button phx-click={JS.push("dismiss", value: %{id: @id, kind: "badge"}) |> hide("##{@id}")}>
      <.icon name="hero-x-mark" class={"#{@icon_class}"} />
    </button>
    """
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] [&>.indicator]:bg-[#3E3E3E] hover:bg-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de] [&>.indicator]:bg-white hover:bg-[#072ed3] hover:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C] [&>.indicator]:bg-white hover:bg-[#60636f] hover:border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] [&>.indicator]:bg-[#047857] hover:bg-[#d4fde4] hover:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd] hover:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd] hover:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff] hover:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff] hover:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1] hover:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9] hover:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404] [&>.indicator]:bg-white hover:bg-[#111111] hover:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white [&>.indicator]:bg-white hover:text-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] [&>.indicator]:bg-[#4363EC] hover:text-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] [&>.indicator]:bg-[#6B6E7C] hover:text-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7] [&>.indicator]:bg-[#227A52] hover:text-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:text-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:text-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:text-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:text-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:text-[#FFECDA] hover:border-[#FFECDA]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:text-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] [&>.indicator]:bg-[#1E1E1E] hover:text-[#111111] hover:border-[#111111]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent [&>.indicator]:bg-[#3E3E3E] hover:bg-[#ededed]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent [&>.indicator]:bg-[#047857] hover:bg-[#d4fde4]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent [&>.indicator]:bg-white hover:bg-[#111111]"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent [&>.indicator]:bg-white hover:text-[#ededed]"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent [&>.indicator]:bg-[#4363EC] hover:text-[#072ed3]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent [&>.indicator]:bg-[#6B6E7C] hover:text-[#60636f]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent [&>.indicator]:bg-[#227A52] hover:text-[#d4fde4]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent [&>.indicator]:bg-[#FF8B08] hover:text-[#fff1cd]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent [&>.indicator]:bg-[#E73B3B] hover:text-[#ffcdcd]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent [&>.indicator]:bg-[#6663FD] hover:text-[#cce1ff]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent [&>.indicator]:bg-[#52059C] hover:text-[#ffe0ff]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent [&>.indicator]:bg-[#4D4137] hover:text-[#FFECDA]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent [&>.indicator]:bg-[#707483] hover:text-[#d2d8e9]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent [&>.indicator]:bg-[#1E1E1E] hover:text-[#111111]"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow [&>.indicator]:bg-[#3E3E3E] hover:bg-[#ededed] hover:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow [&>.indicator]:bg-white hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow [&>.indicator]:bg-white hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow [&>.indicator]:bg-[#227A52] hover:bg-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow [&>.indicator]:bg-[#FF8B08] hover:bg-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow [&>.indicator]:bg-[#E73B3B] hover:bg-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow [&>.indicator]:bg-[#004FC4] hover:bg-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow [&>.indicator]:bg-[#52059C] hover:bg-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow [&>.indicator]:bg-[#4D4137] hover:bg-[#ffdfc1] hover:border-[#ffdfc1]"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow [&>.indicator]:bg-[#707483] hover:bg-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow [&>.indicator]:bg-white hover:bg-[#111111] hover:border-[#111111]"
  end

  defp color_variant(_, _), do: color_variant("default", "white")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp size_class("extra_small"), do: "px-2 py-0.5 text-xs [&>.indicator]:size-1"
  defp size_class("small"), do: "px-2.5 py-1 text-sm [&>.indicator]:size-1.5"
  defp size_class("medium"), do: "px-2.5 py-1.5 text-base [&>.indicator]:size-2"
  defp size_class("large"), do: "px-3 py-2 text-lg [&>.indicator]:size-2.5"
  defp size_class("extra_large"), do: "px-3.5 py-2.5 text-xl [&>.indicator]:size-3"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"

  defp dismiss_position(%{right_dismiss: true}), do: "right"
  defp dismiss_position(%{left_dismiss: true}), do: "left"
  defp dismiss_position(%{dismiss: true}), do: "right"
  defp dismiss_position(_), do: false

  defp indicator_position(%{left_indicator: true}), do: "left"
  defp indicator_position(%{right_indicator: true}), do: "right"
  defp indicator_position(%{indicator: true}), do: "left"
  defp indicator_position(_), do: false

  defp default_classes(is_pinging) do
    [
      "inline-flex gap-1.5 justify-center items-center border",
      "[&>.indicator]:inline-block [&>.indicator]:shrink-0 [&>.indicator]:rounded-full",
      !is_nil(is_pinging) && "[&>.indicator]:animate-ping"
    ]
  end
end
