defmodule MishkaChelekom.ModalFocusTest do
  @moduledoc """
  Opening the styled modal moves keyboard focus into its dialog, and closing it gives focus back.

  The template is generated the way `mix mishka.ui.gen.component modal` writes it, every option
  on, compiled, and rendered. `show_modal/2` and `hide_modal/2` are `Phoenix.LiveView.JS` commands,
  and a command whose `to:` names an element the page does not have does nothing and says nothing:
  `show_modal/2` once focused `#<id>-content`, which the modal never rendered, so a keyboard user
  who opened it was left on the page behind it.

  Escape reaches every modal on the page, open or closed, through `phx-window-keydown`, and
  `phx-remove` runs on a closed modal that a patch removes, so the commands that move focus run
  only for the modal that is actually opening or closing.

  The focus stack is shared by every dialog on the page, so an open pushes one entry whatever has
  focus, nothing included, and the close pops that entry and not one another dialog pushed.
  """
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.JS

  @template Application.app_dir(:mishka_chelekom, "priv/components/modal.eex")
  @id "probe"

  defmodule Web.Components.Icon do
    @moduledoc false
    use Phoenix.Component

    def icon(assigns), do: ~H|<span class={[@name, @class]}></span>|
  end

  # The template as the generator writes it, every catalog option on (an option it is not given is
  # nil). The host's Gettext backend is not here, so the passthrough the runtime harness uses
  # stands in for it.
  defp generated_source do
    assigns = %{
      module: inspect(__MODULE__.Modal),
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

  defp page_source(modal) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(modal)}

      def page(assigns) do
        ~H\"\"\"
        <.modal id="#{@id}" title="Probe">
          <p>Body</p>
        </.modal>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{modal, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(modal))

    html =
      %{}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    [root] = Regex.run(~r/<div\s[^>]*\bid="#{@id}"[^>]*>/, html)

    %{
      html: html,
      closed: state(root),
      show: commands(modal.show_modal(@id), root),
      hide: commands(modal.hide_modal(@id), root)
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

  # The rendered root as the selectors see it: `[name]` for each attribute, `.name` for each class.
  defp state(root) do
    [_match, classes] = Regex.run(~r/\sclass="([^"]*)"/, root)
    names = String.replace(root, ~r/="[^"]*"/, "")
    attrs = for [_match, name] <- Regex.scan(~r/\s([\w:-]+)/, names), do: "[#{name}]"
    MapSet.new(attrs ++ for(class <- String.split(classes), do: ".#{class}"))
  end

  # The rest of the page the commands change: `<body>`'s classes, the element that has focus
  # ("opener", the control that opened the modal, or `nil` when nothing has focus, as after a page
  # load or in Safari after a click on a button) and the focus stack, top first.
  @page %{body: MapSet.new(), focus: "opener", stack: []}

  # Runs `commands` from `state` the way the browser does for what decides the focus stack: the
  # attributes and classes they set on the root, and the gates they are run under. Returns the
  # state after them and the focus commands that ran, in order.
  defp run(commands, state) do
    {state, ran, _page} = play(commands, state, @page)
    {state, ran}
  end

  # `run/2` on `page`, which the focus commands and the classes set on `<body>` change. Returns the
  # page after them as well.
  defp play(commands, state, page) do
    target = "##{@id}"

    {state, ran, page} =
      Enum.reduce(commands, {state, [], page}, fn {kind, args, gate}, {state, ran, page} ->
        cond do
          not gate?(gate, state) ->
            {state, ran, page}

          kind in ["push_focus", "focus_first", "pop_focus"] ->
            {state, [kind | ran], focus(page, kind, args)}

          args["to"] == "body" ->
            {state, ran, %{page | body: change(page.body, kind, args)}}

          args["to"] == target ->
            {change(state, kind, args), ran, page}

          true ->
            {state, ran, page}
        end
      end)

    {state, Enum.reverse(ran), page}
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

  defp change(state, "set_attr", %{"attr" => [name, _value]}), do: MapSet.put(state, "[#{name}]")
  defp change(state, "remove_attr", %{"attr" => name}), do: MapSet.delete(state, "[#{name}]")

  defp change(state, "add_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.put(&2, ".#{&1}"))

  defp change(state, "remove_class", %{"names" => names}),
    do: Enum.reduce(names, state, &MapSet.delete(&2, ".#{&1}"))

  defp change(state, _kind, _args), do: state

  # A gate is `#<id>`, `#<id>X` or `#<id>:not(X)`, where X is one `[attr]` or `.class`.
  defp gate?(nil, _state), do: true

  defp gate?(gate, state) do
    [_match, rest] = Regex.run(~r/^##{@id}(.*)$/, gate)

    case Regex.run(~r/^:not\((.+)\)$/, rest) do
      [_match, token] -> not MapSet.member?(state, token)
      nil -> rest == "" or MapSet.member?(state, rest)
    end
  end

  defp position(commands, fun), do: Enum.find_index(commands, fun)

  defp kind?(kind), do: &match?({^kind, _args, _gate}, &1)

  test "every element the open and close commands name is in the rendered modal", context do
    %{html: html, show: show, hide: hide} = context

    missing =
      for {_kind, %{"to" => "#" <> selector}, _gate} <- show ++ hide,
          [id] = Regex.run(~r/^[\w-]+/, selector),
          not String.contains?(html, ~s|id="#{id}"|),
          uniq: true,
          do: id

    assert missing == []
  end

  test "opening focuses the first focusable element inside the dialog", %{html: html, show: show} do
    assert [to] = for({"focus_first", %{"to" => to}, _gate} <- show, do: to)
    "#" <> target = to

    [_before, dialog] = String.split(html, ~s|role="dialog"|, parts: 2)
    assert [_before, inside] = String.split(dialog, ~s|id="#{target}"|, parts: 2)
    assert inside =~ ~r/<button[^>]*aria-label="close"/
  end

  test "opening remembers the focused element and closing returns focus to it", context do
    %{closed: closed, show: show, hide: hide} = context

    assert position(show, kind?("push_focus")) < position(show, kind?("focus_first"))

    assert {open, _ran, %{focus: "inside", stack: ["opener"]} = page} = play(show, closed, @page)
    assert {_closed, _ran, %{focus: "opener", stack: []}} = play(hide, open, page)
  end

  test "opening pushes one focus entry whether or not anything has focus", context do
    %{closed: closed, show: show} = context

    assert {_open, _ran, %{stack: ["opener"]}} = play(show, closed, @page)
    assert {_open, _ran, %{stack: ["body"]}} = play(show, closed, %{@page | focus: nil})
  end

  test "a modal opened with nothing focused does not close with another dialog's entry",
       context do
    %{closed: closed, show: show, hide: hide} = context

    # Another dialog is open and has pushed its opener; focus is on nothing.
    page = %{@page | focus: nil, stack: ["other-opener"]}

    {open, _ran, page} = play(show, closed, page)
    assert {_closed, ["pop_focus"], page} = play(hide, open, page)
    assert page.stack == ["other-opener"]
    refute page.focus == "other-opener"
  end

  test "closing a modal that is already closed leaves the focus stack alone", context do
    %{closed: closed, hide: hide} = context

    assert {^closed, []} = run(hide, closed)
  end

  test "only a real open and a real close touch the focus stack", context do
    %{closed: closed, show: show, hide: hide} = context

    assert {open, ["push_focus", "focus_first"]} = run(show, closed)
    assert {^open, []} = run(show, open)
    assert {^closed, ["pop_focus"]} = run(hide, open)
  end
end
