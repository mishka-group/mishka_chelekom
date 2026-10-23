defmodule MishkaMob.Device.RadioTest do
  @moduledoc """
  Device tests for the Radio page: a port of `RadioTest.kt`, one test per `@Test`, on
  the host-driven suite instead of Compose instrumentation.

  `only one option stays selected` is the invariant the whole component exists for. The
  web gets it free (a shared `name` makes the browser enforce it), but there is no form
  and no browser here, so exclusivity is entirely the screen's handler. Nothing in the
  component can guarantee it, which is exactly why it is asserted on a device.

  The selection is a DOT, not text, so there is nothing in the tree to read. The ring's
  tag carries the state instead (`rd-pro-selected` / `rd-pro-empty`); see
  `MishkaMob.Components.MishkaRadio`.

  Run with `mix test --only device test/device/radio_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :radio

  @plans ~w(free pro team)

  test "only one option stays selected" do
    before = selected_plan()
    id = Enum.find(@plans, &(&1 != before))

    tap_ring("rd-#{id}")
    assert_shown("rd-#{id}-selected")

    # The half a checkbox would get wrong: selecting one must UNSELECT the other.
    # `selected_plan/0` fails outright if two rings are filled at once, which is the bug
    # this exists to catch.
    assert_eventually(fn -> selected_plan() == id end,
      message: "picking #{id} did not clear #{before}"
    )
  end

  test "re tapping the selection keeps it" do
    tap_ring("rd-team")
    assert_shown("rd-team-selected")

    # A radio set cannot be cleared by re-tapping, which is the whole behavioural
    # difference from a checkbox, and one line in the handler, so nothing but a device
    # test notices when it regresses. The tap does reach the handler (tap/2 checks), and
    # the handler leaves the selection alone.
    tap("rd-team-selected")

    assert selected_plan() == "team", "re-tapping cleared the selection"
  end

  test "the summary line proves the event reached a clause" do
    # The summary renders from the same assign the radios drive, so it is the honest
    # witness that the composed {:rd_plan, id} tag matched a clause: a ring can repaint
    # without any event arriving.
    assert text_of!("rd-summary") =~ "Selected:", "the example rendered no summary"

    id = Enum.find(@plans, &(&1 != selected_plan()))
    tap_ring("rd-#{id}")

    assert_eventually(fn -> text_of!("rd-summary") == "Selected: #{id}" end,
      message: fn -> "the summary did not follow the tap to #{id}: #{text_of!("rd-summary")}" end
    )
  end

  test "the ring scales and stays round" do
    big = frame!("rd-large-selected")
    small = frame!("rd-small-selected")

    assert big.width > small.width,
           "size did not scale the ring: #{inspect(big)} vs #{inspect(small)}"

    # A square ring is a circle once corner_radius is size/2; an oblong one renders as
    # a lozenge, which is what an inherited height would produce.
    for {name, ring} <- [large: big, small: small] do
      assert abs(ring.width - ring.height) < 1, "the #{name} ring is not round: #{inspect(ring)}"
    end
  end

  test "a disabled radio does not change" do
    # Read both rings BEFORE the touch: an end state that merely happens to look right
    # proves nothing, so the test pins the starting point and then demands neither ring
    # moved.
    off_before = ring_state("rd-locked-off")
    on_before = ring_state("rd-locked-on")

    assert {off_before, on_before} == {"empty", "selected"},
           "the disabled example did not start as declared: off=#{off_before}, on=#{on_before}"

    # Disabled wires no handler, so this must be inert rather than merely grey. A label
    # is a plain Text that never varies with `checked` (the selection is a dot), so the
    # ring's tag is the only witness of selection, and a touch that reached a handler
    # would show there.
    tap("rd-locked-off-empty", expect: :none)

    assert ring_state("rd-locked-off") == off_before,
           "tapping a disabled radio changed it: #{off_before} -> #{ring_state("rd-locked-off")}"

    refute shown?("rd-locked-off-selected"), "the disabled empty radio grew a dot"

    assert ring_state("rd-locked-on") == on_before,
           "the disabled selected radio lost its dot: #{ring_state("rd-locked-on")}"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Pick one",
          "Circle, not a tick",
          "Disabled",
          "Colour and size",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <- ~w(rd-pro-selected rd-locked-on-selected rd-large-selected), do: assert_shown(tag)

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # A ring's state as its own tag spells it: "selected" or "empty". Nil when the row is
  # not on screen at all, which is how a vanished example reads. A ring with both tags
  # at once is also nil.
  defp ring_state(prefix) do
    case Enum.filter(~w(selected empty), &shown?("#{prefix}-#{&1}")) do
      [state] -> state
      _none_or_both -> nil
    end
  end

  # Which plan is selected right now, failing outright if two rings are filled.
  defp selected_plan do
    case Enum.filter(@plans, &(ring_state("rd-#{&1}") == "selected")) do
      [plan] -> plan
      other -> flunk("expected exactly one selected plan, got #{inspect(other)}")
    end
  end

  # A touch on the row whose ring is tagged `<prefix>-<its current state>`. The tag
  # sits on the ring and the on_tap on its Row, so the touch lands at the ring's centre
  # and the Row's clickable receives it.
  defp tap_ring(prefix),
    do: tap("#{prefix}-#{ring_state(prefix) || flunk("no ring tagged #{prefix}")}")
end
