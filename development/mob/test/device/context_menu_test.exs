defmodule MishkaMob.Device.ContextMenuTest do
  @moduledoc """
  Device tests for the Context Menu page: a port of `ContextMenuTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The web opens this on right-click, and its own keyboard notes name the touch
  equivalent: a long press. That is what `holding a row opens its actions` asserts,
  and it is the thing the port shipped without: the moduledoc claimed "Mob's
  Android bridge exposes no long-press gesture", when in fact the handler was
  registered all along and only this bridge had not wired it.

  The second example is a menu pinned open whose rows include "Rename", so a
  page-wide text query is true from the moment the page mounts. Every assertion
  here reads a tag instead: `row-<file>` for the thing you hold and
  `act-<file>-<action>` for a row of that file's menu.

  Run with `mix test --only device test/device/context_menu_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :context_menu

  defp open?(file), do: shown?("act-#{file}-rename")

  test "holding a row opens its actions" do
    refute open?(:report), "this row's menu was already open"

    hold("row-report")

    assert_shown("act-report-rename")

    assert shown?("act-report-duplicate") and shown?("act-report-delete"),
           "the menu opened but did not render its rows"
  end

  test "a plain tap on the row does not open it" do
    # The long press must not swallow the ordinary tap: a row keeps doing whatever
    # it already did, which is why this is on_long_press rather than a repurposed
    # on_tap. The row does nothing on a tap, so the touch must reach no handler at
    # all, and the menu stays shut.
    tap("row-report", expect: :none)

    refute open?(:report), "a plain tap opened the context menu"
    assert assigns().cm_for == nil
  end

  test "the menu names the row it belongs to" do
    # "report.pdf" is the row's own label, once.
    before = text_count("report.pdf")

    hold("row-report")
    assert_shown("act-report-rename")

    # for_label is the whole reason this is not just a Menu: on a phone there is no
    # cursor to open at, so the subject has to be stated. A page-wide search for
    # the name was already true from the row itself, so count what the tree draws:
    # the menu's heading is a second node reading exactly that.
    assert text_count("report.pdf") == before + 1,
           "the menu did not state its subject (#{before} before, #{text_count("report.pdf")} after)"
  end

  test "holding a different row moves the menu" do
    hold("row-report")
    assert_shown("act-report-rename")

    # The menu renders in flow, not in a window of its own, so nothing covers the
    # other row and a real hold reaches it.
    hold("row-notes")

    # Still one menu, now belonging to the other row.
    assert_shown("act-notes-rename")
    refute_shown("act-report-rename")
  end

  test "picking an action reports it and closes" do
    hold("row-report")
    assert_shown("act-report-rename")

    tap("act-report-rename")

    assert_eventually(fn -> assert_text("rename on report") end,
      message: "the pick was never reported"
    )

    assert assigns().cm_last == {:report, :rename}
    refute_shown("act-report-duplicate")
    refute open?(:report), "the menu stayed open after an action"
  end

  test "the page renders every example" do
    for heading <- ["Hold a row", "Without a subject", "Props"], do: assert_text(heading)

    # Both rows are laid out, and the pinned example is there without being held.
    assert_shown("row-report")
    assert_shown("row-notes")

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
