defmodule MishkaChelekom.Divider do
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["dashed", "dotted", "solid"], default: "solid", doc: ""
  attr :color, :string, values: @colors, default: "light", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""

  slot :text, required: false do
    attr :class, :string
    attr :color, :string
    attr :size, :string
    attr :position, :string
  end

  slot :icon, required: false do
    attr :name, :string, required: true
    attr :class, :string
    attr :icon_class, :string
    attr :color, :string
    attr :size, :string
    attr :position, :string
  end

  attr :class, :string, default: nil, doc: ""
  attr :rest, :global

  def divider(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            "has-[.divider-content]:flex before:has-[.divider-content.devider-middle]:content-none before:has-[.divider-content.devider-middle]:block before:has-[.divider-content.devider-middle]:h-1 before:has-[.divider-content.devider-middle]:w-full before:has-[.divider-content.devider-middle]:bg-black",
            color_class(@color),
            border_type_class(@type),
            width_class(@width),
            size_class(@size),
            @class
          ]
      }
      {@rest}
    >
      <div
        :for={icon <- @icon}
        class={[
          "divider-content whitespace-nowrap",
          icon[:size] || size_class(@size, :icon),
          icon[:color] || color_class(@color),
          icon[:class] || "bg-transparent",
          text_position(:divider, icon[:position])
        ]}
      >
        <.icon name={icon[:name]} class={icon[:icon_class] || ""} />
      </div>
       <%!-- Text --%>
      <div
        :for={text <- @text}
        class={[
          "divider-content whitespace-nowrap",
          text[:color] || color_class(@color),
          text[:class] || "bg-transparent",
          text_position(:divider, text[:position]),
          text[:size]
        ]}
      >
        <%= render_slot(text) %>
      </div>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["dashed", "dotted", "solid"], default: "solid", doc: ""
  attr :color, :string, values: @colors, default: "light", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""

  slot :text, required: false do
    attr :class, :string
    attr :color, :string
    attr :size, :string
    attr :position, :string
  end

  slot :icon, required: false do
    attr :name, :string, required: true
    attr :class, :string
    attr :icon_class, :string
    attr :color, :string
    attr :size, :string
  end

  attr :class, :string, default: nil, doc: ""
  attr :rest, :global

  def hr(assigns) do
    ~H"""
    <div class="relative">
      <hr
        id={@id}
        class={
          default_classes() ++
            [
              color_class(@color),
              border_type_class(@type),
              width_class(@width),
              size_class(@size),
              @class
            ]
        }
        {@rest}
      /> <%!-- Icon --%>
      <div
        :for={icon <- @icon}
        class={[
          "flex item-center justify-center absolute p-2",
          "-translate-x-1/2 whitespace-nowrap",
          icon[:size] || size_class(@size, :icon),
          icon[:color] || color_class(@color),
          icon[:class] || "bg-white"
        ]}
      >
        <.icon name={icon[:name]} class={icon[:icon_class] || ""} />
      </div>
       <%!-- Text --%>
      <div
        :for={text <- @text}
        class={[
          "flex item-center justify-center absolute p-2",
          "-translate-x-1/2 whitespace-nowrap",
          text[:color] || color_class(@color),
          text[:class] || "bg-white",
          text_position(:hr, text[:position]),
          text[:size]
        ]}
      >
        <%= render_slot(text) %>
      </div>
    </div>
    """
  end

  defp size_class("extra_small"), do: "[&:not(:has(.divider-content))]:border-t text-xs my-2"
  defp size_class("small"), do: "[&:not(:has(.divider-content))]:border-t-2 text-sm my-3"
  defp size_class("medium"), do: "[&:not(:has(.divider-content))]:border-t-[3px] text-base my-4"
  defp size_class("large"), do: "[&:not(:has(.divider-content))]:border-t-4 text-lg my-5"
  defp size_class("extra_large"), do: "[&:not(:has(.divider-content))]:border-t-[5px] text-xl my-6"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp size_class("extra_small", :icon), do: "[&>*]:size-5"
  defp size_class("small", :icon), do: "[&>*]:size-6"
  defp size_class("medium", :icon), do: "[&>*]:size-7"
  defp size_class("large", :icon), do: "[&>*]:size-8"
  defp size_class("extra_large", :icon), do: "[&>*]:size-9"
  defp size_class(params, :icon) when is_binary(params), do: params
  defp size_class(_, _), do: size_class("extra_small", :icon)

  defp width_class("full"), do: "w-full"
  defp width_class("half"), do: "w-1/2"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp color_class("white") do
    "border-white text-[#3E3E3E]"
  end

  defp color_class("primary") do
    "border-[#4363EC] text-[#4363EC]"
  end

  defp color_class("secondary") do
    "border-[#6B6E7C] text-[#6B6E7C]"
  end

  defp color_class("success") do
    "border-[#227A52] text-[#047857]"
  end

  defp color_class("warning") do
    "border-[#FF8B08] text-[#FF8B08]"
  end

  defp color_class("danger") do
    "border-[#E73B3B] text-[#E73B3B]"
  end

  defp color_class("info") do
    "border-[#6663FD] text-[#004FC4]"
  end

  defp color_class("misc") do
    "border-[#52059C] text-[#52059C]"
  end

  defp color_class("dawn") do
    "border-[#FFECDA] text-[#4D4137]"
  end

  defp color_class("light") do
    "border-[#707483] text-[#707483]"
  end

  defp color_class("dark") do
    "border-[#1E1E1E] text-[#1E1E1E]"
  end

  defp border_type_class("dashed") do
    "border-dashed"
  end

  defp border_type_class("dotted") do
    "border-dotted"
  end

  defp border_type_class("solid") do
    "border-solid"
  end

  defp text_position(:hr, "right") do
    "-top-1/2 -translate-y-1/2 -right-5"
  end

  defp text_position(:hr, "left") do
    "-top-1/2 -translate-y-1/2 left-0"
  end

  defp text_position(:hr, "middle") do
    "-top-1/2 -translate-y-1/2 left-1/2"
  end

  defp text_position(:hr, _), do: text_position(:hr, "middle")

  defp text_position(:divider, "right") do
    "devider-right"
  end

  defp text_position(:divider, "left") do
    "devider-left"
  end

  defp text_position(:divider, "middle") do
    "devider-middle"
  end

  defp text_position(:divider, _), do: text_position(:divider, "middle")

  defp default_classes() do
    [
      "mx-auto"
    ]
  end
end
