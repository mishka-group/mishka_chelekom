defmodule MishkaChelekom.Menu do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def menu(assigns) do
    ~H"""
    """
  end
end
