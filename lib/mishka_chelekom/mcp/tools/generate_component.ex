defmodule MishkaChelekom.MCP.Tools.GenerateComponent do
  @moduledoc """
  Generate a Mishka Chelekom component with specific customization options.

  Returns the mix command to run for creating the component in a Phoenix project.
  The component will be generated in the project's components directory.

  ## Usage

  Call this tool with a component name and optional customization parameters.
  Use the list_components resource to discover available components.
  Use list_colors, list_variants, and list_sizes resources for valid option values.

  ## Example

  Generate a button component with primary color and outline variant:

      generate_component(name: "button", color: "primary", variant: "outline")

  Returns:
      mix mishka.ui.gen.component button --color "primary" --variant outline
  """

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response

  schema do
    field(:name, :string,
      required: true,
      description:
        "Component name from list_components resource (e.g., alert, button, accordion, modal, card)"
    )

    field(:color, :string,
      description:
        "Color variant from list_colors resource. Multiple colors can be comma-separated (e.g., 'info,danger,warning')"
    )

    field(:variant, :string,
      description:
        "Style variant from list_variants resource (e.g., default, outline, shadow, bordered)"
    )

    field(:size, :string,
      description:
        "Size from list_sizes resource (extra_small, small, medium, large, extra_large)"
    )

    field(:padding, :string,
      description: "Padding size (extra_small, small, medium, large, extra_large, none)"
    )

    field(:rounded, :string,
      description: "Border radius (extra_small, small, medium, large, extra_large, full, none)"
    )

    field(:only, :string,
      description:
        "Generate only specific sub-components. Comma-separated list of component types."
    )

    field(:module, :string, description: "Custom module name for the generated component")
  end

  @impl true
  def execute(params, frame) do
    command = build_mix_command(params)

    response =
      Response.tool()
      |> Response.text("""
      Run this command in your Phoenix project root:

      ```bash
      #{command}
      ```

      This will generate the #{params.name} component with your specified options.

      After generation, the component will be available in your project. Import it with:

      ```elixir
      use MishkaChelekom
      # or import individual component
      import YourAppWeb.Components.#{Macro.camelize(params.name)}
      ```

      For more options, run:
      ```bash
      mix help mishka.ui.gen.component
      ```
      """)

    {:reply, response, frame}
  end

  defp build_mix_command(params) do
    base = "mix mishka.ui.gen.component #{params.name}"

    opts = []
    opts = if params[:color], do: opts ++ ["--color", ~s("#{params.color}")], else: opts
    opts = if params[:variant], do: opts ++ ["--variant", params.variant], else: opts
    opts = if params[:size], do: opts ++ ["--size", params.size], else: opts
    opts = if params[:padding], do: opts ++ ["--padding", params.padding], else: opts
    opts = if params[:rounded], do: opts ++ ["--rounded", params.rounded], else: opts
    opts = if params[:only], do: opts ++ ["--only", ~s("#{params.only}")], else: opts
    opts = if params[:module], do: opts ++ ["--module", params.module], else: opts

    if Enum.empty?(opts) do
      base
    else
      base <> " " <> Enum.join(opts, " ")
    end
  end
end
