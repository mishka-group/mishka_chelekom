defmodule DevelopmentWeb.Components.Headless.Marquee do
  @moduledoc """
  Headless **marquee** — a continuously scrolling row of content (Mantine Marquee parity).

  The content is rendered **twice** (the second copy `aria-hidden`) inside a `track`, so a
  simple `translateX(-50%)` CSS animation loops seamlessly — **pure CSS, no JS hook**. You
  own the keyframes, speed and direction; clip the overflow on the root.

  Ships **no** styling or animation — style via `chelekom-marquee*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/marquee
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :class, :any, default: nil, doc: "Extra classes for the root (clip overflow here)"
  attr :track_class, :any, default: nil, doc: "Extra classes for the moving track (animate here)"
  attr :group_class, :any, default: nil, doc: "Extra classes for each content group"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The scrolling content"

  def marquee(assigns) do
    ~H"""
    <div id={@id} data-part="root" class={["chelekom-marquee", @class]} {@rest}>
      <div data-part="track" class={["chelekom-marquee__track", @track_class]}>
        <div data-part="group" class={["chelekom-marquee__group", @group_class]}>
          {render_slot(@inner_block)}
        </div>
        <div data-part="group" aria-hidden="true" class={["chelekom-marquee__group", @group_class]}>
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end
end
