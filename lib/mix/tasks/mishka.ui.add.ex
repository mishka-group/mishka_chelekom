defmodule Mix.Tasks.Mishka.Ui.Add do
  use Igniter.Mix.Task
  use GuardedStruct
  alias GuardedStruct.Derive.ValidationDerive

  @example "mix mishka.ui.add repo --example arg"
  @shortdoc "A Mix Task for generating and configuring Phoenix components from a repo"
  @moduledoc """
  #{@shortdoc}

  This script is used in the development environment and allows you to easily add all Mishka

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--variant` or `-v` - Specifies component variant
  """

  guardedstruct do
    field(:name, String.t(),
      derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=80, min_len=3)",
      enforce: true
    )

    field(:type, String.t(),
      derive: "sanitize(tag=strip_tags) validate(enum=String[component::preset::template])",
      enforce: true
    )

    conditional_field(:components, list(String.t()),
      structs: true,
      derive: "validate(list)",
      default: []
    ) do
      field(:components, String.t(),
        derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)",
        validator: {Mix.Tasks.Mishka.Ui.Add, :is_component?}
      )
    end

    sub_field(:files, list(map()),
      structs: true,
      validator: {Mix.Tasks.Mishka.Ui.Add, :uniq_components?},
      default: []
    ) do
      field(:type, String.t(),
        derive: "sanitize(tag=strip_tags) validate(enum=String[component::preset::template])",
        enforce: true
      )

      field(:content, String.t(), derive: "validate(not_empty_string)", enforce: true)

      field(:name, String.t(),
        derive: "sanitize(tag=strip_tags) validate(not_empty_string, regex=\"^[a-z_]+$\")",
        enforce: true
      )

      field(:from, String.t(), derive: "validate(not_empty_string, url)")

      conditional_field(:optional, list(String.t()),
        structs: true,
        derive: "validate(list)",
        default: []
      ) do
        field(:optional, String.t(),
          derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)",
          validator: {Mix.Tasks.Mishka.Ui.Add, :is_component?}
        )
      end

      conditional_field(:necessary, list(String.t()),
        structs: true,
        derive: "validate(list)",
        default: []
      ) do
        field(:necessary, String.t(),
          derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)",
          validator: {Mix.Tasks.Mishka.Ui.Add, :is_component?}
        )
      end

      sub_field(:args, map(), default: %{}) do
        field(:variant, list(String.t()), derive: "validate(list)", default: [])
        field(:color, list(String.t()), derive: "validate(list)", default: [])
        field(:size, list(String.t()), derive: "validate(list)", default: [])
        field(:padding, list(String.t()), derive: "validate(list)", default: [])
        field(:space, list(String.t()), derive: "validate(list)", default: [])
        field(:type, list(String.t()), derive: "validate(list)", default: [])
        field(:rounded, list(String.t()), derive: "validate(list)", default: [])
        field(:only, list(String.t()), derive: "validate(list)", default: [])

        field(:module, String.t(), derive: "validate(string)", default: "")
      end
    end
  end

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation
      example: @example,
      # Accept additional arguments that are not in your schema
      # Does not guarantee that, when composed, the only options you get are the ones you define
      extra_args?: false,
      # A list of environments that this should be installed in, only relevant if this is an installer.
      only: nil,
      # a list of positional arguments, i.e `[:file]`
      positional: [:repo],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [],
      # CLI aliases
      aliases: []
    }
  end

  def igniter(igniter, argv) do
    {:ok, _} = Application.ensure_all_started(:req)
    # extract positional arguments according to `positional` above
    {%{repo: repo}, argv} = positional_args!(argv)

    _options = options!(argv)

    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.tools
      """

    IO.puts(IO.ANSI.blue() <> String.trim_trailing(msg) <> IO.ANSI.reset())

    _file_url = repo_url(repo) |> IO.inspect()

    resp = Req.get!("https://fancy-mountain-ac66.mishka.workers.dev")

    resp.body
    |> __MODULE__.builder()
    |> case do
      {:ok, params} ->
        params = Map.merge(params, %{from: String.trim(repo)})

        Enum.reduce(params.files, igniter, fn item, acc ->
          args =
            if is_struct(item.args),
              do:
                item.args
                |> Map.from_struct()
                |> Map.to_list()
                |> Enum.reject(&match?({_, []}, &1)),
              else: []

          direct_path =
            File.cwd!()
            |> Path.join(["priv", "/mishka_chelekom", "/#{item.type}s", "/#{item.name}"])

          config =
            [
              {String.to_atom(item.name),
               [
                 name: item.name,
                 args: args,
                 optional: item.necessary,
                 necessary: item.optional
               ]}
            ]
            |> Enum.into([])

          acc
          |> Igniter.create_new_file(direct_path <> ".eex", item.content, on_exists: :overwrite)
          |> Igniter.create_new_file(direct_path <> ".exs", "#{inspect(config)}",
            on_exists: :overwrite
          )
        end)

      {:error, errors} ->
        show_errors(igniter, errors)
    end

    # TODO: Mix tasks must can create it as a component
    # TODO: Should be in --import
  rescue
    errors ->
      show_errors(igniter, errors)
  end

  def supports_umbrella?(), do: false

  # Validator functions
  def is_component?(name, value) do
    if Enum.member?(components(), value),
      do: {:ok, name, value},
      else:
        {:error, name, "One of the components entered as a dependency is missing from the list!"}
  end

  def uniq_components?(name, value) do
    names = Enum.map(value, & &1[:name]) |> Enum.uniq() |> length()

    if names == length(value) do
      {:ok, name, value}
    else
      msg =
        "The requested files to be created in your project directory are duplicates. Please correct your source."

      {:error, [%{message: msg, field: :files, action: :validator}]}
    end
  end

  defp components() do
    Application.app_dir(:mishka_chelekom, ["priv", "templates", "components"])
    |> File.ls!()
    |> Enum.filter(&(Path.extname(&1) == ".eex"))
    |> Enum.map(&Path.rootname(&1, ".eex"))
  end

  # Errors functions
  defp show_errors(igniter, %MatchError{term: {:error, errors}}) do
    show_errors(igniter, errors)
  end

  defp show_errors(igniter, errors) when is_list(errors) do
    igniter
    |> Igniter.add_issue(
      "\e[1mOne or more errors occurred while processing your request.\e[0m\n" <>
        format_errors(errors)
    )
  end

  defp show_errors(igniter, errors) when is_map(errors) do
    igniter
    |> Igniter.add_issue("""
    \e[1mOne or more errors occurred while processing your request.\e[0m\n
    - fields: #{inspect(Map.get(errors, :fields))}
    - message: #{Map.get(errors, :message)}
    - action: #{Map.get(errors, :action)}
    """)
  end

  defp show_errors(igniter, errors) do
    igniter
    |> Igniter.add_issue("""
    \e[1mOne or more errors occurred while processing your request.\e[0m\n
    #{inspect(errors)}
    """)
  end

  def format_errors(errors) do
    errors
    |> Enum.map(&process_error(&1, ""))
    |> Enum.join("\n")
  end

  defp process_error(%{errors: nested_errors} = error, indent) do
    [
      format_field("fields", Map.get(error, :fields) || Map.get(error, :field), indent),
      format_field("message", Map.get(error, :message), indent),
      format_field("action", Map.get(error, :action), indent),
      format_nested_errors(nested_errors, indent <> "--")
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  defp process_error(error, indent) do
    [
      format_field("fields", Map.get(error, :fields) || Map.get(error, :field), indent),
      format_field("message", Map.get(error, :message), indent),
      format_field("action", Map.get(error, :action), indent)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  defp format_field(_label, nil, _indent), do: ""
  defp format_field(label, value, indent), do: "#{indent}- #{label}: #{value}"

  defp format_nested_errors(nested_errors, indent) do
    nested_errors
    |> Enum.map(&process_error(&1, indent))
    |> Enum.join("\n")
  end

  defp repo_url("component-" <> _file_name) do
    nil
  end

  defp repo_url("preset-" <> _file_name) do
    nil
  end

  defp repo_url("template-" <> _file_name) do
    nil
  end

  defp repo_url(repo) do
    ValidationDerive.validate(:url, repo, :repo)
    |> case do
      {:error, :repo, :url, _msg} -> nil
      url when is_binary(url) -> nil
    end
  end
end
