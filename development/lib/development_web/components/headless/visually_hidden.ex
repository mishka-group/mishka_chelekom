defmodule DevelopmentWeb.Components.Headless.VisuallyHidden do
  @moduledoc """
  Headless **visually hidden** — hide content visually while keeping it available to
  screen readers (Mantine VisuallyHidden parity).

  Applies the standard visually-hidden CSS inline so it works with **no** stylesheet —
  use it for extra labels, live-region text, or skip-link content.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/visually_hidden
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :class, :any, default: nil, doc: "Extra classes"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The screen-reader-only content"

  def visually_hidden(assigns) do
    ~H"""
    <span
      id={@id}
      class={["chelekom-visually-hidden", @class]}
      style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0"
      {@rest}
    >{render_slot(@inner_block)}</span>
    """
  end
end
