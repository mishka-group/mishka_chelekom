defmodule MishkaChelekom.MixProject do
  use Mix.Project

  @version "0.0.1"
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
      description: description(),
      package: package(),
      homepage_url: "https://github.com/mishka-group",
      source_url: @source_url,
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        extras: ["README.md", "CHANGELOG.md"],
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

  defp elixirc_paths(_mode), do: ["lib", "priv"]

  defp deps do
    [
      {:igniter, "~> 0.4.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:owl, "~> 0.12.0"}
    ]
  end

  defp description() do
    "Mishka Chelekom is a fully featured components and UI kit library for Phoenix & Phoenix LiveView"
  end

  defp package() do
    [
      files: ~w(lib priv .formatter.exs mix.exs LICENSE README*),
      licenses: ["Apache-2.0"],
      maintainers: ["Shahryar Tavakkoli", "Mona Aghili", "Arian Alijani"],
      links: %{
        "Chelekom" => "https://mishka.tools/chelekom",
        "Official document" => "https://mishka.tools/chelekom/docs",
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end
end
