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
end
