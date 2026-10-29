defmodule MishkaChelekom.HeadlessEditorToolbarTest do
  @moduledoc """
  The TipTap engine marks the active toolbar buttons after every transaction.

  A mark toggled at a collapsed cursor (Bold with nothing selected) only sets the stored marks: the
  transaction changes neither the document nor the selection, so `onUpdate` and `onSelectionUpdate`
  never fire for it, and a toolbar repainted only from those showed `data-active` one keystroke late.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.{Assets, Core}

  # The source of the engine the editor installs by default, found the way the generator finds it.
  defp engine_source do
    {:ok, %{config: config}} = Core.fetch_catalog(Igniter.new(), "editor", :headless)
    [script] = Assets.scripts(config, Assets.resolve_lib(config))

    File.read!(Core.lib_priv("assets/js/#{script.file}"))
  end

  defp function_body(source, name) do
    [_, rest] = String.split(source, "\n  #{name}() {", parts: 2)
    [body, _] = String.split(rest, "\n  },", parts: 2)
    body
  end

  test "repaints the toolbar on every transaction" do
    assert engine_source() =~ "onTransaction: () => this.render()"
  end

  test "repaints once per keystroke: schedule() leaves it to the transaction" do
    refute engine_source() |> function_body("schedule") =~ "this.render()"
  end

  test "no longer repaints from selection updates alone" do
    refute engine_source() =~ "onSelectionUpdate"
  end
end
