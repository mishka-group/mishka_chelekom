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
    # Try to read from usage-rules/components/{name}.md
    usage_rules_path = get_usage_rules_path(name)

    if File.exists?(usage_rules_path) do
      case File.read(usage_rules_path) do
        {:ok, content} ->
          format_component_doc(name, content)

        {:error, _} ->
          fallback_response(name)
      end
    else
      fallback_response(name)
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
    📖 Full docs: https://mishka.tools/chelekom/docs/#{format_doc_url(name)}
    ⚡ Generate: `mix mishka.ui.gen.component #{name}`
    """
  end

  defp format_doc_url(name) do
    # Form components use /forms/ prefix
    form_components = [
      "checkbox_card",
      "checkbox_field",
      "color_field",
      "combobox",
      "date_time_field",
      "email_field",
      "fieldset",
      "file_field",
      "form_wrapper",
      "input_field",
      "native_select",
      "number_field",
      "password_field",
      "radio_card",
      "radio_field",
      "range_field",
      "search_field",
      "tel_field",
      "text_field",
      "textarea_field",
      "toggle_field",
      "url_field"
    ]

    url_name = String.replace(name, "_", "-")

    if name in form_components do
      "forms/#{url_name}"
    else
      url_name
    end
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

    📖 Visit: https://mishka.tools/chelekom/docs/#{format_doc_url(name)}

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
