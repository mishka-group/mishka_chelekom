defmodule Mix.Tasks.Mishka.Ui.Add do
  # TODO: Handle JS side for external repo and add it to user project
  use Igniter.Mix.Task
  use GuardedStruct
  alias GuardedStruct.Derive.ValidationDerive

  @community_url "https://api.github.com/repos/mishka-group/mishka_chelekom_community/contents/"

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

  This section is part of the CLI community version, which allows you to download components,
  templates, and presets from another repository and add them to the `priv` directory of
  your project—without requiring any additional plugins.
  Additionally, you can specify your own custom URLs to share components you've developed
  with your team. This CLI provides functionalities to facilitate such sharing.
  For more details, please refer to the documentation on the https://mishka.tools/chelekom website.

  **Official Library Repository**:
  - https://github.com/mishka-group/mishka_chelekom

  **Official Community Version Repository**:
  - https://github.com/mishka-group/mishka_chelekom_community

  **Important Notice:**:
  > Several sections in the documentation on Mishka.tools, as well as individual tasks,
  > address security concerns. Since you are integrating an external component,
  > it is crucial to verify the source from which the file is being imported.
  > Please note that all responsibility for this integration lies with you.


  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--no-github` - Specifies a URL without github replacing
  * `--headers` - Specifies a repo url request headers
  """
  guardedstruct do
    field(:name, String.t(),
      derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=80, min_len=3)",
      enforce: true
    )

    field(:type, String.t(),
      derive:
        "sanitize(tag=strip_tags) validate(enum=String[component::preset::template::javascript])",
      enforce: true
    )

    conditional_field(:components, list(String.t()),
      structs: true,
      derive: "validate(list)",
      default: []
    ) do
      field(:components, String.t(),
        derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)"
      )
    end

    sub_field(:files, list(map()),
      structs: true,
      validator: {Mix.Tasks.Mishka.Ui.Add, :uniq_components?},
      default: []
    ) do
      field(:type, String.t(),
        derive:
          "sanitize(tag=strip_tags) validate(enum=String[component::preset::template::javascript])",
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
          derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)"
        )
      end

      conditional_field(:necessary, list(String.t()),
        structs: true,
        derive: "validate(list)",
        default: []
      ) do
        field(:necessary, String.t(),
          derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=25, min_len=3)"
        )
      end

      conditional_field(:scripts, list(String.t()),
        structs: true,
        derive: "validate(list)",
        default: []
      ) do
        field(:scripts, map(), derive: "validate(map)")
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
        field(:helpers, list(String.t()), derive: "validate(map)", default: %{})
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
      schema: [no_github: :boolean, headers: :keep],
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
        resp =
          Req.new()
          |> Req.Request.prepend_response_steps(
            noop: fn {req, res} ->
              is_text_plain? = res.headers["content-type"] == ["text/plain; charset=utf-8"]

              if repo_action in [:gist_content, :github_raw] and
                   !Keyword.get(options, :no_github, false) and is_text_plain? do
                {converted_req, converted_res} = Req.Steps.decompress_body({req, res})
                {converted_req, update_in(converted_res.body, &Jason.decode!/1)}
              else
                {req, res}
              end
            end
          )
          |> Req.get!(url: url, headers: convert_headers(Keyword.get(options, :headers, [])))

        igniter =
          with %Req.Response{status: 200, body: body} <- resp,
               {:ok, igniter, decoded_body} <-
                 convert_request_body(body, repo_action, igniter),
               {:ok, params} <- __MODULE__.builder(decoded_body) do
            create_requested_files(igniter, params, repo)
          else
            %Req.Response{status: 404} ->
              msg = "The link or repo name entered is wrong."
              show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})

            %Req.Response{status: 401} ->
              msg = "Unauthorized: Access denied. Please check your credentials."
              show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})

            {:error, errors} ->
              show_errors(igniter, errors)
          end

        igniter
      else
        with {:file, {:ok, file}} <- {:file, File.read(String.trim(repo))},
             {:json, {:ok, decoded_body}} <- {:json, Jason.decode(file)},
             {:builder, {:ok, params}} <- {:builder, __MODULE__.builder(decoded_body)} do
          create_requested_files(igniter, params, repo)
        else
          {:file, {:error, _result}} ->
            msg = "Unfortunately, the file cannot be accessed."
            show_errors(igniter, %{fields: :path, message: msg, action: :get_repo})

          {:json, {:error, _result}} ->
            msg = "There was a problem reading the JSON file. Please ensure the file is correct."
            show_errors(igniter, %{fields: :path, message: msg, action: :get_repo})

          {:builder, {:error, errors}} ->
            show_errors(igniter, errors)
        end
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

  defp repo_url("component_" <> name, igniter, _github?) do
    {Path.join(@community_url, ["components", "/#{name}.json"]), :community, igniter}
  end

  defp repo_url("preset_" <> name, igniter, _github?) do
    {Path.join(@community_url, ["presets", "/#{name}.json"]), :community, igniter}
  end

  defp repo_url("template_" <> name, igniter, _github?) do
    {Path.join(@community_url, ["templates", "/#{name}.json"]), :community, igniter}
  end

  defp repo_url(repo, igniter, github?) do
    ValidationDerive.validate(:url, repo, :repo)
    |> case do
      {:error, :repo, :url, msg} ->
        if File.exists?(repo) do
          {"none_url_error", :url, igniter}
        else
          {"none_url_error", :url,
           show_errors(igniter, %{fields: :repo, message: msg, action: :get_repo})}
        end

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

  def convert_headers(headers_list) do
    headers_list
    |> Enum.map(fn item ->
      [key, value] = String.split(item, ": ")
      {String.trim(key), String.trim(value)}
    end)
  end

  defp create_requested_files(igniter, params, repo) do
    params = Map.merge(params, %{from: String.trim(repo)})

    Enum.reduce(params.files, igniter, fn item, acc ->
      args =
        if is_struct(item.args) do
          item.args
          |> Map.from_struct()
          |> Map.merge(%{helpers: Map.to_list(item.args.helpers)})
          |> Map.to_list()
          |> Enum.reject(&(match?({_, []}, &1) and elem(&1, 0) not in [:only, :helpers]))
          |> Enum.sort()
        else
          []
        end

      direct_path =
        File.cwd!()
        |> Path.join(["priv", "/mishka_chelekom", "/#{item.type}s", "/#{item.name}"])

      decode! =
        case Base.decode64(item.content) do
          :error -> item.content
          {:ok, content} -> content
        end

      if item.type == "javascript" do
        acc
        |> Igniter.create_new_file(direct_path <> ".js", decode!, on_exists: :overwrite)
      else
        config =
          [
            {String.to_atom(item.name),
             [
               name: item.name,
               args: args,
               optional: item.optional,
               necessary: item.necessary,
               scripts: item.scripts
             ]}
          ]
          |> Enum.into([])

        acc
        |> Igniter.create_new_file(direct_path <> ".eex", decode!, on_exists: :overwrite)
        |> Igniter.create_new_file(direct_path <> ".exs", "#{inspect(config)}",
          on_exists: :overwrite
        )
      end
    end)
  end
end
