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
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :background, :string, default: nil, doc: "Tailwind CSS background color class without with or without opacity"
  attr :size, :string, values: @sizes, default: "small", doc: ""

  attr :rest, :global,
    include: ~w(has_overlay),
    doc: ""

  def spinner(assigns) do
    ~H"""
    <div
      id={@id}
     class={[
      overlay_class(@rest),
      background_opacity(@background),
      @class
    ]}>
      <div
        class={
          default_classes() ++
            [
              size_class(@size),
              color_class(@color),
            ]
        }
        role="status"
        aria-label="loading"
      >
        <span class="sr-only">Loading...</span>
      </div>
    </div>
    """
  end

  defp size_class("extra_small"), do: "size-3.5 border-2"
  defp size_class("small"), do: "size-4 border-[3px]"
  defp size_class("medium"), do: "size-5 border-4"
  defp size_class("large"), do: "size-6 border-[5px]"
  defp size_class("extra_large"), do: "size-7 border-[5px]"
  defp size_class("2xl"), do: "size-8 border-[5px]"
  defp size_class("3xl"), do: "size-9 border-[6px]"
  defp size_class("4xl"), do: "size-10 border-[6px]"

  defp color_class("white") do
    "border-white"
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

  defp background_opacity("white"), do: "bg-white/50"
  defp background_opacity("primary"), do: "bg-[#2441de]/50"
  defp background_opacity("secondary"), do: "bg-[#877C7C]/50"
  defp background_opacity("success"), do: "bg-[#6EE7B7]/50"
  defp background_opacity("warning"), do: "bg-[#FF8B08]/50"
  defp background_opacity("danger"), do: "bg-[#E73B3B]/50"
  defp background_opacity("info"), do: "bg-[#004FC4]/50"
  defp background_opacity("misc"), do: "bg-[#52059C]/50"
  defp background_opacity("dawn"), do: "bg-[#4D4137]/50"
  defp background_opacity("light"), do: "bg-[#707483]/50"
  defp background_opacity("dark"), do: "bg-[#050404]/50"

  defp background_opacity(nil), do: "bg-transparent"
  defp background_opacity(background), do: "#{background}"

  defp overlay_class(%{has_overlay: true}), do: "absolute w-full top-0 bottom-0"
  defp overlay_class(_), do: nil

  defp default_classes() do
    [
      "animate-spin border-t-transparent rounded-full border-current"
    ]
  end
end
