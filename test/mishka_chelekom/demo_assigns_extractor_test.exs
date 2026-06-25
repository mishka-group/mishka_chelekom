defmodule MishkaChelekom.DemoAssignsExtractorTest do
  @moduledoc """
  Covers `DemoAssignsExtractor` — the export-time harvester of a demo's `mount/3` assigns.

  Focus: it keeps serializable literals and SKIPS un-evaluable values (free variables, unsafe
  calls) WITHOUT letting `Code.eval_quoted` leak an "undefined variable" compiler diagnostic to
  stderr (the `nonce`/`session` noise seen during `mix mishka.ui.export`).
  """
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias MishkaChelekom.DemoAssignsExtractor

  defp mount(body) do
    """
    defmodule Demo do
      def mount(_p, session, socket) do
        #{body}
        {:ok, socket}
      end
    end
    """
  end

  describe "extract_from_source/1" do
    test "captures serializable literal assigns" do
      {assigns, _skipped} =
        DemoAssignsExtractor.extract_from_source(
          mount(~s|socket = assign(socket, posts: %{total: 10, active: 1}, title: "Hi")|)
        )

      assert assigns.posts == %{total: 10, active: 1}
      assert assigns.title == "Hi"
    end

    test "skips a free-variable value (csp_nonce: nonce) and records it as skipped" do
      source =
        mount("""
        nonce = Map.get(session, "style_csp_nonce")
        socket = assign(socket, count: 3, csp_nonce: nonce)
        """)

      {assigns, skipped} = DemoAssignsExtractor.extract_from_source(source)

      # the literal is kept; the free-variable assign is dropped
      assert assigns.count == 3
      refute Map.has_key?(assigns, :csp_nonce)
      assert {:csp_nonce, :unsafe_call} in skipped
    end

    test "does NOT leak an 'undefined variable' compiler diagnostic to stderr" do
      source =
        mount("""
        nonce = Map.get(session, "style_csp_nonce")
        socket = assign(socket, csp_nonce: nonce, seo: seo_tags())
        """)

      stderr =
        capture_io(:stderr, fn ->
          {_assigns, _skipped} = DemoAssignsExtractor.extract_from_source(source)
        end)

      refute stderr =~ "undefined variable"
      refute stderr =~ "nonce"
    end

    test "skips unsafe calls (route sigils, non-whitelisted modules, captures)" do
      {assigns, skipped} =
        DemoAssignsExtractor.extract_from_source(
          mount(~s|socket = assign(socket, ok: 1, path: ~p"/x", cb: &IO.puts/1)|)
        )

      assert assigns.ok == 1
      refute Map.has_key?(assigns, :path)
      refute Map.has_key?(assigns, :cb)
      assert Enum.any?(skipped, &match?({:path, _}, &1))
      assert Enum.any?(skipped, &match?({:cb, _}, &1))
    end
  end
end
