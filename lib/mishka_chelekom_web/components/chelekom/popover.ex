defmodule MishkaChelekom.Popover do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Avoid placing block-level elements inside a `<p>` tag if you want to use inline popover. These include:
   - `<div>`
   - `<header>`
   - `<footer>`
   - `<section>`
   - `<article>`
   - `<aside>`
   - `<h1>`, `<h2>`, `<h3>`, etc.
   - `<nav>`
   - `<form>`
   - `<table>`
   - `<ul>`, `<ol>`, `<li>`
    These elements create their own block context and should not be nested within a paragraph.

    2. **Other `<p>` Tags**: Nesting one `<p>` tag inside another can lead to invalid HTML and unexpected rendering.

    3. **Semantic Inconsistencies**: While you can technically include inline elements like:
     `<a>`, `<strong>`, `<em>`, `<span>`, and `<img>` within a `<p>` tag,
      avoid misusing them or using them in ways that don't align with their semantic purpose.

    4. **Structural Tags**: Tags that define the structure of the document or a section, like:
    `<main>`, `<section>`, `<article>`, `<aside>`, `<figure>`, etc., should not be inside a `<p>` tag.

    ### Proper Usage
  The `<p>` tag should primarily contain inline elements,
  such as text, `<a>`, `<strong>`, `<em>`, `<span>`, and `<img>`
  (with caution), or other inline elements that do not disrupt the flow of text within the paragraph.

  """

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
  attr :class, :string, default: nil, doc: ""
  attr :inline, :boolean, default: false, doc: ""
  attr :clickable, :boolean, default: false, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

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

  attr :id, :string, default: nil, doc: ""
  attr :trigger_id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :inline, :boolean, default: false, doc: ""
  slot :inner_block, required: false, doc: ""
  attr :rest, :global, doc: ""

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

  attr :id, :string, default: nil, doc: ""
  attr :inline, :boolean, default: false, doc: ""
  attr :position, :string, default: "top", doc: ""
  attr :variant, :string, values: @variants, default: "shadow", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :size, :string, default: nil, doc: ""
  attr :space, :string, default: nil, doc: ""
  attr :width, :string, default: "extra_large", doc: ""
  attr :text_position, :string, default: "start", doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :padding, :string, default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

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
