defmodule MishkaChelekom.Avatar do
  use Phoenix.Component

  # TODO: We need Avatar tooltip
  # TODO: We need Dot indicator
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

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon"],
    default: "default",
    doc: ""

  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :border, :string, doc: ""
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    <img
      src="https://flowbite.com/docs/images/people/profile-picture-5.jpg"
      class="size-8 rounded-full shadow-sm border border-neutral-500 border-opacity-25"
      alt=""
    />
    """
  end

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon", nil],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :border, :string, doc: ""
  attr :rest, :global

  def avatar_group(assigns) do
    ~H"""
    """
  end

  defp color("white") do
    "text-white"
  end

  defp color("primary") do
    "text-[#4363EC]"
  end

  defp color("secondary") do
    "text-[#6B6E7C]"
  end

  defp color("success") do
    "text-[#227A52]"
  end

  defp color("warning") do
    "text-[#FF8B08]"
  end

  defp color("danger") do
    "text-[#E73B3B]"
  end

  defp color("info") do
    "text-[#6663FD]"
  end

  defp color("misc") do
    "text-[#52059C]"
  end

  defp color("dawn") do
    "text-[#4D4137]"
  end

  defp color("light") do
    "text-[#707483]"
  end

  defp color("dark") do
    "text-[#1E1E1E]"
  end

  defp color(params), do: params

  defp size_class("extra_small"), do: "text-xs"
  defp size_class("small"), do: "text-sm"
  defp size_class("medium"), do: "text-base"
  defp size_class("large"), do: "text-lg"
  defp size_class("extra_large"), do: "text-xl"
  defp size_class("double_large"), do: "text-2xl"
  defp size_class("triple_large"), do: "text-3xl"
  defp size_class("quadruple_large"), do: "text-4xl"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("medoum")
end
