defmodule DevelopmentWeb.AvatarTest do
  @moduledoc """
  An avatar keeps its size in a flex row. Its root clips its content, which lets a flex parent
  shrink it below its width, so initials such as `+20` were cut off in a narrow row.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Avatar

  defp root_classes(assigns) do
    assigns = Map.put_new(assigns, :inner_block, [%{inner_block: fn _, _ -> "SB" end}])

    (&Avatar.avatar/1)
    |> render_component(assigns)
    |> doc()
    |> LazyHTML.query("#test-root > *")
    |> LazyHTML.attribute("class")
    |> List.first()
    |> String.split()
  end

  test "every kind of avatar refuses to shrink" do
    for src <- [nil, "/images/avatar.png"], rounded <- ["full", "medium"] do
      assert "shrink-0" in root_classes(%{src: src, rounded: rounded}),
             "src=#{inspect(src)} rounded=#{rounded}"
    end
  end
end
