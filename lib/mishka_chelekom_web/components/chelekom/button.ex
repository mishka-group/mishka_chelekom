defmodule MishkaChelekom.Button do
  use Phoenix.Component
  import MishkaChelekomComponents

  # TODO: We need Loader for Button, after creating spinner module

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "outline",
    "transparent",
    "subtle",
    "shadow",
    "inverted",
    "default_gradient",
    "outline_gradient",
    "inverted_gradient",
    "unbordered"
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
    "dawn",
    "transparent"
  ]

  @indicator_positions [
    "indicator",
    "right_indicator",
    "left_indicator",
    "top_left_indicator",
    "top_center_indicator",
    "top_right_indicator",
    "middle_left_indicator",
    "middle_right_indicator",
    "bottom_left_indicator",
    "bottom_center_indicator",
    "bottom_right_indicator"
  ]

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :variation, :string, values: ["horizontal", "vertical"], default: "horizontal", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :border, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "small", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def button_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes(:grouped) ++
          [
            variation(@variation),
            rounded_size(@rounded),
            border(@color),
            @class
          ]
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :type, :string, values: ["button", "submit", "reset", nil], default: nil, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :indicator_class, :string, default: nil, doc: ""
  attr :indicator_size, :string, default: nil, doc: ""

  attr :rest, :global,
    include:
      ~w(disabled form name value right_icon left_icon pinging circle) ++ @indicator_positions,
    doc: ""

  slot :inner_block, required: false, doc: ""

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      id={@id}
      class={
        default_classes(@rest[:pinging]) ++
          size_class(@size, @rest[:circle]) ++
          [
            color_variant(@variant, @color),
            rounded_size(@rounded),
            @font_weight,
            @class
          ]
      }
      {drop_rest(@rest)}
    >
      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />
    </button>
    """
  end

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :navigate, :string, doc: ""
  attr :patch, :string, doc: ""
  attr :href, :string, doc: ""
  attr :variant, :string, values: @variants, default: "default", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr :indicator_class, :string, default: nil, doc: ""
  attr :indicator_size, :string, default: nil, doc: ""

  attr :rest, :global,
    include:
      ~w(right_icon left_icon pinging circle download hreflang referrerpolicy rel target type csrf_token method replace) ++
        @indicator_positions,
    doc: ""

  slot :inner_block, required: false, doc: ""

  def button_link(%{navigate: _navigate} = assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      id={@id}
      class={
        default_classes(@rest[:pinging]) ++
          size_class(@size, @rest[:circle]) ++
          [
            color_variant(@variant, @color),
            rounded_size(@rounded),
            @font_weight,
            @class
          ]
      }
      {drop_rest(@rest)}
    >
      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />
    </.link>
    """
  end

  def button_link(%{patch: _patch} = assigns) do
    ~H"""
    <.link
      patch={@patch}
      id={@id}
      class={
        default_classes(@rest[:pinging]) ++
          size_class(@size, @rest[:circle]) ++
          [
            color_variant(@variant, @color),
            rounded_size(@rounded),
            @font_weight,
            @class
          ]
      }
      {drop_rest(@rest)}
    >
      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />
    </.link>
    """
  end

  def button_link(%{href: _href} = assigns) do
    ~H"""
    <.link
      href={@href}
      id={@id}
      class={
        default_classes(@rest[:pinging]) ++
          size_class(@size, @rest[:circle]) ++
          [
            color_variant(@variant, @color),
            rounded_size(@rounded),
            @font_weight,
            @class
          ]
      }
      {drop_rest(@rest)}
    >
      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <%= render_slot(@inner_block) %>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />
    </.link>
    """
  end

  attr :position, :string, default: "none"
  attr :class, :string, default: nil
  attr :size, :string
  attr :rest, :global

  defp button_indicator(%{position: "left", rest: %{left_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "left", rest: %{indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{right_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 right-1/2"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{middle_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{middle_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2"
    ]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
    ]} />
    """
  end

  defp button_indicator(assigns) do
    ~H"""
    """
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] hover:bg-[#E8E8E8] hover:border-[#d9d9d9]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de] hover:bg-[#072ed3] hover:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#3d3f49] hover:bg-[#60636f] hover:border-[#3d3f49]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] hover:bg-[#d4fde4] hover:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08] hover:bg-[#fff1cd] hover:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B] hover:bg-[#ffcdcd] hover:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4] hover:bg-[#cce1ff] hover:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C] hover:bg-[#ffe0ff] hover:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137] hover:bg-[#ffdfc1] hover:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483] hover:bg-[#d2d8e9] hover:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404] hover:bg-[#111111] hover:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white hover:text-[#E8E8E8] hover:border-[#E8E8E8]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] hover:text-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:text-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#227A52] hover:text-[#50AF7A] hover:border-[#50AF7A]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] hover:text-[#FFB045] hover:border-[#FFB045]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B] hover:text-[#F0756A] hover:border-[#F0756A]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] hover:text-[#3680DB] hover:border-[#3680DB]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] hover:text-[#8535C3] hover:border-[#8535C3]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] hover:text-[#948474] hover:border-[#948474]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483] hover:text-[#A0A5B4] hover:border-[#A0A5B4]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:text-[#787878] hover:border-[#787878]"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent hover:text-[#E8E8E8]"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent hover:text-[#072ed3]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent hover:text-[#60636f]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent hover:text-[#50AF7A]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent hover:text-[#FFB045]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent hover:text-[#F0756A]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent hover:text-[#3680DB]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent hover:text-[#8535C3]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent hover:text-[#948474]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent hover:text-[#A0A5B4]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent hover:text-[#787878]"
  end

  defp color_variant("subtle", "white") do
    "bg-transparent text-white border-transparent hover:bg-white hover:text-[#3E3E3E]"
  end

  defp color_variant("subtle", "primary") do
    "bg-transparent text-[#4363EC] border-transparent hover:bg-[#4363EC] hover:text-white"
  end

  defp color_variant("subtle", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent hover:bg-[#6B6E7C] hover:text-white"
  end

  defp color_variant("subtle", "success") do
    "bg-transparent text-[#227A52] border-transparent hover:bg-[#AFEAD0] hover:text-[#227A52]"
  end

  defp color_variant("subtle", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent hover:bg-[#FFF8E6] hover:text-[#FF8B08]"
  end

  defp color_variant("subtle", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent hover:bg-[#FFE6E6] hover:text-[#E73B3B]"
  end

  defp color_variant("subtle", "info") do
    "bg-transparent text-[#6663FD] border-transparent hover:bg-[#E5F0FF] hover:text-[#103483]"
  end

  defp color_variant("subtle", "misc") do
    "bg-transparent text-[#52059C] border-transparent hover:bg-[#FFE6FF] hover:text-[#52059C]"
  end

  defp color_variant("subtle", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent hover:bg-[#FFECDA] hover:text-[#4D4137]"
  end

  defp color_variant("subtle", "light") do
    "bg-transparent text-[#707483] border-transparent hover:bg-[#E3E7F1] hover:text-[#707483]"
  end

  defp color_variant("subtle", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent hover:bg-[#111111] hover:text-white"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md hover:bg-[#E8E8E8] hover:border-[#d9d9d9]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md hover:bg-[#072ed3] hover:border-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md hover:bg-[#60636f] hover:border-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#6EE7B7] shadow-md hover:bg-[#d4fde4] hover:border-[#d4fde4]"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md hover:bg-[#fff1cd] hover:border-[#fff1cd]"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md hover:bg-[#ffcdcd] hover:border-[#ffcdcd]"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md hover:bg-[#cce1ff] hover:border-[#cce1ff]"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md hover:bg-[#ffe0ff] hover:border-[#ffe0ff]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md hover:bg-[#ffdfc1] hover:border-[#ffdfc1]"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md hover:bg-[#d2d8e9] hover:border-[#d2d8e9]"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md hover:bg-[#111111] hover:border-[#111111]"
  end

  defp color_variant("inverted", "white") do
    "bg-transparent text-white border-white hover:bg-white hover:text-[#3E3E3E] hover:border-[#DADADA]"
  end

  defp color_variant("inverted", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] hover:bg-[#4363EC] hover:text-white hover:border-[#4363EC]"
  end

  defp color_variant("inverted", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] hover:bg-[#6B6E7C] hover:text-white hover:border-[#6B6E7C]"
  end

  defp color_variant("inverted", "success") do
    "bg-transparent text-[#227A52] border-[#227A52] hover:bg-[#AFEAD0] hover:text-[#227A52] hover:border-[#AFEAD0]"
  end

  defp color_variant("inverted", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] hover:bg-[#FFF8E6] hover:text-[#FF8B08] hover:border-[#FFF8E6]"
  end

  defp color_variant("inverted", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]  hover:bg-[#FFE6E6] hover:text-[#E73B3B] hover:border-[#FFE6E6]"
  end

  defp color_variant("inverted", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] hover:bg-[#E5F0FF] hover:text-[#103483] hover:border-[#E5F0FF]"
  end

  defp color_variant("inverted", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] hover:bg-[#FFE6FF] hover:text-[#52059C] hover:border-[#FFE6FF]"
  end

  defp color_variant("inverted", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] hover:bg-[#FFECDA] hover:text-[#4D4137] hover:border-[#FFECDA]"
  end

  defp color_variant("inverted", "light") do
    "bg-transparent text-[#707483] border-[#707483] hover:bg-[#E3E7F1] hover:text-[#707483] hover:border-[#E3E7F1]"
  end

  defp color_variant("inverted", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] hover:bg-[#111111] hover:text-white hover:border-[#111111]"
  end

  defp color_variant("default_gradient", "primary") do
    "text-white bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "secondary") do
    "text-white bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "success") do
    "text-gray-900 bg-gradient-to-r from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "warning") do
    "text-gray-900 bg-gradient-to-r from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "danger") do
    "text-white bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("default_gradient", "info") do
    "text-white bg-gradient-to-r from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "primary") do
    "relative overflow-hidden bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "secondary") do
    "relative overflow-hidden bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "success") do
    "relative overflow-hidden text-gray-900 bg-gradient-to-br from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "warning") do
    "relative overflow-hidden text-gray-900 bg-gradient-to-br from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "danger") do
    "relative overflow-hidden bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("outline_gradient", "info") do
    "relative overflow-hidden bg-gradient-to-br from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "primary") do
    "relative overflow-hidden bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "secondary") do
    "relative overflow-hidden bg-gradient-to-br from-green-400 to-blue-600 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "success") do
    "relative overflow-hidden bg-gradient-to-r from-teal-200 to-lime-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "warning") do
    "relative overflow-hidden bg-gradient-to-r from-red-200 via-red-300 to-yellow-200 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "danger") do
    "relative overflow-hidden bg-gradient-to-br from-pink-500 to-orange-400 hover:bg-gradient-to-bl"
  end

  defp color_variant("inverted_gradient", "info") do
    "relative overflow-hidden bg-gradient-to-r from-cyan-500 to-blue-500 hover:bg-gradient-to-bl"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent hover:bg-[#E8E8E8]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent hover:bg-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent hover:bg-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent hover:bg-[#d4fde4]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent hover:bg-[#fff1cd]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent hover:bg-[#ffcdcd]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent hover:bg-[#cce1ff]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent hover:bg-[#ffe0ff]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent hover:bg-[#ffdfc1]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent hover:bg-[#d2d8e9]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent hover:bg-[#111111]"
  end

  defp color_variant(_, _), do: color_variant("default", "white")

  defp border("white") do
    "border-[#DADADA] hover:border-[#d9d9d9]"
  end

  defp border("transparent") do
    "border-transparent"
  end

  defp border("primary") do
    "border-[#4363EC] hover:border-[#072ed3]"
  end

  defp border("secondary") do
    "border-[#6B6E7C] hover:border-[#60636f]"
  end

  defp border("success") do
    "border-[#227A52] hover:border-[#d4fde4]"
  end

  defp border("warning") do
    "border-[#FF8B08] hover:border-[#fff1cd]"
  end

  defp border("danger") do
    "border-[#E73B3B] hover:border-[#ffcdcd]"
  end

  defp border("info") do
    "border-[#004FC4] hover:border-[#cce1ff]"
  end

  defp border("misc") do
    "border-[#52059C] hover:border-[#ffe0ff]"
  end

  defp border("dawn") do
    "border-[#4D4137] hover:border-[#FFECDA]"
  end

  defp border("light") do
    "border-[#707483] hover:border-[#d2d8e9]"
  end

  defp border("dark") do
    "border-[#1E1E1E] hover:border-[#111111]"
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp size_class("extra_small", circle) do
    [
      is_nil(circle) && "py-1 px-2",
      "text-xs [&>.indicator]:size-1",
      !is_nil(circle) && "size-6"
    ]
  end

  defp size_class("small", circle) do
    [
      is_nil(circle) && "py-1.5 px-3",
      "text-sm [&>.indicator]:size-1.5",
      !is_nil(circle) && "size-7"
    ]
  end

  defp size_class("medium", circle) do
    [
      is_nil(circle) && "py-2 px-4",
      "text-base [&>.indicator]:size-2",
      !is_nil(circle) && "size-8"
    ]
  end

  defp size_class("large", circle) do
    [
      is_nil(circle) && "py-2.5 px-5",
      "text-lg [&>.indicator]:size-2.5",
      !is_nil(circle) && "size-9"
    ]
  end

  defp size_class("extra_large", circle) do
    [
      is_nil(circle) && "py-3 px-5",
      "text-xl [&>.indicator]:size-3",
      !is_nil(circle) && "size-10"
    ]
  end

  defp size_class("full_width", _circle), do: ["py-2 px-4 w-full text-lg"]

  defp size_class(params, _circle) when is_binary(params), do: [params]

  defp size_class(_, _circle), do: size_class("large", nil)

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"

  defp variation("horizontal") do
    "flex-row [&>*:not(:last-child)]:border-r"
  end

  defp variation("vertical") do
    "flex-col [&>*:not(:last-child)]:border-b"
  end

  defp indicator_size("extra_small"), do: "!size-2"
  defp indicator_size("small"), do: "!size-2.5"
  defp indicator_size("medium"), do: "!size-3"
  defp indicator_size("large"), do: "!size-3.5"
  defp indicator_size("extra_large"), do: "!size-4"
  defp indicator_size(params) when is_binary(params), do: params
  defp indicator_size(nil), do: nil

  defp default_classes(:grouped) do
    [
      "phx-submit-loading:opacity-75 overflow-hidden bg-white flex w-fit rounded-lg border",
      "[&>*]:rounded-none [&>*]:border-0"
    ]
  end

  defp default_classes(pinging) do
    [
      "phx-submit-loading:opacity-75 relative inline-flex gap-2 items-center justify-center border",
      "transition-all ease-in-ou duration-100 group",
      "disabled:bg-opacity-60 disabled:border-opacity-40 disabled:cursor-not-allowed disabled:text-opacity-60",
      "disabled:cursor-not-allowed",
      "focus:outline-none",
      !is_nil(pinging) && "[&>.indicator]:animate-ping"
    ]
  end

  defp drop_rest(rest) do
    all_rest =
      (["pinging", "circle", "right_icon", "left_icon"] ++ @indicator_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end
end
