defmodule Mix.Tasks.Mishka.Ui.ExportExamplesTest do
  @moduledoc """
  Fast, focused coverage for the `--cms` example pipeline in `mix mishka.ui.export`.

  Two consumers, two outputs (see `populate_examples/4`):

    * top-level `examples` — clean, self-contained, ≤5 HEEx strings for the CMS preview.
    * `extra.demo_examples` — the full invocation maps the `DemoHarness` compiles and renders.

  Guards the regression where the export dropped `extra.demo_examples` (the harness then saw
  `components with examples: 0`). Until now that contract was only covered by the ~100s end-to-end
  harness; these unit tests lock it down in milliseconds.
  """
  use ExUnit.Case, async: true

  alias Mix.Tasks.Mishka.Ui.Export

  describe "normalize_example_source/1" do
    test "rewrites every site binding to site=\"Global\"" do
      assert Export.normalize_example_source(~s(<.x site={assigns[:site]} />)) =~
               ~s(site="Global")

      assert Export.normalize_example_source(~s(<.x site={@site} />)) =~ ~s(site="Global")
      assert Export.normalize_example_source(~s(<.x site={assigns.site} />)) =~ ~s(site="Global")
    end

    test "strips wrapper :if attrs left over from interactive demos" do
      out = Export.normalize_example_source(~S(<div :if={true}><.x /></div>))
      refute out =~ ":if="
      assert out =~ "<.x"
    end

    test "collapses whitespace to a single line and trims" do
      out = Export.normalize_example_source("  <.x\n     a=\"1\"\n     b=\"2\"  />  ")
      refute out =~ "\n"
      assert out == ~s(<.x a="1" b="2" />)
    end

    test "returns \"\" for non-binary input" do
      assert Export.normalize_example_source(nil) == ""
      assert Export.normalize_example_source(123) == ""
    end
  end

  describe "self_contained_example?/1" do
    test "accepts a snippet with no interpolations" do
      assert Export.self_contained_example?(~s(<.x a="1">hi</.x>))
    end

    test "accepts only safe literal interpolations" do
      for lit <- [~s({"text"}), "{123}", "{-1.5}", "{true}", "{false}", "{nil}", "{:large}"] do
        assert Export.self_contained_example?("<.x>" <> lit <> "</.x>"),
               "expected literal: #{lit}"
      end
    end

    test "is quote-aware: a } inside a string literal does not fool the scan" do
      assert Export.self_contained_example?(~S(<.x label={"a}b"} />))
    end

    test "rejects any non-literal interpolation" do
      for expr <- ["{@variant}", "{assigns.site}", "{some_fn()}", "{@a <> @b}", "{[1, 2]}", "{x}"] do
        refute Export.self_contained_example?("<.x>" <> expr <> "</.x>"),
               "expected non-literal: #{expr}"
      end
    end

    test "rejects an empty string" do
      refute Export.self_contained_example?("")
    end
  end

  describe "build_example_strings/1" do
    test "normalizes, then keeps only self-contained snippets" do
      out =
        Export.build_example_strings([
          ~s(<.x site={@site} a="1" />),
          ~s(<.x b={@dynamic} />)
        ])

      assert out == [~s(<.x site="Global" a="1" />)]
    end

    test "dedupes snippets that normalize to the same string" do
      out = Export.build_example_strings([~s(<.x   a="1" />), ~s(<.x a="1"   />)])
      assert out == [~s(<.x a="1" />)]
    end

    test "caps the list at five examples" do
      sources = for i <- 1..9, do: ~s(<.x a="#{i}" />)
      assert length(Export.build_example_strings(sources)) == 5
    end
  end

  describe "populate_examples/4 — dual-field contract (regression guard)" do
    @kit "chelekom"

    setup do
      bundle =
        :code.priv_dir(:mishka_chelekom)
        |> Path.join("components/chelekom.json")
        |> File.read!()
        |> Jason.decode!()

      # The kit set is built exactly as the task does — drives Heex extract + rewrite.
      kit_set =
        bundle["components"]
        |> MapSet.new(& &1["extra"]["function"])
        |> MapSet.delete(nil)

      # Isolate ONE real demo pair into a temp dir so the test is fast and hermetic.
      tmp = Path.join(System.tmp_dir!(), "demos_#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      on_exit(fn -> File.rm_rf!(tmp) end)

      demos = Path.join(:code.priv_dir(:mishka_chelekom), "demos")
      File.cp!(Path.join(demos, "card_live.html.heex"), Path.join(tmp, "card_live.html.heex"))
      File.cp!(Path.join(demos, "card_live.ex"), Path.join(tmp, "card_live.ex"))

      component = %{
        "name" => "chelekom-card",
        "extra" => %{"component" => "card", "function" => "card"}
      }

      %{kit_set: kit_set, demos_dir: tmp, component: component}
    end

    test "populates BOTH top-level examples AND extra.demo_examples", ctx do
      [result] = Export.populate_examples([ctx.component], ctx.demos_dir, ctx.kit_set, @kit)

      examples = result["examples"]
      demo_examples = get_in(result, ["extra", "demo_examples"])

      assert is_list(examples) and examples != []
      assert is_list(demo_examples) and demo_examples != []

      # `examples` — cleaned, self-contained strings for the CMS preview.
      assert length(examples) <= 5
      assert Enum.all?(examples, &is_binary/1)
      assert Enum.all?(examples, &(&1 =~ ~s(component_name="chelekom-card")))
      refute Enum.any?(examples, &(&1 =~ ":if="))
      refute Enum.any?(examples, &(&1 =~ "\n"))

      # `extra.demo_examples` — the rich invocation maps the DemoHarness renders.
      ex = hd(demo_examples)

      for key <- ["source", "raw_source", "line", "file", "assigns", "component"] do
        assert Map.has_key?(ex, key), "demo_example missing #{key}"
      end

      assert ex["component"] == "card"
      assert ex["file"] == "card_live.html.heex"
      assert ex["source"] =~ ~s(component_name="chelekom-card")
    end

    test "preserves existing extra keys while adding demo_examples", ctx do
      [result] = Export.populate_examples([ctx.component], ctx.demos_dir, ctx.kit_set, @kit)

      assert result["extra"]["component"] == "card"
      assert result["extra"]["function"] == "card"
      assert Map.has_key?(result["extra"], "demo_examples")
    end

    test "leaves components untouched when the demos dir does not exist", ctx do
      missing = Path.join(System.tmp_dir!(), "nope_#{System.unique_integer([:positive])}")
      refute File.dir?(missing)

      assert Export.populate_examples([ctx.component], missing, ctx.kit_set, @kit) == [
               ctx.component
             ]
    end
  end
end
