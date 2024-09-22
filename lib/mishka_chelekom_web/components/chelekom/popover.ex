defmodule MishkaChelekom.Popover do
  @moduledoc """
  The `MishkaChelekom.Popover` module provides a versatile popover component for Phoenix LiveView
  applications. It allows developers to create interactive and visually appealing popover elements
  with various customization options.

  This component supports different display configurations, such as inline and block styles, and
  can be triggered by various user interactions like clicks or hover events. The popover can be
  styled using predefined color schemes and variants, including options for shadowed elements.

  The module also offers control over positioning, size, and spacing of the popover content, making
  it adaptable to different use cases. It is built to be highly configurable while maintaining a
  consistent design system across the application.

  By utilizing `slots`, it allows developers to include custom content within the popover and
  trigger elements, enhancing its flexibility and usability for complex UI scenarios.
  """
  use Phoenix.Component
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
    "shadow"
  ]

  @doc """
  Renders a customizable popover component that can display additional information when an element is
  hovered or clicked.

  You can choose between inline and block rendering, and include rich content within the popover.

  ## Examples

  ```elixir
  <p>
    Due to its central geographic location in Southern Europe,
    <.popover inline clickable>
      <.popover_trigger trigger_id="popover-1" inline class="text-blue-400">Italy</.popover_trigger>
      <.popover_content
        id="popover-1"
        rounded="large"
        width="quadruple_large"
        color="light"
        padding="none"
        class="grid grid-cols-5"
        inline
      >
        <span class="block p-2 space-y-5 col-span-3">
          <span class="font-semibold block">About Italy</span>
          <span class="block">
            Italy is located in the middle of the Mediterranean Sea, in Southern Europe,
            and it is also considered part of Western Europe. It is a unitary parliamentary
            republic with Rome as its capital and largest city.
          </span>
          <a href="/" class="block text-blue-400">Read more <.icon name="hero-link" /></a>
        </span>
        <img
          src="https://example.com/italy.png"
          class="h-full w-full col-span-2"
          alt="Map of Italy"
        />
      </.popover_content>
    </.popover>
    has historically been home to myriad peoples and cultures. In addition to the various ancient peoples dispersed throughout what is now modern-day Italy, the most predominant being the Indo-European Italic peoples who gave the peninsula its name, beginning from the classical era, Phoenicians and Carthaginians founded colonies mostly in insular Italy.
  </p>

  <.popover clickable>
    <.popover_trigger trigger_id="popover-2" class="text-blue-400">Hover or Click here</.popover_trigger>
    <.popover_content id="popover-2" color="light" rounded="large" padding="medium">
      <div class="p-4">
        <h4 class="text-lg font-semibold">Popover Title</h4>
        <p class="mt-2">This is a simple popover example with content that can be customized.</p>
      </div>
    </.popover_content>
  </.popover>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def popover(%{inline: true} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        "inline-block relative w-fit",
        "[&_.popover-content]:invisible [&_.popover-content]:opacity-0",
        "[&_.popover-content.show-popover]:visible [&_.popover-content.show-popover]:opacity-100",
        !@clickable && tirgger_popover(),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  def popover(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "relative w-fit",
        "[&_.popover-content]:invisible [&_.popover-content]:opacity-0",
        "[&_.popover-content.show-popover]:visible [&_.popover-content.show-popover]:opacity-100",
        !@clickable && tirgger_popover(),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a popover trigger element, which is used to show or hide a popover content element.
  The trigger can be rendered as either an inline or block element. When the trigger is clicked,
  it toggles the visibility of the associated popover content.

  ## Examples

  ```elixir
  <p>
    Discover more about
    <.popover_trigger trigger_id="popover-1" inline class="text-blue-400">Italy</.popover_trigger>
    by clicking on the name.
    <.popover_content
      id="popover-1"
      inline
      rounded="large"
      width="quadruple_large"
      color="light"
      padding="none"
      class="grid grid-cols-5"
    >
      <span class="block p-2 space-y-5 col-span-3">
        <span class="font-semibold block">About Italy</span>
        <span class="block">
          Italy is located in the middle of the Mediterranean Sea, in Southern Europe, and it is also considered part of Western Europe. It is a unitary parliamentary republic with Rome as its capital and largest city.
        </span>
        <a href="/" class="block text-blue-400">Read more <.icon name="hero-link" /></a>
      </span>
      <img
        src="https://flowbite.com/docs/images/popovers/italy.png"
        class="h-full w-full col-span-2"
        alt="Map of Italy"
      />
    </.popover_content>
  </p>

  <.popover_trigger trigger_id="popover-2" class="text-blue-400">
    Hover or Click here to show the popover
  </.popover_trigger>
  <.popover_content id="popover-2" color="light" rounded="large" padding="medium">
    <div class="p-4">
      <h4 class="text-lg font-semibold">Popover Title</h4>
      <p class="mt-2">This is a simple popover example with content that can be customized.</p>
    </div>
  </.popover_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :trigger_id, :string, default: nil, doc: "Identifies what is the triggered element id"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def popover_trigger(%{inline: true} = assigns) do
    ~H"""
    <span
      id={@id}
      phx-click-away={@trigger_id && JS.remove_class("show-popover", to: "##{@trigger_id}")}
      phx-click={@trigger_id && JS.toggle_class("show-popover", to: "##{@trigger_id}")}
      class={["inline-block cursor-pointer popover-trigger", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  def popover_trigger(assigns) do
    ~H"""
    <div
      id={@id}
      phx-click-away={@trigger_id && JS.remove_class("show-popover", to: "##{@trigger_id}")}
      phx-click={@trigger_id && JS.toggle_class("show-popover", to: "##{@trigger_id}")}
      class={["cursor-pointer popover-trigger", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a popover content element, which displays additional information when the associated
  popover trigger is activated.

  The content can be positioned relative to the trigger and customized with various styles,
  such as color, padding, and size.

  ## Examples

  ```elixir
  <.popover_content id="popover-3" inline position="top" color="dark" rounded="small" padding="small">
    <span class="block text-white p-2">This is a tooltip message!</span>
  </.popover_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"
  attr :position, :string, default: "top", doc: "Determines the element position"
  attr :variant, :string, values: @variants, default: "shadow", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"

  attr :size, :string,
    default: nil,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: nil, doc: "Space between items"
  attr :width, :string, default: "extra_large", doc: "Determines the element width"
  attr :text_position, :string, default: "start", doc: "Determines the element' text position"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "none", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def popover_content(%{inline: true} = assigns) do
    ~H"""
    <span
      role="tooltip"
      id={@id}
      class={[
        "popover-content absolute z-10 w-full",
        "transition-all ease-in-out delay-100 duratio-500",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        position_class(@position),
        text_position(@text_position),
        width_class(@width),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <span class={["block absolute size-[8px] bg-inherit rotate-45 popover-arrow"]}></span>
    </span>
    """
  end

  def popover_content(assigns) do
    ~H"""
    <div
      role="dialog "
      id={@id}
      class={[
        "popover-content absolute z-10 w-full",
        "transition-all ease-in-out delay-100 duratio-500",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        position_class(@position),
        text_position(@text_position),
        width_class(@width),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <span class={[
        "block absolute size-[8px] bg-inherit rotate-45 popover-arrow"
      ]}>
      </span>
    </div>
    """
  end

  defp tirgger_popover(),
    do: "[&_.popover-content]:hover:visible [&_.popover-content]:hover:opacity-100"

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("small")

  defp position_class("top") do
    [
      "bottom-full left-1/2 -translate-x-1/2 -translate-y-[6px]",
      "[&>.popover-arrow]:-bottom-[4px] [&>.popover-arrow]:-translate-x-1/2 [&>.popover-arrow]:left-1/2"
    ]
  end

  defp position_class("bottom") do
    [
      "top-full left-1/2 -translate-x-1/2 translate-y-[6px]",
      "[&>.popover-arrow]:-top-[4px] [&>.popover-arrow]:-translate-x-1/2 [&>.popover-arrow]:left-1/2"
    ]
  end

  defp position_class("left") do
    [
      "right-full top-1/2 -translate-y-1/2 -translate-x-[6px]",
      "[&>.popover-arrow]:-right-[4px] [&>.popover-arrow]:translate-y-1/2 [&>.popover-arrow]:top-1/3"
    ]
  end

  defp position_class("right") do
    [
      "left-full top-1/2 -translate-y-1/2 translate-x-[6px]",
      "[&>.popover-arrow]:-left-[4px] [&>.popover-arrow]:translate-y-1/2 [&>.popover-arrow]:top-1/3"
    ]
  end

  defp size_class("extra_small"), do: "text-xs max-w-60 [&_.popover-title-icon]:size-3"
  defp size_class("small"), do: "text-sm max-w-64 [&_.popover-title-icon]:size-3.5"
  defp size_class("medium"), do: "text-base max-w-72 [&_.popover-title-icon]:size-4"
  defp size_class("large"), do: "text-lg max-w-80 [&_.popover-title-icon]:size-5"
  defp size_class("extra_large"), do: "text-xl max-w-96 [&_.popover-title-icon]:size-6"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medium")

  defp text_position("left"), do: "text-left"
  defp text_position("right"), do: "text-right"
  defp text_position("center"), do: "text-center"
  defp text_position("justify"), do: "text-justify"
  defp text_position("start"), do: "text-start"
  defp text_position("end"), do: "text-end"
  defp text_position(_), do: text_position("start")

  defp width_class("extra_small"), do: "min-w-48"
  defp width_class("small"), do: "min-w-52"
  defp width_class("medium"), do: "min-w-56"
  defp width_class("large"), do: "min-w-60"
  defp width_class("extra_large"), do: "min-w-64"
  defp width_class("double_large"), do: "min-w-72"
  defp width_class("triple_large"), do: "min-w-80"
  defp width_class("quadruple_large"), do: "min-w-96"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("extra_large")

  defp wrapper_padding("extra_small") do
    "[&:has(.popover-section)>.popover-section]:p-1 [&:not(:has(.popover-section))]:p-1"
  end

  defp wrapper_padding("small") do
    "[&:has(.popover-section)>.popover-section]:p-2 [&:not(:has(.popover-section))]:p-2"
  end

  defp wrapper_padding("medium") do
    "[&:has(.popover-section)>.popover-section]:p-3 [&:not(:has(.popover-section))]:p-3"
  end

  defp wrapper_padding("large") do
    "[&:has(.popover-section)>.popover-section]:p-4 [&:not(:has(.popover-section))]:p-4"
  end

  defp wrapper_padding("extra_large") do
    "[&:has(.popover-section)>.popover-section]:p-5 [&:not(:has(.popover-section))]:p-5"
  end

  defp wrapper_padding("none"), do: "p-0"
  defp wrapper_padding(params) when is_binary(params), do: params
  defp wrapper_padding(_), do: wrapper_padding("none")

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white shadow-md"
  end
end
