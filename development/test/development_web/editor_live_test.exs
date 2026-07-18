defmodule DevelopmentWeb.EditorLiveTest do
  @moduledoc """
  The `editor`'s server-rendered contract at `/showcase/headless/editor`.

  Everything asserted here is a rule that, if broken, produces a component that still renders and
  still passes a smoke test, but loses the user's document in production: a stripped ignore
  boundary, an unstable id, a mirror LiveView's form recovery skips, or config placed where the
  server can no longer reach it.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  @path "/showcase/headless/editor"

  defp query(html, selector), do: html |> LazyHTML.from_document() |> LazyHTML.query(selector)

  defp attr(html, selector, name),
    do: html |> query(selector) |> LazyHTML.attribute(name) |> List.first()

  describe "the ignore boundary" do
    test "the hook sits on an INNER surface, never on the root", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      root = query(html, "[data-part=root].chelekom-editor")
      surface = query(html, "[data-part=surface]")

      assert Enum.any?(root)
      assert Enum.any?(surface)

      refute LazyHTML.attribute(root, "phx-hook") |> List.first(),
             "the hook must NOT be on the root: LiveView merges only data-* on an ignored " <>
               "element, so the root's class would freeze at first render"

      assert LazyHTML.attribute(surface, "phx-hook") |> List.first() == "Editor"
      assert LazyHTML.attribute(surface, "phx-update") |> List.first() == "ignore"
    end

    test "the surface id derives from the root id and is stable", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      root_id = attr(html, "[data-part=root].chelekom-editor", "id")
      surface_id = attr(html, "[data-part=surface]", "id")

      assert root_id

      assert surface_id == "#{root_id}-surface",
             "a changed id makes morphdom replace the node, destroying the editor and its undo history"

      # The engine filters chelekom:editor on this, so the server must know it.
      assert attr(html, "[data-part=surface]", "data-root-id") == root_id
    end

    test "all live config is on the surface, the only channel that crosses the boundary", %{
      conn: conn
    } do
      {:ok, _view, html} = live(conn, @path)

      for name <- ~w(data-format data-editable data-debounce data-value-id) do
        assert attr(html, "[data-part=surface]", name),
               "#{name} must be on the surface — data-* is what LiveView merges on an ignored element"
      end
    end
  end

  describe "form participation" do
    test "the mirror carries name but never phx-change", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/showcase/headless/editor")

      mirror = query(html, "textarea[data-part=value]")
      assert Enum.any?(mirror), "the form demo must render a hidden mirror"

      assert LazyHTML.attribute(mirror, "name") |> List.first() == "post[body]"

      refute LazyHTML.attribute(mirror, "phx-change") |> List.first(),
             "LiveView's form recovery skips elements carrying phx-change — the document would " <>
               "be silently lost on reconnect"

      assert LazyHTML.attribute(mirror, "hidden") |> List.first()
    end

    test "the server receives the document through an ordinary phx-change", %{conn: conn} do
      {:ok, view, _html} = live(conn, @path)

      doc =
        ~s({"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"hello"}]}]})

      html =
        view
        |> form("#hl-ex-editor-form-form", %{"post" => %{"body" => doc}})
        |> render_change()

      assert html =~ "#{String.length(doc)}</strong>",
             "the demo echoes the live length, proving the server saw the edit"
    end

    test "submitting shows the document the server received", %{conn: conn} do
      {:ok, view, _html} = live(conn, @path)

      doc = ~s({"type":"doc","content":[]})

      html =
        view
        |> form("#hl-ex-editor-form-form", %{"post" => %{"body" => doc}})
        |> render_submit()

      assert html =~ "Submitted document"
    end
  end

  describe "toolbar" do
    test "buttons declare commands the engine knows and are real buttons", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      buttons = query(html, "[data-part=toolbar] button[data-editor-command]")
      assert Enum.count(buttons) >= 4

      # type=button, or the first toolbar click would submit the surrounding form.
      for type <- LazyHTML.attribute(buttons, "type") do
        assert type == "button"
      end

      known =
        ~w(bold italic strike code paragraph h1 h2 h3 bullet_list ordered_list blockquote
           code_block horizontal_rule undo redo)

      for command <- LazyHTML.attribute(buttons, "data-editor-command") do
        assert command in known,
               "unknown toolbar command #{inspect(command)} — the engine ignores it"
      end
    end

    test "the toolbar is labelled and points at the surface it controls", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      assert attr(html, "[data-part=toolbar]", "role") == "toolbar"
      assert attr(html, "[data-part=toolbar]", "aria-label")

      assert attr(html, "[data-part=toolbar]", "aria-controls") ==
               attr(html, "[data-part=surface]", "id")
    end
  end

  describe "accessibility" do
    test "the surface is an accessible multiline textbox", %{conn: conn} do
      {:ok, _view, html} = live(conn, @path)

      assert attr(html, "[data-part=surface]", "role") == "textbox"
      assert attr(html, "[data-part=surface]", "aria-multiline") == "true"

      assert attr(html, "[data-part=surface]", "aria-label") ||
               attr(html, "[data-part=surface]", "aria-labelledby"),
             "an unlabelled textbox is unusable with a screen reader"
    end
  end

  describe "the npm dependency is really wired" do
    test "the engine is vendored and registered as a hook", %{conn: _conn} do
      engine = File.read!("assets/vendor/editor_tiptap.js")

      assert engine =~ ~s(from "@tiptap/core"),
             "the engine must import the npm package, not a vendored copy"

      registry = File.read!("assets/vendor/mishka_components.js")
      assert registry =~ ~s(import Editor from "./editor_tiptap.js")
      assert registry =~ "Editor,"
    end

    test "the packages are pinned in package.json and installed" do
      pkg = "assets/package.json" |> File.read!() |> Jason.decode!()

      for name <- ~w(@tiptap/core @tiptap/pm @tiptap/starter-kit) do
        assert pkg["dependencies"][name] == "3.28.0",
               "#{name} must be pinned exactly — peer-pinned packages drifting apart yields two " <>
                 "prosemirror-model copies and an opaque runtime RangeError"

        assert File.dir?("assets/node_modules/#{name}"),
               "#{name} is not installed; run mix assets.setup"
      end
    end
  end
end
