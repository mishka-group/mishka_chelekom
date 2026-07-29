package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
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
import kotlin.math.abs

/**
 * End-to-end tests for the Empty State page.
 *
 * The feature is a round trip: an empty state is what a list shows INSTEAD of
 * itself, so the only real proof is that filling the list makes it go away. Its
 * buttons used to be wired to a no-op and the page had no handler at all, which
 * is exactly the "renders perfectly and does nothing" shape these tests exist to
 * catch.
 *
 * The other thing only a device can settle is the two layouts. `:center` puts
 * the indicator ABOVE the text and `:leading` puts it BESIDE — that is a claim
 * about geometry, and the node tree is the same handful of Rows and Columns
 * either way.
 *
 * Careful with strings here: this page quotes its own markup, so
 * "No projects yet" is on screen whether or not the empty state renders, and
 * "Untitled" appears in the sample too. Assert on things only the render
 * produces — the reset button is the reliable one.
 *
 * NOT covered here: tapping the SECOND action. It could not be made to land
 * reliably — the button reports a (0, 0, 0, 0) rect and the click reaches
 * nothing, through several attempts at scrolling it into view first. The cause
 * is unknown, so rather than commit a flaky test the coverage sits in
 * ShowcaseTest, which drives {:tap, :es_import} directly and asserts the list
 * grows by two. What is lost is only the proof that the second button is
 * REACHABLE on a device — worth revisiting.
 *
 * Run with `mix e2e EmptyStateTest`.
 */
@RunWith(AndroidJUnit4::class)
class EmptyStateTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Fills a blank screen"

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

    /** Bounds of the topmost placed node reading exactly [label]. */
    private fun boundsOf(label: String): Rect {
        compose.waitForIdle()

        val placed = compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

        require(placed.isNotEmpty()) { "no laid-out node reading exactly \"$label\"" }
        return placed.minByOrNull { it.top }!!
    }

    @Before
    fun openEmptyStateScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Empty State", substring = false)
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun filling_the_list_makes_the_empty_state_go_away() {
        // "Delete them all" only ever renders — it is not quoted in the sample —
        // so it is the honest signal for "the list has content now".
        if (showing("Delete them all")) {
            tap("Delete them all")
            compose.waitUntil(10_000) { !showing("Delete them all") }
        }

        tap("New")
        compose.waitUntil(10_000) { showing("Untitled 1") }

        require(showing("Delete them all")) { "the list rendered no reset control" }

        tap("Delete them all")
        compose.waitUntil(10_000) { !showing("Untitled 1") }
    }

    @Test
    fun centred_stacks_the_indicator_above_the_text() {
        val glyph = boundsOf("📭")
        val title = boundsOf("No messages")

        require(title.top > glyph.bottom - 2f) { "the indicator is not above the title" }
    }

    @Test
    fun leading_puts_the_indicator_beside_the_text() {
        // Same component, same props but align — and a genuinely different
        // layout, which is why both are ported rather than one being a nicety.
        val glyph = boundsOf("🔍")
        val title = boundsOf("No results")

        require(title.left > glyph.right - 2f) { "the indicator is not beside the title" }
        require(abs(title.center.y - glyph.center.y) < title.height * 2f) {
            "the indicator and the title are not on the same line"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf("Centred", "Leading", "With actions", "Text only", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
