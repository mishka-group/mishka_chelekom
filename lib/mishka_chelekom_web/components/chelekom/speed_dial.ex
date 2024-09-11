defmodule MishkaChelekom.SpeedDial do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :action_position, :string, default: "bottom-end", doc: ""
  attr :position_size, :string, default: "large", doc: ""
  attr :wrapper_position, :string, default: "top", doc: ""
  attr :rounded, :string, default: "full", doc: ""
  attr :size, :string, default: "medium", doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :variant, :string, default: "default", doc: ""
  attr :space, :string, default: "extra_small", doc: ""
  attr :width, :string, default: "fit", doc: ""
  attr :border, :string, default: "extra_small", doc: ""
  attr :padding, :string, default: "extra_small", doc: ""
  attr :clickable, :boolean, default: false, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_animated, :boolean, default: false, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  slot :item, required: false do
    attr :icon, :string
    attr :class, :string
    attr :navigate, :string, doc: ""
    attr :patch, :string, doc: ""
    attr :href, :string, doc: ""
    attr :icon_class, :string
    attr :color, :string
    attr :variant, :string
    attr :icon_position, :string, doc: "end, start"
  end

  slot :trigger_content, required: false do
    attr :class, :string
  end

  def speed_dial(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed group",
        "[&_.speed-dial-content]:invisible [&_.speed-dial-content]:opacity-0",
        "[&_.speed-dial-content.show-dial]:visible [&_.speed-dial-content.show-dial]:opacity-100",
        "[&_.speed-dial-base]:flex [&_.speed-dial-base]:items-center [&_.speed-dial-base]:justify-center",
        !@clickable && trigger_dial(),
        action_position(@position_size, @action_position),
        position_class(@wrapper_position),
        rounded_size(@rounded),
        border_class(@border),
        padding_class(@padding),
        width_class(@width),
        space_class(@space),
        size_class(@size)
      ]}
      {@rest}
    >
      <div class={[
        "speed-dial-content flex items-center",
        "absolute z-10 w-full transition-all ease-in-out delay-100 duratio-500",
        (@wrapper_position == "top" || @wrapper_position == "bottom") && "flex-col"
      ]}>
        <div
          :for={{item, index} <- Enum.with_index(@item, 1)}
          id={"#{@id}-item-header-#{index}"}
          class={[
            "speed-dial-item",
            item[:icon_position] == "end" && "flex-row-reverse",
            item[:class]
          ]}
        >
          <.speed_dial_content id={@id} index={index} {item}>
            <%= render_slot(item) %>
          </.speed_dial_content>
        </div>
        <%= render_slot(@inner_block) %>
      </div>

      <button type="button" class={[
        "speed-dial-base",
        color_variant(@variant, @color),
      ]}>
        <.icon
          :if={!is_nil(@icon)}
          name={@icon}
          class={@icon_animated && "transition-transform group-hover:rotate-45"}
        />
        <span :if={is_nil(@icon)} class={@trigger_content[:class]}><%= @trigger_content %></span>
        <span class="sr-only">Open actions menu</span>
      </button>
    </div>
    """
  end

  attr :id, :string, required: true, doc: ""
  attr :navigate, :string, default: nil, doc: ""
  attr :patch, :string, default: nil, doc: ""
  attr :href, :string, default: nil, doc: ""
  attr :color, :string, default: "primary", doc: ""
  attr :variant, :string, default: "defauly", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :icon_class, :string, default: nil, doc: ""
  attr :index, :integer, required: true, doc: ""
  attr :icon_position, :string, doc: "end, start"
  slot :inner_block, required: false, doc: ""

  defp speed_dial_content(%{navigate: nav, patch: pat, href: hrf} = assigns)
       when is_binary(nav) or is_binary(pat) or is_binary(hrf) do
    ~H"""
    <.link
      id={"#{@id}-speed-dial-item-#{@index}"}
      class={[
        "block speed-dial-base",
        color_variant(@variant, @color),
      ]}
      navigate={@navigate}
      patch={@patch}
      href={@href}
    >
      <.icon
        :if={@icon}
        name={@icon}
        class={[
          "item-icon",
          @icon_class
        ]}
      />
      <span class="block">
        <%= render_slot(@inner_block) %>
      </span>
    </.link>
    """
  end

  defp speed_dial_content(assigns) do
    ~H"""
    <div id={"#{@id}-speed-dial-item-#{@index}"}
      class={[
        "speed-dial-base",
        color_variant(@variant, @color),
      ]}
    >
      <.icon
        :if={@icon}
        name={@icon}
        class={[
          "item-icon",
          @icon_class
        ]}
      />
      <span class="block">
        <%= render_slot(@inner_block) %>
      </span>
    </div>
    """
  end

  defp trigger_dial(),
    do: "[&_.speed-dial-content]:hover:visible [&_.speed-dial-content]:hover:opacity-100"

  defp position_class("top") do
    [
      "[&_.speed-dial-content]:bottom-full [&_.speed-dial-content]:left-1/2",
      "[&_.speed-dial-content]:-translate-x-1/2 [&_.speed-dial-content]:-translate-y-[6px]"
    ]
  end

  defp position_class("bottom") do
    [
      "[&_.speed-dial-content]:top-full [&_.speed-dial-content]:left-1/2",
      "[&_.speed-dial-content]:-translate-x-1/2 [&_.speed-dial-content]:translate-y-[6px]"
    ]
  end

  defp position_class("left") do
    [
      "[&_.speed-dial-content]:right-full [&_.speed-dial-content]:top-1/2",
      "[&_.speed-dial-content]:-translate-y-1/2 [&_.speed-dial-content]:-translate-x-[6px]"
    ]
  end

  defp position_class("right") do
    [
      "[&_.speed-dial-content]:left-full [&_.speed-dial-content]:top-1/2",
      "[&_.speed-dial-content]:-translate-y-1/2 [&_.speed-dial-content]:translate-x-[6px]"
    ]
  end

  defp width_class("extra_small"), do: "[&_.speed-dial-content]:w-48"
  defp width_class("small"), do: "[&_.speed-dial-content]:w-52"
  defp width_class("medium"), do: "[&_.speed-dial-content]:w-56"
  defp width_class("large"), do: "[&_.speed-dial-content]:w-60"
  defp width_class("extra_large"), do: "[&_.speed-dial-content]:w-64"
  defp width_class("double_large"), do: "[&_.speed-dial-content]:w-72"
  defp width_class("triple_large"), do: "[&_.speed-dial-content]:w-80"
  defp width_class("quadruple_large"), do: "[&_.speed-dial-content]:w-96"
  defp width_class("fit"), do: "[&_.speed-dial-content]:w-fit"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("fit")

  defp space_class("extra_small"), do: "[&_.speed-dial-item]:space-y-2"
  defp space_class("small"), do: "[&_.speed-dial-item]:space-y-3"
  defp space_class("medium"), do: "[&_.speed-dial-item]:space-y-4"
  defp space_class("large"), do: "[&_.speed-dial-item]:space-y-5"
  defp space_class("extra_large"), do: "[&_.speed-dial-item]:space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("extra_small")

  defp padding_class("none"), do: "[&_.speed-dial-content]:p-0"
  defp padding_class("extra_small"), do: "[&_.speed-dial-content]:p-1"
  defp padding_class("small"), do: "[&_.speed-dial-content]:p-1.5"
  defp padding_class("medium"), do: "[&_.speed-dial-content]:p-2"
  defp padding_class("large"), do: "[&_.speed-dial-content]:p-2.5"
  defp padding_class("extra_large"), do: "[&_.speed-dial-content]:p-3"
  defp padding_class(params) when is_binary(params), do: params
  defp padding_class(_), do: padding_class("extra_small")

  defp rounded_size("extra_small"), do: "[&_.speed-dial-base]:rounded-sm"
  defp rounded_size("small"), do: "[&_.speed-dial-base]:rounded"
  defp rounded_size("medium"), do: "[&_.speed-dial-base]:rounded-md"
  defp rounded_size("large"), do: "[&_.speed-dial-base]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.speed-dial-base]:rounded-xl"
  defp rounded_size("full"), do: "[&_.speed-dial-base]:rounded-full"
  defp rounded_size(_), do: rounded_size("full")

  defp size_class("extra_small"),
    do: "[&_.speed-dial-content]:max-w-60 [&_.speed-dial-base]:size-9"

  defp size_class("small"), do: "[&_.speed-dial-content]:max-w-64 [&_.speed-dial-base]:size-10"
  defp size_class("medium"), do: "[&_.speed-dial-content]:max-w-72 [&_.speed-dial-base]:size-12"
  defp size_class("large"), do: "[&_.speed-dial-content]:max-w-80 [&_.speed-dial-base]:size-14"

  defp size_class("extra_large"),
    do: "[&_.speed-dial-content]:max-w-96 [&_.speed-dial-base]:size-18"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("extra_large")

  defp border_class("none"), do: "[&_.speed-dial-base]:border-0"
  defp border_class("extra_small"), do: "[&_.speed-dial-base]:border"
  defp border_class("small"), do: "[&_.speed-dial-base]:border-2"
  defp border_class("medium"), do: "[&_.speed-dial-base]:border-[3px]"
  defp border_class("large"), do: "[&_.speed-dial-base]:border-4"
  defp border_class("extra_large"), do: "[&_.speed-dial-base]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp action_position("none", "top-start"), do: "top-0 start-0"
  defp action_position("extra_small", "top-start"), do: "top-1 start-4"
  defp action_position("small", "top-start"), do: "top-2 start-5"
  defp action_position("medium", "top-start"), do: "top-3 start-6"
  defp action_position("large", "top-start"), do: "top-4 start-7"
  defp action_position("extra_large", "top-start"), do: "top-8 start-8"

  defp action_position("none", "top-end"), do: "top-0 end-0"
  defp action_position("extra_small", "top-end"), do: "top-4 end-4"
  defp action_position("small", "top-end"), do: "top-5 end-5"
  defp action_position("medium", "top-end"), do: "top-6 end-6"
  defp action_position("large", "top-end"), do: "top-7 end-7"
  defp action_position("extra_large", "top-end"), do: "top-8 end-8"

  defp action_position("none", "[&_.speed-dial-content]:start"), do: "bottom-0 start-0"
  defp action_position("extra_small", "bottom-start"), do: "bottom-4 start-4"
  defp action_position("small", "bottom-start"), do: "bottom-5 start-5"
  defp action_position("medium", "bottom-start"), do: "bottom-6 start-6"
  defp action_position("large", "bottom-start"), do: "bottom-8 start-8"
  defp action_position("extra_large", "bottom-start"), do: "bottom-9 start-9"

  defp action_position("none", "bottom-end"), do: "bottom-0 end-0"
  defp action_position("extra_small", "bottom-end"), do: "bottom-4 end-4"
  defp action_position("small", "bottom-end"), do: "bottom-5 end-5"
  defp action_position("medium", "bottom-end"), do: "bottom-6 end-6"
  defp action_position("large", "bottom-end"), do: "bottom-8 end-8"
  defp action_position("extra_large", "bottom-end"), do: "bottom-9 end-9"

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white border-transparent text-[#3E3E3E]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] border-transparent text-white"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] border-transparent text-white"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] border-transparent text-[#047857]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] border-transparent text-[#FF8B08]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] border-transparent text-[#E73B3B]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] border-transparent text-[#004FC4]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] border-transparent text-[#52059C]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] border-transparent text-[#4D4137]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] border-transparent text-[#707483]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] border-transparent text-white"
  end

  defp color_variant("shadow", "white") do
    [
      "bg-white text-[#3E3E3E]",
      "border-[#DADADA] shadow"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#4363EC] text-white",
      "border-[#4363EC] shadow"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#6B6E7C] text-white",
      "border-[#6B6E7C] shadow"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#AFEAD0] text-[#227A52]",
      "border-[#AFEAD0] shadow"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08]",
      "border-[#FFF8E6] shadow"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B]",
      "border-[#FFE6E6] shadow"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4]",
      "border-[#E5F0FF] shadow"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C",
      "border-[#FFE6FF] shadow"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137]",
      "border-[#FFECDA] shadow"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "bg-[#E3E7F1] text-[#707483]",
      "border-[#E3E7F1] shadow"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "bg-[#1E1E1E] text-white",
      "border-[#1E1E1E] shadow"
    ]
  end

  defp color_variant(_, _), do: color_variant("default", "primary")
end
