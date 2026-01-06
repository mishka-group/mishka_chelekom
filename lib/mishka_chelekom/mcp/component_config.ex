defmodule MishkaChelekom.MCP.ComponentConfig do
  @moduledoc """
  Reads component configurations from priv/components/*.exs files.

  This module provides dynamic access to all component metadata including
  names, categories, colors, variants, sizes, and other configuration options.
  """

  @doc """
  Returns the path to the components directory.
  """
  def components_path do
    :code.priv_dir(:mishka_chelekom)
    |> Path.join("components")
  end

  @doc """
  Loads and returns all component configurations.

  Returns a list of `{name, config}` tuples where config is a keyword list.
  """
  def load_all do
    path = components_path()

    if File.exists?(path) do
      path
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".exs"))
      |> Enum.map(fn file ->
        file_path = Path.join(path, file)

        try do
          {[{name, config}], _} = Code.eval_file(file_path)
          {name, config}
        rescue
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(fn {name, _} -> to_string(name) end)
    else
      []
    end
  end

  @doc """
  Returns all components with their metadata.

  Returns a list of maps with keys: name, category, generator, docs
  """
  def list_components do
    load_all()
    |> Enum.map(fn {name, config} ->
      name_str = to_string(name)

      %{
        name: name_str,
        category: Keyword.get(config, :category, "general"),
        generator: "mix mishka.ui.gen.component #{name_str}",
        docs: Keyword.get(config, :doc_url, "https://mishka.tools/chelekom/docs/#{name_str}")
      }
    end)
  end

  @doc """
  Returns the documentation URL for a specific component.

  Looks up the doc_url from the component config, or generates a default URL.
  """
  def get_doc_url(name) when is_binary(name) do
    case get_component(name) do
      nil ->
        # Default URL for unknown components
        url_name = String.replace(name, "_", "-")
        "https://mishka.tools/chelekom/docs/#{url_name}"

      config ->
        Keyword.get(
          config,
          :doc_url,
          "https://mishka.tools/chelekom/docs/#{String.replace(name, "_", "-")}"
        )
    end
  end

  @doc """
  Returns a map of all component names to their doc URLs.
  """
  def list_doc_urls do
    load_all()
    |> Enum.map(fn {name, config} ->
      name_str = to_string(name)
      url = Keyword.get(config, :doc_url, "https://mishka.tools/chelekom/docs/#{name_str}")
      {name_str, url}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns all unique categories from component configs.
  """
  def list_categories do
    load_all()
    |> Enum.map(fn {_name, config} -> Keyword.get(config, :category, "general") end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns components grouped by category.
  """
  def components_by_category do
    load_all()
    |> Enum.group_by(
      fn {_name, config} -> Keyword.get(config, :category, "general") end,
      fn {name, _config} -> to_string(name) end
    )
    |> Enum.into(%{})
  end

  @doc """
  Returns all unique colors from all component configs.
  """
  def list_colors do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:color, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique variants from all component configs.
  """
  def list_variants do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:variant, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique sizes from all component configs.
  """
  def list_sizes do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:size, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique rounded options from all component configs.
  """
  def list_rounded do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:rounded, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique padding options from all component configs.
  """
  def list_padding do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:padding, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique space options from all component configs.
  """
  def list_spaces do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:space, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all scripts/JS dependencies from all component configs.

  Returns a list of maps with component name and its scripts.
  """
  def list_scripts do
    load_all()
    |> Enum.map(fn {name, config} ->
      scripts = Keyword.get(config, :scripts, [])
      {to_string(name), scripts}
    end)
    |> Enum.filter(fn {_name, scripts} -> scripts != [] end)
    |> Enum.into(%{})
  end

  @doc """
  Returns all unique script files across all components.
  """
  def list_unique_scripts do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      Keyword.get(config, :scripts, [])
    end)
    |> Enum.uniq_by(fn script -> script[:file] || script.file end)
  end

  @doc """
  Returns components with their dependencies (necessary and optional).

  Returns a map with component names as keys and dependency info as values.
  """
  def list_dependencies do
    load_all()
    |> Enum.map(fn {name, config} ->
      necessary = Keyword.get(config, :necessary, [])
      optional = Keyword.get(config, :optional, [])

      {to_string(name),
       %{
         necessary: necessary,
         optional: optional
       }}
    end)
    |> Enum.filter(fn {_name, deps} ->
      deps.necessary != [] or deps.optional != []
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns all unique necessary dependencies across all components.
  """
  def list_necessary_deps do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      Keyword.get(config, :necessary, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns all unique optional dependencies across all components.
  """
  def list_optional_deps do
    load_all()
    |> Enum.flat_map(fn {_name, config} ->
      Keyword.get(config, :optional, [])
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Gets configuration for a specific component.
  """
  def get_component(name) when is_binary(name) do
    get_component(String.to_atom(name))
  end

  def get_component(name) when is_atom(name) do
    load_all()
    |> Enum.find(fn {n, _} -> n == name end)
    |> case do
      {_name, config} -> config
      nil -> nil
    end
  end

  @doc """
  Returns the actual count of components based on the `only:` field in each config.

  Some .exs files contain multiple components (e.g., button has button and button_group).
  This counts the actual number of components, not just config files.
  """
  def count_actual_components do
    load_all()
    |> Enum.map(fn {_name, config} ->
      config
      |> Keyword.get(:args, [])
      |> Keyword.get(:only, [])
      |> length()
    end)
    |> Enum.sum()
  end

  @doc """
  Returns all JS hooks from priv/assets/js directory.
  """
  def list_js_hooks do
    js_path = :code.priv_dir(:mishka_chelekom) |> Path.join("assets/js")

    if File.exists?(js_path) do
      js_path
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".js"))
      |> Enum.map(fn file ->
        name = Path.rootname(file)

        %{
          file: file,
          name: name,
          module: Macro.camelize(name),
          path: "priv/assets/js/#{file}"
        }
      end)
      |> Enum.sort_by(& &1.name)
    else
      []
    end
  end
end
