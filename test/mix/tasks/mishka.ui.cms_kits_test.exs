defmodule Mix.Tasks.Mishka.Ui.CmsKitsTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  @moduletag :igniter

  defp kit_versions(igniter) do
    for file <- ["chelekom.json", "chelekom_headless.json"] do
      key = Path.join("priv/cms_ui_kits", file)
      assert %Rewrite.Source{} = source = igniter.rewrite.sources[key]
      source |> Rewrite.Source.get(:content) |> Jason.decode!() |> Map.fetch!("version")
    end
  end

  defp run(args) do
    test_project_with_formatter()
    |> Igniter.compose_task("mishka.ui.cms_kits", args)
  end

  test "writes both kits at the project version" do
    version = Mix.Project.config()[:version]
    assert kit_versions(run([])) == [version, version]
  end

  test "--bundle-version overrides the version" do
    assert kit_versions(run(["--bundle-version", "9.9.9"])) == ["9.9.9", "9.9.9"]
  end
end
