defmodule MishkaMob.Device.TabsTest do
  @moduledoc """
  Device tests for the Tabs page: a port of `TabsTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  A tab announces itself with a colour and a 2dp underline, and a device test can
  read neither, so the component folds the state into its own tag
  (`<id>-tab-<tab>-active|idle|disabled`). That is what makes "which tab is
  selected" answerable here at all.

  The headline test is `the strip drags sideways to reach tabs past the edge`. The
  strip shipped as a bare Row, which cannot wrap, so the fifth tab was drawn
  off-screen and was unreachable for good: invisible on this page until an example
  had more tabs than fit.

  Run with `mix test --only device test/device/tabs_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :tabs

  import MishkaMob.DeviceText

  @main ~w(overview specs support)
  @locked ~w(overview locked specs)

  # Which tab of `strip` is active, by reading the state out of the tags.
  defp active_tab(strip, tabs), do: Enum.find(tabs, &shown?("#{strip}-tab-#{&1}-active"))

  # The tab's tag, whichever state it is in now.
  defp tab_tag(strip, tab) do
    ~w(idle active disabled)
    |> Enum.map(&"#{strip}-tab-#{tab}-#{&1}")
    |> Enum.find(&shown?/1) || flunk("no tab tagged #{strip}-tab-#{tab}-*")
  end

  defp tap_tab(strip, tab, opts \\ []), do: tap(tab_tag(strip, tab), opts)

  test "tapping a tab selects it and swaps the panel" do
    tap_tab("main", "specs")

    assert active_tab("main", @main) == "specs",
           "tapping Specs did not select it, active is #{active_tab("main", @main)}"

    # The panel is the tab's own children, so selecting must change what is under
    # the strip, not merely recolour the label.
    assert Enum.any?(texts_under("main-panel"), &(&1 =~ "Content-sized tabs"))

    tap_tab("main", "support")

    assert active_tab("main", @main) == "support", "tapping Support did not select it"
    assert Enum.any?(texts_under("main-panel"), &(&1 =~ "Each panel is the tab's own children"))
  end

  test "exactly one tab is active at a time" do
    tap_tab("main", "specs")

    active = Enum.count(@main, &shown?("main-tab-#{&1}-active"))
    assert active == 1, "expected one active tab, found #{active}"
  end

  test "the strip drags sideways to reach tabs past the edge" do
    # "settings" is the ninth tab, well past a phone's width. Before the strip
    # scrolled it was drawn off-screen and could never be tapped.
    strip = scroll_into_view("many-strip")
    first = "many-tab-inbox-active"
    first_before = frame!(first).left

    drag("many-strip", {-150, 0})

    # The strip moved: the first tab slid left, out of view. A scrolled-off tab keeps
    # its frame, so its position is still readable.
    assert_eventually(
      fn -> frame!(first).left < first_before - 40 end,
      message: fn ->
        "the strip did not scroll: first tab was at #{first_before}, now #{inspect(frame(first))}"
      end
    )

    # And the strip itself stayed put: it is the CONTENT that moved, not the whole page.
    assert abs(frame!("many-strip").left - strip.left) < 4,
           "the page scrolled instead of the strip"
  end

  test "a tab revealed by dragging is tappable and shows its panel" do
    scroll_into_view("many-strip")
    first = "many-tab-inbox-active"

    # Far enough to reach the end of a nine-tab strip. The gesture itself is covered by
    # the test above; here it is scroll_to, because a real drag ends in a fling and a
    # finger that lands on a flinging strip stops it instead of clicking, for ~0.4s,
    # and there is nothing to wait on but the clock. scroll_to moves the strip the same
    # distance without leaving one running.
    :ok = Mob.Test.scroll_to(device!(), "many-strip", :bottom)
    sync()

    # The last tab has to end up on the screen rather than past its edge.
    settings = settled_frame("many-tab-settings-idle")
    window = frame!("page")

    assert settings.left >= 0 and settings.right <= window.right,
           "the last tab is still off screen: #{inspect(settings)} in #{inspect(window)}"

    assert frame!(first).left < 0, "the strip never moved"

    # This is the whole point: a tab that was unreachable before now works.
    tap_tab("many", "settings")

    assert shown?("many-tab-settings-active"), "the last tab did not select"
    assert Enum.any?(texts_under("many-panel"), &(&1 =~ "you had to drag to get here"))
  end

  test "a disabled tab does not select" do
    before = active_tab("locked", @locked)

    assert_shown("locked-tab-locked-disabled")

    # Disabled wires no handler at all, so this is genuinely inert rather than
    # merely grey: a real touch reaches nothing.
    tap_tab("locked", "locked", expect: :none)

    assert active_tab("locked", @locked) == before,
           "a disabled tab selected: #{before} -> #{active_tab("locked", @locked)}"

    refute_shown("locked-tab-locked-active")
  end

  test "each strip keeps its own selection" do
    # The examples used to share assigns, two of them with different tab ids, so
    # picking in one silently reset another.
    tap_tab("main", "support")
    tap_tab("plain", "three")

    assert shown?("main-tab-support-active"), "the first strip lost its selection"
    assert shown?("plain-tab-three-active"), "the second strip did not keep its own"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A tab strip",
          "Too many to fit",
          "Without the indicator",
          "Disabled tab",
          "Colour and spacing",
          "Props"
        ] do
      assert_text(heading)
    end

    for strip <- ~w(main many plain locked styled), do: assert_shown("#{strip}-strip")
  end
end
