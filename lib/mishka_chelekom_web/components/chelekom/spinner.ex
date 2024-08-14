defmodule MishkaChelekom.Spinner do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def spinner(assigns) do
    ~H"""
    <div class="animate-spin inline-block border-t-transparent rounded-full border-current border-[3px] text-gray-800" role="status" aria-label="loading">
      <span class="sr-only">Loading...</span>
    </div>
    """
  end
end
