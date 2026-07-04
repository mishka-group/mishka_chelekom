defmodule Mishka.AddTest do
  @moduledoc """
  `mix mishka.ui.add <repo>` — fetches a component from a GitHub repo / URL.

  Its happy path performs network I/O, so the deterministic, offline-safe coverage here is
  the CLI contract plus the graceful failure path for a bad target.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.Mishka.Ui.Add, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "CLI contract" do
    test "requires a repo positional and exposes --no-github / --headers" do
      info = Task.info([], nil)
      assert info.positional == [:repo]
      assert Keyword.get(info.schema, :no_github) == :boolean
      assert Keyword.has_key?(info.schema, :headers)
    end
  end

  describe "graceful failure" do
    test "a malformed target surfaces an issue instead of crashing" do
      igniter = stage(Task, ["this is not a valid repo", "--no-github"])
      assert match?(%Igniter{}, igniter)
      assert igniter.issues != []
    end
  end
end
