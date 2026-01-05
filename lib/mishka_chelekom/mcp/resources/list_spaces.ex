defmodule MishkaChelekom.MCP.Resources.ListSpaces do
  @moduledoc """
  List all available space options for Mishka Chelekom components.

  Spaces are read dynamically from priv/components/*.exs configuration files.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://spaces",
    name: "list_spaces",
    description: "List all available space/gap options for Mishka Chelekom components",
    mime_type: "application/json"

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig

  @space_descriptions %{
    "extra_small" => "Minimal spacing between elements",
    "small" => "Reduced spacing for compact layouts",
    "medium" => "Default balanced spacing",
    "large" => "Increased spacing for more breathing room",
    "extra_large" => "Maximum spacing for prominent separation",
    "none" => "No spacing applied"
  }

  @space_aliases %{
    "extra_small" => "xs",
    "small" => "sm",
    "medium" => "md",
    "large" => "lg",
    "extra_large" => "xl"
  }

  @impl true
  def read(_params, frame) do
    spaces = ComponentConfig.list_spaces()

    spaces_with_descriptions =
      Enum.map(spaces, fn space ->
        %{
          name: space,
          alias: Map.get(@space_aliases, space),
          description: Map.get(@space_descriptions, space, "Space option"),
          usage: "--space #{space}"
        }
      end)

    response =
      Response.resource()
      |> Response.json(%{
        spaces: spaces,
        details: spaces_with_descriptions,
        description: "Available space/gap options for components (read from component configs)",
        usage_example: "mix mishka.ui.gen.component accordion --space medium"
      })

    {:reply, response, frame}
  end
end
