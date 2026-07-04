defmodule Mishka.InstallTest do
  @moduledoc """
  `mix mishka_chelekom.install` — the top-level installer, which composes the batch styled
  generator with `--import --helpers --global`.
  """
  use ExUnit.Case, async: false
  import MishkaCliHelper
  alias Mix.Tasks.MishkaChelekom.Install, as: Task

  @moduletag :mishka_cli

  setup do
    Application.ensure_all_started(:owl)
    :ok
  end

  describe "behaviour" do
    test "composes the styled generator (stages components + the import macro)" do
      igniter = stage(Task, [])
      assert staged?(igniter, styled_path("accordion"))
      assert staged?(igniter, "#{components_dir()}/mishka_components.ex")
      assert igniter.issues == []
    end
  end

  describe "CLI contract" do
    test "belongs to the mishka_chelekom group and takes no positionals" do
      info = Task.info([], nil)
      assert info.group == :mishka_chelekom
      assert info.positional == []
    end
  end
end
