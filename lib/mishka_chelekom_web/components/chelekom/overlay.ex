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
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :opacity, :string, default: "100", doc: ""
  attr :backdrop, :string, default: "none", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  def overlay(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "absolute inset-0",
        color_class(@color, @opacity, @backdrop),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp color_class("white", opacity, backdrop) do
    "bg-white/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("primary", opacity, backdrop) do
    "bg-[#2441de]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("secondary", opacity, backdrop) do
    "bg-[#877C7C]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("success", opacity, backdrop) do
    "bg-[#6EE7B7]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("warning", opacity, backdrop) do
    "bg-[#FF8B08]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("danger", opacity, backdrop) do
    "bg-[#E73B3B]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("info", opacity, backdrop) do
    "bg-[#004FC4]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("misc", opacity, backdrop) do
    "bg-[#52059C]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("dawn", opacity, backdrop) do
    "bg-[#4D4137]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("light", opacity, backdrop) do
    "bg-[#707483]/#{opacity} backdrop-blur-#{backdrop}"
  end

  defp color_class("dark", opacity, backdrop) do
    "bg-[#050404]/#{opacity} backdrop-blur-#{backdrop}"
  end
end
