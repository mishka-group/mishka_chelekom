defmodule MishkaChelekom.MCP.Tools.GetDocs do
  @moduledoc """
  Fetch documentation from the Mishka Chelekom website.

  Retrieves component documentation, guides, and examples from mishka.tools.
  Documentation URLs are read from component configs (doc_url field in priv/components/*.exs).

  ## Usage

      get_docs(topic: "button")
      get_docs(topic: "accordion")
      get_docs(topic: "cli")
      get_docs(topic: "getting-started")
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.PathHelper

  @base_url "https://mishka.tools/chelekom/docs"

  # Special topics that aren't components
  @special_topics %{
    "getting-started" => "#{@base_url}/getting-started",
    "installation" => "#{@base_url}/getting-started",
    "setup" => "#{@base_url}/getting-started",
    "cli" => "#{@base_url}/cli",
    "mix-tasks" => "#{@base_url}/cli",
    "commands" => "#{@base_url}/cli",
    "design-system" => "#{@base_url}/design-system",
    "roadmap" => "#{@base_url}/roadmap",
    "security" => "#{@base_url}/security"
  }

  # Mapping of special topics to their local markdown files
  @local_docs_map %{
    "getting-started" => "getting-started.md",
    "installation" => "getting-started.md",
    "setup" => "getting-started.md",
    "cli" => "cli.md",
    "mix-tasks" => "cli.md",
    "commands" => "cli.md",
    "design-system" => "design-system.md",
    "roadmap" => "roadmap.md",
    "security" => "security.md"
  }

  schema do
    field(:topic, :string,
      required: true,
      description:
        "Documentation topic: component name (button, modal, accordion), 'cli', 'getting-started', 'design-system', 'roadmap', or 'security'"
    )
  end

  @impl true
  def execute(%{topic: topic}, frame) do
    normalized_topic = normalize_topic(topic)
    doc_url = get_doc_url(normalized_topic)

    content = format_doc_response(normalized_topic, doc_url)

    response =
      Response.tool()
      |> Response.text(content)

    {:reply, response, frame}
  end

  defp normalize_topic(topic) do
    topic
    |> String.downcase()
    |> String.trim()
    |> String.replace("_", "-")
  end

  defp get_doc_url(topic) do
    # First check special topics
    case Map.get(@special_topics, topic) do
      nil ->
        # Look up from component configs (convert dashes back to underscores for lookup)
        component_name = String.replace(topic, "-", "_")
        ComponentConfig.get_doc_url(component_name)

      url ->
        url
    end
  end

  defp format_doc_response(topic, doc_url) do
    # Check if we have local usage-rules documentation
    local_doc = check_local_docs(topic)

    """
    # #{format_topic_name(topic)} Documentation

    ## Online Documentation

    **URL:** #{doc_url}

    > Fetch this URL to get the full, up-to-date documentation from mishka.tools

    ---

    #{local_doc}

    ## Quick Reference

    #{quick_reference(topic)}

    ---

    ## Related Commands

    #{related_commands(topic)}

    ---

    📖 **Full docs:** #{doc_url}
    """
  end

  defp check_local_docs(topic) do
    # Convert topic to filename format
    filename = String.replace(topic, "-", "_")

    # Check usage-rules/docs/ for library-level documentation
    docs_filename = Map.get(@local_docs_map, topic)

    docs_path =
      if docs_filename,
        do: PathHelper.lib_doc_path(docs_filename),
        else: nil

    # Check usage-rules/components/
    component_path = PathHelper.component_doc_path(filename)
    # Check usage-rules/js/
    js_path = PathHelper.js_hook_doc_path(filename)

    cond do
      docs_path && File.exists?(docs_path) ->
        case File.read(docs_path) do
          {:ok, content} ->
            """
            ## Local Documentation

            #{content}
            """

          _ ->
            ""
        end

      File.exists?(component_path) ->
        """
        ## Local Documentation Available

        Use the `get_example` tool for full component documentation:

        ```
        get_example(name: "#{filename}")
        ```

        Or use `get_component_info` for configuration options:

        ```
        get_component_info(name: "#{filename}")
        ```
        """

      File.exists?(js_path) ->
        """
        ## Local JS Hook Documentation Available

        Use the `get_js_hook_info` tool:

        ```
        get_js_hook_info(name: "#{filename}")
        ```
        """

      true ->
        ""
    end
  end

  defp format_topic_name(topic) do
    topic
    |> String.split("-")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp quick_reference(topic) when topic in ["cli", "mix-tasks", "commands"] do
    """
    ### Mix Tasks

    | Task | Description |
    |------|-------------|
    | `mix mishka.ui.gen.component NAME` | Generate a single component |
    | `mix mishka.ui.gen.components` | Generate all/multiple components |
    | `mix mishka.ui.add NAME` | Add from community templates |
    | `mix mishka.ui.uninstall NAME` | Remove component(s) |
    | `mix mishka.ui.css.config` | Manage CSS configuration |
    """
  end

  defp quick_reference(topic) when topic in ["getting-started", "installation", "setup"] do
    """
    ### Installation

    ```bash
    # Add to mix.exs
    {:mishka_chelekom, "~> 0.0.9"}

    # Install dependencies
    mix deps.get

    # Generate all components (recommended for new projects)
    mix mishka.ui.gen.components --import --helpers --global --yes

    # Or generate specific components
    mix mishka.ui.gen.component button
    mix mishka.ui.gen.component modal
    ```

    ### Requirements

    - Phoenix 1.8+
    - Tailwind CSS 4.0+
    - Elixir 1.14+
    """
  end

  defp quick_reference("design-system") do
    """
    ### Design Tokens

    - **Typography**: extra_small, small, medium, large, extra_large, double_large, triple_large, quadruple_large
    - **Sizes**: extra_small, small, medium, large, extra_large
    - **Shadows**: extra_small, small, medium, large, extra_large
    - **Font Weights**: thin, light, normal, medium, semibold, bold, extrabold

    ### Color Categories

    - Neutrals, Primary, Secondary, Success, Warning, Danger, Info, Misc, Dawn
    """
  end

  defp quick_reference("roadmap") do
    """
    ### Current Version: v0.0.8

    Key milestones:
    - Tailwind CSS 4 migration
    - CLI tool for custom CSS configuration
    - Phoenix 1.8+ compatibility

    **GitHub Milestones**: https://github.com/mishka-group/mishka_chelekom/milestones
    """
  end

  defp quick_reference("security") do
    """
    ### Security Principles

    - Multi-layered defense model
    - Input validation & sanitization
    - CSP header compatibility
    - Rate limiting recommendations

    **Report vulnerabilities to**: shahryar@mishka.tools
    """
  end

  defp quick_reference(topic) do
    filename = String.replace(topic, "-", "_")

    """
    ### Generate Component

    ```bash
    mix mishka.ui.gen.component #{filename}
    ```

    ### Common Options

    ```bash
    # With specific colors
    mix mishka.ui.gen.component #{filename} --color primary,danger

    # With specific variants
    mix mishka.ui.gen.component #{filename} --variant default,outline

    # Custom module name
    mix mishka.ui.gen.component #{filename} --module MyAppWeb.Components.Custom#{format_topic_name(topic) |> String.replace(" ", "")}
    ```
    """
  end

  defp related_commands(topic) when topic in ["cli", "mix-tasks", "commands"] do
    """
    ```bash
    # Get help on any mix task
    mix help mishka.ui.gen.component
    mix help mishka.ui.gen.components
    mix help mishka.ui.css.config
    ```
    """
  end

  defp related_commands(topic) when topic in ["getting-started", "installation", "setup"] do
    """
    ```bash
    # After installation, check available components
    mix mishka.ui.gen.component --help

    # Generate import macro for easy access
    mix mishka.ui.gen.components --import --helpers
    ```
    """
  end

  defp related_commands(topic) when topic in ["design-system", "roadmap", "security"] do
    """
    ```bash
    # Related MCP tools
    list_components()
    get_docs(topic: "getting-started")
    get_docs(topic: "cli")
    ```
    """
  end

  defp related_commands(topic) do
    filename = String.replace(topic, "-", "_")

    """
    ```bash
    # Search for related components
    mix mishka.ui.gen.component --help

    # Get component info via MCP
    get_component_info(name: "#{filename}")

    # Get examples via MCP
    get_example(name: "#{filename}")
    ```
    """
  end
end
