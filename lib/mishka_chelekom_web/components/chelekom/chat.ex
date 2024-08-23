defmodule MishkaChelekom.Chat do
  use Phoenix.Component

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
    "gradient",
    "unbordered"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "light", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :rounded, :string, default: "extra_large", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :space, :string, default: "extra_small", doc: ""
  attr :position, :string, values: ["normal", "flipped"], default: "normal", doc: ""
  attr :padding, :string, default: "small", doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def chat(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex items-start gap-3",
        position_class(@position),
        rounded_size(@rounded, @position),
        border_class(@border),
        color_variant(@variant, @color),
        space_class(@space),
        padding_size(@padding),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :status, required: false do
    attr :time, :string
    attr :deliver, :string
  end

  slot :meta, required: false
  slot :inner_block, required: false, doc: ""

  def chat_section(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "chat-section-bubble leading-1.5",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <div :for={status <- @status} class="flex items-center justify-between gap-2 text-xs">
        <div :if={status[:time]}><%= status[:time] %></div>
        <div :if={status[:deliver]} class="font-semibold"><%= status[:deliver] %></div>
      </div>

      <div :for={meta <- @meta} class="flex items-center justify-between gap-2 text-xs">
        <%= render_slot(meta) %>
      </div>
    </div>
    """
  end

  defp position_class("normal"), do: "justify-start flex-row"
  defp position_class("flipped"), do: "justify-start flex-row-reverse"
  defp position_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-sm [&>.chat-section-bubble]:rounded-es-sm"
    ]
  end

  defp rounded_size("small", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e [&>.chat-section-bubble]:rounded-es"
    ]
  end

  defp rounded_size("medium", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-md [&>.chat-section-bubble]:rounded-es-md"
    ]
  end

  defp rounded_size("large", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-lg [&>.chat-section-bubble]:rounded-es-lg"
    ]
  end

  defp rounded_size("extra_large", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-xl [&>.chat-section-bubble]:rounded-es-xl"
    ]
  end

  defp rounded_size("extra_small", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-sm [&>.chat-section-bubble]:rounded-ee-sm"
    ]
  end

  defp rounded_size("small", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s [&>.chat-section-bubble]:rounded-ee"
    ]
  end

  defp rounded_size("medium", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-md [&>.chat-section-bubble]:rounded-ee-md"
    ]
  end

  defp rounded_size("large", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-lg [&>.chat-section-bubble]:rounded-ee-lg"
    ]
  end

  defp rounded_size("extra_large", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-xl [&>.chat-section-bubble]:rounded-ee-xl"
    ]
  end

  defp rounded_size(_, _), do: rounded_size("extra_large", "normal")

  defp space_class("extra_small"), do: "[&>.chat-section-bubble]:space-y-2"
  defp space_class("small"), do: "[&>.chat-section-bubble]:space-y-3"
  defp space_class("medium"), do: "[&>.chat-section-bubble]:space-y-4"
  defp space_class("large"), do: "[&>.chat-section-bubble]:space-y-5"
  defp space_class("extra_large"), do: "[&>.chat-section-bubble]:space-y-6"
  defp space_class(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "[&>.chat-section-bubble]:p-1"
  defp padding_size("small"), do: "[&>.chat-section-bubble]:p-2"
  defp padding_size("medium"), do: "[&>.chat-section-bubble]:p-3"
  defp padding_size("large"), do: "[&>.chat-section-bubble]:p-4"
  defp padding_size("extra_large"), do: "[&>.chat-section-bubble]:p-5"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp border_class("extra_small"), do: "[&>.chat-section-bubble]:border"
  defp border_class("small"), do: "[&>.chat-section-bubble]:border-2"
  defp border_class("medium"), do: "[&>.chat-section-bubble]:border-[3px]"
  defp border_class("large"), do: "[&>.chat-section-bubble]:border-4"
  defp border_class("extra_large"), do: "[&>.chat-section-bubble]:border-[5px]"
  defp border_class("none"), do: "[&>.chat-section-bubble]:border-0"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp size_class("extra_small"), do: "text-xs [&>.chat-section-bubble]:max-w-[12rem]"
  defp size_class("small"), do: "text-sm [&>.chat-section-bubble]:max-w-[14rem]"
  defp size_class("medium"), do: "text-base [&>.chat-section-bubble]:max-w-[16rem]"
  defp size_class("large"), do: "text-lg [&>.chat-section-bubble]:max-w-[18rem]"
  defp size_class("extra_large"), do: "text-xl [&>.chat-section-bubble]:max-w-[20rem]"
  defp size_class(_), do: size_class("medium")

  defp color_variant("default", "white") do
    "[&>.chat-section-bubble]:bg-white text-[#3E3E3E] [&>.chat-section-bubble]:border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "[&>.chat-section-bubble]:bg-[#4363EC] text-white [&>.chat-section-bubble]:border-[#F6F6FA]"
  end

  defp color_variant("default", "secondary") do
    "[&>.chat-section-bubble]:bg-[#6B6E7C] text-white [&>.chat-section-bubble]:border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "[&>.chat-section-bubble]:bg-[#ECFEF3] text-[#047857] [&>.chat-section-bubble]:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "[&>.chat-section-bubble]:bg-[#FFF8E6] text-[#FF8B08] [&>.chat-section-bubble]:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "[&>.chat-section-bubble]:bg-[#FFE6E6] text-[#E73B3B] [&>.chat-section-bubble]:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "[&>.chat-section-bubble]:bg-[#E5F0FF] text-[#004FC4] [&>.chat-section-bubble]:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "[&>.chat-section-bubble]:bg-[#FFE6FF] text-[#52059C] [&>.chat-section-bubble]:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "[&>.chat-section-bubble]:bg-[#FFECDA] text-[#4D4137] [&>.chat-section-bubble]:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "[&>.chat-section-bubble]:bg-[#E3E7F1] text-[#707483] [&>.chat-section-bubble]:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "[&>.chat-section-bubble]:bg-[#1E1E1E] text-white [&>.chat-section-bubble]:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "[&>.chat-section-bubble]:bg-transparent text-white [&>.chat-section-bubble]:border-white"
  end

  defp color_variant("outline", "primary") do
    "[&>.chat-section-bubble]:bg-transparent text-[#4363EC] [&>.chat-section-bubble]:border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "[&>.chat-section-bubble]:bg-transparent text-[#6B6E7C] [&>.chat-section-bubble]:border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "[&>.chat-section-bubble]:bg-transparent text-[#227A52] [&>.chat-section-bubble]:border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "[&>.chat-section-bubble]:bg-transparent text-[#FF8B08] [&>.chat-section-bubble]:border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "[&>.chat-section-bubble]:bg-transparent text-[#E73B3B] [&>.chat-section-bubble]:border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "[&>.chat-section-bubble]:bg-transparent text-[#004FC4] [&>.chat-section-bubble]:border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "[&>.chat-section-bubble]:bg-transparent text-[#52059C] [&>.chat-section-bubble]:border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "[&>.chat-section-bubble]:bg-transparent text-[#4D4137] [&>.chat-section-bubble]:border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "[&>.chat-section-bubble]:bg-transparent text-[#707483] [&>.chat-section-bubble]:border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "[&>.chat-section-bubble]:bg-transparent text-[#1E1E1E] [&>.chat-section-bubble]:border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "[&>.chat-section-bubble]:bg-white text-[#3E3E3E] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "[&>.chat-section-bubble]:bg-[#4363EC] text-white [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "[&>.chat-section-bubble]:bg-[#6B6E7C] text-white [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "[&>.chat-section-bubble]:bg-[#ECFEF3] text-[#047857] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "[&>.chat-section-bubble]:bg-[#FFF8E6] text-[#FF8B08] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "[&>.chat-section-bubble]:bg-[#FFE6E6] text-[#E73B3B] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "[&>.chat-section-bubble]:bg-[#E5F0FF] text-[#004FC4] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "[&>.chat-section-bubble]:bg-[#FFE6FF] text-[#52059C] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "[&>.chat-section-bubble]:bg-[#FFECDA] text-[#4D4137] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "[&>.chat-section-bubble]:bg-[#E3E7F1] text-[#707483] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "[&>.chat-section-bubble]:bg-[#1E1E1E] text-white [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("shadow", "white") do
    [
      "[&>.chat-section-bubble]:bg-white text-[#3E3E3E] [&>.chat-section-bubble]:border-[#DADADA]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&>.chat-section-bubble]:bg-[#4363EC] text-white [&>.chat-section-bubble]:border-[#4363EC]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&>.chat-section-bubble]:bg-[#6B6E7C] text-white [&>.chat-section-bubble]:border-[#6B6E7C]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&>.chat-section-bubble]:bg-[#AFEAD0] text-[#227A52] [&>.chat-section-bubble]:border-[#AFEAD0]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&>.chat-section-bubble]:bg-[#FFF8E6] text-[#FF8B08] [&>.chat-section-bubble]:border-[#FFF8E6]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&>.chat-section-bubble]:bg-[#FFE6E6] text-[#E73B3B] [&>.chat-section-bubble]:border-[#FFE6E6]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&>.chat-section-bubble]:bg-[#E5F0FF] text-[#004FC4] [&>.chat-section-bubble]:border-[#E5F0FF]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&>.chat-section-bubble]:bg-[#FFE6FF] text-[#52059C] [&>.chat-section-bubble]:border-[#FFE6FF]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&>.chat-section-bubble]:bg-[#FFECDA] text-[#4D4137] [&>.chat-section-bubble]:border-[#FFECDA]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "[&>.chat-section-bubble]:bg-[#E3E7F1] text-[#707483] [&>.chat-section-bubble]:border-[#E3E7F1]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "[&>.chat-section-bubble]:bg-[#1E1E1E] text-white [&>.chat-section-bubble]:border-[#1E1E1E]",
      "[&>.chat-section-bubble]:shadow-md"
    ]
  end

  defp color_variant("transparent", "white") do
    "[&>.chat-section-bubble]:bg-transparent text-white [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "[&>.chat-section-bubble]:bg-transparent text-[#4363EC] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "[&>.chat-section-bubble]:bg-transparent text-[#6B6E7C] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "success") do
    "[&>.chat-section-bubble]:bg-transparent text-[#227A52] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "[&>.chat-section-bubble]:bg-transparent text-[#FF8B08] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "[&>.chat-section-bubble]:bg-transparent text-[#E73B3B] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "info") do
    "[&>.chat-section-bubble]:bg-transparent text-[#6663FD] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "[&>.chat-section-bubble]:bg-transparent text-[#52059C] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "[&>.chat-section-bubble]:bg-transparent text-[#4D4137] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "light") do
    "[&>.chat-section-bubble]:bg-transparent text-[#707483] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "[&>.chat-section-bubble]:bg-transparent text-[#1E1E1E] [&>.chat-section-bubble]:border-transparent"
  end

  defp color_variant("gradient", "white") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#e9ecef]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#3E3E3E]"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#4363ec94]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#1E1E1E]"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#6B6E7C]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#1E1E1E]"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#ECFEF3]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#047857]"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#FFF8E6]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#FF8B08]"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#FFE6E6]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#E73B3B]"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#E5F0FF]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#6663FD]"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#FFE6FF]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#52059C]"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#FFECDA]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#4D4137]"
    ]
  end

  defp color_variant("gradient", "light") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#E3E7F1]",
      "[&>.chat-section-bubble]:to-[#F6F6FA] text-[#707483]"
    ]
  end

  defp color_variant("gradient", "dark") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-b [&>.chat-section-bubble]:from-[#000]",
      "[&>.chat-section-bubble]:to-[#777777] text-white"
    ]
  end
end
