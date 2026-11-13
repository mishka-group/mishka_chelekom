defmodule MishkaMob.Device.ListItemTest do
  @moduledoc """
  Device tests for `MishkaListItem`: the real layout puts the leading slot, the
  body and the trailing slot on one line, in that order, and the row is a tap
  target.
  """
  use MishkaMob.DeviceCase, page: :list_item

  test "leading and trailing sit on one line with room for the body between" do
    avatar = scroll_into_view("li-avatar")
    chevron = frame!("li-chevron")
    row = frame!("li-row")

    assert same_row?(avatar, chevron), "the slots are on different lines"

    assert avatar.right < chevron.left,
           "the leading slot overlaps the trailing one: #{avatar.right} > #{chevron.left}"

    # The body's space is the gap between the slots; without it the trailing
    # slot would butt against the avatar.
    assert chevron.left - avatar.right >= 100,
           "the body has no room: #{chevron.left - avatar.right}dp between the slots"

    assert row.left <= avatar.left and chevron.right <= row.right,
           "a slot escapes the row: #{inspect({row, avatar, chevron})}"
  end

  test "the row is one tap target" do
    tap("li-row")
  end
end
