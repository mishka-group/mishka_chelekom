defmodule MishkaChelekom.CmsBundle.Icons do
  @moduledoc """
  The icon set this kit's components name, shipped IN the bundle.

  ## Why the bundle carries the glyphs

  A Chelekom `icon` attribute's value is a class — `hero-bell` — and the picture behind it comes from
  the Tailwind heroicons plugin reading `deps/heroicons`. That works for anyone building this kit
  from source and for nobody else: a CMS installing the bundle has no `deps/heroicons`, no plugin,
  and therefore no way to draw the glyph in a picker or to emit the mask rule for a class its own
  pages have not rendered yet. Its only options were to guess, or to require the consumer to take a
  dependency this bundle never mentions.

  So the export reads the SVGs once, here, and writes them into the bundle. The consumer then has
  everything it needs from the one file it already downloaded.

  ## Cost

  1,288 glyphs across the four weights, ~0.72 MB of JSON against a bundle that is already ~11 MB — a
  6.6% increase for the difference between an icon picker that works and one that cannot exist. The
  SVGs are the `optimized/` ones heroicons ships, not the source files.

  ## Read at EXPORT time, not compile time

  The opposite of the consumer's constraint, and for the same reason. `deps/` exists when this task
  runs (it runs in a checkout) and does not exist in a release — so the export is exactly the moment
  to turn a build-time artefact into shipped data.

  ## Shape

      "icons": {
        "prefix": "hero-",
        "label": "Heroicons",
        "variants": [["", "Outline"], ["-solid", "Solid"], ["-mini", "Mini"], ["-micro", "Micro"]],
        "glyphs": {"hero-bell": "<svg …>…</svg>"}
      }

  `variants` is a list of pairs rather than an object because the ORDER is meaningful — outline first,
  because it is the default weight — and JSON objects do not promise one.
  """

  require Logger

  # The heroicons plugin's own table, mirrored: suffix, source directory, and the label a picker shows.
  @variants [
    {"", "24/outline", "Outline"},
    {"-solid", "24/solid", "Solid"},
    {"-mini", "20/solid", "Mini"},
    {"-micro", "16/solid", "Micro"}
  ]

  @candidates ["deps/heroicons/optimized", "../../deps/heroicons/optimized"]

  @doc """
  The `icons` block for the bundle, or `nil` when the icon set is not on disk.

  `nil` rather than an empty block: a bundle that ships no glyphs and a bundle that ships zero glyphs
  say different things to a consumer, and only the first is honest about a set it could not read.
  """
  @spec block(Path.t() | nil) :: map() | nil
  def block(root \\ nil) do
    case root || Enum.find(@candidates, &File.dir?/1) do
      nil ->
        Logger.warning("[CmsBundle.Icons] no heroicons directory found; bundle ships no glyphs")
        nil

      dir ->
        build(dir)
    end
  end

  defp build(dir) do
    glyphs =
      for {suffix, source, _label} <- @variants,
          path <- Path.wildcard(Path.join([dir, source, "*.svg"])),
          into: %{} do
        {"hero-" <> Path.basename(path, ".svg") <> suffix, path |> File.read!() |> String.trim()}
      end

    case map_size(glyphs) do
      0 ->
        Logger.warning("[CmsBundle.Icons] heroicons directory #{dir} held no SVGs")
        nil

      count ->
        Logger.info("[CmsBundle.Icons] shipping #{count} glyphs")

        %{
          "prefix" => "hero-",
          "label" => "Heroicons",
          "variants" => for({suffix, _source, label} <- @variants, do: [suffix, label]),
          "glyphs" => glyphs
        }
    end
  end
end
