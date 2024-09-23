defmodule MishkaChelekom.Banner do
  @moduledoc """
  This module provides components for rendering customizable banners in your **Phoenix LiveView**
  application.

  ## Features

  - **Banner Component**: Create visually appealing banners with various styles, colors, and sizes.
  - **Dismissable Banners**: Add dismiss buttons to banners to allow users to hide them with a
  smooth transition.
  - **Positioning Options**: Control the positioning of the banners on the screen with flexible
  vertical and horizontal alignment options.
  - **Custom Styles**: Customize the look and feel of your banners using various attributes for size,
  border, padding, and more.
  - **Animation Transitions**: Use built-in JavaScript commands to show and hide banners with
  smooth animation transitions.

  > The main component for rendering a banner with optional inner content and dismiss functionality.

  ## JS Commands

  - `show_banner/2`: Displays the banner element with a smooth transition.
  - `hide_banner/2`: Hides the banner element with a smooth transition.

  Use this module to create interactive and aesthetically pleasing banner elements for
  your **LiveView** applications.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import MishkaChelekomComponents
  import MishkaChelekomWeb.Gettext

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
    "dawn"
  ]

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @positions ["top_left", "top_right", "bottom_left", "bottom_right", "center", "full"]

  @doc """
  The `banner` component is used to display fixed position banners with various customization
  options such as size, color, and position. It supports displaying content through an inner block,
  and attributes like `vertical_position` and `rounded_position` for flexible layout configuration.

  ## Examples

  ```elixir
  <.banner id="banner">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea
      atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>

  <.banner id="banner" color="primary" space="large" vertical_position="bottom">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
      praesentium quidem dicta sapiente accusamus nihil.
    </div>
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque
      soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>

  <.banner id="banner" color="secondary" space="large" vertical_position="top" vertical_size="top-24">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>
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

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :border_position, :string,
    values: ["top", "bottom", "full", "none"],
    default: "top",
    doc: ""

  attr :rounded, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines the border radius"

  attr :rounded_position, :string,
    values: ["top", "bottom", "all", "none"],
    default: "none",
    doc: ""

  attr :space, :string,
    values: @sizes ++ ["none"],
    default: "extra_small",
    doc: "Space between items"

  attr :vertical_position, :string, values: ["top", "bottom"], default: "top", doc: ""
  attr :vertical_size, :string, default: "none", doc: "Specifies the vertical size of the element"

  attr :position, :string,
    values: @positions,
    default: "full",
    doc: "Determines the element position"

  attr :position_size, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines the size for positioning the element"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "extra_small",
    doc: "Determines padding for items"

  attr :class, :string, default: "", doc: "Custom CSS class for additional styling"

  attr :params, :map,
    default: %{kind: "banner"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  attr :rest, :global,
    include: ~w(right_dismiss left_dismiss),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def banner(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden fixed",
        vertical_position(@vertical_size, @vertical_position),
        rounded_size(@rounded, @rounded_position),
        border_class(@border, @border_position),
        color_variant(@variant, @color),
        position_class(@position_size, @position),
        space_class(@space),
        padding_size(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class="flex gap-2 items-center justify-between">
        <div>
          <%= render_slot(@inner_block) %>
        </div>
        <.banner_dismiss id={@id} params={@params} />
      </div>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :dismiss, :boolean,
    default: false,
    doc: "Indicates if the element can be dismissed with a close button."

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  defp banner_dismiss(assigns) do
    ~H"""
    <button
      type="button"
      class="group shrink-0"
      aria-label={gettext("close")}
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_banner("##{@id}")}
    >
      <.icon
        name="hero-x-mark-solid"
        class={[
          "banner-icon opacity-80 group-hover:opacity-70",
          dismiss_size(@size),
          @class
        ]}
      />
    </button>
    """
  end

  defp dismiss_size("extra_small"), do: "size-3.5"
  defp dismiss_size("small"), do: "size-4"
  defp dismiss_size("medium"), do: "size-5"
  defp dismiss_size("large"), do: "size-6"
  defp dismiss_size("extra_large"), do: "size-7"
  defp dismiss_size(params) when is_binary(params), do: params
  defp dismiss_size(_), do: dismiss_size("small")

  defp padding_size("extra_small"), do: "p-2"
  defp padding_size("small"), do: "p-3"
  defp padding_size("medium"), do: "p-4"
  defp padding_size("large"), do: "p-5"
  defp padding_size("extra_large"), do: "p-6"
  defp padding_size("none"), do: "p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("extra_small")

  defp vertical_position("none", "top"), do: "top-0"
  defp vertical_position("extra_small", "top"), do: "top-1"
  defp vertical_position("small", "top"), do: "top-2"
  defp vertical_position("medium", "top"), do: "top-3"
  defp vertical_position("large", "top"), do: "top-4"
  defp vertical_position("extra_large", "top"), do: "top-5"

  defp vertical_position("none", "bottom"), do: "bottom-0"
  defp vertical_position("extra_small", "bottom"), do: "bottom-1"
  defp vertical_position("small", "bottom"), do: "bottom-2"
  defp vertical_position("medium", "bottom"), do: "bottom-3"
  defp vertical_position("large", "bottom"), do: "bottom-4"
  defp vertical_position("extra_large", "bottom"), do: "bottom-5"

  defp vertical_position(params, _) when is_binary(params), do: params
  defp vertical_position(_, _), do: vertical_position("none", "top")

  defp position_class("none", "top_left"), do: "left-0 ml-0"
  defp position_class("extra_small", "top_left"), do: "left-1 ml-1"
  defp position_class("small", "top_left"), do: "left-2 ml-2"
  defp position_class("medium", "top_left"), do: "left-3 ml-3"
  defp position_class("large", "top_left"), do: "left-4 ml-4"
  defp position_class("extra_large", "top_left"), do: "left-5 ml-5"

  defp position_class("none", "top_right"), do: "right-0"
  defp position_class("extra_small", "top_right"), do: "right-1"
  defp position_class("small", "top_right"), do: "right-2"
  defp position_class("medium", "top_right"), do: "right-3"
  defp position_class("large", "top_right"), do: "right-4"
  defp position_class("extra_large", "top_right"), do: "right-5"

  defp position_class("none", "bottom_left"), do: "left-0 ml-0"
  defp position_class("extra_small", "bottom_left"), do: "left-1 ml-1"
  defp position_class("small", "bottom_left"), do: "left-2 ml-2"
  defp position_class("medium", "bottom_left"), do: "left-3 ml-3"
  defp position_class("large", "bottom_left"), do: "left-4 ml-4"
  defp position_class("extra_large", "bottom_left"), do: "left-5 ml-5"

  defp position_class("none", "bottom_right"), do: "right-0"
  defp position_class("extra_small", "bottom_right"), do: "right-1"
  defp position_class("small", "bottom_right"), do: "right-2"
  defp position_class("medium", "bottom_right"), do: "right-3"
  defp position_class("large", "bottom_right"), do: "right-4"
  defp position_class("extra_large", "bottom_right"), do: "right-5"

  defp position_class(_, "center"), do: "mx-auto"
  defp position_class(_, "full"), do: "inset-x-0"

  defp position_class(params, _) when is_binary(params), do: params
  defp position_class(_, _), do: position_class(nil, "full")

  defp rounded_size("extra_small", "top"), do: "rounded-b-sm"
  defp rounded_size("small", "top"), do: "rounded-b"
  defp rounded_size("medium", "top"), do: "rounded-b-md"
  defp rounded_size("large", "top"), do: "rounded-b-lg"
  defp rounded_size("extra_large", "top"), do: "rounded-b-xl"

  defp rounded_size("extra_small", "bottom"), do: "rounded-t-sm"
  defp rounded_size("small", "bottom"), do: "rounded-t"
  defp rounded_size("medium", "bottom"), do: "rounded-t-md"
  defp rounded_size("large", "bottom"), do: "rounded-t-lg"
  defp rounded_size("extra_large", "bottom"), do: "rounded-t-xl"

  defp rounded_size("extra_small", "all"), do: "rounded-sm"
  defp rounded_size("small", "all"), do: "rounded"
  defp rounded_size("medium", "all"), do: "rounded-md"
  defp rounded_size("large", "all"), do: "rounded-lg"
  defp rounded_size("extra_large", "all"), do: "rounded-xl"

  defp rounded_size("none", _), do: "rounded-none"

  defp space_class("none"), do: "space-y-0"
  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"

  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("extra_small")

  defp border_class("none", _), do: "border-0"

  defp border_class("extra_small", "top"), do: "border-b"
  defp border_class("small", "top"), do: "border-b-2"
  defp border_class("medium", "top"), do: "border-b-[3px]"
  defp border_class("large", "top"), do: "border-b-4"
  defp border_class("extra_large", "top"), do: "border-b-[5px]"

  defp border_class("extra_small", "bottom"), do: "border"
  defp border_class("small", "bottom"), do: "border-b-2"
  defp border_class("medium", "bottom"), do: "border-b-[3px]"
  defp border_class("large", "bottom"), do: "border-b-4"
  defp border_class("extra_large", "bottom"), do: "border-b-[5px]"

  defp border_class("extra_small", "full"), do: "border"
  defp border_class("small", "full"), do: "border-2"
  defp border_class("medium", "full"), do: "border-[3px]"
  defp border_class("large", "full"), do: "border-4"
  defp border_class("extra_large", "full"), do: "border-[5px]"

  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: border_class("extra_small", "top")

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

  ## JS Commands
  @doc """
  Displays a banner element with a smooth transition effect.

  ## Parameters

    - `js` (optional): An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the banner element to be shown.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the banner element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from an initial state of reduced opacity and scale
    (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`) to full opacity and scale
    (`opacity-100 translate-y-0 sm:scale-100`) over a duration of 300 milliseconds.

  ## Example

    ```elixir
    show_banner(%JS{}, "#banner-element")
    ```

    This example will show the banner element with the ID banner-element using the defined transition effect.
  """
  def show_banner(js \\ %JS{}, selector) do
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
  Hides a banner element with a smooth transition effect.

  ## Parameters

    - `js` (optional): An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the banner element to be hidden.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to hide the banner element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from full opacity and scale (`opacity-100 translate-y-0 sm:scale-100`)
    to reduced opacity and scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`)
    over a duration of 200 milliseconds.

  ## Example

    ```elixir
    hide_banner(%JS{}, "#banner-element")
    ```

  This example will hide the banner element with the ID banner-element using the defined transition effect.
  """
  def hide_banner(js \\ %JS{}, selector) do
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
