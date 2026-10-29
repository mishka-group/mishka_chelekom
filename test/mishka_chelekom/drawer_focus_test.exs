defmodule MishkaChelekom.DrawerFocusTest do
  @moduledoc """
  Opening the styled drawer moves keyboard focus into it, keeps it there, and closing gives it
  back; a closed drawer is out of the Tab order.

  The template is generated the way `mix mishka.ui.gen.component drawer` writes it, every option
  on, compiled, and rendered. A closed drawer is not hidden, only moved off-screen, so whatever
  takes it out of the Tab order has to be on the element the page renders, and `show_drawer/3` and
  `hide_drawer/3` have to change it. They are `Phoenix.LiveView.JS` commands, and a command whose
  `to:` names an element the page does not have does nothing and says nothing.

  Escape reaches every drawer on the page, open or closed, through `phx-window-keydown`, so the
  commands that move focus run only for the drawer that is actually opening or closing.
  """
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.JS

  @template Application.app_dir(:mishka_chelekom, "priv/components/drawer.eex")
  @id "probe"

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

      def page(assigns) do
        ~H\"\"\"
        <.drawer id="#{@id}" title="Probe">
          <a href="/probe">Link</a>
        </.drawer>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{drawer, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(drawer))

    html =
      %{}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    [root] = Regex.run(~r/<div\s[^>]*\bid="#{@id}"[^>]*>/, html)

    %{
      html: html,
      root: root,
      show: commands(drawer.show_drawer(@id, "left"), root),
      hide: commands(drawer.hide_drawer(@id, "left"), root)
    }
  end

  # `{kind, args, gate}` for each command a `JS` value runs. A `JS.exec/2` is replaced by the
  # commands of the root attribute it names, each tagged with the exec's `to:`, the selector that
  # decides whether they run at all. A `JS` value and an attribute both decode from the JSON the
  # page carries, so either way the args have string keys.
  defp commands(%JS{} = js, root) do
    js
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> commands(root, nil)
  end

  defp commands(encoded, root, gate) do
    encoded
    |> unescape()
    |> Jason.decode!()
    |> Enum.flat_map(fn
      ["exec", %{"attr" => attr, "to" => to}] ->
        assert [_match, value] = Regex.run(~r/\s#{attr}="([^"]*)"/, root)
        commands(value, root, to)

      [kind, args] ->
        [{kind, args, gate}]
    end)
  end

  defp unescape(attribute) do
    Enum.reduce(
      [{"&quot;", "\""}, {"&#39;", "'"}, {"&lt;", "<"}, {"&gt;", ">"}, {"&amp;", "&"}],
      attribute,
      fn {entity, char}, acc -> String.replace(acc, entity, char) end
    )
  end

  defp position(commands, fun), do: Enum.find_index(commands, fun)

  defp kind?(kind), do: &match?({^kind, _args, _gate}, &1)

  test "every element the open and close commands name is in the rendered drawer", context do
    %{html: html, show: show, hide: hide} = context

    missing =
      for {_kind, %{"to" => "#" <> selector}, _gate} <- show ++ hide,
          [id] = Regex.run(~r/^[\w-]+/, selector),
          not String.contains?(html, ~s|id="#{id}"|),
          uniq: true,
          do: id

    assert missing == []
  end

  test "a closed drawer is out of the Tab order, and only an open one is back in it", context do
    %{root: root, show: show, hide: hide} = context

    assert root =~ ~r/\sinert[\s>=]/
    assert {"set_attr", %{"attr" => ["inert", ""], "to" => "##{@id}"}, nil} in hide

    removes_inert = &match?({"remove_attr", %{"attr" => "inert", "to" => "#" <> @id}, nil}, &1)
    assert position(show, removes_inert) < position(show, kind?("focus_first"))
  end

  test "opening focuses the first focusable element inside the dialog", %{html: html, show: show} do
    assert [to] = for({"focus_first", %{"to" => to}, _gate} <- show, do: to)
    "#" <> target = to

    [_before, dialog] = String.split(html, ~s|role="dialog"|, parts: 2)
    assert [_before, inside] = String.split(dialog, ~s|id="#{target}"|, parts: 2)
    assert inside =~ ~r/<button[^>]*aria-label="Close menu"/
  end

  test "Tab stays inside the open drawer", %{html: html} do
    [_before, dialog] = String.split(html, ~s|role="dialog"|, parts: 2)
    wrap = ~r/<div[^>]*id="#{@id}-container"[^>]*phx-hook="Phoenix.FocusWrap"/

    assert [_before, wrapped] = String.split(dialog, wrap, parts: 2)
    [wrapped, _after] = String.split(wrapped, ~s|id="#{@id}-container-end"|, parts: 2)
    assert wrapped =~ ~r/<button[^>]*aria-label="Close menu"/
    assert wrapped =~ ~s|href="/probe"|
  end

  test "opening remembers the focused element and closing returns focus to it", context do
    %{show: show, hide: hide} = context

    assert {"push_focus", %{"to" => ":focus"}, _gate} = Enum.find(show, kind?("push_focus"))
    assert position(show, kind?("push_focus")) < position(show, kind?("focus_first"))
    assert Enum.any?(hide, kind?("pop_focus"))
  end

  test "only the drawer that opens or closes touches the focus stack", %{show: show, hide: hide} do
    shown = &match?({"add_class", %{"names" => ["drawer-showed"]}, nil}, &1)
    hidden = &match?({"remove_class", %{"names" => ["drawer-showed"]}, nil}, &1)

    for kind <- ["push_focus", "focus_first"] do
      assert {^kind, _args, "##{@id}:not(.drawer-showed)"} = Enum.find(show, kind?(kind))
      assert position(show, kind?(kind)) < position(show, shown)
    end

    assert {"pop_focus", _args, "##{@id}.drawer-showed"} = Enum.find(hide, kind?("pop_focus"))
    assert position(hide, kind?("pop_focus")) < position(hide, hidden)
  end
end
