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

    # add a brand-new :brand color (new name ⇒ added). NB: Tailwind v4 → `bg-linear-*`, not `bg-gradient-*`
    color :brand,
          "bg-linear-to-r! from-fuchsia-600! to-indigo-600! text-white! hover:opacity-90!"

    variant :glow, "shadow-[0_0_25px_currentColor]! ring-2! ring-current/30!"
    default color: "brand"
  end

  # Customize the alert — its color lives in `kind` (an atom); add a brand kind.
  customize :alert do
    kind :brand, "bg-indigo-600! text-white!"
    default kind: :brand, variant: "default"
  end

  # `from {Module, :function}` — point at an EXACT module/function instead of the convention. Here
  # `DevelopmentWeb.Widgets.ribbon/1` is hand-written and lives nowhere near `<Web>.Components`, so the
  # bare-atom convention could never find it — the tuple does, with no `components` namespace needed.
  customize :ribbon do
    from {DevelopmentWeb.Widgets, :ribbon}
    base "plain"
    color :brand, "bg-fuchsia-600! text-white! ring-fuchsia-600!"
    default color: :brand
  end

  # Customize the headless accordion (its `part` rules ⇒ headless) into a styled `my_accordion`.
  # The headless component ships *zero* CSS, so the entire look is baked in right here — verbatim
  # classes, scanned straight from this file (no safelist). Each `part` rule targets a `data-part`
  # via a `[&_…]:` variant; the rules are concatenated onto the wrapper's root element.
  customize :my_accordion do
    from :accordion

    # the whole card — background, border, rounded corners, and hairline dividers between items
    part :root,
         "rounded-2xl border border-base-300 bg-base-100 shadow-sm overflow-hidden divide-y divide-base-200"

    # tint whichever item is open so it reads as one clear, highlighted block
    part :item,
         "[&_[data-part=item]:has([data-part=panel][data-open])]:bg-base-200/40"

    # the header button — full-width row, comfy padding, hover tint, and a chevron that flips when open
    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:px-4 [&_[data-part=trigger]]:py-3.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:transition-colors [&_[data-part=trigger]]:hover:bg-base-200/60 [&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-base-content/40 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][aria-expanded=true]]:after:rotate-180"

    # the panel — padded body with muted text (closed panels are hidden by the headless base CSS)
    part :panel,
         "[&_[data-part=panel]]:px-4 [&_[data-part=panel]]:pb-4 [&_[data-part=panel]]:pt-1 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:text-base-content/70"
  end
end
