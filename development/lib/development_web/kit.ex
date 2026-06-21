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

  # Customize the headless meter into a styled `my_meter` — warm amber gauge: label on the left,
  # value pushed right, amber track + fill below. Reads in light and dark.
  customize :my_meter do
    from :meter

    part :root, "flex flex-wrap items-center"

    part :label,
         "[&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-100"

    part :value,
         "[&_[data-part=value]]:ml-auto [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-amber-700 dark:[&_[data-part=value]]:text-amber-300"

    part :track,
         "[&_[data-part=track]]:mt-1.5 [&_[data-part=track]]:h-2.5 [&_[data-part=track]]:w-full [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-amber-100 dark:[&_[data-part=track]]:bg-amber-950/40"

    # the fill — amber, width driven by the --chelekom-meter ratio the component exposes
    part :indicator,
         "[&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-amber-500 dark:[&_[data-part=indicator]]:bg-amber-400 [&_[data-part=indicator]]:[width:calc(var(--chelekom-meter)*100%)]"
  end

  customize :my_alert_dialog do
    from :alert_dialog
    part :root, "relative inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-center [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40"

    part :backdrop,
         "[&_[data-part=backdrop]]:fixed [&_[data-part=backdrop]]:inset-0 [&_[data-part=backdrop]]:z-40 [&_[data-part=backdrop]]:bg-amber-950/40 dark:[&_[data-part=backdrop]]:bg-amber-950/60 [&[data-closed]_[data-part=backdrop]]:hidden"

    part :popup,
         "[&_[data-part=popup]]:fixed [&_[data-part=popup]]:left-1/2 [&_[data-part=popup]]:top-1/2 [&_[data-part=popup]]:z-50 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:max-w-[calc(100vw-2rem)] [&_[data-part=popup]]:-translate-x-1/2 [&_[data-part=popup]]:-translate-y-1/2 [&_[data-part=popup]]:rounded-xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=popup]]:focus:outline-none dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/95 [&[data-closed]_[data-part=popup]]:hidden"

    part :title,
         "[&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=title]]:text-amber-950 dark:[&_[data-part=title]]:text-amber-50"

    part :description,
         "[&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-amber-700 dark:[&_[data-part=description]]:text-amber-300"

    part :content,
         "[&_[data-part=content]]:mt-3 [&_[data-part=content]]:text-sm [&_[data-part=content]]:text-amber-900/80 dark:[&_[data-part=content]]:text-amber-100/80"

    part :actions,
         "[&_[data-part=actions]]:mt-5 [&_[data-part=actions]]:flex [&_[data-part=actions]]:justify-end [&_[data-part=actions]]:gap-2"
  end

  customize :my_autocomplete do
    from :autocomplete
    part :root, "relative inline-block"

    part :clear,
         "[&_[data-part=clear]]:absolute [&_[data-part=clear]]:right-2 [&_[data-part=clear]]:top-1.5 [&_[data-part=clear]]:text-amber-500 [&_[data-part=clear]]:hover:text-amber-700 [&_[data-part=clear][data-hidden]]:hidden dark:[&_[data-part=clear]]:text-amber-400 dark:[&_[data-part=clear]]:hover:text-amber-200"

    part :group_label,
         "[&_[data-part=group-label]]:block [&_[data-part=group-label]]:px-3 [&_[data-part=group-label]]:pb-1 [&_[data-part=group-label]]:pt-2 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-amber-700/70 dark:[&_[data-part=group-label]]:text-amber-300/60"

    part :empty,
         "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-amber-700/60 dark:[&_[data-part=empty]]:text-amber-300/50"

    part :input,
         "[&_[data-part=input]]:w-full [&_[data-part=input]]:min-w-56 [&_[data-part=input]]:rounded-lg [&_[data-part=input]]:border [&_[data-part=input]]:border-amber-200 [&_[data-part=input]]:bg-amber-50 [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:pr-8 [&_[data-part=input]]:text-sm [&_[data-part=input]]:text-amber-950 [&_[data-part=input]]:placeholder:text-amber-700/60 [&_[data-part=input]]:outline-none [&_[data-part=input]]:focus:ring-2 [&_[data-part=input]]:focus:ring-amber-500/40 dark:[&_[data-part=input]]:border-amber-900 dark:[&_[data-part=input]]:bg-amber-950/30 dark:[&_[data-part=input]]:text-amber-50 dark:[&_[data-part=input]]:placeholder:text-amber-300/50 dark:[&_[data-part=input]]:focus:ring-amber-400/40"

    part :popup,
         "[&_[data-part=popup]]:mt-1.5 [&_[data-part=popup]]:min-w-56 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/30"

    part :item,
         "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-900 [&_[data-part=item][data-highlighted]]:bg-amber-100 [&_[data-part=item][data-highlighted]]:text-amber-950 [&_[data-part=item][aria-selected=true]]:font-semibold [&_[data-part=item][aria-selected=true]]:text-amber-950 [&_[data-part=item][data-hidden]]:hidden dark:[&_[data-part=item]]:text-amber-300 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/40 dark:[&_[data-part=item][data-highlighted]]:text-amber-50 dark:[&_[data-part=item][aria-selected=true]]:text-amber-50"
  end

  customize :my_avatar do
    from :avatar

    part :root,
         "relative inline-flex h-12 w-12 items-center justify-center overflow-hidden rounded-full border border-amber-200 bg-amber-50 text-sm font-semibold text-amber-950 dark:border-amber-900 dark:bg-amber-950/30 dark:text-amber-50 [&:has([data-part=image])_[data-part=fallback]]:hidden"

    part :image,
         "[&_[data-part=image]]:h-full [&_[data-part=image]]:w-full [&_[data-part=image]]:object-cover"

    part :fallback,
         "[&_[data-part=fallback]]:absolute [&_[data-part=fallback]]:inset-0 [&_[data-part=fallback]]:flex [&_[data-part=fallback]]:items-center [&_[data-part=fallback]]:justify-center [&_[data-part=fallback]]:bg-amber-100 [&_[data-part=fallback]]:text-amber-700 dark:[&_[data-part=fallback]]:bg-amber-950/40 dark:[&_[data-part=fallback]]:text-amber-300"
  end

  customize :my_checkbox do
    from :checkbox

    part :root,
         "inline-flex cursor-pointer items-center gap-2 text-amber-950 dark:text-amber-50 [&[data-disabled]]:cursor-not-allowed [&[data-disabled]]:opacity-50"

    # the box — fills amber with a ✓ when checked and a – when indeterminate (the indicator carries
    # its own data-checked / data-indeterminate state)
    part :indicator,
         "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-amber-200 [&_[data-part=indicator]]:bg-amber-50 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:font-bold [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-amber-50 dark:[&_[data-part=indicator]]:border-amber-900 dark:[&_[data-part=indicator]]:bg-amber-950/30 dark:[&_[data-part=indicator]]:text-amber-950 [&_[data-part=indicator][data-checked]]:border-amber-500 [&_[data-part=indicator][data-checked]]:bg-amber-500 dark:[&_[data-part=indicator][data-checked]]:border-amber-400 dark:[&_[data-part=indicator][data-checked]]:bg-amber-400 [&_[data-part=indicator][data-checked]]:after:content-['✓'] [&_[data-part=indicator][data-indeterminate]]:border-amber-500 [&_[data-part=indicator][data-indeterminate]]:bg-amber-500 dark:[&_[data-part=indicator][data-indeterminate]]:border-amber-400 dark:[&_[data-part=indicator][data-indeterminate]]:bg-amber-400 [&_[data-part=indicator][data-indeterminate]]:after:content-['–']"

    part :label,
         "[&_[data-part=label]]:text-sm [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-50"
  end

  customize :my_checkbox_group do
    from :checkbox_group

    part :root,
         "flex flex-col gap-0.5 rounded-xl border border-amber-200 bg-amber-50 p-3 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30"

    part :label,
         "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-semibold [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-50"

    # each item is a clickable row; the select_all parent is set apart with a divider
    part :item,
         "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-900 dark:[&_[data-part=item]]:text-amber-100 [&_[data-part=item]:hover]:bg-amber-100/60 dark:[&_[data-part=item]:hover]:bg-amber-900/30 [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-50 [&_[data-part=item][data-parent]]:mb-1 [&_[data-part=item][data-parent]]:border-b [&_[data-part=item][data-parent]]:border-amber-200/70 dark:[&_[data-part=item][data-parent]]:border-amber-900/40 [&_[data-part=item][data-parent]]:pb-1.5 [&_[data-part=item][data-parent]]:font-medium"

    # the box — fills amber with a ✓ when checked and a – when indeterminate (the parent's mixed state)
    part :indicator,
         "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:shrink-0 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-amber-200 [&_[data-part=indicator]]:bg-amber-50 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:font-bold [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-amber-50 dark:[&_[data-part=indicator]]:border-amber-900 dark:[&_[data-part=indicator]]:bg-amber-950/30 dark:[&_[data-part=indicator]]:text-amber-950 [&_[data-part=indicator][data-checked]]:border-amber-500 [&_[data-part=indicator][data-checked]]:bg-amber-500 dark:[&_[data-part=indicator][data-checked]]:border-amber-400 dark:[&_[data-part=indicator][data-checked]]:bg-amber-400 [&_[data-part=indicator][data-checked]]:after:content-['✓'] [&_[data-part=indicator][data-indeterminate]]:border-amber-500 [&_[data-part=indicator][data-indeterminate]]:bg-amber-500 dark:[&_[data-part=indicator][data-indeterminate]]:border-amber-400 dark:[&_[data-part=indicator][data-indeterminate]]:bg-amber-400 [&_[data-part=indicator][data-indeterminate]]:after:content-['–']"
  end

  customize :my_combobox do
    from :combobox
    part :root, "relative inline-block"

    part :input,
         "[&_[data-part=input]]:w-full [&_[data-part=input]]:rounded-lg [&_[data-part=input]]:border [&_[data-part=input]]:border-amber-200 [&_[data-part=input]]:bg-amber-50 [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-2 [&_[data-part=input]]:text-sm [&_[data-part=input]]:text-amber-950 [&_[data-part=input]]:placeholder:text-amber-700/60 [&_[data-part=input]]:outline-none [&_[data-part=input]]:focus:border-amber-500 [&_[data-part=input]]:focus:ring-2 [&_[data-part=input]]:focus:ring-amber-500/30 dark:[&_[data-part=input]]:border-amber-900 dark:[&_[data-part=input]]:bg-amber-950/30 dark:[&_[data-part=input]]:text-amber-50 dark:[&_[data-part=input]]:placeholder:text-amber-300/50 dark:[&_[data-part=input]]:focus:border-amber-400 dark:[&_[data-part=input]]:focus:ring-amber-400/30"

    part :popup,
         "[&_[data-part=popup]]:mt-1.5 [&_[data-part=popup]]:w-full [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/30"

    part :item,
         "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-950 dark:[&_[data-part=item]]:text-amber-50 [&_[data-part=item][data-highlighted]]:bg-amber-100 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/40 [&_[data-part=item][aria-selected=true]]:font-semibold [&_[data-part=item][aria-selected=true]]:text-amber-700 dark:[&_[data-part=item][aria-selected=true]]:text-amber-300 [&_[data-part=item][data-hidden]]:hidden"
  end

  customize :my_context_menu do
    from :context_menu
    part :root, "relative"

    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:h-32 [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:select-none [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-center [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-dashed [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:text-amber-700 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-300"

    part :popup,
         "[&_[data-part=popup]]:hidden [&_[data-part=popup][data-open]]:block [&_[data-part=popup]]:z-50 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/95"

    part :item,
         "[&_[data-part=item]]:block [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-left [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-950 dark:[&_[data-part=item]]:text-amber-50 [&_[data-part=item][data-highlighted]]:bg-amber-100 [&_[data-part=item][data-highlighted]]:text-amber-950 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/40 dark:[&_[data-part=item][data-highlighted]]:text-amber-50 [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-50"
  end

  customize :my_dialog do
    from :dialog

    part :root,
         "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3.5 [&_[data-part=trigger]]:py-2 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40"

    part :backdrop,
         "[&_[data-part=backdrop]]:bg-amber-950/40 [&_[data-part=backdrop]]:backdrop-blur-sm dark:[&_[data-part=backdrop]]:bg-amber-950/60"

    part :popup,
         "[&_[data-part=popup]]:w-80 [&_[data-part=popup]]:rounded-2xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/95"

    part :title,
         "[&_[data-part=title]]:text-base [&_[data-part=title]]:font-semibold [&_[data-part=title]]:text-amber-950 dark:[&_[data-part=title]]:text-amber-50"

    part :description,
         "[&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-amber-700 dark:[&_[data-part=description]]:text-amber-300"

    part :content,
         "[&_[data-part=content]]:mt-3 [&_[data-part=content]]:text-sm [&_[data-part=content]]:text-amber-900/80 dark:[&_[data-part=content]]:text-amber-100/80"

    part :footer,
         "[&_[data-part=footer]]:mt-5 [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end [&_[data-part=footer]]:gap-2 [&_[data-part=footer]>button]:rounded-lg [&_[data-part=footer]>button]:px-3.5 [&_[data-part=footer]>button]:py-2 [&_[data-part=footer]>button]:text-sm [&_[data-part=footer]>button]:font-medium [&_[data-part=footer]>button:first-child]:border [&_[data-part=footer]>button:first-child]:border-amber-200 [&_[data-part=footer]>button:first-child]:bg-amber-50 [&_[data-part=footer]>button:first-child]:text-amber-950 [&_[data-part=footer]>button:first-child]:hover:bg-amber-100 [&_[data-part=footer]>button:last-child]:bg-amber-500 [&_[data-part=footer]>button:last-child]:text-amber-50 [&_[data-part=footer]>button:last-child]:hover:bg-amber-600 dark:[&_[data-part=footer]>button:first-child]:border-amber-900 dark:[&_[data-part=footer]>button:first-child]:bg-amber-950/30 dark:[&_[data-part=footer]>button:first-child]:text-amber-50 dark:[&_[data-part=footer]>button:first-child]:hover:bg-amber-900/40 dark:[&_[data-part=footer]>button:last-child]:bg-amber-400 dark:[&_[data-part=footer]>button:last-child]:text-amber-950 dark:[&_[data-part=footer]>button:last-child]:hover:bg-amber-300"
  end

  customize :my_drawer do
    from :drawer
    part :root, "inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40"

    part :backdrop,
         "[&_[data-part=backdrop]]:fixed [&_[data-part=backdrop]]:inset-0 [&_[data-part=backdrop]]:z-40 [&_[data-part=backdrop]]:bg-amber-950/40 dark:[&_[data-part=backdrop]]:bg-amber-950/60 [&_[data-part=backdrop][data-closed]]:hidden"

    part :popup,
         "[&_[data-part=popup]]:fixed [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-0 [&_[data-part=popup]]:z-50 [&_[data-part=popup]]:flex [&_[data-part=popup]]:h-full [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:flex-col [&_[data-part=popup]]:gap-3 [&_[data-part=popup]]:overflow-y-auto [&_[data-part=popup]]:border-l [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=popup]]:outline-none dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/95 [&_[data-part=popup][data-closed]]:hidden"

    part :title,
         "[&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=title]]:text-amber-950 dark:[&_[data-part=title]]:text-amber-50"

    part :description,
         "[&_[data-part=description]]:text-sm [&_[data-part=description]]:text-amber-700 dark:[&_[data-part=description]]:text-amber-300"

    part :content,
         "[&_[data-part=content]]:flex-1 [&_[data-part=content]]:text-sm [&_[data-part=content]]:text-amber-900/80 dark:[&_[data-part=content]]:text-amber-100/80"

    part :footer,
         "[&_[data-part=footer]]:mt-auto [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end [&_[data-part=footer]]:gap-2 [&_[data-part=footer]]:border-t [&_[data-part=footer]]:border-amber-200 [&_[data-part=footer]]:pt-3 dark:[&_[data-part=footer]]:border-amber-900 [&_[data-part=footer]_button]:rounded-md [&_[data-part=footer]_button]:border [&_[data-part=footer]_button]:border-amber-200 [&_[data-part=footer]_button]:bg-amber-100 [&_[data-part=footer]_button]:px-3 [&_[data-part=footer]_button]:py-1.5 [&_[data-part=footer]_button]:text-sm [&_[data-part=footer]_button]:font-medium [&_[data-part=footer]_button]:text-amber-950 [&_[data-part=footer]_button]:hover:bg-amber-200 dark:[&_[data-part=footer]_button]:border-amber-900 dark:[&_[data-part=footer]_button]:bg-amber-900/40 dark:[&_[data-part=footer]_button]:text-amber-50 dark:[&_[data-part=footer]_button]:hover:bg-amber-900/60"
  end

  customize :my_field do
    from :field

    part :root,
         "rounded-2xl border border-amber-200 bg-amber-50 p-4 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30"

    part :label,
         "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-50"

    part :control,
         "[&_[data-part=control]]:mt-1 [&_[data-part=control]_input]:w-full [&_[data-part=control]_input]:rounded-lg [&_[data-part=control]_input]:border [&_[data-part=control]_input]:border-amber-200 [&_[data-part=control]_input]:bg-amber-100 [&_[data-part=control]_input]:px-3 [&_[data-part=control]_input]:py-1.5 [&_[data-part=control]_input]:text-sm [&_[data-part=control]_input]:text-amber-950 [&_[data-part=control]_input]:placeholder:text-amber-700/50 [&_[data-part=control]_input]:focus:border-amber-500 [&_[data-part=control]_input]:focus:outline-none dark:[&_[data-part=control]_input]:border-amber-900/50 dark:[&_[data-part=control]_input]:bg-amber-950/30 dark:[&_[data-part=control]_input]:text-amber-50 dark:[&_[data-part=control]_input]:placeholder:text-amber-300/40 dark:[&_[data-part=control]_input]:focus:border-amber-400"

    part :description,
         "[&_[data-part=description]]:mt-1.5 [&_[data-part=description]]:text-xs [&_[data-part=description]]:text-amber-700 dark:[&_[data-part=description]]:text-amber-300"

    part :error,
         "[&_[data-part=error]]:mt-1 [&_[data-part=error]]:text-xs [&_[data-part=error]]:font-medium [&_[data-part=error]]:text-amber-700 dark:[&_[data-part=error]]:text-amber-300"
  end

  customize :my_fieldset do
    from :fieldset

    part :root,
         "rounded-xl border border-amber-200 bg-amber-50 p-4 text-amber-950 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30 dark:text-amber-50"

    part :legend,
         "[&_[data-part=legend]]:px-1 [&_[data-part=legend]]:text-sm [&_[data-part=legend]]:font-semibold [&_[data-part=legend]]:text-amber-700 dark:[&_[data-part=legend]]:text-amber-300"
  end

  customize :my_menu do
    from :menu
    part :root, "relative inline-block text-left"

    part :trigger,
         "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-1.5 [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:shadow-sm [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900/50 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40 [&_[data-part=trigger][aria-expanded=true]]:bg-amber-100 [&_[data-part=trigger][aria-expanded=true]]:border-amber-300 dark:[&_[data-part=trigger][aria-expanded=true]]:bg-amber-900/40 dark:[&_[data-part=trigger][aria-expanded=true]]:border-amber-800"

    part :popup,
         "[&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup]]:shadow-amber-950/10 dark:[&_[data-part=popup]]:border-amber-900/50 dark:[&_[data-part=popup]]:bg-amber-950/95 dark:[&_[data-part=popup]]:shadow-black/40 [&_[data-part=popup][data-closed]]:hidden"

    part :item,
         "[&_[data-part=item]]:block [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded-lg [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-left [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-900 dark:[&_[data-part=item]]:text-amber-200 [&_[data-part=item][data-highlighted]]:bg-amber-100 [&_[data-part=item][data-highlighted]]:text-amber-950 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/50 dark:[&_[data-part=item][data-highlighted]]:text-amber-50 [&_[data-part=item][aria-haspopup=menu]]:flex [&_[data-part=item][aria-haspopup=menu]]:items-center [&_[data-part=item][aria-haspopup=menu]]:justify-between [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:text-amber-700/50 dark:[&_[data-part=item][data-disabled]]:text-amber-300/40 [&_[data-part=item][data-disabled]]:opacity-60"

    part :separator,
         "[&_[data-part=separator]]:my-1 [&_[data-part=separator]]:h-px [&_[data-part=separator]]:bg-amber-200 dark:[&_[data-part=separator]]:bg-amber-900/50"
  end

  customize :my_menubar do
    from :menubar

    part :root,
         "inline-flex gap-1 rounded-md border border-amber-200 bg-amber-50 p-1 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30 [&_[role=menuitem]]:block [&_[role=menuitem]]:w-full [&_[role=menuitem]]:cursor-pointer [&_[role=menuitem]]:rounded [&_[role=menuitem]]:px-3 [&_[role=menuitem]]:py-1.5 [&_[role=menuitem]]:text-left [&_[role=menuitem]]:text-sm [&_[role=menuitem]]:text-amber-950 dark:[&_[role=menuitem]]:text-amber-50 [&_[role=menuitem]:hover]:bg-amber-100 dark:[&_[role=menuitem]:hover]:bg-amber-900/40 [&_[data-highlighted]]:bg-amber-100 [&_[data-highlighted]]:text-amber-950 dark:[&_[data-highlighted]]:bg-amber-900/40 dark:[&_[data-highlighted]]:text-amber-50"

    part :trigger,
         "[&_[data-part=trigger]]:cursor-pointer [&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger]:hover]:bg-amber-100 dark:[&_[data-part=trigger]:hover]:bg-amber-900/40 [&_[data-part=trigger][aria-expanded=true]]:bg-amber-100 [&_[data-part=trigger][aria-expanded=true]]:text-amber-950 dark:[&_[data-part=trigger][aria-expanded=true]]:bg-amber-900/50 dark:[&_[data-part=trigger][aria-expanded=true]]:text-amber-50"

    part :popup,
         "[&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900/50 dark:[&_[data-part=popup]]:bg-amber-950 [&_[data-part=popup][data-closed]]:hidden"
  end

  customize :my_navigation_menu do
    from :navigation_menu

    part :root,
         "flex gap-1 rounded-xl border border-amber-200 bg-amber-50 p-1 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30"

    part :link,
         "[&_[data-part=link]]:block [&_[data-part=link]]:rounded-lg [&_[data-part=link]]:px-3 [&_[data-part=link]]:py-1.5 [&_[data-part=link]]:text-sm [&_[data-part=link]]:font-medium [&_[data-part=link]]:text-amber-950 dark:[&_[data-part=link]]:text-amber-50 [&_[data-part=link]]:hover:bg-amber-100 dark:[&_[data-part=link]]:hover:bg-amber-900/40"

    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-1 [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40 [&_[data-part=trigger][aria-expanded=true]]:bg-amber-100 dark:[&_[data-part=trigger][aria-expanded=true]]:bg-amber-900/50"

    part :popup,
         "[&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:min-w-48 [&_[data-part=popup]]:rounded-xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-2 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900/50 dark:[&_[data-part=popup]]:bg-amber-950 [&_[data-part=popup][data-closed]]:hidden [&_[data-part=popup]_a]:block [&_[data-part=popup]_a]:rounded-lg [&_[data-part=popup]_a]:px-3 [&_[data-part=popup]_a]:py-1.5 [&_[data-part=popup]_a]:text-sm [&_[data-part=popup]_a]:text-amber-700 dark:[&_[data-part=popup]_a]:text-amber-300 [&_[data-part=popup]_a]:hover:bg-amber-100 dark:[&_[data-part=popup]_a]:hover:bg-amber-900/40 [&_[data-part=popup]_a]:hover:text-amber-950 dark:[&_[data-part=popup]_a]:hover:text-amber-50"
  end

  customize :my_number_field do
    from :number_field

    part :root,
         "inline-flex items-center overflow-hidden rounded-lg border border-amber-200 bg-amber-50 shadow-sm dark:border-amber-900 dark:bg-amber-950/30"

    part :decrement,
         "[&_[data-part=decrement]]:px-3 [&_[data-part=decrement]]:py-1.5 [&_[data-part=decrement]]:text-lg [&_[data-part=decrement]]:leading-none [&_[data-part=decrement]]:text-amber-700 [&_[data-part=decrement]]:hover:bg-amber-100 [&_[data-part=decrement]]:active:bg-amber-200 dark:[&_[data-part=decrement]]:text-amber-300 dark:[&_[data-part=decrement]]:hover:bg-amber-900/40 dark:[&_[data-part=decrement]]:active:bg-amber-900/60"

    part :input,
         "[&_[data-part=input]]:w-16 [&_[data-part=input]]:border-x [&_[data-part=input]]:border-amber-200 [&_[data-part=input]]:bg-amber-100 [&_[data-part=input]]:px-2 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:text-center [&_[data-part=input]]:tabular-nums [&_[data-part=input]]:text-amber-950 [&_[data-part=input]]:[appearance:textfield] [&_[data-part=input]::-webkit-inner-spin-button]:appearance-none [&_[data-part=input]::-webkit-outer-spin-button]:appearance-none [&_[data-part=input]]:focus:outline-none dark:[&_[data-part=input]]:border-amber-900 dark:[&_[data-part=input]]:bg-amber-950/40 dark:[&_[data-part=input]]:text-amber-50"

    part :increment,
         "[&_[data-part=increment]]:px-3 [&_[data-part=increment]]:py-1.5 [&_[data-part=increment]]:text-lg [&_[data-part=increment]]:leading-none [&_[data-part=increment]]:text-amber-700 [&_[data-part=increment]]:hover:bg-amber-100 [&_[data-part=increment]]:active:bg-amber-200 dark:[&_[data-part=increment]]:text-amber-300 dark:[&_[data-part=increment]]:hover:bg-amber-900/40 dark:[&_[data-part=increment]]:active:bg-amber-900/60"
  end

  customize :my_otp_field do
    from :otp_field
    part :root, "flex gap-2"

    part :input,
         "[&_[data-part=input]]:size-11 [&_[data-part=input]]:rounded-lg [&_[data-part=input]]:border [&_[data-part=input]]:border-amber-200 [&_[data-part=input]]:bg-amber-50 [&_[data-part=input]]:text-center [&_[data-part=input]]:text-lg [&_[data-part=input]]:font-semibold [&_[data-part=input]]:text-amber-950 [&_[data-part=input]]:caret-amber-500 [&_[data-part=input]]:outline-none [&_[data-part=input]]:transition-colors [&_[data-part=input]]:focus:border-amber-500 [&_[data-part=input]]:focus:bg-amber-100 [&_[data-part=input]]:focus:ring-2 [&_[data-part=input]]:focus:ring-amber-500/30 dark:[&_[data-part=input]]:border-amber-900 dark:[&_[data-part=input]]:bg-amber-950/30 dark:[&_[data-part=input]]:text-amber-50 dark:[&_[data-part=input]]:caret-amber-400 dark:[&_[data-part=input]]:focus:border-amber-400 dark:[&_[data-part=input]]:focus:bg-amber-900/40 dark:[&_[data-part=input]]:focus:ring-amber-400/30"
  end

  customize :my_popover do
    from :popover
    part :root, "inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-2 [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40 [&_[data-part=trigger][aria-expanded=true]]:border-amber-500 [&_[data-part=trigger][aria-expanded=true]]:bg-amber-100 dark:[&_[data-part=trigger][aria-expanded=true]]:border-amber-400 dark:[&_[data-part=trigger][aria-expanded=true]]:bg-amber-900/50"

    part :popup,
         "[&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:w-64 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:text-amber-950 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/30 dark:[&_[data-part=popup]]:text-amber-50 [&_[data-part=popup][data-closed]]:hidden"
  end

  customize :my_preview_card do
    from :preview_card
    part :root, "relative inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:cursor-pointer [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:underline-offset-4 [&_[data-part=trigger]]:decoration-amber-500 [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:decoration-amber-400 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger][aria-expanded=true]]:decoration-solid [&_[data-part=trigger][aria-expanded=true]]:text-amber-700 dark:[&_[data-part=trigger][aria-expanded=true]]:text-amber-300"

    part :popup,
         "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:z-50 [&_[data-part=popup]]:mb-2 [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:text-sm [&_[data-part=popup]]:text-amber-900 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/30 dark:[&_[data-part=popup]]:text-amber-300 [&_[data-part=popup][data-closed]]:hidden [&_[data-part=popup][data-open]]:block"
  end

  customize :my_progress do
    from :progress

    # label on the left, value on the right, the track spans both columns below (like my_meter)
    part :root, "grid w-full grid-cols-2 items-center gap-y-1.5"

    part :label,
         "[&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-100"

    part :value,
         "[&_[data-part=value]]:text-right [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-amber-700 dark:[&_[data-part=value]]:text-amber-300"

    part :track,
         "[&_[data-part=track]]:col-span-2 [&_[data-part=track]]:h-2.5 [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-amber-100 dark:[&_[data-part=track]]:bg-amber-950/40"

    # fill scales via the --chelekom-progress ratio; deepens on complete; a partial pulsing bar when indeterminate
    part :indicator,
         "[&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:w-full [&_[data-part=indicator]]:origin-left [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-amber-500 dark:[&_[data-part=indicator]]:bg-amber-400 [&_[data-part=indicator]]:transition-transform [&_[data-part=indicator]]:[transform:scaleX(var(--chelekom-progress,0))] [&_[data-part=indicator][data-complete]]:bg-amber-600 dark:[&_[data-part=indicator][data-complete]]:bg-amber-300 [&_[data-part=indicator][data-indeterminate]]:w-1/3 [&_[data-part=indicator][data-indeterminate]]:[transform:none] [&_[data-part=indicator][data-indeterminate]]:animate-pulse"
  end

  customize :my_radio do
    from :radio

    part :root,
         "inline-flex w-full max-w-md cursor-pointer items-center gap-3 rounded-xl border border-amber-200 bg-amber-50 px-3.5 py-2.5 text-amber-950 has-[:checked]:border-amber-500 has-[:checked]:bg-amber-100 data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50 dark:border-amber-900/50 dark:bg-amber-950/30 dark:text-amber-50 dark:has-[:checked]:border-amber-400 dark:has-[:checked]:bg-amber-950/60"

    part :input, "[&_[data-part=input]]:peer [&_[data-part=input]]:sr-only"

    part :indicator,
         "[&_[data-part=indicator]]:relative [&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:shrink-0 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:border-2 [&_[data-part=indicator]]:border-amber-300 [&_[data-part=indicator]]:bg-amber-50 dark:[&_[data-part=indicator]]:border-amber-700 dark:[&_[data-part=indicator]]:bg-amber-950/40 [&_[data-part=indicator]]:after:size-2.5 [&_[data-part=indicator]]:after:rounded-full [&_[data-part=indicator]]:after:bg-amber-500 dark:[&_[data-part=indicator]]:after:bg-amber-400 [&_[data-part=indicator]]:after:scale-0 [&_[data-part=indicator]]:after:transition-transform [&_[data-part=indicator]]:after:content-[''] [&_[data-part=input]:checked~[data-part=indicator]]:border-amber-500 dark:[&_[data-part=input]:checked~[data-part=indicator]]:border-amber-400 [&_[data-part=input]:checked~[data-part=indicator]]:after:scale-100 [&_[data-part=input]:focus-visible~[data-part=indicator]]:ring-2 [&_[data-part=input]:focus-visible~[data-part=indicator]]:ring-amber-500/40 dark:[&_[data-part=input]:focus-visible~[data-part=indicator]]:ring-amber-400/40"

    part :label,
         "[&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-100"
  end

  customize :my_radio_group do
    from :radio_group
    part :root, "flex flex-col gap-2 w-full"

    part :item,
         "[&_[data-part=item]]:flex [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-lg [&_[data-part=item]]:border [&_[data-part=item]]:border-amber-200 [&_[data-part=item]]:bg-amber-50 [&_[data-part=item]]:px-3.5 [&_[data-part=item]]:py-2.5 [&_[data-part=item]]:text-left [&_[data-part=item]]:text-sm [&_[data-part=item]]:font-medium [&_[data-part=item]]:text-amber-950 dark:[&_[data-part=item]]:border-amber-900 dark:[&_[data-part=item]]:bg-amber-950/30 dark:[&_[data-part=item]]:text-amber-50 [&_[data-part=item]]:hover:bg-amber-100 dark:[&_[data-part=item]]:hover:bg-amber-900/30 [&_[data-part=item][data-highlighted]]:outline-none [&_[data-part=item][data-highlighted]]:ring-2 [&_[data-part=item][data-highlighted]]:ring-amber-500 dark:[&_[data-part=item][data-highlighted]]:ring-amber-400 [&_[data-part=item][aria-checked=true]]:border-amber-500 [&_[data-part=item][aria-checked=true]]:bg-amber-100 [&_[data-part=item][aria-checked=true]]:font-semibold [&_[data-part=item][aria-checked=true]]:text-amber-950 dark:[&_[data-part=item][aria-checked=true]]:border-amber-400 dark:[&_[data-part=item][aria-checked=true]]:bg-amber-900/40 dark:[&_[data-part=item][aria-checked=true]]:text-amber-50 [&_[data-part=item]]:before:flex [&_[data-part=item]]:before:h-4 [&_[data-part=item]]:before:w-4 [&_[data-part=item]]:before:shrink-0 [&_[data-part=item]]:before:rounded-full [&_[data-part=item]]:before:border-2 [&_[data-part=item]]:before:border-amber-300 [&_[data-part=item]]:before:bg-amber-50 [&_[data-part=item]]:before:content-[''] dark:[&_[data-part=item]]:before:border-amber-700 dark:[&_[data-part=item]]:before:bg-amber-950/30 [&_[data-part=item][aria-checked=true]]:before:border-amber-500 [&_[data-part=item][aria-checked=true]]:before:bg-amber-500 [&_[data-part=item][aria-checked=true]]:before:shadow-[inset_0_0_0_3px_theme(colors.amber.50)] dark:[&_[data-part=item][aria-checked=true]]:before:border-amber-400 dark:[&_[data-part=item][aria-checked=true]]:before:bg-amber-400 dark:[&_[data-part=item][aria-checked=true]]:before:shadow-[inset_0_0_0_3px_theme(colors.amber.950)]"
  end

  customize :my_scroll_area do
    from :scroll_area

    part :root,
         "h-48 w-72 rounded-xl border border-amber-200 bg-amber-50 shadow-sm overflow-hidden dark:border-amber-900/50 dark:bg-amber-950/30"

    part :viewport,
         "[&_[data-part=viewport]]:h-full [&_[data-part=viewport]]:overflow-auto [&_[data-part=viewport]]:p-3 [&_[data-part=viewport]]:text-amber-950 dark:[&_[data-part=viewport]]:text-amber-100 [&_[data-part=viewport]]:focus:outline-none [&_[data-part=viewport]]:focus-visible:ring-2 [&_[data-part=viewport]]:focus-visible:ring-amber-500 dark:[&_[data-part=viewport]]:focus-visible:ring-amber-400 [&_[data-part=viewport]]:focus-visible:ring-inset"
  end

  customize :my_select do
    from :select
    part :root, "relative inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:min-w-44 [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-2 [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-2 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40 [&_[data-part=trigger][aria-expanded=true]]:border-amber-500 [&_[data-part=trigger][aria-expanded=true]]:bg-amber-100 dark:[&_[data-part=trigger][aria-expanded=true]]:border-amber-400 dark:[&_[data-part=trigger][aria-expanded=true]]:bg-amber-900/40"

    part :value,
         "[&_[data-part=value]]:truncate [&_[data-part=value]]:text-amber-950 dark:[&_[data-part=value]]:text-amber-50"

    part :icon,
         "[&_[data-part=icon]]:shrink-0 [&_[data-part=icon]]:text-amber-500 [&_[data-part=icon]]:transition-transform dark:[&_[data-part=icon]]:text-amber-400 [&_[data-part=trigger][aria-expanded=true]_[data-part=icon]]:rotate-180"

    part :positioner, "[&_[data-part=positioner]]:z-50"

    part :popup,
         "[&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:overflow-hidden [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 [&_[data-part=popup]]:bg-amber-50 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg dark:[&_[data-part=popup]]:border-amber-900 dark:[&_[data-part=popup]]:bg-amber-950/95 [&_[data-part=popup][data-closed]]:hidden"

    part :item,
         "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-md [&_[data-part=item]]:px-2.5 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-amber-900 dark:[&_[data-part=item]]:text-amber-100 [&_[data-part=item][data-highlighted]]:bg-amber-100 [&_[data-part=item][data-highlighted]]:text-amber-950 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/50 dark:[&_[data-part=item][data-highlighted]]:text-amber-50 [&_[data-part=item][aria-selected=true]]:font-semibold [&_[data-part=item][aria-selected=true]]:text-amber-950 dark:[&_[data-part=item][aria-selected=true]]:text-amber-50"

    part :item_indicator,
         "[&_[data-part=item-indicator]]:w-4 [&_[data-part=item-indicator]]:shrink-0 [&_[data-part=item-indicator]]:text-center [&_[data-part=item-indicator]]:text-amber-500 [&_[data-part=item-indicator]]:opacity-0 dark:[&_[data-part=item-indicator]]:text-amber-400 [&_[data-part=item][aria-selected=true]_[data-part=item-indicator]]:opacity-100"

    part :item_text, "[&_[data-part=item-text]]:flex-1 [&_[data-part=item-text]]:truncate"
  end

  customize :my_separator do
    from :separator

    part :root,
         "flex w-full items-center gap-3 text-xs font-medium uppercase tracking-wide text-amber-700 before:h-px before:flex-1 before:rounded-full before:bg-amber-200 after:h-px after:flex-1 after:rounded-full after:bg-amber-200 dark:text-amber-300 dark:before:bg-amber-900 dark:after:bg-amber-900 data-[orientation=vertical]:h-full data-[orientation=vertical]:w-auto data-[orientation=vertical]:flex-col data-[orientation=vertical]:before:h-auto data-[orientation=vertical]:before:w-px data-[orientation=vertical]:after:h-auto data-[orientation=vertical]:after:w-px"

    part :label,
         "[&_[data-part=label]]:shrink-0 [&_[data-part=label]]:rounded-full [&_[data-part=label]]:bg-amber-50 [&_[data-part=label]]:px-2 [&_[data-part=label]]:py-0.5 [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:bg-amber-950/30 dark:[&_[data-part=label]]:text-amber-50"
  end

  customize :my_slider do
    from :slider
    part :root, "relative flex w-full items-center gap-3"

    part :value,
         "[&_[data-part=value]]:ml-auto [&_[data-part=value]]:shrink-0 [&_[data-part=value]]:text-sm [&_[data-part=value]]:font-medium [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-amber-700 dark:[&_[data-part=value]]:text-amber-300"

    part :track,
         "[&_[data-part=track]]:relative [&_[data-part=track]]:h-2 [&_[data-part=track]]:w-full [&_[data-part=track]]:grow [&_[data-part=track]]:overflow-visible [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-amber-100 dark:[&_[data-part=track]]:bg-amber-950/40"

    part :range,
         "[&_[data-part=range]]:absolute [&_[data-part=range]]:inset-y-0 [&_[data-part=range]]:left-0 [&_[data-part=range]]:rounded-full [&_[data-part=range]]:bg-amber-500 dark:[&_[data-part=range]]:bg-amber-400"

    part :thumb,
         "[&_[data-part=thumb]]:absolute [&_[data-part=thumb]]:top-1/2 [&_[data-part=thumb]]:h-4 [&_[data-part=thumb]]:w-4 [&_[data-part=thumb]]:-translate-x-1/2 [&_[data-part=thumb]]:-translate-y-1/2 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border [&_[data-part=thumb]]:border-amber-200 [&_[data-part=thumb]]:bg-amber-50 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:cursor-grab dark:[&_[data-part=thumb]]:border-amber-900 dark:[&_[data-part=thumb]]:bg-amber-950/30 [&_[data-part=thumb]]:focus:outline-none [&_[data-part=thumb]]:focus:ring-2 [&_[data-part=thumb]]:focus:ring-amber-500 dark:[&_[data-part=thumb]]:focus:ring-amber-400"
  end

  customize :my_switch do
    from :switch

    part :root,
         "inline-flex items-center gap-3 relative h-6 w-11 rounded-full transition-colors border border-amber-200 dark:border-amber-900 [&[data-checked=true]]:bg-amber-500 dark:[&[data-checked=true]]:bg-amber-400 [&[data-unchecked=true]]:bg-amber-100 dark:[&[data-unchecked=true]]:bg-amber-950/30"

    part :thumb,
         "[&_[data-part=thumb]]:absolute [&_[data-part=thumb]]:left-0 [&_[data-part=thumb]]:top-1/2 [&_[data-part=thumb]]:-translate-y-1/2 [&_[data-part=thumb]]:translate-x-0.5 [&_[data-part=thumb]]:inline-block [&_[data-part=thumb]]:h-5 [&_[data-part=thumb]]:w-5 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-amber-50 dark:[&_[data-part=thumb]]:bg-amber-50 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:transition-transform [&[data-checked=true]_[data-part=thumb]]:translate-x-[1.375rem]"

    part :label,
         "[&_[data-part=label]]:absolute [&_[data-part=label]]:left-[3.25rem] [&_[data-part=label]]:top-1/2 [&_[data-part=label]]:-translate-y-1/2 [&_[data-part=label]]:whitespace-nowrap [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=label]]:text-amber-950 dark:[&_[data-part=label]]:text-amber-50"

    part :input, "[&_[data-part=input]]:sr-only"
  end

  customize :my_tabs do
    from :tabs
    part :root, "flex flex-col"

    part :tablist,
         "[&_[data-part=tablist]]:flex [&_[data-part=tablist]]:gap-1 [&_[data-part=tablist]]:border-b [&_[data-part=tablist]]:border-amber-200 dark:[&_[data-part=tablist]]:border-amber-900"

    part :item,
         "[&_[data-part=item]]:-mb-px [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:border-b-2 [&_[data-part=item]]:border-transparent [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:font-medium [&_[data-part=item]]:text-amber-700 dark:[&_[data-part=item]]:text-amber-300 [&_[data-part=item]]:hover:text-amber-950 dark:[&_[data-part=item]]:hover:text-amber-50 [&_[data-part=item][aria-selected=true]]:border-amber-500 dark:[&_[data-part=item][aria-selected=true]]:border-amber-400 [&_[data-part=item][aria-selected=true]]:font-semibold [&_[data-part=item][aria-selected=true]]:text-amber-950 dark:[&_[data-part=item][aria-selected=true]]:text-amber-50 [&_[data-part=item]:focus-visible]:outline-none [&_[data-part=item]:focus-visible]:ring-2 [&_[data-part=item]:focus-visible]:ring-amber-400"

    part :panel,
         "[&_[data-part=panel]]:rounded-b-lg [&_[data-part=panel]]:bg-amber-50 dark:[&_[data-part=panel]]:bg-amber-950/30 [&_[data-part=panel]]:p-3 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:text-amber-900 dark:[&_[data-part=panel]]:text-amber-100/80 [&_[data-part=panel]:focus-visible]:outline-none [&_[data-part=panel][data-closed=true]]:hidden"
  end

  customize :my_toast do
    from :toast

    part :root, "relative w-full max-w-sm space-y-3"

    part :trigger,
         "[&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-amber-200 [&_[data-part=trigger]]:bg-amber-50 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 [&_[data-part=trigger]]:hover:bg-amber-100 dark:[&_[data-part=trigger]]:border-amber-900 dark:[&_[data-part=trigger]]:bg-amber-950/30 dark:[&_[data-part=trigger]]:text-amber-50 dark:[&_[data-part=trigger]]:hover:bg-amber-900/40"

    part :viewport,
         "[&_[data-part=viewport]]:relative [&_[data-part=viewport]]:h-60 [&_[data-part=viewport]]:w-full [&_[data-part=viewport]]:overflow-hidden [&_[data-part=viewport]]:[list-style:none] [&_[data-part=viewport]]:[padding:0] [&_[data-part=viewport]]:[margin:0]"

    # the stacking math (Base UI parity) + warm amber surface; older toasts peek behind, fan out on hover
    part :toast,
         "[&_[data-part=toast]]:[--gap:0.6rem] [&_[data-part=toast]]:[--peek:0.6rem] [&_[data-part=toast]]:[--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [&_[data-part=toast]]:[--shrink:calc(1-var(--scale))] [&_[data-part=toast]]:[--height:var(--toast-frontmost-height,var(--toast-height))] [&_[data-part=toast]]:[--offset-y:calc(var(--toast-offset-y)*-1+(var(--toast-index)*var(--gap)*-1)+var(--toast-swipe-movement-y))] [&_[data-part=toast]]:absolute [&_[data-part=toast]]:inset-x-0 [&_[data-part=toast]]:bottom-0 [&_[data-part=toast]]:origin-bottom [&_[data-part=toast]]:z-[calc(1000-var(--toast-index))] [&_[data-part=toast]]:h-[var(--height)] [&_[data-part=toast]]:rounded-lg [&_[data-part=toast]]:border [&_[data-part=toast]]:border-amber-200 [&_[data-part=toast]]:bg-amber-50 [&_[data-part=toast]]:text-amber-950 [&_[data-part=toast]]:shadow-lg [&_[data-part=toast]]:shadow-amber-900/10 dark:[&_[data-part=toast]]:border-amber-900 dark:[&_[data-part=toast]]:bg-amber-950/40 dark:[&_[data-part=toast]]:text-amber-50 dark:[&_[data-part=toast]]:shadow-black/40 [&_[data-part=toast]]:[transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.4s,height_0.15s] [&_[data-part=toast]]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)-(var(--toast-index)*var(--peek))-(var(--shrink)*var(--height))))_scale(var(--scale))] [&_[data-part=toast][data-expanded]]:[transform:translateY(var(--offset-y))] [&_[data-part=toast][data-expanded]]:h-[var(--toast-height)] [&_[data-part=toast][data-starting-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-ending-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-expanded][data-starting-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-expanded][data-ending-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-ending-style]]:opacity-0 [&_[data-part=toast][data-limited]]:opacity-0"

    part :content,
         "[&_[data-part=content]]:flex [&_[data-part=content]]:h-full [&_[data-part=content]]:items-start [&_[data-part=content]]:gap-3 [&_[data-part=content]]:overflow-hidden [&_[data-part=content]]:p-3 [&_[data-part=content]]:text-sm [&_[data-part=content]]:transition-opacity [&_[data-part=content][data-behind]]:opacity-0"

    part :close,
         "[&_[data-part=close]]:ml-auto [&_[data-part=close]]:shrink-0 [&_[data-part=close]]:px-1.5 [&_[data-part=close]]:text-lg [&_[data-part=close]]:leading-none [&_[data-part=close]]:text-amber-500 [&_[data-part=close]]:hover:text-amber-700 dark:[&_[data-part=close]]:text-amber-400 dark:[&_[data-part=close]]:hover:text-amber-200"
  end

  customize :my_toggle do
    from :toggle

    part :root,
         "inline-flex items-center gap-2 rounded-md border border-amber-200 bg-amber-50 px-3 py-1.5 text-sm font-medium text-amber-950 hover:bg-amber-100 dark:border-amber-900 dark:bg-amber-950/30 dark:text-amber-50 dark:hover:bg-amber-900/30 data-[on]:border-amber-500 data-[on]:bg-amber-500 data-[on]:text-white dark:data-[on]:border-amber-400 dark:data-[on]:bg-amber-400 dark:data-[on]:text-amber-950"
  end

  customize :my_toggle_group do
    from :toggle_group

    part :root,
         "inline-flex gap-1 rounded-xl border border-amber-200 bg-amber-50 p-1 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30"

    part :item,
         "[&_[data-part=item]]:rounded-lg [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:font-medium [&_[data-part=item]]:transition-colors [&_[data-part=item][data-off]]:text-amber-700 dark:[&_[data-part=item][data-off]]:text-amber-300 [&_[data-part=item][data-off]]:hover:bg-amber-100 dark:[&_[data-part=item][data-off]]:hover:bg-amber-900/30 [&_[data-part=item][data-on]]:bg-amber-500 [&_[data-part=item][data-on]]:text-amber-50 dark:[&_[data-part=item][data-on]]:bg-amber-400 dark:[&_[data-part=item][data-on]]:text-amber-950 [&_[data-part=item][data-highlighted]]:outline [&_[data-part=item][data-highlighted]]:outline-2 [&_[data-part=item][data-highlighted]]:outline-amber-500 dark:[&_[data-part=item][data-highlighted]]:outline-amber-400 [&_[data-part=item][data-disabled]]:opacity-40 [&_[data-part=item][data-disabled]]:cursor-not-allowed"
  end

  customize :my_toolbar do
    from :toolbar

    part :root,
         "inline-flex gap-1 rounded-xl border border-amber-200 bg-amber-50 p-1 shadow-sm dark:border-amber-900/50 dark:bg-amber-950/30"

    part :item,
         "[&_[data-part=item]]:rounded-lg [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:font-medium [&_[data-part=item]]:text-amber-950 dark:[&_[data-part=item]]:text-amber-100 [&_[data-part=item]:hover]:bg-amber-100 dark:[&_[data-part=item]:hover]:bg-amber-900/40 [&_[data-part=item][data-highlighted]]:bg-amber-100 dark:[&_[data-part=item][data-highlighted]]:bg-amber-900/40 [&_[data-part=item]:focus]:outline [&_[data-part=item]:focus]:outline-2 [&_[data-part=item]:focus]:outline-offset-2 [&_[data-part=item]:focus]:outline-amber-500 dark:[&_[data-part=item]:focus]:outline-amber-400 [&_[data-part=item][data-disabled]]:opacity-40 [&_[data-part=item][data-disabled]]:pointer-events-none"
  end

  customize :my_tooltip do
    from :tooltip
    part :root, "relative inline-block"

    part :trigger,
         "[&_[data-part=trigger]]:cursor-help [&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:decoration-amber-500 dark:[&_[data-part=trigger]]:decoration-amber-400 [&_[data-part=trigger]]:underline-offset-4 [&_[data-part=trigger]]:rounded-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:text-amber-950 dark:[&_[data-part=trigger]]:text-amber-50 [&_[data-part=trigger]]:focus-visible:outline-none [&_[data-part=trigger]]:focus-visible:ring-2 [&_[data-part=trigger]]:focus-visible:ring-amber-500 dark:[&_[data-part=trigger]]:focus-visible:ring-amber-400"

    part :popup,
         "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:z-50 [&_[data-part=popup][data-closed]]:hidden [&_[data-part=popup][data-open]]:block [&_[data-part=popup]]:mb-1 [&_[data-part=popup]]:max-w-48 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-amber-200 dark:[&_[data-part=popup]]:border-amber-900 [&_[data-part=popup]]:bg-amber-50 dark:[&_[data-part=popup]]:bg-amber-950/30 [&_[data-part=popup]]:px-2 [&_[data-part=popup]]:py-1 [&_[data-part=popup]]:text-xs [&_[data-part=popup]]:text-amber-950 dark:[&_[data-part=popup]]:text-amber-50 [&_[data-part=popup]]:shadow-lg"
  end
end
