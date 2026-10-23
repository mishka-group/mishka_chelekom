defmodule MishkaMob.Device.HarnessTest do
  @moduledoc """
  The device suite's own checks: that the harness reports what it should and that
  its pacing does not lose taps. Run with the rest of the suite
  (`mix test --only device`); a failure here means a failure elsewhere is the
  harness, not the component.
  """
  use MishkaMob.DeviceCase, page: :popover

  @toggles 40

  # The race this suite exists to survive. Event handles carry their render
  # generation and native drops a tap sent with a stale one. `settle` alone lost 12
  # of 30 rapid taps; with the native barrier none are lost. `retry: 0` switches the
  # one-retry safety net off, so a single drop fails the test instead of being papered
  # over.
  test "rapid toggles lose no tap" do
    dropped_before = stats().retried

    for round <- 1..@toggles do
      open? = rem(round, 2) == 1
      tap(if(open?, do: "pop-trigger-closed", else: "pop-trigger-open"), retry: 0)

      assert Map.fetch!(assigns(), :pop_details) == open?,
             "toggle #{round} left the popover #{if open?, do: "closed", else: "open"}"
    end

    assert stats().retried == dropped_before
  end

  test "a tap that reaches nothing delivers no event" do
    # The gutter at the very left of the page has no handler under it.
    {_x, y} = "pop-trigger-closed" |> frame!() |> center()

    assert [] = tap_xy(1.0, y, expect: :none)
    refute_shown("pop-panel")
  end

  # The bug: scrollInfo reported viewport_w equal to viewport_h, so a scroll view
  # always read as a square.
  test "scroll_info reports the viewport's own width and height" do
    %{viewport: {width, height}, content: {content_w, content_h}} =
      Mob.Test.scroll_info(device!(), "page")

    assert width > 0 and height > 0
    assert width != height, "viewport width and height are the same number: #{width}"
    assert content_w == width, "a vertical scroll is as wide as its viewport"
    assert content_h > height, "the page should scroll"
  end

  # The bug: scrollInfo read Compose state off the main thread and, racing a layout,
  # threw "Reading a state that was created after the snapshot was taken", which took
  # the app down. Hammer it while the page is moving.
  test "scroll_info survives being read while the page scrolls" do
    node = device!()

    reader =
      Task.async(fn ->
        for _read <- 1..60, do: Mob.Test.scroll_info(node, "page")
      end)

    {_x, y} = center(frame!("page"))
    swipe({100.0, y + 150}, {100.0, y - 150})
    swipe({100.0, y - 150}, {100.0, y + 150})

    assert reader |> Task.await(10_000) |> Enum.all?(&is_map/1)
    assert Map.has_key?(Mob.Test.scroll_info(node, "page"), :offset), "the app is still answering"
  end

  # The bug: a node that left the composition kept its frame, so "is the panel gone"
  # read the last place it was.
  test "a frame goes when its node leaves the screen" do
    tap("pop-trigger-closed")
    assert_shown("pop-panel")

    tap("pop-close")

    refute_shown("pop-panel")
    refute Map.has_key?(frames(), "pop-panel"), "the closed panel's frame outlived it"
  end

  test "the native barrier answers with the screen's geometry" do
    info = Mob.Test.screen_info(device!())

    assert info.width > 0 and info.height > info.width
    assert info.scale > 1
    assert Map.has_key?(info.safe_area, :top)
  end

  # The soft keyboard resizes the page for ~400ms after a field takes focus, and a frame
  # read in that window is a frame in flight. The tap does the waiting, so the page holds
  # still the moment it returns.
  @tag page: :autocomplete
  test "a tap on a text field returns with the page at rest" do
    tap("ac-city-input", retry: 0)

    at_rest = frame!("page")
    for _frame <- 1..4, do: barrier()

    assert frame!("page") == at_rest, "the page was still moving when the tap returned"
  end

  # A field with no on_focus delivers no event, which tap/2 would report as a drop.
  @tag page: :json_input
  test "focus reaches a field that has no on_focus, and tap says to use it" do
    assert_raise ExUnit.AssertionError, ~r/focus\/1/, fn -> tap("json-valid", retry: 0) end

    before = value_of("json-valid")
    focus("json-valid")
    type("x")

    assert_eventually(fn -> value_of("json-valid") == before <> "x" end,
      message: fn ->
        "the key did not reach the focused field: #{inspect(value_of("json-valid"))}"
      end
    )
  end

  # A canvas drag leaves no Mob.Agent.Receipts entry, so tap/2's default would call the
  # touch a drop.
  @tag page: :hue_slider
  test "a canvas takes touches that leave no receipt" do
    touch("hue-strip", 0.1)
    low = readout_int(~r/\A\d+°\z/)

    tap("hue-strip", expect: :any, retry: 0)
    touch("hue-strip", 0.9)

    assert readout_int(~r/\A\d+°\z/) > low, "the touch on the strip set nothing"
  end

  # A finger lifted at speed leaves a fling that swallows the next tap.
  test "a swipe returns once the page has stopped scrolling" do
    {_x, y} = center(frame!("page"))
    swipe({100.0, y + 150}, {100.0, y - 150})

    %{offset: at_rest} = Mob.Test.scroll_info(device!(), "page")
    for _frame <- 1..4, do: barrier()

    assert %{offset: ^at_rest} = Mob.Test.scroll_info(device!(), "page")
  end

  # Another gesture refuses while a finger is down, so a tap that lands proves it is up.
  test "while_pressed lifts the finger even when its body fails" do
    {_x, y} = center(frame!("page"))

    assert_raise RuntimeError, "boom", fn ->
      while_pressed({1.0, y}, fn -> raise "boom" end)
    end

    tap("pop-trigger-closed", retry: 0)
    assert_shown("pop-panel")
  end

  # Independent of the screen: the tag nearest the middle of the fresh page is pushed up
  # to a tenth of the way down the viewport by a measured scroll, which is certainly
  # off-centre, and `center: true` must bring it back.
  test "scroll_into_view center: true brings a tag that is only on screen to the middle" do
    node = device!()
    page = frame!("page")
    {_x, middle} = center(page)

    tag =
      frames()
      |> Enum.filter(fn {tag, {_x, top, _w, height}} ->
        tag != "page" and height > 0 and top + height / 2 > page.top and
          top + height / 2 < page.bottom
      end)
      |> Enum.min_by(fn {_tag, {_x, top, _w, height}} -> abs(top + height / 2 - middle) end)
      |> elem(0)

    {_x, y} = tag |> frame!() |> center()
    %{offset: {_ox, offset}} = Mob.Test.scroll_info(node, "page")
    pushed_to = page.top + page.height * 0.1
    :ok = Mob.Test.scroll_to(node, "page", {0.0, offset + (y - pushed_to) * screen().scale})
    sync()

    {_x, off_centre} = tag |> frame!() |> center()
    assert middle - off_centre > page.height / 4, "#{tag} was not pushed off-centre"
    assert scroll_into_view(tag) |> center() |> elem(1) == off_centre, "it is already on screen"

    {_x, centred} = tag |> scroll_into_view(center: true) |> center()

    assert abs(centred - middle) <= page.height / 4 + 1,
           "#{tag} is still #{abs(centred - middle)}dp from the middle of a #{page.height}dp page"
  end

  test "fresh_page puts a page back to the top, in the default theme" do
    scroll_page(:bottom)
    :rpc.call(device!(), Mob.State, :put, [:theme, :light])

    fresh_page(:popover)

    assert %{offset: {+0.0, +0.0}} = Mob.Test.scroll_info(device!(), "page")
    assert :rpc.call(device!(), Mob.State, :get, [:theme]) == :dark
    refute_shown("pop-panel")
  end
end
