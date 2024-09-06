defmodule MishkaChelekom.Menu do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  slot :inner_block, doc: ""
  attr :rest, :global, doc: ""

  def menu(assigns) do
    ~H"""
    <ul id={@id} class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end
end
