defmodule MishkaChelekom.MCP.Tools.GetExample do
  @moduledoc """
  Get HEEx code examples for a Mishka Chelekom component.

  Reads examples from usage-rules/components/*.md documentation files.
  Returns ready-to-use code snippets showing common usage patterns.

  ## Usage

      get_example(name: "alert")
      get_example(name: "button")
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.PathHelper

  schema do
    field(:name, :string,
      required: true,
      description: "Component name (e.g., alert, button, modal, accordion)"
    )
  end

  @impl true
  def execute(%{name: name}, frame) do
    content = read_usage_rules(name)

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp read_usage_rules(name) do
    # Read usage-rules/components/{name}.md, with the path built only from a component this kit
    # ships, never from the name as given.
    with true <- ComponentConfig.known_component?(name),
         usage_rules_path = get_usage_rules_path(name),
         true <- File.exists?(usage_rules_path),
         {:ok, content} <- File.read(usage_rules_path) do
      format_component_doc(name, content)
    else
      _not_found -> fallback_response(name)
    end
  end

  defp get_usage_rules_path(name) do
    PathHelper.component_doc_path(name)
  end

  defp format_component_doc(name, content) do
    """
    # #{String.capitalize(name)} Component Documentation

    #{content}

    ---
    📖 Full docs: https://mishka.tools/chelekom/docs/#{ComponentConfig.docs_path(name)}
    ⚡ Generate: `mix mishka.ui.gen.component #{name}`
    """
  end

  defp fallback_response(name) do
    """
    # #{String.capitalize(name)} Component

    Documentation file not found in usage-rules/components/#{name}.md

    ## Basic Example

    ```heex
    <.#{name}>
      Content here
    </.#{name}>
    ```

    ## Get Full Documentation

    📖 Visit: https://mishka.tools/chelekom/docs/#{ComponentConfig.docs_path(name)}

    ## Generate This Component

    ```bash
    mix mishka.ui.gen.component #{name}
    ```

    ## Get Component Info

    Use the `get_component_info` tool to see available options:
    - variants, colors, sizes, padding, rounded
    - dependencies (necessary and optional)
    - available component types
    """
  end
end
