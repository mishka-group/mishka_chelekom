defmodule MishkaChelekom.SidebarFocusTest do
  @moduledoc """
  A closed styled sidebar is out of the Tab order; opening it moves keyboard focus into it, and
  closing it while focus is inside gives focus back.

  The template is generated the way `mix mishka.ui.gen.component sidebar` writes it, every option
  on, compiled, and rendered. With a `hide_position`, a closed sidebar is not hidden, only moved
  off-screen below `md`, and it stays in view from `md` up, so what takes it out of the Tab order
  has to follow that breakpoint and the class `show_sidebar/3` and `hide_sidebar/3` change. They
  are `Phoenix.LiveView.JS` commands, and a command whose `to:` names an element the page does not
  have does nothing and says nothing.

  `phx-click-away` closes the sidebar on every click outside it, open or closed, so the commands
  that move focus run only for the sidebar that is actually opening or closing, and closing gives
  focus back only when focus is inside the sidebar: a click outside has already put it elsewhere.
  """
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.JS

  @template Application.app_dir(:mishka_chelekom, "priv/components/sidebar.eex")
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
      module: inspect(__MODULE__.Sidebar),
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

  defp page_source(sidebar) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(sidebar)}

      def page(assigns) do
        ~H\"\"\"
        <.sidebar id="#{@id}" hide_position={@hide_position}>
          <a href="/probe">Link</a>
        </.sidebar>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{sidebar, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(sidebar))

    render = fn hide_position ->
      %{hide_position: hide_position}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()
    end

    html = render.("left")
    [root] = Regex.run(~r/<aside\s[^>]*\bid="#{@id}"[^>]*>/, html)
    [shown] = Regex.run(~r/<aside\s[^>]*\bid="#{@id}"[^>]*>/, render.(nil))

    %{
      html: html,
      root: root,
      always_shown: shown,
      closed: state(root),
      show: commands(sidebar.show_sidebar(@id, "left"), root),
      hide: commands(sidebar.hide_sidebar(@id, "left"), root)
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

  defp classes(root) do
    [_match, classes] = Regex.run(~r/\sclass="([^"]*)"/, root)
    classes |> unescape() |> String.split()
  end

  # The rendered root as the selectors see it: `[name]` for each attribute, `.name` for each class.
  defp state(root) do
    names = String.replace(root, ~r/="[^"]*"/, "")
    attrs = for [_match, name] <- Regex.scan(~r/\s([\w:-]+)/, names), do: "[#{name}]"
    MapSet.new(attrs ++ for(class <- classes(root), do: ".#{class}"))
  end

  # Runs `commands` from `state` the way the browser does for what decides the focus stack: the
  # attributes and classes they set on the root, and the gates they are run under. `:focus-within`
  # is in the state while focus is inside the sidebar. Returns the state after them and the focus
  # commands that ran, in order.
  defp run(commands, state) do
    target = "##{@id}"

    {state, ran} =
      Enum.reduce(commands, {state, []}, fn {kind, args, gate}, {state, ran} ->
        cond do
          not gate?(gate, state) -> {state, ran}
          kind in ["push_focus", "focus_first", "pop_focus"] -> {state, [kind | ran]}
          args["to"] == target -> {change(state, kind, args), ran}
          true -> {state, ran}
        end
      end)

    {state, Enum.reverse(ran)}
  end

  defp change(state, "set_attr", %{"attr" => [name, _value]}), do: MapSet.put(state, "[#{name}]")
  defp change(state, "remove_attr", %{"attr" => name}), do: MapSet.delete(state, "[#{name}]")

  defp change(state, "add_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.put(&2, ".#{&1}"))

  defp change(state, "remove_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.delete(&2, ".#{&1}"))

  defp change(state, _kind, _args), do: state

  # A gate is `#<id>` followed by `[attr]`, `.class`, `:pseudo` and `:not(X)` parts, all of which
  # must hold.
  defp gate?(nil, _state), do: true

  defp gate?(gate, state) do
    [_match, rest] = Regex.run(~r/^##{@id}(.*)$/, gate)

    ~r/:not\(([^)]+)\)|\[[\w-]+\]|\.[\w-]+|:[\w-]+/
    |> Regex.scan(rest)
    |> Enum.all?(fn
      [_not, token] -> not MapSet.member?(state, token)
      [token] -> MapSet.member?(state, token)
    end)
  end

  defp position(commands, fun), do: Enum.find_index(commands, fun)

  defp kind?(kind), do: &match?({^kind, _args, _gate}, &1)

  test "every element the open and close commands name is in the rendered sidebar", context do
    %{html: html, show: show, hide: hide} = context

    missing =
      for {_kind, %{"to" => "#" <> selector}, _gate} <- show ++ hide,
          [id] = Regex.run(~r/^[\w-]+/, selector),
          not String.contains?(html, ~s|id="#{id}"|),
          uniq: true,
          do: id

    assert missing == []
  end

  test "a closed sidebar is hidden while it is off-screen, and only an open one is shown",
       context do
    %{root: root, closed: closed, show: show, hide: hide} = context
    hidden = "max-md:[&:not(.translate-none)]:invisible"

    # Below `md` the closed sidebar is off-screen; from `md` up `md:translate-x-0` keeps it in view.
    assert "-translate-x-full" in classes(root)
    assert "md:translate-x-0" in classes(root)
    assert hidden in classes(root)

    {open, _focus} = run(show, closed)
    assert MapSet.member?(open, ".translate-none")
    refute run(hide, open) |> elem(0) |> MapSet.member?(".translate-none")

    # It is hidden only once it has slid out, not before.
    [transition] = for "transition-[" <> _rest = class <- classes(root), do: class
    assert transition =~ "visibility"
    assert transition =~ "translate"
  end

  test "a sidebar without a hide_position is never hidden", %{always_shown: always_shown} do
    refute Enum.any?(classes(always_shown), &String.ends_with?(&1, "invisible"))
  end

  test "opening focuses the first focusable element inside the sidebar", context do
    %{html: html, show: show} = context

    assert [to] = for({"focus_first", %{"to" => to}, _gate} <- show, do: to)
    "#" <> target = to

    assert [_before, inside] = String.split(html, ~s|id="#{target}"|, parts: 2)
    [inside, _after] = String.split(inside, "</aside>", parts: 2)
    assert inside =~ ~r/<button[^>]*aria-label="Close sidebar"/
    assert inside =~ ~s|href="/probe"|
  end

  test "opening remembers the focused element and closing returns focus to it", context do
    %{show: show, hide: hide} = context

    assert {"push_focus", %{"to" => ":focus"}, _gate} = Enum.find(show, kind?("push_focus"))
    assert position(show, kind?("push_focus")) < position(show, kind?("focus_first"))
    assert Enum.any?(hide, kind?("pop_focus"))
  end

  test "closing a sidebar that is not open leaves the focus stack alone", context do
    %{closed: closed, hide: hide} = context

    assert {^closed, []} = run(hide, closed)
    assert {_closed, []} = run(hide, MapSet.put(closed, ":focus-within"))
  end

  test "only a real open, and a close with focus inside, touch the focus stack", context do
    %{closed: closed, show: show, hide: hide} = context

    assert {open, ["push_focus", "focus_first"]} = run(show, closed)
    assert {^open, []} = run(show, open)

    assert {^closed, []} = run(hide, open)

    focused = MapSet.put(open, ":focus-within")
    assert {after_close, ["pop_focus"]} = run(hide, focused)
    assert MapSet.delete(after_close, ":focus-within") == closed
  end
end
