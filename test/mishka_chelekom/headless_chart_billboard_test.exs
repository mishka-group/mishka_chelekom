defmodule MishkaChelekom.HeadlessChartBillboardTest do
  @moduledoc """
  The billboard.js chart engine draws every chart type a billboard config can name.

  A bundler resolves `billboard.js` to its ESM build, which draws a chart type only after that
  type's module has been called and throws while mounting otherwise. The engine imports every type
  module, and the feature modules a config turns on, by name, and maps each type string to its
  module's call. `chart_billboard.test.mjs` (run with `node --test` in `priv/assets/js`) generates
  charts through the hook against a stand-in that throws the same way.

  It also draws on a page whose Content Security Policy allows no inline style: the engine adopts
  one constructable stylesheet instead of writing a `<style>`, and its tooltip colors each swatch
  with an SVG `fill` instead of a `style` attribute.
  """
  use ExUnit.Case, async: true

  @engine Path.expand("../../priv/assets/js/chart_billboard.js", __DIR__)
  @catalog Path.expand("../../priv/headless/chart.exs", __DIR__)

  # billboard.js 4's chart types (its TYPE constant) and the ESM export that registers each one.
  @types [
    {"line", "line"},
    {"spline", "spline"},
    {"step", "step"},
    {"area", "area"},
    {"area-spline", "areaSpline"},
    {"area-step", "areaStep"},
    {"area-line-range", "areaLineRange"},
    {"area-spline-range", "areaSplineRange"},
    {"area-step-range", "areaStepRange"},
    {"bar", "bar"},
    {"scatter", "scatter"},
    {"bubble", "bubble"},
    {"candlestick", "candlestick"},
    {"pie", "pie"},
    {"donut", "donut"},
    {"gauge", "gauge"},
    {"polar", "polar"},
    {"radar", "radar"},
    {"funnel", "funnel"},
    {"treemap", "treemap"}
  ]

  @features ~w(grid zoom subchart selection regions)

  setup_all do
    %{source: File.read!(@engine)}
  end

  defp named_imports(source) do
    [_, names] = Regex.run(~r/import bb, \{([^}]*)\} from "billboard\.js";/, source)
    names |> String.split(",", trim: true) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end

  defp mapped_types(source) do
    ~r/\["([a-z-]+)", \(\) => (\w+)\(\)\]/
    |> Regex.scan(source, capture: :all_but_first)
    |> Enum.map(fn [type, module] -> {type, module} end)
  end

  test "imports every chart type module by name from billboard.js", %{source: source} do
    imports = named_imports(source)

    for {_type, module} <- @types do
      assert module in imports, "chart_billboard.js does not import #{module} from billboard.js"
    end
  end

  test "maps every chart type string to its own module's call, and nothing else", %{
    source: source
  } do
    assert Enum.sort(mapped_types(source)) == Enum.sort(@types)
  end

  test "imports the feature modules by name and calls each one in resolveFeatures", %{
    source: source
  } do
    imports = named_imports(source)
    [_, body] = Regex.run(~r/function resolveFeatures\(config\) \{(.*?)\n\}/s, source)

    for module <- @features do
      assert module in imports, "chart_billboard.js does not import #{module} from billboard.js"
      assert body =~ "#{module}();", "resolveFeatures never calls #{module}()"
    end
  end

  test "resolves the types and features before billboard generates", %{source: source} do
    [_, body] = Regex.run(~r/\n  generate\(raw\) \{(.*?)\n  \},/s, source)

    {types_at, _} = :binary.match(body, "resolveTypes(config.data);")
    {features_at, _} = :binary.match(body, "resolveFeatures(config);")
    {generate_at, _} = :binary.match(body, "bb.generate(config)")

    assert types_at < generate_at
    assert features_at < generate_at
  end

  describe "under a style-src with no 'unsafe-inline'" do
    test "adopts one stylesheet for the page and never adds it twice", %{source: source} do
      [_, mounted] = Regex.run(~r/\n  mounted\(\) \{(.*?)\n  \},/s, source)
      [_, adopt] = Regex.run(~r/function adoptStyles\(\) \{(.*?)\n\}/s, source)

      assert mounted =~ "adoptStyles();"
      assert adopt =~ "sheet.replaceSync(BILLBOARD_CSS);"
      assert adopt =~ "if (!document.adoptedStyleSheets.includes(sheet)) {"
      assert adopt =~ "document.adoptedStyleSheets = [...document.adoptedStyleSheets, sheet];"
    end

    test "keeps the injectStyles: false opt-out for the sheet and the tooltip", %{source: source} do
      assert source =~ "const stylesOn = () => userConfig?.billboard?.injectStyles !== false;"
      assert source =~ ~r/function adoptStyles\(\) \{\n  if \(!stylesOn\(\)\) return;/
      assert source =~ "if (stylesOn()) resolveTooltip(config);"
    end

    test "colors the tooltip swatch with an SVG fill the sheet sizes", %{source: source} do
      [_, template] = Regex.run(~r/const TOOLTIP_TEMPLATE =(.*?);\n/s, source)
      [_, css] = Regex.run(~r/const BILLBOARD_CSS = `(.*?)`;/s, source)

      refute template =~ "style="
      assert template =~ ~s(fill="{=COLOR}")
      assert css =~ ".bb-tooltip td > svg {"
    end
  end

  test "the catalog installs this engine with billboard.js 4, whose module list this is" do
    libs = Config.Reader.read!(@catalog)[:chart][:libs][:billboard]
    [%{name: "billboard.js", version: version}] = libs[:npm]

    assert [%{file: "chart_billboard.js"}] = libs[:scripts]

    assert Version.match?(version, "~> 4.0"),
           "billboard.js #{version} may ship a different ESM module list; recheck the type map " <>
             "in chart_billboard.js, chart_billboard.test.mjs and this test"
  end
end
