defmodule MishkaChelekom.Badge do
  @moduledoc """
  Provides customizable and flexible badge components for use in Phoenix LiveView.

  The `MishkaChelekom.Badge` module allows you to create badge elements with various styles,
  sizes, and colors. You can add icons, indicators, and dismiss buttons, and configure
  the badge's appearance and behavior using a range of attributes.
  This module also provides helper functions to show and hide badges with smooth transition effects.

  > The badges can be customized further with global attributes such as position, padding, and more.
  > Utilize the built-in helper functions to dynamically show and hide badges as needed.

  This module is designed to be highly customizable, enabling you to create badges
  that fit your application's needs seamlessly.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

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

  @icon_positions [
    "right_icon",
    "left_icon"
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

  @dismiss_positions ["dismiss", "right_dismiss", "left_dismiss"]

  @doc """
  The `badge` component is used to display badges with various styles and indicators.

  It supports customization of attributes such as `variant`, `size`, and `color`,
  along with optional icons and indicator styles.

  ## Examples

  ```elixir
  <.badge icon="hero-arrow-down-tray" color="warning" dismiss indicator>Default warning</.badge>
  <.badge variant="shadow" rounded="large" indicator>Active</.badge>

  <.badge icon="hero-square-2-stack" color="danger" size="medium" bottom_center_indicator pinging>
    Duplicate
  </.badge>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string,
    values: ["default", "outline", "transparent", "unbordered", "shadow"],
    default: "default",
    doc: "Determines the style"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "small",
    doc: "Determines the border radius"

  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :indicator_class, :string,
    default: nil,
    doc: "CSS class for additional styling of the badge indicator"

  attr :indicator_size, :string, default: nil, doc: "Specifies the size of the badge indicator"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  attr :rest, :global,
    include:
      ["pinging", "circle"] ++ @dismiss_positions ++ @indicator_positions ++ @icon_positions,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def badge(assigns) do
    ~H"""
    <div
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
      <.badge_dismiss :if={dismiss_position(@rest) == "left"} id={@id} params={@params} />
      <.badge_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <div class="leading-none"><%= render_slot(@inner_block) %></div>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.badge_indicator size={@indicator_size} class={@indicator_class} {@rest} />
      <.badge_dismiss :if={dismiss_position(@rest) == "right"} id={@id} params={@params} />
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :dismiss, :boolean,
    default: false,
    doc: "Determines if the badge should include a dismiss button"

  attr :icon_class, :string, default: "size-4", doc: "Determines custom class for the icon"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for badge configuration, such as type or kind"

  defp badge_dismiss(assigns) do
    ~H"""
    <button
      class="dismmiss-button inline-flex justify-center items-center w-fit shrink-0"
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_badge("##{@id}")}
    >
      <.icon name="hero-x-mark" class={"#{@icon_class}"} />
    </button>
    """
  end

  @doc type: :component
  attr :position, :string, default: "none", doc: "Determines the element position"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  defp badge_indicator(%{position: "left", rest: %{left_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "left", rest: %{indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{right_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute top-0 -translate-y-1/2 translate-x-1/2 right-1/2"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{middle_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{middle_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
    ]} />
    """
  end

  defp badge_indicator(assigns) do
    ~H"""
    """
  end

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] [&>.indicator]:bg-[#3E3E3E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de] [&>.indicator]:bg-white hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C] [&>.indicator]:bg-white hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] [&>.indicator]:bg-[#047857] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:[&>button]:text-[#948474]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404] [&>.indicator]:bg-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white [&>.indicator]:bg-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] [&>.indicator]:bg-[#4363EC] hover:[&>button]:text-[#072ed3] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C] [&>.indicator]:bg-[#6B6E7C] hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7] [&>.indicator]:bg-[#227A52] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08] [&>.indicator]:bg-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B] [&>.indicator]:bg-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4] [&>.indicator]:bg-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C] [&>.indicator]:bg-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137] [&>.indicator]:bg-[#4D4137] hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483] [&>.indicator]:bg-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E] [&>.indicator]:bg-[#1E1E1E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent [&>.indicator]:bg-[#3E3E3E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent [&>.indicator]:bg-white hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent [&>.indicator]:bg-white hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent [&>.indicator]:bg-[#047857] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent [&>.indicator]:bg-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent [&>.indicator]:bg-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent [&>.indicator]:bg-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent [&>.indicator]:bg-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent [&>.indicator]:bg-[#4D4137] hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent [&>.indicator]:bg-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent [&>.indicator]:bg-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent [&>.indicator]:bg-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent [&>.indicator]:bg-[#4363EC] hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent [&>.indicator]:bg-[#6B6E7C] hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent [&>.indicator]:bg-[#227A52] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent [&>.indicator]:bg-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent [&>.indicator]:bg-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent [&>.indicator]:bg-[#6663FD] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent [&>.indicator]:bg-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent [&>.indicator]:bg-[#4D4137] hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent [&>.indicator]:bg-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent [&>.indicator]:bg-[#1E1E1E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow [&>.indicator]:bg-[#3E3E3E] hover:[&>button]:text-[#787878]"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow [&>.indicator]:bg-white hover:[&>button]:text-[#072ed3]"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow [&>.indicator]:bg-white hover:[&>button]:text-[#60636f]"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow [&>.indicator]:bg-[#227A52] hover:[&>button]:text-[#50AF7A]"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow [&>.indicator]:bg-[#FF8B08] hover:[&>button]:text-[#FFB045]"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow [&>.indicator]:bg-[#E73B3B] hover:[&>button]:text-[#F0756A]"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow [&>.indicator]:bg-[#004FC4] hover:[&>button]:text-[#3680DB]"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow [&>.indicator]:bg-[#52059C] hover:[&>button]:text-[#8535C3]"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow [&>.indicator]:bg-[#4D4137] hover:[&>button]:text-[#FFECDA]"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow [&>.indicator]:bg-[#707483] hover:[&>button]:text-[#A0A5B4]"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow [&>.indicator]:bg-white hover:[&>button]:text-[#787878]"
  end

  defp color_variant(_, _), do: color_variant("default", "white")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size("none"), do: "rounded-none"

  defp indicator_size("extra_small"), do: "!size-2"
  defp indicator_size("small"), do: "!size-2.5"
  defp indicator_size("medium"), do: "!size-3"
  defp indicator_size("large"), do: "!size-3.5"
  defp indicator_size("extra_large"), do: "!size-4"
  defp indicator_size(params) when is_binary(params), do: params
  defp indicator_size(nil), do: nil

  defp size_class("extra_small", circle) do
    [
      is_nil(circle) && "px-2 py-0.5",
      "text-xs [&>.indicator]:size-1",
      !is_nil(circle) && "size-6"
    ]
  end

  defp size_class("small", circle) do
    [
      is_nil(circle) && "px-2.5 py-1",
      "text-sm [&>.indicator]:size-1.5",
      !is_nil(circle) && "size-7"
    ]
  end

  defp size_class("medium", circle) do
    [
      is_nil(circle) && "px-2.5 py-1.5",
      "text-base [&>.indicator]:size-2",
      !is_nil(circle) && "size-8"
    ]
  end

  defp size_class("large", circle) do
    [
      is_nil(circle) && "px-3 py-2",
      "text-lg [&>.indicator]:size-2.5",
      !is_nil(circle) && "size-9"
    ]
  end

  defp size_class("extra_large", circle) do
    [
      is_nil(circle) && "px-3.5 py-2.5",
      "text-xl [&>.indicator]:size-3",
      !is_nil(circle) && "size-10"
    ]
  end

  defp size_class(params, _circle) when is_binary(params), do: [params]

  defp size_class(_, _circle), do: size_class("extra_small", nil)

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"

  defp dismiss_position(%{right_dismiss: true}), do: "right"
  defp dismiss_position(%{left_dismiss: true}), do: "left"
  defp dismiss_position(%{dismiss: true}), do: "right"
  defp dismiss_position(_), do: false

  defp default_classes(pinging) do
    [
      "has-[.indicator]:relative inline-flex gap-1.5 justify-center items-center border",
      "[&>.indicator]:inline-block [&>.indicator]:shrink-0 [&>.indicator]:rounded-full",
      !is_nil(pinging) && "[&>.indicator]:animate-ping"
    ]
  end

  defp drop_rest(rest) do
    all_rest =
      (["pinging", "circle"] ++ @dismiss_positions ++ @indicator_positions ++ @icon_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end

  ## JS Commands
  @doc """
  Displays a badge element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply
    transformations on. Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the badge element to be shown.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the badge element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from an initial state of reduced opacity and
    scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`) to full opacity
    and scale (`opacity-100 translate-y-0 sm:scale-100`) over a duration of 300 milliseconds.

  ## Example

  ```elixir
  show_badge(%JS{}, "#badge-element")
  ```

  This example will show the badge element with the ID badge-element using the defined transition effect.
  """
  def show_badge(js \\ %JS{}, selector) do
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
  Hides a badge element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the badge element to be hidden.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to hide the badge element
    with a smooth transition effect.

  ## Transition Details

    - The element transitions from full opacity and scale (`opacity-100 translate-y-0 sm:scale-100`)
    to reduced opacity and scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`)
    over a duration of 200 milliseconds.

  ## Example

  ```elixir
  hide_badge(%JS{}, "#badge-element")
  ```

  This example will hide the badge element with the ID badge-element using the defined transition effect.
  """

  def hide_badge(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
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
