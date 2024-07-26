defmodule MishkaChelekom.Chat do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def chat(assigns) do
    ~H"""
    """
  end
end
