defmodule MishkaChelekom.Avatar do
  @moduledoc """
  The `MishkaChelekom.Avatar` module provides a set of components for creating and
  managing avatar elements in your **Phoenix LiveView** applications.

  It supports various avatar types, including standard avatars, placeholders, and placeholder icons.
  You can customize the appearance and behavior of avatars using attributes such as size, color,
  border, and shadow.

  ### Components

  - **Avatar (`avatar/1`)**: Renders an individual avatar element, which can include an image,
  icon, or text content. The component supports several attributes for customization,
  such as size, color, shadow, and border radius. Slots are available for adding additional
  content like icons.

  - **Avatar Group (`avatar_group/1`)**: Renders a group of avatar elements arranged in a flex container.
  You can control the spacing between avatars and provide custom styling using the
  available attributes and slots.
  """

  use Phoenix.Component
  import MishkaChelekomComponents

  # TODO: We need Avatar tooltip
  # TODO: We need dropdown
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

  @doc """
  The `avatar` component is used to display user avatars with various customization options,
  including size, shape, and styling.

  It supports displaying an image or an icon with optional inner content.

  ## Examples

  ```elixir
  <.avatar size="medium" rounded="full" color="light">
    <:icon name="hero-user" />
    <.indicator size="small" bottom_right />
  </.avatar>

  <.avatar src="https://example.com/profile.jpg" size="extra_small" rounded="full">
    <.indicator size="extra_small" bottom_left />
  </.avatar>

  <.avatar src="https://example.com/profile.jpg" size="extra_large" rounded="full">
    <.indicator size="extra_small" color="success" top_left />
  </.avatar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon"],
    default: "default",
    doc: ""

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :src, :string, default: nil, doc: "Media link"

  attr :color, :string,
    values: @colors ++ ["transparent"],
    default: "transparent",
    doc: "Determines color theme"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :shadow, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines shadow style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "medium",
    doc: "Determines the border radius"

  attr :border, :string, default: "none", doc: "Determines border style"

  slot :icon, required: false do
    attr :name, :string, required: true, doc: "Specifies the name of the element"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"
  end

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def avatar(%{src: src, rounded: "full"} = assigns) when not is_nil(src) do
    ~H"""
    <div class={[
      "relative w-fit",
      size_class(@size, :image)
    ]}>
      <img
        id={@id}
        src={@src}
        class={[
          image_color(@color),
          rounded_size(@rounded),
          border_class(@border),
          shadow_class(@shadow),
          @class
        ]}
        {@rest}
      />
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def avatar(%{src: src, rounded: "full"} = assigns) when is_nil(src) do
    ~H"""
    <div class={
      default_classes() ++
        [
          color_class(@color),
          rounded_size(@rounded),
          size_class(@size, :text),
          border_class(@border),
          shadow_class(@shadow),
          @font_weight,
          @class
        ]
    }>
      <div :for={icon <- @icon} class={[icon[:size], icon[:color], icon[:class]]}>
        <.icon name={icon[:name]} class={icon[:icon_class] || size_class(@size, :icon)} />
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def avatar(%{src: src} = assigns) when not is_nil(src) do
    ~H"""
    <div class="relative">
      <img
        id={@id}
        src={@src}
        class={[
          image_color(@color),
          rounded_size(@rounded),
          size_class(@size),
          border_class(@border),
          shadow_class(@shadow),
          @class
        ]}
        {@rest}
      />
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def avatar(assigns) do
    ~H"""
    <div class={
      default_classes() ++
        [
          color_class(@color),
          rounded_size(@rounded),
          size_class(@size),
          border_class(@border),
          shadow_class(@shadow),
          @font_weight,
          @class
        ]
    }>
      <div :for={icon <- @icon} class={[icon[:size], icon[:color], icon[:class]]}>
        <.icon name={icon[:name]} class={icon[:icon_class] || size_class(@size, :icon)} />
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  The `avatar_group` component is used to display a group of avatars with customizable spacing and layout.
  It supports different types of avatars such as `default`, `placeholder`, and `placeholder_icon`,
  allowing for flexible content presentation within a group.

  ## Examples

  ```elixir
  <.avatar_group>
    <.avatar src="https://example.com/profile.jpg" size="large" color="dark" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" border="extra_large" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" color="warning" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" color="dark" rounded="full"/>
    <.avatar size="large" rounded="full" border="medium">+20</.avatar>
  </.avatar_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon", nil],
    default: "default",
    doc: "Specifies the type of avatar group to be rendered"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :space, :string, values: @sizes ++ ["none"], default: "medium", doc: "Space between items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def avatar_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex items-center",
        space_class(@space),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp image_color("transparent") do
    "border-0"
  end

  defp image_color("white") do
    "border border-white"
  end

  defp image_color("primary") do
    "border border-[#4363EC]"
  end

  defp image_color("secondary") do
    "border border-[#6B6E7C]"
  end

  defp image_color("success") do
    "border border-[#227A52]"
  end

  defp image_color("warning") do
    "border border-[#FF8B08]"
  end

  defp image_color("danger") do
    "border border-[#E73B3B]"
  end

  defp image_color("info") do
    "border border-[#6663FD]"
  end

  defp image_color("misc") do
    "border border-[#52059C]"
  end

  defp image_color("dawn") do
    "border border-[#4D4137]"
  end

  defp image_color("light") do
    "border border-[#707483]"
  end

  defp image_color("dark") do
    "border border-[#1E1E1E]"
  end

  defp image_color(params), do: params

  defp color_class("white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_class("primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_class("secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_class("success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_class("warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_class("danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_class("info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_class("misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_class("dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_class("light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_class("dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_class(_), do: color_class("white")

  defp border_class("extra_small"), do: "border-avatar border"
  defp border_class("small"), do: "border-avatar border-2"
  defp border_class("medium"), do: "border-avatar border-[3px]"
  defp border_class("large"), do: "border-avatar border-4"
  defp border_class("extra_large"), do: "border-avatar border-[5px]"
  defp border_class("none"), do: "border-0"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("none")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(params) when is_binary(params), do: params
  defp rounded_size(_), do: rounded_size("medium")

  defp size_class("extra_small"), do: "size-8 text-xs"
  defp size_class("small"), do: "size-9 text-sm"
  defp size_class("medium"), do: "size-10 text-base"
  defp size_class("large"), do: "size-12 text-lg"
  defp size_class("extra_large"), do: "size-14 text-xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp size_class("extra_small", :icon), do: "size-4"
  defp size_class("small", :icon), do: "size-5"
  defp size_class("medium", :icon), do: "size-6"
  defp size_class("large", :icon), do: "size-7"
  defp size_class("extra_large", :icon), do: "size-8"
  defp size_class(params, :icon) when is_binary(params), do: params
  defp size_class(_, :icon), do: size_class("small", :icon)

  defp size_class("extra_small", :image) do
    [
      "[&>img]:size-8 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("small", :image) do
    [
      "[&>img]:size-9 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("medium", :image) do
    [
      "[&>img]:size-10 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("large", :image) do
    [
      "[&>img]:size-11 [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("extra_large", :image) do
    [
      "[&>img]:size-12 [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class(params, :image) when is_binary(params), do: params
  defp size_class(_, :image), do: size_class("small", :image)

  defp size_class("extra_small", :text) do
    [
      "size-8 text-xs [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("small", :text) do
    [
      "size-9 text-sm [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("medium", :text) do
    [
      "size-10 text-base [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("large", :text) do
    [
      "size-11 text-lg [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("extra_large", :text) do
    [
      "size-12 text-xl [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class(params, :text) when is_binary(params), do: params
  defp size_class(_, :text), do: size_class("small", :text)

  defp shadow_class("extra_small"), do: "shadow-sm"
  defp shadow_class("small"), do: "shadow"
  defp shadow_class("medium"), do: "shadow-md"
  defp shadow_class("large"), do: "shadow-lg"
  defp shadow_class("extra_large"), do: "shadow-xl"
  defp shadow_class("none"), do: "shadow-none"
  defp shadow_class(params) when is_binary(params), do: params
  defp shadow_class(_), do: shadow_class("none")

  defp space_class("extra_small"), do: "-space-x-2"
  defp space_class("small"), do: "-space-x-3"
  defp space_class("medium"), do: "-space-x-4"
  defp space_class("large"), do: "-space-x-5"
  defp space_class("extra_large"), do: "-space-x-6"
  defp space_class("none"), do: "space-x-0"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp default_classes() do
    [
      "relative inline-flex items-center justify-center p-0.5 [&.border-avatar:has(.indicator)]:box-content"
    ]
  end
end
