defmodule MishkaChelekom.MCP.PathHelper do
  @moduledoc """
  Helper module for resolving file paths that works both when:
  1. Running directly inside the mishka_chelekom library (development/testing)
  2. Installed as a dependency in a user's Phoenix project

  Uses `:code.priv_dir/1` for installed dependency, falls back to local paths for development.
  """

  @doc """
  Returns the package root directory for mishka_chelekom.
  This is where usage-rules/ folder is located.

  In development: returns File.cwd!() since we're working in the source tree
  As dependency: returns the deps path where usage-rules/ is located
  """
  def package_root do
    # First check if we're in development mode (source directory has usage-rules/)
    source_usage_rules = Path.join(File.cwd!(), "usage-rules")

    if File.dir?(source_usage_rules) do
      # Development mode - working in the library source
      File.cwd!()
    else
      # Installed as dependency - find package in deps
      case :code.priv_dir(:mishka_chelekom) do
        {:error, :bad_name} ->
          # Fallback to deps path
          Path.join([File.cwd!(), "deps", "mishka_chelekom"])

        path when is_list(path) ->
          # priv_dir returns priv/, go up one level to get package root
          path
          |> List.to_string()
          |> Path.dirname()
      end
    end
  end

  @doc """
  Returns the priv directory path for mishka_chelekom.
  Works both in development and when installed as a dependency.
  """
  def priv_dir do
    case :code.priv_dir(:mishka_chelekom) do
      {:error, :bad_name} ->
        # Fallback for development - check local priv directory
        local_priv = Path.join(File.cwd!(), "priv")

        if File.dir?(local_priv) do
          local_priv
        else
          # Last resort - try deps path
          Path.join([File.cwd!(), "deps", "mishka_chelekom", "priv"])
        end

      path when is_list(path) ->
        List.to_string(path)
    end
  end

  @doc """
  Returns the path to usage-rules directory.
  Located at package root, not inside priv.
  """
  def usage_rules_dir do
    Path.join(package_root(), "usage-rules")
  end

  @doc """
  Returns the path to a component documentation file in usage-rules/components/.
  """
  def component_doc_path(name) do
    Path.join([usage_rules_dir(), "components", "#{name}.md"])
  end

  @doc """
  Returns the path to a JS hook documentation file in usage-rules/js/.
  """
  def js_hook_doc_path(name) do
    Path.join([usage_rules_dir(), "js", "#{name}.md"])
  end

  @doc """
  Returns the path to a library documentation file in usage-rules/docs/.
  """
  def lib_doc_path(filename) do
    Path.join([usage_rules_dir(), "docs", filename])
  end

  @doc """
  Returns the path to mix-tasks.md documentation.
  """
  def mix_tasks_doc_path do
    Path.join(usage_rules_dir(), "mix-tasks.md")
  end

  @doc """
  Returns the path to a component config file in priv/components/.
  """
  def component_config_path(name) do
    Path.join([priv_dir(), "components", "#{name}.exs"])
  end

  @doc """
  Returns the path to the user's config file in their project.
  This always uses File.cwd!() since it's in the user's project, not the library.
  """
  def user_config_path do
    Path.join([File.cwd!(), "priv", "mishka_chelekom", "config.exs"])
  end

  @doc """
  Checks if a file exists at the given path.
  """
  def file_exists?(path) do
    File.exists?(path)
  end

  @doc """
  Reads a file, returning {:ok, content} or {:error, reason}.
  """
  def read_file(path) do
    File.read(path)
  end
end
