defmodule MishkaChelekom.Menu do
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

  @variants [
    "default",
    "filled",
    "outline",
    "seperated",
    "tinted_split",
    "transparent"
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :title, :string, required: true, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :image, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :variant, :string, values: @variants, default: "filled", doc: ""
  attr :chevron_icon, :string, default: "hero-chevron-right", doc: ""
  slot :item, validate_attrs: false
  attr :rest, :global, doc: ""
  slot :inner_block, doc: ""

  def menu(assigns) do
    ~H"""

    <div id={@id}>
        <div
          role="button"
          class={[
            "menu-trigger block w-full",
            "transition-all duration-100 ease-in-out [&.active-menu-button_.menu-chevron]:rotate-90",
          ]}
        >
          <.menu_link
            phx-click={
              show_menu_content("#{@id}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-close-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            title={@title}
            hide_chevron={@rest[:hide_chevron] || false}
          />

          <.menu_link
            phx-click={
              hide_menu_content("#{@id}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-open-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            title={@title}
            class="hidden"
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </div>
      <div
        :for={{item, index} <- Enum.with_index(@item, 1)}
        class={["group menu-item-wrapper", item[:class]]}
      >
        <.focus_wrap
          id={"#{@id}-#{index}"}
          class="menu-content-wrapper relative hidden transition [&:not(.active)_.menu-content]:grid-rows-[0fr] [&.active_.menu-content]:grid-rows-[1fr]"
        >
          <div
            id={"#{@id}-#{index}-content"}
            class={[
              "menu-content transition-all duration-500 grid",
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

  attr :id, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :variant, :string, values: @variants, default: "filled", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  def ul(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        space_class(@space),
        color_variant(@color, @variant),
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
  attr :class, :list, default: nil, doc: ""
  attr :count, :integer, default: nil, doc: ""
  attr :count_separator, :string, default: ". ", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_class, :string, default: "list-item-icon", doc: ""
  attr :content_class, :string, default: nil
  attr :padding, :string, default: "none", doc: ""
  attr :position, :string, values: ["start", "end", "center"], default: "start", doc: ""
  attr :rest, :global
  slot :inner_block, required: true, doc: ""

  @spec li(map()) :: Phoenix.LiveView.Rendered.t()
  def li(assigns) do
    ~H"""
    <li
      id={@id}
      class={[
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      <div class={[
        "flex items-center gap-2 w-full"
      ]}>
        <.icon :if={!is_nil(@icon)} name={@icon} class={@icon_class} />
        <span :if={is_integer(@count)}><%= @count %><%= @count_separator %></span>
        <div class="w-full">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </li>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :title, :string, default: nil, doc: ""
  attr :item, :map
  attr :position, :string, values: ["left", "right"]
  attr :chevron_icon, :string
  attr :hide_chevron, :boolean, default: false
  attr :rest, :global

  defp menu_link(%{position: "left"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class="flex flex-nowrap items-center rtl:justify-start ltr:justify-start gap-2">


        <div class="flex items-center gap-5">
          <div ><%= @title %></div>
        </div>
      </div>
    </div>
    """
  end

  defp menu_link(%{position: "right"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class="flex items-center justify-between gap-2">
        <div class="flex items-center gap-5">


            <div ><%= @title %></div>

        </div>


      </div>
    </div>
    """
  end

  def show_menu_content(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.add_class("active", to: "##{id}")
    |> JS.add_class("active-menu-button", to: "##{id}-role-button")
  end

  def hide_menu_content(js \\ %JS{}, id) do
    js
    |> JS.remove_class("active", to: "##{id}")
    |> JS.remove_class("active-menu-button", to: "##{id}-role-button")
  end

  defp chevron_position(%{left_chevron: true}), do: "left"
  defp chevron_position(%{right_chevron: true}), do: "right"
  defp chevron_position(%{chevron: true}), do: "right"
  defp chevron_position(_), do: "right"

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: nil

  defp size_class("extra_small"), do: "text-xs [&_.list-item-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.list-item-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.list-item-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.list-item-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.list-item-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("none")

  defp color_variant("default", "white") do
    [
      "bg-white border border-[#DADADA] text-[#3E3E3E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border border-[#877C7C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#877C7C]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "border border-[#DADADA]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#DADADA]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "border border-[#2441de]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#2441de]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "border border-[#227A52]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#227A52]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "border border-[#004FC4]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#004FC4]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "border border-[#52059C]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#52059C]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#4D4137]"
    ]
  end

  defp color_variant("outline", "light") do
    [
      "border border-[#707483]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#707483]"
    ]
  end

  defp color_variant("outline", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>li:not(:last-child)]:border-b",
      "[&>li:not(:last-child)]:border-[#1E1E1E]"
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

  defp color_variant("transparent", _) do
    [
      "bg-transplant"
    ]
  end
end
