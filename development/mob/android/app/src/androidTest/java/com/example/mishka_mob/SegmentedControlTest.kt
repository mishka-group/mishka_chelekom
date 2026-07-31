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
 * End-to-end tests for the Segmented Control page.
 *
 * [the_selection_can_never_be_emptied] is what makes this component distinct
 * from its two neighbours: a toggle group CLEARS when you re-press the pressed
 * one, a radio group KEEPS its selection, and a segmented control keeps it too
 * but can never start empty either. `select/2` is one line, so it is exactly the
 * kind of rule a screen quietly reimplements wrongly.
 *
 * [the_segments_sit_side_by_side] guards the layout bug that hit every Box-based
 * control in this library: a Box with neither a width nor `fill_width` fills its
 * parent, so the first segment took the whole strip and the rest were pushed off
 * the screen — correct in the node tree, invisible on the device.
 *
 * Selection is a fill colour, which is not in the accessibility tree, so state
 * rides in the testTag: `sc-view-week-selected` / `sc-view-week-idle`.
 *
 * Run with `mix e2e SegmentedControlTest`.
 */
@RunWith(AndroidJUnit4::class)
class SegmentedControlTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "joined strip where exactly one"

    private val views = listOf("day" to "Day", "week" to "Week", "month" to "Month")

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** useUnmergedTree — a tappable segment Box merges its label's semantics over its tag. */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun stateOf(prefix: String): String? =
        listOf("selected", "idle").firstOrNull { tagged("$prefix-$it") }

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    /** Bounds of a segment whichever state it is in — the selection moves. */
    private fun segmentBounds(prefix: String): Rect =
        boundsOf("$prefix-" + (stateOf(prefix) ?: error("\"$prefix\" is untagged")))

    /** The selected view. singleOrNull, so two selections read as null and fail loudly. */
    private fun selectedView(): String? =
        views.map { it.first }.singleOrNull { stateOf("sc-view-$it") == "selected" }

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
    fun openSegmentedControlScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Segmented Control", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_segments_sit_side_by_side() {
        compose.onAllNodesWithText("Day", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val day = segmentBounds("sc-view-day")
        val week = segmentBounds("sc-view-week")
        val month = segmentBounds("sc-view-month")

        // A filling segment would take the whole strip and push these off-screen,
        // where Compose reports zero bounds — segmentBounds would already fail.
        require(week.left >= day.right - 2f) { "Day and Week overlap: $day vs $week" }
        require(month.left >= week.right - 2f) { "Week and Month overlap: $week vs $month" }

        // Three segments in one strip, so none may be anywhere near full width.
        require(day.width in 1f..400f) { "the segment is not segment-sized: $day" }

        // Content-sized, as the moduledoc claims: "Month" is wider than "Day".
        require(month.width > day.width) { "segments are not content-sized: $day vs $month" }
    }

    @Test
    fun the_selection_can_never_be_emptied() {
        compose.onAllNodesWithText("Day", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Read the current selection rather than assume it: the BEAM outlives
        // the Activity, so a previous test's tap survives into this one.
        val before = selectedView() ?: error("the control started with nothing selected")
        val label = views.first { it.first == before }.second

        // Re-tapping the selected segment is a NO-OP. A toggle group would clear
        // here — that is the entire difference between the two components.
        tap(label)
        Thread.sleep(400)

        require(selectedView() == before) { "re-tapping cleared the selection" }
    }

    @Test
    fun tapping_another_segment_moves_the_selection() {
        compose.onAllNodesWithText("Week", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val (id, label) = views.first { it.first != selectedView() }

        tap(label)
        compose.waitUntil(10_000) { selectedView() == id }

        // selectedView uses singleOrNull, so two filled segments read as null —
        // which is what a control that forgot to clear the old one would produce.
        require(selectedView() == id) { "more than one segment is selected" }
        compose.waitUntil(10_000) { showing("Value: $id") }
    }

    @Test
    fun the_track_hugs_unless_fill_width_is_asked_for() {
        // Scroll to the caption BELOW both strips, not to a label in the first.
        // performScrollTo moves the minimum distance, so aiming at the top strip
        // leaves the second below the fold — where Compose reports zero bounds
        // and every measurement reads as "the node is missing".
        compose.onAllNodesWithText("Segments stay content-sized", substring = true)[0]
            .performScrollTo()
        compose.waitForIdle()

        // Same three labels, two strips: one hugging, one spanning. Compare the
        // strips by their outermost segments rather than their tracks, which
        // carry no tag of their own.
        val hugLeft = segmentBounds("sc-hug-s")
        val hugRight = segmentBounds("sc-hug-l")
        val fillLeft = segmentBounds("sc-fill-s")

        val hugWidth = hugRight.right - hugLeft.left
        require(hugWidth in 1f..500f) { "the hugging strip is not compact: $hugWidth" }

        // The spanning one starts at the same left edge but its track runs on —
        // the segments stay content-sized, which is the documented compromise.
        require(kotlin.math.abs(fillLeft.left - hugLeft.left) < 40f) {
            "the two strips do not share a left edge: $hugLeft vs $fillLeft"
        }
    }

    @Test
    fun a_disabled_segment_cannot_be_selected() {
        compose.onAllNodesWithText("Archive (off)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val before = stateOf("sc-one-archive")

        tap("Archive (off)")
        Thread.sleep(400)

        require(stateOf("sc-one-archive") == before) { "a disabled segment took the selection" }
        require(stateOf("sc-one-archive") == "idle") { "the disabled segment started selected" }
    }

    @Test
    fun a_disabled_control_cascades_and_still_shows_its_selection() {
        compose.onAllNodesWithText("Mid (off)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Greyed rather than accented, but still SHOWN — a locked control must
        // say which option it is locked into.
        require(stateOf("sc-off-mid") == "selected") { "a disabled control lost its selection" }
        require(stateOf("sc-off-low") == "idle") { "a disabled control gained a selection" }

        tap("Low (off)")
        Thread.sleep(400)

        require(stateOf("sc-off-mid") == "selected") { "a disabled control responded to a tap" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Always one selected",
            "With a label",
            "It hugs, or it spans",
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
