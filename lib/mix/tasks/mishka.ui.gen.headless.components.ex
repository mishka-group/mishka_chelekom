defmodule Mix.Tasks.Mishka.Ui.Gen.Headless.Components do
  use Igniter.Mix.Task

  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.Config

  @example "mix mishka.ui.gen.headless.components dialog,tabs"
  @shortdoc "Generate multiple (or all) headless components at once"
  @moduledoc """
  #{@shortdoc}

  Pass a comma-separated list of headless component names, or omit it (or pass `all`) to
  generate every component in `priv/headless/`.

  ## Example

  ```bash
  #{@example}
  mix mishka.ui.gen.headless.components       # all of them
  ```

  ## Options

  * `--exclude` - Comma-separated names to skip
  * `--component-prefix` - Prefix for public function names
  * `--module-prefix` - Prefix for module names
  * `--no-save` - Use prefixes without saving them to config
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      example: @example,
      positional: [{:components, optional: true}],
      composes: ["mishka.ui.gen.headless"],
      schema: [
        exclude: :csv,
        component_prefix: :string,
        module_prefix: :string,
        no_save: :boolean
      ],
      aliases: [e: :exclude]
    }
  end

  def supports_umbrella?(), do: false

  def igniter(igniter) do
    %Igniter.Mix.Task.Args{positional: %{components: components}} = igniter.args
    options = igniter.args.options

    requested = String.split(components || "", ",", trim: true)
    exclude = options[:exclude] || []

    list =
      if requested == [] or "all" in requested, do: all_headless(), else: requested

    list = Enum.reject(list, &(&1 in exclude))

    prefix_args =
      []
      |> maybe_arg("--component-prefix", options[:component_prefix])
      |> maybe_arg("--module-prefix", options[:module_prefix])
      |> then(&if(options[:no_save], do: &1 ++ ["--no-save"], else: &1))

    Config.load_user_config(igniter)
    |> then(&Igniter.assign(igniter, %{mishka_user_config: &1}))
    |> then(fn ig ->
      Enum.reduce(list, ig, fn name, acc ->
        Igniter.compose_task(
          acc,
          "mishka.ui.gen.headless",
          [name, "--sub", "--yes"] ++ prefix_args
        )
      end)
    end)
  end

  defp all_headless do
    Core.template_dir(:headless)
    |> Path.join("*.eex")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".eex"))
    |> Enum.sort()
  end

  defp maybe_arg(args, _flag, nil), do: args
  defp maybe_arg(args, _flag, ""), do: args
  defp maybe_arg(args, flag, value), do: args ++ [flag, value]
end
