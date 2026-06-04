defmodule MishkaChelekom.Layer3Test do
  use ExUnit.Case, async: false

  alias MishkaChelekom.{CSS, Overrides}

  describe "CSS.classes/1 (built-in dedupe seam)" do
    test "flattens nested/conditional inputs and drops nil/false" do
      assert CSS.classes(["px-2 py-1", nil, {true, "font-bold"}, {false, "hidden"}]) ==
               "px-2 py-1 font-bold"
    end

    test "dedupes tokens keeping the last occurrence so caller classes win" do
      assert CSS.classes(["text-sm font-bold", "text-sm"]) == "font-bold text-sm"
    end

    test "honors a configured class_merger" do
      Application.put_env(:mishka_chelekom, :class_merger, fn s -> String.upcase(s) end)
      on_exit(fn -> Application.delete_env(:mishka_chelekom, :class_merger) end)
      assert CSS.classes(["px-2"]) == "PX-2"
    end
  end

  describe "Overrides" do
    defmodule TestOverrides do
      use MishkaChelekom.Overrides
      override :button, :root, "rounded-full"
    end

    test "__overrides__/0 returns the declared map" do
      assert TestOverrides.__overrides__() == %{{:button, :root} => "rounded-full"}
    end

    test "class_for resolves across configured modules (first wins)" do
      Application.put_env(:mishka_chelekom, :overrides, [TestOverrides, MishkaChelekom.Presets.Default])
      on_exit(fn -> Application.delete_env(:mishka_chelekom, :overrides) end)

      assert Overrides.class_for(:button, :root) == "rounded-full"
      assert Overrides.class_for(:button, :missing) == nil
    end

    test "merge composes base + override + user with user winning" do
      Application.put_env(:mishka_chelekom, :overrides, [TestOverrides])
      on_exit(fn -> Application.delete_env(:mishka_chelekom, :overrides) end)

      assert Overrides.merge(:button, :root, "px-3", "px-3") == "rounded-full px-3"
    end
  end

  describe "Spark DSL (MishkaChelekom.Theme)" do
    test "a valid theme module compiles and is introspectable" do
      defmodule ValidTheme do
        use MishkaChelekom.Theme

        variants do
          default :primary
          variant :primary, classes: "bg-primary"
          variant :ghost, classes: "bg-transparent"
        end

        theme do
          token :radius, value: "0.5rem"
        end
      end

      names = ValidTheme |> MishkaChelekom.Theme.Info.variants() |> Enum.map(& &1.name)
      assert :primary in names and :ghost in names
      assert MishkaChelekom.Theme.Info.variants_default!(ValidTheme) == :primary
      assert [%{name: :radius, value: "0.5rem"}] = MishkaChelekom.Theme.Info.theme(ValidTheme)
    end

    test "an undeclared default variant is reported at compile time" do
      code = """
      defmodule MishkaChelekom.Layer3Test.BadTheme do
        use MishkaChelekom.Theme
        variants do
          default :nope
          variant :primary, classes: "bg-primary"
        end
      end
      """

      # Spark runs verifiers in the parallel-checker phase, so the DslError surfaces as a
      # compile diagnostic rather than a synchronous raise.
      {_result, diagnostics} =
        Code.with_diagnostics(fn ->
          try do
            Code.compile_string(code)
          rescue
            e -> e
          end
        end)

      assert Enum.any?(diagnostics, fn d ->
               is_binary(d.message) and d.message =~ "default variant :nope is not declared"
             end)
    end
  end
end
