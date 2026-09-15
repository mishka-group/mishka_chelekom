defmodule MishkaChelekom.MixProject do
  use Mix.Project

  @version "0.0.10-alpha.8"
  @source_url "https://github.com/mishka-group/mishka_chelekom"

  @app :mishka_chelekom

  def project do
    warn_if_misnamed()

    [
      app: @app,
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
      {:igniter, "~> 0.6 and >= 0.8.4"},
      {:guarded_struct, "~> 0.1"},
      # Layer 3 declarative config DSL (already present transitively via guarded_struct).
      {:spark, "~> 2.7"},
      {:igniter_js, "~> 0.5"},
      {:igniter_css, "~> 1.0"},
      {:owl, "~> 0.13"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      # Checks the lockfile against the Elixir security advisories. The harness apps have
      # carried it for a while; this project did not, which is how a HIGH-severity bandit
      # advisory sat in all three lockfiles unnoticed. Not forced on consumers.
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      # EXPORT-TIME ONLY, and never forced on a consumer. This kit's components name heroicon
      # CLASSES (`hero-bell`) and leave the pictures to the host's Tailwind plugin — which is right
      # for a Phoenix app and impossible for a CMS installing the bundle, because it has neither the
      # plugin nor the SVGs. `mix mishka.ui.export --cms` reads them once and writes them into the
      # bundle's `icons` block, so a consumer gets an icon picker out of the one file it downloaded.
      # See `MishkaChelekom.CmsBundle.Icons`. `only: :dev` because the export runs nowhere else.
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1,
       only: :dev},
      {:plug, "~> 1.18 and >= 1.20.3"},
      {:usage_rules, "~> 1.2", only: :test},
      {:anubis_mcp, "~> 2.0"},
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

  # MIX NEVER MENTIONS THE NAME YOU GAVE IT. A dependency declared under the wrong app name — a
  # `{:mihka_chelekom, github: "mishka-group/mishka_chelekom"}` with the `s` dropped — is fetched
  # happily into `deps/mihka_chelekom`, and only then does the graph go wrong: Mix keys a
  # dependency's own dependencies on the name it was declared with, so ours are never attached to
  # us, `anubis_mcp` is not compiled before we are, and the build dies on ten screens of
  #
  #   module Anubis.Server.Component is not loaded and could not be found
  #
  # which says nothing about the cause and sends the reader to the MCP code, or to Anubis, or to
  # their Elixir version. The directory we were unpacked into carries the name that was typed, so we
  # can read it and say so — once, before the errors, in the words of the fix.
  #
  # Only for a managed dependency: a path dep legitimately lives in a directory named whatever its
  # author cloned it as, and warning about that would be noise.
  defp warn_if_misnamed do
    declared = Path.basename(__DIR__)

    if Path.basename(Path.dirname(__DIR__)) == "deps" and declared != Atom.to_string(@app) do
      IO.warn(
        """
        #{@app} was declared as :#{declared}, and the two have to match.

            {:#{declared}, github: "mishka-group/mishka_chelekom"}   # what your mix.exs says
            {:#{@app}, github: "mishka-group/mishka_chelekom"}   # what it has to say

        Mix attaches a dependency's own dependencies to the name it was declared with, so under any
        other name ours are not attached at all — anubis_mcp is then not compiled before this
        library, and the errors below are the result rather than the cause.

        Fix the name in mix.exs, then run: mix deps.clean :#{declared} && mix deps.get
        """,
        []
      )
    end
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
