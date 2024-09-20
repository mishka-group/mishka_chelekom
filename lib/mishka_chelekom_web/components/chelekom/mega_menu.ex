defmodule MishkaChelekom.MegaMenu do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import MishkaChelekomComponents

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
    "shadow"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :clickable, :boolean, default: false, doc: ""
  attr :variant, :string, values: @variants, default: "shadow", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :size, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_class, :string, default: nil, doc: ""
  attr :title, :string, default: nil, doc: ""
  attr :title_class, :string, default: nil, doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :top_gap, :string, default: "extra_small", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  slot :trigger, required: false do
    attr :class, :string
  end

  def mega_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-open-mega={
        JS.toggle_class("show-mega-menu",
          to: "##{@id}-mega-menu-content",
          transition: "duration-100"
        )
      }
      class={[
        "[&>.mega-menu-content]:invisible [&>.mega-menu-content]:opacity-0",
        "[&>.mega-menu-content.show-mega-menu]:visible [&>.mega-menu-content.show-mega-menu]:opacity-100",
        !@clickable && tirgger_mega_menu(),
        color_variant(@variant, @color),
        padding_size(@padding),
        rounded_size(@rounded),
        width_size(@width),
        border_class(@border),
        top_gap(@top_gap),
        space_class(@space),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <button
        :if={!is_nil(@title)}
        phx-click={@id && JS.exec("phx-open-mega", to: "##{@id}")}
        class={["flex items-center", @title_class]}
      >
        <.icon :if={!is_nil(@icon)} name={@icon} class={["aler-icon", @icon_class]} />
        <span><%= @title %></span>
      </button>

      <div
        :if={@trigger}
        phx-click={@id && JS.exec("phx-open-mega", to: "##{@id}")}
        class={["cursor-pointer mega-menu-trigger", @trigger[:class]]}
      >
        <%= render_slot(@trigger) %>
      </div>

      <div
        id={@id && "#{@id}-mega-menu-content"}
        phx-click-away={
          @id &&
            JS.remove_class("show-mega-menu",
              to: "##{@id}-mega-menu-content",
              transition: "duration-300"
            )
        }
        class={[
          "mega-menu-content inset-x-0 top-full absolute z-20 transition-all ease-in-out delay-100 duratio-500 w-full",
          "invisible opacity-0"
        ]}
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp tirgger_mega_menu(),
    do: "[&>.mega-menu-content]:hover:visible [&>.mega-menu-content]:hover:opacity-100"

  defp top_gap("none"), do: "[&>.mega-menu-content]:mt-0"
  defp top_gap("extra_small"), do: "[&>.mega-menu-content]:mt-1"
  defp top_gap("small"), do: "[&>.mega-menu-content]:mt-2"
  defp top_gap("medium"), do: "[&>.mega-menu-content]:mt-3"
  defp top_gap("large"), do: "[&>.mega-menu-content]:mt-4"
  defp top_gap("extra_large"), do: "[&>.mega-menu-content]:mt-5"
  defp top_gap(params) when is_binary(params), do: params
  defp top_gap(_), do: top_gap("extra_small")

  defp width_size("full"), do: "[&>.mega-menu-content]:w-ful"

  defp width_size("half"),
    do:
      "[&>.mega-menu-content]:w-full md:[&>.mega-menu-content]:w-1/2 md:[&>.mega-menu-content]:mx-auto"

  defp width_size(params) when is_binary(params), do: params
  defp width_size(_), do: width_size("full")

  defp border_class("none"), do: "[&>.mega-menu-content]:border-0"
  defp border_class("extra_small"), do: "[&>.mega-menu-content]:border"
  defp border_class("small"), do: "[&>.mega-menu-content]:border-2"
  defp border_class("medium"), do: "[&>.mega-menu-content]:[&>.mega-menu-content]:border-[3px]"
  defp border_class("large"), do: "[&>.mega-menu-content]:border-4"

  defp border_class("extra_large"),
    do: "[&>.mega-menu-content]:[&>.mega-menu-content]:border-[5px]"

  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp rounded_size("extra_small"), do: "[&>.mega-menu-content]:rounded-sm"
  defp rounded_size("small"), do: "[&>.mega-menu-content]:rounded"
  defp rounded_size("medium"), do: "[&>.mega-menu-content]:rounded-md"
  defp rounded_size("large"), do: "[&>.mega-menu-content]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&>.mega-menu-content]:rounded-xl"
  defp rounded_size("none"), do: "[&>.mega-menu-content]:rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp size_class("extra_small"), do: "text-xs"
  defp size_class("small"), do: "text-sm"
  defp size_class("medium"), do: "text-base"
  defp size_class("large"), do: "text-lg"
  defp size_class("extra_large"), do: "text-xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"), do: "[&>.mega-menu-content]:p-2"
  defp padding_size("small"), do: "[&>.mega-menu-content]:p-3"
  defp padding_size("medium"), do: "[&>.mega-menu-content]:p-4"
  defp padding_size("large"), do: "[&>.mega-menu-content]:p-5"
  defp padding_size("extra_large"), do: "[&>.mega-menu-content]:p-6"
  defp padding_size("none"), do: "[&>.mega-menu-content]:p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("extra_small")

  defp space_class("none"), do: "[&>.mega-menu-content]:space-y-0"
  defp space_class("extra_small"), do: "[&>.mega-menu-content]:space-y-2"
  defp space_class("small"), do: "[&>.mega-menu-content]:space-y-3"
  defp space_class("medium"), do: "[&>.mega-menu-content]:space-y-4"
  defp space_class("large"), do: "[&>.mega-menu-content]:space-y-5"
  defp space_class("extra_large"), do: "[&>.mega-menu-content]:space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("none")

  defp color_variant("default", "white") do
    "[&>.mega-menu-content]:bg-white text-[#3E3E3E] [&>.mega-menu-content]:border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "[&>.mega-menu-content]:bg-[#4363EC] text-white [&>.mega-menu-content]:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "[&>.mega-menu-content]:bg-[#6B6E7C] text-white [&>.mega-menu-content]:border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "[&>.mega-menu-content]:bg-[#ECFEF3] text-[#047857] [&>.mega-menu-content]:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "[&>.mega-menu-content]:bg-[#FFF8E6] text-[#FF8B08] [&>.mega-menu-content]:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "[&>.mega-menu-content]:bg-[#FFE6E6] text-[#E73B3B] [&>.mega-menu-content]:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "[&>.mega-menu-content]:bg-[#E5F0FF] text-[#004FC4] [&>.mega-menu-content]:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "[&>.mega-menu-content]:bg-[#FFE6FF] text-[#52059C] [&>.mega-menu-content]:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "[&>.mega-menu-content]:bg-[#FFECDA] text-[#4D4137] [&>.mega-menu-content]:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "[&>.mega-menu-content]:bg-[#E3E7F1] text-[#707483] [&>.mega-menu-content]:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "[&>.mega-menu-content]:bg-[#1E1E1E] text-white [&>.mega-menu-content]:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "[&>.mega-menu-content]:bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "[&>.mega-menu-content]:bg-transparent text-[#4363EC] [&>.mega-menu-content]:border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "[&>.mega-menu-content]:bg-transparent text-[#6B6E7C] [&>.mega-menu-content]:border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "[&>.mega-menu-content]:bg-transparent text-[#227A52] [&>.mega-menu-content]:border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "[&>.mega-menu-content]:bg-transparent text-[#FF8B08] [&>.mega-menu-content]:border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "[&>.mega-menu-content]:bg-transparent text-[#E73B3B] [&>.mega-menu-content]:border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "[&>.mega-menu-content]:bg-transparent text-[#004FC4] [&>.mega-menu-content]:border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "[&>.mega-menu-content]:bg-transparent text-[#52059C] [&>.mega-menu-content]:border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "[&>.mega-menu-content]:bg-transparent text-[#4D4137] [&>.mega-menu-content]:border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "[&>.mega-menu-content]:bg-transparent text-[#707483] [&>.mega-menu-content]:border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "[&>.mega-menu-content]:bg-transparent text-[#1E1E1E] [&>.mega-menu-content]:border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "[&>.mega-menu-content]:bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "[&>.mega-menu-content]:bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "[&>.mega-menu-content]:bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "[&>.mega-menu-content]:bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "[&>.mega-menu-content]:bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "[&>.mega-menu-content]:bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "[&>.mega-menu-content]:bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "[&>.mega-menu-content]:bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "[&>.mega-menu-content]:bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "[&>.mega-menu-content]:bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "[&>.mega-menu-content]:bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "[&>.mega-menu-content]:bg-white text-[#3E3E3E] [&>.mega-menu-content]:border-[#DADADA] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "primary") do
    "[&>.mega-menu-content]:bg-[#4363EC] text-white [&>.mega-menu-content]:border-[#4363EC] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "secondary") do
    "[&>.mega-menu-content]:bg-[#6B6E7C] text-white [&>.mega-menu-content]:border-[#6B6E7C] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "success") do
    "[&>.mega-menu-content]:bg-[#AFEAD0] text-[#227A52] [&>.mega-menu-content]:border-[#AFEAD0] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "warning") do
    "[&>.mega-menu-content]:bg-[#FFF8E6] text-[#FF8B08] [&>.mega-menu-content]:border-[#FFF8E6] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "danger") do
    "[&>.mega-menu-content]:bg-[#FFE6E6] text-[#E73B3B] [&>.mega-menu-content]:border-[#FFE6E6] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "info") do
    "[&>.mega-menu-content]:bg-[#E5F0FF] text-[#004FC4] [&>.mega-menu-content]:border-[#E5F0FF] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "misc") do
    "[&>.mega-menu-content]:bg-[#FFE6FF] text-[#52059C] [&>.mega-menu-content]:border-[#FFE6FF] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "dawn") do
    "[&>.mega-menu-content]:bg-[#FFECDA] text-[#4D4137] [&>.mega-menu-content]:border-[#FFECDA] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "light") do
    "[&>.mega-menu-content]:bg-[#E3E7F1] text-[#707483] [&>.mega-menu-content]:border-[#E3E7F1] [&>.mega-menu-content]:shadow"
  end

  defp color_variant("shadow", "dark") do
    "[&>.mega-menu-content]:bg-[#1E1E1E] text-white [&>.mega-menu-content]:border-[#1E1E1E] [&>.mega-menu-content]:shadow"
  end
end
