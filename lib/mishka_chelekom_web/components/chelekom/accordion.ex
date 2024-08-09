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
  attr :name, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :space, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :border, :string, values: @colors ++ ["transparent"], default: "transparent", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "medium", doc: ""
  attr :media_size, :string, values: @sizes, default: "small", doc: ""

  slot :item, required: true do
    attr :title, :string, required: true
    attr :description, :string
    attr :icon, :string
    attr :class, :string
    attr :image, :string
    attr :image_class, :string
    attr :icon_class, :string
    attr :content_class, :string
    attr :title_class, :string
    attr :summary_class, :string
  end

  attr :rest, :global, doc: ""

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            "overflow-hidden",
            space_class(@space),
            color_class(@color),
            padding_size(@padding),
            media_size(@media_size),
            @class
          ] ++ border(@border, @space)
      }
      {@rest}
    >
      <details :for={item <- @item} name={@name} class={["group", item[:class]]}>
        <summary class={[
          "w-full flex flex-nowrap items-center justify-between gap-2 group-open:mb-2",
          "cursor-pointer transition-[margin,background] duration-[250ms] ease-in-out list-none",
          item_color(@color),
          item[:summary_class]
        ]}>
          <div class="flex items-center gap-5">
            <%= if !is_nil(item[:image]) do %>
              <img class={["accordion-title-media shrink-0", item[:image_class]]} src={item[:image]} />
            <% end %>

            <%= if !is_nil(item[:icon]) do %>
              <.icon name={item[:icon]} class={item[:icon_class] || "accordion-title-media"} />
            <% end %>

            <div class={["space-y-2", item[:title_class]]}>
              <div><%= item[:title] %></div>

              <%= if !is_nil(item[:description]) do %>
                <div class="text-xs font-light">
                  <%= item[:description] %>
                </div>
              <% end %>
            </div>
          </div>
          <.icon
            name="hero-chevron-right"
            class="w-5 transition-transform duration-300 ease-in-out group-open:rotate-90"
          />
        </summary>

        <div class={[
          "shrink-0 transition-[opacity, translate] duration-1000 ease-in-out opacity-0 group-open:opacity-100",
          "-translate-y-4	group-open:translate-y-0",
          item[:content_class]
        ]}>
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

  defp media_size("extra_small"), do: "[&>details_.accordion-title-media]:size-12"
  defp media_size("small"), do: "[&>details_.accordion-title-media]:size-14"
  defp media_size("medium"), do: "[&>details_.accordion-title-media]:size-16"
  defp media_size("large"), do: "[&>details_.accordion-title-media]:size-20"
  defp media_size("extra_large"), do: "[&>details_.accordion-title-media]:size-24"
  defp media_size(params) when is_binary(params), do: params
  defp media_size(_), do: media_size("small")

  defp padding_size("extra_small"), do: "[&>details>*]:p-1"
  defp padding_size("small"), do: "[&>details>*]:p-2"
  defp padding_size("medium"), do: "[&>details>*]:p-3"
  defp padding_size("large"), do: "[&>details>*]:p-4"
  defp padding_size("extra_large"), do: "[&>details>*]:p-5"
  defp padding_size("none"), do: "[&>details>*]:p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp border("transparent", space) do
    ["border-0", space != "none" && "yechizi"]
  end

  defp border("white", space) do
    [
      "border border-[#DADADA]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#DADADA]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#DADADA]",
      space != "none" && "yechizi"
    ]
  end

  defp border("primary", space) do
    [
      "border border-[#4363EC]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#4363EC]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#4363EC]",
      space != "none" && "yechizi"
    ]
  end

  defp border("secondary", space) do
    [
      "border border-[#6B6E7C]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#6B6E7C]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#6B6E7C]",
      space != "none" && "yechizi"
    ]
  end

  defp border("success", space) do
    [
      "border border-[#227A52]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#227A52]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#227A52]",
      space != "none" && "yechizi"
    ]
  end

  defp border("warning", space) do
    [
      "border border-[#FF8B08]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#FF8B08]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#FF8B08]",
      space != "none" && "yechizi"
    ]
  end

  defp border("danger", space) do
    [
      "border border-[#E73B3B]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#E73B3B]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#E73B3B]",
      space != "none" && "yechizi"
    ]
  end

  defp border("info", space) do
    [
      "border border-[#004FC4]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#004FC4]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#004FC4]",
      space != "none" && "yechizi"
    ]
  end

  defp border("misc", space) do
    [
      "border border-[#52059C]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#52059C]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#52059C]",
      space != "none" && "yechizi"
    ]
  end

  defp border("dawn", space) do
    [
      "border border-[#4D4137]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#4D4137]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#4D4137]",
      space != "none" && "yechizi"
    ]
  end

  defp border("light", space) do
    [
      "border border-[#707483]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#707483]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#707483]",
      space != "none" && "yechizi"
    ]
  end

  defp border("dark", space) do
    [
      "border border-[#1E1E1E]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#1E1E1E]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#1E1E1E]",
      space != "none" && "yechizi"
    ]
  end

  defp color_class("white") do
    [
      "bg-white text-[#3E3E3E]",
      "[&>details>summary]:bg-white",
      "hover:[&>details>summary]:bg-[#E8E8E8]"
    ]
  end

  defp color_class("primary") do
    [
      "bg-[#4363EC] text-white",
      "[&>details>summary]:bg-[#4363EC]",
      "hover:[&>details>summary]:bg-[#072ed3]",
      "group-open:[&>details>summary]:bg-[#072ed3]"
    ]
  end

  defp color_class("secondary") do
    [
      "bg-[#6B6E7C] text-white",
      "group-open:bg-",
      "[&>details>summary]:bg-[#6B6E7C]",
      "hover:[&>details>summary]:bg-[#60636f]",
      "group-open:[&>details>summary]:bg-[#60636f]"
    ]
  end

  defp color_class("success") do
    [
      "bg-[#ECFEF3] text-[#047857]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#ECFEF3]",
      "hover:[&>details>summary]:bg-[#d4fde4]",
      "group-open:[&>details>summary]:bg-[#d4fde4]"
    ]
  end

  defp color_class("warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#FFF8E6]",
      "hover:[&>details>summary]:bg-[#fff1cd]",
      "group-open:[&>details>summary]:bg-[#fff1cd]"
    ]
  end

  defp color_class("danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#FFE6E6]",
      "hover:[&>details>summary]:bg-[#ffcdcd]",
      "group-open:[&>details>summary]:bg-[#ffcdcd]"
    ]
  end

  defp color_class("info") do
    [
      "bg-[#E5F0FF] text-[#004FC4]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#E5F0FF]",
      "hover:[&>details>summary]:bg-[#cce1ff]",
      "group-open:[&>details>summary]:bg-[#cce1ff]"
    ]
  end

  defp color_class("misc") do
    [
      "bg-[#FFE6FF] text-[#52059C]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#FFE6FF]",
      "hover:[&>details>summary]:bg-[#ffe0ff]",
      "group-open:[&>details>summary]:bg-[#ffe0ff]"
    ]
  end

  defp color_class("dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#FFECDA]",
      "hover:[&>details>summary]:bg-[#ffdfc1]",
      "group-open:[&>details>summary]:bg-[#ffdfc1]"
    ]
  end

  defp color_class("light") do
    [
      "bg-[#E3E7F1] text-[#707483]",
      "group-open:bg-",
      "[&>details>summary]:bg-[#E3E7F1]",
      "hover:[&>details>summary]:bg-[#d2d8e9]",
      "group-open:[&>details>summary]:bg-[#d2d8e9]"
    ]
  end

  defp color_class("dark") do
    [
      "bg-[#1E1E1E] text-white",
      "group-open:bg-",
      "[&>details>summary]:bg-[#1E1E1E]",
      "hover:[&>details>summary]:bg-[#111111]",
      "group-open:[&>details>summary]:bg-[#111111]"
    ]
  end

  defp item_color("white") do
    [
      "group-open:bg-[#E8E8E8]"
    ]
  end

  defp item_color("primary") do
    [
      "group-open:bg-[#072ed3]"
    ]
  end

  defp item_color("secondary") do
    [
      "group-open:bg-[#60636f]"
    ]
  end

  defp item_color("success") do
    [
      "group-open:bg-[#d4fde4]"
    ]
  end

  defp item_color("warning") do
    [
      "group-open:bg-[#fff1cd]"
    ]
  end

  defp item_color("danger") do
    [
      "group-open:bg-[#ffcdcd]"
    ]
  end

  defp item_color("info") do
    [
      "group-open:bg-[#cce1ff]"
    ]
  end

  defp item_color("misc") do
    [
      "group-open:bg-[#ffe0ff]"
    ]
  end

  defp item_color("dawn") do
    [
      "group-open:bg-[#ffdfc1]"
    ]
  end

  defp item_color("light") do
    [
      "group-open:bg-[#d2d8e9]"
    ]
  end

  defp item_color("dark") do
    [
      "group-open:bg-[#111111]"
    ]
  end

  defp default_classes() do
    [
      ""
    ]
  end
end
