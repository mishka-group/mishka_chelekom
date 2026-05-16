defmodule Mix.Tasks.Mishka.Mcp.SetupTest do
  use ExUnit.Case, async: true

  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Mcp.Setup

  @moduletag :igniter

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()

    on_exit(fn ->
      MishkaChelekom.ComponentTestHelper.cleanup_config()
    end)

    :ok
  end

  describe "info/2" do
    test "returns correct task info" do
      info = Setup.info([], nil)

      assert %Igniter.Mix.Task.Info{} = info
      assert {:anubis, "~> 0.2"} in info.adds_deps
      assert :path in Keyword.keys(info.schema)
      assert :dev_only in Keyword.keys(info.schema)
      assert :yes in Keyword.keys(info.schema)
    end

    test "has correct default values" do
      info = Setup.info([], nil)

      assert Keyword.get(info.defaults, :path) == "/mcp"
      assert Keyword.get(info.defaults, :dev_only) == true
    end

    test "has correct aliases" do
      info = Setup.info([], nil)

      assert Keyword.get(info.aliases, :p) == :path
    end
  end

  describe "igniter/1" do
    test "adds MCP route to router" do
      igniter =
        test_project_with_formatter(
          app_name: :test_app,
          files: %{
            "lib/test_app_web.ex" => """
            defmodule TestAppWeb do
              def router do
                quote do
                  use Phoenix.Router
                end
              end
            end
            """,
            "lib/test_app_web/router.ex" => """
            defmodule TestAppWeb.Router do
              use Phoenix.Router

              pipeline :browser do
                plug :accepts, ["html"]
              end

              scope "/", TestAppWeb do
                pipe_through :browser
                get "/", PageController, :home
              end
            end
            """
          }
        )
        |> Igniter.compose_task(Setup, ["--yes"])

      # Check that router has MCP route with MishkaChelekom.MCP.Server directly
      sources = igniter.rewrite.sources

      router_path =
        Enum.find(Map.keys(sources), fn path ->
          String.contains?(path, "router.ex")
        end)

      if router_path do
        source = Map.get(sources, router_path)
        content = Rewrite.Source.get(source, :content)

        assert content =~ "forward"
        assert content =~ "/mcp"
        assert content =~ "MishkaChelekom.MCP.Server"
      end
    end

    test "adds notice with connection instructions" do
      igniter =
        test_project_with_formatter(
          app_name: :test_app,
          files: %{
            "lib/test_app_web.ex" => """
            defmodule TestAppWeb do
              def router do
                quote do
                  use Phoenix.Router
                end
              end
            end
            """,
            "lib/test_app_web/router.ex" => """
            defmodule TestAppWeb.Router do
              use Phoenix.Router

              pipeline :browser do
                plug :accepts, ["html"]
              end

              scope "/", TestAppWeb do
                pipe_through :browser
                get "/", PageController, :home
              end
            end
            """
          }
        )
        |> Igniter.compose_task(Setup, ["--yes"])

      # Check notices contain setup instructions
      notices = igniter.notices
      notice_text = Enum.join(notices, "\n")

      assert notice_text =~ "MCP Server setup complete"
      assert notice_text =~ "claude mcp add"
      assert notice_text =~ "mishka-chelekom"
    end

    test "uses custom path when provided" do
      igniter =
        test_project_with_formatter(
          app_name: :test_app,
          files: %{
            "lib/test_app_web.ex" => """
            defmodule TestAppWeb do
              def router do
                quote do
                  use Phoenix.Router
                end
              end
            end
            """,
            "lib/test_app_web/router.ex" => """
            defmodule TestAppWeb.Router do
              use Phoenix.Router

              pipeline :browser do
                plug :accepts, ["html"]
              end

              scope "/", TestAppWeb do
                pipe_through :browser
                get "/", PageController, :home
              end
            end
            """
          }
        )
        |> Igniter.compose_task(Setup, ["--path", "/api/mcp", "--yes"])

      # Check notices use the custom path
      notices = igniter.notices
      notice_text = Enum.join(notices, "\n")

      assert notice_text =~ "/api/mcp"
    end
  end

  describe "edge cases" do
    test "raises error when router is missing" do
      # The setup task requires a router to be present
      assert_raise RuntimeError, ~r/Could not find module.*Router/, fn ->
        test_project_with_formatter(
          app_name: :test_app,
          files: %{
            "lib/test_app_web.ex" => """
            defmodule TestAppWeb do
            end
            """
          }
        )
        |> Igniter.compose_task(Setup, ["--yes"])
      end
    end
  end

  describe "info/2 — stdio flag" do
    test "exposes --stdio in schema with -s alias" do
      info = Setup.info([], nil)

      assert :stdio in Keyword.keys(info.schema)
      assert Keyword.get(info.aliases, :s) == :stdio
      assert Keyword.get(info.defaults, :stdio) == false
    end
  end

  describe "fresh_mcp_json/0 (pure)" do
    test "produces valid JSON with the mishka-chelekom stdio entry" do
      json = Setup.fresh_mcp_json()
      decoded = Jason.decode!(json)

      entry = get_in(decoded, ["mcpServers", "mishka-chelekom"])
      assert entry["type"] == "stdio"
      assert entry["command"] == "mix"
      assert entry["args"] == ["mishka.mcp.server", "--transport", "stdio"]
      assert entry["env"] == %{"MIX_QUIET" => "1"}
    end

    test "ends with a trailing newline" do
      assert String.ends_with?(Setup.fresh_mcp_json(), "\n")
    end
  end

  describe "merge_stdio_entry/1 (pure)" do
    test "treats invalid JSON as no-existing-file (overwrites)" do
      result = Setup.merge_stdio_entry("not json {")
      decoded = Jason.decode!(result)
      assert Map.keys(decoded["mcpServers"]) == ["mishka-chelekom"]
    end

    test "preserves other mcpServers entries" do
      existing =
        Jason.encode!(%{
          "mcpServers" => %{
            "other" => %{"type" => "http", "url" => "http://x"}
          }
        })

      result = Setup.merge_stdio_entry(existing)
      decoded = Jason.decode!(result)

      assert Map.has_key?(decoded["mcpServers"], "other")
      assert Map.has_key?(decoded["mcpServers"], "mishka-chelekom")
      assert decoded["mcpServers"]["other"]["url"] == "http://x"
    end

    test "preserves top-level keys outside of mcpServers" do
      existing = Jason.encode!(%{"mcpServers" => %{}, "custom" => "preserve me"})

      result = Setup.merge_stdio_entry(existing)
      decoded = Jason.decode!(result)

      assert decoded["custom"] == "preserve me"
      assert Map.has_key?(decoded["mcpServers"], "mishka-chelekom")
    end

    test "replaces an existing mishka-chelekom entry (idempotent)" do
      existing =
        Jason.encode!(%{
          "mcpServers" => %{
            "mishka-chelekom" => %{"type" => "http", "url" => "http://old"}
          }
        })

      result = Setup.merge_stdio_entry(existing)
      decoded = Jason.decode!(result)

      entry = decoded["mcpServers"]["mishka-chelekom"]
      assert entry["type"] == "stdio"
      refute Map.has_key?(entry, "url")
    end

    test "merging an already-stdio entry yields identical result on second run" do
      first = Setup.merge_stdio_entry(~s({"mcpServers":{}}))
      second = Setup.merge_stdio_entry(first)
      assert Jason.decode!(first) == Jason.decode!(second)
    end

    test "treats a JSON object without mcpServers as base" do
      existing = Jason.encode!(%{"somethingElse" => true})

      result = Setup.merge_stdio_entry(existing)
      decoded = Jason.decode!(result)

      assert decoded["somethingElse"] == true
      assert Map.has_key?(decoded["mcpServers"], "mishka-chelekom")
    end
  end

  describe "igniter/1 — --stdio flag" do
    test "creates .mcp.json with the stdio entry when none exists" do
      igniter =
        test_project_with_formatter(app_name: :test_app, files: %{})
        |> Igniter.compose_task(Setup, ["--stdio", "--yes"])

      source = Map.fetch!(igniter.rewrite.sources, ".mcp.json")
      content = Rewrite.Source.get(source, :content)
      decoded = Jason.decode!(content)

      entry = decoded["mcpServers"]["mishka-chelekom"]
      assert entry["type"] == "stdio"
      assert entry["command"] == "mix"
      assert entry["env"] == %{"MIX_QUIET" => "1"}
    end

    test "merges into an existing .mcp.json without touching other servers" do
      existing =
        Jason.encode!(%{
          "mcpServers" => %{
            "other-server" => %{"type" => "http", "url" => "http://keep.me"}
          }
        }) <> "\n"

      igniter =
        test_project_with_formatter(
          app_name: :test_app,
          files: %{".mcp.json" => existing}
        )
        |> Igniter.compose_task(Setup, ["--stdio", "--yes"])

      content =
        igniter.rewrite.sources
        |> Map.fetch!(".mcp.json")
        |> Rewrite.Source.get(:content)

      decoded = Jason.decode!(content)
      assert decoded["mcpServers"]["other-server"]["url"] == "http://keep.me"
      assert decoded["mcpServers"]["mishka-chelekom"]["type"] == "stdio"
    end

    test "does NOT add a Phoenix route when --stdio is set" do
      # Even with a router file present, --stdio skips router patching.
      igniter =
        test_project_with_formatter(
          app_name: :test_app,
          files: %{
            "lib/test_app_web.ex" => """
            defmodule TestAppWeb do
              def router do
                quote do
                  use Phoenix.Router
                end
              end
            end
            """,
            "lib/test_app_web/router.ex" => """
            defmodule TestAppWeb.Router do
              use Phoenix.Router

              scope "/", TestAppWeb do
              end
            end
            """
          }
        )
        |> Igniter.compose_task(Setup, ["--stdio", "--yes"])

      router_path =
        igniter.rewrite.sources
        |> Map.keys()
        |> Enum.find(&String.contains?(&1, "router.ex"))

      if router_path do
        source = Map.get(igniter.rewrite.sources, router_path)
        content = Rewrite.Source.get(source, :content)
        refute content =~ "Anubis.Server.Transport.StreamableHTTP.Plug"
        refute content =~ ~r/forward\s+"\/mcp"/
      end
    end

    test "stdio notice mentions .mcp.json and MIX_QUIET" do
      igniter =
        test_project_with_formatter(app_name: :test_app, files: %{})
        |> Igniter.compose_task(Setup, ["--stdio", "--yes"])

      notice_text = Enum.join(igniter.notices, "\n")
      assert notice_text =~ "Stdio MCP setup complete"
      assert notice_text =~ ".mcp.json"
      assert notice_text =~ "MIX_QUIET"
    end
  end
end
