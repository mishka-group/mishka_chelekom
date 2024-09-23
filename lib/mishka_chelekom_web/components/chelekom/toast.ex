defmodule MishkaChelekom.Toast do
  @moduledoc """
  A module for creating toast notifications in a Phoenix application.

  This module provides components for rendering toast messages, including
  options for customization such as size, color, and dismiss behavior. It
  supports a variety of visual styles and positions, allowing for
  flexible integration into any user interface.

  Toasts can be used to provide feedback to users or display
  informational messages without interrupting their workflow. The
  components defined in this module handle the presentation and
  interaction logic, enabling developers to easily implement toast
  notifications within their applications.

  > You can create a toast notification with various styles and
  > configurations to suit your application's needs.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import MishkaChelekomComponents
  import MishkaChelekomWeb.Gettext

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
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc """
  The `toast` component displays temporary notifications or messages, usually at the top
  or bottom of the screen.

  It supports customization for size, color, border, and positioning, allowing you to
  style the toast as needed.

  ## Examples

  ```elixir
  <.toast id="toast-1">
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>

  <.toast
    id="toast-2"
    color="success"
    content_border="small"
    border_position="end"
    horizontal="center"
    vertical_space="large"
  >
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>

  <.toast
    id="toast-3"
    color="misc"
    horizontal="left"
    content_border="extra_small"
    border_position="start"
    rounded="medium"
    width="extra_large"
  >
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :fixed, :boolean, default: true, doc: "Determines whether the element is fixed"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "medium", doc: "Determines the border radius"
  attr :width, :string, default: "medium", doc: "Determines the element width"
  attr :space, :string, default: "extra_small", doc: "Space between items"
  attr :vertical, :string, values: ["top", "bottom"], default: "top", doc: "Type of vertical"
  attr :vertical_space, :string, default: "extra_small", doc: "Space between vertical items"

  attr :horizontal, :string,
    values: ["left", "right", "center"],
    default: "right",
    doc: "Type of horizontal"

  attr :horizontal_space, :string, default: "extra_small", doc: "Space between horizontal items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :class, :string, default: "", doc: "Additional CSS classes to be added to the toast."

  attr :params, :map,
    default: %{kind: "toast"},
    doc: "A map of additional parameters used for element configuration"

  attr :rest, :global,
    include: ~w(right_dismiss left_dismiss),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :content_border, :string, default: "none", doc: "Determines the content border style"
  attr :border_position, :string, default: "start", doc: "Determines the border position style"
  attr :row_direction, :string, default: "none", doc: "Determines row direction"
  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden",
        @fixed && "fixed",
        space_class(@space),
        width_class(@width),
        rounded_size(@rounded),
        border_class(@border),
        color_variant(@variant, @color),
        position_class(@horizontal_space, @horizontal),
        vertical_position(@vertical_space, @vertical),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class={[
        "toast-content-wrapper relative",
        "before:block before:absolute before:inset-y-0 before:rounded-full before:my-1",
        content_border(@content_border),
        @content_border != "none" && boder_position(@border_position)
      ]}>
        <div class={[
          "flex gap-2 items-center justify-between",
          row_direction(@row_direction),
          padding_size(@padding)
        ]}>
          <div>
            <%= render_slot(@inner_block) %>
          </div>
          <.toast_dismiss id={@id} params={@params} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  The `toast_group` component is used to group multiple `toast` elements together,
  allowing for coordinated display and positioning of toast notifications.

  ## Examples

  ```elixir
  <.toast_group vertical_space="large" horizontal_space="extra_large">
    <.toast
      id="toast-1"
      color="success"
      content_border="small"
      border_position="end"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>

    <.toast
      id="toast-2"
      variant="outline"
      color="danger"
      content_border="small"
      border_position="start"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>

    <.toast
      id="toast-3"
      variant="unbordered"
      color="warning"
      content_border="small"
      border_position="start"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>
  </.toast_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :space, :string, default: "small", doc: "Space between items"
  attr :vertical, :string, values: ["top", "bottom"], default: "bottom", doc: "Type of vertical"
  attr :vertical_space, :string, default: "extra_small", doc: "Space between vertical items"

  attr :horizontal, :string,
    values: ["left", "right", "center"],
    default: "right",
    doc: "Type of horizontal"

  attr :horizontal_space, :string, default: "extra_small", doc: "Space between horizontal items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def toast_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed",
        space_class(@space),
        position_class(@horizontal_space, @horizontal),
        vertical_position(@vertical_space, @vertical),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :dismiss, :boolean,
    default: false,
    doc: "Determines if the toast should include a dismiss button"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :params, :map,
    default: %{kind: "toast"},
    doc: "A map of additional parameters used for element configuration"

  defp toast_dismiss(assigns) do
    ~H"""
    <button
      type="button"
      class="group shrink-0"
      aria-label={gettext("close")}
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_toast("##{@id}")}
    >
      <.icon
        name="hero-x-mark-solid"
        class={[
          "toast-icon opacity-80 group-hover:opacity-70",
          dismiss_size(@size),
          @class
        ]}
      />
    </button>
    """
  end

  defp boder_position("end"), do: "pe-1.5 before:end-1"
  defp boder_position("start"), do: "ps-1.5 before:start-1"
  defp boder_position(params) when is_binary(params), do: params
  defp boder_position(_), do: boder_position("start")

  defp content_border("extra_small"), do: "before:w-0.5"
  defp content_border("small"), do: "before:w-1"
  defp content_border("medium"), do: "before:w-1.5"
  defp content_border("large"), do: "before:w-2"
  defp content_border("extra_large"), do: "before:w-2.5"
  defp content_border("none"), do: "before:content-none"
  defp content_border(params) when is_binary(params), do: params
  defp content_border(_), do: content_border("none")

  defp row_direction("none"), do: "flex-row"
  defp row_direction("reverse"), do: "flex-row-reverse"
  defp row_direction(_), do: row_direction("none")

  defp padding_size("extra_small"), do: "p-2"
  defp padding_size("small"), do: "p-3"
  defp padding_size("medium"), do: "p-4"
  defp padding_size("large"), do: "p-5"
  defp padding_size("extra_large"), do: "p-6"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("extra_small")

  defp width_class("extra_small"), do: "max-w-60"
  defp width_class("small"), do: "max-w-64"
  defp width_class("medium"), do: "max-w-72"
  defp width_class("large"), do: "max-w-80"
  defp width_class("extra_large"), do: "max-w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("medium")

  defp dismiss_size("extra_small"), do: "size-3.5"
  defp dismiss_size("small"), do: "size-4"
  defp dismiss_size("medium"), do: "size-5"
  defp dismiss_size("large"), do: "size-6"
  defp dismiss_size("extra_large"), do: "size-7"
  defp dismiss_size(params) when is_binary(params), do: params
  defp dismiss_size(_), do: dismiss_size("small")

  defp vertical_position("extra_small", "top"), do: "top-1"
  defp vertical_position("small", "top"), do: "top-2"
  defp vertical_position("medium", "top"), do: "top-3"
  defp vertical_position("large", "top"), do: "top-4"
  defp vertical_position("extra_large", "top"), do: "top-5"

  defp vertical_position("extra_small", "bottom"), do: "bottom-1"
  defp vertical_position("small", "bottom"), do: "bottom-2"
  defp vertical_position("medium", "bottom"), do: "bottom-3"
  defp vertical_position("large", "bottom"), do: "bottom-4"
  defp vertical_position("extra_large", "bottom"), do: "bottom-5"

  defp vertical_position(params, _) when is_binary(params), do: params
  defp vertical_position(_, _), do: vertical_position("none", "top")

  defp position_class("extra_small", "left"), do: "left-1 ml-1"
  defp position_class("small", "left"), do: "left-2 ml-2"
  defp position_class("medium", "left"), do: "left-3 ml-3"
  defp position_class("large", "left"), do: "left-4 ml-4"
  defp position_class("extra_large", "left"), do: "left-5 ml-5"

  defp position_class("extra_small", "right"), do: "right-1 mr-1"
  defp position_class("small", "right"), do: "right-2 mr-2"
  defp position_class("medium", "right"), do: "right-3 mr-3"
  defp position_class("large", "right"), do: "right-4 mr-4"
  defp position_class("extra_large", "right"), do: "right-5 mr-5"

  defp position_class(_, "center"), do: "left-1/2 -translate-x-1/2"

  defp position_class(params, _) when is_binary(params), do: params
  defp position_class(_, _), do: position_class("extra_small", "right")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"

  defp space_class("none"), do: "space-y-0"
  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("extra_small")

  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp color_variant("default", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA]",
      "[&>.toast-content-wrapper]:before:bg-[#DADADA]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#4363EC] text-white border-[#2441de]",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#877C7C]",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]",
      "[&>.toast-content-wrapper]:before:bg-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]",
      "[&>.toast-content-wrapper]:before:bg-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]",
      "[&>.toast-content-wrapper]:before:bg-[#E73B3B]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]",
      "[&>.toast-content-wrapper]:before:bg-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#52059C]",
      "[&>.toast-content-wrapper]:before:bg-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]",
      "[&>.toast-content-wrapper]:before:bg-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#707483]",
      "[&>.toast-content-wrapper]:before:bg-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#050404]",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("outline", "white") do
    [
      "bg-white text-[#1E1E1E] border-white",
      "[&>.toast-content-wrapper]:before:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "bg-white text-[#4363EC] border-[#4363EC]",
      "[&>.toast-content-wrapper]:before:bg-[#4363EC]"
    ]
  end

  defp color_variant("outline", "secondary") do
    ["bg-white text-[#6B6E7C] border-[#6B6E7C]", "[&>.toast-content-wrapper]:before:bg-[#6B6E7C]"]
  end

  defp color_variant("outline", "success") do
    ["bg-white text-[#227A52] border-[#6EE7B7]", "[&>.toast-content-wrapper]:before:bg-[#227A52]"]
  end

  defp color_variant("outline", "warning") do
    ["bg-white text-[#FF8B08] border-[#FF8B08]", "[&>.toast-content-wrapper]:before:bg-[#FF8B08]"]
  end

  defp color_variant("outline", "danger") do
    ["bg-white text-[#E73B3B] border-[#E73B3B]", "[&>.toast-content-wrapper]:before:bg-[#E73B3B]"]
  end

  defp color_variant("outline", "info") do
    ["bg-white text-[#004FC4] border-[#004FC4]", "[&>.toast-content-wrapper]:before:bg-[#004FC4]"]
  end

  defp color_variant("outline", "misc") do
    ["bg-white text-[#52059C] border-[#52059C]", "[&>.toast-content-wrapper]:before:bg-[#52059C]"]
  end

  defp color_variant("outline", "dawn") do
    ["bg-white text-[#4D4137] border-[#4D4137]", "[&>.toast-content-wrapper]:before:bg-[#4D4137]"]
  end

  defp color_variant("outline", "light") do
    ["bg-white text-[#707483] border-[#707483]", "[&>.toast-content-wrapper]:before:bg-[#707483]"]
  end

  defp color_variant("outline", "dark") do
    ["bg-white text-[#1E1E1E] border-[#1E1E1E]", "[&>.toast-content-wrapper]:before:bg-[#1E1E1E]"]
  end

  defp color_variant("unbordered", "white") do
    [
      "bg-white text-[#3E3E3E] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("unbordered", "primary") do
    ["bg-[#4363EC] text-white border-transparent", "[&>.toast-content-wrapper]:before:bg-white"]
  end

  defp color_variant("unbordered", "secondary") do
    ["bg-[#6B6E7C] text-white border-transparent", "[&>.toast-content-wrapper]:before:bg-white"]
  end

  defp color_variant("unbordered", "success") do
    [
      "bg-[#ECFEF3] text-[#047857] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#047857]"
    ]
  end

  defp color_variant("unbordered", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#FF8B08]"
    ]
  end

  defp color_variant("unbordered", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#E73B3B]"
    ]
  end

  defp color_variant("unbordered", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#004FC4]"
    ]
  end

  defp color_variant("unbordered", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#-[#]"
    ]
  end

  defp color_variant("unbordered", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#4D4137]"
    ]
  end

  defp color_variant("unbordered", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-transparent",
      "[&>.toast-content-wrapper]:before:bg-[#707483]"
    ]
  end

  defp color_variant("unbordered", "dark") do
    ["bg-[#1E1E1E] text-white border-transparent", "[&>.toast-content-wrapper]:before:bg-white"]
  end

  defp color_variant("shadow", "white") do
    [
      "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#4363EC] text-white border-[#4363EC] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#227A52]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#FF8B08]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#E73B3B]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#004FC4]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#52059C]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#4D4137]"
    ]
  end

  defp color_variant("shadow", "light") do
    [
      "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-[#707483]"
    ]
  end

  defp color_variant("shadow", "dark") do
    [
      "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  ## JS Commands

  @doc """
  Displays a toast notification.

  This function shows a toast notification by applying a specified transition effect to the
  element identified by the provided `selector`. It utilizes the `JS.show/2` function to handle
  the showing animation with a duration of 300 milliseconds.

  ## Parameters

  - `js` (optional): A `JS` struct that can be used to chain further JavaScript actions.
  - `selector`: A string representing the CSS selector for the toast element to be displayed.

  ## Example

  ```elixir
  show_toast(js, "#my-toast")
  ```

  This documentation provides a clear explanation of what the function does,
  its parameters, and an example usage.
  """
  def show_toast(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  @doc """
  Hides a toast notification.

  This function hides a toast notification by applying a specified transition effect to the
  element identified by the provided `selector`. It utilizes the `JS.hide/2` function to handle
  the hiding animation with a duration of 200 milliseconds.

  ## Parameters

  - `js` (optional): A `JS` struct that can be used to chain further JavaScript actions.
  - `selector`: A string representing the CSS selector for the toast element to be hidden.

  ## Example

  ```elixir
  hide_toast(js, "#my-toast")
  ```

  This documentation clearly outlines the purpose of the function, its parameters,
  and an example of how to use it.
  """
  def hide_toast(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end
end
