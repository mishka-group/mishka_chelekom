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


  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--base64` or `-b` - Converts component content to Base64
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
      schema: [base64: :boolean, template: :boolean],
      # Default values for the options in the `schema`
      defaults: [],
      # CLI aliases
      aliases: [b: :base64, t: :template],
      # A list of options in the schema that are required
      required: []
    }
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    # Do your work here and return an updated igniter
    igniter
    |> Igniter.add_warning("mix mishka.ui.export is not yet implemented")
  end
end
