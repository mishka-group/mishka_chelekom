defmodule MishkaChelekom.List do
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

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ul(assigns) do
    ~H"""
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def li(assigns) do
    ~H"""
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def ol(assigns) do
    ~H"""
    """
  end
end
