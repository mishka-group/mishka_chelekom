defmodule DevelopmentWeb.Kit do
  @moduledoc """
  A `MishkaChelekom.Kit` demo — the two ways to reuse existing Mishka components:

    * `customize` an existing styled component (add a brand color, a glow variant) — reuses the
      real `DevelopmentWeb.Components.Button` / `.Alert`, never touches their files.
    * `skin` an existing headless component (`accordion` → a styled `my_accordion`).

  Classes are used **verbatim** — written whole right here, so Tailwind scans them straight from this
  file (no safelist, no `@source inline`): styled classes carry a trailing `!` for precedence, and
  part classes are full `[&_[data-part=…]]:` variants. Powers `/showcase/kit`. Wrappers are reached by
  remote call (`<DevelopmentWeb.Kit.button …>`) so they don't clash with the globally-imported originals.
  """
  use MishkaChelekom.Kit

  # Customize the styled button — restyle an existing color, add a new one, add a variant.
  customize :button do
    # replace the existing :primary (same name ⇒ your classes win)
    color :primary, "bg-rose-600! text-white! hover:bg-rose-700!"

    # add a brand-new :brand color (new name ⇒ added)
    color :brand,
          "bg-gradient-to-r! from-fuchsia-600! to-indigo-600! text-white! hover:opacity-90!"

    variant :glow, "shadow-[0_0_25px_currentColor]! ring-2! ring-current/30!"
    default color: "brand"
  end

  # Customize the alert — its color lives in `kind` (an atom); add a brand kind.
  customize :alert do
    kind :brand, "bg-indigo-600! text-white!"
    default kind: :brand, variant: "default"
  end

  # Customize the headless accordion (its `part` rules ⇒ headless) into a styled `my_accordion`.
  customize :my_accordion do
    from :accordion

    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:py-3 [&_[data-part=trigger]]:font-medium"

    part :panel,
         "[&_[data-part=panel]]:pb-3 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:text-base-content/70"
  end
end
