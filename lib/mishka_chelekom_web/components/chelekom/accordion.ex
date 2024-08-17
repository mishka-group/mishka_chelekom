defmodule MishkaChelekom.Accordion do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "contained",
    "filled",
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
    "dawn",
    "transparent"
  ]

  @doc type: :component
  attr :id, :string, required: true, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :space, :string, values: @sizes, default: "small", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :border, :string, values: @colors ++ ["transparent"], default: "transparent", doc: ""
  attr :padding, :string, values: @sizes ++ ["none"], default: "small", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "none", doc: ""
  attr :chevron_icon, :string, default: "hero-chevron-right", doc: ""
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
    attr :open, :boolean
  end

  attr :rest, :global,
  include: ~w(left_chevron right_chevron chevron hide_chevron),
  doc: ""

  def accordion(assigns) do
    ~H"""
    <div
      class={[
        "overflow-hidden w-full",
        rounded_size(@rounded),
        space_class(@space, @variant),
        padding_size(@padding),
        media_size(@media_size),
        color_variant(@variant, @color),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <div
        :for={{item, index} <- Enum.with_index(@item, 1)}
        class={["group accordion-item-wrapper", item[:class]]}
      >
        <div
          role="button"
          class={[
            "accordion-summary block w-full",
            "transition-all duration-100 ease-in-out",
            item[:summary_class]
          ]}
        >
          <.native_chevron_position
            id={"#{@id}-#{index}-open-chevron"}
            phx-click={
              show_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-close-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />

          <.native_chevron_position
            id={"#{@id}-#{index}-close-chevron"}
            phx-click={
              hide_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-open-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            class="hidden"
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </div>
        <.focus_wrap
          id={"#{@id}-#{index}"}
          class="accordion-content-wrapper relative hidden transition [&:not(.active)_.accordion-content]:grid-rows-[0fr] [&.active_.accordion-content]:grid-rows-[1fr]"
        >
          <div
            id={"#{@id}-#{index}-content"}
            class={[
              "accordion-content transition-all duration-500 grid",
              item[:content_class]
            ]}
          >
            <div class="overflow-hidden">
              <%= render_slot(item) %>
            </div>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end

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
  attr :chevron_icon, :string, default: "hero-chevron-right", doc: ""

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
    attr :open, :boolean
  end

  attr :rest, :global,
    include: ~w(left_chevron right_chevron chevron hide_chevron),
    doc: ""

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden",
        rounded_size(@rounded),
        space_class(@space, @variant),
        padding_size(@padding),
        media_size(@media_size),
        color_variant(@variant, @color),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <details
        :for={item <- @item}
        name={@name}
        class={["group accordion-item-wrapper", item[:class]]}
        open={item[:open] || false}
      >
        <summary class={[
          "accordion-summary w-full group-open:mb-1",
          "cursor-pointer transition-[margin,background,text] duration-[250ms] ease-in-out list-none",
          item_color(@variant, @color),
          item[:summary_class]
        ]}>
          <.native_chevron_position
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </summary>

        <div class={[
          "-mt-1 shrink-0 transition-all duration-1000 ease-in-out opacity-0 group-open:opacity-100",
          "-translate-y-4	group-open:translate-y-0 accordion-content",
          item_color(@variant, @color),
          item[:content_class]
        ]}>
          <%= render_slot(item) %>
        </div>
      </details>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :item, :map
  attr :position, :string, values: ["left", "right"]
  attr :chevron_icon, :string
  attr :hide_chevron, :boolean, default: false
  attr :rest, :global

  defp native_chevron_position(%{position: "left"} = assigns) do
    ~H"""
    <div
      id={@id}
      class={["flex flex-nowrap items-center rtl:justify-start ltr:justify-start gap-2", @class]}
      {@rest}
    >
      <.icon
        :if={!@hide_chevron}
        name={@chevron_icon}
        class="w-5 transition-transform duration-300 ease-in-out group-open:rotate-90 rotate-180 rtl:rotate-0"
      />

      <div class="flex items-center gap-5">
        <img
          :if={!is_nil(@item[:image])}
          class={["accordion-title-media shrink-0", @item[:image_class]]}
          src={@item[:image]}
        />

        <.icon
          :if={!is_nil(@item[:icon])}
          name={@item[:icon]}
          class={@item[:icon_class] || "accordion-title-media"}
        />

        <div class={["space-y-2", @item[:title_class]]}>
          <div><%= @item[:title] %></div>

          <div :if={!is_nil(@item[:description])} class="text-xs font-light">
            <%= @item[:description] %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp native_chevron_position(%{position: "right"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class="flex items-center justify-between gap-2">
        <div class="flex items-center gap-5">
          <img
            :if={!is_nil(@item[:image])}
            class={["accordion-title-media shrink-0", @item[:image_class]]}
            src={@item[:image]}
          />

          <.icon
            :if={!is_nil(@item[:icon])}
            name={@item[:icon]}
            class={@item[:icon_class] || "accordion-title-media"}
          />

          <div class={["space-y-2", @item[:title_class]]}>
            <div><%= @item[:title] %></div>

            <div :if={!is_nil(@item[:description])} class="text-xs font-light">
              <%= @item[:description] %>
            </div>
          </div>
        </div>

        <.icon
          :if={!@hide_chevron}
          name={@chevron_icon}
          class="w-5 transition-transform duration-300 ease-in-out group-open:rotate-90 rtl:rotate-180"
        />
      </div>
    </div>
    """
  end

  def show_accordion_content(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.add_class("active", to: "##{id}")
  end

  def hide_accordion_content(js \\ %JS{}, id) do
    js
    |> JS.remove_class("active", to: "##{id}")
  end

  defp space_class(_, variant) when variant not in ["seperated", "tinted_split"], do: nil
  defp space_class("extra_small", _), do: "accordion-item-gap space-y-2"
  defp space_class("small", _), do: "accordion-item-gap space-y-3"
  defp space_class("medium", _), do: "accordion-item-gap space-y-4"
  defp space_class("large", _), do: "accordion-item-gap space-y-5"
  defp space_class("extra_large", _), do: "accordion-item-gap space-y-6"
  defp space_class(params, _) when is_binary(params), do: params
  defp space_class(_, _), do: nil

  defp media_size("extra_small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-12"
  defp media_size("small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-14"
  defp media_size("medium"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-16"
  defp media_size("large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-20"
  defp media_size("extra_large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-24"
  defp media_size(params) when is_binary(params), do: params
  defp media_size(_), do: media_size("small")

  defp rounded_size("extra_small") do
    [
      "rounded-sm [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-sm [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-sm"
    ]
  end

  defp rounded_size("small") do
    [
      "rounded [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b"
    ]
  end

  defp rounded_size("medium") do
    [
      "rounded-md [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-md [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-md"
    ]
  end

  defp rounded_size("large") do
    [
      "rounded-lg [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-lg [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-lg"
    ]
  end

  defp rounded_size("extra_large") do
    [
      "rounded-xl [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-xl [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-xl"
    ]
  end

  defp rounded_size("none"), do: "rounded-none"

  defp padding_size("extra_small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-1"
    ]
  end

  defp padding_size("small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-2"
    ]
  end

  defp padding_size("medium") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-3"
    ]
  end

  defp padding_size("large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-4"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-5"
    ]
  end

  defp padding_size("none"), do: "[&>.accordion-item-wrapper>.accordion-summary]:p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp color_variant("default", "white") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#DADADA]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#4363EC]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#072ed3] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#6B6E7C]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#60636f] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#227A52]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#d4fde4] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#FF8B08]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#fff1cd] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#E73B3B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffcdcd] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#004FC4]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#cce1ff] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#52059C]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffe0ff] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#4D4137]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffdfc1] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#707483]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#d2d8e9] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#1E1E1E]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#111111] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("contained", "white") do
    [
      "border border-[#DADADA]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DADADA]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#DADADA]"
    ]
  end

  defp color_variant("contained", "primary") do
    [
      "border border-[#4363EC]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#4363EC]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#4363EC]"
    ]
  end

  defp color_variant("contained", "secondary") do
    [
      "border border-[#6B6E7C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#6B6E7C]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("contained", "success") do
    [
      "border border-[#227A52]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#227A52]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#227A52]"
    ]
  end

  defp color_variant("contained", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FF8B08]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("contained", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#E73B3B]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("contained", "info") do
    [
      "border border-[#004FC4]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#004FC4]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#004FC4]"
    ]
  end

  defp color_variant("contained", "misc") do
    [
      "border border-[#52059C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#52059C]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#52059C]"
    ]
  end

  defp color_variant("contained", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#4D4137]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#4D4137]"
    ]
  end

  defp color_variant("contained", "light") do
    [
      "border border-[#707483]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#707483]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#707483]"
    ]
  end

  defp color_variant("contained", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#1E1E1E]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("filled", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-[#1E1E1E] text-white"
    ]
  end

  defp color_variant("tinted_split", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white text-[#3E3E3E]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("tinted_split", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#4363EC] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4363EC]"
    ]
  end

  defp color_variant("tinted_split", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#6B6E7C] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("tinted_split", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-[#ECFEF3] text-[#047857]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#227A52]"
    ]
  end

  defp color_variant("tinted_split", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFF8E6] text-[#FF8B08]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#FF8B08]"
    ]
  end

  defp color_variant("tinted_split", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6E6] text-[#E73B3B]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#E73B3B]"
    ]
  end

  defp color_variant("tinted_split", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E5F0FF] text-[#004FC4]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#004FC4]"
    ]
  end

  defp color_variant("tinted_split", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6FF] text-[#52059C]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#52059C]"
    ]
  end

  defp color_variant("tinted_split", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFECDA] text-[#4D4137]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4D4137]"
    ]
  end

  defp color_variant("tinted_split", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E3E7F1] text-[#707483]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#707483]"
    ]
  end

  defp color_variant("tinted_split", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-[#1E1E1E] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("seperated", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#DADADA]"
    ]
  end

  defp color_variant("seperated", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4363EC]"
    ]
  end

  defp color_variant("seperated", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("seperated", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#227A52]"
    ]
  end

  defp color_variant("seperated", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#FF8B08]"
    ]
  end

  defp color_variant("seperated", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#E73B3B]"
    ]
  end

  defp color_variant("seperated", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#004FC4]"
    ]
  end

  defp color_variant("seperated", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#52059C]"
    ]
  end

  defp color_variant("seperated", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4D4137]"
    ]
  end

  defp color_variant("seperated", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#707483]"
    ]
  end

  defp color_variant("seperated", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#1E1E1E]"
    ]
  end

  defp item_color("default", "white") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("default", "primary") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#072ed3]"
    ]
  end

  defp item_color("default", "secondary") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#60636f]"
    ]
  end

  defp item_color("default", "success") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#d4fde4]"
    ]
  end

  defp item_color("default", "warning") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#fff1cd]"
    ]
  end

  defp item_color("default", "danger") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffcdcd]"
    ]
  end

  defp item_color("default", "info") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#cce1ff]"
    ]
  end

  defp item_color("default", "misc") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffe0ff]"
    ]
  end

  defp item_color("default", "dawn") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffdfc1]"
    ]
  end

  defp item_color("default", "light") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#d2d8e9]"
    ]
  end

  defp item_color("default", "dark") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#111111]"
    ]
  end

  defp item_color("contained", "white") do
    [
      "group-open:bg-[#E8E8E8] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "primary") do
    [
      "group-open:bg-[#072ed3] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "secondary") do
    [
      "group-open:bg-[#60636f] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "success") do
    [
      "group-open:bg-[#d4fde4] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "warning") do
    [
      "group-open:bg-[#fff1cd] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "danger") do
    [
      "group-open:bg-[#ffcdcd] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "info") do
    [
      "group-open:bg-[#cce1ff] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "misc") do
    [
      "group-open:bg-[#ffe0ff] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dawn") do
    [
      "group-open:bg-[#ffdfc1] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "light") do
    [
      "group-open:bg-[#d2d8e9] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dark") do
    [
      "group-open:bg-[#111111] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
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

  defp item_color("tinted_split", "white") do
    [
      "group-open:bg-[#E8E8E8]"
    ]
  end

  defp item_color("tinted_split", "primary") do
    [
      "group-open:bg-[#072ed3]"
    ]
  end

  defp item_color("tinted_split", "secondary") do
    [
      "group-open:bg-[#60636f]"
    ]
  end

  defp item_color("tinted_split", "success") do
    [
      "group-open:bg-[#d4fde4]"
    ]
  end

  defp item_color("tinted_split", "warning") do
    [
      "group-open:bg-[#fff1cd]"
    ]
  end

  defp item_color("tinted_split", "danger") do
    [
      "group-open:bg-[#ffcdcd]"
    ]
  end

  defp item_color("tinted_split", "info") do
    [
      "group-open:bg-[#cce1ff]"
    ]
  end

  defp item_color("tinted_split", "misc") do
    [
      "group-open:bg-[#ffe0ff]"
    ]
  end

  defp item_color("tinted_split", "dawn") do
    [
      "group-open:bg-[#ffdfc1]"
    ]
  end

  defp item_color("tinted_split", "light") do
    [
      "group-open:bg-[#d2d8e9]"
    ]
  end

  defp item_color("tinted_split", "dark") do
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

  defp chevron_position(%{left_chevron: true}), do: "left"
  defp chevron_position(%{right_chevron: true}), do: "right"
  defp chevron_position(%{chevron: true}), do: "right"
  defp chevron_position(_), do: "right"

  defp drop_rest(rest) do
    all_rest =
      ~w(left_chevron right_chevron chevron hide_chevron)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end
end
