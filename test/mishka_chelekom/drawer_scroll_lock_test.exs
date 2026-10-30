defmodule MishkaChelekom.DrawerScrollLockTest do
  @moduledoc """
  An open drawer locks the page's scroll, and the page stays locked while any drawer or modal on
  it is still open.

  The template is generated the way `mix mishka.ui.gen.component drawer` writes it, every option
  on, compiled, and rendered twice on one page. `show_drawer/3` and `hide_drawer/3` are
  `Phoenix.LiveView.JS` commands, run here on a model of that page: the attributes and classes of
  each root, `<body>`'s and `<html>`'s classes, and `JS.exec/2` running the commands an attribute
  holds on every element its `to:` matches, as LiveView does. LiveView applies a class change on
  the next animation frame, in the order the commands made it, so running them in order gives the
  state that frame paints.

  The lock is one class on `<body>` that every dialog adds, so the first dialog to close took it off
  under one that was still open. A dialog that keeps the convention carries what its open does to
  the page's scroll in `data-open-scroll` and is `data-open` while it is open; the modal keeps it
  too, so the lock lasts until the last of them closes, whichever closes first.
  """
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.JS

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

  # Two drawers, and another dialog that keeps the convention with a lock of its own: what a modal
  # on the same page is to the drawer.
  defp page_source(drawer) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(drawer)}
      alias Phoenix.LiveView.JS

      def page(assigns) do
        ~H\"\"\"
        <.drawer id="first" title="First"><a href="/first">First</a></.drawer>
        <.drawer id="second" title="Second"><a href="/second">Second</a></.drawer>
        <div id="other" data-open-scroll={JS.add_class("overflow-hidden", to: "body")}></div>
        \"\"\"
      end
    end
    """
  end

  @ids ["first", "second", "other"]

  setup_all do
    [{drawer, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(drawer))

    html =
      %{}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    elements =
      Map.new(@ids, fn id ->
        [root] = Regex.run(~r/<div\s[^>]*\bid="#{id}"[^>]*>/, html)
        {id, element(root)}
      end)

    %{drawer: drawer, page: %{elements: elements, body: MapSet.new(), html: MapSet.new()}}
  end

  # A root as the selectors see it, `#id`, `[name]` for each attribute and `.name` for each class,
  # and the value of each attribute, the commands `JS.exec/2` reads.
  defp element(root) do
    attrs =
      for match <- Regex.scan(~r/\s([\w:-]+)(?:="([^"]*)")?/, root), into: %{} do
        case match do
          [_match, name, value] -> {name, unescape(value)}
          [_match, name] -> {name, ""}
        end
      end

    classes = attrs |> Map.get("class", "") |> String.split()

    tokens =
      ["##{attrs["id"]}" | Enum.map(Map.keys(attrs), &"[#{&1}]")] ++ Enum.map(classes, &".#{&1}")

    %{tokens: MapSet.new(tokens), attrs: attrs}
  end

  defp unescape(attribute) do
    Enum.reduce(
      [{"&quot;", "\""}, {"&#39;", "'"}, {"&lt;", "<"}, {"&gt;", ">"}, {"&amp;", "&"}],
      attribute,
      fn {entity, char}, acc -> String.replace(acc, entity, char) end
    )
  end

  defp run(page, %JS{} = js) do
    encoded = js |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    run(page, unescape(encoded))
  end

  defp run(page, encoded) when is_binary(encoded) do
    encoded |> Jason.decode!() |> Enum.reduce(page, &step(&2, &1))
  end

  # LiveView throws when an element `JS.exec/2` matches does not have the attribute.
  defp step(page, ["exec", %{"attr" => attr, "to" => to}]) do
    Enum.reduce(targets(page, to), page, fn id, page ->
      assert commands = page.elements[id].attrs[attr], "##{id} matches #{to} but has no #{attr}"
      run(page, commands)
    end)
  end

  defp step(page, [kind, _args]) when kind in ~w(push_focus pop_focus focus_first focus),
    do: page

  defp step(page, [kind, %{"to" => "body"} = args]),
    do: %{page | body: classes(page.body, kind, args)}

  defp step(page, [kind, %{"to" => "html"} = args]),
    do: %{page | html: classes(page.html, kind, args)}

  defp step(page, [kind, %{"to" => to} = args]) do
    Enum.reduce(targets(page, to), page, fn id, page ->
      update_in(page, [:elements, id, :tokens], &change(&1, kind, args))
    end)
  end

  defp classes(names, "add_class", %{"names" => added}),
    do: MapSet.union(names, MapSet.new(added))

  defp classes(names, "remove_class", %{"names" => removed}),
    do: MapSet.difference(names, MapSet.new(removed))

  defp change(tokens, "set_attr", %{"attr" => [name, _value]}),
    do: MapSet.put(tokens, "[#{name}]")

  defp change(tokens, "remove_attr", %{"attr" => name}), do: MapSet.delete(tokens, "[#{name}]")

  defp change(tokens, "add_class", %{"names" => names}),
    do: Enum.reduce(names, tokens, &MapSet.put(&2, ".#{&1}"))

  defp change(tokens, "remove_class", %{"names" => names}),
    do: Enum.reduce(names, tokens, &MapSet.delete(&2, ".#{&1}"))

  defp change(tokens, _kind, _args), do: tokens

  # The ids of the page's roots a selector matches, in page order. The selector is a list of
  # compounds of `#id`, `.class`, `[attr]` and `:not()`; anything else fails the test.
  defp targets(page, selector) do
    for id <- @ids, matches?(page.elements[id].tokens, selector), do: id
  end

  defp matches?(tokens, list) do
    list |> String.split(",") |> Enum.any?(&compound?(tokens, String.trim(&1)))
  end

  defp compound?(_tokens, ""), do: true

  defp compound?(tokens, ":not(" <> rest) do
    [inner, rest] = String.split(rest, ")", parts: 2)
    not compound?(tokens, inner) and compound?(tokens, rest)
  end

  defp compound?(tokens, compound) do
    case Regex.run(~r/^([#.][\w-]+|\[[\w-]+\])(.*)$/, compound) do
      [_match, simple, rest] -> MapSet.member?(tokens, simple) and compound?(tokens, rest)
      nil -> flunk("the model does not read the selector #{inspect(compound)}")
    end
  end

  defp open(page, drawer, id), do: run(page, drawer.show_drawer(id, "left"))
  defp close(page, drawer, id), do: run(page, drawer.hide_drawer(id, "left"))

  defp locked?(page), do: "overflow-hidden" in page.body

  test "closing one of two open drawers leaves the page locked until the other closes", context do
    %{drawer: drawer, page: page} = context
    both = page |> open(drawer, "first") |> open(drawer, "second")
    assert locked?(both)

    for [last, first] <- [["first", "second"], ["second", "first"]] do
      page = close(both, drawer, first)
      assert locked?(page), "closing ##{first} unlocked the page under ##{last}"
      refute locked?(close(page, drawer, last))
    end
  end

  test "a drawer closing over another open dialog runs that dialog's own lock again", context do
    %{drawer: drawer, page: page} = context

    # The other dialog opened before the drawer: it is open, and its lock is on.
    page =
      page
      |> update_in([:elements, "other", :tokens], &MapSet.put(&1, "[data-open]"))
      |> run(page.elements["other"].attrs["data-open-scroll"])

    page = page |> open(drawer, "first") |> close(drawer, "first")
    assert locked?(page)
  end

  test "closing a drawer that is already closed leaves the page's scroll as it is", context do
    %{drawer: drawer, page: page} = context
    page = open(page, drawer, "second")

    assert close(page, drawer, "first") == page
  end
end
