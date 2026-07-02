defmodule MishkaChelekom.MCP.Resources.ListHeadlessComponentsTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.Resources.ListHeadlessComponents
  alias MishkaChelekom.Generators.Core
  alias Anubis.Server.Frame

  # The real set of headless components the library ships, read straight from disk.
  defp headless_names do
    Core.template_dir(:headless)
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".exs"))
    |> Enum.sort()
  end

  describe "component metadata" do
    test "name/uri/mime_type identify the resource" do
      assert ListHeadlessComponents.name() == "list_headless_components"
      assert ListHeadlessComponents.uri() == "mishka_chelekom://headless"
      assert ListHeadlessComponents.mime_type() == "text/plain"
    end
  end

  describe "read/2" do
    test "returns the headless summary as text" do
      {:reply, response, _frame} = ListHeadlessComponents.read(%{}, %Frame{})

      assert response.contents["text"] =~ "Headless components"
      # read/2 is just the transport wrapper around summary/0
      assert response.contents["text"] == ListHeadlessComponents.summary()
    end
  end

  describe "summary/0" do
    test "lists every headless component on disk and the header count matches" do
      names = headless_names()
      summary = ListHeadlessComponents.summary()

      assert names != [], "expected priv/headless/*.exs to exist"

      # the header count must equal what was actually loaded and rendered
      [_, count_str] = Regex.run(~r/Headless components \((\d+)\)/, summary)
      assert String.to_integer(count_str) == length(names)

      # and each real component must have its own rendered section
      Enum.each(names, fn name ->
        assert summary =~ "## #{name}", "summary should include a section for #{name}"
      end)
    end

    test "documents each component's ARIA pattern, hooks, parts and docs" do
      summary = ListHeadlessComponents.summary()

      assert summary =~ "Pattern:"
      assert summary =~ "JS hooks:"
      assert summary =~ "Parts:"
      assert summary =~ "Docs:"
    end
  end
end
