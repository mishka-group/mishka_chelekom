defmodule MishkaChelekom.Rating do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def rating(assigns) do
    ~H"""
    """
  end
end
