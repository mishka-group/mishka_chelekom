defmodule MishkaChelekom.Generators.Core do
  @moduledoc """
  Shared generator plumbing used by the styled (`mix mishka.ui.gen.component(s)`) and
  headless (`mix mishka.ui.gen.headless`) tasks.

  The single most important responsibility here is **resolving the library's own `priv/`
  directory robustly**. The original tasks hardcoded string paths like
  `"deps/mishka_chelekom/priv/components/<name>.eex"`, which do not exist when the library
  is consumed as a `path:` dependency (path deps are not materialised into `deps/`) or in an
  umbrella. `lib_priv/1` resolves via `:code.priv_dir/1` (the canonical, env-agnostic way —
  already used by `MishkaChelekom.Config`) and only falls back to the legacy `deps/` string
  when the application priv dir cannot be located.

  This change is a pure relocation of *where templates/assets are read from*; it does not
  change generated component output (the resolved files are identical for hex-dep installs).
  """

  @doc """
  Returns the absolute path to the library's `priv/` directory.

  Prefers `:code.priv_dir(:mishka_chelekom)` (works for hex deps, path deps, and umbrellas),
  falling back to the legacy `"deps/mishka_chelekom/priv"` string only if the app priv dir
  is unavailable.
  """
  @spec lib_priv_dir() :: String.t()
  def lib_priv_dir do
    case :code.priv_dir(:mishka_chelekom) do
      {:error, _} ->
        "deps/mishka_chelekom/priv"

      dir ->
        dir = to_string(dir)
        if File.dir?(dir), do: dir, else: "deps/mishka_chelekom/priv"
    end
  end

  @doc """
  Joins a sub-path onto the library `priv/` dir.

      iex> MishkaChelekom.Generators.Core.lib_priv("components/button.eex")
  """
  @spec lib_priv(String.t()) :: String.t()
  def lib_priv(sub), do: Path.join(lib_priv_dir(), sub)

  @doc """
  The catalog template directories searched for a component name, in priority order.

  `kind` selects the layer:

    * `:styled`   → `priv/components`
    * `:headless` → `priv/headless`

  Custom user templates (host-app `priv/mishka_chelekom/{components,templates,presets}`) are
  honoured by the styled task via its name-prefix routing and are not affected here.
  """
  @spec template_dir(:styled | :headless) :: String.t()
  def template_dir(:styled), do: lib_priv("components")
  def template_dir(:headless), do: lib_priv("headless")

  @doc """
  Validates that a loaded catalog config has the minimal expected shape, returning
  `{:ok, config}` or `{:error, reason}`. Guards against a malformed `.exs` silently
  producing a broken component.
  """
  @spec validate_catalog(term()) :: {:ok, keyword()} | {:error, String.t()}
  def validate_catalog(config) when is_list(config) do
    cond do
      !Keyword.keyword?(config) ->
        {:error, "catalog config must be a keyword list"}

      !is_binary(config[:name]) ->
        {:error, "catalog is missing a string :name"}

      config[:args] != nil and !Keyword.keyword?(config[:args]) ->
        {:error, ":args must be a keyword list of dimension => allowed-values"}

      true ->
        {:ok, config}
    end
  end

  def validate_catalog(_), do: {:error, "catalog config must be a keyword list"}
end
