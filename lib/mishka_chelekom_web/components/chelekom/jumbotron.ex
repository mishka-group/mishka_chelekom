defmodule MishkaChelekom.Jumbotron do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def jumbotron(assigns) do
    ~H"""
    """
  end
end
