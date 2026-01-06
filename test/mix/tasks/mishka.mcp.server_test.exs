defmodule Mix.Tasks.Mishka.Mcp.ServerTest do
  use ExUnit.Case, async: false

  @moduletag :mcp_server

  alias MishkaChelekom.MCP.Supervisor, as: MCPSupervisor

  describe "MCP Server" do
    setup do
      # Start required applications
      Application.ensure_all_started(:inets)
      Application.ensure_all_started(:plug_cowboy)

      # Use a random port to avoid conflicts
      port = Enum.random(5000..5999)

      on_exit(fn ->
        # Stop the supervisor if it's running
        try do
          case Process.whereis(MCPSupervisor) do
            nil -> :ok
            pid -> Supervisor.stop(pid, :normal, 1000)
          end
        catch
          :exit, _ -> :ok
        end
      end)

      {:ok, port: port}
    end

    test "supervisor starts successfully", %{port: port} do
      assert {:ok, pid} = MCPSupervisor.start_link(port: port)
      assert is_pid(pid)
      assert Process.alive?(pid)

      # Clean stop
      Supervisor.stop(pid, :normal, 1000)
    end

    test "HTTP server responds on root endpoint", %{port: port} do
      {:ok, pid} = MCPSupervisor.start_link(port: port)

      # Give the server time to start
      Process.sleep(100)

      # Test root endpoint
      {:ok, response} = :httpc.request(:get, {~c"http://localhost:#{port}/", []}, [], [])
      {{_, status_code, _}, _headers, body} = response

      assert status_code == 200
      assert body |> to_string() =~ "Mishka Chelekom MCP Server"
      assert body |> to_string() =~ "/mcp"

      Supervisor.stop(pid, :normal, 1000)
    end

    test "HTTP server returns 404 for unknown routes", %{port: port} do
      {:ok, pid} = MCPSupervisor.start_link(port: port)
      Process.sleep(100)

      {:ok, response} = :httpc.request(:get, {~c"http://localhost:#{port}/unknown", []}, [], [])
      {{_, status_code, _}, _headers, body} = response

      assert status_code == 404
      assert body |> to_string() =~ "Not found"

      Supervisor.stop(pid, :normal, 1000)
    end

    test "MCP endpoint accepts POST requests with correct headers", %{port: port} do
      {:ok, pid} = MCPSupervisor.start_link(port: port)
      Process.sleep(100)

      # Send an MCP initialize request with proper MCP headers
      body =
        Jason.encode!(%{
          jsonrpc: "2.0",
          method: "initialize",
          id: 1,
          params: %{
            protocolVersion: "2024-11-05",
            capabilities: %{},
            clientInfo: %{name: "test", version: "1.0"}
          }
        })

      request = {
        ~c"http://localhost:#{port}/mcp",
        [
          {~c"content-type", ~c"application/json"},
          {~c"accept", ~c"application/json, text/event-stream"}
        ],
        ~c"application/json",
        body
      }

      {:ok, response} = :httpc.request(:post, request, [], [])
      {{_, status_code, _}, _headers, _response_body} = response

      # MCP endpoint should respond with 200, 202, or 406 depending on protocol version
      assert status_code in [200, 202, 406]

      Supervisor.stop(pid, :normal, 1000)
    end

    test "MCP endpoint responds to requests", %{port: port} do
      {:ok, pid} = MCPSupervisor.start_link(port: port)
      Process.sleep(100)

      # Test that the endpoint exists and responds
      body = Jason.encode!(%{jsonrpc: "2.0", method: "ping", id: 1, params: %{}})

      request = {
        ~c"http://localhost:#{port}/mcp",
        [
          {~c"content-type", ~c"application/json"},
          {~c"accept", ~c"*/*"}
        ],
        ~c"application/json",
        body
      }

      {:ok, response} = :httpc.request(:post, request, [], [])
      {{_, status_code, _}, _headers, _response_body} = response

      # The endpoint should respond (not timeout or 500)
      assert status_code in [200, 202, 400, 406]

      Supervisor.stop(pid, :normal, 1000)
    end
  end

  describe "Server module" do
    test "server module defines expected components" do
      # Check that the server module has the expected tools and resources
      components = MishkaChelekom.MCP.Server.__components__()

      assert is_list(components)
      assert length(components) > 0
    end

    test "server module has tools" do
      tools = MishkaChelekom.MCP.Server.__components__(:tool)

      assert is_list(tools)
      assert length(tools) > 0

      # Check for expected tools - components return structs with handler field
      tool_handlers = Enum.map(tools, fn tool -> tool.handler end)

      assert MishkaChelekom.MCP.Tools.GenerateComponent in tool_handlers
      assert MishkaChelekom.MCP.Tools.GetComponentInfo in tool_handlers
      assert MishkaChelekom.MCP.Tools.GetExample in tool_handlers
      assert MishkaChelekom.MCP.Tools.SearchComponents in tool_handlers
    end

    test "server module has resources" do
      resources = MishkaChelekom.MCP.Server.__components__(:resource)

      assert is_list(resources)
      assert length(resources) > 0

      # Check for expected resources - components return structs with handler field
      resource_handlers = Enum.map(resources, fn resource -> resource.handler end)

      assert MishkaChelekom.MCP.Resources.ListComponents in resource_handlers
      assert MishkaChelekom.MCP.Resources.ListColors in resource_handlers
      assert MishkaChelekom.MCP.Resources.ListVariants in resource_handlers
      assert MishkaChelekom.MCP.Resources.ListSizes in resource_handlers
    end
  end

  describe "Router" do
    test "router module exists" do
      assert Code.ensure_loaded?(MishkaChelekom.MCP.Router)
    end
  end
end
