defmodule MishkaChelekom.Spinner do
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "primary", doc: ""
  attr :size, :string, values: @sizes, default: "small", doc: ""
  attr :rest, :global, doc: ""

  def spinner(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
            size_class(@size),
            color_class(@color),
            @class
          ]
      }
      role="status"
      aria-label="loading"
    >
      <span class="sr-only">Loading...</span>
    </div>
    """
  end

  defp size_class("extra_small"), do: "size-3 border-2"
  defp size_class("small"), do: "size-4 border-[3px]"
  defp size_class("medium"), do: "size-5 border-4"
  defp size_class("large"), do: "size-6 border-[5px]"
  defp size_class("extra_large"), do: "size-7 border-[6px]"
  defp size_class("2xl"), do: "size-8 border-[7px]"

  defp color_class("white") do
    "border-[#DADADA]"
  end

  defp color_class("primary") do
    "text-[#2441de]"
  end

  defp color_class("secondary") do
    "text-[#877C7C]"
  end

  defp color_class("success") do
    "text-[#6EE7B7]"
  end

  defp color_class("warning") do
    "text-[#FF8B08]"
  end

  defp color_class("danger") do
    "text-[#E73B3B]"
  end

  defp color_class("info") do
    "text-[#004FC4]"
  end

  defp color_class("misc") do
    "text-[#52059C]"
  end

  defp color_class("dawn") do
    "text-[#4D4137]"
  end

  defp color_class("light") do
    "text-[#707483]"
  end

  defp color_class("dark") do
    "text-[#050404]"
  end

  defp default_classes() do
    [
      "animate-spin inline-block border-t-transparent rounded-full border-current"
    ]
  end
end
