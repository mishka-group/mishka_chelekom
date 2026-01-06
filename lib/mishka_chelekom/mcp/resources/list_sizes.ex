defmodule MishkaChelekom.MCP.Resources.ListSizes do
  @moduledoc """
  List all available size options for Mishka Chelekom components.

  Sizes are read dynamically from priv/components/*.exs configuration files.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://sizes",
    name: "list_sizes",
    description: "List all available size options for Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @size_descriptions %{
    "extra_small" => "Compact size with minimal spacing, suitable for dense UIs",
    "small" => "Reduced size with tight spacing",
    "medium" => "Default balanced size, suitable for most use cases",
    "large" => "Increased size with more prominence",
    "extra_large" => "Maximum size with high visual prominence",
    "double_large" => "Double large size, used for headings and prominent elements",
    "triple_large" => "Triple large size, used for page headings",
    "quadruple_large" => "Quadruple large size, used for hero text and major headings",
    "full" => "Full width or height (context dependent)",
    "auto" => "Automatic sizing based on content",
    "none" => "No size constraints applied"
  }

  @size_aliases %{
    "extra_small" => "xs",
    "small" => "sm",
    "medium" => "md",
    "large" => "lg",
    "extra_large" => "xl",
    "double_large" => "2xl",
    "triple_large" => "3xl",
    "quadruple_large" => "4xl"
  }

  @impl true
  def read(_params, frame) do
    sizes = ComponentConfig.list_sizes()
    rounded = ComponentConfig.list_rounded()
    padding = ComponentConfig.list_padding()

    sizes_with_descriptions =
      Enum.map(sizes, fn size ->
        %{
          name: size,
          alias: Map.get(@size_aliases, size),
          description: Map.get(@size_descriptions, size, "Size option"),
          usage: "--size #{size}"
        }
      end)

    response =
      Response.resource()
      |> Response.json(%{
        sizes: sizes,
        details: sizes_with_descriptions,
        description: "Available size options for components (read from component configs)",
        related_options: %{
          padding: padding,
          rounded: rounded
        },
        usage_example:
          "mix mishka.ui.gen.component button --size large --padding medium --rounded full"
      })

    {:reply, response, frame}
  end
end
