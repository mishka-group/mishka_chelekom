defmodule MishkaChelekom.CmsBundle.Location do
  @moduledoc """
  Where to find an exported bundle, for the three things in this project that read one.

  `mix mishka.ui.export <dir> --cms --name <kit>` writes to `<dir>/<kit>.json` and takes no output
  path, so exporting `priv/components` leaves an 11 MB file there. That file is a BUILD ARTIFACT: it
  is rewritten by every export and by the export suite, it is excluded from the Hex package, and the
  copy that ships is `priv/cms_ui_kits/<kit>.json`.

  Two copies of the same bundle in one repository is one copy too many, and the fresh export is the
  one that must not be committed — an 11 MB rewrite per run buries every real diff, and the two files
  drift apart the moment a suite run re-stamps one of them with a different version string. So it is
  ignored by git, and the readers come here instead of naming a path that may not exist.

  ## Which one you get

  The fresh export when there is one, the published copy otherwise. That order is deliberate: a kit
  author who has just exported is checking their own changes and must see them, while a clone that
  has never run an export still has a bundle to read rather than a `File.read!/1` raising in test
  setup.

  Both answers are the same bundle in every respect but the version string it was stamped with.
  """

  @kits_dir "cms_ui_kits"

  @export_dir "components"

  @doc """
  The readable bundle for `kit`, or `nil` when neither copy is there.

  `nil` rather than a raise, because the caller decides: the showcase site degrades to an empty
  metadata map, and a test says which file it wanted.
  """
  @spec bundle(String.t()) :: String.t() | nil
  def bundle(kit \\ "chelekom"), do: Enum.find(candidates(kit), &File.regular?/1)

  @doc """
  Both places a bundle for `kit` may be, in the order `bundle/1` prefers them.

  Public so a failure message can list what was looked for instead of naming one path and leaving the
  reader to guess at the other.
  """
  @spec candidates(String.t()) :: [String.t()]
  def candidates(kit \\ "chelekom") do
    for dir <- [@export_dir, @kits_dir],
        do: Path.join([:code.priv_dir(:mishka_chelekom), dir, "#{kit}.json"])
  end

  @doc """
  The bundle for `kit`, raising with both candidate paths when there is none.

  For a test or a task that cannot proceed without one.
  """
  @spec bundle!(String.t()) :: String.t()
  def bundle!(kit \\ "chelekom") do
    bundle(kit) ||
      raise """
      no #{kit} bundle found. Looked in:

        #{Enum.join(candidates(kit), "\n        ")}

      Run: mix mishka.ui.export priv/components --cms --name #{kit} --bundle-name #{kit}
      """
  end
end
