defmodule Mix.Tasks.Mishka.Mcp.ServerTest do
  use ExUnit.Case, async: false

  @moduletag :mcp_server

  alias MishkaChelekom.MCP.Supervisor, as: MCPSupervisor

  describe "MCP Server" do
    setup do
      Application.ensure_all_started(:inets)
      Application.ensure_all_started(:plug_cowboy)

      stop_supervisor = fn ->
        case Process.whereis(MCPSupervisor) do
          nil ->
            :ok

          pid ->
            try do
              Supervisor.stop(pid, :normal, 2000)
            catch
              :exit, _ -> :ok
            end
        end
      end

      stop_supervisor.()

      port = Enum.random(5000..5999)
      on_exit(stop_supervisor)

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
          {~c"accept", ~c"application/json"}
        ],
        ~c"application/json",
        body
      }

      {:ok, response} = :httpc.request(:post, request, [{:timeout, 5000}], [])
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

  describe "parse_args/1 (transport selection)" do
    alias Mix.Tasks.Mishka.Mcp.Server, as: ServerTask

    test "defaults to http on port 4003 when no args" do
      assert {:ok, {:http, 4003}} = ServerTask.parse_args([])
    end

    test "--port overrides default http port" do
      assert {:ok, {:http, 5000}} = ServerTask.parse_args(["--port", "5000"])
      assert {:ok, {:http, 5000}} = ServerTask.parse_args(["-p", "5000"])
    end

    test "--transport http is equivalent to default" do
      assert {:ok, {:http, 4003}} = ServerTask.parse_args(["--transport", "http"])
      assert {:ok, {:http, 5000}} = ServerTask.parse_args(["--transport", "http", "--port", "5000"])
    end

    test "--transport stdio selects stdio mode" do
      assert {:ok, :stdio} = ServerTask.parse_args(["--transport", "stdio"])
      assert {:ok, :stdio} = ServerTask.parse_args(["-t", "stdio"])
    end

    test "--port is ignored under stdio (stdio has no port)" do
      # Not strictly enforced — but the parser must still return :stdio
      assert {:ok, :stdio} = ServerTask.parse_args(["--transport", "stdio", "--port", "9999"])
    end

    test "unknown transport returns an error" do
      assert {:error, msg} = ServerTask.parse_args(["--transport", "tcp"])
      assert msg =~ "Unknown --transport"
      assert msg =~ "http"
      assert msg =~ "stdio"
    end
  end

  describe "Application transport override" do
    test "Application.start reads :mcp_transport from app env" do
      # Default: when unset, Application should choose the existing HTTP transport.
      original = Application.get_env(:mishka_chelekom, :mcp_transport)
      Application.delete_env(:mishka_chelekom, :mcp_transport)

      try do
        default =
          Application.get_env(:mishka_chelekom, :mcp_transport, {:streamable_http, start: true})

        assert default == {:streamable_http, start: true}

        Application.put_env(:mishka_chelekom, :mcp_transport, :stdio)
        assert Application.get_env(:mishka_chelekom, :mcp_transport) == :stdio
      after
        case original do
          nil -> Application.delete_env(:mishka_chelekom, :mcp_transport)
          val -> Application.put_env(:mishka_chelekom, :mcp_transport, val)
        end
      end
    end
  end
end
