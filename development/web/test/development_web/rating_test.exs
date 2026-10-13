defmodule DevelopmentWeb.RatingTest do
  @moduledoc """
  The styled `rating`: a `select` given as text fills the same stars as the number, and a star it
  does not fill keeps the component's own empty colour, at full opacity.
  """
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  alias DevelopmentWeb.Components.Rating

  defp stars(assigns) do
    assigns = Map.merge(%{__changed__: nil}, assigns)

    ~H"""
    <Rating.rating {@attrs} />
    """
    |> rendered_to_string()
    |> LazyHTML.from_fragment()
  end

  defp rated(attrs), do: %{attrs: attrs} |> stars() |> LazyHTML.query("svg.rated") |> Enum.count()

  test "select as text fills as many stars as the number does" do
    for {text, number} <- [{"3", 3}, {"0", 0}, {"5", 5}, {"2.5", 2.5}] do
      assert rated(%{select: text}) == rated(%{select: number}), "select=#{inspect(text)}"
    end

    assert rated(%{select: "3"}) == 3
    assert rated(%{select: "2.5"}) == 3
  end

  test "a select that is no number fills nothing" do
    assert rated(%{select: "many"}) == 0
    assert rated(%{select: ""}) == 0
    assert rated(%{select: nil}) == 0
  end

  test "an empty star's path carries no opacity class of its own" do
    paths = %{attrs: %{select: 2}} |> stars() |> LazyHTML.query("svg:not(.rated) path")

    assert Enum.count(paths) == 3
    assert paths |> LazyHTML.attribute("class") |> Enum.all?(&is_nil/1)
  end
end
