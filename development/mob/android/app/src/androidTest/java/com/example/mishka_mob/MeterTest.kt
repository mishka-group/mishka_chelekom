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
 * End-to-end tests for the Meter page.
 *
 * A meter draws no text of its own — the gauge is a native bar — so everything
 * here is asserted through the READOUT the page renders beside it, from the same
 * assign the buttons move. That makes each one a round trip.
 *
 * [the_stored_value_clamps_too] is the one worth keeping. ratio/1 clamps what is
 * DRAWN, so a runaway assign still shows a full gauge; the bug it catches is
 * that the value behind the bar kept climbing, and coming back down then took as
 * many wasted taps as had been spent going up. The bar looked right the whole
 * time, which is exactly why no unit test noticed.
 *
 * Run with `mix e2e MeterTest`.
 */
@RunWith(AndroidJUnit4::class)
class MeterTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A measurement with its own readout"

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

    /**
     * The percentage the FIRST gauge reports.
     *
     * Topmost, because the page shows several readouts and only this one is
     * wired to the buttons. Matched whole against a pattern, since the page's
     * own descriptions mention percentages too.
     */
    private fun percent(): Int {
        val texts = compose.onAllNodesWithText("%", substring = true)
            .fetchSemanticsNodes()
            .filter { it.boundsInRoot.width > 0f }
            .sortedBy { it.boundsInRoot.top }
            .mapNotNull { node ->
                node.config.firstOrNull { it.key.name == "Text" }
                    ?.value
                    ?.let { (it as? List<*>)?.firstOrNull()?.toString() }
            }

        val first = texts.firstOrNull { Regex("""\d+%""").matches(it) }
            ?: error("no percentage readout on screen")

        return first.dropLast(1).toInt()
    }

    @Before
    fun openMeterScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Meter", substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_buttons_move_the_gauge_and_the_readout_follows() {
        val start = percent()

        tap("Fill up")
        compose.waitUntil(10_000) { percent() != start }
        val up = percent()
        require(up > start) { "Fill up went from $start% to $up%" }

        tap("Free up")
        compose.waitUntil(10_000) { percent() != up }
        require(percent() < up) { "Free up did not come back down from $up%" }
    }

    @Test
    fun the_stored_value_clamps_too() {
        // Push well past the top. The gauge pins at 100 either way — the point
        // is what happens NEXT.
        repeat(10) { tap("Fill up") }
        require(percent() == 100) { "after ten fills the readout is ${percent()}%, not 100%" }

        // One tap down must move it immediately. If the assign had run past 100
        // behind a full bar, this would still read 100.
        tap("Free up")
        require(percent() == 88) { "one tap down from full gave ${percent()}%, not 88%" }
    }

    @Test
    fun a_custom_readout_replaces_the_percentage() {
        compose.onAllNodesWithText("Any range", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        require(showing("3 of 5")) { "value_text did not replace the computed readout" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A gauge",
            "Any range",
            "Clamped, never overshooting",
            "Colour and thickness",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
