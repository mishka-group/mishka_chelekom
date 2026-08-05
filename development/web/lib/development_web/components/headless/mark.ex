defmodule DevelopmentWeb.Components.Headless.Mark do
  @moduledoc """
  Headless **mark** — highlight an inline run of text with a `<mark>` (Mantine Mark parity).

  Semantics only — bring your own highlight color. Ships **no** styling; style via `chelekom-mark`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/mark
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :class, :any, default: nil, doc: "Extra classes"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The text to highlight"

  def mark(assigns) do
    ~H"""
    <mark id={@id} class={["chelekom-mark", @class]} {@rest}>{render_slot(@inner_block)}</mark>
    """
  end
end
