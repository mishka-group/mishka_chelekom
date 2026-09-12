defmodule Mishka.AssetsDepsTest do
  @moduledoc """
  `mix mishka.assets.deps <deps>` — installs JS asset dependencies into `assets/package.json`.

  `--test` only suppresses the banner and the spinner; it does *not* stop the task from shelling
  out. The staged cases below stay offline because `stage/2` never runs the queued task, but the
  end-to-end case really does invoke the package manager — so it has to put every lockfile back.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Assets.Deps, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "mix mishka.assets.deps --test runs end-to-end against assets/package.json" do
      # This case really installs, so every artifact the run can touch has to be restored — which
      # lockfile appears depends on which package manager the machine has. Missing `bun.lock` here
      # leaked a stray `accordion` pin into the committed lockfile after every full test run.
      snaps =
        Enum.map(
          ~w(assets/package.json assets/package-lock.json assets/bun.lock assets/yarn.lock),
          &snapshot/1
        )

      on_exit(fn -> Enum.each(snaps, &restore/1) end)

      mix!("mishka.assets.deps", ["accordion", "--test", "--yes"])
      assert File.exists?("assets/package.json")
    end
  end

  describe "options" do
    test "stages assets/package.json for the requested dep" do
      igniter = stage(Task, ["accordion", "--test"])
      assert staged?(igniter, "assets/package.json")
    end

    for mgr <- ~w(--npm --yarn --bun --mix_bun) do
      test "#{mgr} package manager selection runs cleanly" do
        igniter = stage(Task, ["accordion", unquote(mgr), "--test"])
        assert staged?(igniter, "assets/package.json")
      end
    end

    test "--dev installs as a dev dependency" do
      igniter = stage(Task, ["accordion", "--dev", "--test"])
      assert match?(%Igniter{}, igniter)
    end

    test "--remove runs cleanly" do
      igniter = stage(Task, ["accordion", "--remove", "--test"])
      assert match?(%Igniter{}, igniter)
    end
  end

  describe "CLI contract" do
    test "exposes the deps positional and the documented schema" do
      info = Task.info([], nil)
      assert info.positional == [:deps]

      for opt <- [:bun, :npm, :yarn, :mix_bun, :test, :dev, :remove] do
        assert Keyword.get(info.schema, opt) == :boolean, "schema should expose --#{opt}"
      end
    end
  end
end
