defmodule Mix.Tasks.Mishka.Ui.Export do
  @example "mix mishka.ui.export --example arg"

  @shortdoc "A Mix Task for generating a JSON file from a directory of components"

  @moduledoc """
  #{@shortdoc}

  This Mix Task helps you generate a JSON file from the files in a directory,
  enabling you to use it with `mix mishka.ui.add` or share it in the community version.

  Keep in mind that for each component, you must have both `.eex` and `.exs` files according to the
  documentation of the [Mishka Chelekom](https://github.com/mishka-group/mishka_chelekom) library.
  Otherwise, you will need to create the necessary files manually.
  It’s recommended to review the Core components and follow their structure as a guide.

  If you prefer to perform the process manually, simply add the relevant option to your command to
  generate a template file. You can then customize it based on your specific requirements.

  **Note**:

  > Use `--base64` option to convert the file content to Base64 if you're using special Erlang
  characters that do not retain their original form when converted back to the original file.

  **Note**:

  It is important to note that to place each file in its designated section and specify its type,
  you must use the following naming convention:

  For example, if your file is a `component`, you need to have two files:

  - `component_something.exs`
  - `component_something.eex`

  Similarly, for other file types like `preset` and `template`, you should follow the same
  naming pattern as above. For instance:

  - `template_something.exs`
  - `template_something.eex`

  All files within the directory do not need to have the same name. However,
  they must start with the section name where they are intended to be placed, such as
  `component`, `preset`, or `template`. Additionally, each file must have both the
  `exs` and `eex` formats.

  > **Note**: Since JavaScript files do not require configuration, you only need to
  place the file in the directory. For example: `something.js`


  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--base64` or `-b` - Converts component content to Base64
  * `--name` or `-n` - Defines a name for JSON file, if it is not set default is template.json
  * `--template` or `-t` - Creates a default JSON file for manual processing steps.
  """

  use Igniter.Mix.Task

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # Groups allow for overlapping arguments for tasks by the same author
      # See the generators guide for more.
      group: :mishka_chelekom,
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation
      example: @example,
      # a list of positional arguments, i.e `[:file]`
      positional: [:dir],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [base64: :boolean, template: :boolean, name: :string],
      # Default values for the options in the `schema`
      defaults: [],
      # CLI aliases
      aliases: [b: :base64, t: :template, n: :name],
      # A list of options in the schema that are required
      required: []
    }
  end

  @default_json_template """
  {
    "name": "something-new",
    "type": "preset",
    "files": [
      {
        "type": "component",
        "content": "",
        "name": "last_message",
        "from": "https://mishka.tools/example/template.json",
        "args": {
          "variant": [],
          "color": [],
          "size": [],
          "padding": [],
          "space": [],
          "type": [],
          "rounded": [],
          "only": [],
          "module": ""
        },
        "optional": [],
        "necessary": []
      }
    ]
  }
  """

  @impl Igniter.Mix.Task
  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {%{dir: dir}, argv} = positional_args!(argv)

    options = options!(argv)

    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.tools
      """

    IO.puts(IO.ANSI.yellow() <> String.trim_trailing(msg) <> IO.ANSI.reset())

    name = Keyword.get(options, :name, "template")

    igniter =
      if !File.dir?(dir),
        do: Igniter.add_issue(igniter, "The entered directory does not exist."),
        else: igniter

    # If user selects --template, it just creates a default JSON template
    if Keyword.get(options, :template, false) do
      Igniter.create_new_file(igniter, dir <> "/#{name}.json", @default_json_template,
        on_exists: :overwrite
      )
    else
      igniter
      |> Igniter.assign(%{cli_args: options, cli_dir: dir})
      |> check_dir_files()
      |> create_elixir_files_config()
      |> create_asset_files_config()
      |> create_json_file(name)
    end
  end

  defp check_dir_files(igniter) do
    with {:ls, {:ok, files_list}} <- {:ls, File.ls(igniter.assigns.cli_dir)},
         components <- Enum.filter(files_list, &(Path.extname(&1) in [".exs", ".eex"])),
         {:validate_files, {:ok, _}} <- {:validate_files, validate_files(components)},
         js_files <- Enum.filter(files_list, &(Path.extname(&1) == "js")) do
      # We could put the data instead of file path, but they were not clear to read
      igniter
      |> Igniter.assign(%{cli_files: [components | js_files]})
    else
      {:ls, {:error, errors}} ->
        igniter
        |> Igniter.add_issue("There is a problem with the directory. Errors: #{inspect(errors)}")

      {:validate_files, {:error, errors}} ->
        msg = """
        There are one or more problems with the file list.

        #{Enum.map(errors, fn {msg, value} -> "* #{"#{msg}"}: #{value}\n" end)}
        """

        Igniter.add_issue(igniter, msg)
    end
  end

  defp create_elixir_files_config(igniter) do
    # Check the `:cli_files` exist or not, it helps to skip File.read!
    cli_files = Map.get(igniter.assigns, :cli_files, false)

    if cli_files do
      configs =
        Enum.filter(cli_files, &(Path.extname(&1) in [".eex"]))
        |> Enum.reduce([], fn item, acc ->
          content = File.read!(item) |> Base.encode64()

          file_name = item |> Path.basename() |> Path.rootname()
          file_name_type = List.first(String.split(file_name, "_"))

          file_name_type =
            if file_name_type in ["component", "preset", "template"],
              do: file_name_type,
              else: "component"

          {_name, config} =
            Config.Reader.read!("#{String.replace_suffix(item, ".eex", ".exs")}")
            |> List.first()

          converted = %{
            type: file_name_type,
            name: config[:name],
            content: content,
            args: Enum.into(config[:args], %{}),
            optional: config[:optional],
            necessary: config[:necessary],
            scripts: config[:scripts]
          }

          [[converted] | acc]
        end)

      igniter
      |> Igniter.assign(%{cli_configs: configs})
    else
      igniter
    end
  rescue
    _ ->
      msg =
        "This error occurs when there is a problem with your .exs file configuration or the files cannot be accessed."

      Igniter.add_issue(igniter, msg)
  end

  defp create_asset_files_config(igniter) do
    cli_files = Map.get(igniter.assigns, :cli_files, false)

    if cli_files do
      configs =
        Enum.filter(cli_files, &(Path.extname(&1) in [".js"]))
        |> Enum.reduce([], fn item, acc ->
          content = File.read!(item) |> Base.encode64()
          file_name = item |> Path.basename() |> Path.rootname()

          converted = %{
            type: "javascript",
            name: file_name,
            content: content,
            args: %{},
            optional: [],
            necessary: [],
            scripts: []
          }

          [[converted] | acc]
        end)

      igniter
      |> Igniter.assign(%{cli_configs: cli_files ++ configs})
    else
      igniter
    end
  rescue
    _ ->
      msg =
        "This error occurs when there is a problem with your asset file or the files cannot be accessed."

      Igniter.add_issue(igniter, msg)
  end

  defp create_json_file(igniter, name) do
    dir = igniter.assigns.cli_dir

    igniter
    |> Igniter.create_new_file(dir <> "/#{name}.json", @default_json_template,
      on_exists: :overwrite
    )
  end

  def validate_files([]), do: {:error, :validate_files, "Empty directory"}

  def validate_files(components) do
    Enum.reduce(components, {:ok, []}, fn file, {status, errors} ->
      ext = Path.extname(file)

      cond do
        ext not in [".exs", ".eex"] ->
          {:error, [{"Invalid extension", file} | errors]}

        # The next two patterns are very easy to read. Refactor them when the goal is
        # not just to reduce code but also to make it simple.
        ext == ".exs" ->
          eex_file = Path.rootname(file) <> ".eex"

          if eex_file in components,
            do: {status, errors},
            else: {:error, [{".eex missing", eex_file} | errors]}

        ext == ".eex" ->
          exs_file = Path.rootname(file) <> ".exs"

          if exs_file in components,
            do: {status, errors},
            else: {:error, [{".exs missing", exs_file} | errors]}

        true ->
          {status, errors}
      end
    end)
  end
end
