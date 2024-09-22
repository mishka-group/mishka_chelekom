defmodule MishkaChelekom.Drawer do
  @moduledoc """
  The `MishkaChelekom.Drawer` module provides a flexible and customizable drawer component
  for use in Phoenix LiveView applications.

  ## Features:
  - **Positioning:** Drawers can be positioned on the left, right, top, or bottom of the screen.
  - **Styling Variants:** Offers several styling options like `default`, `outline`,
  `transparent`, `shadow`, and `unbordered`.
  - **Color Themes:** Supports a variety of predefined color themes, including `primary`,
  `secondary`, `success`, `danger`, `info`, and more.
  - **Customizable:** Allows customization of border style, size, border radius,
  and padding to fit various design needs.
  - **Interactive:** Integrated with `Phoenix.LiveView.JS` for show/hide functionality and
  nteraction management.
  - **Slots Support:** Includes slots for adding a custom header and inner content,
  with full HEEx support for dynamic rendering.
  """
  use Phoenix.Component
  import MishkaChelekomComponents
  alias Phoenix.LiveView.JS
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
  A drawer component for displaying content in a sliding panel. It can be positioned on the left or
  right side of the viewport and controlled using custom JavaScript actions.

  ## Examples

  ```elixir
  <.drawer id="acc-left" show={true}>
    Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
    praesentium quidem dicta sapiente accusamus nihil.
  </.drawer>

  <.drawer id="acc-right" title_class="text-2xl font-light" position="right">
    <:header><p>Right Drawer</p></:header>
    Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
    quidem dicta sapiente accusamus nihil.
  </.drawer>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :title_class, :string, default: nil, doc: "Determines custom class for the title"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"
  attr :position, :string, default: "left", doc: "Determines the element position"
  attr :space, :string, default: nil, doc: "Space between items"
  attr :padding, :string, default: "none", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :on_hide, JS, default: %JS{}, doc: "Custom JS module for on_hide action"
  attr :on_show, JS, default: %JS{}, doc: "Custom JS module for on_show action"
  attr :on_hide_away, JS, default: %JS{}, doc: "Custom JS module for on_hide_away action"
  attr :show, :boolean, default: false, doc: "Show element"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :header, required: false, doc: "Specifies element's header that accepts heex"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def drawer(assigns) do
    ~H"""
    <div
      id={@id}
      phx-click-away={hide_drawer(@on_hide_away, @id, @position)}
      phx-mounted={@show && show_drawer(@on_show, @id, @position)}
      phx-remove={hide_drawer(@id, @position)}
      class={[
        "fixed z-50 p-2 overflow-y-auto transition-transform",
        translate_position(@position),
        size_class(@size, @position),
        position_class(@position),
        border_class(@border, @position),
        color_variant(@variant, @color),
        @class
      ]}
      tabindex="-1"
      aria-labelledby={"#{@id}-#{@position}-label"}
      {@rest}
    >
      <div class="flex flex-row-reverse justify-between items-center gap-5 mb-2">
        <button type="button" phx-click={JS.exec(@on_hide, "phx-remove", to: "##{@id}")}>
          <.icon name="hero-x-mark" />
          <span class="sr-only"><%= gettext("Close menu") %></span>
        </button>
        <h5
          :if={title = @title || render_slot(@header)}
          id={"#{@id}-#{@position}-title"}
          class={[@title_class || "text-lg font-semibold"]}
        >
          <%= title %>
        </h5>
      </div>

      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp translate_position("left"), do: "-translate-x-full"
  defp translate_position("right"), do: "translate-x-full"
  defp translate_position("bottom"), do: "translate-y-full"
  defp translate_position("top"), do: "-translate-y-full"

  defp position_class("left"), do: "top-0 left-0 h-screen"
  defp position_class("right"), do: "top-0 right-0 h-screen"
  defp position_class("top"), do: "top-0 inset-x-0 w-full"
  defp position_class("bottom"), do: "bottom-0 inset-x-0 w-full"
  defp position_class(params) when is_binary(params), do: params
  defp position_class(_), do: position_class("left")

  defp border_class("none", _), do: "border-0"

  defp border_class("extra_small", "left"), do: "border-r"
  defp border_class("small", "left"), do: "border-r-2"
  defp border_class("medium", "left"), do: "border-r-[3px]"
  defp border_class("large", "left"), do: "border-r-4"
  defp border_class("extra_large", "left"), do: "border-r-[5px]"

  defp border_class("extra_small", "right"), do: "border-l"
  defp border_class("small", "right"), do: "border-l-2"
  defp border_class("medium", "right"), do: "border-l-[3px]"
  defp border_class("large", "right"), do: "border-l-4"
  defp border_class("extra_large", "right"), do: "border-l-[5px]"

  defp border_class("extra_small", "top"), do: "border-b"
  defp border_class("small", "top"), do: "border-b-2"
  defp border_class("medium", "top"), do: "border-b-[3px]"
  defp border_class("large", "top"), do: "border-b-4"
  defp border_class("extra_large", "top"), do: "border-b-[5px]"

  defp border_class("extra_small", "bottom"), do: "border-t"
  defp border_class("small", "bottom"), do: "border-t-2"
  defp border_class("medium", "bottom"), do: "border-t-[3px]"
  defp border_class("large", "bottom"), do: "border-t-4"
  defp border_class("extra_large", "bottom"), do: "border-t-[5px]"

  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: border_class("extra_small", "left")

  defp size_class("extra_small", "left"), do: "w-60"
  defp size_class("small", "left"), do: "w-64"
  defp size_class("medium", "left"), do: "w-72"
  defp size_class("large", "left"), do: "w-80"
  defp size_class("extra_large", "left"), do: "w-96"

  defp size_class("extra_small", "right"), do: "w-60"
  defp size_class("small", "right"), do: "w-64"
  defp size_class("medium", "right"), do: "w-72"
  defp size_class("large", "right"), do: "w-80"
  defp size_class("extra_large", "right"), do: "w-96"

  defp size_class("extra_small", "top"), do: "min-h-32"
  defp size_class("small", "top"), do: "min-h-36"
  defp size_class("medium", "top"), do: "min-h-40"
  defp size_class("large", "top"), do: "min-h-44"
  defp size_class("extra_large", "top"), do: "min-h-48"

  defp size_class("extra_small", "bottom"), do: "min-h-32"
  defp size_class("small", "bottom"), do: "min-h-36"
  defp size_class("medium", "bottom"), do: "min-h-40"
  defp size_class("large", "bottom"), do: "min-h-44"
  defp size_class("extra_large", "bottom"), do: "min-h-48"

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

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end

  @doc """
  Shows the drawer component by modifying its CSS classes to transition it into view.

  ## Parameters:
    - `js` (optional, `Phoenix.LiveView.JS`): The JS struct used to chain JavaScript commands.
    Defaults to an empty `%JS{}`.
    - `id` (string): The unique identifier of the drawer element to show.
    - `position` (string): The position of the drawer, such as "left", "right", "top", or "bottom".

  ## Behavior:
  Removes the CSS class that keeps the drawer off-screen and adds the class `"transform-none"`
  to bring the drawer into view.

  ## Examples:

  ```elixir
  show_drawer(%JS{}, "drawer-id", "left")
  ```

  This will show the drawer with ID `drawer-id` positioned on the left side of the screen.
  """
  def show_drawer(js \\ %JS{}, id, position) when is_binary(id) do
    JS.remove_class(js, translate_position(position), to: "##{id}")
    |> JS.add_class("transform-none", to: "##{id}")
  end

  @doc """
  Hides the drawer component by modifying its CSS classes to transition it out of view.

  ## Parameters:
    - `js` (optional, `Phoenix.LiveView.JS`): The JS struct used to chain JavaScript commands. Defaults to an empty `%JS{}`.
    - `id` (string): The unique identifier of the drawer element to hide.
    - `position` (string): The position of the drawer, such as "left", "right", "top", or "bottom".

  ## Behavior:
  Removes the `"transform-none"` CSS class that keeps the drawer visible and adds the class based on the drawer's position (e.g., `"-translate-x-full"` for a left-positioned drawer) to move the drawer off-screen.

  ## Examples:

  ```elixir
  hide_drawer(%JS{}, "drawer-id", "left")
  ```

  This will hide the drawer with ID "drawer-id" positioned on the left side of the screen.
  """
  def hide_drawer(js \\ %JS{}, id, position) do
    JS.remove_class(js, "transform-none", to: "##{id}")
    |> JS.add_class(translate_position(position), to: "##{id}")
  end
end
