defmodule MishkaMob.Device.DialogTest do
  @moduledoc """
  Device tests for the Dialog page: a port of `DialogTest.kt`, one test per `@Test`,
  on the host-driven suite instead of Compose instrumentation.

  Every assertion reads a tag, never page text. The page is one scrolling column of
  seven examples and each example ships a `code:` sample, so "on_open_change" and
  "dismissible" are text nodes several times over.

  The tags come from the component's `id`: `<id>-open` exists only while the dialog
  is up (presence IS the open state), the backdrop names whether it dims
  (`-backdrop-modal` / `-backdrop-plain`, since `modal` is otherwise a difference of
  colour alone), and a disabled trigger says so in its own tag.

  Each example owns a SEPARATE assign and a separate id, which is what lets "each
  example owns its own dialog" mean anything.

  Run with `mix test --only device test/device/dialog_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :dialog

  @dialogs ~w(dlg-basic dlg-slots dlg-dismiss dlg-forced dlg-plain dlg-tinted dlg-disabled)

  test "a closed dialog renders nothing at all" do
    # The page is up: every example's trigger is laid out.
    assert_shown("dlg-basic-trigger")

    for id <- @dialogs do
      refute shown?("#{id}-open"), "#{id} was open on a fresh page"
      refute shown?("#{id}-panel"), "#{id} drew a panel while closed"
      refute shown?("#{id}-title"), "#{id} drew a title while closed"
    end
  end

  test "opening a dialog renders the whole anatomy" do
    open_dialog("dlg-basic")

    # Every part the web names with a data-part, named here with a tag.
    for part <- ~w(panel backdrop-modal title description content footer) do
      assert shown?("dlg-basic-#{part}"), "the dialog opened without its #{part}"
    end
  end

  test "tapping the backdrop dismisses and reports the new state" do
    open_dialog("dlg-dismiss")

    tap_backdrop("dlg-dismiss-backdrop-modal")

    refute_shown("dlg-dismiss-open")
    # on_open_change carries the new state, exactly like the web's {open}. The
    # readout folds it into its own tag: the words "on_open_change" also appear in
    # the code sample above it, so text proves nothing.
    assert_shown("dlg-dismiss-readout-false")
  end

  test "an inert backdrop leaves the choice to the footer" do
    open_dialog("dlg-forced")

    # dismissible: false wires no handler at all, so the backdrop has no hit shape and
    # a touch sails through to whatever the page has parked underneath. Aim at the
    # left gutter, where the page holds nothing that takes a tap, and require that
    # the touch reaches no handler anywhere: not the backdrop's, not the page's.
    backdrop = frame!("dlg-forced-backdrop-modal")
    tap_xy(10.0, backdrop.top + backdrop.height * 0.12, expect: :none)

    assert shown?("dlg-forced-open"), "the forced dialog closed on its own"

    # The footer is the only way out, which is the whole point.
    tap("dlg-forced-close")
    refute_shown("dlg-forced-open")
  end

  test "a tap on the panel does not fall through to the backdrop" do
    open_dialog("dlg-basic")

    # Inside the panel's own padding, above everything the caller put there, and
    # mid-width, because `corner_radius` clips the corners out of the hit shape too,
    # so a touch near one would fall straight through.
    panel = frame!("dlg-basic-panel")
    tap_xy(panel.left + panel.width / 2, panel.top + 4.0)

    assert shown?("dlg-basic-open"), "the dialog dismissed itself through its own panel"
  end

  test "a non-modal dialog names its undimmed backdrop" do
    open_dialog("dlg-plain")

    # modal={false} differs from the default by nothing but the scrim's alpha, and a
    # device test cannot read a colour, so it reads the tag.
    assert_shown("dlg-plain-backdrop-plain")
    refute shown?("dlg-plain-backdrop-modal"), "modal={false} still dimmed the page"
  end

  test "the slot form builds the same parts as the string props" do
    open_dialog("dlg-slots")

    for part <- ~w(title description content footer) do
      assert shown?("dlg-slots-#{part}"), "the slot form skipped its #{part}"
    end
  end

  test "a disabled trigger opens nothing" do
    assert_shown("dlg-disabled-trigger-disabled")
    refute shown?("dlg-disabled-trigger"), "a disabled trigger kept the enabled tag"

    # disabled wires no handler at all, so a real touch reaches nothing.
    tap("dlg-disabled-trigger-disabled", expect: :none)

    refute shown?("dlg-disabled-open"), "a disabled trigger opened the dialog"
  end

  test "each example owns its own dialog" do
    open_dialog("dlg-basic")

    refute shown?("dlg-tinted-open"), "one trigger opened two dialogs"
    refute shown?("dlg-forced-open"), "one trigger opened two dialogs"

    tap("dlg-basic-close")
    refute_shown("dlg-basic-open")

    open_dialog("dlg-tinted")
    refute shown?("dlg-basic-open"), "the previous example's dialog came back"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "The whole anatomy",
          "Slots, not strings",
          "Tap outside to dismiss",
          "Forced choice",
          "Not modal",
          "Custom chrome",
          "A disabled trigger",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for id <- @dialogs -- ["dlg-disabled"], do: assert_shown("#{id}-trigger")
    assert_shown("dlg-disabled-trigger-disabled")
  end

  defp open_dialog(id) do
    tap("#{id}-trigger")
    assert_shown("#{id}-open")
  end

  # The backdrop spans the window and the panel is drawn on top of it, dead centre, so
  # a tap on the backdrop's own centre would land on the PANEL, which absorbs taps by
  # design. Aim in the upper eighth instead, which is backdrop and nothing else. A
  # fraction of the height, not a fixed offset: a few dp down is still the theme bar.
  defp tap_backdrop(tag) do
    backdrop = frame!(tag)
    tap_xy(backdrop.left + backdrop.width / 2, backdrop.top + backdrop.height * 0.12)
  end
end
