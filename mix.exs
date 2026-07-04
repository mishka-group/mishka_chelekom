defmodule MishkaChelekom.MixProject do
  use Mix.Project

  @version "0.0.9-beta.5"
  @source_url "https://github.com/mishka-group/mishka_chelekom"

  def project do
    [
      app: :mishka_chelekom,
      name: "Mishka Chelekom",
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")],
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

  # `priv/demos/` holds vendored `<comp>_live.{ex,html.heex}` showcase
  # files used by `mix mishka.ui.export --cms` and `mix mishka.ui.verify`.
  # The companion `_live.ex` files reference host-app modules
  # (MishkaWeb, etc.) that aren't loaded in chelekom — read them as
  # source text, never auto-compile.
  defp elixirc_paths(:test), do: ["lib", "priv/components", "test/support"]
  defp elixirc_paths(_mode), do: ["lib", "priv/components"]

  defp aliases do
    [
      "mcp.server": ["mishka.mcp.server"],
      "mcp.setup": ["mishka.mcp.setup"]
    ]
  end

  defp deps do
    [
      {:igniter, "~> 0.6 and >= 0.8.2"},
      {:guarded_struct, "~> 0.1.1"},
      # Layer 3 declarative config DSL (already present transitively via guarded_struct).
      {:spark, "~> 2.7"},
      {:igniter_js, "~> 0.4.11"},
      {:owl, "~> 0.13"},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false},
      {:plug, "~> 1.18 and >= 1.20.0"},
      {:usage_rules, "~> 1.2", only: :test},
      {:anubis_mcp, "~> 1.6"},
      {:bandit, "~> 1.12", optional: true},
      {:jason, "~> 1.4"},
      # Optional (not forced on consumers): host Phoenix apps always provide their own
      # phoenix_live_view. Declaring it `optional` (rather than dev/test-only) keeps the
      # dependency edge in the graph, so when mishka_chelekom compiles as a dependency the
      # host's LiveView is compiled first and `Phoenix.Component` is available to the
      # `MishkaChelekom.Component` macro renderers and the `mix mishka.ui.verify --cms` harness.
      # Production-installed users are unaffected — `optional` is never auto-installed.
      {:phoenix_live_view, "~> 1.2", optional: true}
    ]
  end

  defp description() do
    "Mishka Chelekom is a fully featured components and UI kit library for Phoenix & Phoenix LiveView"
  end

  defp package() do
    [
      extra: %{igniter_only: ["dev"]},
      # `priv` is listed explicitly (rather than as a whole) so the large generated
      # `priv/components/chelekom.json` bundle is NOT shipped to Hex — it is a build export
      # (cms_bundle_exporter), not read at runtime. Everything else under priv is included.
      files: ~w(lib .formatter.exs mix.exs LICENSE README* MCP.md usage-rules.md usage-rules
           priv/assets priv/demos priv/headless
           priv/components/*.exs priv/components/*.eex),
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
