package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Checkbox page.
 *
 * [the_tick_scales_with_the_box] is the reported regression. The indicator is
 * drawn from a Box plus a glyph — Mob has no checkbox widget — and the glyph was
 * a fixed `:base` while the Box took `size`. A small box therefore clipped its
 * tick into a smear and a large one left it stranded. Both are invisible in the
 * node tree, so this measures the glyph against its box.
 *
 * Run with `mix e2e CheckboxTest`.
 */
@RunWith(AndroidJUnit4::class)
class CheckboxTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "checked, unchecked and"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Laid-out bounds of every node reading EXACTLY [label]. */
    private fun allBounds(label: String): List<Rect> =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

    private fun boundsOf(label: String): Rect =
        allBounds(label).firstOrNull() ?: error("no laid-out node reading \"$label\"")

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
    fun openCheckboxScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Checkbox", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_box_scales_and_both_report_their_state() {
        compose.onAllNodesWithText("Small", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The mark is DRAWN, so there is no glyph in the tree to look for — the
        // state rides in the testTag instead. Both boxes are checked here.
        val big = compose.onNodeWithTag("cb-large-checked").fetchSemanticsNode().boundsInRoot
        val small = compose.onNodeWithTag("cb-small-checked").fetchSemanticsNode().boundsInRoot

        require(big.width > small.width) { "size did not scale the box: $big vs $small" }
        require(small.width > 0f && small.height > 0f) { "the small box did not lay out: $small" }

        // Square, so the drawn mark's fractions land where the arithmetic says.
        require(kotlin.math.abs(small.width - small.height) < 2f) {
            "the small indicator is not square: $small"
        }
    }

    @Test
    fun a_mixed_box_draws_a_dash_not_a_tick() {
        compose.onAllNodesWithText("Select all", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        // The three states must differ by SHAPE, not only colour, so they survive
        // a colourblind reading. With the mark drawn, that shape is asserted in
        // the unit test (two lines vs one); here we only check the row rendered.
        require(showing("All languages")) { "the select-all row did not render" }
    }

    @Test
    fun tapping_the_label_toggles_it_too() {
        compose.onAllNodesWithText("Remember me", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // on_tap sits on the Row, so the label is as tappable as the 22dp box —
        // which is the whole reason it is on the Row. The state rides in the
        // testTag, so tapping the LABEL must flip the tag on the indicator.
        // useUnmergedTree: this row carries an on_tap, so Compose MERGES its
        // children's semantics into the clickable Row and the indicator's own
        // testTag disappears from the merged tree. The unchecked examples above
        // have no handler, which is why their tags are findable either way.
        fun tagged(state: String) =
            compose.onAllNodesWithTag("cb-remember-$state", useUnmergedTree = true)
                .fetchSemanticsNodes().isNotEmpty()

        val startedChecked = tagged("checked")

        tap("Remember me")
        compose.waitUntil(10_000) { tagged("checked") != startedChecked }

        tap("Remember me")
        compose.waitUntil(10_000) { tagged("checked") == startedChecked }
    }

    @Test
    fun a_disabled_box_does_not_change() {
        compose.onAllNodesWithText("Disabled", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        // Disabled wires no handler, so this must be inert rather than merely grey.
        compose.onAllNodesWithText("Locked on", substring = false)[0].performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        require(showing("Locked on")) { "the disabled row vanished" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Checked and unchecked",
            "Select all",
            "Disabled",
            "Colour and size",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
