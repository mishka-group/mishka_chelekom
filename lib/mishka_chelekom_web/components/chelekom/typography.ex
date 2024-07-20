defmodule MishkaChelekom.Typography do
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

  def h1(assigns) do
    ~H"""
    """
  end

  def h2(assigns) do
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

  def h3(assigns) do
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

  def h4(assigns) do
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

  def h5(assigns) do
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

  def h6(assigns) do
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

  def p(assigns) do
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

  attr :id, :string, default: nil, doc: ""
  attr :color, :string, values: @colors, default: "dark", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :font_weight, :string, default: "font-normal", doc: ""
  attr(:rest, :global)
  slot :inner_block, required: true, doc: ""

  def strong(assigns) do
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

  def em(assigns) do
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

  def blockquote(assigns) do
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

  def dl(assigns) do
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

  def dt(assigns) do
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

  def dd(assigns) do
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

  def figure(assigns) do
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

  def figcaption(assigns) do
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

  def abbr(assigns) do
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

  def mark(assigns) do
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

  def small(assigns) do
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

  def s(assigns) do
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

  def u(assigns) do
    ~H"""
    """
  end
end
