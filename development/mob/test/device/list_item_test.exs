defmodule MishkaMob.Device.ListItemTest do
  @moduledoc """
  Device tests for `MishkaListItem`: the real layout puts the leading slot, the
  body and the trailing slot on one line, in that order, and the row is a tap
  target.
  """
  use MishkaMob.DeviceCase, page: :list_item

  test "leading, body and trailing share a line, in order" do
    avatar = scroll_into_view("li-avatar")
    title = frame!("li-title")
    chevron = frame!("li-chevron")
    row = frame!("li-row")

    assert same_row?(avatar, title), "the avatar is not beside the body"
    assert same_row?(title, chevron), "the chevron is not beside the body"

    assert avatar.right <= title.left,
           "the leading slot overlaps the body: #{avatar.right} > #{title.left}"

    assert title.right <= chevron.left,
           "the body overlaps the trailing slot: #{title.right} > #{chevron.left}"

    assert row.left <= avatar.left and chevron.right <= row.right,
           "a slot escapes the row: #{inspect({row, avatar, chevron})}"
  end

  test "the row is one tap target" do
    tap("li-row")
  end
end
