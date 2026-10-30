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
  # to read as a placeholder any page could keep. The drop defaults read like one shop's pages: a
  # timeline tracked a parcel from "Order placed" to "Out for delivery", the tabs sold a walnut desk
  # shelf, a strong said "Free delivery on orders over $50" and an h6 said "Shipping and returns".
  # A page about anything else had to clear all of that first, so no furnishing sells, prices or
  # ships anything.
  @shop_copy ~r/\b(?:orders?|parcels?|courier|deliver(?:y|ies|ed)|warehouse|shipping|shop(?:s|ping)?|carts?|checkout|refunds?|pric(?:e|es|ing)|billing|licen[cs]es?|discounts?|coupons?|invoices?|receipts?|purchases?|buy(?:s|ing|ers?)?|retail|freight|in stock|customers?|products?|pay(?:ment)?s?|paid)\b|[$€£¥]\s?\d/iu

  test "no component dropped on a page arrives with a shop's copy" do
    shop_copy =
      for path <- @showcase,
          furnishing = entry(path)["furnishing"],
          is_map(furnishing),
          text <- furnishing_text(furnishing),
          [match | _] <- [Regex.run(@shop_copy, text)],
          uniq: true,
          do: {Path.basename(path), String.downcase(match)}

    assert shop_copy == [],
           "these drop defaults read like a shop's page: #{inspect(shop_copy)}"
  end

  # Every string a drop writes onto the page: the body, each slot's body, and the attribute values on
  # the component and on its slots (a timeline's steps and a gallery's captions are attributes).
  defp furnishing_text(furnishing) do
    slots = furnishing["slots"] || []

    [furnishing["body"], attribute_text(furnishing["attrs"])] ++
      Enum.flat_map(slots, &[&1["body"], attribute_text(&1["attrs"])])
  end

  defp attribute_text(value) when is_map(value),
    do: value |> Map.values() |> Enum.map_join(" ", &attribute_text/1)

  defp attribute_text(value) when is_list(value), do: Enum.map_join(value, " ", &attribute_text/1)
  defp attribute_text(nil), do: ""
  defp attribute_text(value), do: to_string(value)

  # AND THE SHIPPED KIT DROPS WHAT THE FILES SAY. The bundle in `priv/cms_ui_kits/` is what a CMS
  # installs, and it is regenerated from these files by an export; a furnishing edited here and not
  # carried into the bundle is a fix no CMS ever sees.
  test "the shipped kit drops every component's showcase furnishing" do
    shipped =
      "priv/cms_ui_kits/chelekom.json"
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("components")
      |> Map.new(&{&1["name"], get_in(&1, ["extra", "furnishing"])})

    names =
      for path <- @showcase, entry = entry(path), is_map(entry["furnishing"]), do: entry["name"]

    stale =
      for component <-
            Showcase.overlay(Enum.map(names, &%{"name" => &1, "extra" => %{}}), "priv/showcase"),
          shipped[component["name"]] != component["extra"]["furnishing"],
          do: component["name"]

    assert length(names) > 100, "no showcase file carries a furnishing to compare"

    assert stale == [],
           "the shipped kit drops something other than these showcase furnishings: #{inspect(stale)}"
  end

  # A HEADLESS COMPONENT SHIPS NO STYLING, so dropped bare a slider, a splitter, a tree, a chart and an
  # editor draw nothing at all: a track with no height, panels with no size, a tree with no nodes, a
  # chart with no data, an editor with no edge. Their furnishings give a plain drop neutral Tailwind
  # utilities and sample content, and the headless bundle has to carry them, as the styled one does.
  @headless_showcase Path.wildcard("priv/showcase_headless/*.json")

  @drawn_by_furnishing ~w(
    chelekom-headless-alpha-slider chelekom-headless-hue-slider chelekom-headless-splitter
    chelekom-headless-tree chelekom-headless-chart chelekom-headless-editor
  )

  test "a headless component that draws nothing bare arrives with something to draw" do
    furnished =
      for path <- @headless_showcase,
          entry = entry(path),
          map_size(get_in(entry, ["furnishing", "attrs"]) || %{}) > 0,
          do: entry["name"]

    assert @drawn_by_furnishing -- furnished == []

    for path <- @headless_showcase, entry = entry(path) do
      assert length(entry["examples"] || []) >= 2, "#{entry["name"]} ships too few examples"

      refute inspect(entry) =~ "style=",
             "#{entry["name"]}: plain Tailwind utilities only, the CMS compiles them from markup"
    end
  end

  test "the shipped headless kit drops every headless showcase furnishing" do
    shipped =
      "priv/cms_ui_kits/chelekom_headless.json"
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("components")
      |> Map.new(&{&1["name"], get_in(&1, ["extra", "furnishing"])})

    stale =
      for path <- @headless_showcase,
          entry = entry(path),
          shipped[entry["name"]] != entry["furnishing"],
          do: entry["name"]

    assert @headless_showcase != [], "no headless showcase file to compare"
    assert stale == [], "the shipped headless kit drops something else for: #{inspect(stale)}"
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
