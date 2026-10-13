defmodule MishkaChelekom.CmsBundle.AttrValuesTest do
  @moduledoc """
  What every attribute of the real kit ships: the list of its axis, as `values` when the template
  accepts only those and as `examples` when it accepts any class string beside them.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundleExporter
  alias MishkaChelekom.CmsBundle.AttrValues

  doctest AttrValues

  setup_all do
    kit =
      for exs <- Path.wildcard("priv/components/*.exs"),
          eex = String.replace_suffix(exs, ".exs", ".eex"),
          {:ok, %{components: cps}} =
            CmsBundleExporter.convert(File.read!(exs), File.read!(eex), "kit", "1.0"),
          config = exs |> Code.eval_file() |> elem(0) |> hd() |> elem(1),
          axes = AttrValues.axes(config[:args], Enum.map(cps, & &1["extra"]["function"])),
          component <- cps,
          do: {component, Map.put(Map.new(config), :axes, axes)}

    {:ok, kit: kit}
  end

  defp listed(attr), do: attr["opts"]["values"] || attr["opts"]["examples"]

  test "there are components to check", %{kit: kit} do
    assert length(kit) > 100
  end

  # A closed list Phoenix would refuse — its default is not one of the values — is the one case
  # an axis attribute ships without one.
  test "every attribute named for an axis carries that axis's list", %{kit: kit} do
    missing =
      for {component, config} <- kit,
          axes = config.axes,
          attr <- component["attrs"],
          attr["type"] in ["string", "any", "atom"],
          Map.has_key?(axes, attr["name"]),
          listed(attr) == nil,
          to_string(attr["opts"]["default"]) in axes[attr["name"]],
          do: "#{component["name"]}.#{attr["name"]}"

    assert missing == []
  end

  test "every list an attribute ships is one of its component's axes, or the template's own",
       %{kit: kit} do
    foreign =
      for {component, config} <- kit,
          lists = Map.values(config.axes),
          attr <- component["attrs"],
          list = attr["opts"]["examples"],
          list != nil,
          list not in lists,
          do: "#{component["name"]}.#{attr["name"]}"

    assert foreign == []
  end

  test "no attribute takes the generator's function list", %{kit: kit} do
    taken =
      for {component, config} <- kit,
          functions = Enum.filter(config[:args][:only] || [], &is_binary/1),
          functions != [],
          attr <- component["attrs"],
          list = listed(attr),
          list != nil,
          Enum.all?(list, &(&1 in functions)),
          do: "#{component["name"]}.#{attr["name"]}"

    assert taken == []
  end

  test "the alert and the flash take their colour through `kind`", %{kit: kit} do
    for name <- ["kit-alert", "kit-flash"] do
      {component, config} = Enum.find(kit, fn {c, _} -> c["name"] == name end)
      kind = Enum.find(component["attrs"], &(&1["name"] == "kind"))

      assert kind["opts"]["values"] == config[:args][:color]
      assert "danger" in kind["opts"]["values"]
    end
  end

  test "a size given as classes is accepted where the template takes any string", %{kit: kit} do
    {button, _config} = Enum.find(kit, fn {c, _} -> c["name"] == "kit-button" end)
    size = Enum.find(button["attrs"], &(&1["name"] == "size"))

    assert "small" in size["opts"]["examples"]
    refute Map.has_key?(size["opts"], "values")
  end
end
