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
      override(:button, :root, "rounded-full")
    end

    test "__overrides__/0 returns the declared map" do
      assert TestOverrides.__overrides__() == %{{:button, :root} => "rounded-full"}
    end

    test "class_for resolves across configured modules (first wins)" do
      Application.put_env(:mishka_chelekom, :overrides, [
        TestOverrides,
        MishkaChelekom.Presets.Default
      ])

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
end
