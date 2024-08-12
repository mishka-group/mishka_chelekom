defmodule MishkaChelekom.List do
  use Phoenix.Component
  import MishkaChelekomComponents

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "filled",
    "outline",
    "seperated",
    "tinted_split"
  ]

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

  attr :id, :string, default: nil, doc: ""
  attr :style, :string, default: "list-none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ul(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        @style,
        @font_weight,
        @class
      ]}
      {@rest}
    >
        <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  @spec li(map()) :: Phoenix.LiveView.Rendered.t()
  def li(assigns) do
    ~H"""
    <li
      id={@id}
      class={[
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ol(assigns) do
    ~H"""
    <ol class="list-decimal">
      <%= render_slot(@inner_block) %>
    </ol>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>

          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :space, :string, values: @sizes ++ [nil], default: "small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :border, :string, values: @sizes ++ [nil], default: "extra_small", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr(:rest, :global)

  slot :item, required: true do
    attr :icon, :string
    attr :class, :string
    attr :image, :string
    attr :image_class, :string
    attr :icon_class, :string
    attr :content_class, :string
    attr :position, :string, values: ["start", "end", "center"], doc: ""
  end

  def list_group(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "overflow-hidden",
        rounded_size(@rounded),
        space_class(@space, @variant),
        width_class(@width),
        border_class(@border, @variant),
        size_class(@size),
        color_variant(@variant, @color),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <MishkaChelekom.List.li
        :for={item <- @item}
        class={[
        "flex items-center gap-2",
        content_position(item[:position]),
        padding_size(@padding),
        item[:class]
      ] |> Enum.join(" ")}
      >
        <div :if={item[:icon]} class="">
          <.icon :if={!is_nil(item[:icon])} name={item[:icon]} class="list-group-icon" />
        </div>
        <div>
          <%= render_slot(item) %>
        </div>
      </MishkaChelekom.List.li>
    </ul>
    """
  end

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position(_), do: content_position("start")

  defp border_class(_, variant) when variant in ["seperated", "tinted_split"], do: "border-0"
  defp border_class("extra_small",_), do: "border"
  defp border_class("small",_), do: "border-2"
  defp border_class("medium",_), do: "border-[3px]"
  defp border_class("large",_), do: "border-4"
  defp border_class("extra_large",_), do: "border-[5px]"
  defp border_class("none",_), do: "border-0"
  defp border_class(params,_) when is_binary(params), do: params
  defp border_class(_, _), do: nil

  defp rounded_size("extra_small"), do: "[&:not(.list-items-gap)]:rounded-sm [&.list-items-gap>li]:rounded-sm"
  defp rounded_size("small"), do: "[&:not(.list-items-gap)]:rounded [&.list-items-gap>li]:rounded"
  defp rounded_size("medium"), do: "[&:not(.list-items-gap)]:rounded-md [&.list-items-gap>li]:rounded-md"
  defp rounded_size("large"), do: "[&:not(.list-items-gap)]:rounded-lg [&.list-items-gap>li]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&:not(.list-items-gap)]:rounded-xl [&.list-items-gap>li]:rounded-xl"
  defp rounded_size("full"), do: "[&:not(.list-items-gap)]:rounded-full [&.list-items-gap>li]:rounded:full"
  defp rounded_size("none"), do: "[&:not(.list-items-gap)]:rounded-none [&.list-items-gap>li]:rounded-none"

  defp space_class(_, variant) when variant not in ["seperated", "tinted_split"], do: nil
  defp space_class("extra_small", _), do: "list-items-gap space-y-2"
  defp space_class("small", _), do: "list-items-gap space-y-3"
  defp space_class("medium", _), do: "list-items-gap space-y-4"
  defp space_class("large", _), do: "list-items-gap space-y-5"
  defp space_class("extra_large", _), do: "list-items-gap space-y-6"
  defp space_class(params, _) when is_binary(params), do: params
  defp space_class(_, _), do: nil

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp size_class("extra_small"), do: "tex-xs [&_.list-group-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.list-group-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.list-group-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.list-group-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.list-group-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp color_variant("default", "white") do
    [
      "bg-white border border-[#DADADA]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]",
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]",
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]",
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]",
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]",
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]",
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]",
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]",
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]",
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]",
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]",
    ]
  end

  defp color_variant("outline", "white") do
    [
      "border border-[#DADADA]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]",
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]",
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]",
    ]
  end

  defp color_variant("outline", "success") do
    [
      "border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]",
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]",
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]",
    ]
  end

  defp color_variant("outline", "info") do
    [
      "border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]",
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]",
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]",
    ]
  end

  defp color_variant("outline", "light") do
    [
      "border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]",
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]",
    ]
  end

  defp color_variant("filled", "white") do
    [
      "[&>li]:bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "[&>li]:bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "[&>li]:bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "[&>li]:bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "[&>li]:bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "[&>li]:bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "[&>li]:bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "[&>li]:bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "[&>li]:bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "[&>li]:bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
    [
      "[&>li]:bg-[#1E1E1E] text-white"
    ]
  end

  defp color_variant("tinted_split", "white") do
    [
      "[&>li]:bg-white text-[#3E3E3E]",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "primary") do
    [
      "[&>li]:bg-[#4363EC] text-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "secondary") do
    [
      "[&>li]:bg-[#6B6E7C] text-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("tinted_split", "success") do
    [
      "[&>li]:bg-[#ECFEF3] text-[#047857]",
      "[&>li]:border [&>li]:border-[#227A52]"
    ]
  end

  defp color_variant("tinted_split", "warning") do
    [
      "[&>li]:bg-[#FFF8E6] text-[#FF8B08]",
      "[&>li]:border [&>li]:border-[#FF8B08]"
    ]
  end

  defp color_variant("tinted_split", "danger") do
    [
      "[&>li]:bg-[#FFE6E6] text-[#E73B3B]",
      "[&>li]:border [&>li]:border-[#E73B3B]"
    ]
  end

  defp color_variant("tinted_split", "info") do
    [
      "[&>li]:bg-[#E5F0FF] text-[#004FC4]",
      "[&>li]:border [&>li]:border-[#004FC4]"
    ]
  end

  defp color_variant("tinted_split", "misc") do
    [
      "[&>li]:bg-[#FFE6FF] text-[#52059C]",
      "[&>li]:border [&>li]:border-[#52059C]"
    ]
  end

  defp color_variant("tinted_split", "dawn") do
    [
      "[&>li]:bg-[#FFECDA] text-[#4D4137]",
      "[&>li]:border [&>li]:border-[#4D4137]"
    ]
  end

  defp color_variant("tinted_split", "light") do
    [
      "[&>li]:bg-[#E3E7F1] text-[#707483]",
      "[&>li]:border [&>li]:border-[#707483]"
    ]
  end

  defp color_variant("tinted_split", "dark") do
    [
      "[&>li]:bg-[#1E1E1E] text-white",
      "[&>li]:border [&>li]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("seperated", "white") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#DADADA]"
    ]
  end

  defp color_variant("seperated", "primary") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("seperated", "secondary") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#2441de]"
    ]
  end

  defp color_variant("seperated", "success") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#227A52]"
    ]
  end

  defp color_variant("seperated", "warning") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#FF8B08]"
    ]
  end

  defp color_variant("seperated", "danger") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#E73B3B]"
    ]
  end

  defp color_variant("seperated", "info") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#004FC4]"
    ]
  end

  defp color_variant("seperated", "misc") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#52059C]"
    ]
  end

  defp color_variant("seperated", "dawn") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#4D4137]"
    ]
  end

  defp color_variant("seperated", "light") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#707483]"
    ]
  end

  defp color_variant("seperated", "dark") do
    [
      "[&>li]:bg-white",
      "[&>li]:border [&>li]:border-[#1E1E1E]"
    ]
  end
end
