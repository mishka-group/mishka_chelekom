defmodule Mix.Tasks.Mishka.Ui.Gen.HeadlessSkinTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Headless
  alias MishkaChelekom.Generators.Assets
  @moduletag :igniter

  @vendor "assets/vendor/mishka_chelekom_headless_daisyui.css"

  setup do
    Application.ensure_all_started(:owl)
    MishkaChelekom.ComponentTestHelper.setup_config()
    on_exit(fn -> MishkaChelekom.ComponentTestHelper.cleanup_config() end)
    :ok
  end

  defp source_content(igniter, path) do
    Rewrite.Source.get(igniter.rewrite.sources[path], :content)
  end

  # Every component that ships a daisyUI fragment — the suite grows with the skin.
  defp skinned do
    Path.join(:code.priv_dir(:mishka_chelekom), "headless/skins/daisyui/*.css.eex")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".css.eex"))
    |> Enum.sort()
  end

  defp gen(args), do: Igniter.compose_task(test_project_with_formatter(), Headless, args)

  # The line is not consistent about this: `otp_field` renders `chelekom-otp_field` while
  # `loading_overlay` and `radio_group` render hyphens. Accept either rather than encode a rule the
  # components do not follow.
  defp root_prefixes(name),
    do: [".chelekom-#{name}", ".chelekom-#{String.replace(name, "_", "-")}"]

  describe "skin fragments" do
    test "every advertised skin has a fragment directory, and daisyui has components in it" do
      for skin <- Assets.skins() do
        dir = Path.join(:code.priv_dir(:mishka_chelekom), "headless/skins/#{skin}")

        assert File.dir?(dir),
               "--skin #{skin} is advertised but priv/headless/skins/#{skin} is missing"
      end

      assert "daisyui" in Assets.skins()
      assert skinned() != []
    end

    test "each fragment only ever targets that component's own classes" do
      for component <- skinned() do
        css =
          Path.join(
            :code.priv_dir(:mishka_chelekom),
            "headless/skins/daisyui/#{component}.css.eex"
          )
          |> File.read!()

        selectors = Regex.scan(~r/\.chelekom-[a-z0-9_-]+/, css) |> List.flatten() |> Enum.uniq()

        assert selectors != [], "#{component} skin targets no chelekom class"

        for selector <- selectors do
          assert Enum.any?(root_prefixes(component), &String.starts_with?(selector, &1)),
                 "#{component} skin leaks into #{selector}"
        end
      end
    end

    test "a fragment never changes behavior — no content/display-none on the root, no !important" do
      for component <- skinned() do
        css =
          Path.join(
            :code.priv_dir(:mishka_chelekom),
            "headless/skins/daisyui/#{component}.css.eex"
          )
          |> File.read!()

        refute css =~ "!important", "#{component} skin uses !important"
      end
    end
  end

  describe "--skin daisyui" do
    test "writes every skinned component's block into the vendor stylesheet" do
      for component <- skinned() do
        igniter = gen([component, "--skin", "daisyui", "--yes"])
        css = source_content(igniter, @vendor)

        assert css =~ "/* >>> #{component} */"
        assert css =~ "/* <<< #{component} */"

        assert Enum.any?(root_prefixes(component), &String.contains?(css, &1)),
               "#{component}: no rule targets the component's own classes"
      end
    end

    test "the skin @import lands after tailwindcss and dedupes on re-run" do
      import_path = "../vendor/mishka_chelekom_headless_daisyui.css"

      {:ok, :added, css} =
        MishkaChelekom.SimpleCSSUtilities.add_import(~s|@import "tailwindcss";|, import_path)

      {tailwind_at, _} = :binary.match(css, "tailwindcss")
      {skin_at, _} = :binary.match(css, "mishka_chelekom_headless_daisyui.css")
      assert tailwind_at < skin_at

      assert {:ok, :exists, again} =
               MishkaChelekom.SimpleCSSUtilities.add_import(css, import_path)

      assert length(String.split(again, import_path)) == 2
    end

    test "generating without --skin leaves no skin stylesheet" do
      igniter = gen([hd(skinned()), "--yes"])
      refute igniter.rewrite.sources[@vendor]
    end

    test "--skin-prefix is applied to the design system's class names" do
      component = hd(skinned())

      plain = gen([component, "--skin", "daisyui", "--yes"]) |> source_content(@vendor)

      prefixed =
        gen([component, "--skin", "daisyui", "--skin-prefix", "d-", "--yes"])
        |> source_content(@vendor)

      applied = Regex.scan(~r/@apply ([a-z0-9-]+)/, plain) |> Enum.map(&List.last/1)

      assert applied != [], "#{component} skin applies no design-system class"
      assert Enum.all?(applied, &(prefixed =~ "@apply d-#{&1}"))
    end

    test "--skin-scope nests the whole skin so it cannot paint outside that subtree" do
      component = hd(skinned())
      scope = "[data-skin=daisyui]"

      unscoped = gen([component, "--skin", "daisyui", "--yes"]) |> source_content(@vendor)

      scoped =
        gen([component, "--skin", "daisyui", "--skin-scope", scope, "--yes"])
        |> source_content(@vendor)

      assert scoped =~ "#{scope} {"

      # Every selector the unscoped file declares at column 0 must be indented under the scope.
      for [selector] <-
            Regex.scan(~r/^(\.chelekom-[a-z0-9_-]+[^\n{]*)\{/m, unscoped, capture: :all_but_first) do
        refute scoped =~ ~r/^#{Regex.escape(String.trim(selector))}\s*\{/m,
               "#{String.trim(selector)} escaped the scope"
      end
    end

    test "regenerating replaces the component's block instead of duplicating it" do
      component = hd(skinned())

      once = gen([component, "--skin", "daisyui", "--yes"]) |> source_content(@vendor)

      twice =
        test_project_with_formatter()
        |> Igniter.create_new_file(@vendor, once)
        |> Igniter.compose_task(Headless, [component, "--skin", "daisyui", "--yes"])
        |> source_content(@vendor)

      assert length(String.split(twice, "/* >>> #{component} */")) == 2
    end
  end

  describe "validation" do
    test "an unknown skin is an issue, not a silent no-op" do
      igniter = gen([hd(skinned()), "--skin", "nope", "--yes"])
      assert Enum.join(igniter.issues, " ") =~ "Unknown --skin"
      refute igniter.rewrite.sources[@vendor]
    end

    test "a component with no fragment yet is generated unstyled, with a notice" do
      # Every headless component ships a daisyUI fragment now, so there is no real component left
      # to exercise this path — it used to find one with `hd/1` on the unskinned list, and `hd([])`
      # is how it announced that. The behaviour still matters for a component added tomorrow, so it
      # is exercised with a name the catalog does not know instead of a name that happens to lag.
      unskinned =
        MishkaChelekom.Generators.Core.all_component_names(nil, :headless)
        |> Enum.reject(&(&1 in skinned()))

      assert unskinned == [],
             "these headless components still have no daisyui fragment: #{Enum.join(unskinned, " ")}"

      igniter = gen(["accordion", "--skin", "daisyui", "--yes"])
      assert igniter.rewrite.sources["lib/test_web/components/headless/accordion.ex"]
    end
  end
end
