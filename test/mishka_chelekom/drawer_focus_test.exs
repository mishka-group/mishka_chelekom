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
  commands that move focus and unlock the page's scroll run only for the drawer that is actually
  opening or closing.

  The focus stack is shared by every dialog on the page, so an open pushes one entry whatever has
  focus, nothing included, and the close pops that entry and not one another dialog pushed.
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
      closed: state(root),
      show: commands(drawer.show_drawer(@id, "left"), root),
      hide: commands(drawer.hide_drawer(@id, "left"), root)
    }
  end

  # `{kind, args, gates}` for each command a `JS` value runs. A `JS.exec/2` is replaced by the
  # commands of the root attribute it names, each tagged with the exec's `to:`, the selector that
  # decides whether they run at all, after the gates of the execs around it. A `JS` value and an
  # attribute both decode from the JSON the page carries, so either way the args have string keys.
  defp commands(%JS{} = js, root) do
    js
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> commands(root, [])
  end

  defp commands(encoded, root, gates) do
    encoded
    |> unescape()
    |> Jason.decode!()
    |> Enum.flat_map(fn
      ["exec", %{"attr" => attr, "to" => to}] ->
        assert [_match, value] = Regex.run(~r/\s#{attr}="([^"]*)"/, root)
        commands(value, root, gates ++ [to])

      [kind, args] ->
        [{kind, args, gates}]
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

  # The rendered root as the selectors see it: `[name]` for each attribute, `.name` for each class.
  defp state(root) do
    [_match, classes] = Regex.run(~r/\sclass="([^"]*)"/, root)
    names = String.replace(root, ~r/="[^"]*"/, "")
    attrs = for [_match, name] <- Regex.scan(~r/\s([\w:-]+)/, names), do: "[#{name}]"
    MapSet.new(attrs ++ for(class <- String.split(classes), do: ".#{class}"))
  end

  # The rest of the page the commands change: `<body>`'s classes, the element that has focus
  # ("opener", the control that opened the drawer, or `nil` when nothing has focus, as after a page
  # load or in Safari after a click on a button) and the focus stack, top first.
  @page %{body: MapSet.new(), focus: "opener", stack: []}

  # Runs `commands` from `state` and `page` the way the browser does for what decides the focus
  # stack and the page's scroll: the attributes and classes they set on the root and on `<body>`,
  # the gates they are run under, and the focus commands. Returns the root's state and the page
  # after them.
  defp play(commands, state, page) do
    target = "##{@id}"

    Enum.reduce(commands, {state, page}, fn {kind, args, gates}, {state, page} ->
      cond do
        not Enum.all?(gates, &gate?(&1, state)) -> {state, page}
        kind in ["push_focus", "focus_first", "pop_focus"] -> {state, focus(page, kind, args)}
        args["to"] == "body" -> {state, %{page | body: change(page.body, kind, args)}}
        args["to"] == target -> {change(state, kind, args), page}
        true -> {state, page}
      end
    end)
  end

  defp change(state, "set_attr", %{"attr" => [name, _value]}), do: MapSet.put(state, "[#{name}]")
  defp change(state, "remove_attr", %{"attr" => name}), do: MapSet.delete(state, "[#{name}]")

  defp change(state, "add_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.put(&2, ".#{&1}"))

  defp change(state, "remove_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.delete(&2, ".#{&1}"))

  defp change(state, _kind, _args), do: state

  # A gate is `#<id>`, `#<id>X` or `#<id>:not(X)`, where X is one `[attr]` or `.class`. Any other
  # selector names other dialogs, and this page has none.
  defp gate?(gate, state) do
    case Regex.run(~r/^##{@id}(.*)$/, gate) do
      [_match, rest] -> own_gate?(rest, state)
      nil -> false
    end
  end

  defp own_gate?(rest, state) do
    case Regex.run(~r/^:not\((.+)\)$/, rest) do
      [_match, token] -> not MapSet.member?(state, token)
      nil -> rest == "" or MapSet.member?(state, rest)
    end
  end

  # A push adds what its `to:` matches, a focus-first moves focus into the dialog, and a pop takes
  # the top entry and focuses it. `<body>` cannot take focus, so popping it moves none.
  defp focus(page, "push_focus", %{"to" => to}),
    do: %{page | stack: matched(to, page.focus) ++ page.stack}

  defp focus(page, "focus_first", _args), do: %{page | focus: "inside"}
  defp focus(%{stack: ["body" | stack]} = page, "pop_focus", _args), do: %{page | stack: stack}

  defp focus(%{stack: [top | stack]} = page, "pop_focus", _args),
    do: %{page | stack: stack, focus: top}

  defp focus(page, "pop_focus", _args), do: page

  # The elements of the page a focus `to:` matches while `focused` has focus: `<body>`, which holds
  # the opener and "inside", the first control of the dialog. The selector is a list of compounds
  # of `body`, `:focus`, `:focus-within`, `:not()` and `:has()`; anything else fails the test.
  defp matched(selector, focused) do
    for element <- ["body", "opener", "inside"], matches?(selector, element, focused), do: element
  end

  defp matches?(list, element, focused) do
    list |> split_list() |> Enum.any?(&compound?(String.trim(&1), element, focused))
  end

  defp compound?("", _element, _focused), do: true

  defp compound?("body" <> rest, element, focused),
    do: element == "body" and compound?(rest, element, focused)

  defp compound?(":focus-within" <> rest, element, focused),
    do:
      (element == focused or (element == "body" and focused != nil)) and
        compound?(rest, element, focused)

  defp compound?(":focus" <> rest, element, focused),
    do: element == focused and compound?(rest, element, focused)

  defp compound?(":not(" <> rest, element, focused) do
    {inner, rest} = group(rest, 0, "")
    not matches?(inner, element, focused) and compound?(rest, element, focused)
  end

  defp compound?(":has(" <> rest, element, focused) do
    {inner, rest} = group(rest, 0, "")
    descendants = if element == "body", do: ["opener", "inside"], else: []
    Enum.any?(descendants, &matches?(inner, &1, focused)) and compound?(rest, element, focused)
  end

  # The text up to the `)` that closes a `(` already read, and the text after it.
  defp group(")" <> rest, 0, inner), do: {inner, rest}
  defp group("(" <> rest, depth, inner), do: group(rest, depth + 1, inner <> "(")
  defp group(")" <> rest, depth, inner), do: group(rest, depth - 1, inner <> ")")

  defp group(<<char::utf8, rest::binary>>, depth, inner),
    do: group(rest, depth, inner <> <<char::utf8>>)

  # A selector list split at its own commas, not at those inside `()`.
  defp split_list(list) do
    {parts, last, 0} =
      for <<char::utf8 <- list>>, reduce: {[], "", 0} do
        {parts, part, 0} when char == ?, -> {[part | parts], "", 0}
        {parts, part, depth} when char == ?( -> {parts, part <> "(", depth + 1}
        {parts, part, depth} when char == ?) -> {parts, part <> ")", depth - 1}
        {parts, part, depth} -> {parts, part <> <<char::utf8>>, depth}
      end

    Enum.reverse([last | parts])
  end

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
    assert {"set_attr", %{"attr" => ["inert", ""], "to" => "##{@id}"}, []} in hide

    removes_inert = &match?({"remove_attr", %{"attr" => "inert", "to" => "#" <> @id}, []}, &1)
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
    %{closed: closed, show: show, hide: hide} = context

    assert position(show, kind?("push_focus")) < position(show, kind?("focus_first"))

    assert {open, %{focus: "inside", stack: ["opener"]} = page} = play(show, closed, @page)
    assert {_closed, %{focus: "opener", stack: []}} = play(hide, open, page)
  end

  test "opening pushes one focus entry whether or not anything has focus", context do
    %{closed: closed, show: show} = context

    assert {_open, %{stack: ["opener"]}} = play(show, closed, @page)
    assert {_open, %{stack: ["body"]}} = play(show, closed, %{@page | focus: nil})
  end

  test "a drawer opened with nothing focused does not close with another dialog's entry",
       context do
    %{closed: closed, show: show, hide: hide} = context

    # Another dialog is open and has pushed its opener; focus is on nothing.
    {open, page} = play(show, closed, %{@page | focus: nil, stack: ["other-opener"]})
    {_closed, page} = play(hide, open, page)

    assert page.stack == ["other-opener"]
    refute page.focus == "other-opener"
  end

  test "only the drawer that opens or closes touches the focus stack", %{show: show, hide: hide} do
    shown = &match?({"set_attr", %{"attr" => ["data-open", ""]}, []}, &1)
    hidden = &match?({"remove_attr", %{"attr" => "data-open"}, []}, &1)

    for kind <- ["push_focus", "focus_first"] do
      assert {^kind, _args, ["##{@id}:not([data-open])"]} = Enum.find(show, kind?(kind))
      assert position(show, kind?(kind)) < position(show, shown)
    end

    assert {"pop_focus", _args, ["##{@id}[data-open]"]} = Enum.find(hide, kind?("pop_focus"))
    assert position(hide, kind?("pop_focus")) < position(hide, hidden)
  end

  test "opening locks the page's scroll and only a real close unlocks it", context do
    %{closed: closed, show: show, hide: hide} = context
    locked = MapSet.new([".overflow-hidden"])

    assert {open, %{body: ^locked} = page} = play(show, closed, @page)
    assert {_closed, %{body: body}} = play(hide, open, page)
    assert MapSet.size(body) == 0

    # Another dialog is open and locked it; Escape reaches this drawer, which is closed.
    assert {_closed, %{body: ^locked}} = play(hide, closed, %{@page | body: locked})
  end
end
