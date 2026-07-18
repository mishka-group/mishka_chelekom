defmodule MishkaChelekom.CatalogIntegrityTest do
  @moduledoc """
  Cross-catalog invariants for every `priv/{components,headless}/*.exs`.

  Everything here is derived from the filesystem, so a new component is covered the moment its
  catalog lands — no list to keep in sync. These are the mistakes that produce a component which
  generates cleanly and then fails at runtime in the consumer's app, where we never see it.
  """
  use ExUnit.Case, async: true

  @catalogs Path.wildcard("priv/{components,headless}/*.exs")
  @templates Path.wildcard("priv/{components,headless}/*.eex")
  @engines Path.wildcard("priv/assets/js/*.js") |> Enum.map(&Path.basename/1)

  # Permissive only. A copyleft or license-key-gated package would put a legal or blank-page
  # burden on every consumer who generates the component.
  @permissive ~w(MIT Apache-2.0 BSD-2-Clause BSD-3-Clause ISC)

  defp config(path) do
    name = Path.basename(path, ".exs")
    {name, Config.Reader.read!(path)[String.to_atom(name)]}
  end

  defp configs, do: Enum.map(@catalogs, &config/1)

  defp configs_with(key) do
    configs()
    |> Enum.filter(fn {_name, cfg} -> is_list(cfg) and Keyword.get(cfg, key, []) != [] end)
  end

  test "there are catalogs to check" do
    assert length(@catalogs) > 50,
           "the wildcard matched nothing — every test here would vacuously pass"

    assert length(@templates) > 50
  end

  test "every template has a catalog and every catalog has a template" do
    templates = MapSet.new(@templates, &Path.rootname/1)
    catalogs = MapSet.new(@catalogs, &Path.rootname/1)

    assert MapSet.difference(templates, catalogs) |> MapSet.to_list() == [],
           "these .eex templates have no sibling .exs catalog"

    assert MapSet.difference(catalogs, templates) |> MapSet.to_list() == [],
           "these .exs catalogs have no sibling .eex template"
  end

  test "every catalog is a keyword list keyed by its own filename" do
    for path <- @catalogs do
      {name, cfg} = config(path)

      assert is_list(cfg), "#{path}: no #{name}: entry (the key must match the filename)"
      assert Keyword.get(cfg, :name) == name, "#{path}: :name must equal the filename"
    end
  end

  describe "JS engines" do
    test "every declared script file exists in priv/assets/js" do
      missing =
        for {name, cfg} <- configs(),
            script <- Keyword.get(cfg, :scripts, []),
            script[:type] == "file" or script.type == "file",
            script.file not in @engines,
            do: "#{name} -> #{script.file}"

      assert missing == [], "catalogs reference JS engines that do not exist: #{inspect(missing)}"
    end

    test "every script's import statement references its own file" do
      wrong =
        for {name, cfg} <- configs(),
            script <- Keyword.get(cfg, :scripts, []),
            not String.contains?(script.imports, script.file),
            do: "#{name}: imports #{inspect(script.imports)} but file is #{script.file}"

      assert wrong == [], Enum.join(wrong, "\n")
    end
  end

  describe "npm-backed components" do
    test "every npm entry pins an exact version" do
      bad =
        for {name, cfg} <- configs_with(:npm),
            dep <- cfg[:npm],
            not (is_map(dep) and is_binary(dep[:name]) and
                   is_binary(dep[:version]) and dep[:version] =~ ~r/^\d+\.\d+\.\d+$/),
            do: "#{name} -> #{inspect(dep)}"

      assert bad == [],
             "npm deps must be %{name: _, version: \"x.y.z\"} with an EXACT version — a caret " <>
               "range lets peer-pinned packages drift apart (e.g. two prosemirror-model copies, " <>
               "which fails at runtime, not at install). Offenders: #{inspect(bad)}"
    end

    test "every npm-backed catalog declares a permissive license" do
      for {name, cfg} <- configs_with(:npm) do
        license = Keyword.get(cfg, :license, [])

        assert license != [], "#{name}: an npm-backed component must declare license: [spdx: ...]"

        assert license[:spdx] in @permissive,
               "#{name}: license #{inspect(license[:spdx])} is not one of #{inspect(@permissive)}"
      end
    end

    test "npm-backed catalogs are reachable by the generator's resolver" do
      for {name, cfg} <- configs_with(:npm) do
        assert MishkaChelekom.Generators.Assets.npm_packages(cfg) != [],
               "#{name}: declares :npm but Assets.npm_packages/1 resolves nothing"
      end
    end
  end

  describe "multi-engine (libs) components" do
    test "every libs entry shares one hook module, so the markup is engine-independent" do
      for {name, cfg} <- configs_with(:libs) do
        modules =
          cfg[:libs]
          |> Enum.flat_map(fn {_lib, opts} -> Keyword.get(opts, :scripts, []) end)
          |> Enum.map(& &1.module)
          |> Enum.uniq()

        assert length(modules) <= 1,
               "#{name}: libs declare hook modules #{inspect(modules)}. Every engine must register " <>
                 "the same hook name, or the template would have to branch per library."
      end
    end

    test "exactly one libs entry is the default" do
      for {name, cfg} <- configs_with(:libs) do
        defaults =
          cfg[:libs]
          |> Enum.filter(fn {_lib, opts} -> Keyword.get(opts, :default, false) end)
          |> Enum.map(&elem(&1, 0))

        assert length(defaults) == 1,
               "#{name}: expected exactly one default lib, got #{inspect(defaults)}"
      end
    end

    test "every libs engine file exists" do
      missing =
        for {name, cfg} <- configs_with(:libs),
            {lib, opts} <- cfg[:libs],
            script <- Keyword.get(opts, :scripts, []),
            script.file not in @engines,
            do: "#{name}/#{lib} -> #{script.file}"

      assert missing == [], "libs reference JS engines that do not exist: #{inspect(missing)}"
    end
  end
end
