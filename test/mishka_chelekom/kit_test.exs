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

    # generic so any pass-through value renders (v-base, c-primary, c-secondary, …)
    defp vc(v), do: "v-#{v}"
    defp cc(c), do: "c-#{c}"
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

  # a component the naming convention could NEVER find: odd module path + an odd function name
  defmodule Weird.Thing do
    use Phoenix.Component
    attr(:color, :string, default: "plain")
    attr(:class, :any, default: nil)
    slot(:inner_block)

    def render(assigns),
      do: ~H|<i class={["weird", wc(@color), @class]}>{render_slot(@inner_block)}</i>|

    defp wc(c), do: "w-#{c}"
  end

  # ── kits under test ──────────────────────────────────────────────────────────────────────

  defmodule Kit do
    use MishkaChelekom.Kit

    customize :button do
      # replace (exists) — classes written verbatim, incl. the `!` for precedence
      color :primary, "bg-indigo-600! text-white!"
      # add (new)
      color :brand, "bg-brand-500!"
      # add (new)
      variant :glow, "shadow-glow! hover:opacity-90!"
      default color: "brand"
    end

    customize :alert do
      # atom-typed dimension
      kind :brand, "bg-brand-100! text-brand-700!"
      default kind: :brand
    end

    # a renamed customize: a different generated name, reusing `button`
    customize :fancy_button do
      from :button
      color :gold, "bg-amber-500!"
      default color: "gold"
    end

    # variant×color PAIR rules — classes apply only to that exact combo
    customize :paired_button do
      from :button
      # existing × existing → replace
      variant :outline, "ring-2! ring-rose-500!", color: "danger"
      # new variant × existing color
      variant :promo, "bg-rose-600! ring-4!", color: "danger"
      # same variant, different color → distinct pair
      variant :outline, "border! border-fuchsia-600!", color: "brand"
      # a single rule that COEXISTS
      color :brand, "bg-fuchsia-600!"
    end

    # a pair whose partner is supplied by `default` (not by the caller)
    customize :default_paired do
      from :button
      variant :outline, "ring-2! ring-rose-500!", color: "danger"
      default color: "danger"
    end

    # ONLY pair rules (no single rules) + two identical matches to prove first-match wins
    customize :ordered_pairs do
      from :button
      variant :outline, "first!", color: "danger"
      variant :outline, "second!", color: "danger"
    end

    # a pair remapping to a CUSTOM base
    customize :based_paired do
      from :button
      base "neutral"
      variant :outline, "ring-2!", color: "danger"
    end

    # `from {Module, :function}` — point at an exact module/function, bypassing the convention
    customize :gizmo do
      from {MishkaChelekom.KitTest.Weird.Thing, :render}
      base "plain"
      color :brand, "text-lime-500!"
      default color: "brand"
    end

    # headless (decided by `part` rules) — full [&_[data-part=…]]: variants, verbatim
    customize :faq do
      from :accordion
      part :trigger, "[&_[data-part=trigger]]:py-3 [&_[data-part=trigger]]:font-medium"
      part :panel, "[&_[data-part=panel]]:pb-3 [&_[data-part=panel]]:text-sm"
      default open: true
    end
  end

  defmodule NsKit do
    use MishkaChelekom.Kit
    components MishkaChelekom.KitTest.Ns

    customize :tag do
      base "neutral"
      color :brand, "bg-brand!"
      default color: "brand"
    end
  end

  defmodule Page do
    use Phoenix.Component
    import MishkaChelekom.KitTest.Kit
    import MishkaChelekom.KitTest.NsKit

    def show_button(assigns), do: ~H|<.button variant={@variant} color={@color}>x</.button>|

    def show_paired(assigns),
      do: ~H|<.paired_button variant={@variant} color={@color}>x</.paired_button>|

    def show_default_paired(assigns),
      do: ~H|<.default_paired variant={@variant}>x</.default_paired>|

    def show_ordered(assigns),
      do: ~H|<.ordered_pairs variant={@variant} color={@color}>x</.ordered_pairs>|

    def show_based(assigns),
      do: ~H|<.based_paired variant={@variant} color={@color}>x</.based_paired>|

    def show_gizmo(assigns), do: ~H|<.gizmo>g</.gizmo>|
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

  # ── styled: variant×color PAIR rules ─────────────────────────────────────────────────────

  describe "customize styled — variant×color pair rules" do
    test "existing × existing: the combo matches; BOTH dims remap to base; pair classes win" do
      out = html(&Page.show_paired/1, %{variant: "outline", color: "danger"})
      assert out =~ "v-base"
      assert out =~ "c-base"
      assert out =~ "ring-2! ring-rose-500!"
      # the other rules did NOT fire
      refute out =~ "border! border-fuchsia-600!"
      refute out =~ "bg-rose-600!"
    end

    test "new variant × existing color" do
      out = html(&Page.show_paired/1, %{variant: "promo", color: "danger"})
      assert out =~ "v-base"
      assert out =~ "c-base"
      assert out =~ "bg-rose-600! ring-4!"
    end

    test "same variant, different color is a DIFFERENT pair" do
      out = html(&Page.show_paired/1, %{variant: "outline", color: "brand"})
      assert out =~ "border! border-fuchsia-600!"
      refute out =~ "ring-2! ring-rose-500!"
    end

    test "a matched pair takes precedence — the coexisting single color:brand is skipped" do
      out = html(&Page.show_paired/1, %{variant: "outline", color: "brand"})
      assert out =~ "border! border-fuchsia-600!"
      refute out =~ "bg-fuchsia-600!"
    end

    test "single rule still fires when no pair matches that combo" do
      out = html(&Page.show_paired/1, %{variant: "base", color: "brand"})
      refute out =~ "border! border-fuchsia-600!"
      assert out =~ "bg-fuchsia-600!"
      assert out =~ "c-base"
    end

    test "untouched combo passes straight through (no pair, no single)" do
      out = html(&Page.show_paired/1, %{variant: "base", color: "secondary"})
      assert out =~ "v-base"
      assert out =~ "c-secondary"
      refute out =~ "!"
    end

    test "a pair matches when its partner is supplied by `default`, not the caller" do
      # caller passes only variant; `default color: \"danger\"` fills the partner → pair fires
      out = html(&Page.show_default_paired/1, %{variant: "outline"})
      assert out =~ "v-base"
      assert out =~ "c-base"
      assert out =~ "ring-2! ring-rose-500!"
    end

    test "first matching pair wins; a later identical pair is ignored" do
      out = html(&Page.show_ordered/1, %{variant: "outline", color: "danger"})
      assert out =~ "first!"
      refute out =~ "second!"
    end

    test "a pairs-only customize (no single rules) passes unmatched combos straight through" do
      out = html(&Page.show_ordered/1, %{variant: "base", color: "secondary"})
      assert out =~ "v-base"
      assert out =~ "c-secondary"
      refute out =~ "!"
    end

    test "a pair remaps to the customize's custom `base`, not \"base\"" do
      out = html(&Page.show_based/1, %{variant: "outline", color: "danger"})
      assert out =~ "v-neutral"
      assert out =~ "c-neutral"
      assert out =~ "ring-2!"
    end
  end

  # ── styled: pair guardrail (compile-time) ────────────────────────────────────────────────

  describe "customize styled — pinning your OWN axis is rejected" do
    test "a `color` rule with a `color:` partner is rejected at compile time" do
      # The Spark verifier raises a DslError during compilation; Code.eval_string surfaces it as a
      # compiler diagnostic, so capture it that way (a real `.ex` file hard-fails to compile).
      {_, diagnostics} =
        Code.with_diagnostics(fn ->
          try do
            Code.eval_string("""
            defmodule BadOwnAxisKit#{System.unique_integer([:positive])} do
              use MishkaChelekom.Kit
              customize :x do
                from :button
                color :brand, "bg-x!", color: :danger
              end
            end
            """)
          rescue
            _ -> :ok
          end
        end)

      assert Enum.any?(diagnostics, &(to_string(&1.message) =~ "OWN axis"))
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

  # ── from {Module, :function} ─────────────────────────────────────────────────────────────

  describe "customize — `from {Module, :function}` (explicit target)" do
    test "delegates to the EXACT module + function, bypassing the naming convention" do
      out = html(&Page.show_gizmo/1, %{})

      # rendered by Weird.Thing.render/1 — proves the tuple was honoured (no Components.Gizmo exists)
      assert out =~ "<i"
      assert out =~ "weird"
      # color :brand applied; remapped to the custom base "plain"
      assert out =~ "w-plain"
      assert out =~ "text-lime-500!"
    end

    test "the tuple `from` is preserved in introspection" do
      gizmo = Kit |> Info.customizes() |> Enum.find(&(&1.name == :gizmo))
      assert gizmo.from == {MishkaChelekom.KitTest.Weird.Thing, :render}
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

  # ── introspection ────────────────────────────────────────────────────────────────────────

  describe "Info" do
    test "customizes/1 returns every customize as a struct" do
      names = Kit |> Info.customizes() |> Enum.map(& &1.name) |> Enum.sort()

      assert names == [
               :alert,
               :based_paired,
               :button,
               :default_paired,
               :fancy_button,
               :faq,
               :gizmo,
               :ordered_pairs,
               :paired_button
             ]

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
