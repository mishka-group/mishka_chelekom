defmodule MishkaChelekom.Rating do
  use Phoenix.Component
  import MishkaChelekomWeb.CoreComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :gap, :string, default: "small", doc: ""
  attr :size, :string, default: "small", doc: ""
  attr :color, :string, default: "warning", doc: ""
  attr :rest, :global, doc: ""

  # TODO: when icon have class .rated it's color will change
  def rating(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex flex-nowrap text-[#cccbca]",
        gap_class(@gap),
        size_class(@size),
        color_class(@color)
      ]}
    >
      <.icon name="hero-star-solid" class="rating-icon rated" />
      <.icon name="hero-star-solid" class="rating-icon" />
      <.icon name="hero-star-solid" class="rating-icon" />
      <.icon name="hero-star-solid" class="rating-icon" />
      <.icon name="hero-star-solid" class="rating-icon" />
    </div>
    """
  end

  defp gap_class("extra_small"), do: "gap-1"
  defp gap_class("small"), do: "gap-1.5"
  defp gap_class("medium"), do: "gap-2"
  defp gap_class("large"), do: "gap-2.5"
  defp gap_class("extra_large"), do: "gap-3"
  defp gap_class(params) when is_binary(params), do: params
  defp gap_class(_), do: gap_class("small")

  defp size_class("extra_small"), do: "[&_.rating-icon]:size-4"
  defp size_class("small"), do: "[&_.rating-icon]:size-5"
  defp size_class("medium"), do: "[&_.rating-icon]:size-6"
  defp size_class("large"), do: "[&_.rating-icon]:size-7"
  defp size_class("extra_large"), do: "[&_.rating-icon]:size-8"
  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp color_class("white") do
    "[&_.rated]:text-white"
  end

  defp color_class("primary") do
    "[&_.rated]:text-[#2441de]"
  end

  defp color_class("secondary") do
    "[&_.rated]:text-[#877C7C]"
  end

  defp color_class("success") do
    "[&_.rated]:text-[#6EE7B7]"
  end

  defp color_class("warning") do
    "[&_.rated]:text-[#FF8B08]"
  end

  defp color_class("danger") do
    "[&_.rated]:text-[#E73B3B]"
  end

  defp color_class("info") do
    "[&_.rated]:text-[#004FC4]"
  end

  defp color_class("misc") do
    "[&_.rated]:text-[#52059C]"
  end

  defp color_class("dawn") do
    "[&_.rated]:text-[#4D4137]"
  end

  defp color_class("light") do
    "[&_.rated]:text-[#707483]"
  end

  defp color_class("dark") do
    "[&_.rated]:text-[#1E1E1E]"
  end
end
