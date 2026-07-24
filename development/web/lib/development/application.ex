defmodule Development.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DevelopmentWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:development, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Development.PubSub},
      # Start a worker by calling: Development.Worker.start_link(arg)
      # {Development.Worker, arg},
      # Start to serve requests, typically the last entry
      DevelopmentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Development.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DevelopmentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
