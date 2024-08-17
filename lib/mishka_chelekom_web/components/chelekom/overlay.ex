defmodule MishkaChelekom.Overlay do
  use Phoenix.Component

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
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :opacity, :integer, default: 100, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def overlay(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "absolute inset-0",
        color_class(@color, @opacity),
        @class
      ]}
      {@rest}
    >

    </div>
    """
  end

  defp color_class("white", opacity) do
    "bg-white/#{opacity}"
  end

  defp color_class("primary", opacity) do
    "bg-[#2441de]/#{opacity}"
  end

  defp color_class("secondary", opacity) do
    "bg-[#877C7C]/#{opacity}"
  end

  defp color_class("success", opacity) do
    "bg-[#6EE7B7]/#{opacity}"
  end

  defp color_class("warning", opacity) do
    "bg-[#FF8B08]/#{opacity}"
  end

  defp color_class("danger", opacity) do
    "bg-[#E73B3B]/#{opacity}"
  end

  defp color_class("info", opacity) do
    "bg-[#004FC4]/#{opacity}"
  end

  defp color_class("misc", opacity) do
    "bg-[#52059C]/#{opacity}"
  end

  defp color_class("dawn", opacity) do
    "bg-[#4D4137]/#{opacity}"
  end

  defp color_class("light", opacity) do
    "bg-[#707483]/#{opacity}"
  end

  defp color_class("dark", opacity) do
    "bg-[#050404]/#{opacity}"
  end
end
