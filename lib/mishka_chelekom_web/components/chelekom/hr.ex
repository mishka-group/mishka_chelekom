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
  attr :color, :string, values: @colors, default: "white", doc: ""
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
        class="bg-neutral-200 text-neutral-400 absolute px-2 -top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2 whitespace-nowrap"
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
  defp size_class("large"), do: "border-t-[4px]"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_small")

  defp width_class("full"), do: "w-full"
  defp width_class("half"), do: "w/12"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp color("white") do
    "text-[#4363EC]"
  end

  defp color("primary") do
    "text-[#4363EC]"
  end

  defp color("secondary") do
    "text-[#6B6E7C]"
  end

  defp color("success") do
    "text-[#227A52]"
  end

  defp color("warning") do
    "text-[#FF8B08]"
  end

  defp color("danger") do
    "text-[#E73B3B]"
  end

  defp color("info") do
    "text-[#6663FD]"
  end

  defp color("misc") do
    "text-[#52059C]"
  end

  defp color("dawn") do
    "text-[#4D4137]"
  end

  defp color("light") do
    "text-[#707483]"
  end

  defp color("dark") do
    "text-[#1E1E1E]"
  end

  defp border_type_class("dashed") do
    ""
  end

  defp border_type_class("dotted") do
    ""
  end

  defp border_type_class("solid") do
    ""
  end

  defp default_classes() do
    [
      "my-5 border-gray-200 mx-auto"
    ]
  end
end
