defmodule MishkaMob.Device.TextInputTest do
  @moduledoc """
  Device tests for `MishkaTextInput`: the field takes real key events, and its
  leading/trailing nodes flank it rather than stacking above or below.
  """
  use MishkaMob.DeviceCase, page: :text_input

  test "typing reaches the screen's value" do
    focus("ti-plain")
    type("Dune")

    assert_eventually(fn -> value_of("ti-plain") == "Dune" end)
  end

  test "leading and trailing nodes sit on either side of the field" do
    leading = scroll_into_view("ti-leading")
    field = frame!("ti-slots")
    trailing = frame!("ti-trailing")

    assert same_row?(leading, field), "the leading node is not beside the field"
    assert same_row?(field, trailing), "the trailing node is not beside the field"

    assert leading.right <= field.left,
           "the leading node overlaps the field: #{leading.right} > #{field.left}"

    assert field.right <= trailing.left,
           "the trailing node overlaps the field: #{field.right} > #{trailing.left}"
  end
end
