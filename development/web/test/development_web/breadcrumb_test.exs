defmodule DevelopmentWeb.BreadcrumbTest do
  @moduledoc """
  A breadcrumb in a narrow parent wraps to the next line instead of overlapping its items, and its
  icons and separators keep their size while the text around them wraps.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Breadcrumb

  defp trail(assigns) do
    items =
      for label <- ~w(Home Library Data) do
        %{inner_block: fn _, _ -> label end, __slot__: :item, icon: "hero-home", link: "/"}
      end

    doc(render_component(&Breadcrumb.breadcrumb/1, Map.put(assigns, :item, items)))
  end

  defp classes(doc, selector) do
    doc |> LazyHTML.query(selector) |> LazyHTML.attribute("class") |> Enum.map(&String.split/1)
  end

  test "the list wraps" do
    assert [list] = classes(trail(%{}), "ol")
    assert "flex-wrap" in list
  end

  test "icons and separators do not shrink" do
    doc = trail(%{})

    for selector <- [".breadcrumb-icon", ".separator-icon"] do
      assert [_ | _] = found = classes(doc, selector)
      assert Enum.all?(found, &("shrink-0" in &1)), selector
    end

    text = trail(%{separator_icon: nil, separator_text: "/"})
    assert [_ | _] = found = classes(text, ".separator-text")
    assert Enum.all?(found, &("shrink-0" in &1))
  end

  test "a separator ends its own item, so a wrapped line never starts with one" do
    doc = trail(%{})

    assert doc |> LazyHTML.query("li") |> Enum.count() == 3
    assert doc |> LazyHTML.query("li > .separator-icon") |> Enum.count() == 2
    assert doc |> LazyHTML.query("li:last-child > .separator-icon") |> Enum.count() == 0
  end
end
