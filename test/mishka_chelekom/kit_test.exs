defmodule MishkaChelekom.KitTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.Kit.Info

  # --- stub "real" components (stand in for the user's generated Mishka components) ---------

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

  # --- the Kit under test (uses convention to find the stubs above) -------------------------

  defmodule Kit do
    use MishkaChelekom.Kit

    customize :button do
      # replace (name exists)
      color :primary, "bg-indigo-600 text-white"
      # add (new name)
      color :brand, "bg-brand-500"
      # add
      variant :glow, "shadow-glow hover:opacity-90"
      default color: "brand"
    end

    customize :alert do
      # atom-typed dimension
      kind :brand, "bg-brand-100 text-brand-700"
      default kind: :brand
    end

    customize :faq do
      from :accordion
      part :trigger, "py-3 font-medium"
      part :panel, "pb-3 text-sm"
      default open: true
    end
  end

  defmodule Page do
    use Phoenix.Component
    import MishkaChelekom.KitTest.Kit

    def show_button(assigns), do: ~H|<.button variant={@variant} color={@color}>x</.button>|
    def show_alert(assigns), do: ~H|<.alert>x</.alert>|
    def show_faq(assigns), do: ~H|<.faq id="f"><:item>Q</:item></.faq>|
  end

  defp html(fun, assigns) do
    assigns
    |> Map.put(:__changed__, nil)
    |> fun.()
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  describe "customize (styled) — generates a wrapper delegating to the real component" do
    test "replace: an existing value's classes are swapped for yours (important wins, original dropped)" do
      out = html(&Page.show_button/1, %{variant: "base", color: "primary"})
      # remapped to neutral base
      assert out =~ "c-base"
      # original primary classes dropped
      refute out =~ "c-primary"
      assert out =~ "bg-indigo-600! text-white!"
    end

    test "add: a brand-new color renders your classes over the safe base" do
      out = html(&Page.show_button/1, %{variant: "base", color: "brand"})
      assert out =~ "c-base"
      assert out =~ "bg-brand-500!"
    end

    test "add: a brand-new variant, with variant-aware important" do
      out = html(&Page.show_button/1, %{variant: "glow", color: "base"})
      assert out =~ "v-base"
      assert out =~ "shadow-glow! hover:opacity-90!"
    end

    test "default props apply when not passed" do
      out = html(&Page.show_button/1, %{variant: "base", color: nil})
      # default color: \"brand\"
      assert out =~ "bg-brand-500!"
    end

    test "atom-typed dimension (alert's kind) keeps its type through the remap" do
      out = html(&Page.show_alert/1, %{})
      # :brand → :base atom, kc(:base) matched
      assert out =~ "k-base"
      assert out =~ "bg-brand-100! text-brand-700!"
    end
  end

  describe "customize (headless) — `part` rules style a headless component under a new name" do
    test "compiles per-part classes into [&_[data-part=…]]: variants on the root + applies defaults" do
      out = html(&Page.show_faq/1, %{})
      # default open: true
      assert out =~ "data-open"
      # (& is HTML-escaped to &amp; in the attr)
      assert out =~ "[data-part=trigger]]:py-3"
      assert out =~ "[data-part=trigger]]:font-medium"
      assert out =~ "[data-part=panel]]:pb-3"
    end
  end

  describe "introspection" do
    test "Info exposes every customize (styled and headless)" do
      assert Enum.sort(Enum.map(Info.customizes(Kit), & &1.name)) == [:alert, :button, :faq]
      assert %{name: :faq, from: :accordion} = Enum.find(Info.customizes(Kit), &(&1.name == :faq))
    end
  end

  describe "verifier" do
    test "a customize with no rules is a compile-time error" do
      assert compile_error("""
             customize :button do
             end
             """) =~ "declares no rules"
    end

    test "mixing styled rules with `part` is a compile-time error" do
      assert compile_error("""
             customize :button do
               color :brand, "x"
               part :trigger, "y"
             end
             """) =~ "mixes styled rules"
    end
  end

  defp compile_error(body) do
    code =
      "defmodule MishkaChelekom.KitTest.Bad#{:erlang.unique_integer([:positive])} do\n  use MishkaChelekom.Kit\n  #{body}\nend"

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
