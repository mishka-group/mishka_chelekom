defmodule Mix.Tasks.Mishka.Ui.Add do
  use Igniter.Mix.Task
  use GuardedStruct
  alias GuardedStruct.Derive.ValidationDerive

  @community_url "https://api.github.com/repos/shahryarjb/test/contents/"

  @github_domains [
    github: "github.com",
    gist: "gist.github.com",
    gist_content: "gist.githubusercontent.com",
    github_raw: "raw.githubusercontent.com"
  ]

  @domain_types [:url] ++ Keyword.keys(@github_domains)

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

  * `--no-github` or `-v` - Specifies a URL without github replacing
  """
  # TODO: headers
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
        field(:helpers, list(String.t()), derive: "validate(list)", default: [])

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
      schema: [no_github: :boolean],
      # CLI aliases
      aliases: []
    }
  end

  def igniter(igniter, argv) do
    Application.ensure_all_started(:req)
    Application.ensure_all_started(:owl)
    # extract positional arguments according to `positional` above
    {%{repo: repo}, argv} = positional_args!(argv)

    options = options!(argv)

    msg =
      """
            .-.
           /'v'\\
          (/   \\)
          =="="==
        Mishka.tools
      """

    IO.puts(IO.ANSI.blue() <> String.trim_trailing(msg) <> IO.ANSI.reset())

    Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

    {url, repo_action, igniter} =
      Keyword.get(options, :no_github, false)
      |> then(&repo_url(String.trim(repo), igniter, &1))

    final_igniter =
      if url != "none_url_error" do
        resp = Req.get!(url)

        igniter =
          with %Req.Response{status: 200, body: body} <- resp,
               {:ok, igniter, decoded_body} <-
                 convert_request_body(body, repo_action, igniter),
               {:ok, params} <- __MODULE__.builder(decoded_body) do
            params = Map.merge(params, %{from: String.trim(repo)})

            Enum.reduce(params.files, igniter, fn item, acc ->
              args =
                if is_struct(item.args),
                  do:
                    item.args
                    |> Map.from_struct()
                    |> Map.to_list()
                    |> Enum.reject(
                      &(match?({_, []}, &1) and elem(&1, 0) not in [:only, :helpers])
                    )
                    |> Enum.sort(),
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

              decode! =
                case Base.decode64(item.content) do
                  :error -> item.content
                  {:ok, content} -> content
                end

              acc
              |> Igniter.create_new_file(direct_path <> ".eex", decode!, on_exists: :overwrite)
              |> Igniter.create_new_file(direct_path <> ".exs", "#{inspect(config)}",
                on_exists: :overwrite
              )
            end)
          else
            %Req.Response{status: 404} ->
              msg = "The link or repo name entered is wrong."
              show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})

            {:error, errors} ->
              show_errors(igniter, errors)
          end

        igniter
      else
        igniter
      end

    if Map.get(final_igniter, :issues, []) == [],
      do: Owl.Spinner.stop(id: :my_spinner, resolution: :ok, label: "Done"),
      else: Owl.Spinner.stop(id: :my_spinner, resolution: :error, label: "Error")

    final_igniter
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

  defp show_errors(igniter, errors) when is_non_struct_map(errors) do
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

  defp repo_url("component-" <> _name = file_name, igniter, _github?) do
    {Path.join(@community_url, ["components", "/#{file_name}.json"]), :community, igniter}
  end

  defp repo_url("preset-" <> _name = file_name, igniter, _github?) do
    {Path.join(@community_url, ["presets", "/#{file_name}.json"]), :community, igniter}
  end

  defp repo_url("template-" <> _name = file_name, igniter, _github?) do
    {Path.join(@community_url, ["templates", "/#{file_name}.json"]), :community, igniter}
  end

  defp repo_url(repo, igniter, github?) do
    ValidationDerive.validate(:url, repo, :repo)
    |> case do
      {:error, :repo, :url, msg} ->
        {"none_url_error",
         show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})}

      url when is_binary(url) ->
        type = external_url_type(url)

        converted_url =
          if type == :github and !github?,
            do:
              String.replace(url, "github.com", "api.github.com/repos")
              |> String.replace(~r{/blob/[^/]+/}, "/contents/"),
            else: url

        {converted_url, type, igniter}
    end
  end

  defp external_url_type(url) do
    with %URI{scheme: "https", host: host} <- URI.parse(url),
         data when not is_nil(data) <- Enum.find(@github_domains, &match?({_, ^host}, &1)) do
      elem(data, 0)
    else
      _ -> :url
    end
  end

  defp convert_request_body(body, :community, igniter) do
    with body_content <- String.replace(body["content"], ~r/\s+/, ""),
         {:base64, {:ok, decoded_body}} <- {:base64, Base.decode64(body_content)},
         {:json, {:ok, json_decoded_body}} <- {:json, Jason.decode(decoded_body)} do
      {:ok, igniter, json_decoded_body}
    else
      {:base64, _error} ->
        msg = "There is a problem in converting Base64 text to Elixir structure."
        show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})

      {:json, _error} ->
        msg = "There is a problem in converting JSON to Elixir structure."
        show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})
    end
  end

  defp convert_request_body(body, url, igniter) when url in @domain_types do
    Owl.Spinner.stop(id: :my_spinner, resolution: :ok)

    case Igniter.Util.IO.yes?(external_call_warning()) do
      false ->
        Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])
        {:error, "The operation was stopped at your request."}

      true ->
        Owl.Spinner.start(id: :my_spinner, labels: [processing: "Please wait..."])

        if url == :github,
          do: convert_request_body(body, :community, igniter),
          else: {:ok, igniter, body}
    end
  end

  defp external_call_warning() do
    """
    #{IO.ANSI.red()}#{IO.ANSI.bright()}#{IO.ANSI.underline()}This is a security message, please pay attention to it!!!#{IO.ANSI.reset()}

    #{IO.ANSI.yellow()}You are directly requesting from an address that the Mishka team cannot validate.
    Therefore, if you are not sure about the source, do not download it.
    If needed, please refer to the link below. This is a security warning, so take it seriously.

    Ref: https://mishka.tools/chelekom/docs/security#{IO.ANSI.reset()}

    #{IO.ANSI.red()}#{IO.ANSI.bright()}Do you want to continue?#{IO.ANSI.reset()}
    """
  end
end
