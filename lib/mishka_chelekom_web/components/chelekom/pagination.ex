defmodule MishkaChelekom.Pagination do
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
    "dawn",
    "transparent"
  ]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :total, :integer, required: true, doc: ""
  attr :active, :integer, default: 1, doc: ""
  attr :siblings, :integer, default: 1, doc: ""
  attr :boundaries, :integer, default: nil, doc: ""
  attr :on_select, JS, default: %JS{}
  attr :on_first, JS, default: %JS{}
  attr :on_last, JS, default: %JS{}
  attr :on_next, JS, default: %JS{}
  attr :on_previous, JS, default: %JS{}
  attr :color, :string, values: @colors, default: "transparent", doc: ""
  attr :rounded, :string, values: @sizes ++ ["none"], default: "none", doc: ""
  attr :separator, :string, default: "hero-ellipsis-horizontal", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def pagination(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes() ++
          [
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

  def calculating(_active, _total, nil) do
  end

  def calculating(_active, _total, _boundary) do
  end

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

  defp default_classes() do
    [
      "flex items-center"
    ]
  end
end
