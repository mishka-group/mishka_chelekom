package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Tree's checkboxes.
 *
 * ## Why this file exists
 *
 * The tree used to draw its own ☐ / ☑ / ⊟ glyphs, so a checkbox inside a tree
 * looked nothing like a checkbox in a form. It now renders the real
 * `MishkaCheckbox`, which moved the tap target from a `Box` to the Checkbox's
 * root `Row` — and whether a handler still reaches the screen from there is a
 * question about the bridge, not about the node tree. `mix test` shows
 * `on_tap: {pid, {:check, …}}` sitting on the node either way.
 *
 * A checkbox carries no text, so it cannot be found by label. The tree gives
 * each one an `:id`, which Mob turns into a native testTag — the same handle
 * the OTP field's invisible input uses.
 *
 * Run with `mix e2e TreeTest`.
 */
@RunWith(AndroidJUnit4::class)
class TreeTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Hierarchical data, expandable and checkable"

    /** The caption under the checkbox example, rendered from the same assign. */
    private val caption = "Checked: "

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

    /** The caption's current text, e.g. "Checked: nothing". */
    private fun captionText(): String =
        compose.onAllNodesWithText(caption, substring = true)
            .fetchSemanticsNodes()
            .firstNotNullOfOrNull { node ->
                node.config.firstOrNull { it.key.name == "Text" }
                    ?.value
                    ?.let { (it as? List<*>)?.firstOrNull()?.toString() }
            } ?: error("no \"$caption…\" caption on screen")

    @Before
    fun openTreeScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Tree", substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The checkbox example is the second one; its caption is the anchor
        // everything here measures from.
        compose.onAllNodesWithText(caption, substring = true)[0].performScrollTo()
        compose.waitForIdle()

        // The screen is a live GenServer and keeps whatever the last test did to
        // it — the collapse test leaves "lib" shut, and every later test needs
        // its children back.
        if (compose.onAllNodesWithTag("tree-check-lib/mishka_mob.ex")
                .fetchSemanticsNodes().isEmpty()
        ) {
            compose.onAllNodesWithTag("tree-toggle-lib")[1].performScrollTo().performClick()
            compose.waitUntil(10_000) {
                compose.onAllNodesWithTag("tree-check-lib/mishka_mob.ex")
                    .fetchSemanticsNodes().isNotEmpty()
            }
        }
    }

    @Test
    fun the_checkbox_example_renders_its_caption() {
        compose.onAllNodesWithText(caption, substring = true)[0].assertIsDisplayed()
        require(captionText().startsWith(caption)) { "caption reads ${captionText()}" }
    }

    @Test
    fun tapping_a_node_checkbox_reaches_the_screen() {
        val before = captionText()

        // An ENABLED leaf. mix.exs is disabled: true in the demo data, so its
        // checkbox is deliberately inert and would prove nothing.
        checkbox("lib/mishka_mob.ex").performClick()
        compose.waitUntil(10_000) { captionText() != before }

        require(captionText().contains("mishka_mob.ex")) {
            "the caption reads [${captionText()}] — the tap did not name the node it hit"
        }
    }

    @Test
    fun the_disclosure_arrow_still_works() {
        // A handler this change never touched, on the same page and the same
        // tree. If this fails too, taps on this page are broken independently
        // of the checkbox; if it passes, the checkbox is the odd one out.
        // on_expand / on_collapse carry a per-node value the same way on_check
        // does, so they were inert for the same reason. Collapsing "lib" must
        // take its children off the screen with it.
        val child = "tree-check-lib/mishka_mob.ex"
        require(compose.onAllNodesWithTag(child).fetchSemanticsNodes().isNotEmpty()) {
            "expected lib to start expanded, with its children on screen"
        }

        // By tag, not by glyph: every arrow on the page reads "▾", and the
        // first one belongs to the example above this one.
        compose.onAllNodesWithTag("tree-toggle-lib")[1].performScrollTo().performClick()
        compose.waitUntil(10_000) {
            compose.onAllNodesWithTag(child).fetchSemanticsNodes().isEmpty()
        }
    }

    @Test
    fun the_disabled_node_sends_nothing() {
        val before = captionText()

        checkbox("mix.exs").performClick()

        compose.waitForIdle()
        Thread.sleep(600)

        require(captionText() == before) { "a disabled node changed the checked set" }
    }

    /**
     * The checkbox for the node with [value], scrolled into view.
     *
     * A checkbox carries no text, so there is nothing to match on; the tree
     * gives each one an `:id`, which Mob turns into a native testTag. Indexed,
     * because the page renders more than one tree and only the checkbox example
     * builds these — index 0 is the one under test.
     *
     * The scroll is not optional. performClick dispatches at the node's
     * coordinates whether or not those are inside the window, so clicking one
     * that has been pushed off-screen — which expanding a branch above it does —
     * misses silently: no exception, no event, just a test that waits out its
     * timeout. Every failure this file ever reported was that.
     */
    private fun checkbox(value: String) =
        compose.onAllNodesWithTag("tree-check-$value")[0].performScrollTo()
}
