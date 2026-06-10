defmodule MishkaChelekom.Kit do
  @moduledoc """
  One Spark DSL to **reuse and customize** your Mishka Chelekom components — never to build HTML
  from scratch. The styled and headless components stay normal components; the Kit is an additive,
  opt-in layer on top.

      defmodule MyAppWeb.Kit do
        use MishkaChelekom.Kit

        # customize a STYLED component — add/replace its colors, variants, sizes
        customize :button do
          color :primary, "bg-indigo-600 text-white"        # replace (name exists)
          color :brand,   "bg-brand-500 text-white"          # add (new name)
          variant :glow,  "shadow-[0_0_20px_currentColor]"
          default color: :brand
        end

        # customize a HEADLESS component — style its parts (under a new name)
        customize :confirm_dialog do
          from :dialog
          part :popup, "rounded-2xl bg-base-100 p-6 shadow-2xl"
          part :title, "text-lg font-semibold"
        end
      end

  The macro picks styled vs headless from the **rules you write** (`color`/`variant`/… vs `part`),
  generating a thin wrapper (`<.button>`, `<.confirm_dialog>`) that delegates to the real component
  — its file is never touched. See `MishkaChelekom.Kit.Dsl`; introspect with
  `MishkaChelekom.Kit.Info`; feed `safelist/1` to Tailwind so runtime classes survive purge.
  """
  use Spark.Dsl, default_extensions: [extensions: [MishkaChelekom.Kit.Dsl]]

  alias MishkaChelekom.Kit.{Info, Rule, Runtime}

  @doc """
  Every Tailwind class a Kit introduces at runtime — styled `customize` classes (plain **and** their
  `!important` form) and headless `part` `[&_[data-part=…]]:` variants. The wrapper builds these at
  runtime, so Tailwind's scanner can't see them; feed this to Tailwind, e.g. in `app.css`:
  `@source inline("<the joined list>");`.
  """
  def safelist(kit) do
    kit
    |> Info.customizes()
    |> Enum.flat_map(fn c ->
      {dims, parts} = Enum.split_with(c.rules, &match?(%Rule{}, &1))

      dim_classes =
        Enum.flat_map(
          dims,
          &(String.split(&1.classes) ++ String.split(Runtime.important(&1.classes)))
        )

      part_classes =
        Enum.flat_map(parts, fn p ->
          prefix = "[&_[data-part=#{p.name}]]:"
          Enum.map(String.split(p.classes), &(prefix <> &1))
        end)

      dim_classes ++ part_classes
    end)
    |> Enum.uniq()
  end
end

defmodule MishkaChelekom.Kit.Info do
  @moduledoc "Introspection for `MishkaChelekom.Kit` modules."
  use Spark.InfoGenerator, extension: MishkaChelekom.Kit.Dsl, sections: [:ui]

  @doc "All `customize :x` entries."
  def customizes(module), do: ui(module)
end
