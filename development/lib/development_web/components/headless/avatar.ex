defmodule DevelopmentWeb.Components.Headless.Avatar do
  @moduledoc """
  Headless **avatar** — an image with a text fallback.

  Renders an `<img>` when `src` is provided and always renders a `fallback`
  region (e.g. initials) underneath. CSS can hide the fallback once the image
  has loaded, or reveal it when the image is missing or fails to load. This
  component ships **no** colors, sizing, or spacing — style via the
  `chelekom-avatar*` classes.

  Anatomy (parts): `image` (optional, only when `src` is set), `fallback`.

  WAI-ARIA APG: no formal pattern. Decorative/representational images use an
  empty `alt` by default; pass a meaningful `alt` when the avatar conveys
  information.
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id for the root element"
  attr :src, :string, default: nil, doc: "Image source; when nil only the fallback renders"
  attr :alt, :string, default: "", doc: "Alternative text for the image"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :rest, :global

  slot :inner_block, doc: "Fallback content shown when the image is absent (e.g. initials)"

  def avatar(assigns) do
    ~H"""
    <span id={@id} class={["chelekom-avatar", @class]} {@rest}>
      <img
        :if={@src}
        data-part="image"
        src={@src}
        alt={@alt}
        class="chelekom-avatar__image"
      />
      <span data-part="fallback" class="chelekom-avatar__fallback" aria-hidden={@src && "true"}>
        {render_slot(@inner_block)}
      </span>
    </span>
    """
  end
end
