defmodule Mishka.McpSetupTest do
  @moduledoc """
  `mix mishka.mcp.setup` — covers the default (HTTP) setup, `--stdio`, `--path`, `--dev-only`.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Mcp.Setup, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  # mishka.mcp.setup rewrites shared config (config/config.exs, config/test.exs, …), so it is
  # exercised through non-destructive staging rather than a real disk mutation.
  describe "options" do
    test "default (HTTP) setup stages config and notices without issues" do
      igniter = stage(Task, [])
      assert igniter.issues == []
      assert igniter.notices != []
    end

    test "--stdio runs cleanly" do
      igniter = stage(Task, ["--stdio"])
      assert match?(%Igniter{}, igniter)
      assert igniter.issues == []
    end

    test "--path accepts a custom endpoint path" do
      igniter = stage(Task, ["--path", "/custom/mcp"])
      assert match?(%Igniter{}, igniter)
    end

    test "--dev-only runs cleanly" do
      igniter = stage(Task, ["--dev-only"])
      assert match?(%Igniter{}, igniter)
    end
  end

  describe "CLI contract" do
    test "exposes the documented schema" do
      info = Task.info([], nil)
      assert info.positional == []

      for opt <- [:path, :dev_only, :yes, :stdio] do
        assert Keyword.has_key?(info.schema, opt), "schema should expose --#{opt}"
      end
    end
  end
end
