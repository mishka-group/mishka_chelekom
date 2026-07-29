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
 * [the_second_action_works_too] earns its place. The second button really was
 * unreachable: a Row hands the first child every pixel it asks for and a Button
 * asks for all of them, so "Import" was measured to zero width and parked at the
 * right edge (l=912, r=912). It sat in the node tree the whole time, and the
 * harness would happily "click" it — only a finger could tell the difference,
 * which is exactly the class of bug a device test exists to catch. The component
 * now tells its actions to hug, and this test measures the button rather than
 * trusting the tree.
 *
 * Ordering trap, which cost several runs to see: a node outside the scroll
 * viewport reports (0, 0, 0, 0) whatever its layout, so measuring before
 * scrolling says nothing at all. Scroll first, then measure.
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
    fun the_second_action_works_too() {
        if (showing("Delete them all")) {
            tap("Delete them all")
            compose.waitUntil(10_000) { !showing("Delete them all") }
        }

        // Scroll to the button itself, then measure. A node outside the scroll
        // viewport reports (0, 0, 0, 0) regardless of how it is laid out, so
        // measuring before scrolling says nothing at all.
        compose.onAllNodesWithText("Import", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The regression this guards: the second action used to be measured to
        // ZERO width and parked at the right edge (l=912, r=912) because the
        // first button had taken the whole Row. It was in the tree, and the
        // harness would happily "click" it, but no finger could ever reach it.
        val rect = boundsOf("Import")
        val first = boundsOf("New")
        require(rect.width > 0f) { "\"Import\" has no width: $rect" }
        require(rect.left >= first.right) { "the actions overlap: $rect vs $first" }

        // And they stay centred. Mob maps Column to a bare Compose Column, which
        // has no horizontalAlignment — the centred layout centres by letting this
        // Row HUG inside an aligned Box, so anything that makes the row fill
        // moves the actions to the left edge with nothing failing anywhere.
        val title = boundsOf("No projects yet")
        val actionsCentre = (first.left + rect.right) / 2f
        require(abs(actionsCentre - title.center.x) < 40f) {
            "the actions are not centred under the text: $actionsCentre vs ${title.center.x}"
        }

        tap("Import")
        compose.waitUntil(10_000) { showing("Imported A") }
        require(showing("Imported B")) { "Import added only one project" }
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
