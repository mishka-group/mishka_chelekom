defmodule MishkaChelekom.KitTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.Kit.Info
  alias MishkaChelekom.Kit.Entities.{Rule, Part, Customize}

  # ── stub "real" components (stand in for the user's generated Mishka components) ──────────

  defmodule Components.Button do
    use Phoenix.Component
    attr(:variant, :string, default: "base")
    attr(:color, :string, default: "base")
    attr(:class, :any, default: nil)
    attr(:rest, :global)
    slot(:inner_block)

    def button(assigns) do
      ~H|<button class={["btn", vc(@variant), cc(@color), @class]} {@rest}>{render_slot(@inner_block)}</button>|
    end

    defp vc("base"), do: "v-base"
    defp cc("base"), do: "c-base"
    defp cc("primary"), do: "c-primary"
  end

  defmodule Components.Alert do
    use Phoenix.Component
    attr(:kind, :atom, default: :base)
    attr(:class, :any, default: nil)
    slot(:inner_block)

    def alert(assigns),
      do: ~H|<div class={["alert", kc(@kind), @class]}>{render_slot(@inner_block)}</div>|

    defp kc(:base), do: "k-base"
  end

  defmodule Components.Headless.Accordion do
    use Phoenix.Component
    attr(:id, :string, required: true)
    attr(:open, :boolean, default: false)
    attr(:class, :any, default: nil)
    slot(:item)

    def accordion(assigns) do
      ~H|<div id={@id} data-open={@open} class={["chelekom-accordion", @class]}><span data-part="trigger" :for={i <- @item}>{render_slot(i)}</span></div>|
    end
  end

  # a stub under a CUSTOM namespace (for the `components`/`base` tests)
  defmodule Ns.Tag do
    use Phoenix.Component
    attr(:color, :string, default: "neutral")
    attr(:class, :any, default: nil)
    slot(:inner_block)

    def tag(assigns),
      do: ~H|<span class={["tag", tc(@color), @class]}>{render_slot(@inner_block)}</span>|

    defp tc("neutral"), do: "t-neutral"
  end

  # ── kits under test ──────────────────────────────────────────────────────────────────────

  defmodule Kit do
    use MishkaChelekom.Kit

    customize :button do
      # replace (exists)
      color :primary, "bg-indigo-600 text-white"
      # add (new)
      color :brand, "bg-brand-500"
      # add (new)
      variant :glow, "shadow-glow hover:opacity-90"
      default color: "brand"
    end

    customize :alert do
      # atom-typed dimension
      kind :brand, "bg-brand-100 text-brand-700"
      default kind: :brand
    end

    # a renamed customize: a different generated name, reusing `button`
    customize :fancy_button do
      from :button
      color :gold, "bg-amber-500"
      default color: "gold"
    end

    # headless (decided by `part` rules)
    customize :faq do
      from :accordion
      part :trigger, "py-3 font-medium"
      part :panel, "pb-3 text-sm"
      default open: true
    end
  end

  defmodule NsKit do
    use MishkaChelekom.Kit
    components MishkaChelekom.KitTest.Ns

    customize :tag do
      base "neutral"
      color :brand, "bg-brand"
      default color: "brand"
    end
  end

  defmodule Page do
    use Phoenix.Component
    import MishkaChelekom.KitTest.Kit
    import MishkaChelekom.KitTest.NsKit

    def show_button(assigns), do: ~H|<.button variant={@variant} color={@color}>x</.button>|
    def show_alert(assigns), do: ~H|<.alert>x</.alert>|
    def show_fancy(assigns), do: ~H|<.fancy_button>x</.fancy_button>|
    def show_faq(assigns), do: ~H|<.faq id="f"><:item>Q</:item></.faq>|
    def show_tag(assigns), do: ~H|<.tag>t</.tag>|
  end

  defp html(fun, assigns) do
    assigns
    |> Map.put(:__changed__, nil)
    |> fun.()
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  # ── styled: add / replace ────────────────────────────────────────────────────────────────

  describe "customize styled — replace vs add" do
    test "replace: original value's classes are dropped; yours win as !important" do
      out = html(&Page.show_button/1, %{variant: "base", color: "primary"})
      assert out =~ "c-base"
      refute out =~ "c-primary"
      assert out =~ "bg-indigo-600! text-white!"
    end

    test "add: a brand-new color renders over the safe base" do
      out = html(&Page.show_button/1, %{variant: "base", color: "brand"})
      assert out =~ "c-base"
      assert out =~ "bg-brand-500!"
    end

    test "add: a brand-new variant; trailing-! is applied per utility (incl. variants)" do
      out = html(&Page.show_button/1, %{variant: "glow", color: "base"})
      assert out =~ "v-base"
      assert out =~ "shadow-glow! hover:opacity-90!"
    end

    test "untouched values pass straight through" do
      out = html(&Page.show_button/1, %{variant: "base", color: "base"})
      assert out =~ "v-base"
      assert out =~ "c-base"
      refute out =~ "!"
    end
  end

  # ── defaults ─────────────────────────────────────────────────────────────────────────────

  describe "customize — default props" do
    test "default applies when the prop is not passed" do
      out = html(&Page.show_button/1, %{variant: "base", color: nil})
      assert out =~ "bg-brand-500!"
    end

    test "default does not override an explicitly-passed value" do
      out = html(&Page.show_button/1, %{variant: "base", color: "primary"})
      assert out =~ "bg-indigo-600!"
      refute out =~ "bg-brand-500!"
    end
  end

  # ── atom-typed dimension ─────────────────────────────────────────────────────────────────

  describe "customize — atom attr (alert's kind)" do
    test "atom type is preserved through the remap to base" do
      out = html(&Page.show_alert/1, %{})
      assert out =~ "k-base"
      assert out =~ "bg-brand-100! text-brand-700!"
    end
  end

  # ── renamed / from ───────────────────────────────────────────────────────────────────────

  describe "customize — `from` resolution" do
    test "from defaults to the name (customize :button → Components.Button)" do
      assert function_exported?(Kit, :button, 1)
    end

    test "a renamed customize delegates to `from` but is callable under its own name" do
      out = html(&Page.show_fancy/1, %{})
      # delegated to Components.Button
      assert out =~ "btn"
      # with the fancy color
      assert out =~ "bg-amber-500!"
    end
  end

  # ── headless (part rules) ────────────────────────────────────────────────────────────────

  describe "customize headless — `part` rules" do
    test "parts compile to [&_[data-part=…]]: variants on the root + defaults apply" do
      out = html(&Page.show_faq/1, %{})
      assert out =~ "data-open"
      assert out =~ "[data-part=trigger]]:py-3"
      assert out =~ "[data-part=trigger]]:font-medium"
      assert out =~ "[data-part=panel]]:pb-3"
    end
  end

  # ── namespace + base override ────────────────────────────────────────────────────────────

  describe "customize — `components` namespace + `base` override" do
    test "delegates to the configured namespace, remapping to the custom base" do
      out = html(&Page.show_tag/1, %{})
      # remapped to base \"neutral\" (Ns.Tag), not \"base\"
      assert out =~ "t-neutral"
      assert out =~ "bg-brand!"
    end
  end

  # ── safelist ─────────────────────────────────────────────────────────────────────────────

  describe "safelist/1" do
    test "includes styled classes (plain + !important) and headless part variants, deduped" do
      list = MishkaChelekom.Kit.safelist(Kit)
      assert "bg-indigo-600" in list and "bg-indigo-600!" in list
      assert "shadow-glow" in list and "shadow-glow!" in list
      assert "[&_[data-part=trigger]]:py-3" in list
      assert "[&_[data-part=panel]]:pb-3" in list
      assert list == Enum.uniq(list)
    end
  end

  # ── introspection ────────────────────────────────────────────────────────────────────────

  describe "Info" do
    test "customizes/1 returns every customize as a struct" do
      names = Kit |> Info.customizes() |> Enum.map(& &1.name) |> Enum.sort()
      assert names == [:alert, :button, :fancy_button, :faq]
      assert %Customize{from: :accordion} = Enum.find(Info.customizes(Kit), &(&1.name == :faq))
    end

    test "rules carry their attr/value/classes (styled) or name/classes (headless)" do
      button = Enum.find(Info.customizes(Kit), &(&1.name == :button))

      assert %Rule{attr: :color, value: :primary} =
               Enum.find(button.rules, &match?(%Rule{value: :primary}, &1))

      faq = Enum.find(Info.customizes(Kit), &(&1.name == :faq))
      assert %Part{name: :trigger} = Enum.find(faq.rules, &match?(%Part{name: :trigger}, &1))
    end
  end

  # ── compile-time verifiers ───────────────────────────────────────────────────────────────

  describe "verifier — rules" do
    test "no rules is a compile error" do
      assert compile_error("customize :button do\nend") =~ "declares no rules"
    end

    test "mixing styled rules with `part` is a compile error" do
      assert compile_error(
               ~s|customize :button do\n  color :brand, "x"\n  part :trigger, "y"\nend|
             ) =~
               "mixes styled rules"
    end
  end

  describe "verifier — catalog" do
    test "an unknown `from` is a compile error with a suggestion, at compile time" do
      msg = compile_error(~s|customize :x do\n  from :buton\n  color :brand, "x"\nend|)
      assert msg =~ "is not a styled Mishka component"
      assert msg =~ "Did you mean :button?"
    end

    test "two customizes generating the same name is a compile error" do
      assert compile_error(
               ~s|customize :button do\n  color :brand, "x"\nend\ncustomize :button do\n  color :gold, "y"\nend|
             ) =~
               "both generate :button"
    end

    test "the catalog check is skipped when a custom namespace is set (NsKit compiled fine)" do
      assert function_exported?(NsKit, :tag, 1)
    end
  end

  defp compile_error(body) do
    code =
      "defmodule MishkaChelekom.KitTest.Bad#{:erlang.unique_integer([:positive])} do\n" <>
        "  use MishkaChelekom.Kit\n  #{body}\nend"

    {{_, diagnostics}, _stderr} =
      ExUnit.CaptureIO.with_io(:stderr, fn ->
        Code.with_diagnostics(fn ->
          try do
            Code.compile_string(code)
          rescue
            e -> e
          end
        end)
      end)

    diagnostics
    |> Enum.map(& &1.message)
    |> Enum.filter(&is_binary/1)
    |> Enum.join("\n")
  end
end
