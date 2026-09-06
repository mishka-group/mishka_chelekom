defmodule DevelopmentWeb.Components.Headless.Card do
  @moduledoc """
  Headless **card** — a titled block of content with an optional image and a row of actions.

  A card is layout, not behaviour, so this ships no JS. What it does carry is the semantics that
  are easy to get wrong by hand: the `:title` slot renders a real heading at the level you ask for
  (`title_level`, default `h3`) rather than a bold `<div>`, and it is wired to the root through
  `aria-labelledby`, so a card announced on its own says what it is.

  `figure_position` decides whether the image renders before or after the body. That is a markup
  order, not a class — daisyUI's own rounding rules key off `figure:first-child` versus
  `:last-child` — so flipping it here is what makes a `card-side` image sit on the right with the
  correct corners, instead of hand-reordering the slots at every call site.

  `href` / `navigate` / `patch` turn the whole card into a link, which is the honest markup for a
  card that is one big click target: a nested `<a>` inside a clickable `<div>` is not.

  Parts: `figure`, `body`, `title`, `content`, `actions`.

  Ships **no** colors, sizing or spacing — style via `chelekom-card*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/card
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id (anchors the title for aria-labelledby)"

  attr :title_level, :string,
    default: "h3",
    values: ~w(h1 h2 h3 h4 h5 h6 div),
    doc: "Heading element for the `:title` slot; `div` opts out of the document outline"

  attr :figure_position, :string,
    default: "start",
    values: ~w(start end),
    doc: "Render the figure before or after the body"

  attr :navigate, :string, default: nil, doc: "Make the whole card a `<.link navigate>`"
  attr :patch, :string, default: nil, doc: "Make the whole card a `<.link patch>`"
  attr :href, :string, default: nil, doc: "Make the whole card a `<.link href>`"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :figure_class, :any, default: nil, doc: ~s|Extra classes for `data-part="figure"`|
  attr :body_class, :any, default: nil, doc: ~s|Extra classes for `data-part="body"`|
  attr :title_class, :any, default: nil, doc: ~s|Extra classes for `data-part="title"`|
  attr :actions_class, :any, default: nil, doc: ~s|Extra classes for `data-part="actions"`|
  attr :content_class, :any, default: nil, doc: ~s|Extra classes for `data-part="content"`|
  attr :rest, :global, include: ~w(download hreflang referrerpolicy rel target)

  slot :figure, doc: "The image (or any media); rendered inside a `<figure>`"
  slot :title, doc: "Card heading"
  slot :actions, doc: "Buttons or links at the end of the body"
  slot :inner_block, doc: "The card content"

  def card(assigns) do
    assigns = assign(assigns, :link?, assigns.navigate || assigns.patch || assigns.href)

    ~H"""
    <.dynamic_tag
      tag_name={if @link?, do: "a", else: "div"}
      id={@id}
      data-part="root"
      aria-labelledby={@title != [] && @id && "#{@id}-title"}
      data-figure-position={@figure_position}
      class={["chelekom-card", @class]}
      {link_attrs(assigns)}
      {@rest}
    >
      <.card_figure :if={@figure_position == "start"} figure={@figure} class={@figure_class} />

      <div data-part="body" class={["chelekom-card__body", @body_class]}>
        <.dynamic_tag
          :if={@title != []}
          tag_name={@title_level}
          id={@id && "#{@id}-title"}
          data-part="title"
          class={["chelekom-card__title", @title_class]}
        >
          {render_slot(@title)}
        </.dynamic_tag>

        <div
          :if={@inner_block != []}
          data-part="content"
          class={["chelekom-card__content", @content_class]}
        >
          {render_slot(@inner_block)}
        </div>

        <div
          :if={@actions != []}
          data-part="actions"
          class={["chelekom-card__actions", @actions_class]}
        >
          {render_slot(@actions)}
        </div>
      </div>

      <.card_figure :if={@figure_position == "end"} figure={@figure} class={@figure_class} />
    </.dynamic_tag>
    """
  end

  attr :figure, :list, required: true
  attr :class, :any, default: nil

  defp card_figure(assigns) do
    ~H"""
    <figure :if={@figure != []} data-part="figure" class={["chelekom-card__figure", @class]}>
      {render_slot(@figure)}
    </figure>
    """
  end

  # `patch` and `navigate` are LiveView's own attributes on `<.link>`, but the root here is a
  # dynamic tag, so the href and the data-phx-link markers have to be assembled directly.
  defp link_attrs(%{navigate: navigate}) when is_binary(navigate),
    do: %{"href" => navigate, "data-phx-link" => "redirect", "data-phx-link-state" => "push"}

  defp link_attrs(%{patch: patch}) when is_binary(patch),
    do: %{"href" => patch, "data-phx-link" => "patch", "data-phx-link-state" => "push"}

  defp link_attrs(%{href: href}) when is_binary(href), do: %{"href" => href}

  defp link_attrs(_), do: %{}
end
