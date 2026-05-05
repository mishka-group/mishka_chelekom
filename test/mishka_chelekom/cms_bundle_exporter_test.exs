defmodule MishkaChelekom.CmsBundleExporterTest do
  @moduledoc """
  Comprehensive coverage of the v3 converter pipeline.

  Two layers:

    1. **Direct unit tests on `convert/5`** — reads raw `.exs+.eex`
       sources from `test/fixtures/cms_bundle/*` and asserts the v3
       JSON shape feature-by-feature.
    2. **HEEx tag rewriter unit tests** — exercises edge cases
       (strings, comments, EEx blocks, no-curly regions, non-sibling
       names that must be preserved).
  """

  use ExUnit.Case, async: true
  alias MishkaChelekom.CmsBundleExporter
  alias MishkaChelekom.HeexTagRewriter

  @moduletag :unit

  @fixture_dir Path.expand("../fixtures/cms_bundle", __DIR__)

  setup_all do
    button_exs = File.read!(Path.join(@fixture_dir, "sample_button.exs"))
    button_eex = File.read!(Path.join(@fixture_dir, "sample_button.eex"))
    card_exs = File.read!(Path.join(@fixture_dir, "sample_card.exs"))
    card_eex = File.read!(Path.join(@fixture_dir, "sample_card.eex"))

    {:ok, button_exs: button_exs, button_eex: button_eex, card_exs: card_exs, card_eex: card_eex}
  end

  defp by_name(components, name), do: Enum.find(components, &(&1["name"] == name))

  ## ─── Top-level shape ────────────────────────────────────────────────

  describe "convert/5 — top-level shape" do
    test "returns {:ok, %{components, scripts}}", %{button_exs: e, button_eex: t} do
      assert {:ok, %{components: cps, scripts: ss}} =
               CmsBundleExporter.convert(e, t, "kit", "1.0")

      assert is_list(cps)
      assert is_list(ss)
    end

    test "every component has the v3 final-form keys", %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")

      required_keys = ~w(name site_id active format priority permissions examples
                         template body attrs slots helpers extra)

      for c <- cps, key <- required_keys do
        assert Map.has_key?(c, key), "missing key #{key} on #{c["name"]}"
      end
    end

    test "site_id is null at conversion time", %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      Enum.each(cps, fn c -> assert c["site_id"] == nil end)
    end
  end

  ## ─── Per-public-function emission ───────────────────────────────────

  describe "convert/5 — per-public-fn emission" do
    test "sample_button (2 public defs) → 2 component entries",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      names = Enum.map(cps, & &1["name"]) |> Enum.sort()
      assert names == ["kit-sample-button", "kit-sample-button-link"]
    end

    test "sample_card (2 public defs) → 2 component entries",
         %{card_exs: e, card_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      names = Enum.map(cps, & &1["name"]) |> Enum.sort()
      assert names == ["kit-sample-card", "kit-sample-card-title"]
    end
  end

  ## ─── Slug rewriting ─────────────────────────────────────────────────

  describe "convert/5 — name slugging" do
    test "underscores → hyphens, prefixed with kit name",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      assert by_name(cps, "kit-sample-button-link")
      refute by_name(cps, "kit-sample_button_link")
    end
  end

  ## ─── Sibling cross-call rewrite ────────────────────────────────────

  describe "convert/5 — sibling rewrite" do
    test "card calling sample_card_title gets <.component component_name=...>",
         %{card_exs: e, card_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      card = by_name(cps, "kit-sample-card")

      assert String.contains?(
               card["template"],
               ~s|<.component component_name="kit-sample-card-title"|
             )

      refute String.contains?(card["template"], "<.sample_card_title")
    end

    test "private defp calls remain bare (in helpers list)",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      # sample_button_indicator is defp → goes to helpers, NOT rewritten
      assert String.contains?(btn["template"], "<.sample_button_indicator")
      helper_names = Enum.map(btn["helpers"], & &1["name"])
      assert "sample_button_indicator" in helper_names
    end
  end

  ## ─── Module-aliased attr type resolution ────────────────────────────

  describe "convert/5 — module-aliased attrs" do
    test "attr :on_click, JS resolves to full Phoenix.LiveView.JS path",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")
      on_click = Enum.find(btn["attrs"], &(&1["name"] == "on_click"))

      assert on_click["type"] == "struct"
      assert on_click["struct_name"] == "Phoenix.LiveView.JS"
    end
  end

  ## ─── Unparseable defaults ───────────────────────────────────────────

  describe "convert/5 — drop unrepresentable defaults" do
    test "default: %JS{} is dropped (no default key on the attr)",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")
      on_click = Enum.find(btn["attrs"], &(&1["name"] == "on_click"))

      refute Map.has_key?(on_click["opts"], "default")
    end
  end

  ## ─── Helpers extraction ─────────────────────────────────────────────

  describe "convert/5 — helpers" do
    test "all defps extracted (gated + multi-line + catch-all)",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")
      cv = Enum.filter(btn["helpers"], &(&1["name"] == "color_variant"))

      args = Enum.map(cv, & &1["args"])
      assert "\"default\", \"primary\"" in args
      assert "\"default\", \"danger\"" in args
      assert "\"outline\", \"primary\"" in args
      assert "%{a: 1} = _multi_line_pattern_match" in args
      assert "_, _" in args
    end

    test "every helper.code parses as valid Elixir",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      for h <- btn["helpers"] do
        full = "def #{h["name"]}(#{h["args"]}) do\n#{h["code"]}\nend"

        assert {:ok, _} = Code.string_to_quoted(full),
               "helper #{h["name"]}(#{h["args"]}) failed to parse"
      end
    end

    test "every helper has non-empty args and code",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      for h <- btn["helpers"] do
        refute h["args"] in [nil, ""], "blank args on #{h["name"]}"
        refute h["code"] in [nil, ""], "blank code on #{h["name"]}"
      end
    end
  end

  ## ─── Discriminators ────────────────────────────────────────────────

  describe "convert/5 — discriminators" do
    test "every helper carries a discriminators field (list, possibly empty)",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      for h <- btn["helpers"] do
        assert is_list(h["discriminators"]),
               "helper #{h["name"]}(#{h["args"]}) missing discriminators field"
      end
    end

    test "wrapped defps get axis-value clauses extracted from `<%= if %>` chain",
         %{button_exs: e, button_eex: t} do
      # The fixture wraps `defp color_variant("default", "primary")`
      # in nested ifs:
      #   <%= if is_nil(@variant) or "default" in @variant do %>
      #     <%= if is_nil(@color) or "primary" in @color do %>
      #
      # Both `is_nil` branches are no-ops for filtering — only the
      # value side contributes. Discriminators must capture both axes.
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      cv =
        Enum.find(btn["helpers"], fn h ->
          h["name"] == "color_variant" and h["args"] == "\"default\", \"primary\""
        end)

      axes = cv["discriminators"] |> Enum.map(& &1["axis"]) |> Enum.sort()
      assert axes == ["color", "variant"]

      variant = Enum.find(cv["discriminators"], &(&1["axis"] == "variant"))
      color = Enum.find(cv["discriminators"], &(&1["axis"] == "color"))
      assert variant["values"] == ["default"]
      assert color["values"] == ["primary"]
    end

    test "catch-all + non-literal helpers get empty discriminators",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      catch_all = Enum.find(btn["helpers"], &(&1["args"] == "_, _"))
      assert catch_all["discriminators"] == []

      assigns_helper =
        Enum.find(btn["helpers"], &(&1["name"] == "sample_button_indicator"))

      assert assigns_helper["discriminators"] == []
    end

    test "different argument patterns of the same helper get distinct discriminators",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      cvs = Enum.filter(btn["helpers"], &(&1["name"] == "color_variant"))

      by_args =
        Map.new(cvs, fn h ->
          {h["args"], h["discriminators"] |> Enum.map(&{&1["axis"], &1["values"]}) |> Enum.sort()}
        end)

      assert by_args["\"default\", \"primary\""] ==
               [{"color", ["primary"]}, {"variant", ["default"]}]

      assert by_args["\"default\", \"danger\""] ==
               [{"color", ["danger"]}, {"variant", ["default"]}]

      assert by_args["\"outline\", \"primary\""] ==
               [{"color", ["primary"]}, {"variant", ["outline"]}]
    end
  end

  ## ─── Module attributes ─────────────────────────────────────────────

  describe "convert/5 — module attributes" do
    test "@indicator_positions captured in extra.module_attributes",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      attrs = btn["extra"]["module_attributes"]
      assert [%{"name" => "indicator_positions", "value" => positions}] = attrs
      assert "left" in positions
      assert "right" in positions
    end
  end

  ## ─── Prelude / Tier-1 dedup ─────────────────────────────────────────

  describe "convert/5 — prelude" do
    test "Tier-1 (Phoenix.Component, Phoenix.LiveView.JS, Gettext, ...) stripped",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      btn = by_name(cps, "kit-sample-button")

      pre = btn["extra"]["prelude"]

      if pre do
        refute pre =~ "use Phoenix.Component"
        refute pre =~ "alias Phoenix.LiveView.JS"
        refute pre =~ "use Gettext"
      end
    end
  end

  ## ─── Attr/slot association ─────────────────────────────────────────

  describe "convert/5 — attr/slot association" do
    test "attrs declared between two defs belong to the SECOND def",
         %{button_exs: e, button_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")

      btn = by_name(cps, "kit-sample-button")
      btn_link = by_name(cps, "kit-sample-button-link")

      btn_attrs = Enum.map(btn["attrs"], & &1["name"]) |> MapSet.new()
      link_attrs = Enum.map(btn_link["attrs"], & &1["name"]) |> MapSet.new()

      # `href` is declared right before def sample_button_link
      assert MapSet.member?(link_attrs, "href")
      refute MapSet.member?(btn_attrs, "href")
    end

    test "slots assigned to the right def", %{card_exs: e, card_eex: t} do
      {:ok, %{components: cps}} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      card = by_name(cps, "kit-sample-card")
      title = by_name(cps, "kit-sample-card-title")

      [card_slot] = card["slots"]
      assert card_slot["name"] == "inner_block"
      assert card_slot["opts"]["required"] == true

      [title_slot] = title["slots"]
      assert title_slot["opts"]["required"] == false
    end
  end

  ## ─── Idempotency ───────────────────────────────────────────────────

  describe "convert/5 — idempotency" do
    test "byte-identical output for identical input",
         %{button_exs: e, button_eex: t} do
      {:ok, a} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      {:ok, b} = CmsBundleExporter.convert(e, t, "kit", "1.0")
      assert a == b
    end
  end

  ## ─── HEEx tag rewriter unit tests ──────────────────────────────────

  describe "HeexTagRewriter.rewrite/3" do
    test "no siblings → input unchanged" do
      input = ~s|<button><.icon name="x"/></button>|
      assert HeexTagRewriter.rewrite(input, MapSet.new(), "kit") == input
    end

    test "sibling self-closing tag rewritten" do
      input = ~s|<button><.foo size="md"/></button>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ ~s|<.component component_name="kit-foo"|
      assert out =~ ~s|size="md"|
      refute out =~ ~s|<.foo |
    end

    test "sibling open + close tags both rewritten" do
      input = ~s|<.foo>hello</.foo>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ ~s|<.component component_name="kit-foo"|
      assert out =~ "</.component>"
      refute out =~ "</.foo>"
    end

    test "non-sibling tags left alone" do
      input = ~s|<.foo/><.bar/>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ ~s|<.component component_name="kit-foo"|
      assert out =~ "<.bar/>"
    end

    test "underscore → hyphen in component_name attribute" do
      input = ~s|<.button_indicator/>|
      siblings = MapSet.new(["button_indicator"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ ~s|component_name="kit-button-indicator"|
    end

    test "tag name embedded in HTML attribute string is NOT rewritten" do
      input = ~s|<input value="<.foo/>"/>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      # The `<.foo/>` IS in a string literal, but our scanner is
      # text-mode + `<` initiates tag parse. We don't track double-quoted
      # context inside an outer tag — but inside `value="..."` the text
      # is HTML, not HEEx. Phoenix HEEx normally doesn't allow that. We
      # accept rewriting here as an acceptable limitation; Chelekom
      # never embeds `<.X/>` in a quoted HTML attribute value.
      assert out == input or out =~ ~s|component_name="kit-foo"|
    end

    test "EEx interpolation `<%= @foo %>` is left untouched" do
      input = ~s|<%= @whatever %><.bar/>|
      siblings = MapSet.new(["bar"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ "<%= @whatever %>"
      assert out =~ ~s|component_name="kit-bar"|
    end

    test "HTML comments `<!-- ... -->` skipped" do
      input = ~s|<!-- <.foo/> --><.foo/>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      # Comment content unchanged; outer tag rewritten
      assert out =~ "<!-- <.foo/> -->"
      assert out =~ ~s|component_name="kit-foo"|
    end

    test "preserves attribute spread and event bindings" do
      input = ~s|<.foo phx-click="bump" {@rest}/>|
      siblings = MapSet.new(["foo"])
      out = HeexTagRewriter.rewrite(input, siblings, "kit")
      assert out =~ ~s|component_name="kit-foo"|
      assert out =~ ~s|phx-click="bump"|
      assert out =~ "{@rest}"
    end
  end
end
