defmodule MishkaChelekom.CatalogIntegrityTest do
  @moduledoc """
  Cross-catalog invariants for every `priv/{components,headless}/*.exs`, and the docs facts every
  `.exs` under `priv` declares, Mob's included.

  Everything here is derived from the filesystem, so a new component is covered the moment its
  catalog lands — no list to keep in sync. These are the mistakes that produce a component which
  generates cleanly and then fails at runtime in the consumer's app, where we never see it.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.MCP.ComponentConfig

  @catalogs Path.wildcard("priv/{components,headless}/*.exs")
  @templates Path.wildcard("priv/{components,headless}/*.eex")
  @engines Path.wildcard("priv/assets/js/*.js") |> Enum.map(&Path.basename/1)

  # Every options file under `priv`, Mob's included: each declares its docs facts.
  @documented Path.wildcard("priv/**/*.exs")

  # The facts of a catalog's `docs:` block, in the order it writes them.
  @docs_facts [:stateful, :js_module, :js, :accessible]

  # Permissive only. A copyleft or license-key-gated package would put a legal or blank-page
  # burden on every consumer who generates the component.
  @permissive ~w(MIT Apache-2.0 BSD-2-Clause BSD-3-Clause ISC)

  defp config(path) do
    name = Path.basename(path, ".exs")
    {name, Config.Reader.read!(path)[String.to_atom(name)]}
  end

  defp configs, do: Enum.map(@catalogs, &config/1)

  @inline_styles [
    {~r/createElement\(\s*["'`]style["'`]/, "creates a <style> element"},
    {~r/setAttribute\(\s*["'`]style["'`]/, "sets a style attribute"},
    {~r/<style[\s>]/, "writes a <style> tag"},
    {~r/\sstyle=\\?["'`]/, "writes a style attribute into markup"}
  ]

  defp strip_comments(source) do
    source
    |> String.replace(~r{/\*.*?\*/}s, "")
    |> String.replace(~r{^\s*//.*$}m, "")
  end

  defp configs_with(key) do
    configs()
    |> Enum.filter(fn {_name, cfg} -> is_list(cfg) and Keyword.get(cfg, key, []) != [] end)
  end

  test "there are catalogs to check" do
    styled = Enum.map(ComponentConfig.component_names(), &"priv/components/#{&1}.exs")

    headless =
      Enum.map(Core.all_component_names(Igniter.new(), :headless), &"priv/headless/#{&1}.exs")

    assert length(@catalogs) > 50,
           "the wildcard matched nothing — every test here would vacuously pass"

    assert length(@templates) > 50

    assert Enum.sort(@catalogs) == Enum.sort(styled ++ headless),
           "the wildcard and the library disagree about which catalogs ship"
  end

  test "every template has a catalog and every catalog has a template" do
    templates = MapSet.new(@templates, &Path.rootname/1)
    catalogs = MapSet.new(@catalogs, &Path.rootname/1)

    assert MapSet.difference(templates, catalogs) |> MapSet.to_list() == [],
           "these .eex templates have no sibling .exs catalog"

    assert MapSet.difference(catalogs, templates) |> MapSet.to_list() == [],
           "these .exs catalogs have no sibling .eex template"

    # The generators' own resolver needs both files, so each name it lists must resolve.
    igniter = Igniter.new()

    for layer <- [:styled, :headless], name <- Core.all_component_names(igniter, layer) do
      assert {:ok, %{component: ^name}} = Core.fetch_catalog(igniter, name, layer)
    end
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
            installed = Map.get(script, :as, script.file),
            not String.contains?(script.imports, installed),
            do: "#{name}: imports #{inspect(script.imports)} but installs as #{installed}"

      assert wrong == [], Enum.join(wrong, "\n")
    end

    # A Content Security Policy whose style-src has no 'unsafe-inline' refuses a <style> element and a
    # style attribute, whether written as markup or set with setAttribute. Styles set through the
    # CSSOM (`el.style.x`, `style.cssText`, `setProperty`, an adopted stylesheet) are not refused.
    test "no engine writes a <style> element or a style attribute" do
      found =
        for file <- @engines,
            {pattern, what} <- @inline_styles,
            Path.join("priv/assets/js", file) |> File.read!() |> strip_comments() =~ pattern,
            do: "#{file} #{what}"

      assert found == [], Enum.join(found, "\n")
    end

    test "nor does the JS the CMS kits ship" do
      found =
        for kit <- Path.wildcard("priv/cms_ui_kits/*.json"),
            hook <- kit |> File.read!() |> Jason.decode!() |> Map.fetch!("js_hooks"),
            content <- [hook["content"] | Enum.map(hook["modules"] || [], & &1["content"])],
            {pattern, what} <- @inline_styles,
            strip_comments(content) =~ pattern,
            do: "#{Path.basename(kit)} #{hook["name"]} #{what}"

      assert found == [], Enum.join(found, "\n")
    end
  end

  describe "developer-owned files" do
    test "every declared user file exists in priv/assets/js" do
      missing =
        for {name, cfg} <- configs_with(:user_files),
            item <- cfg[:user_files],
            item.file not in @engines,
            do: "#{name} -> #{item.file}"

      assert missing == [], "catalogs declare user files that do not exist: #{inspect(missing)}"
    end

    test "a user file is never also a script (it must never be regenerated)" do
      for {name, cfg} <- configs_with(:user_files) do
        scripts = cfg |> Keyword.get(:scripts, []) |> Enum.map(& &1.file)
        users = cfg[:user_files] |> Enum.map(& &1.file)

        assert users -- scripts == users,
               "#{name}: #{inspect(users -- (users -- scripts))} is declared as BOTH a script and " <>
                 "a user file — it would be overwritten on every regeneration"
      end
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

  # A catalog and its `docs:` block, `nil` for either it does not have.
  defp docs(path) do
    {_name, cfg} = config(path)
    {cfg, if(is_list(cfg), do: Keyword.get(cfg, :docs))}
  end

  defp fact(docs, fact) when is_list(docs), do: Keyword.get(docs, fact)
  defp fact(_docs, _fact), do: nil

  defp scripts(cfg) when is_list(cfg) do
    libs = Enum.flat_map(cfg[:libs] || [], fn {_lib, opts} -> opts[:scripts] || [] end)
    (cfg[:scripts] || []) ++ libs
  end

  defp scripts(_cfg), do: []

  defp live_component?(path),
    do: File.read!(Path.rootname(path) <> ".eex") =~ ~r/use\s+Phoenix\.LiveComponent\b/

  describe "docs facts" do
    test "there are options files to check, of all three layers" do
      igniter = Igniter.new()

      shipped =
        for layer <- [:styled, :headless, :mob],
            name <- Core.all_component_names(igniter, layer),
            do: "priv/#{Path.basename(Core.template_dir(layer))}/#{name}.exs"

      assert length(@documented) > 200,
             "the wildcard matched almost nothing — every test here would vacuously pass"

      assert @documented |> Enum.map(&Path.dirname/1) |> Enum.uniq() |> Enum.sort() ==
               ~w(priv/components priv/headless priv/mob)

      assert Enum.sort(@documented) == Enum.sort(shipped),
             "the wildcard and the library disagree about which options files ship"
    end

    test "every options file declares exactly the four facts, in order, each true or false" do
      wrong =
        for path <- @documented,
            {_cfg, docs} = docs(path),
            not (is_list(docs) and Keyword.keys(docs) == @docs_facts and
                   Enum.all?(Keyword.values(docs), &is_boolean/1)),
            do: "#{path}: #{inspect(docs)}"

      assert wrong == [],
             "every .exs needs `docs: [stateful: _, js_module: _, js: _, accessible: _]`, each " <>
               "a boolean (see the README's Contributing):\n" <> Enum.join(wrong, "\n")
    end

    test "the docs block is the catalog's last key" do
      wrong =
        for path <- @documented,
            {cfg, _docs} = docs(path),
            is_list(cfg) and cfg |> Keyword.keys() |> List.last() != :docs,
            do: path

      assert wrong == [], "these put a key after `docs:`: #{inspect(wrong)}"
    end

    test "every headless component is accessible" do
      wrong =
        for path <- @documented,
            String.starts_with?(path, "priv/headless/"),
            {_cfg, docs} = docs(path),
            fact(docs, :accessible) != true,
            do: path

      assert wrong == [], "headless components not declared accessible: #{inspect(wrong)}"
    end

    test "a component that ships scripts uses a JS hook" do
      wrong =
        for path <- @documented,
            {cfg, docs} = docs(path),
            scripts(cfg) != [] and fact(docs, :js) != true,
            do: path

      assert wrong == [], "these ship scripts but declare `js: false`: #{inspect(wrong)}"
    end

    test "a component is stateful exactly when its template is a Phoenix.LiveComponent" do
      wrong =
        for path <- @documented,
            {_cfg, docs} = docs(path),
            fact(docs, :stateful) != live_component?(path),
            do: "#{path}: stateful: #{inspect(fact(docs, :stateful))}"

      assert wrong == [], Enum.join(wrong, "\n")
    end
  end
end
