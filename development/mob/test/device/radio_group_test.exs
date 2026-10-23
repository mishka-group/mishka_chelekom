defmodule MishkaMob.Device.RadioGroupTest do
  @moduledoc """
  Device tests for the Radio Group page: a port of `RadioGroupTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  The group's reason to exist is that ONE handler serves every option: each reports the
  same tag widened with its own id, which is what replaces the browser's shared `name`.
  `one handler serves every option` is that claim.

  As with a lone radio, the selection is a dot rather than text, so the ring's tag
  carries it, prefixed here by the group id so a single option can be named:
  `rg-plan-pro-selected`. The touches name the ring by that tag, not by label: "Free" and
  "Pro" are each rendered by three groups on this page, all bound to the same `@rg_plan`,
  so a label does not say which group a touch reached.

  Run with `mix test --only device test/device/radio_group_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :radio_group

  # Option ids, not labels: the labels are shared with two other groups on the page, so a
  # label does not name an option here. The ring tag does.
  @plans ~w(free pro team)

  test "one handler serves every option" do
    current = selected_plan()
    id = Enum.find(@plans, &(&1 != current))

    # Each option widens the SAME on_change tag with its own id. If that widening broke,
    # the touch would still land and simply do nothing, so assert the state moved, not
    # that the touch happened.
    tap("rg-plan-#{id}-empty")
    assert_shown("rg-plan-#{id}-selected")

    assert_eventually(fn -> selected_plan() == id end,
      message: "the group holds more than one selection"
    )

    # The summary renders from the same assign, proving a clause matched rather than the
    # ring merely repainting.
    assert_eventually(fn -> text_of("rg-summary") == "Selected: #{id}" end,
      message: fn -> "the summary did not follow the tap to #{id}: #{text_of("rg-summary")}" end
    )
  end

  test "horizontal lays the options in a row" do
    s = any_ring("rg-size-s")
    m = any_ring("rg-size-m")
    l = any_ring("rg-size-l")

    # Side by side, not stacked: only layout can catch an orientation that silently fell
    # back to a Column.
    assert m.left >= s.right, "S and M are not on one line: #{inspect(s)} vs #{inspect(m)}"
    assert l.left >= m.right, "M and L are not on one line: #{inspect(m)} vs #{inspect(l)}"
    assert abs(s.top - l.top) < 1, "the row is not aligned: #{inspect(s)} vs #{inspect(l)}"
  end

  test "a disabled option is inert while its neighbour works" do
    # Tapping the unavailable option must not move the selection. The group cascades
    # `disabled` per option, and an option that merely LOOKS grey while still reporting is
    # the failure this catches. A real touch delivers nothing to a wired-off option.
    before = selected_plan()

    tap("rg-one-team-empty", expect: :none)
    assert selected_plan() == before, "a disabled option reported a selection"

    # And the option next to it, in the same group, still works: the disabled one is the
    # exception, not the group.
    tap("rg-one-free-empty")
    assert_shown("rg-one-free-selected")
    assert_eventually(fn -> selected_plan() == "free" end)
  end

  test "a disabled group cascades to every option" do
    # The OFF group shows the same @rg_plan as the first example, so while :pro is the
    # plan a cascade that failed would send {:rg_plan, :pro} and change nothing anyone
    # could see. Park the selection elsewhere first, through the group that really works,
    # so the touch has something to prove.
    if selected_plan() == "pro" do
      tap("rg-plan-team-empty")
      assert_shown("rg-plan-team-selected")
    end

    # The group carries a live on_change, so `disabled` cascading to every option is the
    # only thing that can stop a touch. Its rings are still tagged, which is how we can
    # tell it rendered rather than vanished.
    assert shown?("rg-off-free-empty") or shown?("rg-off-free-selected"),
           "the disabled group did not render"

    before = selected_plan()
    assert before != "pro", "the touch below cannot fail while :pro is selected"

    assert shown?("rg-off-pro-empty"),
           "the OFF group's Pro ring is not empty while the plan is #{before}"

    # This group's options are labelled "(off)" precisely so a touch here cannot land on
    # the tappable "Pro" of the first example. A ring tag names one group by construction.
    tap("rg-off-pro-empty", expect: :none)

    # Both fail if the cascade stops reaching an option: once in the shared assign, and
    # once in the OFF group's own ring, the half scoped to the group this test names.
    assert selected_plan() == before,
           "a disabled group reported a selection: #{before} -> #{selected_plan()}"

    assert shown?("rg-off-pro-empty"), "a disabled option filled its own ring"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "A labelled group",
          "Horizontal",
          "Disabled option and group",
          "Colour and size",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every example is laid out, not just described by the tree.
    for tag <-
          ~w(rg-plan-pro-selected rg-size-m-selected rg-one-team-empty rg-off-pro-selected rg-tier-growth-selected) do
      assert_shown(tag)
    end

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end

  # The one selected plan of the first group, failing outright if the group somehow holds
  # two or none.
  defp selected_plan do
    case Enum.filter(@plans, &shown?("rg-plan-#{&1}-selected")) do
      [plan] -> plan
      other -> flunk("expected exactly one selection, got #{inspect(other)}")
    end
  end

  # A ring's frame whichever state it is in: the selection may have moved.
  defp any_ring(prefix), do: frame("#{prefix}-selected") || frame!("#{prefix}-empty")

  # The text of the rendered node whose :id is `tag`.
  defp text_of(tag) do
    %{props: %{text: text}} =
      find_node(render_tree(), to_string(tag)) || flunk("no node tagged #{tag}")

    text
  end

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil
end
