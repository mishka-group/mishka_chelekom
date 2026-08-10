defmodule DevelopmentWeb.HeadlessDOM do
  @moduledoc """
  Query helpers for asserting on a rendered headless component.

  `Phoenix.LiveViewTest.render_component/2` returns HTML, and `LazyHTML.query/2` searches
  *descendants* — so a component whose root is the whole fragment (the file input, the card) never
  matches its own selector. Everything here goes through `doc/1`, which wraps the fragment first.
  """

  @doc "Parse a `render_component/2` result into a queryable document."
  @spec doc(String.t()) :: LazyHTML.t()
  def doc(html), do: LazyHTML.from_fragment(~s|<div id="test-root">| <> html <> "</div>")

  @doc "The named attribute of the first element matching `selector`, or nil."
  @spec attr(LazyHTML.t(), String.t(), String.t()) :: String.t() | nil
  def attr(doc, selector, name) do
    doc |> LazyHTML.query(selector) |> LazyHTML.attribute(name) |> List.first()
  end

  @doc """
  Whether the first element matching `selector` carries the attribute at all.

  HEEx renders a true boolean as a bare attribute, so its value is `""` — presence is the only
  thing worth asserting on `disabled`, `multiple`, `data-invalid` and friends.
  """
  @spec has_attr?(LazyHTML.t(), String.t(), String.t()) :: boolean()
  def has_attr?(doc, selector, name), do: attr(doc, selector, name) != nil

  @doc "The `data-part` of every element matching `selector`, in document order."
  @spec parts(LazyHTML.t(), String.t()) :: [String.t()]
  def parts(doc, selector) do
    doc |> LazyHTML.query(selector) |> LazyHTML.attribute("data-part")
  end

  @doc "The tag name of the first element matching `selector`, or nil."
  @spec tag(LazyHTML.t(), String.t()) :: String.t() | nil
  def tag(doc, selector), do: doc |> LazyHTML.query(selector) |> LazyHTML.tag() |> List.first()
end
