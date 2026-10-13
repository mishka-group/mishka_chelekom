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

  test "an attribute handed on to another component is read where that component reads it",
       %{kit: kit} do
    read_through =
      for {name, attr} <- [
            {"kit-progress-section", "variant"},
            {"kit-progress", "variant"},
            {"kit-list", "variant"},
            {"kit-banner", "dismiss_size"}
          ] do
        {component, _config} = Enum.find(kit, fn {c, _} -> c["name"] == name end)
        Enum.find(component["attrs"], &(&1["name"] == attr))["opts"]
      end

    assert Enum.all?(read_through, &(&1["examples"] != nil and &1["values"] == nil))
  end

  test "a value a helper hands on to a helper with no catch-all keeps its list closed",
       %{kit: kit} do
    {dock, _config} = Enum.find(kit, fn {c, _} -> c["name"] == "kit-dock" end)
    variant = Enum.find(dock["attrs"], &(&1["name"] == "variant"))

    assert "base" in variant["opts"]["values"]
    refute Map.has_key?(variant["opts"], "examples")
  end

  describe "an attribute passed to another component" do
    test "spread into a private component that takes any class string is open" do
      assert declared(~S|<.bar_inner {assigns} />|, inner()) == {"examples", nil}
    end

    test "passed by name to a private component that takes any class string is open" do
      assert declared(~S|<.bar_inner variant={@variant} />|, inner()) == {"examples", nil}
    end

    test "spread into a public component of the same file is open in both" do
      assert declared(~S|<.bar_inner {assigns} />|, inner(:public)) == {"examples", "examples"}
    end

    test "a component that declares its own values for it closes it" do
      child = inner(:private, ~S|attr :variant, :string, values: ["base", "gradient"]|)
      assert declared(~S|<.bar_inner {assigns} />|, child) == {"values", nil}
    end

    test "a component the file does not define closes it" do
      assert declared(~S|<.elsewhere {assigns} />|, "") == {"values", nil}
    end

    test "an attribute the tag sets itself is not the one spread" do
      assert declared(~S|<.bar_inner {assigns} variant="base" />|, inner()) == {"values", nil}
    end

    test "a helper that hands the value on to one with no catch-all closes it" do
      helper = ~S"""
        defp wrapper_class(variant), do: ["wrapper", strict_class(variant)]
        defp strict_class("base"), do: "bg-base"
        defp strict_class("gradient"), do: "bg-gradient"
      """

      assert declared(~S|<div class={wrapper_class(@variant)} />|, helper) == {"values", nil}
    end

    test "a helper that hands the value on to one with a catch-all keeps it open" do
      helper = ~S"""
        defp wrapper_class(variant), do: ["wrapper", color_variant(variant)]
      """

      assert declared(~S|<div class={wrapper_class(@variant)} />|, helper) ==
               {"examples", nil}
    end
  end

  # `bar` renders `template` beside `children`; `color_variant/1` takes any class string. The
  # result is what `bar`'s and `bar_inner`'s `variant` ship, `nil` where there is no `bar_inner`.
  defp declared(template, children) do
    exs = """
    [
      bar: [
        name: "bar",
        category: "general",
        doc_url: "internal",
        args: [variant: ["base", "gradient"], only: ["bar"], helpers: [], module: ""],
        optional: [],
        necessary: []
      ]
    ]
    """

    eex = """
    defmodule <%= @module %> do
      use Phoenix.Component

      attr :variant, :string, default: "base"
      attr :class, :any, default: nil

      def <%= @component_prefix %>bar(assigns) do
        ~H\"\"\"
        #{template}
        \"\"\"
      end

    #{children}

      <%= if is_nil(@variant) or "base" in @variant do %>
      defp color_variant("base"), do: "bg-base"
      <% end %>
      <%= if is_nil(@variant) or "gradient" in @variant do %>
      defp color_variant("gradient"), do: "bg-gradient"
      <% end %>
      defp color_variant(params) when is_binary(params), do: params
    end
    """

    {:ok, %{components: components}} = CmsBundleExporter.convert(exs, eex, "kit", "1.0")

    [bar, inner] =
      for name <- ["kit-bar", "kit-bar-inner"] do
        with %{"attrs" => attrs} <- Enum.find(components, &(&1["name"] == name)),
             %{"opts" => opts} <- Enum.find(attrs, &(&1["name"] == "variant")) do
          Enum.find(["values", "examples"], &Map.has_key?(opts, &1))
        end
      end

    {bar, inner}
  end

  defp inner(visibility \\ :private, attr \\ ~S|attr :variant, :string, default: "base"|) do
    def =
      if visibility == :public,
        do: "def <%= @component_prefix %>bar_inner",
        else: "defp bar_inner"

    """
      #{attr}

      #{def}(assigns) do
        ~H\"\"\"
        <div class={["inner", color_variant(@variant)]} />
        \"\"\"
      end
    """
  end
end
