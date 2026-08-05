package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeLeft
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Scroller rail on the Preview Card page.
 *
 * The point of this file is the distinction the component exists for: a rail
 * that scrolls under a FINGER is the platform doing its job, and proves nothing
 * about this component. What has to work is pressing ‹ and › — the arrows are
 * the whole component, and they used to emit their tags into a handler that
 * only counted them, so the rail never moved. [pressing_next_moves_the_rail]
 * is that test.
 *
 * A scrolled rail does not move its own container; only its contents slide
 * under it. So every assertion here reads a TILE's position, not the rail's.
 *
 * Run with `mix e2e ScrollerTest`.
 */
@RunWith(AndroidJUnit4::class)
class ScrollerTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "plus a horizontal scroller rail"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun boundsOrNull(tag: String): Rect? =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }

    /**
     * A tile's x. Read unclipped, and deliberately NOT filtered on a positive
     * size: once the rail scrolls, the leading tiles sit at negative x, which
     * is the very thing these tests measure.
     */
    private fun tileX(n: Int): Float =
        compose.onAllNodesWithTag("gallery-tile-$n", useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull()
            ?.boundsInRoot
            ?.left
            ?: error("tile $n is not in the tree — the rail did not render")

    private fun press(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(500)
    }

    /**
     * Bring the rail into view.
     *
     * NOT by scrolling to a tile: `performScrollTo` drives the nearest
     * scrollable ancestor, and a tile's nearest scrollable ancestor is the RAIL
     * — so that scrolls the rail sideways and leaves the page exactly where it
     * was, with the whole component still off-screen. The arrow is below the
     * rail and outside it, so scrolling to that moves the page and pulls the
     * rail into view above it.
     */
    private fun showRail() {
        compose.onNodeWithTag("gallery-next", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
    }

    /** Put the rail back at its left edge, so each test starts from a known offset. */
    private fun rewind() {
        showRail()
        var guard = 0
        while (tileX(1) < -1f && guard++ < 12) press("gallery-prev")
    }

    @Before
    fun openScrollerScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Preview Card", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so a previous test's scroll offset
        // survives into this one.
        rewind()
    }

    @Test
    fun pressing_next_moves_the_rail() {
        val before = tileX(1)

        press("gallery-next")

        // The tile slid LEFT, i.e. its x decreased — that is the rail scrolling
        // rightwards. The regression this guards is the one the component
        // shipped with: the arrow fired its tag, the handler ran, and nothing
        // moved, because the handler only incremented a counter.
        val after = tileX(1)
        require(after < before - 20f) {
            "pressing › did not scroll the rail: tile 1 was at $before, now $after"
        }
    }

    @Test
    fun pressing_prev_brings_it_back() {
        val start = tileX(1)

        press("gallery-next")
        val nudged = tileX(1)
        require(nudged < start) { "› did not move the rail, so ‹ cannot be tested" }

        press("gallery-prev")

        // Back where it started. A `nudge` that only ever scrolled one way
        // would pass the test above and fail this one.
        require(kotlin.math.abs(tileX(1) - start) < 20f) {
            "‹ did not undo ›: started $start, ended ${tileX(1)}"
        }
    }

    @Test
    fun the_rail_stops_at_its_left_edge_rather_than_running_negative() {
        val atRest = tileX(1)

        // Already rewound by @Before. Pressing ‹ again must be a no-op, not a
        // scroll into negative space — nudge/3 clamps before it calls the NIF.
        press("gallery-prev")
        press("gallery-prev")

        require(kotlin.math.abs(tileX(1) - atRest) < 4f) {
            "‹ scrolled past the start: $atRest -> ${tileX(1)}"
        }
    }

    @Test
    fun a_finger_scrolls_it_too_and_the_arrows_agree_with_the_finger() {
        val before = tileX(1)

        compose.onNodeWithTag("gallery-tile-1", useUnmergedTree = true)
            .performTouchInput { swipeLeft() }
        compose.waitForIdle()
        Thread.sleep(700)

        val swiped = tileX(1)
        require(swiped < before) { "a swipe did not move the rail: $before -> $swiped" }

        // Both routes drive the same native scroll state, so ‹ after a swipe
        // steps back from where the FINGER left it — not from some offset the
        // handler was tracking separately. That is the difference between
        // nudging a live widget and re-rendering a remembered position.
        press("gallery-prev")
        require(tileX(1) > swiped) {
            "‹ did not continue from where the swipe stopped: $swiped -> ${tileX(1)}"
        }
    }

    @Test
    fun the_arrow_reports_its_tap_as_well_as_scrolling() {
        // Read the counter rather than expecting zero: @Before rewinds the rail
        // by pressing ‹, and the BEAM outlives the Activity, so by the time this
        // runs the count is whatever earlier tests left it at.
        val before = tapCount() ?: error("the tap counter is not on the page")

        press("gallery-next")

        // The counter is the visible difference between "the arrow is dead" and
        // "the rail is already at the end and cannot move further" — worth
        // keeping precisely because a nudge has nothing of its own to re-render.
        compose.waitUntil(10_000) { (tapCount() ?: before) > before }
    }

    private fun tapCount(): Int? =
        compose.onAllNodesWithText("Arrow taps: ", substring = true)
            .fetchSemanticsNodes()
            .flatMap { it.config.getOrNull(SemanticsProperties.Text).orEmpty() }
            .map { it.text }
            .firstNotNullOfOrNull { text ->
                Regex("""Arrow taps: (\d+)""").find(text)?.groupValues?.get(1)?.toIntOrNull()
            }

    @Test
    fun the_page_renders_the_rail_and_both_arrows() {
        showRail()

        require(boundsOrNull("gallery-tile-1") != null) { "the rail's first tile did not lay out" }

        for (arrow in listOf("gallery-prev", "gallery-next")) {
            require(boundsOrNull(arrow) != null) { "$arrow did not lay out" }
        }

        compose.onAllNodesWithText("Scroller", substring = false)[0].assertIsDisplayed()
    }
}
