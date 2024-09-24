defmodule MishkaChelekom.UrlField do
  @moduledoc """
  A component for rendering a URL input field in a Phoenix application.

  This module provides a customizable URL input field with various options
  for styling and layout, including the ability to display errors, descriptions,
  and additional elements before or after the input. It supports both floating
  label and standard label styles.

  The `url_field/1` function can be used to render the URL input, and it accepts
  attributes for customization such as color, border style, and size.

  Additionally, helper functions for rendering labels and error messages are provided
  to enhance usability and accessibility.
  """
  use Phoenix.Component

  @doc """
  The `url_field` component is used to create an input field for URLs.
  It supports various attributes for customization, including color, size, border style, and more.

  ## Examples

  ```elixir
  <.url_field
    name="website"
    value="https://example.com"
    label="Website URL"
    description="Enter your website URL"
    floating="outer"
  />

  <.url_field
    name="social_media"
    value="https://linkedin.com/in/username"
    label="LinkedIn Profile"
    color="success"
    description="Enter your LinkedIn profile URL"
    floating="inner"
  >
    <:start_section>
      <.icon name="hero-link" class="size-4" />
    </:start_section>
  </.url_field>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "light", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, default: "outline", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :floating, :string, default: "none", doc: "none, inner, outer"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  slot :start_section, required: false, doc: "Renders heex content in start of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  slot :end_section, required: false, doc: "Renders heex content in end of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form list maxlength minlength pattern placeholder
        readonly required size spellcheck inputmode title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec url_field(map()) :: Phoenix.LiveView.Rendered.t()
  def url_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:value, fn -> field.value end)
    |> url_field()
  end

  def url_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.url-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        <%= @description %>
      </div>
      <div class={[
        "url-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "url-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>
        <div class="relative w-full z-[2]">
          <input
            type="url"
            name={@name}
            id={@id}
            value={@value}
            class={[
              "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-2.5 px-2",
              "text-sm appearance-none bg-transparent border-0 focus:outline-none peer"
            ]}
            placeholder=" "
            {@rest}
          />

          <label
            class={[
              "floating-label px-1 start-1 -z-[1] absolute text-xs duration-300 transform scale-75 origin-[0]",
              variant_label_position(@floating)
            ]}
            for={@id}
          >
            <%= @label %>
          </label>
        </div>

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  def url_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.url-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}><%= @label %></.label>
        <div :if={!is_nil(@description)} class="text-xs">
          <%= @description %>
        </div>
      </div>

      <div class={[
        "url-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "url-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          <%= render_slot(@start_section) %>
        </div>

        <input
          type="url"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0"
          ]}
          {@rest}
        />

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          <%= render_slot(@end_section) %>
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}><%= msg %></.error>
    </div>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp variant_label_position("outer") do
    [
      "-translate-y-4 top-2 origin-[0] peer-focus:px-1 peer-placeholder-shown:scale-100",
      "peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4",
      "rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp variant_label_position("inner") do
    [
      "-translate-y-4 scale-75 top-4 origin-[0] peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-4 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp size_class("extra_small"),
    do: "[&_.url-field-wrapper_input]:h-7 [&_.url-field-wrapper>.url-field-icon]:size-3.5"

  defp size_class("small"),
    do: "[&_.url-field-wrapper_input]:h-8 [&_.url-field-wrapper>.url-field-icon]:size-4"

  defp size_class("medium"),
    do: "[&_.url-field-wrapper_input]:h-9 [&_.url-field-wrapper>.url-field-icon]:size-5"

  defp size_class("large"),
    do: "[&_.url-field-wrapper_input]:h-10 [&_.url-field-wrapper>.url-field-icon]:size-6"

  defp size_class("extra_large"),
    do: "[&_.url-field-wrapper_input]:h-12 [&_.url-field-wrapper>.url-field-icon]:size-7"

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.url-field-wrapper]:rounded-sm"
  defp rounded_size("small"), do: "[&_.url-field-wrapper]:rounded"
  defp rounded_size("medium"), do: "[&_.url-field-wrapper]:rounded-md"
  defp rounded_size("large"), do: "[&_.url-field-wrapper]:rounded-lg"
  defp rounded_size("extra_large"), do: "[&_.url-field-wrapper]:rounded-xl"
  defp rounded_size("full"), do: "[&_.url-field-wrapper]:rounded-full"
  defp rounded_size(_), do: "[&_.url-field-wrapper]:rounded-none"

  defp border_class("none"), do: "[&_.url-field-wrapper]:border-0"
  defp border_class("extra_small"), do: "[&_.url-field-wrapper]:border"
  defp border_class("small"), do: "[&_.url-field-wrapper]:border-2"
  defp border_class("medium"), do: "[&_.url-field-wrapper]:border-[3px]"
  defp border_class("large"), do: "[&_.url-field-wrapper]:border-4"
  defp border_class("extra_large"), do: "[&_.url-field-wrapper]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"
  defp space_class("small"), do: "space-y-1.5"
  defp space_class("medium"), do: "space-y-2"
  defp space_class("large"), do: "space-y-2.5"
  defp space_class("extra_large"), do: "space-y-3"
  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "white", floating) do
    [
      "text-white [&_.url-field-wrapper:not(:has(.url-field-error))]:border-white",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-white focus-within:[&_.url-field-wrapper]:ring-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#afafaf] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#afafaf]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#afafaf] focus-within:[&_.url-field-wrapper]:ring-[#afafaf]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#2441de] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#2441de]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#2441de] focus-within:[&_.url-field-wrapper]:ring-[#2441de]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#877C7C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#877C7C]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#877C7Cb] focus-within:[&_.url-field-wrapper]:ring-[#877C7C]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#047857] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#047857]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.url-field-wrapper]:ring-[#047857]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#FF8B08] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FF8B08]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.url-field-wrapper]:ring-[#FF8B08]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#E73B3B] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#E73B3B]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.url-field-wrapper]:ring-[#E73B3B]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#004FC4] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#004FC4]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.url-field-wrapper]:ring-[#004FC4]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#52059C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#52059C]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.url-field-wrapper]:ring-[#52059C]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#4D4137] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#4D4137]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.url-field-wrapper]:ring-[#4D4137]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "light", floating) do
    [
      "text-[#707483] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#707483]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.url-field-wrapper]:ring-[#707483]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("outline", "dark", floating) do
    [
      "text-[#1E1E1E] [&_.url-field-wrapper]:text-text-[#1E1E1E] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#050404]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#1E1E1E] focus-within:[&_.url-field-wrapper]:ring-[#050404]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.url-field-wrapper]:bg-white text-[#3E3E3E] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#DADADA]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.url-field-wrapper]:ring-[#DADADA]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#2441de]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700 [&_.url-field-wrapper]:text-white",
      "[&_.url-field-wrapper>input]:placeholder:text-white focus-within:[&_.url-field-wrapper]:ring-[#2441de]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#877C7C]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700 [&_.url-field-wrapper]:text-white",
      "[&_.url-field-wrapper>input]:placeholder:text-white focus-within:[&_.url-field-wrapper]:ring-[#877C7C]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#ECFEF3] text-[#047857] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#6EE7B7]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#047857] focus-within:[&_.url-field-wrapper]:ring-[#6EE7B7]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FF8B08]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#FF8B08] focus-within:[&_.url-field-wrapper]:ring-[#FF8B08]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#E73B3B]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#E73B3B] focus-within:[&_.url-field-wrapper]:ring-[#E73B3B]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#004FC4]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#004FC4] focus-within:[&_.url-field-wrapper]:ring-[#004FC4]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#52059C]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#52059C] focus-within:[&_.url-field-wrapper]:ring-[#52059C]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#4D4137]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#4D4137] focus-within:[&_.url-field-wrapper]:ring-[#4D4137]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("default", "light", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#707483]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-[#707483] focus-within:[&_.url-field-wrapper]:ring-[#707483]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.url-field-wrapper]:text-white [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#050404]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper>input]:placeholder:text-white focus-within:[&_.url-field-wrapper]:ring-[#050404]",
      floating && "[&_.url-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("unbordered", "white", floating) do
    [
      "[&_.url-field-wrapper]:bg-white [&_.url-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("unbordered", "primary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.url-field-wrapper]:border-transparent text-white",
      "[&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#4363EC]"
    ]
  end

  defp color_variant("unbordered", "secondary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.url-field-wrapper]:border-transparent text-white",
      "[&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("unbordered", "success", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#ECFEF3] [&_.url-field-wrapper]:border-transparent text-[#047857]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("unbordered", "warning", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFF8E6] [&_.url-field-wrapper]:border-transparent text-[#FF8B08]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("unbordered", "danger", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6E6] [&_.url-field-wrapper]:border-transparent text-[#E73B3B]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("unbordered", "info", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E5F0FF] [&_.url-field-wrapper]:border-transparent text-[#004FC4]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("unbordered", "misc", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6FF] [&_.url-field-wrapper]:border-transparent text-[#52059C]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("unbordered", "dawn", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFECDA] [&_.url-field-wrapper]:border-transparent text-[#4D4137]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("unbordered", "light", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E3E7F1] [&_.url-field-wrapper]:border-transparent text-[#707483]",
      "[&_.url-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("unbordered", "dark", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.url-field-wrapper]:border-transparent text-white",
      "[&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("shadow", "white", floating) do
    [
      "[&_.url-field-wrapper]:bg-white text-[#3E3E3E] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#DADADA]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#4363EC] text-[#4363EC] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#4363EC]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#3E3E3E]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#6B6E7C] text-[#6B6E7C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#6B6E7C]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#6B6E7C]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#ECFEF3] text-[#227A52] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#047857]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#047857]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#ECFEF3]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFF8E6] text-[#FF8B08] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FFF8E6]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#FF8B08]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFF8E6]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6E6] text-[#E73B3B] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FFE6E6]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#E73B3B]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6E6]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E5F0FF] text-[#004FC4] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#E5F0FF]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#004FC4]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#E5F0FF]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFE6FF] text-[#52059C] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FFE6FF]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#52059C]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFE6FF]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#FFECDA] text-[#4D4137] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#FFECDA]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#4D4137]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#FFECDA]"
    ]
  end

  defp color_variant("shadow", "light", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#E3E7F1] text-[#707483] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#E3E7F1]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-[#707483]",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#E3E7F1]"
    ]
  end

  defp color_variant("shadow", "dark", floating) do
    [
      "[&_.url-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.url-field-wrapper:not(:has(.url-field-error))]:border-[#1E1E1E]",
      "[&_.url-field-wrapper.url-field-error]:border-rose-700",
      "[&_.url-field-wrapper]:shadow [&_.url-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.url-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("transparent", "white", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#DADADA] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#DADADA]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#4363EC] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#6B6E7C] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#6B6E7C]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#047857] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#047857]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#FF8B08] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#FF8B08]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#E73B3B] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#E73B3B]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#004FC4] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#004FC4]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#52059C] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#52059C]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#4D4137] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#4D4137]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "light", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#707483] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#707483]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dark", _) do
    [
      "[&_.url-field-wrapper]:bg-transparent text-[#1E1E1E] [&_.url-field-wrapper]:border-transparent",
      "[&_.url-field-wrapper>input]:placeholder:text-[#1E1E1E]",
      "focus-within:[&_.url-field-wrapper]:ring-transparent"
    ]
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(MishkaChelekomWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MishkaChelekomWeb.Gettext, "errors", msg, opts)
    end
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
