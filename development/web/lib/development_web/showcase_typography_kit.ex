defmodule DevelopmentWeb.ShowcaseTypographyKit do
  @moduledoc """
  A standalone `MishkaChelekom.Kit` just for `typography`.

  Unlike the 62 single-component wrappers in `DevelopmentWeb.ShowcaseKit`, `typography` has no single
  `typography/1` function to wrap (it's a family of `h1`/`p`/`strong`/… functions). So this Kit points
  `components` at `DevelopmentWeb.Kit`, where `DevelopmentWeb.Kit.Typography.typography/1` renders a
  representative specimen — and the brand rule recolors every element to FUCHSIA via descendant
  variants (`[&_h1]:…`), since each element carries its own text colour.
  """
  use MishkaChelekom.Kit

  components(DevelopmentWeb.Kit)

  customize :typography_kit do
    from :typography
    base "natural"

    color :brand,
          "[&_h1]:text-fuchsia-600! [&_h2]:text-fuchsia-600! [&_h3]:text-fuchsia-600! [&_h4]:text-fuchsia-600! [&_p]:text-fuchsia-600! [&_small]:text-fuchsia-600!"

    default color: :brand
  end
end
