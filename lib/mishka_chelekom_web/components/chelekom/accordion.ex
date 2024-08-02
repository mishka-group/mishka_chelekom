defmodule MishkaChelekom.Accordion do
  use Phoenix.Component
  import MishkaChelekomComponents

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
    "dawn",
    "transparent"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :space, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :color, :string, values: @colors ++ ["transparent"], default: "transparent", doc: ""

  slot :item, required: true do
    attr :title, :string, required: true
    attr :icon, :string
    attr :class, :string
    attr :icon_class, :string
    attr :content_class, :string
  end

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            "border [&>details:not(:last-child)>summary]:border-b",
            "[&>details:not(:last-child)>summary]:border-blue-300",
            "[&>details:not(:last-child)>:not(summary)]:border-b",
            "[&>details:not(:last-child)>:not(summary)]:border-blue-300 rounded-lg overflow-hidden",
            space_class(@space),
            border(@color),
            @class
          ]
      }
      {@rest}
    >
      <details
        :for={item <- @item}
        class={
          item[:class] || "cursor-pointer bg-white [&_.native-accordion-chevron]:open:rotate-90 group"
        }
      >
        <summary class="list-none p-5 font-bold flex flex-nowarp items-center justify-between gap-2">
          <div><%= item[:title] %></div>
          <.icon
            name={item[:icon] || "hero-chevron-right"}
            class={
              item[:icon_class] || "w-5 native-accordion-chevron transition ease-in-out duration-800"
            }
          />
        </summary>

        <div class={
          item[:content_class] ||
            "p-5 native-accordion-content max-h-0 overflow-hidden transition-[max-height] duration-1000 group-open:max-h-80"
        }>
          <%= render_slot(item) %>
        </div>
      </details>
    </div>
    """
  end

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class("none"), do: "space-y-0"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("small")

  defp border("transparent") do
    "border-transparent"
  end

  defp border("white") do
    "border-[#DADADA] hover:border-[#d9d9d9]"
  end

  defp border("primary") do
    "border-[#4363EC] hover:border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] hover:border-[#60636f]"
  end

  defp border("success") do
    "border-[#227A52] hover:border-[#d4fde4]"
  end

  defp border("warning") do
    "border-[#FF8B08] hover:border-[#fff1cd]"
  end

  defp border("danger") do
    "border-[#E73B3B] hover:border-[#ffcdcd]"
  end

  defp border("info") do
    "border-[#004FC4] hover:border-[#cce1ff]"
  end

  defp border("misc") do
    "border-[#52059C] hover:border-[#ffe0ff]"
  end

  defp border("dawn") do
    "border-[#4D4137] hover:border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] hover:border-[#d2d8e9]"
  end

  defp border("dark") do
    "border-[#1E1E1E] hover:border-[#111111]"
  end

  defp default_classes() do
    [
      ""
    ]
  end
end
