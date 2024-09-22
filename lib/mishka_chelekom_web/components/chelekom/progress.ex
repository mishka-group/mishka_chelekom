defmodule MishkaChelekom.Progress do
  @moduledoc """
  The `MishkaChelekom.Progress` module provides a customizable progress bar component for
  Phoenix LiveView applications.

  It offers a range of styling options, including different sizes, colors, and variants,
  allowing developers to create both horizontal and vertical progress bars tailored to
  their design requirements.

  This component supports a variety of visual configurations, such as gradient backgrounds
  and rounded corners, and can be used in diverse use cases, from displaying loading states
  to indicating progress in forms and surveys.

  The module's flexibility is further enhanced by its use of `slots`, enabling developers
  to include custom content within the progress bar, making it a versatile choice for building
  interactive and dynamic UIs.
  """
  use Phoenix.Component

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

  @variants ["default", "gradient"]

  @doc """
  Renders a progress bar component that visually represents the completion status of a task.

  It supports both horizontal and vertical orientations and can be customized with various colors and styles.

  ## Examples

  ```elixir
  <.progress value={10} />
  <.progress color="primary" value={20} />
  <.progress color="secondary" value={30} />
  <.progress variation="vertical" color="primary" value={20} />

  <.progress>
    <.progress_section color="primary" value={10} />
    <.progress_section color="secondary" value={15} />
    <.progress_section color="misc" value={10} />
    <.progress_section color="danger" value={5} />
    <.progress_section color="warning" value={10} />
    <.progress_section color="success" value={10} />
    <.progress_section color="info" value={5} />
  </.progress>

  <.progress variation="horizontal" size="large" value={70}>
    <div class="absolute inset-y-0 left-0 flex items-center pl-3 text-white">
      70%
    </div>
  </.progress>

  <.progress variation="vertical" size="extra_large" value={80}>
    <div class="absolute bottom-0 left-0 flex items-center text-white">
      80%
    </div>
  </.progress>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :value, :integer, default: nil, doc: "Value of inout"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"

  attr :size, :string,
    values: @sizes,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def progress(assigns) do
    ~H"""
    <div
      class={[
        "bg-[#e9ecef] rounded-full overflow-hidden",
        @variation == "vertical" && "flex items-end",
        size_class(@size, @variation)
      ]}
      {@rest}
    >
      <.progress_section :if={@value} {assigns} />
      <div
        :if={msg = render_slot(@inner_block)}
        class={[
          "flex",
          (@variation == "horizontal" && "flex-row") || "flex-col"
        ]}
      >
        <%= msg %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a section of a progress bar component. Each section represents a part of the progress
  with its own value and color, allowing for segmented progress bars.

  ## Examples

  ```elixir
  <.progress>
    <.progress_section color="primary" value={10} />
    <.progress_section color="secondary" value={15} />
    <.progress_section color="misc" value={10} />
    <.progress_section color="danger" value={5} />
    <.progress_section color="warning" value={10} />
    <.progress_section color="success" value={10} />
    <.progress_section color="info" value={5} />
  </.progress>
  ```
  """
  @doc type: :component
  attr :value, :integer, default: 0, doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"
  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def progress_section(assigns) do
    assigns = assign(assigns, :value, (is_integer(assigns.value) && assigns.value) || 0)

    ~H"""
    <div
      class={[
        "rounded-full w-full",
        if(@variation == "vertical", do: "progress-vertical"),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        @class
      ]}
      style={(@variation == "horizontal" && "width: #{@value}%;") || "height: #{@value}%;"}
    >
    </div>
    """
  end

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("full"), do: "rounded-full"
  defp rounded_size(_), do: "rounded-none"

  defp size_class("extra_small", "horizontal"), do: "text-xs h-1.5 [&>*]:h-1.5"
  defp size_class("small", "horizontal"), do: "text-sm h-2 [&>*]:h-2"
  defp size_class("medium", "horizontal"), do: "text-base h-2.5 [&>*]:h-2.5"
  defp size_class("large", "horizontal"), do: "text-lg h-3 [&>*]:h-3"
  defp size_class("extra_large", "horizontal"), do: "text-xl h-4 [&>*]:h-4"

  defp size_class("extra_small", "vertical"), do: "text-xs w-1 h-[5rem]"
  defp size_class("small", "vertical"), do: "text-sm w-2 h-[6rem]"
  defp size_class("medium", "vertical"), do: "text-base w-3 h-[7rem]"
  defp size_class("large", "vertical"), do: "text-lg w-4 h-[8rem]"
  defp size_class("extra_large", "vertical"), do: "text-xl w-5 h-[9rem]"

  defp size_class(params, _) when is_binary(params), do: params
  defp size_class(_, _), do: size_class("small", "horizontal")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E]"
  end

  defp color_variant("default", "primary") do
    "bg-[#2441de] text-white"
  end

  defp color_variant("default", "secondary") do
    "bg-[#877C7C] text-white"
  end

  defp color_variant("default", "success") do
    "bg-[#6EE7B7] text-[#047857]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FF8B08] text-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#E73B3B] text-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#004FC4] text-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#52059C] text-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#4D4137] text-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#707483] text-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white"
  end

  defp color_variant("gradient", "white") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l [&:not(.progress-vertical)]:from-white [&:not(.progress-vertical)]:to-[#e9ecef] text-[#3E3E3E]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-white [&.progress-vertical]:to-white"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#2441de] to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef]  [&.progress-vertical]:via-[#2441de] [&.progress-vertical]:to-[#2441de]"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#877C7C] to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#877C7C] [&.progress-vertical]:to-[#877C7C]"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#6EE7B7] to-[#e9ecef] text-[#047857]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#6EE7B7] [&.progress-vertical]:to-[#6EE7B7]"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#FF8B08] to-[#e9ecef] text-[#FF8B08]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#FF8B08] [&.progress-vertical]:to-[#FF8B08]"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#E73B3B] to-[#e9ecef] text-[#E73B3B]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#E73B3B] [&.progress-vertical]:to-[#E73B3B]"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#004FC4] to-[#e9ecef] text-[#004FC4]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#004FC4] [&.progress-vertical]:to-[#004FC4]"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#52059C] to-[#e9ecef] text-[#52059C]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#52059C] [&.progress-vertical]:to-[#52059C]"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#4D4137] to-[#e9ecef] text-[#4D4137]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#4D4137] [&.progress-vertical]:to-[#4D4137]"
    ]
  end

  defp color_variant("gradient", "light") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#707483] to-[#e9ecef] text-[#707483]",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#707483] [&.progress-vertical]:to-[#707483]"
    ]
  end

  defp color_variant("gradient", "dark") do
    [
      "ltr:[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l from-[#1E1E1E] to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:via-[#1E1E1E] [&.progress-vertical]:to-[#1E1E1E]"
    ]
  end
end
