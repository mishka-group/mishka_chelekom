defmodule MishkaMob.Device.SwitchTest do
  @moduledoc """
  Device tests for the Switch page: a port of `SwitchTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  A switch carries no text of its own (the label is a sibling Text inside the row), so
  the Kotlin suite reached the native Toggles with `isToggleable()` and matched each to
  its example by bounds. Here every switch and every label carries an `:id` (the
  Switch component now passes `id` through to the Toggle, and tags its label
  `<id>-label`), and the layout assertions compare the two frames.

  `the switch leads when the label prop is omitted` is the reported page. The
  "Without a label" example used to hand-build the very arrangement `label=` already
  produces, so it looked identical to the labelled example and demonstrated nothing.

  `toggling one example leaves the others alone` guards a state bug: that same example
  was bound to the assign the labelled Bluetooth switch already owned, so moving either
  moved both.

  Run with `mix test --only device test/device/switch_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :switch

  test "the switch leads when the label prop is omitted" do
    scroll_into_view("sw-airplane")

    text = frame!("sw-airplane-label")
    switch = frame!("sw-airplane")

    # THE difference. With `label=` the switch can only trail; omitting it is what buys
    # you the other order, and this is the only way to see that.
    assert switch.right <= text.left + 1,
           "the switch does not lead the text: switch=#{inspect(switch)} text=#{inspect(text)}"
  end

  test "a labelled switch trails its label" do
    scroll_into_view("sw-bluetooth")

    text = frame!("sw-bluetooth-label")
    switch = frame!("sw-bluetooth")

    assert switch.left >= text.right - 1,
           "the labelled switch does not trail: switch=#{inspect(switch)} text=#{inspect(text)}"
  end

  test "toggling one example leaves the others alone" do
    refute Map.fetch!(assigns(), :sw_airplane)

    # A real touch on the unlabelled switch. The summary line is rendered from the
    # Wi-Fi and Bluetooth assigns, so it is the honest witness for "did another
    # example move?".
    tap("sw-airplane")

    assert Map.fetch!(assigns(), :sw_airplane), "the touch did not turn the airplane switch on"
    summary = text_of!("sw-summary")

    assert summary =~ "Bluetooth is off",
           "toggling the unlabelled switch moved the Bluetooth example too: #{summary}"

    assert summary =~ "Wi-Fi is on", "toggling the unlabelled switch moved Wi-Fi too: #{summary}"

    # Put it back.
    tap("sw-airplane")
    refute Map.fetch!(assigns(), :sw_airplane)
  end

  test "a disabled switch cannot be moved" do
    scroll_into_view("sw-locked-on")
    before_on = frame!("sw-locked-on")
    before_off = frame!("sw-locked-off")

    # Disabled here means "no handler is wired", so the control renders normally and
    # simply never changes. A real touch on each must deliver nothing.
    tap("sw-locked-on", expect: :none)
    tap("sw-locked-off", expect: :none)

    assert frame!("sw-locked-on") == before_on, "the disabled switch moved"
    assert frame!("sw-locked-off") == before_off, "the disabled switch moved"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "With a label",
          "Custom colour",
          "Disabled",
          "Without a label",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(sw-wifi sw-colored sw-locked-on sw-airplane), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
