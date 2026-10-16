defmodule DevelopmentWeb.Components.Headless.ScrollArea do
  @moduledoc """
  Headless **scroll area** — a scrollable viewport with a custom scrollbar (Base UI parity).

  The native scrollbar is hidden; the `ScrollArea` engine drives a custom `scrollbar` + `thumb`: the
  thumb is sized proportionally to the content (via `--scroll-area-thumb-height/width`), tracks the
  scroll position, is draggable, and its scrollbar hides when that axis doesn't overflow. `orientation`
  selects which scrollbars render (`vertical` · `horizontal` · `both`).

  State (on root/viewport/scrollbar/content) mirrors Base UI: `data-scrolling`, `data-hovering`
  (scrollbar), `data-has-overflow-x`/`-y`, `data-overflow-{x,y}-{start,end}`. The distance from each
  edge is exposed as `--scroll-area-overflow-{x,y}-{start,end}` (px) so you can fade the edges. Anatomy:
  `viewport`, `content`, `scrollbar` (per orientation), `thumb`, `corner`. Style via `chelekom-scroll_area*`.

  WAI-ARIA APG: no formal pattern; the viewport is focusable for keyboard scrolling.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/scroll-area
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :orientation, :string, default: "vertical", values: ~w(vertical horizontal both)
  attr :class, :any, default: nil
  attr :viewport_class, :any, default: nil, doc: "Custom class for the focusable scroll viewport"
  attr :content_class, :any, default: nil, doc: "Custom class for the scrollable content wrapper"
  attr :scrollbar_class, :any, default: nil, doc: "Custom class for both scrollbars"
  attr :thumb_class, :any, default: nil, doc: "Custom class for both scrollbar thumbs"
  attr :corner_class, :any, default: nil, doc: "Custom class for the corner (both orientation)"
  attr :rest, :global

  slot :inner_block, required: true

  def scroll_area(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ScrollArea"
      data-orientation={@orientation}
      class={["chelekom-scroll_area", "group/scroll-area relative", @class]}
      {@rest}
    >
      <div
        data-part="viewport"
        tabindex="0"
        class={[
          "chelekom-scroll_area__viewport",
          "h-full w-full overflow-auto [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
          "group-data-[orientation=horizontal]/scroll-area:overflow-y-hidden group-data-[orientation=vertical]/scroll-area:overflow-x-hidden",
          @viewport_class
        ]}
      >
        <div data-part="content" class={["chelekom-scroll_area__content", @content_class]}>
          {render_slot(@inner_block)}
        </div>
      </div>

      <div
        :if={@orientation in ~w(vertical both)}
        data-part="scrollbar"
        data-orientation="vertical"
        class={[
          "chelekom-scroll_area__scrollbar",
          "absolute! data-[orientation=vertical]:top-0! data-[orientation=vertical]:right-0! data-[orientation=vertical]:bottom-0!",
          @scrollbar_class
        ]}
      >
        <div
          data-part="thumb"
          data-orientation="vertical"
          class={[
            "chelekom-scroll_area__thumb",
            "data-[orientation=vertical]:h-(--scroll-area-thumb-height,2.5rem)!",
            @thumb_class
          ]}
        >
        </div>
      </div>

      <div
        :if={@orientation in ~w(horizontal both)}
        data-part="scrollbar"
        data-orientation="horizontal"
        class={[
          "chelekom-scroll_area__scrollbar",
          "absolute! data-[orientation=horizontal]:right-0! data-[orientation=horizontal]:bottom-0! data-[orientation=horizontal]:left-0!",
          @scrollbar_class
        ]}
      >
        <div
          data-part="thumb"
          data-orientation="horizontal"
          class={[
            "chelekom-scroll_area__thumb",
            "data-[orientation=horizontal]:w-(--scroll-area-thumb-width,2.5rem)!",
            @thumb_class
          ]}
        >
        </div>
      </div>

      <div
        :if={@orientation == "both"}
        data-part="corner"
        class={["chelekom-scroll_area__corner", @corner_class]}
      >
      </div>
    </div>
    """
  end
end
