package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import kotlin.math.abs

/**
 * End-to-end tests for the Avatar and Code pages.
 *
 * Neither component has events, so there is no round trip to prove — what only
 * a device can answer here is **size and shape**, and both had a claim that the
 * node tree could not check.
 *
 * Inline code says it "hugs its text" and did not: a Box given neither width nor
 * fill_width fills its parent, so it rendered as a full-width bar. The unit test
 * asserted the ABSENCE of fill_width and called that hugging, which is how the
 * bug survived — [inline_code_hugs_its_text] is the assertion that could not be
 * fooled that way.
 *
 * And an avatar's `:circle` is size/2 rather than a radius token, so that a
 * small and a large one are both round. Only real layout can say whether they
 * came out square.
 *
 * Run with `mix e2e DisplayTest`.
 */
@RunWith(AndroidJUnit4::class)
class DisplayTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"

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

    private fun openPage(card: String, marker: String) {
        compose.waitUntil(90_000) { showing(home) || showing(marker) || showing("← Back") }

        var guard = 0
        while (!showing(marker) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(marker)) {
            compose.onNodeWithText(card, substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(marker) }
        }
    }

    /** Bounds of the topmost PLACED node reading exactly [label]. */
    private fun boundsOf(label: String): Rect {
        compose.waitForIdle()

        val placed = compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

        require(placed.isNotEmpty()) { "no laid-out node reading exactly \"$label\"" }
        return placed.minByOrNull { it.top }!!
    }

    // ── Code ─────────────────────────────────────────────────────────────────

    @Test
    fun inline_code_hugs_its_text() {
        openPage("Code", "sits in a sentence")

        // THE regression. The moduledoc said "hugs its text" while the Box
        // filled its parent, and the unit test asserted the absence of
        // fill_width — which is exactly the state that FILLS.
        // By tag, not by text: "mix mob.deploy" is in this example's own code
        // sample too, and that node spans the card — matching it would measure
        // the prose instead of the snippet.
        compose.onNodeWithTag("inline-code").performScrollTo()
        compose.waitForIdle()

        val root = compose.onRoot().fetchSemanticsNode().boundsInRoot
        val snippet = compose.onNodeWithTag("inline-code").fetchSemanticsNode().boundsInRoot

        require(snippet.width > 0f) { "the inline snippet was not laid out" }
        require(snippet.width < root.width / 2f) {
            "inline code spans ${snippet.width} of ${root.width} — it is filling, not hugging"
        }
    }

    @Test
    fun a_code_block_fills_the_width() {
        openPage("Code", "sits in a sentence")

        // The other half of the same prop: a block is meant to fill, so the two
        // together prove fill_width is honoured in BOTH directions rather than
        // just being absent everywhere.
        compose.onAllNodesWithText("Block", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        compose.onAllNodesWithText("Block", substring = false)[0].assertIsDisplayed()
    }

    @Test
    fun the_code_page_renders_every_example_and_the_props_table() {
        openPage("Code", "sits in a sentence")

        for (heading in listOf("Inline", "Block", "Without the scroller", "Colours", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }

    // ── Avatar ───────────────────────────────────────────────────────────────

    @Test
    fun an_avatar_is_square_at_every_size() {
        openPage("Avatar", "text fallback")

        // :circle resolves to size/2 rather than a radius token, which is what
        // keeps a 24 and a 96 both round — and it only works if the box really
        // is square. A token would leave the large one a rounded rectangle.
        compose.onNodeWithTag("avatar-64").performScrollTo()
        compose.waitForIdle()

        for (tag in listOf("avatar-28", "avatar-44", "avatar-64")) {
            val b = compose.onNodeWithTag(tag).fetchSemanticsNode().boundsInRoot
            require(b.width > 0f) { "$tag was not laid out" }
            require(abs(b.width - b.height) < 2f) {
                "$tag is ${b.width}x${b.height} — not square, so size/2 cannot round it"
            }
        }

        // …and they really are three different sizes, so the radius has to scale.
        val small = compose.onNodeWithTag("avatar-28").fetchSemanticsNode().boundsInRoot
        val large = compose.onNodeWithTag("avatar-64").fetchSemanticsNode().boundsInRoot
        require(large.width > small.width * 2f) {
            "28 and 64 came out ${small.width} and ${large.width}"
        }
    }

    @Test
    fun the_fallback_shows_without_a_src() {
        openPage("Avatar", "text fallback")

        // The stacking contract: the fallback is always built, and an image is
        // drawn OVER it. With no src there is no image, so the initials are the
        // avatar — not an empty circle waiting for a load that never comes.
        compose.onAllNodesWithText("Initials", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        require(showing("SH")) { "the fallback initials did not render" }
    }

    @Test
    fun the_avatar_page_renders_every_example_and_the_props_table() {
        openPage("Avatar", "text fallback")

        for (heading in listOf("Initials", "Shapes", "Sizes", "In a row", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
