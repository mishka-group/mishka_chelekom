defmodule Mishka.CssConfigTest do
  @moduledoc """
  `mix mishka.ui.css.config` — covers `--init`, `--show`, `--validate`, `--regenerate`.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Css.Config, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "real end-to-end" do
    test "mix mishka.ui.css.config --init runs end-to-end and is a no-op when configured" do
      config = "priv/mishka_chelekom/config.exs"
      before = File.read(config)
      mix!("mishka.ui.css.config", ["--init"])
      assert File.read(config) == before
    end
  end

  describe "options" do
    test "--init reports what it did without raising an issue" do
      igniter = stage(Task, ["--init"])
      assert igniter.issues == []
      assert igniter.notices != []
    end

    for flag <- ~w(--show --validate --regenerate) do
      test "#{flag} runs cleanly" do
        igniter = stage(Task, [unquote(flag)])
        assert match?(%Igniter{}, igniter)
        assert igniter.issues == []
      end
    end
  end

  describe "CLI contract" do
    test "exposes the documented schema" do
      info = Task.info([], nil)
      assert info.positional == []

      for opt <- [:init, :force, :regenerate, :validate, :show] do
        assert Keyword.get(info.schema, opt) == :boolean, "schema should expose --#{opt}"
      end
    end
  end
end
