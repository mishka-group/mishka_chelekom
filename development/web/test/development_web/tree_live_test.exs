defmodule DevelopmentWeb.TreeLiveTest do
  @moduledoc """
  Drives the two pages the headless tree lives on: `/showcase/headless/tree` (the live preview) and
  `/showcase/headless-baseui/tree` (the Base UI gallery port).

  Two things are guarded here. The first is the port itself — the WAI-ARIA treeview conformance the
  component renders server-side (aria-level/setsize/posinset, aria-checked="mixed", a real
  aria-multiselectable value, one tab stop), none of which the JS hook can be blamed for.

  The second is the wiring: the component ships NO CSS, so a showcase that forgets to consume
  `--label-offset`, to leave the collapsed subtree's `hidden` alone, or to point the chevron at its
  own node renders a flat, unusable tree that still "passes" a smoke test.

  Every lookup is scoped to one tree by id — the preview renders three over different data, so an
  unscoped `data-value=` match would answer from whichever tree came first.

  Queries go through `LazyHTML`, which LiveView 1.1 already requires for `LiveViewTest` — no Floki.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.HeadlessBaseUIExamples
  alias DevelopmentWeb.Showcase.HeadlessPreview

  # The preview's three trees, and the Base UI gallery's one.
  @files "hl-tree"
  @multi "hl-tree-multi"
  @checks "hl-tree-checks"
  @hero "baseui-tree-hero"

  defp query(html, selector), do: html |> LazyHTML.from_document() |> LazyHTML.query(selector)

  defp node_attr(html, tree_id, value, attr) do
    html
    |> query(~s(##{tree_id} li[data-value="#{value}"]))
    |> LazyHTML.attribute(attr)
    |> List.first()
  end

  defp node?(html, tree_id, value) do
    html |> query(~s(##{tree_id} li[data-value="#{value}"])) |> Enum.any?()
  end

  defp root_attr(html, tree_id, attr) do
    html |> query("##{tree_id}") |> LazyHTML.attribute(attr) |> List.first()
  end

  # The subtree a node owns, not its descendants'.
  defp subtree_attr(html, tree_id, value, attr) do
    html
    |> query(~s(##{tree_id} li[data-value="#{value}"] > ul[data-part="subtree"]))
    |> LazyHTML.attribute(attr)
    |> List.first()
  end

  defp preview(conn) do
    {:ok, _view, html} = live(conn, ~p"/showcase/headless/tree")
    html
  end

  defp gallery(conn) do
    {:ok, _view, html} = live(conn, ~p"/showcase/headless-baseui/tree")
    html
  end

  describe "the headless preview page" do
    test "renders every demo tree, hooked", %{conn: conn} do
      html = preview(conn)

      for id <- [@files, @multi, @checks] do
        assert root_attr(html, id, "phx-hook") == "Tree", "#{id} is not hooked"
        assert root_attr(html, id, "role") == "tree"
        assert root_attr(html, id, "data-tree-root")
      end
    end

    test "renders the full nested hierarchy with roles and levels", %{conn: conn} do
      html = preview(conn)

      assert node?(html, @files, "src/components/Tree.tsx")
      assert node_attr(html, @files, "src", "role") == "treeitem"
      assert node_attr(html, @files, "src", "data-level") == "1"
      assert node_attr(html, @files, "src/components", "data-level") == "2"
      assert node_attr(html, @files, "src/components/Tree.tsx", "data-level") == "3"
    end

    test "expanded={[...]} opens exactly the listed nodes", %{conn: conn} do
      html = preview(conn)

      assert node_attr(html, @files, "src", "data-expanded") == "true"
      assert node_attr(html, @files, "src/components", "data-expanded") == "false"
    end

    test "expanded={:all} opens every parent, and leaves stay inert", %{conn: conn} do
      html = preview(conn)

      assert node_attr(html, @multi, "design", "data-expanded") == "true"
      assert node_attr(html, @multi, "eng", "data-expanded") == "true"

      # A leaf never claims expandability.
      refute node_attr(html, @multi, "ana", "data-expanded")
      refute node_attr(html, @multi, "ana", "data-has-children")
    end

    test "the server publishes its expanded set so it can take control back", %{conn: conn} do
      html = preview(conn)

      # Per-node data-expanded cannot drive this: when the server re-renders an unchanged value
      # LiveView sends no diff, so the DOM keeps whatever the hook wrote. This one attribute is
      # the server's unambiguous statement of intent.
      assert root_attr(html, @files, "data-expanded-values") == ~s(["src"])

      # `:all` resolves server-side to the real parent list, not the literal atom.
      values = root_attr(html, @multi, "data-expanded-values")
      assert Jason.decode!(values) |> Enum.sort() == ["design", "eng"]
    end

    test "options are wired onto the root element", %{conn: conn} do
      html = preview(conn)

      assert root_attr(html, @files, "data-select-on-click") == "true"
      assert root_attr(html, @multi, "data-multiple") == "true"
      assert root_attr(html, @multi, "data-allow-range-selection") == "true"
      assert root_attr(html, @checks, "data-with-checkboxes") == "true"
    end

    test "the :node slot receives the node and its derived state", %{conn: conn} do
      html = preview(conn)

      # The slot draws the icons: headless ships none, so a folder/file glyph proves the payload
      # (`has_children`) and the node map both arrive.
      assert html |> query(~s(##{@files} li[data-value="src"] svg)) |> Enum.any?()

      text =
        html
        |> query(~s(##{@files} li[data-value="src/components/Tree.tsx"] [data-part="label-text"]))
        |> LazyHTML.text()

      assert text =~ "Tree.tsx"
    end
  end

  # Headless ships zero CSS. Without these the tree renders as a flat, always-open list — which a
  # smoke test would still call a pass.
  describe "the preview supplies the styling the component omits" do
    test "a collapsed subtree is hidden, an expanded one is not", %{conn: conn} do
      html = preview(conn)

      # Tailwind's preflight hides `[hidden]` with `display: none !important`, and the hook toggles
      # the property on collapse — so the subtree must never be given a display utility.
      assert subtree_attr(html, @files, "src/components", "hidden")
      refute subtree_attr(html, @files, "src", "hidden")
    end

    test "the label consumes --label-offset, so nesting actually indents", %{conn: conn} do
      html = preview(conn)

      # Preflight zeroes every list's padding, so the component's per-node var is the only indent.
      assert node_attr(html, @files, "src/components", "style") =~
               "--label-offset: calc(var(--level-offset) * 1)"

      assert root_attr(html, @files, "style") =~ "--level-offset:"
      assert root_attr(html, @files, "class") =~ "pl-[calc(var(--label-offset)"
    end

    test "the chevron rotates for its own node only", %{conn: conn} do
      html = preview(conn)

      # A descendant match (`[data-expanded=true] [data-part=expand-icon]`) would also rotate every
      # chevron nested under an open folder; the child chain pins it to the node that owns it.
      assert root_attr(html, @files, "class") =~
               "[&_[data-expanded=true]>[data-part=label]>[data-part=expand-icon]]:rotate-90"

      assert html
             |> query(~s(##{@files} li[data-value="src"] > [data-part="label"] svg))
             |> Enum.any?()
    end
  end

  describe "WAI-ARIA treeview conformance" do
    test "aria-multiselectable renders as a real true/false value, not a bare attribute", %{
      conn: conn
    } do
      html = preview(conn)

      # HEEx renders `attr={true}` as a BARE attribute, whose DOM value is "" — an invalid token
      # for an ARIA true/false property, so AT falls back to the default (false) and a multi-select
      # tree is announced as single-select.
      assert root_attr(html, @multi, "aria-multiselectable") == "true"
      assert root_attr(html, @files, "aria-multiselectable") == "false"
    end

    test "the tree has an accessible name", %{conn: conn} do
      html = preview(conn)
      assert root_attr(html, @files, "aria-label") not in [nil, ""]
    end

    test "aria-checked lives on the treeitem, and aria-selected is not mixed in", %{conn: conn} do
      html = preview(conn)

      # APG: "If the selection state is indicated with aria-selected, then aria-checked is not
      # specified for any nodes." A checkbox tree reports aria-checked only.
      assert node_attr(html, @checks, "content:read", "aria-checked") == "true"
      assert node_attr(html, @checks, "content:write", "aria-checked") == "false"
      refute node_attr(html, @checks, "content", "aria-selected")

      # A parent whose leaves disagree is mixed; one whose leaves all agree is not.
      assert node_attr(html, @checks, "content", "aria-checked") == "mixed"
      assert node_attr(html, @checks, "billing", "aria-checked") == "true"

      # A tree without checkboxes reports aria-selected only.
      assert node_attr(html, @files, "src", "aria-selected") == "false"
      refute node_attr(html, @files, "src", "aria-checked")
    end

    test "a half-checked parent is indeterminate and cannot post itself", %{conn: conn} do
      html = preview(conn)

      assert node_attr(html, @checks, "content", "data-indeterminate") == "true"
      assert node_attr(html, @checks, "content", "data-checked") == "false"
      refute node_attr(html, @checks, "billing", "data-indeterminate")

      # An unchecked box is never submitted by a browser, so the parent cannot post.
      parent =
        html |> query(~s(##{@checks} li[data-value="content"] > div input[data-part="checkbox"]))

      assert LazyHTML.attribute(parent, "checked") == []
    end

    test "the checkbox carries the field name, so checked values post natively", %{conn: conn} do
      html = preview(conn)

      boxes = html |> query(~s(##{@checks} input[data-part="checkbox"]))
      assert "permissions[]" in LazyHTML.attribute(boxes, "name")
      assert "content:read" in LazyHTML.attribute(boxes, "value")
    end

    test "the checkbox is out of the tab sequence — a tree is ONE tab stop", %{conn: conn} do
      html = preview(conn)

      # Without tabindex=-1 an N-node tree becomes N+1 tab stops.
      tabindexes =
        html
        |> query(~s(##{@checks} input[data-part="checkbox"]))
        |> LazyHTML.attribute("tabindex")

      assert tabindexes != []
      assert Enum.all?(tabindexes, &(&1 == "-1"))

      # Exactly one treeitem is in the tab sequence.
      zero =
        html
        |> query(~s(##{@checks} li[role="treeitem"]))
        |> LazyHTML.attribute("tabindex")
        |> Enum.count(&(&1 == "0"))

      assert zero == 1
    end

    test "aria-level, aria-setsize and aria-posinset are set on every node", %{conn: conn} do
      html = preview(conn)

      # Required here because the component supports async loading, so the full set of nodes is
      # not always in the DOM.
      assert node_attr(html, @files, "src", "aria-level") == "1"
      assert node_attr(html, @files, "src", "aria-posinset") == "1"
      assert node_attr(html, @files, "src", "aria-setsize") == "3"

      assert node_attr(html, @files, "tsconfig.json", "aria-posinset") == "3"
      assert node_attr(html, @files, "tsconfig.json", "aria-setsize") == "3"

      # Position is per-level, not global.
      assert node_attr(html, @files, "src/components", "aria-setsize") == "2"
      assert node_attr(html, @files, "src/components/Tree.tsx", "aria-posinset") == "2"
    end

    test "aria-expanded is only on parents", %{conn: conn} do
      html = preview(conn)

      assert node_attr(html, @files, "src", "aria-expanded") == "true"
      assert node_attr(html, @files, "src/components", "aria-expanded") == "false"
      refute node_attr(html, @files, "package.json", "aria-expanded")
    end
  end

  describe "the Base UI gallery port" do
    test "renders the hero tree, hooked and nested", %{conn: conn} do
      html = gallery(conn)

      assert root_attr(html, @hero, "phx-hook") == "Tree"
      assert node_attr(html, @hero, "app/components", "data-level") == "2"
      assert node_attr(html, @hero, "app/components/Menu.tsx", "data-level") == "3"
    end

    test "shows a selected row and a real chevron", %{conn: conn} do
      html = gallery(conn)

      assert node_attr(html, @hero, "app/components/Menu.tsx", "data-selected") == "true"

      # The gallery rule: real icons, never a CSS glyph hack.
      assert html
             |> query(~s(##{@hero} li[data-value="app"] > [data-part="label"] svg path))
             |> Enum.any?()
    end

    test "the chevron and the indent are wired onto the component's own part classes", %{
      conn: conn
    } do
      html = gallery(conn)

      icon_classes =
        html |> query(~s(##{@hero} [data-part="expand-icon"])) |> LazyHTML.attribute("class")

      assert Enum.all?(
               icon_classes,
               &(&1 =~ "[[data-expanded=true]>[data-part=label]>&]:rotate-90")
             )

      label_classes =
        html |> query(~s(##{@hero} [data-part="label"])) |> LazyHTML.attribute("class")

      assert Enum.all?(label_classes, &(&1 =~ "pl-[calc(var(--label-offset)"))
    end

    test "is styled with Tailwind utilities only — no showcase theme vars", %{conn: _conn} do
      source = HeadlessBaseUIExamples.source("tree-hero")

      assert source =~ "<.tree"
      # Base UI's palette is self-contained: the gallery must not reach for the showcase's theme.
      refute source =~ "var(--c-"
      assert source =~ "neutral-950"
      assert source =~ "dark:"
    end
  end

  test "the copy-paste block is lifted from the preview's real source", %{conn: _conn} do
    source = HeadlessPreview.source("tree")

    # source/1 re-reads this module's file with a regex, so a mis-indented ~H silently yields nil.
    assert is_binary(source)
    assert source =~ "<.tree"
    assert source =~ "<:expand_icon>"
  end

  test "the API table is derived from the component's real attrs", %{conn: conn} do
    html = preview(conn)

    # Read the name column only — matching anywhere in the table would also hit doc prose.
    names =
      html
      |> query("table tbody tr td:first-child")
      |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))

    for name <- ~w(nodes expanded with_checkboxes check_strictly with_lines allow_drop name) do
      assert name in names, "attrs table missing #{name}"
    end

    # The styled component's opinions did not survive the port to headless.
    for gone <- ~w(variant color size rounded padding space border) do
      refute gone in names, "#{gone} is a styling knob a headless component must not ship"
    end

    # `:rest` is a global passthrough, not a documented option.
    refute "rest" in names
  end
end
