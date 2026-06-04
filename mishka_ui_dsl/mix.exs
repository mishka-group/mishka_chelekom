defmodule MishkaUiDsl.MixProject do
  use Mix.Project

  @moduledoc false

  def project do
    [
      app: :mishka_ui_dsl,
      version: "0.1.0-dev",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "Declarative (Spark DSL) UI bridge that renders Ash resources via Mishka Chelekom components."
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:spark, "~> 2.7"},
      # Ash is optional so the extension compiles/ships without forcing Ash on consumers.
      {:ash, "~> 3.0", optional: true},
      # The renderer targets Chelekom components in the host app (dev-time generation).
      {:mishka_chelekom, path: "../", only: :dev, optional: true}
    ]
  end
end
