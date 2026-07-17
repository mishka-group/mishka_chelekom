defmodule DevelopmentWeb.TreeExamplesTest do
  @moduledoc """
  Drives the "Examples" section at the bottom of `/showcase/headless/tree` — the same place
  every other headless component puts its worked patterns.

  These are the situations a reader is most likely to copy, so each is exercised for real:
  the form posts, the click reaches `handle_event`, drag & drop mutates the server's data, and
  async children arrive. Queries use LazyHTML (LiveView 1.1 dropped Floki).
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  @path "/showcase/headless/tree"

  defp query(html, selector), do: html |> LazyHTML.from_document() |> LazyHTML.query(selector)

  defp node_attr(html, tree_id, value, attr) do
    html
    |> query(~s(##{tree_id} li[data-value="#{value}"]))
    |> LazyHTML.attribute(attr)
    |> List.first()
  end

  defp node?(html, tree_id, value),
    do: html |> query(~s(##{tree_id} li[data-value="#{value}"])) |> Enum.any?()

  # The demos LiveComponent ids are derived from the page's own id.
  defp demos(id), do: "hl-ex-tree-demos-#{id}"

  test "the Examples section renders every situation", %{conn: conn} do
    {:ok, _view, html} = live(conn, @path)

    assert html =~ "Examples"

    for {id, what} <- [
          {"controller", "server-driven expand/check"},
          {"form", "permissions form"},
          {"click", "one click → one handle_event"},
          {"async", "async children"},
          {"dnd", "drag & drop"},
          {"search", "search"}
        ] do
      assert html |> query(~s(#hl-ex-tree-demos-#{id})) |> Enum.any?(), "missing demo: #{what}"
    end
  end

  test "every example tree is hooked and named", %{conn: conn} do
    {:ok, _view, html} = live(conn, @path)

    roots = html |> query(~s([data-tree-root]))
    assert Enum.count(roots) >= 6

    # An unnamed tree fails the APG; every one on the page must carry a label.
    for label <- LazyHTML.attribute(roots, "aria-label") do
      assert label not in [nil, ""]
    end

    assert Enum.all?(LazyHTML.attribute(roots, "phx-hook"), &(&1 == "Tree"))
  end

  test "the form starts pre-checked, cascades, and skips the disabled node", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    form = "hl-ex-tree-demos-form"

    assert node_attr(html, form, "content:read", "data-checked") == "true"
    assert node_attr(html, form, "billing:read", "data-checked") == "true"
    assert node_attr(html, form, "content:write", "data-checked") == "false"

    # Partially checked group -> indeterminate, and never submitted itself.
    assert node_attr(html, form, "content", "aria-checked") == "mixed"

    # `disabled` is a real state, not just a CSS effect.
    assert node_attr(html, form, "content:delete", "aria-disabled") == "true"

    # The checkbox carries the field name, so the form posts with no JS glue.
    boxes = html |> query(~s(##{form} input[data-part="checkbox"]))
    assert "permissions[]" in LazyHTML.attribute(boxes, "name")
    assert "content:read" in LazyHTML.attribute(boxes, "value")
    # ...and stays out of the tab sequence (the tree is ONE tab stop).
    assert Enum.all?(LazyHTML.attribute(boxes, "tabindex"), &(&1 == "-1"))

    html =
      view
      |> form("#hl-ex-tree-demos-permissions-form", %{
        "permissions" => ["content:read", "users:invite"]
      })
      |> render_submit()

    assert html =~ "users:invite"
  end

  test "checking every leaf of a group checks the group", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    form = "hl-ex-tree-demos-form"

    html =
      view
      |> element("#hl-ex-tree-demos-form")
      |> render_hook("form_checked", %{"values" => ["billing:read", "billing:write"]})

    assert node_attr(html, form, "billing", "aria-checked") == "true"
  end

  test "one click runs one handle_event and the server reports the value", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)

    assert html =~ "Click a file…"

    html =
      view
      |> element("#hl-ex-tree-demos-click")
      |> render_hook("opened", %{"values" => ["src/components/Tree.tsx"]})

    refute html =~ "Click a file…"
    assert html =~ "src/components/Tree.tsx"
  end

  test "drag and drop moves a node in the server's data", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    dnd = "hl-ex-tree-demos-dnd"

    assert node_attr(html, dnd, "tsconfig.json", "data-level") == "1"

    html =
      view
      |> element("#hl-ex-tree-demos-dnd")
      |> render_hook("dropped", %{
        "dragged" => "tsconfig.json",
        "target" => "src",
        "position" => "inside"
      })

    assert node_attr(html, dnd, "tsconfig.json", "data-level") == "2"
  end

  test "a node cannot be dropped into its own descendant", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    dnd = "hl-ex-tree-demos-dnd"

    html =
      view
      |> element("#hl-ex-tree-demos-dnd")
      |> render_hook("dropped", %{
        "dragged" => "src",
        "target" => "src/components",
        "position" => "inside"
      })

    assert node_attr(html, dnd, "src", "data-level") == "1"
    assert node_attr(html, dnd, "src/components", "data-level") == "2"
  end

  test "async children arrive via send_update and are pushed to the hook", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    async = "hl-ex-tree-demos-async"

    assert node_attr(html, async, "async/lazy", "data-has-children") == "true"
    refute node?(html, async, "async/lazy/a.txt")

    view
    |> element("#hl-ex-tree-demos-async")
    |> render_hook("load_children", %{"value" => "async/lazy"})

    # The LiveComponent answers from a Task via send_update/3 — no parent handle_info involved.
    assert_push_event(view, "tree:hl-ex-tree-demos-async:children", %{value: "async/lazy"}, 3000)

    html = render(view)
    assert node?(html, async, "async/lazy/a.txt")
    refute node?(html, async, "async/lazy-2/a.txt")
  end

  test "search keeps matches and their ancestors", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    search = "hl-ex-tree-demos-search"

    html =
      view |> form("#hl-ex-tree-demos-search-form", %{query: "Accordion"}) |> render_change()

    assert node?(html, search, "src")
    assert node?(html, search, "src/components/Accordion.tsx")
    refute node?(html, search, "src/components/Tree.tsx")
  end

  test "the server can take expansion back (collapse all is not a no-op)", %{conn: conn} do
    {:ok, view, html} = live(conn, @path)
    controller = "hl-ex-tree-demos-controller"

    # data-expanded-values is the server's unambiguous statement of intent; the hook diffs it.
    assert html |> query("##{controller}") |> LazyHTML.attribute("data-expanded-values") == [
             ~s(["src"])
           ]

    collapsed =
      view |> element("#hl-ex-tree-demos button[phx-click=collapse_all]") |> render_click()

    assert collapsed |> query("##{controller}") |> LazyHTML.attribute("data-expanded-values") == [
             "[]"
           ]

    expanded = view |> element("#hl-ex-tree-demos button[phx-click=expand_all]") |> render_click()
    [values] = expanded |> query("##{controller}") |> LazyHTML.attribute("data-expanded-values")
    assert values =~ "node_modules"
  end

  describe "state survives a re-render" do
    test "an open <details> stays open when a button inside it is clicked", %{conn: conn} do
      {:ok, view, html} = live(conn, @path)

      # `<details open>` is uncontrolled DOM state — the server must render `open` or morphdom
      # strips it on the next patch and the section slams shut on every click.
      assert html |> query("details[open]") |> Enum.any?()

      after_click =
        view |> element("#hl-ex-tree-demos button[phx-click=expand_all]") |> render_click()

      open_summaries =
        after_click |> query("details[open] > summary") |> LazyHTML.text()

      assert open_summaries =~ "Controller", "the Controller section closed on a button click"
    end

    test "a closed section can be opened and stays open across a patch", %{conn: conn} do
      {:ok, view, _html} = live(conn, @path)

      opened =
        view
        |> element(~s(#hl-ex-tree-demos summary[phx-value-key="dnd"]))
        |> render_click()

      assert opened |> query("details[open] > summary") |> LazyHTML.text() =~ "Drag"

      after_click =
        view |> element("#hl-ex-tree-demos button[phx-click=check_all]") |> render_click()

      assert after_click |> query("details[open] > summary") |> LazyHTML.text() =~ "Drag"
    end

    test "the server publishes selected and checked, not just expanded", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      # The hook writes data-selected/data-checked; the server never renders them per-node, so
      # morphdom strips them on any patch. These attributes are what lets the hook restore them.
      for attr <- ~w(data-expanded-values data-selected-values data-checked-values) do
        assert html |> query("#hl-ex-tree-demos-controller") |> LazyHTML.attribute(attr) != [],
               "root does not publish #{attr}"
      end
    end

    test "checked state survives an unrelated re-render", %{conn: conn} do
      {:ok, view, _html} = live(conn, @path)
      form = "hl-ex-tree-demos-form"

      # Something unrelated re-renders the page…
      view |> element("#hl-ex-tree-demos button[phx-click=expand_all]") |> render_click()
      html = render(view)

      # …and the form's pre-checked nodes are still published, so the hook can repaint them.
      [checked] = html |> query("##{form}") |> LazyHTML.attribute("data-checked-values")
      assert checked =~ "content:read"
      assert checked =~ "billing:read"
    end
  end

  describe "component page links" do
    test "Mishka Tools points at doc_url and ARIA pattern at spec_url", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      links =
        html
        |> query("header a[target=_blank]")
        |> then(fn ls ->
          Enum.zip(LazyHTML.attribute(ls, "href"), Enum.map(ls, &LazyHTML.text/1))
        end)

      docs = Enum.find(links, fn {_h, t} -> t =~ "Mishka Tools" end)
      aria = Enum.find(links, fn {_h, t} -> t =~ "ARIA pattern" end)

      assert docs, "no Mishka Tools link"
      assert aria, "no ARIA pattern link"

      {doc_href, _} = docs
      {aria_href, _} = aria

      assert doc_href == "https://mishka.tools/chelekom/docs/headless/tree"

      # This linked to doc_url before — every headless page pointed "ARIA pattern" at mishka.tools.
      assert aria_href == "https://www.w3.org/WAI/ARIA/apg/patterns/treeview/"
    end

    test "every headless component carries both urls, so neither link is ever wrong", %{conn: _} do
      for c <- DevelopmentWeb.Showcase.HeadlessCatalog.all() do
        assert c.doc_url, "#{c.name} has no doc_url"
        assert c.spec_url, "#{c.name} has no spec_url"
        assert c.doc_url =~ "mishka.tools", "#{c.name} doc_url is not a Mishka docs link"
        refute c.spec_url =~ "mishka.tools", "#{c.name} spec_url points back at the docs"
      end
    end
  end

  test "the drop indicator is styled — the hook sets the markers, the skin must paint them", %{
    conn: conn
  } do
    {:ok, _view, html} = live(conn, @path)

    # Headless ships no CSS: the hook writes data-drag-over/data-dragging, but if the consumer's
    # classes don't paint them the drop is invisible and you can't tell where the node will land.
    [classes] = html |> query("#hl-ex-tree-demos-dnd") |> LazyHTML.attribute("class")

    for marker <-
          ~w(data-drag-over=before data-drag-over=after data-drag-over=inside data-dragging) do
      assert classes =~ marker, "nothing paints #{marker}"
    end

    # The insertion line is absolutely positioned, so the label must establish a containing block.
    assert classes =~ "[&_[data-part=label]]:relative"
  end

  test "the Base UI gallery example renders for tree", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-baseui/tree")

    assert html |> query("[data-tree-root]") |> Enum.any?()
    # Base UI examples are Tailwind-only — no showcase theme vars leak in.
    refute html =~ "tree-hero\" class=\"[^\"]*var(--c-"
  end
end
