defmodule DevelopmentWeb.Components.Headless.Breadcrumb do
  @moduledoc """
  Headless **breadcrumb** — the trail back up, as an ordered list inside a landmark.

  The semantics are the part worth owning. The root is a `<nav aria-label>` so a screen reader can
  jump to it, the trail is an `<ol>` because the order carries meaning, and the last item renders as
  a `<span aria-current="page">` rather than a link — a link to the page you are already on is a
  dead end that still takes a tab stop. Separators are `aria-hidden`, so the trail reads as words
  and not as punctuation.

  `max_items` collapses a long trail: the first `boundary` items, an ellipsis, then the last
  `boundary` items. That is server-side arithmetic, so it costs no JS and works before the socket
  connects — and the ellipsis is a real `<button>` when `on_expand` is given, so the trail can be
  opened rather than merely truncated.

  Parts: `list`, `item`, `link`, `separator`, `ellipsis`.

  Ships **no** colors, sizing or spacing — style via `chelekom-breadcrumb*`.

  WAI-ARIA: https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/breadcrumb
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id"
  attr :label, :string, default: "Breadcrumb", doc: "Accessible name for the nav landmark"

  attr :max_items, :integer,
    default: nil,
    doc: "Collapse the middle of the trail once it is longer than this; nil never collapses"

  attr :boundary, :integer,
    default: 1,
    doc: "How many items to keep at each end when collapsing"

  attr :on_expand, :any,
    default: nil,
    doc: "A JS command or LiveView event name; makes the ellipsis a real button"

  attr :expand_label, :string,
    default: "Show all",
    doc: "Accessible label for the ellipsis button"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :list_class, :any, default: nil, doc: ~s|Extra classes for `data-part="list"`|
  attr :item_class, :any, default: nil, doc: ~s|Extra classes for `data-part="item"`|
  attr :separator_class, :any, default: nil, doc: ~s|Extra classes for `data-part="separator"`|
  attr :ellipsis_class, :any, default: nil, doc: ~s|Extra classes for `data-part="ellipsis"`|
  attr :rest, :global

  slot :separator, doc: "Custom separator; falls back to a `/` character"

  slot :item, doc: "One crumb" do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :current, :boolean, doc: "Force this crumb to be the current page"
    attr :class, :any
  end

  def breadcrumb(assigns) do
    assigns =
      assign(assigns, :entries, collapse(assigns.item, assigns.max_items, assigns.boundary))

    ~H"""
    <nav
      id={@id}
      aria-label={@label}
      data-part="root"
      data-collapsed={@entries != @item}
      class={["chelekom-breadcrumb", @class]}
      {@rest}
    >
      <ol data-part="list" class={["chelekom-breadcrumb__list", @list_class]}>
        <li
          :for={{entry, index} <- Enum.with_index(@entries)}
          data-part="item"
          data-index={index}
          data-current={entry == :ellipsis && nil}
          class={["chelekom-breadcrumb__item", @item_class]}
        >
          <span
            :if={index > 0}
            data-part="separator"
            data-default={@separator == []}
            aria-hidden="true"
            class={["chelekom-breadcrumb__separator", @separator_class]}
          >{if @separator != [], do: render_slot(@separator), else: "/"}</span>

          <.crumb
            entry={entry}
            last?={index == length(@entries) - 1}
            on_expand={@on_expand}
            expand_label={@expand_label}
            ellipsis_class={@ellipsis_class}
          />
        </li>
      </ol>
    </nav>
    """
  end

  attr :entry, :any, required: true
  attr :last?, :boolean, required: true
  attr :on_expand, :any, required: true
  attr :expand_label, :string, required: true
  attr :ellipsis_class, :any, default: nil

  defp crumb(%{entry: :ellipsis} = assigns) do
    ~H"""
    <button
      :if={@on_expand}
      type="button"
      data-part="ellipsis"
      aria-label={@expand_label}
      phx-click={expand_action(@on_expand)}
      class={["chelekom-breadcrumb__ellipsis", @ellipsis_class]}
    >…</button>
    <span
      :if={!@on_expand}
      data-part="ellipsis"
      class={["chelekom-breadcrumb__ellipsis", @ellipsis_class]}
    >…</span>
    """
  end

  defp crumb(assigns) do
    assigns = assign(assigns, :current?, current?(assigns.entry, assigns.last?))

    ~H"""
    <.link
      :if={!@current? && link?(@entry)}
      navigate={@entry[:navigate]}
      patch={@entry[:patch]}
      href={@entry[:href]}
      data-part="link"
      class={["chelekom-breadcrumb__link", @entry[:class]]}
    >{render_slot(@entry)}</.link>

    <span
      :if={@current? || !link?(@entry)}
      data-part="link"
      aria-current={@current? && "page"}
      class={["chelekom-breadcrumb__link", @entry[:class]]}
    >{render_slot(@entry)}</span>
    """
  end

  # The last crumb is the page you are on, so it is text, not a link — unless the caller says
  # otherwise, which is how a trail that ends in a section rather than the current page works.
  defp current?(entry, last?), do: Map.get(entry, :current, last?)

  defp link?(entry), do: entry[:navigate] || entry[:patch] || entry[:href]

  defp expand_action(%Phoenix.LiveView.JS{} = js), do: js
  defp expand_action(event) when is_binary(event), do: Phoenix.LiveView.JS.push(event)

  # Collapsing is arithmetic, not a widget: keep `boundary` crumbs at each end and stand one
  # ellipsis in for everything between. Below the threshold the list is returned untouched, so
  # `entries == item` is what tells the root whether it collapsed.
  defp collapse(items, nil, _boundary), do: items

  defp collapse(items, max, boundary) when length(items) > max and max > 0 do
    keep = max(boundary, 1)

    if length(items) <= keep * 2 + 1 do
      items
    else
      Enum.take(items, keep) ++ [:ellipsis] ++ Enum.take(items, -keep)
    end
  end

  defp collapse(items, _max, _boundary), do: items
end
