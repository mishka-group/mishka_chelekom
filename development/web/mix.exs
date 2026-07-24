defmodule Development.MixProject do
  use Mix.Project

  def project do
    [
      app: :development,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Development.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2"},
      # Ecto (NO ecto_sql / postgrex): embedded changesets to drive the showcase form demos —
      # validation only, nothing is ever persisted to a database. phoenix_ecto provides the
      # Phoenix.HTML.FormData protocol for Ecto.Changeset so `to_form(changeset)` works.
      {:ecto, "~> 3.12"},
      {:phoenix_ecto, "~> 4.6"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      # Mishka Chelekom dev harness: consume the in-repo library as a path dep so
      # editing templates/JS/CSS in ../../priv reflects live when regenerating here.
      # See README.md. (Path is ../../ since this app moved under development/web/.)
      {:mishka_chelekom, path: "../../", only: [:dev, :test]},
      {:igniter, "~> 0.7", only: [:dev, :test]},
      # Quality gate — see `mix precommit` and CLAUDE.md. Latest versions.
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.14", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": [
        "mishka.assets.install",
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ],
      "assets.build": [
        "mishka.assets.install",
        "compile",
        "tailwind development",
        "esbuild development"
      ],
      "assets.deploy": [
        "mishka.assets.install",
        "tailwind development --minify",
        "esbuild development --minify",
        "phx.digest"
      ],
      # Quality gate — the agent runs `mix precommit` before finishing and CI runs
      # it inbound. Sobelow stays here (this is a Phoenix web surface — HEEx,
      # controllers); the native Mob app (../mob) omits it. Dialyzer runs on its
      # own (slow); add :boundary once contexts are annotated.
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --check-unused",
        "format --check-formatted",
        "deps.audit",
        "hex.audit",
        "credo --strict",
        "sobelow --config",
        "test --warnings-as-errors"
      ]
    ]
  end
end
