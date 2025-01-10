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

    igniter =
      if !File.dir?(dir),
        do: Igniter.add_issue(igniter, "The entered directory does not exist."),
        else: igniter

    # If user selects --template, it just creates a default JSON template
    if Keyword.get(options, :template, false) do
      name = Keyword.get(options, :name, "template")

      json = """
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

      igniter
      |> Igniter.create_new_file(dir <> "/#{name}.json", json, on_exists: :overwrite)
    else
      igniter
      |> Igniter.add_warning("mix mishka.ui.export is not yet implemented")
    end
  end
end
