defmodule MishkaChelekom.CmsBundle.ShowcaseTest do
  @moduledoc """
  Authored examples lie OVER the harvest, and only for the components that have
  one.

  The constraint that shapes every test here: the harvest keeps working exactly
  as it did. `MishkaChelekom.CmsBundle.Examples` and its regression guards are
  not touched by this feature, so a component with no showcase file has to come
  out the far side byte-identical.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.Showcase

  @harvested %{
    "name" => "chelekom-card",
    "examples" => [
      "<.component component_name=\"chelekom-card\" site=\"Global\">Base</.component>"
    ],
    "extra" => %{
      "function" => "card",
      "demo_examples" => [%{"source" => "<.component component_name=\"chelekom-card\"/>"}],
      "examples" => [
        %{
          "source" =>
            "<.component component_name=\"chelekom-card\" site=\"Global\">Base</.component>",
          "label" => "Base",
          "section" => "card-base",
          "base" => true,
          "requires" => %{}
        }
      ]
    }
  }

  # `requires` is the intersection of the markup's root attrs with the options the
  # component actually ships, so a component with no discriminators requires
  # nothing however it is written.
  defp with_options(component) do
    put_in(component["helpers"], [
      %{
        "name" => "color_variant",
        "discriminators" => [%{"axis" => "variant", "values" => ["default", "outline"]}]
      }
    ])
  end

  defp write!(dir, name, json) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "#{name}.json"), Jason.encode!(json))
  end

  setup do
    dir = Path.join(System.tmp_dir!(), "showcase-#{System.unique_integer([:positive])}")
    on_exit(fn -> File.rm_rf(dir) end)
    {:ok, dir: dir}
  end

  describe "overlay/2" do
    test "a kit that has authored nothing is untouched", %{dir: dir} do
      assert Showcase.overlay([@harvested], dir) == [@harvested]
      assert Showcase.overlay([@harvested], Path.join(dir, "nope")) == [@harvested]
    end

    test "a component with no file of its own is untouched", %{dir: dir} do
      write!(dir, "chelekom-banner", %{
        "name" => "chelekom-banner",
        "examples" => [%{"label" => "Cookie notice", "source" => "<.component/>"}]
      })

      assert Showcase.overlay([@harvested], dir) == [@harvested]
    end

    test "authored examples replace the harvested ones", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{"label" => "Pricing card", "source" => "<.component>Pro</.component>"},
          %{"label" => "Profile card", "source" => "<.component>Ada</.component>"}
        ]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert Enum.map(result["extra"]["examples"], & &1["label"]) == [
               "Pricing card",
               "Profile card"
             ]

      assert result["examples"] == [
               "<.component>Pro</.component>",
               "<.component>Ada</.component>"
             ]
    end

    # The demo harness renders these, and nothing about authoring a nicer example
    # makes them less true.
    test "the harvested demo_examples survive", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [%{"label" => "Pricing card", "source" => "<.component/>"}]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert result["extra"]["demo_examples"] == @harvested["extra"]["demo_examples"]
      assert result["extra"]["function"] == "card"
    end

    test "the first authored example is the base", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{"label" => "One", "source" => "<.component/>"},
          %{"label" => "Two", "source" => "<.component/>"}
        ]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert Enum.map(result["extra"]["examples"], & &1["base"]) == [true, false]
    end

    # A minimal install ships only the default variant, so an example pinned to
    # one it did not receive has to be hideable — the same `requires` the harvest
    # emits, in the same shape, and read off the markup for the same reason.
    test "a non-default option is read off the markup", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{
            "label" => "Outlined",
            "source" =>
              ~s(<.component component_name="chelekom-card" site="Global" variant="outline">Hi</.component>)
          }
        ]
      })

      [result] = Showcase.overlay([with_options(@harvested)], dir)

      assert [%{"requires" => %{"variant" => ["outline"]}}] = result["extra"]["examples"]
    end

    # Asked to LIST the options they used, an author writes prose. Read off the
    # markup, there is nothing to get wrong — and a class that is not one of the
    # component's options is a Tailwind passthrough, not a requirement.
    test "a Tailwind class is not mistaken for an option", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{
            "label" => "Narrow",
            "source" =>
              ~s(<.component component_name="chelekom-card" site="Global" class="max-w-sm" size="nonsense">Hi</.component>)
          }
        ]
      })

      [result] = Showcase.overlay([with_options(@harvested)], dir)

      assert [%{"requires" => requires}] = result["extra"]["examples"]
      assert requires == %{}
    end

    # A block wrapped in a plain `<div>` pins nothing: the options inside belong to
    # its children, and an install missing one of those still renders the block.
    test "a block with no component at its root requires nothing", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{
            "label" => "Grid of cards",
            "source" =>
              ~s(<div class="grid"><.component component_name="chelekom-card" site="Global" variant="outline">Hi</.component></div>)
          }
        ]
      })

      [result] = Showcase.overlay([with_options(@harvested)], dir)

      assert [%{"requires" => %{}}] = result["extra"]["examples"]
    end

    # A finished block composes: a pricing card is a card, a title, a badge and a button. An install
    # that took the card without the badge would render it with a hole, so `requires` has to name
    # what the block dispatches to — the rule the harvest already follows, and the one the shipped
    # bundle's own regression guard checks.
    test "the components an example composes are required too", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{
            "label" => "Pricing card",
            "source" => """
            <.component component_name="chelekom-card" site="Global">
              <.component component_name="chelekom-card-title" site="Global">Pro</.component>
              <.component component_name="chelekom-badge" site="Global">Popular</.component>
            </.component>
            """
          }
        ]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert [%{"requires" => requires}] = result["extra"]["examples"]
      assert Enum.sort(requires["components"]) == ["chelekom-badge", "chelekom-card-title"]
    end

    # An example of a card is expected to contain a card; naming itself would be noise.
    test "a block that composes nothing requires no components", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "examples" => [
          %{
            "label" => "Plain",
            "source" =>
              ~s(<.component component_name="chelekom-card" site="Global">Hi</.component>)
          }
        ]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert [%{"requires" => requires}] = result["extra"]["examples"]
      refute Map.has_key?(requires, "components")
    end

    test "the drop default is carried through as furnishing", %{dir: dir} do
      write!(dir, "chelekom-card", %{
        "name" => "chelekom-card",
        "furnishing" => %{"body" => "A card", "slots" => []},
        "examples" => [%{"label" => "Pricing card", "source" => "<.component/>"}]
      })

      [result] = Showcase.overlay([@harvested], dir)

      assert result["extra"]["furnishing"] == %{"body" => "A card", "slots" => []}
    end

    # `_schema.json` sits in the directory for authors to validate against. Read as
    # a component's showcase it would fail and warn on every single export.
    test "a file about the showcase is not read as one", %{dir: dir} do
      File.mkdir_p!(dir)
      File.write!(Path.join(dir, "_schema.json"), Jason.encode!(%{"title" => "schema"}))

      assert Showcase.overlay([@harvested], dir) == [@harvested]
    end

    # A showcase file is content, hand-edited, often by somebody not watching the
    # export run. One bad file costs its own component and the bundle still ships.
    test "a malformed file is skipped rather than fatal", %{dir: dir} do
      File.mkdir_p!(dir)
      File.write!(Path.join(dir, "broken.json"), "{not json")
      write!(dir, "no-name", %{"examples" => [%{"label" => "x", "source" => "y"}]})
      write!(dir, "no-examples", %{"name" => "chelekom-card"})

      write!(dir, "blank-source", %{
        "name" => "chelekom-card",
        "examples" => [%{"label" => "x", "source" => "  "}]
      })

      assert Showcase.overlay([@harvested], dir) == [@harvested]
    end
  end
end
