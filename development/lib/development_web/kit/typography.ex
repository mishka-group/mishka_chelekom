defmodule DevelopmentWeb.Kit.Typography do
  @moduledoc """
  A showcase-only *specimen* of the `typography` component family.

  `typography` is not one component — it's ~20 semantic text functions (`h1`..`h6`, `p`, `strong`,
  `em`, `mark`, …). The `MishkaChelekom.Kit` `customize`/`from` convention maps one name → one module
  → one function, so it can't wrap "typography" as a whole. This module gives the Kit a single
  `typography/1` to point at (`DevelopmentWeb.ShowcaseTypographyKit` sets `components` to
  `DevelopmentWeb.Kit`, so `from :typography` resolves here). It just renders a representative block
  the Kit can then recolor — exactly mirroring the typography preview.
  """
  use DevelopmentWeb, :html

  attr :color, :string, default: "natural", doc: "Color theme forwarded to each element"
  attr :size, :string, default: "medium", doc: "Body text size"
  attr :class, :any, default: nil, doc: "Custom classes (the Kit appends its brand rules here)"
  attr :rest, :global

  def typography(assigns) do
    ~H"""
    <div class={["space-y-2 text-left", @class]} {@rest}>
      <.h1 color={@color}>Heading one</.h1>
      <.h2 color={@color}>Heading two</.h2>
      <.h3 color={@color}>Heading three</.h3>
      <.h4 color={@color}>Heading four</.h4>
      <.p color={@color} size={@size}>
        Body paragraph with <.strong>strong</.strong>, <.em>emphasis</.em>, <.mark>a highlight</.mark>, <.u>underline</.u>, <.s>strikethrough</.s>, and an
        <.abbr title="HyperText Markup Language">HTML</.abbr>
        abbreviation.
      </.p>
      <.small color={@color}>Small print — captions and fine details.</.small>
    </div>
    """
  end
end
