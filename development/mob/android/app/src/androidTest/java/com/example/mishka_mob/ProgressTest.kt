package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.ExperimentalTestApi
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
 * End-to-end tests for the Progress page.
 *
 * ## The reason this class looks different from the others
 *
 * This page renders an INDETERMINATE bar, which loops forever — and an infinite
 * animation means Compose never reports idle. `performScrollTo` and
 * `waitForIdle` both block on idleness, so on this page they run until Espresso
 * gives up. That is not hypothetical: it is what broke the whole suite once
 * before, because the BEAM outlives the Activity and every later class resumed
 * on whatever screen was left behind.
 *
 * So this class freezes the animation clock (`mainClock.autoAdvance = false`)
 * before it touches anything, and puts it back afterwards. With the clock
 * manual the looping bar stops driving frames, Compose can settle, and the
 * ordinary helpers work.
 *
 * The bar itself carries no text, so what is asserted is the READOUT beside it —
 * which the page renders from the same assign the buttons move, making each of
 * these a round trip.
 *
 * Run with `mix e2e ProgressTest`.
 */
@OptIn(ExperimentalTestApi::class)
@RunWith(AndroidJUnit4::class)
class ProgressTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A value inside"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

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

    /** The "42%" readout the page renders beside the labelled bar. */
    private fun readout(): String? =
        compose.onAllNodesWithText("%", substring = true)
            .fetchSemanticsNodes()
            .mapNotNull { node ->
                node.config.firstOrNull { it.key.name == "Text" }
                    ?.value
                    ?.let { (it as? List<*>)?.firstOrNull()?.toString() }
            }
            .firstOrNull { Regex("""\d+%""").matches(it) }

    private fun percent(): Int =
        readout()?.dropLast(1)?.toInt() ?: error("no percentage readout on screen")

    @Before
    fun openProgressScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Progress", substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_buttons_move_the_bar_and_the_readout_follows() {
        val start = percent()

        tap("+ 15")
        compose.waitUntil(10_000) { percent() != start }
        val up = percent()
        require(up > start) { "+15 went from $start% to $up%" }

        tap("− 15")
        compose.waitUntil(10_000) { percent() != up }
        require(percent() < up) { "−15 did not come back down from $up%" }
    }

    @Test
    fun the_value_clamps_rather_than_overshooting_its_track() {
        // Two clamps have to agree. fraction/1 pins what is DRAWN to 0..1, and
        // the screen pins the value it stores — without the second, the assign
        // kept climbing behind a full bar and coming back down took as many
        // extra taps as you had wasted going up.
        repeat(10) { tap("+ 15") }
        require(percent() == 100) { "after ten +15s the readout is ${percent()}%, not 100%" }

        // One tap down must move it immediately, which is only true if the
        // stored value stopped at 100 too.
        tap("− 15")
        require(percent() == 85) { "one tap down from full gave ${percent()}%, not 85%" }

        repeat(6) { tap("− 15") }
        require(percent() == 0) { "seven taps down from full gave ${percent()}%, not 0%" }
    }

    @Test
    fun a_custom_readout_replaces_the_percentage() {
        // value_text overrides the rounded percentage entirely — "3 of 5" is
        // not something the component could derive.
        compose.onAllNodesWithText("Step", substring = false)[0].performScrollTo()

        require(showing("3 of 5")) { "value_text did not replace the computed readout" }
    }

    @Test
    fun the_indeterminate_bar_shows_no_readout() {
        // There is no percentage to report, so show_value is ignored rather
        // than rendering a misleading 0%.
        compose.onAllNodesWithText("Connecting…", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        val label = compose.onAllNodesWithText("Connecting…", substring = true)
            .fetchSemanticsNodes()
            .first { it.boundsInRoot.width > 0f }
            .boundsInRoot

        // Nothing shaped like a percentage sits on that row.
        val readouts: List<Rect> = compose.onAllNodesWithText("%", substring = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && kotlin.math.abs(it.center.y - label.center.y) < label.height }

        require(readouts.isEmpty()) { "the indeterminate bar rendered a readout" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Determinate",
            "Indeterminate",
            "Custom range and readout",
            "Colour",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
