defmodule MishkaChelekom.Tabs do
  use Phoenix.Component
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
    "transparent",
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "transparent", doc: ""
  attr :color, :string, values: @colors, default: "primary", doc: ""
  attr :border, :string, default: "none", doc: ""
  attr :tab_border, :string, default: "extra_small", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :gap, :string, default: "none", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, default: "extra_small", doc: ""
  attr :triggers_position, :string, default: "extra_small", doc: ""
  attr :vertical, :boolean, default: false, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  slot :tab, required: true do
    attr :icon, :string
    attr :class, :string
    attr :padding, :string
    attr :icon_class, :string
    attr :icon_position, :string, doc: "end, start"
  end

  slot :panel, required: true do
    attr :class, :string
  end


  # The first tab should always have the `active` class, and the corresponding first panel should be visible

  def tabs(%{vertical: true} = assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex",
        content_position(@triggers_position),
        tab_border(@tab_border, @vertical),
        color_variant(@variant, @color),
        padding_size(@padding),
        gap_size(@gap),
        border_class(@border),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div role="tablist" tabindex="0" class={"tab-trigger-list flex flex-col"}>
        <button
          role="tab"
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          class={[
            "tab-trigger flex flex-row flex-nowrap items-center gap-1.5",
            "transition-all duration-400 delay-100 disabled:opacity-80",
            tab[:icon_position] == "end" && "flex-row-reverse",
            tab[:class]
          ]}
        >
          <.icon :if={tab[:icon]} name={tab[:icon]} class="tab-icon" />
          <span class="block">
            <%= render_slot(tab) %>
          </span>
        </button>
      </div>

      <div class="ms-2 flex-1">
        <div
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          role="tabpanel"
          class="tab-content"
        >
          <%= render_slot(panel) %>
        </div>
      </div>
    </div>
    """
  end

  def tabs(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "w-full",
        content_position(@triggers_position),
        tab_border(@tab_border, @vertical),
        color_variant(@variant, @color),
        padding_size(@padding),
        border_class(@border),
        gap_size(@gap),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div role="tablist" tabindex="0" class={"tab-trigger-list flex flex-wrap flex-wrap"}>
        <button
          role="tab"
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          class={[
            "tab-trigger flex flex-row flex-nowrap items-center gap-1.5",
            "transition-all duration-400 delay-100 disabled:opacity-80",
            tab[:icon_position] == "end" && "flex-row-reverse",
            tab[:class]
          ]}
        >
          <.icon :if={tab[:icon]} name={tab[:icon]} class="tab-icon" />
          <span class="block">
            <%= render_slot(tab) %>
          </span>
        </button>
      </div>

      <div class="mt-2">
        <div
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          role="tabpanel"
          class="tab-content"
        >
          <%= render_slot(panel) %>
        </div>
      </div>
    </div>
    """
  end

  defp content_position("start") do
    "[&_.tab-trigger-list]:justify-start"
  end

  defp content_position("end") do
    "[&_.tab-trigger-list]:justify-end"
  end

  defp content_position("center") do
    "[&_.tab-trigger-list]:justify-center"
  end

  defp content_position("between") do
    "[&_.tab-trigger-list]:justify-between"
  end

  defp content_position("around") do
    "[&_.tab-trigger-list]:justify-around"
  end

  defp content_position(_), do: content_position("start")

  defp space_class("none"), do: "space-y-0"
  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("none")

  defp padding_size("none") do
    [
      "[&_.tab-trigger]:p-0 [&_.tab-content]:p-0"
    ]
  end
  defp padding_size("extra_small") do
    [
      "[&_.tab-trigger]:py-1 [&_.tab-trigger]:px-2 [&_.tab-content]:p-2"
    ]
  end
  defp padding_size("small") do
    [
      "[&_.tab-trigger]:py-1.5 [&_.tab-trigger]:px-3 [&_.tab-content]:p-3"
    ]
  end
  defp padding_size("medium") do
    [
      "[&_.tab-trigger]:py-2 [&_.tab-trigger]:px-4 [&_.tab-content]:p-4"
    ]
  end
  defp padding_size("large") do
    [
      "[&_.tab-trigger]:py-2.5 [&_.tab-trigger]:px-5 [&_.tab-content]:p-5"
    ]
  end
  defp padding_size("extra_large") do
    [
      "[&_.tab-trigger]:py-3 [&_.tab-trigger]:px-5 [&_.tab-content]:p-6"
    ]
  end
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp size_class("extra_small"), do: "text-xs [&_.tab-icon]:size-4"
  defp size_class("small"), do: "text-sm [&_.tab-icon]:size-5"
  defp size_class("medium"), do: "text-base [&_.tab-icon]:size-6"
  defp size_class("large"), do: "text-lg [&_.tab-icon]:size-7"
  defp size_class("extra_large"), do: "text-xl [&_.tab-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp gap_size("extra_small"), do: "gap-1"
  defp gap_size("small"), do: "gap-2"
  defp gap_size("medium"), do: "gap-3"
  defp gap_size("large"), do: "gap-4"
  defp gap_size("extra_large"), do: "gap-5"
  defp gap_size(params) when is_binary(params), do: params
  defp gap_size(_), do: nil

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: [params]
  defp border_class(nil), do: border_class("none")

  defp tab_border("none", true), do: "[&_.tab-trigger]:border-e-0"
  defp tab_border("extra_small", true), do: "[&_.tab-trigger]:border-e"
  defp tab_border("small", true), do: "[&_.tab-trigger]:border-e-2"
  defp tab_border("medium", true), do: "[&_.tab-trigger]:border-e-[3px]"
  defp tab_border("large", true), do: "[&_.tab-trigger]:border-e-4"
  defp tab_border("extra_large", true), do: "[&_.tab-trigger]:border-e-[5px]"
  defp tab_border(params) when is_binary(params), do: [params]
  defp tab_border(nil, true), do: tab_border("none", true)

  defp tab_border("none", false), do: "[&_.tab-trigger]:border-b-0"
  defp tab_border("extra_small", false), do: "[&_.tab-trigger]:border-b"
  defp tab_border("small", false), do: "[&_.tab-trigger]:border-b-2"
  defp tab_border("medium", false), do: "[&_.tab-trigger]:border-b-[3px]"
  defp tab_border("large", false), do: "[&_.tab-trigger]:border-b-4"
  defp tab_border("extra_large", false), do: "[&_.tab-trigger]:border-b-[5px]"
  defp tab_border(params) when is_binary(params), do: [params]
  defp tab_border(nil, false), do: tab_border("none", false)

  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(nil), do: rounded_size("none")

  defp color_variant("default", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA]",
      "[&_.tab-trigger.active-tab]:text-[#d9d9d9] [&_.tab-trigger.active-tab]:border-[#d9d9d9]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border-[#2441de]",
      "[&_.tab-trigger.active-tab]:text-[#162da8] [&_.tab-trigger.active-tab]:border-[#162da8]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#877C7C]",
      "[&_.tab-trigger.active-tab]:text-[#434652] [&_.tab-trigger.active-tab]:border-[#434652]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]",
      "[&_.tab-trigger.active-tab]:text-[#047857] [&_.tab-trigger.active-tab]:border-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]",
      "[&_.tab-trigger.active-tab]:text-[#FF8B08] [&_.tab-trigger.active-tab]:border-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]",
      "[&_.tab-trigger.active-tab]:text-[#E73B3B] [&_.tab-trigger.active-tab]:border-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]",
      "[&_.tab-trigger.active-tab]:text-[#004FC4] [&_.tab-trigger.active-tab]:border-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#52059C]",
      "[&_.tab-trigger.active-tab]:text-[#52059C] [&_.tab-trigger.active-tab]:border-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]",
      "[&_.tab-trigger.active-tab]:text-[#4D4137] [&_.tab-trigger.active-tab]:border-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#707483]",
      "[&_.tab-trigger.active-tab]:text-[#707483] [&_.tab-trigger.active-tab]:border-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#050404]",
      "[&_.tab-trigger.active-tab]:text-[#050404] [&_.tab-trigger.active-tab]:border-[#050404]"
    ]
  end

  defp color_variant("transparent", "white") do
    [
      " [&_.tab-trigger]:text-white [&_.tab-trigger]:border-white",
      "[&_.tab-trigger.active-tab]:text-[#3E3E3E] [&_.tab-trigger.active-tab]:border-[#DADADA]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_.tab-trigger]:text-[#4363EC] [&_.tab-trigger]:border-[#4363EC]",
      "[&_.tab-trigger.active-tab]:text-[#162da8] [&_.tab-trigger.active-tab]:border-[#162da8]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_.tab-trigger]:text-[#6B6E7C] [&_.tab-trigger]:border-[#6B6E7C]",
      "[&_.tab-trigger.active-tab]:text-[#434652] [&_.tab-trigger.active-tab]:border-[#434652]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_.tab-trigger]:text-[#6EE7B7] [&_.tab-trigger]:border-[#6EE7B7]",
      "[&_.tab-trigger.active-tab]:text-[#047857] [&_.tab-trigger.active-tab]:border-[#047857]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_.tab-trigger]:text-[#FFF8E6] [&_.tab-trigger]:border-[#FFF8E6]",
      "[&_.tab-trigger.active-tab]:text-[#FF8B08] [&_.tab-trigger.active-tab]:border-[#FF8B08]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_.tab-trigger]:text-[#FFE6E6] [&_.tab-trigger]:border-[#FFE6E6]",
      "[&_.tab-trigger.active-tab]:text-[#E73B3B] [&_.tab-trigger.active-tab]:border-[#E73B3B]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_.tab-trigger]:text-[#E5F0FF] [&_.tab-trigger]:border-[#E5F0FF]",
      "[&_.tab-trigger.active-tab]:text-[#004FC4] [&_.tab-trigger.active-tab]:border-[#004FC4]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_.tab-trigger]:text-[#FFE6FF] [&_.tab-trigger]:border-[#FFE6FF]",
      "[&_.tab-trigger.active-tab]:text-[#52059C] [&_.tab-trigger.active-tab]:border-[#52059C]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_.tab-trigger]:text-[#FFECDA] [&_.tab-trigger]:border-[#FFECDA]",
      "[&_.tab-trigger.active-tab]:text-[#4D4137] [&_.tab-trigger.active-tab]:border-[#4D4137]"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "[&_.tab-trigger]:text-[#E3E7F1] [&_.tab-trigger]:border-[#E3E7F1]",
      "[&_.tab-trigger.active-tab]:text-[#707483] [&_.tab-trigger.active-tab]:border-[#707483]"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "[&_.tab-trigger]:text-[#1E1E1E] [&_.tab-trigger]:border-[#1E1E1E]",
      "[&_.tab-trigger.active-tab]:text-[#050404] [&_.tab-trigger.active-tab]:border-[#050404]"
    ]
  end
end
