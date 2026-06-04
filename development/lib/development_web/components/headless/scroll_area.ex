defmodule DevelopmentWeb.Components.Headless.ScrollArea do
  @moduledoc """
  Headless **scroll area** — a scrollable viewport.

  A structural overflow container with a focusable viewport (keyboard scrolling). It ships
  **no** custom scrollbar styling — style the `chelekom-scroll_area*` classes (and, if you
  want a custom scrollbar, attach the optional `ScrollArea` JS hook). `data-orientation`
  selects the scroll axis.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :orientation, :string, default: "vertical", values: ~w(vertical horizontal both)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def scroll_area(assigns) do
    ~H"""
    <div id={@id} class={["chelekom-scroll_area", @class]} data-orientation={@orientation} {@rest}>
      <div data-part="viewport" tabindex="0" class="chelekom-scroll_area__viewport">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
