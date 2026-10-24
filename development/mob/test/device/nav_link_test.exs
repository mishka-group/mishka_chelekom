defmodule MishkaMob.Device.NavLinkTest do
  @moduledoc """
  Device tests for the Nav Link page: a port of `NavLinkTest.kt`, one test per
  `@Test`, on the host-driven suite instead of Compose instrumentation.

  Everything a nav link says about itself, it says in colour or in a glyph: the
  current row is `:primary` on a raised background, an expanded group is a ▾ rather
  than a ▸. A device test reads neither. So the component fans `id` out into tags
  that name the state (`<id>-active` / `-inactive` / `-disabled` on the label,
  `<id>-open` / `-closed` on the chevron) and every assertion here reads those
  rather than the page's text.

  Text would be worse than useless on this page: all eight examples render into one
  scrolling column and each carries a code block, so "Docs" is on screen from the
  moment it mounts whatever the rows are doing.

  Run with `mix test --only device test/device/nav_link_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :nav_link

  test "tapping a leaf moves the active mark to it" do
    assert_shown("nav-dash-active")

    tap("nav-docs")

    assert_shown("nav-docs-active")
    # Exactly one row is current: that is the whole point of `active`.
    assert_shown("nav-dash-inactive")
    assert_shown("nav-settings-inactive")
    refute_shown("nav-dash-active")
  end

  test "one handler serves every link because the href rides back" do
    tap("nav-settings")

    # Three rows, one `on_tap` tag: the row is identified only by the href the tap
    # carried, so a wrong href would mark the wrong row.
    assert_shown("nav-settings-active")

    assert_eventually(fn -> "Current: /settings" in texts() end,
      message: "the screen was told the wrong destination"
    )
  end

  test "a group opens and shuts from a prop the screen owns" do
    assert_shown("nav-mail-closed")
    refute_shown("nav-inbox")

    tap("nav-mail")

    assert_shown("nav-mail-open")
    assert_shown("nav-inbox")
    assert_shown("nav-drafts")

    tap("nav-mail")

    # And back: `opened` is a prop, so the same tap closes it again. The web's
    # <details> would have needed the server to re-render it shut.
    assert_shown("nav-mail-closed")
    refute_shown("nav-inbox")
  end

  test "the nested links sit in from their parent" do
    tap("nav-mail")
    assert_shown("nav-inbox")

    scroll_into_view("nav-inbox")

    parent = frame!("nav-mail")
    child = frame!("nav-inbox")

    # `indent` is 24 on this example. Geometry is the only thing that says a nested
    # link belongs to the group above it.
    assert child.left > parent.left + 8,
           "the nested links are not indented: parent=#{inspect(parent)} child=#{inspect(child)}"

    assert child.top > parent.top, "the nested links are not below their parent"
  end

  test "a nested link reports on its own and leaves the group open" do
    tap("nav-mail")
    assert_shown("nav-inbox")

    tap("nav-inbox")

    assert_shown("nav-inbox-active")
    assert_shown("nav-drafts-inactive")
    # Choosing a destination is not the same as collapsing the section.
    assert_shown("nav-mail-open")
  end

  test "default_opened is open at mount and stays where it is" do
    assert_shown("nav-team-open")
    assert_shown("nav-alice")
    assert_shown("nav-bob")

    # Uncontrolled means fixed here: with no `opened` and no `on_toggle` there is
    # nowhere for the answer to live, so the row wires no handler at all and a real
    # touch reaches nothing. The web's <details> would have shut on this tap.
    tap("nav-team", expect: :none)

    assert_shown("nav-team-open")
  end

  test "a disabled row reports nothing while its sibling still does" do
    before = shown?("nav-reports-active")

    tap("nav-archive", expect: :none)

    assert shown?("nav-reports-active") == before, "a disabled row fired its handler"
    assert_shown("nav-archive-disabled")

    tap("nav-reports")

    # The disabled row is inert, not the example: its neighbour still works.
    assert_eventually(fn -> shown?("nav-reports-active") != before end,
      message: "the enabled neighbour did not respond"
    )
  end

  test "every glyph is attributable to the row it belongs to" do
    # A ▤ or a ↗ is the same character wherever it appears, so the icon and trailing
    # slots carry tags of their own. The badge is a NODE in the trailing slot, and it
    # is tagged exactly as a glyph string would be.
    for tag <- ["nav-dash-icon", "nav-docs-trailing", "nav-reports-trailing"] do
      assert shown?(tag), "#{tag} is not addressable"
    end
  end

  test "the page renders every example" do
    for heading <- [
          "Leaves",
          "A group the screen owns",
          "default_opened",
          "Disabled, and a node",
          "Props"
        ] do
      assert_text(heading)
    end

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
