package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
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
 * End-to-end tests for the Semi Circle Progress page.
 *
 * The arc itself is drawn on a canvas, which has no semantics — uiautomator and
 * Compose's tree both see an opaque node. So these tests assert the two things a
 * device CAN settle, and the arc geometry is unit-tested off the draw ops
 * instead (mishka_semi_circle_progress_test.exs).
 *
 * [the_value_is_clamped_at_the_call_site] is the one that earns its place. The
 * demo used to do `sc_value + delta` with no bound, so "+ 15" walked the assign
 * to 147 while the arc sat at full — and then FIVE taps of "− 15" did nothing
 * visible before the needle moved. The progress and meter demos both shipped
 * with this exact bug and both got a device test for it; this is the third.
 * Saturate, then decrement once: the readout must leave 100%.
 *
 * String trap on this page, as everywhere in this gallery: every example prints
 * its own source, so "3 / 5", "1234567" and "Battery" are all on screen whether
 * or not anything rendered. A code sample is ONE Text node holding the whole
 * snippet, so an exact-match query never hits it — every assertion below uses
 * substring = false for that reason.
 *
 * Run with `mix e2e SemiCircleProgressTest`.
 */
@RunWith(AndroidJUnit4::class)
class SemiCircleProgressTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "ratios of size"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Nodes reading EXACTLY [label] that were really laid out. */
    private fun placed(label: String): Int =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .count { it.boundsInRoot.width > 0f && it.boundsInRoot.height > 0f }

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
        Thread.sleep(250)
    }

    @Before
    fun openGaugeScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Semi Circle Progress", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    /**
     * Drive the gauge to a known 0%. The BEAM outlives the Activity, so the page
     * keeps whatever value an earlier test left — asserting against the mount
     * default only passes when this class happens to run first.
     */
    private fun zeroTheGauge() {
        repeat(10) { tap("− 15") }
        compose.waitUntil(10_000) { placed("0%") > 0 }
    }

    @Test
    fun the_gauge_reports_a_percentage_and_responds_to_both_buttons() {
        zeroTheGauge()

        // The readout is a real Text stacked over the canvas — if it were painted
        // into the canvas instead, nothing here could see it at all.
        tap("+ 15")
        compose.waitUntil(10_000) { placed("15%") > 0 }

        tap("+ 15")
        compose.waitUntil(10_000) { placed("30%") > 0 }

        tap("− 15")
        compose.waitUntil(10_000) { placed("15%") > 0 }
    }

    @Test
    fun the_value_is_clamped_at_the_call_site() {
        zeroTheGauge()

        // Saturate well past the top. With the bug the assign runs to 150, and
        // nothing on screen says so.
        repeat(10) { tap("+ 15") }
        compose.waitUntil(10_000) { placed("100%") > 0 }

        // One decrement must move the needle. Unclamped, 150 - 15 = 135, which
        // still reads 100% because only the arc's fraction was ever clamped.
        tap("− 15")
        compose.waitUntil(10_000) { placed("100%") == 0 }
        require(placed("85%") > 0) { "expected 85% after one step down from a clamped 100%" }

        // And the bottom holds: one extra step below zero must stay at zero.
        zeroTheGauge()
        tap("− 15")
        require(placed("0%") > 0) { "the gauge went below zero" }
    }

    @Test
    fun value_text_replaces_the_percentage() {
        // Rendered as exactly "3 / 5"; the printed sample is one long node, so an
        // exact match cannot collide with it.
        compose.onAllNodesWithText("STEPS", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        require(placed("3 / 5") > 0) { "value_text did not replace the readout" }
        require(placed("60%") == 0) { "the percentage rendered alongside value_text" }
    }

    @Test
    fun the_rolling_number_counts_and_resets() {
        compose.onAllNodesWithText("Roll to 1,284", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        tap("Roll to 1,284")
        // The screen walks steps/3 on a timer, so wait for the landing value.
        compose.waitUntil(15_000) { placed("1,284") > 0 }

        tap("Reset")
        compose.waitUntil(10_000) { placed("0") > 0 }
    }

    @Test
    fun grouping_renders_every_separator_the_description_promises() {
        for (rendered in listOf("1,234,567", "1 234 567", "1234567", "-98,765")) {
            compose.onAllNodesWithText(rendered, substring = false)[0].performScrollTo()
            compose.waitForIdle()
            require(placed(rendered) > 0) { "the grouping example never rendered $rendered" }
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A gauge",
            "Custom readout",
            "Rolling number",
            "Grouping",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
