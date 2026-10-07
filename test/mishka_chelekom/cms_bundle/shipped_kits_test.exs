defmodule MishkaChelekom.CmsBundle.ShippedKitsTest do
  @moduledoc """
  The kits in `priv/cms_ui_kits/`, read the way a CMS reads them.

  A CMS registers each hook under its row name slugified — `chelekom_headless-chart` is
  `GlobalChelekomHeadlessChart` — so a component that names any other key mounts nothing, and
  nothing says so. A hook that imports packages ships them, pinned and hashed, and the files it
  imports from beside itself.
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

  test "there are kits to check" do
    refute Enum.empty?(@kits)
  end

  for path <- @kits do
    @path path

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
