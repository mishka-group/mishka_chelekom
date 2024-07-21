defmodule MishkaChelekom.Hr do
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
  attr :type, :string, values: ["dashed", "solid"], default: "dashed", doc: ""
  attr :color, :string, values: @colors, default: "white", doc: ""
  attr :size, :string, default: "large", doc: ""
  attr :class, :string, default: nil, doc: ""

  def hr(assigns) do
    ~H"""
    """
  end
end
