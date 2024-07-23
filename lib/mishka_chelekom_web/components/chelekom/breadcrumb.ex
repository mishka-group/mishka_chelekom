defmodule MishkaChelekom.Breadcrumb do
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
  attr :separator, :string, default: "chevron-right", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""

  slot :item, required: true do
    attr :text, :string, required: true
    attr :icon, :string
    attr :link, :string
  end

  attr :rest, :global
  slot :inner_block, required: false, doc: ""

  def breadcrumb(assigns) do
    ~H"""
    """
  end
end
