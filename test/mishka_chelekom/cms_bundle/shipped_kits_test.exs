defmodule MishkaChelekom.CmsBundle.ShippedKitsTest do
  @moduledoc """
  The kits in `priv/cms_ui_kits/`, read the way a CMS reads them.

  A CMS stores every component, hook and stylesheet under its name slugified, and rewrites nothing
  that refers to one. A row must already carry that name, and every component a template calls, a
  `dependencies` list holds or an example requires must be a component of the same kit by it —
  `chelekom_headless-button` called `chelekom_headless-button-content`, stored as
  `chelekom-headless-button-content`, and every headless button failed to render its label.

  A CMS registers each hook as `Global` and its stored name in PascalCase —
  `chelekom-headless-chart` is `GlobalChelekomHeadlessChart` — so a component that names any other
  key mounts nothing, and nothing says so. A hook that imports packages ships them, pinned and
  hashed, and the files it imports from beside itself.
  """
  use ExUnit.Case, async: true

  @kits Path.wildcard(Path.expand("../../../priv/cms_ui_kits/*.json", __DIR__))

  defp registered(kit) do
    MapSet.new(kit["js_hooks"] || [], fn hook ->
      "Global" <>
        (hook["name"]
         |> String.downcase()
         |> String.replace(~r/[^a-z0-9]+/, "-")
         |> String.split("-", trim: true)
         |> Enum.map_join("", &String.capitalize/1))
    end)
  end

  defp templates(component) do
    clauses = get_in(component, ["extra", "clauses"]) || []
    Enum.filter([component["template"] | Enum.map(clauses, & &1["template"])], &is_binary/1)
  end

  # Every hook key a component can mount: a literal `phx-hook="…"`, or the default of the attribute
  # a `phx-hook={@…}` reads.
  defp named_hooks(component) do
    texts = templates(component)
    literal = for text <- texts, [_, key] <- Regex.scan(~r/phx-hook="([^"]+)"/, text), do: key

    attrs =
      for text <- texts,
          [_, attr] <- Regex.scan(~r/phx-hook=\{@(\w+)\}/, text),
          uniq: true,
          do: attr

    defaults =
      for attr <- component["attrs"] || [],
          attr["name"] in attrs,
          default = get_in(attr, ["opts", "default"]),
          is_binary(default),
          do: default

    literal ++ defaults
  end

  # Lowercase letters and digits, single hyphens between: what slugifying leaves, and nothing else.
  @stored ~r/^[a-z0-9]+(-[a-z0-9]+)*$/

  # Every string in a component, base64 or not: templates, clause templates, bodies, helpers, examples.
  defp strings(value) when is_map(value), do: value |> Map.values() |> Enum.flat_map(&strings/1)
  defp strings(value) when is_list(value), do: Enum.flat_map(value, &strings/1)
  defp strings("base64:" <> encoded), do: [Base.decode64!(encoded)]
  defp strings(value) when is_binary(value), do: [value]
  defp strings(_other), do: []

  defp required(%{"requires" => %{"components" => names}} = value),
    do: names ++ required(Map.delete(value, "requires"))

  defp required(value) when is_map(value), do: value |> Map.values() |> Enum.flat_map(&required/1)
  defp required(value) when is_list(value), do: Enum.flat_map(value, &required/1)
  defp required(_other), do: []

  defp references(component) do
    called =
      for text <- strings(component),
          [_, name] <- Regex.scan(~r/component_name="([^"]+)"/, text),
          do: {"component_name", name}

    depended =
      for name <- component["dependencies"] || [],
          not String.ends_with?(name, ".js"),
          do: {"dependencies", name}

    called ++ depended ++ Enum.map(required(component), &{"requires", &1})
  end

  test "there are kits to check" do
    refute Enum.empty?(@kits)
  end

  for path <- @kits do
    @path path

    test "every row of #{Path.basename(path)} carries the name a CMS stores it under" do
      kit = @path |> File.read!() |> Jason.decode!()

      for section <- ~w(components js_hooks stylesheets), row <- kit[section] || [] do
        assert row["name"] =~ @stored, "#{section}: #{inspect(row["name"])}"
      end
    end

    test "every component #{Path.basename(path)} refers to is one of its own" do
      kit = @path |> File.read!() |> Jason.decode!()
      names = MapSet.new(kit["components"], & &1["name"])

      missing =
        for component <- kit["components"],
            {where, name} <- references(component),
            not MapSet.member?(names, name),
            do: "#{component["name"]} #{where}: #{name}"

      assert missing == []
      assert Enum.any?(kit["components"], &(references(&1) != []))
    end

    test "every hook a component of #{Path.basename(path)} names is one its kit registers" do
      kit = @path |> File.read!() |> Jason.decode!()
      registered = registered(kit)

      for component <- kit["components"],
          key <- named_hooks(component),
          String.starts_with?(key, "Global") do
        assert key in registered,
               "#{component["name"]} names #{key}, which #{kit["name"]} does not register"
      end
    end

    test "every hook of #{Path.basename(path)} ships its packages and modules whole" do
      kit = @path |> File.read!() |> Jason.decode!()

      for hook <- kit["js_hooks"] || [], package <- hook["npm"] || [] do
        assert %{"name" => name, "version" => version, "path" => p, "integrity" => integrity} =
                 package

        assert Regex.match?(~r/^\d+\.\d+\.\d+/, version), "#{hook["name"]}: #{name}@#{version}"
        assert String.ends_with?(p, "node_modules/" <> name), "#{hook["name"]}: #{p}"
        assert String.starts_with?(integrity, "sha512-"), "#{hook["name"]}: #{name}"
      end

      for hook <- kit["js_hooks"] || [], module <- hook["modules"] || [] do
        assert Regex.match?(~r/^[A-Za-z0-9][A-Za-z0-9_-]*\.js$/, module["file"])
        assert is_binary(module["content"]) and module["content"] != ""
      end
    end
  end
end
