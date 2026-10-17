defmodule DevelopmentWeb.PanelClassesTest do
  @moduledoc """
  The sidebar and the drawer open and close by adding and removing classes on their root.

  A command can only remove a class the root renders, so each command's classes are read from
  the `Phoenix.LiveView.JS` it builds and checked against the classes of the rendered root, and
  the showcase previews, which add classes of their own, may not make one of them important:
  `translate-none!` keeps a panel open however many times `translate-none` is removed.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.{Drawer, Sidebar}
  alias DevelopmentWeb.Showcase.Preview

  defp classes(js, op), do: for([^op, %{names: names}] <- js.ops, name <- names, do: name)

  defp root_classes(html, selector) do
    html
    |> doc()
    |> LazyHTML.query(selector)
    |> LazyHTML.attribute("class")
    |> List.first()
    |> String.split()
  end

  defp inner_block, do: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]

  defp render_sidebar(extra) do
    render_component(
      &Sidebar.sidebar/1,
      Map.merge(%{id: "sb", inner_block: inner_block()}, extra)
    )
  end

  describe "sidebar" do
    for position <- ["left", "right"] do
      test "hide_sidebar adds what the #{position} root renders closed and removes what show adds" do
        hide = Sidebar.hide_sidebar("sb", unquote(position))
        show = Sidebar.show_sidebar("sb", unquote(position))
        root = root_classes(render_sidebar(%{hide_position: unquote(position)}), "#sb")

        assert classes(hide, "add_class") != []
        assert Enum.all?(classes(hide, "add_class"), &(&1 in root))
        assert classes(show, "remove_class") == classes(hide, "add_class")
        assert classes(show, "add_class") == classes(hide, "remove_class")
        assert "translate-none" in classes(hide, "remove_class")
      end
    end

    test "the showcase preview renders the class its close command removes, not an important one" do
      html = render_component(&Preview.show/1, preview("sidebar", %{hide_position: "left"}))
      root = root_classes(html, "aside")
      hide = Sidebar.hide_sidebar("sb", "left")

      assert "translate-none" in root
      assert "translate-none" in classes(hide, "remove_class")

      for class <- classes(hide, "remove_class") ++ classes(hide, "add_class") do
        refute (class <> "!") in root, "#{class}! on the sidebar root outlives its close command"
      end
    end
  end

  describe "drawer" do
    for position <- ["left", "right", "top", "bottom"] do
      test "hide_drawer adds what the #{position} root renders closed and removes what show adds" do
        hide = Drawer.hide_drawer("dr", unquote(position))
        show = Drawer.show_drawer("dr", unquote(position))

        html =
          render_component(
            &Drawer.drawer/1,
            %{id: "dr", position: unquote(position), inner_block: inner_block()}
          )

        root = root_classes(html, "#dr")

        assert Enum.all?(classes(hide, "add_class"), &(&1 in root))
        assert Enum.all?(classes(show, "remove_class"), &(&1 in root))
        assert Enum.all?(classes(hide, "remove_class"), &(&1 in classes(show, "add_class")))
      end
    end

    test "the showcase preview does not make a class its commands change important" do
      html = render_component(&Preview.show/1, preview("drawer", %{position: "left"}))
      hide = Drawer.hide_drawer("dr", "left")

      tokens =
        html
        |> doc()
        |> LazyHTML.query("[class]")
        |> LazyHTML.attribute("class")
        |> Enum.flat_map(&String.split/1)

      for class <- classes(hide, "remove_class") ++ classes(hide, "add_class") do
        refute (class <> "!") in tokens, "#{class}! in the drawer preview"
      end
    end
  end

  defp preview(component, props) do
    %{component: component, id: "pv", props: props, sample: "x", form: nil}
  end
end
