defmodule MishkaChelekom.MCP.Resources.ListVariants do
  @moduledoc """
  List all available style variants for Mishka Chelekom components.

  Variants are read dynamically from priv/components/*.exs configuration files.
  Different components may support different subsets of variants.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://variants",
    name: "list_variants",
    description: "List all available style variants for Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @variant_descriptions %{
    "default" => "Standard solid appearance with background color",
    "outline" => "Border-only with transparent background",
    "transparent" => "Fully transparent with visible text",
    "shadow" => "Elevated appearance with drop shadow",
    "bordered" => "Strong border emphasis with background",
    "gradient" => "Gradient background effect",
    "base" => "Minimal, unstyled base appearance",
    "subtle" => "Subdued, low-emphasis styling",
    "surface" => "Surface-level styling for containers",
    "soft" => "Soft, muted appearance",
    "inverted" => "Inverted color scheme",
    "default_gradient" => "Default style with gradient background",
    "outline_gradient" => "Outline style with gradient border",
    "inverted_gradient" => "Inverted style with gradient"
  }

  @impl true
  def read(_params, frame) do
    variants = ComponentConfig.list_variants()

    variants_with_descriptions =
      Enum.map(variants, fn variant ->
        %{
          name: variant,
          description: Map.get(@variant_descriptions, variant, "Style variant"),
          usage: "--variant #{variant}"
        }
      end)

    response =
      Response.resource()
      |> Response.json(%{
        variants: variants,
        details: variants_with_descriptions,
        description: "Available style variants for components (read from component configs)",
        note:
          "Not all variants are available for every component. Use get_component_info tool to check available variants for a specific component.",
        usage_example: "mix mishka.ui.gen.component button --variant outline"
      })

    {:reply, response, frame}
  end
end
