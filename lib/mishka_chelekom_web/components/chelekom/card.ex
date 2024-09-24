defmodule MishkaChelekom.Card do
  @moduledoc """
  Provides a set of card components for the `MishkaChelekom.Card` project. These components
  allow for flexible and customizable card layouts, including features such as card titles,
  media, content sections, and footers.

  ## Components

    - `card/1`: Renders a basic card container with customizable size, color, border,
    padding, and other styling options.
    - `card_title/1`: Renders a title section for the card with support for icons and
    custom positioning.
    - `card_media/1`: Renders a media section within the card, such as an image or other media types.
    - `card_content/1`: Renders a content section within the card to display various information.
    - `card_footer/1`: Renders a footer section for the card, suitable for additional
    information or actions.

  ## Configuration Options

  The module supports various attributes such as size, color, variant, and border
  styles to match different design requirements. Components can be nested and
  combined to create complex card layouts with ease.

  This module offers a powerful and easy-to-use way to create cards with consistent
  styling and behavior while providing the flexibility to adapt to various use cases.
  """

  use Phoenix.Component

  @sizes [
    "extra_small",
    "small",
    "medium",
    "large",
    "extra_large",
    "double_large",
    "triple_large",
    "quadruple_large"
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

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @positions [
    "start",
    "center",
    "end",
    "between",
    "around"
  ]

  @doc """
  The `card` component is used to display content in a structured container with various customization options such as `variant`, `color`, and `padding`. It supports an inner block for rendering nested content like media, titles, and footers, allowing for flexible layout designs.

  ## Examples

  ```elixir
  <.card>
    <.card_title title="This is a title in inner content" icon="hero-home" size="extra_large" />
    <.card_content>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
      quidem dicta sapiente accusamus nihil.
    </.card_content>
  </.card>

  <.card>
    <.card_media src="https://example.com/bg.png" alt="test"/>
    <.card_content padding="large">
      <p>
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
        quidem dicta sapiente accusamus nihil.
      </p>
    </.card_content>
    <.card_footer padding="large">
      <.button size="full">See more</.button>
    </.card_footer>
  </.card>

  <.card padding="small">
    <.card_title class="flex items-center gap-2 justify-between">
      <div>Title</div>
      <div>Link</div>
    </.card_title>
    <MishkaChelekom.Divider.hr />
    <.card_content space="large">
      <.card_media rounded="large" src="https://example.com/bg.png" alt="test"/>
      <p>
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
        praesentium quidem dicta sapiente accusamus nihil.
      </p>
    </.card_content>
    <MishkaChelekom.Divider.hr />
    <.card_footer class="flex items-center gap-2">
      <.card_media src="https://example.com/bg.png" alt="test"/>
      <.card_media src="https://example.com/bg.png" alt="test"/>
      <.card_media src="https://example.com/bg.png" alt="test"/>
    </.card_footer>
  </.card>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: nil, doc: "Determines the border radius"
  attr :space, :string, default: nil, doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: nil, doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden",
        space_class(@space),
        border_class(@border),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `card_title` component is used to display the title section of a card with customizable
  attributes such as `position`, `size`, and `padding`.

  It supports adding an optional icon alongside the title and includes an inner block for additional content.

  ## Examples

  ```elixir
  <.card_title class="border-b" padding="small" position="between">
    <div>Title</div>
    <div><.icon name="hero-ellipsis-horizontal" /></div>
  </.card_title>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :position, :string,
    values: @positions,
    default: "start",
    doc: "Determines the element position"

  attr :font_weight, :string,
    default: "font-semibold",
    doc: "Determines custom class for the font weight"

  attr :size, :string,
    values: @sizes,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :padding, :string, default: "none", doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_title(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section flex items-center gap-2",
        padding_size(@padding),
        content_position(@position),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div :if={@title || @icon} class="flex gap-2 items-center">
        <.icon :if={@icon} name={@icon} class="card-title-icon" />
        <h3 :if={@title}><%= @title %></h3>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `card_media` component is used to display media elements, such as images, within a card.

  It supports customizable attributes like `rounded` and `class` for styling and can include an inner
  block for additional content.

  ## Examples

  ```elixir
  <.card_media src="https://example.com/bg.png" alt="test"/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :alt, :string, doc: "Media link description"
  attr :src, :string, required: true, doc: "Media link"

  attr :rounded, :string,
    values: @sizes ++ [nil],
    default: nil,
    doc: "Determines the border radius"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_media(assigns) do
    ~H"""
    <div id={@id}>
      <img
        src={@src}
        alt={@alt}
        class={[
          "max-w-full",
          rounded_size(@rounded),
          @class
        ]}
      />
    </div>
    """
  end

  @doc """
  The `card_content` component is used to display the main content of a card with customizable attributes
  such as `padding` and `space` between items.

  It supports an inner block for rendering additional content, allowing for flexible layout and styling.

  ## Examples

  ```elixir
  <.card_content padding="large">
    <p>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
      quidem dicta sapiente accusamus nihil.
    </p>
  </.card_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :space, :string, values: @sizes, default: "extra_small", doc: "Space between items"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines padding for items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_content(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section",
        space_class(@space),
        padding_size(@padding),
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `card_footer` component is used to display the footer section of a card, allowing for
  additional actions or information at the bottom of the card.

  It supports customizable attributes such as `padding` and `class` for styling and includes an
  inner block for rendering content.

  ## Examples

  ```elixir
  <.card_footer padding="large">
    <.button size="full">See more</.button>
  </.card_footer>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_footer(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section",
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp border_class("none"), do: "border-0"
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: "rounded-none"

  defp size_class("extra_small"), do: "text-xs [&_.card-title-icon]:size-3"
  defp size_class("small"), do: "text-sm [&_.card-title-icon]:size-3.5"
  defp size_class("medium"), do: "text-base [&_.card-title-icon]:size-4"
  defp size_class("large"), do: "text-lg [&_.card-title-icon]:size-5"
  defp size_class("extra_large"), do: "text-xl [&_.card-title-icon]:size-6"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("large")

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position("between") do
    "justify-between"
  end

  defp content_position("around") do
    "justify-around"
  end

  defp content_position(_), do: content_position("start")

  defp wrapper_padding("extra_small"),
    do: "[&:has(.card-section)>.card-section]:p-1 [&:not(:has(.card-section))]:p-1"

  defp wrapper_padding("small"),
    do: "[&:has(.card-section)>.card-section]:p-2 [&:not(:has(.card-section))]:p-2"

  defp wrapper_padding("medium"),
    do: "[&:has(.card-section)>.card-section]:p-3 [&:not(:has(.card-section))]:p-3"

  defp wrapper_padding("large"),
    do: "[&:has(.card-section)>.card-section]:p-4 [&:not(:has(.card-section))]:p-4"

  defp wrapper_padding("extra_large"),
    do: "[&:has(.card-section)>.card-section]:p-5 [&:not(:has(.card-section))]:p-5"

  defp wrapper_padding("none"), do: "p-0"
  defp wrapper_padding(params) when is_binary(params), do: params
  defp wrapper_padding(_), do: wrapper_padding("none")

  defp padding_size("extra_small"), do: "p-1"
  defp padding_size("small"), do: "p-2"
  defp padding_size("medium"), do: "p-3"
  defp padding_size("large"), do: "p-4"
  defp padding_size("extra_large"), do: "p-5"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: nil

  defp space_class("extra_small"), do: "space-y-2"
  defp space_class("small"), do: "space-y-3"
  defp space_class("medium"), do: "space-y-4"
  defp space_class("large"), do: "space-y-5"
  defp space_class("extra_large"), do: "space-y-6"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: "space-y-0"

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

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
