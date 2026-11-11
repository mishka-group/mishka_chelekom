defmodule MishkaMob.Device.ActionIconOverlayTest do
  @moduledoc """
  Device test for `MishkaActionIcon overlay`: the badge is drawn over the glyph
  in the target's top-right corner, not beside it or outside it.
  """
  use MishkaMob.DeviceCase, page: :action_icon

  test "the badge sits in the top-right half of the target" do
    bell = scroll_into_view("ai-bell")
    dot = frame!("ai-dot")

    assert dot.left > bell.left + bell.width / 2,
           "the badge is not on the right half of the target"

    assert dot.top < bell.top + bell.height / 2,
           "the badge is not on the top half of the target"

    assert bell.left <= dot.left and dot.right <= bell.right,
           "the badge escapes the target horizontally"

    assert bell.top <= dot.top and dot.bottom <= bell.bottom,
           "the badge escapes the target vertically"
  end

  test "the decorated button is still one tap target" do
    tap("ai-bell")
  end
end
