defmodule DevelopmentWeb.Components.Headless.Fieldset do
  @moduledoc """
  Headless **fieldset** — groups a set of related form controls.

  Renders a native `<fieldset>` with an optional `<legend>` (shown when the `<:legend>`
  slot is provided) followed by the grouped fields. The native `fieldset`/`legend`
  elements already supply the grouping semantics and accessible name, so no JS or extra
  ARIA wiring is required. Style via the `chelekom-fieldset*` classes — this component
  ships **no** colors or spacing.

  Anatomy (named slots / parts): `legend` (the group label), inner content (the fields).
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id for the fieldset"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :legend, doc: "The group label rendered as a <legend>"
  slot :inner_block, required: true, doc: "The grouped form controls"

  def fieldset(assigns) do
    ~H"""
    <fieldset id={@id} class={["chelekom-fieldset", @class]} {@rest}>
      <legend :if={@legend != []} data-part="legend" class="chelekom-fieldset__legend">
        {render_slot(@legend)}
      </legend>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end
end
