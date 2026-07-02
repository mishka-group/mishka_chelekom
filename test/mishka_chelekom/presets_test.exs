defmodule MishkaChelekom.PresetsTest do
  # These tests flip the global `:mishka_chelekom, :overrides` env, so they must not
  # run concurrently with anything else that reads it.
  use ExUnit.Case, async: false

  alias MishkaChelekom.Overrides
  alias MishkaChelekom.Presets

  setup do
    # `Overrides.class_for/2` uses `function_exported?/3`, which only sees loaded modules;
    # ensure the presets are loaded so resolution is deterministic regardless of test order.
    Enum.each([Presets.Default, Presets.Flat, Presets.Bordered], &Code.ensure_loaded!/1)

    previous = Application.get_env(:mishka_chelekom, :overrides)

    on_exit(fn ->
      if previous == nil do
        Application.delete_env(:mishka_chelekom, :overrides)
      else
        Application.put_env(:mishka_chelekom, :overrides, previous)
      end
    end)

    :ok
  end

  describe "preset override maps" do
    test "Default is the empty, no-op preset" do
      assert Presets.Default.__overrides__() == %{}
    end

    test "Flat and Bordered declare non-empty, well-formed override maps" do
      for preset <- [Presets.Flat, Presets.Bordered] do
        overrides = preset.__overrides__()

        assert map_size(overrides) > 0, "#{inspect(preset)} should declare at least one override"

        Enum.each(overrides, fn {{component, part}, classes} ->
          assert is_atom(component), "#{inspect(preset)} component key must be an atom"
          assert is_atom(part), "#{inspect(preset)} part key must be an atom"

          assert is_binary(classes) and String.trim(classes) != "",
                 "#{inspect(preset)} #{inspect({component, part})} must map to a non-empty class string"
        end)
      end
    end

    test "presets express genuinely different design systems" do
      flat = Presets.Flat.__overrides__()
      bordered = Presets.Bordered.__overrides__()

      # both touch button/root, but with different intent
      assert Map.has_key?(flat, {:button, :root})
      assert Map.has_key?(bordered, {:button, :root})
      refute flat[{:button, :root}] == bordered[{:button, :root}]
    end

    test "Flat drops shadows and Bordered emphasizes borders" do
      assert Presets.Flat.__overrides__()[{:card, :root}] =~ "shadow-none"
      assert Presets.Bordered.__overrides__()[{:card, :root}] =~ "border"
    end
  end

  describe "resolution through the real Overrides engine" do
    test "class_for/2 resolves a configured preset's classes" do
      Application.put_env(:mishka_chelekom, :overrides, [Presets.Flat])

      assert Overrides.class_for(:button, :root) ==
               Presets.Flat.__overrides__()[{:button, :root}]

      assert Overrides.class_for(:card, :root) =~ "shadow-none"

      # a part the preset does not override resolves to nil
      assert Overrides.class_for(:button, :not_a_real_part) == nil
    end

    test "first configured module wins (Pyro-style resolution order)" do
      Application.put_env(:mishka_chelekom, :overrides, [Presets.Bordered, Presets.Flat])

      # both declare {:button, :root}; the first module listed must win
      assert Overrides.class_for(:button, :root) ==
               Presets.Bordered.__overrides__()[{:button, :root}]
    end

    test "merge/4 composes base + preset override + caller class into one deduped string" do
      Application.put_env(:mishka_chelekom, :overrides, [Presets.Flat])

      # base intentionally repeats the override token so we can prove de-duplication
      merged = Overrides.merge(:button, :root, "inline-flex shadow-none", "font-bold")

      # base is kept
      assert merged =~ "inline-flex"
      # the Flat preset override (button/root -> "shadow-none") is applied
      assert merged =~ "shadow-none"
      # the caller's class is present
      assert merged =~ "font-bold"

      # the token duplicated across base + override collapses to a single occurrence
      # (default merger keeps the last occurrence so caller classes reliably win)
      shadow_tokens = merged |> String.split() |> Enum.count(&(&1 == "shadow-none"))
      assert shadow_tokens == 1
    end
  end
end
