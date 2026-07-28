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
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import kotlin.math.abs

/**
 * End-to-end tests for the Mark and Highlight pages.
 *
 * ## Why this file exists
 *
 * A mark rendered as a full-width bar rather than a highlighted word — the
 * opposite of what `<mark>` means — because a Box told neither `width` nor
 * `fill_width` fills its parent. Same defect as the pill, one component over,
 * and invisible to the Elixir suite for the same reason: the node tree was
 * correct, and `Mob.ScreenCase` asserts on the tree.
 *
 * So the assertions here are geometric. [a_mark_sits_inline_with_its_neighbour]
 * fails on the old build; nothing in `mix test` could.
 *
 * The other thing only a device can show is the wrap. `Text` has no span API, so
 * a highlighted sentence is many nodes in a `Row`, and a `Row` does not wrap —
 * `wrap_at` packs them into lines by a declared character budget, and whether
 * that lands correctly is a question about pixels.
 *
 * Case sensitivity is deliberately NOT tested here: Compose semantics do not
 * expose a node's background, so "is this word marked" is unanswerable on
 * device. `MishkaHighlightTest` covers it against `split/3` directly.
 *
 * Run with `mix e2e HighlightTest`.
 */
@RunWith(AndroidJUnit4::class)
class HighlightTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val markPage = "A colour per mark"
    private val highlightPage = "Every occurrence, whatever its casing"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun awaitText(text: String, timeoutMs: Long = 60_000) =
        compose.waitUntil(timeoutMs) { showing(text) }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    /**
     * Reach the page whose [card] is in the gallery, from wherever the last test
     * left the app — it outlives the Activity, and both classes run in one
     * process, so "← Back" counts as booted alongside the two page markers.
     */
    private fun openPage(card: String, marker: String) {
        compose.waitUntil(90_000) { showing(home) || showing(marker) || showing("← Back") }

        var guard = 0
        while (!showing(marker) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(marker)) {
            compose.onNodeWithText(card, substring = false).performScrollTo().performClick()
            awaitText(marker)
        }
    }

    /**
     * Scroll the FIRST node matching [label] into view.
     *
     * Indexed rather than `onNodeWithText`, which demands exactly one match and
     * dies otherwise — and on these pages nothing is unique. "BEAM" is marked in
     * two examples, "This" in two, and "Highlighted text" is both a heading and
     * the page's own description.
     */
    private fun scrollTo(label: String, exact: Boolean = true) {
        compose.onAllNodesWithText(label, substring = !exact)[0].performScrollTo()
        compose.waitForIdle()
    }

    /**
     * Bounds of the topmost PLACED node whose text is EXACTLY [label].
     *
     * Exact is what makes this meaningful: the code samples quote the same
     * words, but each sample is one long string node, so only the rendered runs
     * match. Topmost, because a word can appear in more than one example.
     *
     * Empty rects are dropped first. A node that is in the semantics tree but
     * has not been laid out reports (0, 0, 0, 0), and a zero top wins every
     * "topmost" comparison — which is how this came to ask whether "BEAM" shared
     * a row with a rectangle that is not anywhere.
     */
    private fun boundsOf(label: String): Rect {
        compose.waitForIdle()

        val placed =
            compose.onAllNodesWithText(label, substring = false)
                .fetchSemanticsNodes()
                .map { it.boundsInRoot }
                .filter { it.width > 0f && it.height > 0f }

        require(placed.isNotEmpty()) { "no laid-out node reading exactly \"$label\"" }
        return placed.minByOrNull { it.top }!!
    }

    private fun sameRow(a: Rect, b: Rect) = abs(a.center.y - b.center.y) < a.height

    // ── the reason this file exists ──────────────────────────────────────────

    @Test
    fun a_mark_sits_inline_with_its_neighbour() {
        openPage("Mark", markPage)
        scrollTo("BEAM")

        // THE regression. A filling mark takes the whole line, so these two
        // cannot share a row — which is exactly what the screen showed.
        val beam = boundsOf("BEAM")
        val device = boundsOf("on device")

        require(sameRow(beam, device)) { "different rows: BEAM=$beam onDevice=$device" }
        require(device.left > beam.right) { "\"on device\" is not to the right of \"BEAM\"" }
    }

    @Test
    fun a_mark_hugs_its_word_rather_than_filling_the_line() {
        openPage("Mark", markPage)
        scrollTo("BEAM")

        val root = compose.onRoot().fetchSemanticsNode().boundsInRoot
        val beam = boundsOf("BEAM")

        require(beam.width < root.width / 3f) {
            "a mark spans ${beam.width} of ${root.width} — it is filling, not hugging"
        }
    }

    @Test
    fun a_mark_composes_inline_with_ordinary_text() {
        openPage("Mark", markPage)
        scrollTo("Error")

        // The per-match-colour example: a tinted word followed by plain text,
        // which is what Highlight's single background cannot express.
        val error = boundsOf("Error")
        val rest = boundsOf(": Invalid input.")

        require(sameRow(error, rest)) { "the mark and its sentence are on different rows" }
        require(rest.left > error.right) { "the sentence is not to the right of the mark" }
    }

    @Test
    fun a_highlighted_sentence_wraps_instead_of_running_off_the_edge() {
        openPage("Highlight", highlightPage)
        scrollTo("This")

        // wrap_at={34} breaks this sentence after "THIS", so the first two marks
        // share a line and the third starts the next one.
        val first = boundsOf("This")
        val second = boundsOf("THIS")
        val third = boundsOf("this")

        require(sameRow(first, second)) { "different rows: This=$first THIS=$second" }
        require(!sameRow(first, third)) { "no wrap: This=$first this=$third" }
        require(third.top > first.top) { "this above This: This=$first this=$third" }

        // …and nothing left the screen on the way.
        val root = compose.onRoot().fetchSemanticsNode().boundsInRoot
        for (mark in listOf(first, second, third)) {
            require(mark.right <= root.right) { "a mark at ${mark.right} is past the edge" }
        }
    }

    // ── the pages ────────────────────────────────────────────────────────────

    @Test
    fun the_mark_page_renders_every_example_and_the_props_table() {
        openPage("Mark", markPage)

        for (heading in listOf(
            "Highlighted text",
            "A colour per mark",
            "In a sentence",
            "Colours",
            "Props",
        )) {
            scrollTo(heading, exact = false)
            compose.onAllNodesWithText(heading, substring = true)[0].assertIsDisplayed()
        }
    }

    @Test
    fun the_highlight_page_renders_every_example_and_the_props_table() {
        openPage("Highlight", highlightPage)

        for (heading in listOf(
            "Every occurrence",
            "Case sensitivity",
            "Matching a query",
            "Several queries",
            "Wrapping a sentence",
            "No match, no marks",
            "Props",
        )) {
            scrollTo(heading, exact = false)
            compose.onAllNodesWithText(heading, substring = true)[0].assertIsDisplayed()
        }
    }

    @Test
    fun the_live_query_follows_the_tapped_button() {
        openPage("Highlight", highlightPage)

        // The button is the query itself, and the page keeps rendering the
        // sentence it marks — a crash or a dropped handler shows up here.
        scrollTo("beam")
        compose.onAllNodesWithText("beam", substring = false)[0].performClick()
        compose.waitForIdle()

        awaitText("Mishka Chelekom", timeoutMs = 15_000)
    }

    @Test
    fun the_code_samples_show_the_tags_inside_a_sigil() {
        openPage("Highlight", highlightPage)

        val tags =
            compose.onAllNodesWithText("<MishkaHighlight", substring = true).fetchSemanticsNodes()
        require(tags.isNotEmpty()) { "no <MishkaHighlight … /> in the samples" }

        // wrap_at and case_sensitive are the two props a reader cannot guess,
        // so both appear in a sample rather than only in the table.
        for (prop in listOf("wrap_at", "case_sensitive")) {
            require(showing(prop)) { "$prop appears in no code sample" }
        }
    }
}
