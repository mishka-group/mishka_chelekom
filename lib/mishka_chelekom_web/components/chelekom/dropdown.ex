defmodule MishkaChelekom.Dropdown do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def dropdown(assigns) do
    ~H"""
    """
  end
end
