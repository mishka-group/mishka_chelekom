defmodule Mishka.ExportTest do
  @moduledoc """
  `mix mishka.ui.export <dir>` — exports component/template/bundle artifacts. Covered here:
  `--template`, `--name`, `--org`, and the missing-directory guard.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Export, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "mix mishka.ui.export --template writes a JSON scaffold to disk, then removes it" do
      out = "priv/#{String.downcase(uniq_prefix("exp"))}.json"
      on_exit(fn -> rm_generated(out) end)

      name = Path.basename(out, ".json")
      refute File.exists?(out)
      mix!("mishka.ui.export", ["priv", "--template", "--name", name, "--yes"])
      assert File.exists?(out), "expected #{out} to be exported to disk"
    end
  end

  describe "options" do
    test "--template stages a JSON scaffold named by --name" do
      igniter = stage(Task, ["priv", "--template", "--name", "probe_bundle"])
      assert staged?(igniter, "priv/probe_bundle.json")
    end

    test "--org is accepted" do
      igniter = stage(Task, ["priv", "--template", "--name", "probe_bundle", "--org", "acme"])
      assert match?(%Igniter{}, igniter)
    end
  end

  describe "guards" do
    test "surfaces an issue when there is nothing to export" do
      igniter = stage(Task, ["nonexistent_dir_xyz"])
      assert igniter.issues != []
    end
  end

  describe "CLI contract" do
    test "exposes the dir positional, schema and aliases" do
      info = Task.info([], nil)
      assert info.positional == [:dir]

      for opt <- [:base64, :template, :name, :org, :test, :cms, :bundle_name, :bundle_version] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end

      assert info.aliases[:t] == :template
      assert info.aliases[:n] == :name
    end
  end
end
