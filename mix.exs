defmodule MishkaChelekom.MixProject do
  use Mix.Project

  @version "0.0.9-alpha.7"
  @source_url "https://github.com/mishka-group/mishka_chelekom"

  def project do
    [
      app: :mishka_chelekom,
      name: "Mishka Chelekom",
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      homepage_url: "https://github.com/mishka-group",
      source_url: @source_url,
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        extras: ["README.md", "MCP.md", "CHANGELOG.md"],
        source_url: @source_url
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MishkaChelekom.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_mode), do: ["lib", "priv"]

  defp aliases do
    [
      "mcp.server": ["mishka.mcp.server"],
      "mcp.setup": ["mishka.mcp.setup"]
    ]
  end

  defp deps do
    [
      {:igniter, "~> 0.5 and >= 0.7.0"},
      {:guarded_struct, "~> 0.0.4"},
      {:igniter_js, "~> 0.4.11"},
      {:owl, "~> 0.13"},
      {:ex_doc, "~> 0.39.1", only: :dev, runtime: false},
      {:plug, "~> 1.18"},
      {:usage_rules, "~> 0.1.26", only: :test},
      {:anubis_mcp, "~> 0.17.0"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"}
    ]
  end

  defp description() do
    "Mishka Chelekom is a fully featured components and UI kit library for Phoenix & Phoenix LiveView"
  end

  defp package() do
    [
      extra: %{igniter_only: ["dev"]},
      files:
        ~w(lib priv .formatter.exs mix.exs LICENSE README* MCP.md usage-rules.md usage-rules),
      licenses: ["Apache-2.0"],
      maintainers: ["Shahryar Tavakkoli", "Mona Aghili", "Arian Alijani"],
      links: %{
        "Chelekom" => "https://mishka.tools/chelekom",
        "Official document" => "https://mishka.tools/chelekom/docs",
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "Sponsor" => "https://github.com/sponsors/mishka-group"
      }
    ]
  end
end
