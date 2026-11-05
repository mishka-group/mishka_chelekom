defmodule Mix.Tasks.Mishka.Ui.CmsKits do
  @shortdoc "Exports both Chelekom CMS kits into priv/cms_ui_kits"

  @moduledoc """
  Exports Chelekom's two CMS kits into `priv/cms_ui_kits`, in one Igniter run.

  The styled bundle (`priv/components`, named `chelekom`) and the headless bundle
  (`priv/headless`, named `chelekom_headless`) are written with `mix mishka.ui.export --cms`, both
  at one version, so you review one diff and confirm once. Maintainers run it from Chelekom's own
  repository; `mix cms.kits` is its shortcut alias.

  ```bash
  mix mishka.ui.cms_kits
  mix cms.kits --bundle-version 0.0.9
  ```

  ## Options

  * `--bundle-version` - Sets the version of both bundles (defaults to the project's version).
  """

  use Igniter.Mix.Task

  @output "priv/cms_ui_kits"
  @kits [{"priv/components", "chelekom"}, {"priv/headless", "chelekom_headless"}]

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      group: :mishka_chelekom,
      example: "mix mishka.ui.cms_kits --bundle-version 0.0.9",
      composes: ["mishka.ui.export"],
      schema: [bundle_version: :string]
    }
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    version = Keyword.get(igniter.args.options, :bundle_version, Mix.Project.config()[:version])

    Enum.reduce(@kits, igniter, fn {dir, name}, igniter ->
      Igniter.compose_task(igniter, "mishka.ui.export", argv(dir, name, version))
    end)
  end

  defp argv(dir, name, version) do
    [
      dir,
      "--cms",
      "--name",
      name,
      "--bundle-name",
      name,
      "--bundle-version",
      version,
      "--output",
      @output
    ]
  end
end
