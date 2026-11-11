defmodule MishkaMob.Device.CardWeightTest do
  @moduledoc """
  Device test for `MishkaCard weight`: two cards at weight 1.0 split their row
  evenly, which no node tree can prove.
  """
  use MishkaMob.DeviceCase, page: :card

  test "two cards at weight 1 share the row evenly" do
    left = scroll_into_view("card-weight-left")
    right = frame!("card-weight-right")

    assert same_row?(left, right), "the two cards are on different lines"
    assert left.right <= right.left, "the cards overlap: #{left.right} > #{right.left}"
    assert_in_delta left.width, right.width, 1.0
  end
end
