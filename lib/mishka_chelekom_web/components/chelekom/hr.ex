defmodule MishkaChelekom.Hr do
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
  attr :type, :string, values: ["default", "icon", "text"], default: "default", doc: ""
  attr :border_type, :string, values: ["dashed", "dotted", "solid"], default: "solid", doc: ""
  attr :color, :string, values: @colors, default: "light", doc: ""
  attr :size, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "full", doc: ""

  slot :text, required: false

  slot :icon, required: false do
    attr :name, :string, required: true
    attr :class, :string
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
              color(@color),
              border_type_class(@border_type),
              width_class(@width),
              size_class(@size),
              @class
            ]
        }
        {@rest}
      />
      <%!-- Icon --%>
      <div
        :for={icon <- @icon}
        class="bg-white absolute px-2 -top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2 whitespace-nowrap"
      >
        <.icon name={icon[:name]} class={icon[:class] || "w-5"} />
      </div>

      <%!-- Text --%>
      <div
        :for={text <- @text}
        class="bg-white absolute px-2 -top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2 whitespace-nowrap"
      >
        <%= render_slot(text) %>
      </div>
    </div>
    """
  end

  defp size_class("extra_small"), do: "border-t"
  defp size_class("small"), do: "border-t-2"
  defp size_class("medium"), do: "border-t-[3px]"
  defp size_class("large"), do: "border-t-4"
  defp size_class("extra_large"), do: "border-t-[5px]"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp width_class("full"), do: "w-full"
  defp width_class("half"), do: "w/12"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp color("white") do
    "border-white"
  end

  defp color("primary") do
    "border-[#4363EC]"
  end

  defp color("secondary") do
    "border-[#6B6E7C]"
  end

  defp color("success") do
    "border-[#227A52]"
  end

  defp color("warning") do
    "border-[#FF8B08]"
  end

  defp color("danger") do
    "border-[#E73B3B]"
  end

  defp color("info") do
    "border-[#6663FD]"
  end

  defp color("misc") do
    "border-[#52059C]"
  end

  defp color("dawn") do
    "border-[#4D4137]"
  end

  defp color("light") do
    "border-[#707483]"
  end

  defp color("dark") do
    "border-[#1E1E1E]"
  end

  defp border_type_class("dashed") do
    "border-dashed"
  end

  defp border_type_class("dotted") do
    "border-dashed"
  end

  defp border_type_class("solid") do
    "border-solid"
  end

  defp default_classes() do
    [
      "my-5 mx-auto"
    ]
  end
end
