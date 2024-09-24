defmodule MishkaChelekom.Accordion do
  @moduledoc """
  The `MishkaChelekom.Accordion` module provides a flexible and customizable accordion
  component for Phoenix LiveView applications.

  It supports a variety of configuration options including size, variant, color, padding,
  and border styles.

  ### Features

  - **Customizable Design**: Supports multiple variants such as `"default"`, `"contained"`,
  `"filled"`, `"separated"`, `"tinted_split"`, `"transparent"`, and `"menu"`.
  - **Size and Spacing**: Provides control over the size and spacing of accordion items
  using predefined values such as `"extra_small"`, `"small"`, `"medium"`,
  `"large"`, and `"extra_large"`.
  - **Color Themes**: Offers a range of color options including `"primary"`,
  `"secondary"`, `"success"`, `"warning"`, `"danger"`, `"info"`, `"light"`, `"dark"`, and more.
  - **Interactive Animations**: Includes interactive JavaScript-based animations
  for showing and hiding content with smooth transitions.
  - **Icon and Media Support**: Allows the inclusion of icons and images within
  accordion items, enhancing the visual appeal and usability of the component.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "contained",
    "filled",
    "seperated",
    "tinted_split",
    "transparent",
    "menu"
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

  @doc """
  The `accordion` component provides a collapsible structure with various styling options,
  ideal for organizing content into expandable panels. It supports customizable attributes such
  as `variant`, `color`, and `media_size.

  ## Examples
  ```elixir
  <.accordion id="test-108" media_size="medium" color="secondary">
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
  </.accordion>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :space, :string, values: @sizes, default: "small", doc: "Space between items"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "transparent", doc: "Determines border style"
  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :chevron_icon, :string,
    default: "hero-chevron-right",
    doc: "Determines the icon for the chevron"

  attr :media_size, :string,
    values: @sizes,
    default: "small",
    doc: "Determines size of the media elements"

  attr :size, :string,
    default: nil,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  slot :item, required: true, doc: "Specifies item slot of a accordion" do
    attr :title, :string,
      required: true,
      doc: "Specifies the title of the element",
      doc: "Specifies the title of the element"

    attr :description, :string, doc: "Determines a short description"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :image, :string, doc: "Image displayed alongside of an item"
    attr :hover, :string, doc: "Determines custom class for the hover"
    attr :image_class, :string, doc: "Determines custom class for the image"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :title_class, :string, doc: "Determines custom class for the title"
    attr :summary_class, :string, doc: "Determines custom class for the summary"
    attr :font_weight, :string, doc: "Determines custom class for the font weight"
    attr :open, :boolean, doc: "Whether the accordion item is initially open or closed"
  end

  attr :rest, :global,
    include: ~w(left_chevron right_chevron chevron hide_chevron),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def accordion(assigns) do
    ~H"""
    <div
      class={[
        "overflow-hidden w-full h-fit",
        @variant == "menu" && menu_rounded(@rounded),
        @variant != "menu" && rounded_size(@rounded),
        color_variant(@variant, @color),
        space_class(@space, @variant),
        media_size(@media_size),
        padding_size(@padding),
        size_class(@size),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <div
        :for={{item, index} <- Enum.with_index(@item, 1)}
        class={["group accordion-item-wrapper", item[:class]]}
      >
        <div
          id={"#{@id}-#{index}-role-button"}
          role="button"
          class={[
            "accordion-summary block w-full",
            "transition-all duration-100 ease-in-out [&.active-accordion-button_.accordion-chevron]:rotate-90",
            item[:summary_class]
          ]}
        >
          <.native_chevron_position
            id={"#{@id}-#{index}-open-chevron"}
            phx-click={
              show_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-close-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />

          <.native_chevron_position
            id={"#{@id}-#{index}-close-chevron"}
            phx-click={
              hide_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-open-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            class="hidden"
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </div>
        <.focus_wrap
          id={"#{@id}-#{index}"}
          class="accordion-content-wrapper relative hidden transition [&:not(.active)_.accordion-content]:grid-rows-[0fr] [&.active_.accordion-content]:grid-rows-[1fr]"
        >
          <div
            id={"#{@id}-#{index}-content"}
            class={[
              "accordion-content transition-all duration-500 grid",
              item[:content_class]
            ]}
          >
            <div class="overflow-hidden">
              <%= render_slot(item) %>
            </div>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  @doc """
  The Native Accordion component provides an expandable structure that uses the native `<details>`
  HTML element.

  It offers various customization options such as `variant`, `color`, and `media_size` for
  styling and configuration.

  ## Examples
  ```elixir
  <.native_accordion name="example-zero" media_size="small">
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
  </.native_accordion>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :name, :string, default: nil, doc: "Specifies the name of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :space, :string, values: @sizes, default: "small", doc: "Space between items"
  attr :color, :string, default: "white", doc: "Determines color theme"
  attr :border, :string, default: "transparent", doc: "Determines border style"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "small",
    doc: "Determines padding for items"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "none",
    doc: "Determines the border radius"

  attr :media_size, :string,
    values: @sizes,
    default: "small",
    doc: "Determines size of the media elements"

  attr :chevron_icon, :string,
    default: "hero-chevron-right",
    doc: "Determines the icon for the chevron"

  slot :item, required: true, doc: "Specifies item slot of a accordion" do
    attr :title, :string, required: true, doc: "Specifies the title of the element"
    attr :description, :string, doc: "Determines a short description"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :image, :string, doc: "Image displayed alongside of an item"
    attr :image_class, :string, doc: "Determines custom class for the image"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :title_class, :string, doc: "Determines custom class for the title"
    attr :summary_class, :string, doc: "Determines custom class for the summary"
    attr :open, :boolean, doc: "Whether the accordion item is initially open or closed"
  end

  attr :rest, :global,
    include: ~w(left_chevron right_chevron chevron hide_chevron),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden",
        @variant == "menu" && menu_rounded(@rounded),
        @variant != "menu" && rounded_size(@rounded),
        space_class(@space, @variant),
        padding_size(@padding),
        media_size(@media_size),
        color_variant(@variant, @color),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <details
        :for={item <- @item}
        name={@name}
        class={["group accordion-item-wrapper", item[:class]]}
        open={item[:open] || false}
      >
        <summary class={[
          "accordion-summary w-full group-open:mb-1",
          "cursor-pointer transition-[margin,background,text] duration-[250ms] ease-in-out list-none",
          item_color(@variant, @color),
          item[:summary_class]
        ]}>
          <.native_chevron_position
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </summary>

        <div class={[
          "-mt-1 shrink-0 transition-all duration-1000 ease-in-out opacity-0 group-open:opacity-100",
          "-translate-y-4	group-open:translate-y-0 custom-accordion-content",
          item_color(@variant, @color),
          item[:content_class]
        ]}>
          <%= render_slot(item) %>
        </div>
      </details>
    </div>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :item, :map, doc: "Determines each item"
  attr :position, :string, values: ["left", "right"], doc: "Determines the element position"
  attr :chevron_icon, :string, doc: "Determines the icon for the chevron"
  attr :hide_chevron, :boolean, default: false, doc: "Hide chevron icon"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  defp native_chevron_position(%{position: "left"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class={[
        "flex flex-nowrap items-center rtl:justify-start ltr:justify-start gap-2",
        @item[:hover]
      ]}>
        <.icon
          :if={!@hide_chevron}
          name={@chevron_icon}
          class="accordion-chevron size-5 transition-transform duration-300 ease-in-out group-open:rotate-90 rotate-180 rtl:rotate-0"
        />

        <div class="flex items-center gap-2">
          <img
            :if={!is_nil(@item[:image])}
            class={["accordion-title-media shrink-0", @item[:image_class]]}
            src={@item[:image]}
          />

          <.icon
            :if={!is_nil(@item[:icon])}
            name={@item[:icon]}
            class={@item[:icon_class] || "accordion-title-media"}
          />

          <div class={["space-y-2"]}>
            <div class={[
              @item[:title_class],
              @item[:font_weight]
            ]}>
              <%= @item[:title] %>
            </div>

            <div :if={!is_nil(@item[:description])} class="text-xs font-light">
              <%= @item[:description] %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp native_chevron_position(%{position: "right"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class={[
        "flex items-center justify-between gap-2",
        @item[:hover]
      ]}>
        <div class="flex items-center gap-2">
          <img
            :if={!is_nil(@item[:image])}
            class={["accordion-title-media shrink-0", @item[:image_class]]}
            src={@item[:image]}
          />

          <.icon
            :if={!is_nil(@item[:icon])}
            name={@item[:icon]}
            class={@item[:icon_class] || "accordion-title-media"}
          />

          <div class={["space-y-2", @item[:title_class]]}>
            <div class={[
              @item[:title_class],
              @item[:font_weight]
            ]}>
              <%= @item[:title] %>
            </div>

            <div :if={!is_nil(@item[:description])} class="text-xs font-light">
              <%= @item[:description] %>
            </div>
          </div>
        </div>

        <.icon
          :if={!@hide_chevron}
          name={@chevron_icon}
          class="accordion-chevron size-5 transition-transform duration-300 ease-in-out group-open:rotate-90 rtl:rotate-180"
        />
      </div>
    </div>
    """
  end

  @doc """
  Shows the content of an accordion item and applies the necessary CSS classes to indicate
  its active state.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `id`: A string representing the unique identifier of the accordion item. It is used
    to target the specific DOM elements for showing content and applying classes.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the accordion content,
    add the `active` class to the content, and add the `active-accordion-button`
    class to the corresponding button.

  ## Example
  ```elixir
  show_accordion_content(%JS{}, "accordion-item-1")
  ```

  This example will show the content of the accordion item with the ID `accordion-item-1`
  and add the active classes to it.
  """
  def show_accordion_content(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.add_class("active", to: "##{id}")
    |> JS.add_class("active-accordion-button", to: "##{id}-role-button")
  end

  @doc """
  Hides the content of an accordion item and removes the active CSS classes to indicate its
  inactive state.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `id`: A string representing the unique identifier of the accordion item. It is used to
    target the specific DOM elements for hiding content and removing classes.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to remove the `active` class from
    the content and the `active-accordion-button` class from the corresponding button.

  ## Example
  ```elixir
  hide_accordion_content(%JS{}, "accordion-item-1")
  ```
  This example will hide the content of the accordion item with the ID "accordion-item-1" and remove
  the active classes from it.
  """
  def hide_accordion_content(js \\ %JS{}, id) do
    js
    |> JS.remove_class("active", to: "##{id}")
    |> JS.remove_class("active-accordion-button", to: "##{id}-role-button")
  end

  defp space_class(_, variant) when variant not in ["seperated", "tinted_split"], do: nil
  defp space_class("extra_small", _), do: "accordion-item-gap space-y-2"
  defp space_class("small", _), do: "accordion-item-gap space-y-3"
  defp space_class("medium", _), do: "accordion-item-gap space-y-4"
  defp space_class("large", _), do: "accordion-item-gap space-y-5"
  defp space_class("extra_large", _), do: "accordion-item-gap space-y-6"
  defp space_class(params, _) when is_binary(params), do: params
  defp space_class(_, _), do: nil

  defp menu_rounded("extra_small"), do: "[&_.accordion-summary]:rounded-sm"
  defp menu_rounded("small"), do: "[&_.accordion-summary]:rounded"
  defp menu_rounded("medium"), do: "[&_.accordion-summary]:rounded-md"
  defp menu_rounded("large"), do: "[&_.accordion-summary]:rounded-lg"
  defp menu_rounded("extra_large"), do: "[&_.accordion-summary]:rounded-xl"
  defp menu_rounded("full"), do: "[&_.accordion-summary]:rounded-full"
  defp menu_rounded(params) when is_binary(params), do: params
  defp menu_rounded(_), do: nil

  defp media_size("extra_small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-12"
  defp media_size("small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-14"
  defp media_size("medium"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-16"
  defp media_size("large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-20"
  defp media_size("extra_large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-24"
  defp media_size(params) when is_binary(params), do: params
  defp media_size(_), do: media_size("small")

  defp size_class("extra_small") do
    [
      "text-xs [&_.accordion-summary]:py-1 [&_.accordion-summary]:px-2"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.accordion-summary]:py-1.5 [&_.accordion-summary]:px-3"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.accordion-summary]:py-2 [&_.accordion-summary]:px-4"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.accordion-summary]:py-2.5 [&_.accordion-summary]:px-5"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.accordion-summary]:py-3 [&_.accordion-summary]:px-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: nil

  defp rounded_size("extra_small") do
    [
      "rounded-sm [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-sm [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-sm"
    ]
  end

  defp rounded_size("small") do
    [
      "rounded [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b"
    ]
  end

  defp rounded_size("medium") do
    [
      "rounded-md [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-md [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-md"
    ]
  end

  defp rounded_size("large") do
    [
      "rounded-lg [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-lg [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-lg"
    ]
  end

  defp rounded_size("extra_large") do
    [
      "rounded-xl [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper]:rounded-xl [&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-xl"
    ]
  end

  defp rounded_size("none"), do: "rounded-none"

  defp padding_size("extra_small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-1",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-1"
    ]
  end

  defp padding_size("small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-2",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-2"
    ]
  end

  defp padding_size("medium") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-3",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-3"
    ]
  end

  defp padding_size("large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-4",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-4"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-5",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-5"
    ]
  end

  defp padding_size("zero"), do: "[&>.accordion-item-wrapper>.accordion-summary]:p-0"
  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp color_variant("transparent", "white") do
    [
      "bg-transparent border-transparent text-white"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "bg-transparent border-transparent text-[#4363EC]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "bg-transparent border-transparent text-[#6B6E7C]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "bg-transparent border-transparent text-[#227A52]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "bg-transparent border-transparent text-[#FF8B08]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "bg-transparent border-transparent text-[#E73B3B]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "bg-transparent border-transparent text-[#6663FD]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "bg-transparent border-transparent text-[#52059C]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "bg-transparent border-transparent text-[#4D4137]"
    ]
  end

  defp color_variant("transparent", "light") do
    [
      "bg-transparent border-transparent text-[#707483]"
    ]
  end

  defp color_variant("transparent", "dark") do
    [
      "bg-transparent border-transparent text-[#1E1E1E]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#DADADA]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#3E3E3E]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#4363EC]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#072ed3] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#6B6E7C]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#60636f] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#227A52]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#d4fde4] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#047857]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#FF8B08]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#fff1cd] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#FF8B08]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#E73B3B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffcdcd] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#004FC4]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#cce1ff] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#004FC4]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#52059C]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffe0ff] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#52059C]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#4D4137]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#ffdfc1] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#4D4137]"
    ]
  end

  defp color_variant("default", "light") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#707483]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#d2d8e9] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-[#707483]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-white",
      "[&>.accordion-item-wrapper]:border-b",
      "[&>.accordion-item-wrapper]:border-[#1E1E1E]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#111111] hover:[&>.accordion-item-wrapper>.accordion-summary]:text-white"
    ]
  end

  defp color_variant("contained", "white") do
    [
      "border border-[#DADADA]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DADADA]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#DADADA]"
    ]
  end

  defp color_variant("contained", "primary") do
    [
      "border border-[#4363EC]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#4363EC]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#4363EC]"
    ]
  end

  defp color_variant("contained", "secondary") do
    [
      "border border-[#6B6E7C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#6B6E7C]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("contained", "success") do
    [
      "border border-[#227A52]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#227A52]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#227A52]"
    ]
  end

  defp color_variant("contained", "warning") do
    [
      "border border-[#FF8B08]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FF8B08]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#FF8B08]"
    ]
  end

  defp color_variant("contained", "danger") do
    [
      "border border-[#E73B3B]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#E73B3B]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#E73B3B]"
    ]
  end

  defp color_variant("contained", "info") do
    [
      "border border-[#004FC4]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#004FC4]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#004FC4]"
    ]
  end

  defp color_variant("contained", "misc") do
    [
      "border border-[#52059C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#52059C]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#52059C]"
    ]
  end

  defp color_variant("contained", "dawn") do
    [
      "border border-[#4D4137]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#4D4137]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#4D4137]"
    ]
  end

  defp color_variant("contained", "light") do
    [
      "border border-[#707483]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#707483]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#707483]"
    ]
  end

  defp color_variant("contained", "dark") do
    [
      "border border-[#1E1E1E]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#1E1E1E]",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>:not(.accordion-summary)]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("filled", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("filled", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("filled", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("filled", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("filled", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("filled", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("filled", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("filled", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("filled", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("filled", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("filled", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-[#1E1E1E] text-white"
    ]
  end

  defp color_variant("tinted_split", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white text-[#3E3E3E]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("tinted_split", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#4363EC] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4363EC]"
    ]
  end

  defp color_variant("tinted_split", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#6B6E7C] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("tinted_split", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-[#ECFEF3] text-[#047857]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#227A52]"
    ]
  end

  defp color_variant("tinted_split", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFF8E6] text-[#FF8B08]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#FF8B08]"
    ]
  end

  defp color_variant("tinted_split", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6E6] text-[#E73B3B]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#E73B3B]"
    ]
  end

  defp color_variant("tinted_split", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E5F0FF] text-[#004FC4]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#004FC4]"
    ]
  end

  defp color_variant("tinted_split", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFE6FF] text-[#52059C]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#52059C]"
    ]
  end

  defp color_variant("tinted_split", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-[#FFECDA] text-[#4D4137]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4D4137]"
    ]
  end

  defp color_variant("tinted_split", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-[#E3E7F1] text-[#707483]",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#707483]"
    ]
  end

  defp color_variant("tinted_split", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-[#1E1E1E] text-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("seperated", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#DADADA]"
    ]
  end

  defp color_variant("seperated", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4363EC]"
    ]
  end

  defp color_variant("seperated", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#6B6E7C]"
    ]
  end

  defp color_variant("seperated", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#227A52]"
    ]
  end

  defp color_variant("seperated", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#FF8B08]"
    ]
  end

  defp color_variant("seperated", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#E73B3B]"
    ]
  end

  defp color_variant("seperated", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#004FC4]"
    ]
  end

  defp color_variant("seperated", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#52059C]"
    ]
  end

  defp color_variant("seperated", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#4D4137]"
    ]
  end

  defp color_variant("seperated", "light") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#707483]"
    ]
  end

  defp color_variant("seperated", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-white",
      "[&>.accordion-item-wrapper]:border [&>.accordion-item-wrapper]:border-[#1E1E1E]"
    ]
  end

  defp color_variant("menu", "white") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-white text-[#3E3E3E]"
    ]
  end

  defp color_variant("menu", "primary") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#4363EC] text-white"
    ]
  end

  defp color_variant("menu", "secondary") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#6B6E7C] text-white"
    ]
  end

  defp color_variant("menu", "success") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#ECFEF3] text-[#047857]"
    ]
  end

  defp color_variant("menu", "warning") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#FFF8E6] text-[#FF8B08]"
    ]
  end

  defp color_variant("menu", "danger") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#FFE6E6] text-[#E73B3B]"
    ]
  end

  defp color_variant("menu", "info") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#E5F0FF] text-[#004FC4]"
    ]
  end

  defp color_variant("menu", "misc") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#FFE6FF] text-[#52059C]"
    ]
  end

  defp color_variant("menu", "dawn") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#FFECDA] text-[#4D4137]"
    ]
  end

  defp color_variant("menu", "light") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#E3E7F1] text-[#707483]"
    ]
  end

  defp color_variant("menu", "dark") do
    [
      "[&>.accordion-item-wrapper_.accordion-summary]:bg-[#1E1E1E] text-white"
    ]
  end

  defp item_color("default", "white") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("default", "primary") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#072ed3]"
    ]
  end

  defp item_color("default", "secondary") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#60636f]"
    ]
  end

  defp item_color("default", "success") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#d4fde4]"
    ]
  end

  defp item_color("default", "warning") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#fff1cd]"
    ]
  end

  defp item_color("default", "danger") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffcdcd]"
    ]
  end

  defp item_color("default", "info") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#cce1ff]"
    ]
  end

  defp item_color("default", "misc") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffe0ff]"
    ]
  end

  defp item_color("default", "dawn") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#ffdfc1]"
    ]
  end

  defp item_color("default", "light") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#d2d8e9]"
    ]
  end

  defp item_color("default", "dark") do
    [
      "group-open:bg-white group-open:hover:[&:is(.accordion-summary)]:bg-[#111111]"
    ]
  end

  defp item_color("contained", "white") do
    [
      "group-open:bg-[#E8E8E8] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "primary") do
    [
      "group-open:bg-[#072ed3] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "secondary") do
    [
      "group-open:bg-[#60636f] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "success") do
    [
      "group-open:bg-[#d4fde4] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "warning") do
    [
      "group-open:bg-[#fff1cd] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "danger") do
    [
      "group-open:bg-[#ffcdcd] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "info") do
    [
      "group-open:bg-[#cce1ff] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "misc") do
    [
      "group-open:bg-[#ffe0ff] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dawn") do
    [
      "group-open:bg-[#ffdfc1] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "light") do
    [
      "group-open:bg-[#d2d8e9] group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("contained", "dark") do
    [
      "group-open:bg-[#111111] group-open:text-white group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("filled", "white") do
    [
      "group-open:bg-[#E8E8E8]"
    ]
  end

  defp item_color("filled", "primary") do
    [
      "group-open:bg-[#072ed3]"
    ]
  end

  defp item_color("filled", "secondary") do
    [
      "group-open:bg-[#60636f]"
    ]
  end

  defp item_color("filled", "success") do
    [
      "group-open:bg-[#d4fde4]"
    ]
  end

  defp item_color("filled", "warning") do
    [
      "group-open:bg-[#fff1cd]"
    ]
  end

  defp item_color("filled", "danger") do
    [
      "group-open:bg-[#ffcdcd]"
    ]
  end

  defp item_color("filled", "info") do
    [
      "group-open:bg-[#cce1ff]"
    ]
  end

  defp item_color("filled", "misc") do
    [
      "group-open:bg-[#ffe0ff]"
    ]
  end

  defp item_color("filled", "dawn") do
    [
      "group-open:bg-[#ffdfc1]"
    ]
  end

  defp item_color("filled", "light") do
    [
      "group-open:bg-[#d2d8e9]"
    ]
  end

  defp item_color("filled", "dark") do
    [
      "group-open:bg-[#111111]"
    ]
  end

  defp item_color("tinted_split", "white") do
    [
      "group-open:bg-[#E8E8E8]"
    ]
  end

  defp item_color("tinted_split", "primary") do
    [
      "group-open:bg-[#072ed3]"
    ]
  end

  defp item_color("tinted_split", "secondary") do
    [
      "group-open:bg-[#60636f]"
    ]
  end

  defp item_color("tinted_split", "success") do
    [
      "group-open:bg-[#d4fde4]"
    ]
  end

  defp item_color("tinted_split", "warning") do
    [
      "group-open:bg-[#fff1cd]"
    ]
  end

  defp item_color("tinted_split", "danger") do
    [
      "group-open:bg-[#ffcdcd]"
    ]
  end

  defp item_color("tinted_split", "info") do
    [
      "group-open:bg-[#cce1ff]"
    ]
  end

  defp item_color("tinted_split", "misc") do
    [
      "group-open:bg-[#ffe0ff]"
    ]
  end

  defp item_color("tinted_split", "dawn") do
    [
      "group-open:bg-[#ffdfc1]"
    ]
  end

  defp item_color("tinted_split", "light") do
    [
      "group-open:bg-[#d2d8e9]"
    ]
  end

  defp item_color("tinted_split", "dark") do
    [
      "group-open:bg-[#111111]"
    ]
  end

  defp item_color("seperated", "white") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "primary") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "secondary") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "success") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "warning") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "danger") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "info") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "misc") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "dawn") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "light") do
    [
      "group-open:bg-white"
    ]
  end

  defp item_color("seperated", "dark") do
    [
      "group-open:bg-white"
    ]
  end

  defp chevron_position(%{left_chevron: true}), do: "left"
  defp chevron_position(%{right_chevron: true}), do: "right"
  defp chevron_position(%{chevron: true}), do: "right"
  defp chevron_position(_), do: "right"

  defp drop_rest(rest) do
    all_rest =
      ~w(left_chevron right_chevron chevron hide_chevron)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
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
