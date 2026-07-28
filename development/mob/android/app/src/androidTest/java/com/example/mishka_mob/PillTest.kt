package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import kotlin.math.abs

/**
 * End-to-end tests for the Pill and its showcase page.
 *
 * ## Why this file exists
 *
 * The pill bug that prompted it was invisible to all 1126 Elixir tests, and had
 * to be: `MobBridge` never read `fill_width` for a Box, so a Box could only be
 * told to stop filling by pinning an exact width — which a pill, being as wide
 * as its text, cannot do. Every pill therefore filled its row and the "Inside
 * inputs" example showed one token per line.
 *
 * The node tree was correct throughout. `Mob.ScreenCase` asserts on that tree,
 * so it saw three sibling pills in a Row and was satisfied; only the screen
 * disagreed. That is the whole reason for testing here: **[pills_wrap_three_to_a_row]
 * is the assertion that would have failed**, and it can only be made against
 * real layout.
 *
 * See [OtpFieldTest] for the two things that make this app unusual to test (the
 * BEAM boots asynchronously, and it outlives the Activity).
 *
 * Run with `mix e2e PillTest`.
 */
@RunWith(AndroidJUnit4::class)
class PillTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun awaitText(text: String, timeoutMs: Long = 60_000) =
        compose.waitUntil(timeoutMs) { showing(text) }

    /** Root-relative bounds of a label, scrolled into view first. */
    private fun boundsOf(label: String): Rect {
        compose.onNodeWithText(label, substring = false).performScrollTo()
        compose.waitForIdle()
        return compose.onNodeWithText(label, substring = false).fetchSemanticsNode().boundsInRoot
    }

    private fun sameRow(a: Rect, b: Rect) = abs(a.center.y - b.center.y) < a.height

    /**
     * Index into `onAllNodesWithText("✕")` of the remove button belonging to
     * [label] — the nearest ✕ to its right on the same row.
     *
     * Found by geometry rather than by counting, because tree order is not the
     * page's promise: the ✕ that dismisses "Item 3" is defined by sitting next
     * to it, and that is exactly what a finger goes by.
     */
    private fun crossIndexFor(label: String): Int {
        val target = boundsOf(label)
        val crosses = compose.onAllNodesWithText("✕", substring = false).fetchSemanticsNodes()

        val index =
            crosses.withIndex()
                .filter { (_, node) ->
                    val b = node.boundsInRoot
                    b.left >= target.right - 1f && sameRow(target, b)
                }
                .minByOrNull { (_, node) -> node.boundsInRoot.left }
                ?.index

        require(index != null) { "no ✕ found to the right of \"$label\"" }
        return index
    }

    private fun tokenCount() =
        compose.onAllNodesWithText("Item ", substring = true).fetchSemanticsNodes().size

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    /** The Pill page's own copy — nothing else in the gallery carries it. */
    private val marker = "The wrapping is the point"

    /**
     * The home screen's subtitle. Waiting on "Components" instead — the GALLERY
     * screen's header — hangs for the full 90s: the app boots to home, which
     * lists the component cards directly and never says that word.
     */
    private val home = "Native component library"

    @Before
    fun openPillScreen() {
        // Wait for ANY rendered screen, not just the two this test wants. The
        // BEAM outlives the Activity and instrumentation runs the classes in one
        // process, so PillTest starts wherever OtpFieldTest finished — on the OTP
        // page, where neither `home` nor `marker` will ever appear. "← Back" is
        // on every component page, which makes the three together "booted".
        compose.waitUntil(90_000) { showing(home) || showing(marker) || showing("← Back") }

        var guard = 0
        while (!showing(marker) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(marker)) {
            compose.onNodeWithText("Pill", substring = false).performScrollTo().performClick()
            awaitText(marker)
        }

        // The screen is a live GenServer and keeps whatever the last test did to
        // it, so start from all ten tokens.
        if (tokenCount() < 10) {
            compose.onNodeWithText("Reset tokens", substring = false)
                .performScrollTo()
                .performClick()
            compose.waitUntil(10_000) { tokenCount() >= 10 }
        }
    }

    // ── layout: the reason this file exists ──────────────────────────────────

    @Test
    fun pills_wrap_three_to_a_row() {
        // THE regression. With fill_width ignored each pill took the whole row,
        // so Item 0 and Item 1 sat on different lines. Their y-centres are the
        // entire assertion, and no node-tree test can make it.
        val zero = boundsOf("Item 0")
        val one = boundsOf("Item 1")
        val two = boundsOf("Item 2")
        val three = boundsOf("Item 3")

        require(sameRow(zero, one)) { "Item 0 and Item 1 are on different rows" }
        require(sameRow(zero, two)) { "Item 0 and Item 2 are on different rows" }
        require(one.left > zero.right) { "Item 1 is not to the right of Item 0" }

        // …and the chunk is three, so the fourth starts a new row BELOW.
        require(!sameRow(zero, three)) { "Item 3 did not wrap onto a new row" }
        require(three.top > zero.top) { "Item 3 is above the row it should follow" }
    }

    @Test
    fun a_pill_hugs_its_label_rather_than_filling_the_width() {
        val root = compose.onRoot().fetchSemanticsNode().boundsInRoot
        val short = boundsOf("Item 0")

        require(short.width < root.width / 2f) {
            "a pill spans ${short.width} of ${root.width} — it is filling, not hugging"
        }
    }

    // ── behaviour ────────────────────────────────────────────────────────────

    @Test
    fun tapping_a_remove_button_drops_exactly_that_token() {
        val before = tokenCount()
        val index = crossIndexFor("Item 3")

        compose.onAllNodesWithText("✕", substring = false)[index].performClick()
        compose.waitUntil(10_000) { !showing("Item 3") }

        require(tokenCount() == before - 1) { "expected ${before - 1} tokens, got ${tokenCount()}" }
        require(showing("Item 2") && showing("Item 4")) { "a neighbouring token went with it" }
    }

    @Test
    fun reset_brings_every_token_back() {
        compose.onAllNodesWithText("✕", substring = false)[crossIndexFor("Item 0")].performClick()
        compose.waitUntil(10_000) { !showing("Item 0") }

        compose.onNodeWithText("Reset tokens", substring = false).performScrollTo().performClick()
        compose.waitUntil(10_000) { showing("Item 0") }

        require(tokenCount() == 10) { "expected 10 tokens after reset, got ${tokenCount()}" }
    }

    @Test
    fun emptying_the_tokens_leaves_a_message() {
        repeat(10) {
            val crosses = compose.onAllNodesWithText("✕", substring = false).fetchSemanticsNodes()
            require(crosses.isNotEmpty()) { "ran out of ✕ before the tokens ran out" }
            compose.onAllNodesWithText("✕", substring = false)[0].performClick()
            compose.waitForIdle()
        }

        awaitText("No tags left", timeoutMs = 15_000)

        compose.onNodeWithText("Reset tokens", substring = false).performScrollTo().performClick()
        compose.waitUntil(10_000) { showing("Item 0") }
    }

    @Test
    fun tapping_a_pill_body_sends_its_tag_to_the_screen() {
        // on_tap is a different target from the ✕, and the caption below is
        // rendered from the assign the tap sets — so this proves the round trip
        // rather than a local highlight.
        compose.onNodeWithText("Elixir", substring = false).performScrollTo().performClick()
        awaitText("Picked: elixir", timeoutMs = 15_000)

        compose.onNodeWithText("Swift", substring = false).performScrollTo().performClick()
        awaitText("Picked: swift", timeoutMs = 15_000)
    }

    @Test
    fun the_disabled_pill_sends_nothing() {
        compose.onNodeWithText("Swift", substring = false).performScrollTo().performClick()
        awaitText("Picked: swift", timeoutMs = 15_000)

        // `disabled` DROPS the handlers rather than guarding them, so this tap
        // has nothing to deliver and the pick must stand.
        compose.onNodeWithText("locked", substring = false).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        require(showing("Picked: swift")) { "the disabled pill changed the selection" }
    }

    // ── the page ─────────────────────────────────────────────────────────────

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf("Inside inputs", "Tappable", "Plain", "Colour", "Disabled", "Props")) {
            compose.onNodeWithText(heading, substring = true)
                .performScrollTo()
                .assertIsDisplayed()
        }
    }

    @Test
    fun the_code_samples_show_the_tag_inside_a_sigil() {
        val sigils = compose.onAllNodesWithText("~MOB", substring = true).fetchSemanticsNodes()
        require(sigils.isNotEmpty()) { "no ~MOB block found in any code sample" }

        val tags = compose.onAllNodesWithText("<MishkaPill", substring = true).fetchSemanticsNodes()
        require(tags.isNotEmpty()) { "no <MishkaPill … /> in the samples" }

        // Every event prop on the page is shown WITH the handler that receives
        // it — a sample that only sets on_tap leaves the reader nowhere to go.
        val handlers =
            compose.onAllNodesWithText("handle_info", substring = true).fetchSemanticsNodes()
        require(handlers.isNotEmpty()) { "no handler shown beside the event props" }
    }
}
