defmodule MishkaMob.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_mob,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: false,
      deps: deps(),
      aliases: aliases(),
      erlc_paths: ["src"],
      erlc_options: [:debug_info]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:mob, "~> 0.7"},
      {:mob_dev, "~> 0.6", only: :dev, runtime: false},
      {:ecto_sqlite3, "~> 0.18"},
      # Showcase plugins — each ships a demo screen the home auto-lists, so a
      # fresh app demonstrates real device capabilities out of the box. Remove
      # any you don't need (and drop it from config :mob, :plugins in mob.exs);
      # the native build shrinks accordingly. Browse more at
      # https://hexdocs.pm/mob/packages.html.
      {:mob_camera, "~> 0.1"},
      {:mob_location, "~> 0.1"},
      {:mob_biometric, "~> 0.1"},
      {:mob_themes, "~> 0.1"},
      # Code quality — Credo + ex_slop (catches AI-generated patterns
      # like blanket rescue, narrator docs, redundant Enum chains, etc).
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4.2", only: [:dev, :test], runtime: false}
    ]
  end

  # Shorthands for the common mob workflows — `mix deploy` is `mix mob.deploy`,
  # etc. Extra args pass through to the underlying task, so `mix deploy
  # --device <udid>` works as expected.
  defp aliases do
    [
      connect: ["mob.connect"],
      deploy: ["mob.deploy"],
      watch: ["mob.watch"],
      icon: ["mob.icon"],
      ios: ["mob.deploy --ios"],
      "ios.native": ["mob.deploy --native --ios"],
      android: ["mob.deploy --android"],
      "android.native": ["mob.deploy --native --android"]
    ]
  end
end
