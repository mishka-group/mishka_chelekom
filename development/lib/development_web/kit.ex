defmodule DevelopmentWeb.Kit do
  @moduledoc """
  A `MishkaChelekom.Kit` demo — the two ways to reuse existing Mishka components:

    * `customize` an existing styled component (add a brand color, a glow variant) — reuses the
      real `DevelopmentWeb.Components.Button` / `.Alert`, never touches their files.
    * `skin` an existing headless component (`accordion` → a styled `my_accordion`).

  The `customize` classes are written with a trailing `!` so Tailwind scans them straight from this
  file; the `skin` part classes are safelisted via `@source inline(...)` in `app.css`. Powers
  `/showcase/kit`. Wrappers are reached by remote call (`<DevelopmentWeb.Kit.button …>`) so they
  don't clash with the globally-imported originals.
  """
  use MishkaChelekom.Kit

  # Customize the styled button — add a brand gradient color + a glow variant.
  customize :button do
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
    part :trigger, "flex w-full justify-between py-3 font-medium"
    part :panel, "pb-3 text-sm text-base-content/70"
  end
end
