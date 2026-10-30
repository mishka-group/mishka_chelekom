defmodule MishkaChelekom.DrawerAccessibilityTest do
  @moduledoc """
  The styled drawer's dialog is named only by an element it renders, and it has a description only
  when the caller gives one.

  The template is generated the way `mix mishka.ui.gen.component drawer` writes it, every option
  on, compiled, and rendered. An `aria-labelledby` or `aria-describedby` that names an id the page
  does not have gives the dialog no name or description at all, and the browser says nothing about
  it. The headless drawer's rule is the bar: the title names the dialog when there is one, a
  drawer without one is named only by what the caller passes, and a description is rendered and
  referenced only when there is one. A generic one would be read out each time the drawer opens
  and say nothing.
  """
  use ExUnit.Case, async: true

  @template Application.app_dir(:mishka_chelekom, "priv/components/drawer.eex")

  defmodule Web.Components.Icon do
    @moduledoc false
    use Phoenix.Component

    def icon(assigns), do: ~H|<span class={@name}></span>|
  end

  # The template as the generator writes it, every catalog option on (an option it is not given is
  # nil). The host's Gettext backend is not here, so the passthrough the runtime harness uses
  # stands in for it.
  defp generated_source do
    assigns = %{
      module: inspect(__MODULE__.Drawer),
      web_module: __MODULE__.Web,
      module_prefix_camel: "",
      component_prefix: ""
    }

    tag = ~r/<%(?!%).*?%>/s

    tag
    |> Regex.replace(File.read!(@template), &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]"))
    |> EEx.eval_string(assigns: assigns)
    |> String.replace(
      ~r/^\s*use Gettext, backend: .*$/m,
      "  import MishkaChelekom.Test.Runtime.GettextStub"
    )
  end

  defp page_source(drawer) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(drawer)}

      def titled(assigns), do: ~H|<.drawer id="titled" title="Cart">Items</.drawer>|

      def headed(assigns) do
        ~H|<.drawer id="headed" position="right"><:header>Cart</:header>Items</.drawer>|
      end

      def untitled(assigns), do: ~H|<.drawer id="untitled">Items</.drawer>|

      def labelled(assigns), do: ~H|<.drawer id="labelled" aria-label="Cart">Items</.drawer>|

      def described(assigns) do
        ~H|<.drawer id="described" title="Cart" description="Three items, 42 euros">Items</.drawer>|
      end

      def referenced(assigns) do
        ~H|<.drawer id="referenced" title="Cart" aria-describedby="cart-total">Items</.drawer>|
      end
    end
    """
  end

  setup_all do
    [{drawer, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(drawer))

    render = fn name ->
      html =
        page
        |> apply(name, [%{}])
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      [root] = Regex.run(~r/<div\s[^>]*role="dialog"[^>]*>/, html)
      {html, root}
    end

    %{render: render}
  end

  defp attribute(root, name) do
    case Regex.run(~r/\s#{name}="([^"]*)"/, root) do
      [_match, value] -> value
      nil -> nil
    end
  end

  # The text of the element with `id`, tags dropped.
  defp text(html, id) do
    [_match, inner] = Regex.run(~r/<[a-z0-9]+\s[^>]*id="#{id}"[^>]*>(.*?)<\/[a-z0-9]+>/s, html)
    inner |> String.replace(~r/<[^>]*>/, "") |> String.trim()
  end

  test "a drawer with a title or a header is named by it", %{render: render} do
    for name <- [:titled, :headed] do
      {html, root} = render.(name)

      assert id = attribute(root, "aria-labelledby")
      assert text(html, id) == "Cart"
    end
  end

  test "a drawer without a title names no element", %{render: render} do
    {html, root} = render.(:untitled)

    for name <- ["aria-labelledby", "aria-describedby"], id = attribute(root, name) do
      assert html =~ ~s|id="#{id}"|, "#{name} names ##{id}, which the drawer does not render"
    end

    refute attribute(root, "aria-labelledby")
  end

  test "a drawer without a title is named by the aria-label the caller gives", %{render: render} do
    {_html, root} = render.(:labelled)

    assert attribute(root, "aria-label") == "Cart"
    refute attribute(root, "aria-labelledby")
  end

  test "the description is the caller's, and a drawer without one has none", %{render: render} do
    {html, root} = render.(:described)
    assert text(html, attribute(root, "aria-describedby")) == "Three items, 42 euros"

    for name <- [:titled, :headed, :untitled, :labelled] do
      {html, root} = render.(name)

      refute attribute(root, "aria-describedby")
      refute html =~ ~r/id="#{name}-\w+-desc"/, "#{name} renders a description it was not given"
    end

    {_html, root} = render.(:referenced)
    assert attribute(root, "aria-describedby") == "cart-total"
  end
end
