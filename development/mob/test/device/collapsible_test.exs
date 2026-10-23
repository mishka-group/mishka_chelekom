defmodule MishkaMob.Device.CollapsibleTest do
  @moduledoc """
  Device tests for the Collapsible page: a port of `CollapsibleTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  A closed region is not in the tree at all, since the component builds the panel
  only when `open` is true, so every assertion here is a real round trip: tap the
  trigger, the screen flips its boolean, the next render contains the body. Each
  example has an `id`: `<id>-trigger` is the header and `<id>-panel` the region.

  A collapsible fires a BARE `{:tap, tag}`, because there is only ever one region.
  That is the whole reason it is not a one-item accordion.

  Run with `mix test --only device test/device/collapsible_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :collapsible

  test "the trigger shows and hides its region" do
    refute_shown("cl-tinted-panel")

    # Both directions from one bare tag: the screen flips a boolean, so the same
    # trigger closes what it opened.
    tap("cl-tinted-trigger")
    assert_shown("cl-tinted-panel")

    tap("cl-tinted-trigger")
    refute_shown("cl-tinted-panel")
  end

  test "a disabled trigger opens nothing" do
    assert_shown("cl-off-trigger")
    assert_shown("cl-off-open-trigger")
    refute_shown("cl-off-panel")
    assert_shown("cl-off-open-panel")

    # disabled wires no handler at all, so there is nothing to fire: a real touch
    # reaches nothing, rather than reaching a handler that then ignores it.
    tap("cl-off-trigger", expect: :none)
    refute_shown("cl-off-panel")

    # And it cannot close what the screen holds open either.
    tap("cl-off-open-trigger", expect: :none)
    assert_shown("cl-off-open-panel")
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A disclosure",
          "Without a chevron",
          "Disabled",
          "Custom colours",
          "Props"
        ] do
      assert_text(heading)
    end

    for id <- ~w(cl-basic cl-plain cl-off cl-off-open cl-tinted), do: assert_shown(id)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
