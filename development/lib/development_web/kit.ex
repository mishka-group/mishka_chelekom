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

    # the whole card — warm amber surface (a hue the project's palette doesn't ship), with a matching
    # border and hairline dividers. Every color carries a `dark:` twin so it reads in both themes.
    part :root,
         "rounded-2xl border border-amber-200 bg-amber-50 shadow-sm overflow-hidden divide-y divide-amber-200/70 dark:border-amber-900/50 dark:bg-amber-950/30 dark:divide-amber-900/40"

    # tint whichever item is open a touch deeper so it reads as one clear, highlighted block
    part :item,
         "[&_[data-part=item]:has([data-part=panel][data-open])]:bg-amber-100/70 dark:[&_[data-part=item]:has([data-part=panel][data-open])]:bg-amber-900/20"

    # the header button — full-width row, comfy padding, warm hover + open-state text, and an amber
    # chevron that flips when open
    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:px-4 [&_[data-part=trigger]]:py-3.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger]]:transition-colors [&_[data-part=trigger]]:hover:bg-amber-100/60 dark:[&_[data-part=trigger]]:hover:bg-amber-900/30 [&_[data-part=trigger][aria-expanded=true]]:text-amber-700 dark:[&_[data-part=trigger][aria-expanded=true]]:text-amber-300 [&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-amber-500 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][aria-expanded=true]]:after:rotate-180"

    # the panel — padded body with warm muted text (closed panels are hidden by the headless base CSS)
    part :panel,
         "[&_[data-part=panel]]:px-4 [&_[data-part=panel]]:pb-4 [&_[data-part=panel]]:pt-1 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:text-amber-900/70 dark:[&_[data-part=panel]]:text-amber-100/70"
  end

  # Customize the headless collapsible into a styled `my_collapsible` — same warm amber palette as
  # `my_accordion`, but a single trigger/panel pair (no group). The closed panel is hidden by the engine.
  customize :my_collapsible do
    from :collapsible

    # the whole card — warm amber surface + border + rounded corners
    part :root,
         "rounded-2xl border border-amber-200 bg-amber-50 shadow-sm overflow-hidden dark:border-amber-900/50 dark:bg-amber-950/30"

    # the header button — full-width row, warm hover + open-state text, and an amber chevron that flips
    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:px-4 [&_[data-part=trigger]]:py-3.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger]]:transition-colors [&_[data-part=trigger]]:hover:bg-amber-100/60 dark:[&_[data-part=trigger]]:hover:bg-amber-900/30 [&_[data-part=trigger][aria-expanded=true]]:text-amber-700 dark:[&_[data-part=trigger][aria-expanded=true]]:text-amber-300 [&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-amber-500 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][aria-expanded=true]]:after:rotate-180"

    # the panel — warm muted body, divided from the header (closed panel hidden by the engine)
    part :panel,
         "[&_[data-part=panel]]:border-t [&_[data-part=panel]]:border-amber-200/70 dark:[&_[data-part=panel]]:border-amber-900/40 [&_[data-part=panel]]:px-4 [&_[data-part=panel]]:py-3 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:text-amber-900/70 dark:[&_[data-part=panel]]:text-amber-100/70"
  end
end
