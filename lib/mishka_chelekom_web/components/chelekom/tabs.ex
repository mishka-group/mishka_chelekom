defmodule MishkaChelekom.Tabs do
  @moduledoc """
  `MishkaChelekom.Tabs` is a Phoenix component module that provides a highly customizable tab
  interface for organizing and displaying content.

  It allows the creation of both horizontal and vertical tabs with different styles, colors, and sizes.

  The component supports various features such as icon placement, active state management,
  and different border and padding options.

  ## Features

  - **Vertical and Horizontal Layouts:** Choose between a vertical or horizontal arrangement for the tabs.
  - **Customizable Styles:** Supports multiple `variant` styles such as `default`, `outline`, and `pills`.
  - **Flexible Size Options:** Adjust the overall size of elements, including padding and font size.
  - **Color Themes:** Offers a range of color themes such as `primary`, `secondary`, `success`, and more.
  - **Active State Management:** Automatically manages active states and interactions with tabs.
  - **Dynamic Content Slots:** Define tab and panel content using dynamic slots for easy customization.

  ### Functionality:

  The component uses Phoenix.LiveView.JS to manage the visibility and active state of the tabs dynamically.
  It provides utility functions like show_tab/3 and hide_tab/3 for controlling the visibility of specific
  tabs and panels programmatically.
  """

  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS

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
    "outline",
    "pills"
  ]

  @doc """
  The `Tabs` component provides a set of clickable tabs for organizing content.

  Each tab can have an icon and supports various styles and configurations like vertical
  or horizontal alignment.

  ## Examples

  ```elixir
  <.tabs id="tab-1" color="warning" padding="large" gap="small" variant="pills" vertical>
      <:tab icon="hero-home">1</:tab>
      <:tab icon="hero-home">2</:tab>
      <:tab icon="hero-home" active>3</:tab>

      <:panel>
        <p>
          Tab1 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
        </p>
      </:panel>
      <:panel>
        <p>
          Tab2 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
        </p>
      </:panel>
      <:panel>
        <p>
          Tab3 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
        </p>
      </:panel>
  </.tabs>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "none", doc: "Determines border style"
  attr :tab_border, :string, default: "small", doc: "Determines border style for tab"

  attr :size, :string,
    default: "small",
    doc: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :gap, :string, default: nil, doc: "Determines gap for tabs"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"
  attr :triggers_position, :string, default: "extra_small", doc: ""
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"
  attr :placement, :string, default: "start", doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :tab, required: true do
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :padding, :string, doc: "Determines padding for items"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :icon_position, :string, doc: "Determines icon position"
    attr :active, :boolean, doc: "Indicates whether the element is currently active and visible"
  end

  slot :panel, required: true do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def tabs(%{vertical: true} = assigns) do
    assigns =
      assign_new(assigns, :mounted_active_tab, fn ->
        Enum.find(assigns.tab, &Map.get(&1, :active))
      end)

    ~H"""
    <div
      id={@id}
      phx-mounted={is_nil(@mounted_active_tab) && hide_tab(@id, length(@tab)) |> show_tab(@id, 1)}
      class={[
        "vertical-tab flex",
        @placement == "end" && "flex-row-reverse",
        content_position(@triggers_position),
        @variant == "default" && tab_border(@tab_border, @vertical),
        color_variant(@variant, @color),
        rounded_size(@rounded, @variant),
        padding_size(@padding),
        border_class(@border),
        size_class(@size),
        gap_size(@gap),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div role="tablist" tabindex="0" class="tab-trigger-list flex flex-col shrink-0">
        <button
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          id={"#{@id}-tab-header-#{index}"}
          phx-show-tab={hide_tab(@id, length(@tab)) |> show_tab(@id, index)}
          phx-click={JS.exec("phx-show-tab", to: "##{@id}-tab-header-#{index}")}
          phx-mounted={tab[:active] && JS.exec("phx-show-tab", to: "##{@id}-tab-header-#{index}")}
          role="tab"
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
          id={"#{@id}-tab-panel-#{index}"}
          role="tabpanel"
          class={[
            "tab-content",
            "[&:not(.active-tab-panel)]:hidden [&:not(.active-tab-panel)]:opacity-0 [&:not(.active-tab-panel)]:invisible",
            "[&.active-tab-panel]:block [&.active-tab-panel]:opacity-100 [&.active-tab-panel]:visible"
          ]}
        >
          <%= render_slot(panel) %>
        </div>
      </div>
    </div>
    """
  end

  def tabs(assigns) do
    assigns =
      assign_new(assigns, :mounted_active_tab, fn ->
        Enum.find(assigns.tab, &Map.get(&1, :active))
      end)

    ~H"""
    <div
      id={@id}
      phx-mounted={is_nil(@mounted_active_tab) && hide_tab(@id, length(@tab)) |> show_tab(@id, 1)}
      class={[
        "horizontal-tab w-full",
        content_position(@triggers_position),
        @variant == "default" && tab_border(@tab_border, @vertical),
        color_variant(@variant, @color),
        rounded_size(@rounded, @variant),
        padding_size(@padding),
        border_class(@border),
        size_class(@size),
        gap_size(@gap),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div role="tablist" tabindex="0" class="tab-trigger-list w-full flex flex-wrap flex-wrap">
        <button
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          id={"#{@id}-tab-header-#{index}"}
          phx-click={hide_tab(@id, length(@tab)) |> show_tab(@id, index)}
          role="tab"
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
          id={"#{@id}-tab-panel-#{index}"}
          role="tabpanel"
          class={[
            "tab-content",
            "[&:not(.active-tab-panel)]:hidden [&:not(.active-tab-panel)]:opacity-0 [&:not(.active-tab-panel)]:invisible",
            "[&.active-tab-panel]:block [&.active-tab-panel]:opacity-100 [&.active-tab-panel]:visible"
          ]}
        >
          <%= render_slot(panel) %>
        </div>
      </div>
    </div>
    """
  end

  defp content_position("start") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-start",
      "[&_.vetrical-tab_.tab-trigger-list]:justify-start"
    ]
  end

  defp content_position("end") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-end",
      "[&_.vertical-tab_.tab-trigger-list]:justify-end"
    ]
  end

  defp content_position("center") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-center",
      "[&_.vertical-tab_.tab-trigger-list]:justify-center"
    ]
  end

  defp content_position("between") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-between",
      "[&_.vertical-tab_.tab-trigger-list]:justify-between"
    ]
  end

  defp content_position("around") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-around",
      "[&_.vertical-tab_.tab-trigger-list]:justify-around"
    ]
  end

  defp content_position(_), do: content_position("start")

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

  defp gap_size("extra_small"), do: "[&_.tab-trigger-list]:gap-1"
  defp gap_size("small"), do: "[&_.tab-trigger-list]:gap-2"
  defp gap_size("medium"), do: "[&_.tab-trigger-list]:gap-3"
  defp gap_size("large"), do: "[&_.tab-trigger-list]:gap-4"
  defp gap_size("extra_large"), do: "[&_.tab-trigger-list]:gap-5"
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
  defp tab_border(params, true) when is_binary(params), do: [params]
  defp tab_border(_, true), do: tab_border("extra_small", true)

  defp tab_border("none", false) do
    [
      "[&_.tab-trigger]:border-b-0  [&_.tab-trigger-list]:border-b-0"
    ]
  end

  defp tab_border("extra_small", false) do
    [
      "[&_.tab-trigger]:border-b [&_.tab-trigger]:-mb-px [&_.tab-trigger-list]:border-b"
    ]
  end

  defp tab_border("small", false) do
    [
      "[&_.tab-trigger]:border-b-2 [&_.tab-trigger]:-mb-0.5 [&_.tab-trigger-list]:border-b-2"
    ]
  end

  defp tab_border("medium", false) do
    [
      "[&_.tab-trigger]:border-b-[3px]  [&_.tab-trigger]:-mb-1 [&_.tab-trigger-list]:border-b-[3px]"
    ]
  end

  defp tab_border("large", false) do
    [
      "[&_.tab-trigger]:border-b-4 [&_.tab-trigger]:-mb-1.5 [&_.tab-trigger-list]:border-b-4"
    ]
  end

  defp tab_border("extra_large", false) do
    [
      "[&_.tab-trigger]:border-b-[5px] [&_.tab-trigger]:-mb-2 [&_.tab-trigger-list]:border-b-[5px]"
    ]
  end

  defp tab_border(params, false) when is_binary(params), do: [params]
  defp tab_border(_, false), do: tab_border("extra_small", false)

  defp rounded_size(_, "default"), do: "rounded-none"

  defp rounded_size("none", "pills"), do: "[&_.tab-trigger]:rounded-none"
  defp rounded_size("extra_small", "pills"), do: "[&_.tab-trigger]:rounded-sm"
  defp rounded_size("small", "pills"), do: "[&_.tab-trigger]:rounded"
  defp rounded_size("medium", "pills"), do: "[&_.tab-trigger]:rounded-md"
  defp rounded_size("large", "pills"), do: "[&_.tab-trigger]:rounded-lg"
  defp rounded_size("extra_large", "pills"), do: "[&_.tab-trigger]:rounded-xl"
  defp rounded_size("full", "pills"), do: "[&_.tab-trigger]:rounded-full"

  defp rounded_size("none", "outline"), do: "[&_.tab-trigger]:rounded-t-none"
  defp rounded_size("extra_small", "outline"), do: "[&_.tab-trigger]:rounded-t-sm"
  defp rounded_size("small", "outline"), do: "[&_.tab-trigger]:rounded-t"
  defp rounded_size("medium", "outline"), do: "[&_.tab-trigger]:rounded-t-md"
  defp rounded_size("large", "outline"), do: "[&_.tab-trigger]:rounded-t-lg"
  defp rounded_size("extra_large", "outline"), do: "[&_.tab-trigger]:rounded-t-xl"
  defp rounded_size("full", "outline"), do: "[&_.tab-trigger]:rounded-t-full"

  defp rounded_size(params, _) when is_binary(params), do: [params]
  defp rounded_size(_, _), do: rounded_size(nil, "default")

  defp color_variant("default", "white") do
    [
      "[&_.tab-trigger.active-tab]:text-[#3E3E3E] [&_.tab-trigger.active-tab]:border-[#DADADA]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.tab-trigger.active-tab]:text-[#162da8] [&_.tab-trigger.active-tab]:border-[#162da8]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#162da8]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.tab-trigger.active-tab]:text-[#434652] [&_.tab-trigger.active-tab]:border-[#434652]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#434652]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.tab-trigger.active-tab]:text-[#047857] [&_.tab-trigger.active-tab]:border-[#047857]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.tab-trigger.active-tab]:text-[#FF8B08] [&_.tab-trigger.active-tab]:border-[#FF8B08]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.tab-trigger.active-tab]:text-[#E73B3B] [&_.tab-trigger.active-tab]:border-[#E73B3B]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.tab-trigger.active-tab]:text-[#004FC4] [&_.tab-trigger.active-tab]:border-[#004FC4]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.tab-trigger.active-tab]:text-[#52059C] [&_.tab-trigger.active-tab]:border-[#52059C]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.tab-trigger.active-tab]:text-[#4D4137] [&_.tab-trigger.active-tab]:border-[#4D4137]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "[&_.tab-trigger.active-tab]:text-[#707483] [&_.tab-trigger.active-tab]:border-[#707483]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.tab-trigger.active-tab]:text-[#050404] [&_.tab-trigger.active-tab]:border-[#050404]",
      "[&_.tab-trigger-list]:border-[#e9ecef] hover:[&_.tab-trigger]:text-[#050404]"
    ]
  end

  defp color_variant("pills", "white") do
    [
      "[&_.tab-trigger.active-tab]:bg-white hover:[&_.tab-trigger]:bg-white",
      "[&_.tab-trigger.active-tab]:text-[#3E3E3E] [&_.tab-trigger.active-tab]:border-[#DADADA]"
    ]
  end

  defp color_variant("pills", "primary") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#6B6E7C] hover:[&_.tab-trigger]:bg-[#6B6E7C] hover:[&_.tab-trigger]:text-white",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:border-[#877C7C]"
    ]
  end

  defp color_variant("pills", "secondary") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#4363EC] hover:[&_.tab-trigger]:bg-[#4363EC] hover:[&_.tab-trigger]:text-white",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:border-[#434652]"
    ]
  end

  defp color_variant("pills", "success") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#ECFEF3] hover:[&_.tab-trigger]:bg-[#ECFEF3]",
      "[&_.tab-trigger.active-tab]:text-[#047857] [&_.tab-trigger.active-tab]:border-[#047857]"
    ]
  end

  defp color_variant("pills", "warning") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#FFF8E6] hover:[&_.tab-trigger]:bg-[#FFF8E6]",
      "[&_.tab-trigger.active-tab]:text-[#FF8B08] [&_.tab-trigger.active-tab]:border-[#FF8B08]"
    ]
  end

  defp color_variant("pills", "danger") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#FFE6E6] hover:[&_.tab-trigger]:bg-[#FFE6E6]",
      "[&_.tab-trigger.active-tab]:text-[#E73B3B] [&_.tab-trigger.active-tab]:border-[#E73B3B]"
    ]
  end

  defp color_variant("pills", "info") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#E5F0FF] hover:[&_.tab-trigger]:bg-[#E5F0FF]",
      "[&_.tab-trigger.active-tab]:text-[#004FC4] [&_.tab-trigger.active-tab]:border-[#004FC4]"
    ]
  end

  defp color_variant("pills", "misc") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#FFE6FF] hover:[&_.tab-trigger]:bg-[#FFE6FF]",
      "[&_.tab-trigger.active-tab]:text-[#52059C] [&_.tab-trigger.active-tab]:border-[#52059C]"
    ]
  end

  defp color_variant("pills", "dawn") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#FFECDA] hover:[&_.tab-trigger]:bg-[#FFECDA]",
      "[&_.tab-trigger.active-tab]:text-[#4D4137] [&_.tab-trigger.active-tab]:border-[#4D4137]"
    ]
  end

  defp color_variant("pills", "light") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#E3E7F1] hover:[&_.tab-trigger]:bg-[#E3E7F1]",
      "[&_.tab-trigger.active-tab]:text-[#707483] [&_.tab-trigger.active-tab]:border-[#707483]"
    ]
  end

  defp color_variant("pills", "dark") do
    [
      "[&_.tab-trigger.active-tab]:bg-[#1E1E1E] hover:[&_.tab-trigger]:bg-[#1E1E1E] hover:[&_.tab-trigger]:text-white",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:border-[#050404]"
    ]
  end

  @doc """
  Sets a specific tab as active by adding `active-tab` and `active-tab-panel` CSS classes to the
  selected tab and its corresponding panel.

  ## Parameters

    - `js` (optional): A `%Phoenix.LiveView.JS{}` struct that allows chaining multiple JS commands.
    Defaults to an empty `%JS{}`.
    - `id`: A `string` representing the unique identifier for the tab group.
    - `count`: An `integer` indicating the tab number to be activated.

  ## Usage

  ```elixir
  show_tab(%JS{}, "example-tabs", 2)
  ```
  This will activate the second tab and its corresponding panel in the tab group with the ID `example-tabs`.
  """

  def show_tab(js \\ %JS{}, id, count) when is_binary(id) do
    JS.add_class(js, "active-tab", to: "##{id}-tab-header-#{count}")
    |> JS.add_class("active-tab-panel", to: "##{id}-tab-panel-#{count}")
  end

  @doc """
  Hides all tabs in a given tab group by removing the `active-tab` and `active-tab-panel` CSS
  classes from each tab and its corresponding panel.

  ## Parameters

    - `js` (optional): A `%Phoenix.LiveView.JS{}` struct used to chain multiple JS commands.
    Defaults to an empty `%JS{}`.
    - `id`: A `string` representing the unique identifier for the tab group.
    - `count`: An `integer` indicating the total number of tabs in the group.

  ## Usage

  ```elixir
  hide_tab(%JS{}, "example-tabs", 3)
  ```

  This will deactivate all three tabs and their corresponding panels in the tab group
  with the ID `example-tabs`.
  """
  def hide_tab(js \\ %JS{}, id, count) do
    Enum.reduce(1..count, js, fn item, acc ->
      acc
      |> JS.remove_class("active-tab", to: "##{id}-tab-header-#{item}")
      |> JS.remove_class("active-tab-panel", to: "##{id}-tab-panel-#{item}")
    end)
  end
end
