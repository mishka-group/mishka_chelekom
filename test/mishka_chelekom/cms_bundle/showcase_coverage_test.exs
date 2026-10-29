defmodule MishkaChelekom.CmsBundle.ShowcaseCoverageTest do
  @moduledoc """
  Every component this kit ships has worked examples, and enough of them to be worth reading.

  ## Why a test rather than a checklist

  An example is how a component is discovered: the CMS palette renders them as the preview an author
  picks from, so a component with none is one that cannot be browsed — it is a name in a list. The
  showcase corpus is hand-authored, one file per component, which means the way it goes wrong is a
  component being ADDED and its file never written. Derived from the filesystem here, so a new
  component is covered the moment its catalog lands.

  Two is the floor rather than one: a single example reads as the only way to use the thing, and the
  attribute that changes between two of them is most of what an author needs to see.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.Showcase

  @showcase Path.wildcard("priv/showcase/*.json")
            |> Enum.reject(&(Path.basename(&1) == "_schema.json"))
  @catalogs Path.wildcard("priv/{components,headless}/*.exs")

  defp entry(path), do: path |> File.read!() |> Jason.decode!()

  # `chelekom-mega-menu` -> `mega menu`. What the tile beside the label already says, so a label
  # equal to it is a label that adds nothing.
  defp bare_name(entry) do
    entry["name"]
    |> String.replace_prefix("chelekom-", "")
    |> String.replace("-", " ")
  end

  test "there are showcase files to check" do
    assert length(@showcase) > 100,
           "the wildcard matched nothing — every test here would vacuously pass"

    # The library's own overlay lays every one of those files over its component.
    entries = Enum.map(@showcase, &entry/1)
    bare = Enum.map(entries, &%{"name" => &1["name"], "extra" => %{}})

    for {entry, component} <- Enum.zip(entries, Showcase.overlay(bare, "priv/showcase")) do
      labels = Enum.map(component["extra"]["examples"], & &1["label"])

      assert labels == Enum.map(entry["examples"], & &1["label"]),
             "#{entry["name"]}: the overlay did not carry its showcase examples"
    end
  end

  test "every showcase entry carries at least two examples" do
    thin =
      for path <- @showcase,
          entry = entry(path),
          length(entry["examples"] || []) < 2,
          do: {Path.basename(path), length(entry["examples"] || [])}

    assert thin == [],
           "these components ship too few examples to browse: #{inspect(thin)}"
  end

  test "every example names itself and renders the component it belongs to" do
    for path <- @showcase, entry = entry(path), example <- entry["examples"] do
      assert is_binary(example["label"]) and String.trim(example["label"]) != "",
             "#{Path.basename(path)} has an unlabelled example"

      assert String.contains?(example["source"], entry["name"]),
             "#{Path.basename(path)} has an example that never mentions #{entry["name"]}"
    end
  end

  # A LABEL IS READ, so it must not be the component's own name back again — "Card" over a card
  # tells a browsing author nothing that the tile above it did not already say.
  test "no example is labelled with nothing but the component's name" do
    lazy =
      for path <- @showcase,
          entry = entry(path),
          example <- entry["examples"],
          bare_name(entry) == String.downcase(String.trim(example["label"])),
          do: {entry["name"], example["label"]}

    assert lazy == [], "these labels only repeat the component name: #{inspect(lazy)}"
  end

  # WHAT LANDS ON A DROP IS ANY PAGE'S. An example is browsed and picked; a furnishing is what a page
  # gets the moment a component is dragged onto it, before the author has chosen anything, so it has
  # to read as a placeholder any page could keep. The timeline's three steps were a parcel's journey,
  # "Order placed" to "Out for delivery", on every page a timeline was dropped onto.
  test "a timeline dropped on a page holds steps any page could use" do
    body = entry("priv/showcase/chelekom-timeline.json")["furnishing"]["body"]

    for word <- ~w(order parcel courier delivery warehouse) do
      refute body =~ ~r/\b#{word}/i, "the timeline's drop default mentions #{inspect(word)}"
    end
  end

  # AND THE SHIPPED KIT DROPS WHAT THE FILE SAYS. The bundle in `priv/cms_ui_kits/` is what a CMS
  # installs, and it is regenerated from these files by an export; a furnishing edited here and not
  # carried into the bundle is a fix no CMS ever sees.
  test "the shipped kit drops the timeline's showcase furnishing" do
    [shipped] =
      for component <-
            "priv/cms_ui_kits/chelekom.json"
            |> File.read!()
            |> Jason.decode!()
            |> Map.fetch!("components"),
          component["name"] == "chelekom-timeline",
          do: component

    [overlaid] =
      Showcase.overlay([%{"name" => "chelekom-timeline", "extra" => %{}}], "priv/showcase")

    assert shipped["extra"]["furnishing"] == overlaid["extra"]["furnishing"]
  end

  # THE GAP THIS CORPUS ACTUALLY DEVELOPS: a component is added and its showcase file is not.
  test "every component in the catalogue has a showcase file" do
    documented = MapSet.new(@showcase, &(&1 |> Path.basename(".json")))

    missing =
      for catalog <- @catalogs,
          name = Path.basename(catalog, ".exs"),
          config = Config.Reader.read!(catalog)[String.to_atom(name)],
          is_list(config),
          component <- Keyword.get(config, :only, []) ++ Keyword.get(config, :type, []),
          key = "chelekom-" <> String.replace(to_string(component), "_", "-"),
          not MapSet.member?(documented, key),
          uniq: true,
          do: key

    assert missing == [],
           "these components have no examples at all: #{inspect(Enum.sort(missing))}"
  end
end
