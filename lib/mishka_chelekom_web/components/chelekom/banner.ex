defmodule MishkaChelekom.Banner do
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

  attr :variant, :string,
    values: ["default", "spaced"],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :border, :string, doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :position, :string, values: ["top", "bottom"], default: "top", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :rest, :global, include: ~w(right_dismiss left_dismiss), doc: ""

  def banner(assigns) do
    ~H"""
    """
  end
end
