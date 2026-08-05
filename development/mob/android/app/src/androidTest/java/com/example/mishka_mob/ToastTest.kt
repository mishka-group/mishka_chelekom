package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Toast page.
 *
 * [the_close_button_can_actually_be_hit] is why this file exists. The card's body
 * was a `fill_width` Column sitting BEFORE the fixed-width ✕ in the same Row, and
 * a Compose Row measures a non-weighted child against the space left over — so
 * the body claimed the whole row and the ✕ was measured at width 0. It was in the
 * node tree, it had its on_tap, and the harness would happily "click" it; only a
 * finger could tell. iOS was unaffected, because an HStack serves its fixed-size
 * children first, which is exactly what let it survive review. Same shape as
 * EmptyStateTest's unreachable second action — measure the control, do not trust
 * the tree.
 *
 * String traps on this page, and there are several: every example prints its own
 * source, so "Saved", "Welcome", "Dismiss" and "Written in markup, not queued."
 * are all on screen whether or not anything rendered. Assert only on strings the
 * RENDER produces and the samples do not:
 *   - "Heads up"            the :info toast's title (samples only say "Saved")
 *   - "its body is a slot"  the markup item's body (the sample stops earlier)
 *   - exact "✕"             the close glyph; the description merely mentions it
 *                           inside a longer string, so substring = false splits them
 *
 * Run with `mix e2e ToastTest`.
 */
@RunWith(AndroidJUnit4::class)
class ToastTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "The viewport renders whatever list the screen holds"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Nodes reading EXACTLY [label] that were really laid out. */
    private fun placed(label: String): List<Rect> =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

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

    /** The toast viewport is an overlay, so its cards need no scrolling. */
    private fun tapOverlay(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performClick()
        compose.waitForIdle()
        Thread.sleep(300)
    }

    @Before
    fun openToastScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Toast", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        clearToasts()
    }

    /**
     * The BEAM outlives the Activity, so a page left holding toasts (or the markup
     * item toggled on) leaks into every later test class. Reset both ends.
     */
    @After
    fun clearToasts() {
        if (showing("its body is a slot")) tap("Toggle markup toast")
        if (showing("Heads up") || showing("Careful")) tap("Clear all")
        compose.waitForIdle()
    }

    @Test
    fun tapping_a_button_stacks_a_toast() {
        tap("Info")
        compose.waitUntil(10_000) { showing("Heads up") }

        tap("Warning")
        compose.waitUntil(10_000) { showing("Careful") }
        require(showing("Heads up")) { "the second toast replaced the first instead of stacking" }
    }

    @Test
    fun the_close_button_can_actually_be_hit() {
        tap("Info")
        compose.waitUntil(10_000) { showing("Heads up") }

        // The regression: the ✕ was measured to ZERO width because the card's
        // body took the whole Row. Measure it, then use it.
        val glyphs = placed("✕")
        require(glyphs.isNotEmpty()) { "no laid-out ✕ — the close button has no size at all" }

        val glyph = glyphs.first()
        require(glyph.width >= 8f) { "the ✕ is too narrow to hit: $glyph" }

        // And it sits clear of the text rather than under it.
        val title = placed("Heads up").first()
        require(glyph.left >= title.right - 2f) { "the ✕ overlaps the title: $glyph vs $title" }

        // The round trip is the feature: tapping it must remove that toast.
        tapOverlay("✕")
        compose.waitUntil(10_000) { !showing("Heads up") }
    }

    @Test
    fun each_card_gets_its_own_close_button() {
        tap("Info")
        compose.waitUntil(10_000) { showing("Heads up") }
        tap("Warning")
        compose.waitUntil(10_000) { showing("Careful") }

        // Two cards, two hittable ✕s — the per-card id is what makes one handler
        // clause serve every toast.
        val glyphs = placed("✕")
        require(glyphs.size >= 2) { "expected a ✕ per card, found ${glyphs.size}" }
        require(glyphs.all { it.width >= 8f }) { "a ✕ was measured too narrow: $glyphs" }

        // Dismissing one leaves the other alone.
        tapOverlay("✕")
        compose.waitUntil(10_000) { placed("✕").size < glyphs.size }
        require(showing("Heads up") || showing("Careful")) { "dismissing one dropped both" }
    }

    @Test
    fun limit_keeps_only_the_newest_few() {
        // The page pushes with limit: 3, so a fourth distinct toast evicts the
        // oldest rather than growing the stack.
        for (label in listOf("Info", "Success", "Warning", "Danger")) {
            tap(label)
            compose.waitForIdle()
        }

        compose.waitUntil(10_000) { showing("Failed") }
        require(placed("✕").size <= 3) { "limit: 3 did not cap the stack: ${placed("✕").size}" }
        require(!showing("Heads up")) { "the oldest toast was not evicted" }
    }

    @Test
    fun the_markup_toast_renders_its_slot_body_and_close_label() {
        tap("Toggle markup toast")

        // "its body is a slot" is only ever produced by the render — the printed
        // sample stops at "not queued."
        compose.waitUntil(10_000) { showing("its body is a slot") }

        // <MishkaToastClose> replaces the glyph on every card, so the exact-"✕"
        // node disappears while a "Dismiss" label takes its place.
        require(placed("✕").isEmpty()) { "the close slot did not replace the ✕" }
        require(placed("Dismiss").isNotEmpty()) { "the close slot rendered nothing" }

        // A static item is not in the queue, so its ✕ cannot go through
        // Queue.dismiss — the screen drops it by flipping the flag.
        tapOverlay("Dismiss")
        compose.waitUntil(10_000) { !showing("its body is a slot") }
    }

    @Test
    fun a_markup_toast_stacks_with_the_queued_ones() {
        tap("Toggle markup toast")
        compose.waitUntil(10_000) { showing("its body is a slot") }

        tap("Info")
        compose.waitUntil(10_000) { showing("Heads up") }

        // Static items render BEFORE the queued ones.
        val markup = placed("Welcome").minByOrNull { it.top }
        val queued = placed("Heads up").minByOrNull { it.top }
        require(markup != null && queued != null) { "expected both cards on screen" }
        require(markup.top < queued.top) { "the markup toast is not above the queued one" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Stack a few",
            "Capped and deduped",
            "Position",
            "Slots",
            "Auto-dismiss",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
