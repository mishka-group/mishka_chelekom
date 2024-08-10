defmodule MishkaChelekom.Accordion do
  use Phoenix.Component
  import MishkaChelekomComponents

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "contained",
    "filled",
    "seperated"
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
    "dawn",
    "transparent"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :name, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :space, :string, values: @sizes, default: "small", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :border, :string, values: @colors ++ ["transparent"], default: "transparent", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "none", doc: ""
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
            space_class(@space, @variant),
            rounded_size(@rounded),
            padding_size(@padding),
            media_size(@media_size),
            @class
          ] ++ color_variant(@variant, @color)
      }
      {@rest}
    >
      <details :for={item <- @item} name={@name} class={["group", item[:class]]}>
        <summary class={[
          "w-full flex flex-nowrap items-center justify-between gap-2 group-open:mb-1",
          "cursor-pointer transition-[margin,background,text] duration-[250ms] ease-in-out list-none",
          item_color(@variant, @color),
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
          "-mt-1 shrink-0 transition-[opacity, translate] duration-1000 ease-in-out opacity-0 group-open:opacity-100",
          "-translate-y-4	group-open:translate-y-0",
          item_color(@variant, @color),
          item[:content_class]
        ]}>
          <%= render_slot(item) %>
        </div>
      </details>
    </div>
    """
  end

  defp space_class(_, variant) when variant != "seperated", do: nil
  defp space_class("extra_small", _), do: "accordion-item-gap space-y-2"
  defp space_class("small", _), do: "accordion-item-gap space-y-3"
  defp space_class("medium", _), do: "accordion-item-gap space-y-4"
  defp space_class("large", _), do: "accordion-item-gap space-y-5"
  defp space_class("extra_large", _), do: "accordion-item-gap space-y-6"
  defp space_class(params, _) when is_binary(params), do: params
  defp space_class(_, _), do: nil

  defp media_size("extra_small"), do: "[&>details_.accordion-title-media]:size-12"
  defp media_size("small"), do: "[&>details_.accordion-title-media]:size-14"
  defp media_size("medium"), do: "[&>details_.accordion-title-media]:size-16"
  defp media_size("large"), do: "[&>details_.accordion-title-media]:size-20"
  defp media_size("extra_large"), do: "[&>details_.accordion-title-media]:size-24"
  defp media_size(params) when is_binary(params), do: params
  defp media_size(_), do: media_size("small")

  defp rounded_size("extra_small"),
    do: "rounded-sm [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t-sm [&.accordion-item-gap>details]:rounded-sm [&.accordion-item-gap>details>*]:rounded-sm"

  defp rounded_size("small"), do: "rounded [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t [&.accordion-item-gap>details]:rounded [&.accordion-item-gap>details>*]:rounded"

  defp rounded_size("medium"),
    do: "rounded-md [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t-md [&.accordion-item-gap>details]:rounded-md [&.accordion-item-gap>details>*]:rounded-md"

  defp rounded_size("large"),
    do: "rounded-lg [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t-lg [&.accordion-item-gap>details]:rounded-lg [&.accordion-item-gap>details>*]:rounded-lg"

  defp rounded_size("extra_large"),
    do: "rounded-xl [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t-xl [&.accordion-item-gap>details]:rounded-xl [&.accordion-item-gap>details>*]:rounded-xl"

  defp rounded_size("none"),
    do: "rounded-none [&:not(.accordion-item-gap)>details:first-child>summary]:rounded-t-none [&.accordion-item-gap>details]:rounded-none [&.accordion-item-gap>details>*]:rounded-none"

  defp padding_size("extra_small"), do: "[&>details>*]:p-1"
  defp padding_size("small"), do: "[&>details>*]:p-2"
  defp padding_size("medium"), do: "[&>details>*]:p-3"
  defp padding_size("large"), do: "[&>details>*]:p-4"
  defp padding_size("extra_large"), do: "[&>details>*]:p-5"
  defp padding_size("none"), do: "[&>details>*]:p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp color_variant("default", "white") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#DADADA]",
      "hover:[&>details>summary]:bg-[#E8E8E8] hover:[&>details>summary]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#4363EC]",
      "hover:[&>details>summary]:bg-[#072ed3] hover:[&>details>summary]:text-white"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#6B6E7C]",
      "hover:[&>details>summary]:bg-[#60636f] hover:[&>details>summary]:text-white"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#227A52]",
      "hover:[&>details>summary]:bg-[#d4fde4] hover:[&>details>summary]:text-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#FF8B08]",
      "hover:[&>details>summary]:bg-[#fff1cd] hover:[&>details>summary]:text-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#E73B3B]",
      "hover:[&>details>summary]:bg-[#ffcdcd] hover:[&>details>summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#004FC4]",
      "hover:[&>details>summary]:bg-[#cce1ff] hover:[&>details>summary]:text-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#52059C]",
      "hover:[&>details>summary]:bg-[#ffe0ff] hover:[&>details>summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#4D4137]",
      "hover:[&>details>summary]:bg-[#ffdfc1] hover:[&>details>summary]:text-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#707483]",
      "hover:[&>details>summary]:bg-[#d2d8e9] hover:[&>details>summary]:text-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-white",
      "[&>details]:border-b",
      "[&>details]:border-[#1E1E1E]",
      "hover:[&>details>summary]:bg-[#111111] hover:[&>details>summary]:text-white"
    ]
  end

  defp color_variant("contained", "white") do
    [
      "border border-[#DADADA]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#DADADA]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#DADADA]"
    ]
  end

  defp color_variant("contained", "primary") do
    [
      "border border-[#4363EC]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#4363EC]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#4363EC]"
    ]
  end

  defp color_variant("contained", "secondary") do
    [
      "border border-[#6B6E7C]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#6B6E7C]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("contained", "success") do
    [
      "border border-[#227A52]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#227A52]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#227A52]"
    ]
  end

  defp color_variant("contained", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#FF8B08]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("contained", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#E73B3B]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("contained", "info") do
    [
      "border border-[#004FC4]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#004FC4]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#004FC4]"
    ]
  end

  defp color_variant("contained", "misc") do
    [
      "border border-[#52059C]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#52059C]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#52059C]"
    ]
  end

  defp color_variant("contained", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#4D4137]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#4D4137]"
    ]
  end

  defp color_variant("contained", "light") do
    [
      "border border-[#707483]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#707483]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#707483]"
    ]
  end

  defp color_variant("contained", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>details:not(:last-child)>summary]:border-b",
      "[&>details:not(:last-child)>summary]:border-[#1E1E1E]",
      "[&>details:not(:last-child)>:not(summary)]:border-b",
      "[&>details:not(:last-child)>:not(summary)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("filled", "white") do
    [
      "bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
    [
      "bg-[#1E1E1E] text-white"
    ]
  end

  defp color_variant("seperated", "white") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#DADADA]",
    ]
  end

  defp color_variant("seperated", "primary") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#4363EC]",
    ]
  end

  defp color_variant("seperated", "secondary") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#6B6E7C]",
    ]
  end

  defp color_variant("seperated", "success") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#227A52]",
    ]
  end

  defp color_variant("seperated", "warning") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#FF8B08]",
    ]
  end

  defp color_variant("seperated", "danger") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#E73B3B]",
    ]
  end

  defp color_variant("seperated", "info") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#004FC4]",
    ]
  end

  defp color_variant("seperated", "misc") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#52059C]",
    ]
  end

  defp color_variant("seperated", "dawn") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#4D4137]",
    ]
  end

  defp color_variant("seperated", "light") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#707483]",
    ]
  end

  defp color_variant("seperated", "dark") do
    [
      "bg-white",
      "[&>details]:border [&>details]:border-[#1E1E1E]",
    ]
  end

  defp item_color("default", "white") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("default", "primary") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-white"
    ]
  end

  defp item_color("default", "secondary") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#60636f]"
    ]
  end

  defp item_color("default", "success") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#d4fde4]"
    ]
  end

  defp item_color("default", "warning") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#fff1cd]"
    ]
  end

  defp item_color("default", "danger") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#ffcdcd]"
    ]
  end

  defp item_color("default", "info") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#cce1ff]"
    ]
  end

  defp item_color("default", "misc") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#ffe0ff]"
    ]
  end

  defp item_color("default", "dawn") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#ffdfc1]"
    ]
  end

  defp item_color("default", "light") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#d2d8e9]"
    ]
  end

  defp item_color("default", "dark") do
    [
      "group-open:bg-white group-open:hover:[&:is(summary)]:bg-[#111111]"
    ]
  end

  defp item_color("contained", "white") do
    [
      "group-open:bg-[#E8E8E8] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "primary") do
    [
      "group-open:bg-[#072ed3] group-open:text-white group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "secondary") do
    [
      "group-open:bg-[#60636f] group-open:text-white group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "success") do
    [
      "group-open:bg-[#d4fde4] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "warning") do
    [
      "group-open:bg-[#fff1cd] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "danger") do
    [
      "group-open:bg-[#ffcdcd] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "info") do
    [
      "group-open:bg-[#cce1ff] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "misc") do
    [
      "group-open:bg-[#ffe0ff] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dawn") do
    [
      "group-open:bg-[#ffdfc1] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "light") do
    [
      "group-open:bg-[#d2d8e9] group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dark") do
    [
      "group-open:bg-[#111111] group-open:text-white group-open:[&:is(summary)]:border-b-0"
    ]
  end

  defp item_color("filled", "white") do
    [
      "group-open:bg-[#E8E8E8]"
    ]
  end

  defp item_color("filled", "primary") do
    [
      "group-open:bg-[#072ed3]"
    ]
  end

  defp item_color("filled", "secondary") do
    [
      "group-open:bg-[#60636f]"
    ]
  end

  defp item_color("filled", "success") do
    [
      "group-open:bg-[#d4fde4]"
    ]
  end

  defp item_color("filled", "warning") do
    [
      "group-open:bg-[#fff1cd]"
    ]
  end

  defp item_color("filled", "danger") do
    [
      "group-open:bg-[#ffcdcd]"
    ]
  end

  defp item_color("filled", "info") do
    [
      "group-open:bg-[#cce1ff]"
    ]
  end

  defp item_color("filled", "misc") do
    [
      "group-open:bg-[#ffe0ff]"
    ]
  end

  defp item_color("filled", "dawn") do
    [
      "group-open:bg-[#ffdfc1]"
    ]
  end

  defp item_color("filled", "light") do
    [
      "group-open:bg-[#d2d8e9]"
    ]
  end

  defp item_color("filled", "dark") do
    [
      "group-open:bg-[#111111]"
    ]
  end

  defp item_color("seperated", "white") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "primary") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "secondary") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "success") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "warning") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "danger") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "info") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "misc") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "dawn") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "light") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "dark") do
    [
      "group-open:bg-white"
    ]
  end

  defp default_classes() do
    [
      ""
    ]
  end
end
