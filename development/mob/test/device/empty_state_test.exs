defmodule MishkaMob.Device.EmptyStateTest do
  @moduledoc """
  Device tests for the Empty State page: a port of `EmptyStateTest.kt`, one test
  per `@Test`, on the host-driven suite instead of Compose instrumentation.

  The feature is a round trip: an empty state is what a list shows INSTEAD of
  itself, so the only real proof is that filling the list makes it go away. Its
  buttons used to be wired to a no-op and the page had no handler at all.

  The other thing only a device settles is the two layouts. `:center` puts the
  indicator ABOVE the text and `:leading` puts it BESIDE it, which is a claim
  about geometry. `MishkaEmptyState` fans its `id` out to `<id>-indicator`,
  `<id>-title` and `<id>-description`, and every assertion here reads those
  rather than the page's text: this page quotes its own markup, so "No projects
  yet" is on screen whether or not the empty state renders.

  Run with `mix test --only device test/device/empty_state_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :empty_state

  test "filling the list makes the empty state go away" do
    # The page mounts empty: the empty state is showing and the list has no
    # reset control, which only ever renders for a list with content.
    assert_shown("es-empty-title")
    refute_shown("es-reset")

    tap("es-new")

    assert_shown("es-row-Untitled-1")
    assert_shown("es-reset")
    refute_shown("es-empty-title")

    tap("es-reset")

    refute_shown("es-row-Untitled-1")
    assert_shown("es-empty-title")
  end

  test "the second action works too" do
    # The regression this guards: the second action used to be measured to ZERO
    # width and parked at the right edge because the first button had taken the
    # whole Row. It was in the tree, a handler on it worked, but no finger could
    # reach it. The component now tells its actions to hug.
    scroll_into_view("es-import")
    import_button = frame!("es-import")
    first = frame!("es-new")

    assert import_button.width > 0, "\"Import\" has no width: #{inspect(import_button)}"

    assert import_button.left >= first.right,
           "the actions overlap: #{inspect(import_button)} vs #{inspect(first)}"

    # And they stay centred. Mob maps Column to a bare Compose Column, which has
    # no horizontalAlignment: the centred layout centres by letting this Row HUG
    # inside an aligned Box, so anything that makes the row fill moves the actions
    # to the left edge with nothing failing anywhere.
    {title_centre, _y} = center(frame!("es-empty-title"))
    actions_centre = (first.left + import_button.right) / 2

    assert abs(actions_centre - title_centre) < 40,
           "the actions are not centred under the text: #{actions_centre} vs #{title_centre}"

    tap("es-import")

    assert_shown("es-row-Imported-A")
    assert_shown("es-row-Imported-B")
  end

  test "centred stacks the indicator above the text" do
    scroll_into_view("es-centred-title")
    glyph = frame!("es-centred-indicator")
    title = frame!("es-centred-title")

    assert title.top > glyph.bottom - 2, "the indicator is not above the title"
  end

  test "leading puts the indicator beside the text" do
    # Same component, same props but align, and a genuinely different layout,
    # which is why both are ported rather than one being a nicety.
    scroll_into_view("es-leading-title")
    glyph = frame!("es-leading-indicator")
    title = frame!("es-leading-title")

    assert title.left > glyph.right - 2, "the indicator is not beside the title"

    {_x, title_y} = center(title)
    {_x, glyph_y} = center(glyph)

    assert abs(title_y - glyph_y) < title.height * 2,
           "the indicator and the title are not on the same line"
  end

  test "the page renders every example and the props table" do
    for heading <- ["Centred", "Leading", "With actions", "Text only", "Props"] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
