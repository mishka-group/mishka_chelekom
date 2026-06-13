defmodule MishkaChelekom.Kit do
  @moduledoc """
  One Spark DSL to **reuse and customize** your Mishka Chelekom components — never to build HTML
  from scratch. The styled and headless components stay normal components; the Kit is an additive,
  opt-in layer on top.

      defmodule MyAppWeb.Kit do
        use MishkaChelekom.Kit

        # customize a STYLED component — add/replace its colors, variants, sizes (classes verbatim,
        # write the trailing `!` yourself for precedence over the component's defaults)
        customize :button do
          color :primary, "bg-indigo-600! text-white!"       # replace (name exists)
          color :brand,   "bg-brand-500! text-white!"         # add (new name)
          variant :glow,  "shadow-[0_0_20px_currentColor]!"
          default color: :brand
        end

        # customize a HEADLESS component — style its parts (write the full [&_[data-part=…]]: variant)
        customize :confirm_dialog do
          from :dialog
          part :popup, "[&_[data-part=popup]]:rounded-2xl [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-6"
          part :title, "[&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold"
        end
      end

  The macro picks styled vs headless from the **rules you write** (`color`/`variant`/… vs `part`),
  generating a thin wrapper (`<.button>`, `<.confirm_dialog>`) that delegates to the real component
  — its file is never touched. See `MishkaChelekom.Kit.Dsl`; introspect with `MishkaChelekom.Kit.Info`.

  ## Tailwind — no safelist needed
  Classes are used **verbatim**: write them whole in your `customize` blocks — including a trailing
  `!` for precedence over the component's defaults (styled), and the full `[&_[data-part=…]]:` variant
  (headless). Because your Kit module lives in your app and the classes are literal strings in it,
  Tailwind's scanner picks them up straight from the file — no `safelist`, no `@source inline`.

      customize :button do
        color :brand, "bg-brand-500! text-white!"          # write the ! yourself
      end

      customize :confirm_dialog do
        from :dialog
        part :popup, "[&_[data-part=popup]]:rounded-2xl"   # write the full variant
      end
  """
  use Spark.Dsl, default_extensions: [extensions: [MishkaChelekom.Kit.Dsl]]
end
