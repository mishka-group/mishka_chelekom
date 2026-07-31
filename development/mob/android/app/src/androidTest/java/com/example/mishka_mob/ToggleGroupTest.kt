package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Toggle Group page.
 *
 * [pressing_the_pressed_one_CLEARS_the_group] is the behaviour that makes this a
 * toggle group rather than a radio group or a segmented control: single mode has
 * an empty state, and you reach it by pressing the button that is already down.
 * It is one line in `press/3`, so it is exactly the kind of thing that gets
 * "simplified" into a radio by accident.
 *
 * [the_items_sit_side_by_side] guards the layout bug that made a group unusable:
 * each item is a Box, and a Box with neither a width nor `fill_width` fills its
 * parent — so the first item took the whole row and the rest were pushed off the
 * screen, present in the tree and invisible on the device.
 *
 * Pressed differs from idle by fill colour alone, which is not in the
 * accessibility tree, so state rides in the testTag: `tgg-align-left-pressed`.
 *
 * Run with `mix e2e ToggleGroupTest`.
 */
@RunWith(AndroidJUnit4::class)
class ToggleGroupTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "row of toggle buttons"

    private val aligns = listOf("left" to "Left", "center" to "Center", "right" to "Right")

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** useUnmergedTree — a tappable Box merges its label's semantics over its own tag. */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun stateOf(prefix: String): String? =
        listOf("pressed", "idle").firstOrNull { tagged("$prefix-$it") }

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    /** Bounds of an item whichever state it is in — the selection moves. */
    private fun itemBounds(prefix: String): Rect =
        boundsOf("$prefix-" + (stateOf(prefix) ?: error("\"$prefix\" is untagged")))

    /** The pressed align, or null — single mode really can hold nothing. */
    private fun pressedAlign(): String? =
        aligns.map { it.first }.singleOrNull { stateOf("tgg-align-$it") == "pressed" }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    private fun tap(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(300)
    }

    @Before
    fun openToggleGroupScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Toggle Group", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_items_sit_side_by_side() {
        compose.onAllNodesWithText("Left", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val left = itemBounds("tgg-align-left")
        val center = itemBounds("tgg-align-center")
        val right = itemBounds("tgg-align-right")

        // A filling item would take the whole row and push these off the screen,
        // where Compose reports zero bounds — itemBounds would already have failed.
        require(center.left >= left.right - 2f) { "Left and Center overlap: $left vs $center" }
        require(right.left >= center.right - 2f) { "Center and Right overlap: $center vs $right" }

        // Three buttons on one line, so none may be anywhere near full width.
        require(left.width in 1f..400f) { "the item is not button-sized: $left" }

        // space: 0 joins them into one bar: no gap between adjacent segments.
        require(center.left - left.right < 3f) { "space: 0 left a gap: $left vs $center" }
    }

    @Test
    fun pressing_the_pressed_one_CLEARS_the_group() {
        compose.onAllNodesWithText("Left", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Get to a known non-empty state without assuming one: the BEAM outlives
        // the Activity, so a previous test's press survives into this one.
        if (pressedAlign() == null) {
            tap("Left")
            compose.waitUntil(10_000) { pressedAlign() != null }
        }

        val pressed = pressedAlign()!!
        val label = aligns.first { it.first == pressed }.second

        // THE differentiator: a radio group cannot be cleared, a segmented control
        // always keeps a selection, and this does neither.
        tap(label)
        compose.waitUntil(10_000) { pressedAlign() == null }

        require(showing("Value: nil")) { "the summary did not follow the clear" }
    }

    @Test
    fun single_mode_moves_the_selection_rather_than_adding_to_it() {
        compose.onAllNodesWithText("Left", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        tap("Left")
        compose.waitUntil(10_000) { pressedAlign() == "left" }

        tap("Center")
        compose.waitUntil(10_000) { pressedAlign() == "center" }

        // pressedAlign uses singleOrNull, so it returns null if TWO are pressed —
        // which is what a group that forgot it was single-select would produce.
        require(pressedAlign() == "center") { "single mode holds more than one press" }
    }

    @Test
    fun multiple_mode_holds_several_at_once() {
        compose.onAllNodesWithText("Italic", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val boldBefore = stateOf("tgg-style-bold")

        tap("Italic")
        compose.waitForIdle()
        Thread.sleep(300)

        // The point of multiple mode: pressing one must NOT release the others.
        require(stateOf("tgg-style-bold") == boldBefore) {
            "pressing Italic released Bold — the group is behaving as single-select"
        }

        // And pressing again removes, rather than doing nothing.
        val italicMid = stateOf("tgg-style-italic")
        tap("Italic")
        compose.waitUntil(10_000) { stateOf("tgg-style-italic") != italicMid }
    }

    @Test
    fun vertical_stacks_them_and_they_share_one_width() {
        compose.onAllNodesWithText("Cards", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val list = itemBounds("tgg-view-list")
        val grid = itemBounds("tgg-view-grid")
        val cards = itemBounds("tgg-view-cards")

        // Stacked, not side by side.
        require(grid.top >= list.bottom - 2f) { "List and Grid are not stacked: $list vs $grid" }
        require(cards.top >= grid.bottom - 2f) { "Grid and Cards are not stacked: $grid vs $cards" }

        // And filling, so "List" and "Cards" are the same width rather than a
        // ragged staircase sized to each label.
        require(kotlin.math.abs(list.width - cards.width) < 2f) {
            "stacked items are not a uniform width: $list vs $cards"
        }
    }

    @Test
    fun a_disabled_item_is_inert_while_its_neighbour_works() {
        compose.onAllNodesWithText("Right (off)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val before = stateOf("tgg-one-right")

        tap("Right (off)")
        Thread.sleep(400)

        require(stateOf("tgg-one-right") == before) { "a disabled item reported a press" }
    }

    @Test
    fun a_disabled_group_cascades_and_still_shows_what_is_pressed() {
        compose.onAllNodesWithText("B (off)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // This group is disabled outright and wires no handler at all.
        require(stateOf("tgg-off-on") == "pressed") { "a disabled group lost its pressed state" }
        require(stateOf("tgg-off-off") == "idle") { "a disabled group gained a press" }

        tap("B (off)")
        Thread.sleep(400)

        require(stateOf("tgg-off-on") == "pressed") { "a disabled group responded to a tap" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Single",
            "Multiple",
            "Vertical",
            "Styled by props",
            "Disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
