defmodule MishkaChelekom.Badge do
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
    values: ["default", "bordered"],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :icon, :string, default: nil, doc: ""
  attr :border, :string, doc: ""
  # left, right, top_right, top_left
  slot :notification, required: false
  attr :rest, :global, include: ~w(right_dismiss left_dismiss right_icon left_icon), doc: ""
  slot :inner_block, required: false, doc: ""

  def badge(assigns) do
    ~H"""
    """
  end
end
