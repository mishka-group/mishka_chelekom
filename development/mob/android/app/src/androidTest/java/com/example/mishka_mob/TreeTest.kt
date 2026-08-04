package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.longClick
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Tree page.
 *
 * ## Everything this component knows, it says in a colour or a glyph
 *
 * A checkbox is a drawn mark, an arrow is "▾" or "▸" on every row alike, and a
 * selection is a tint and a font weight. None of the three is in the semantics
 * tree, so **every assertion here is on a testTag** — the tree gives each part
 * an `:id`, which Mob turns into a native tag, and folds the state into the
 * tags that describe one: `<id>-<value>-open`, `-selected`, `-checked`,
 * `-loading`.
 *
 * Tags rather than text for a second reason too. Every example on this page
 * renders into one scrolling column, and the code samples beneath them are text
 * nodes as well — so a page-wide text query is answered by whichever example
 * happens to contain the string, which is rarely the one under test.
 *
 * The row, the disclosure and the checkbox are all tappable, and a clickable
 * node merges its children's semantics, so the state tags live inside a merged
 * subtree: every query here passes `useUnmergedTree = true`.
 *
 * The first two examples deliberately share the default `id` ("tree") and are
 * addressed by index; the rest carry their own (`multi`, `async`, `strict`,
 * `ts`) and need no index at all.
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

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun node(tag: String) = compose.onNodeWithTag(tag, useUnmergedTree = true)

    /**
     * Scroll [tag] into view and tap it.
     *
     * The scroll is not optional. performClick dispatches at the node's
     * coordinates whether or not those are inside the window, so clicking one
     * that has been pushed off-screen — which expanding a branch above it does
     * — misses silently: no exception, no event, just a test that waits out its
     * timeout. Every failure this file ever reported was that.
     *
     * [settle] is the pause afterwards. It is zero wherever the assertion is
     * about a state that expires — the loader lives for about a second, and a
     * courtesy sleep would spend most of it.
     */
    private fun tap(tag: String, settle: Long = 400) {
        node(tag).performScrollTo().performTouchInput { click() }
        compose.waitForIdle()
        if (settle > 0) Thread.sleep(settle)
    }

    private fun hold(tag: String) {
        node(tag).performScrollTo().performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
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
        if (!tagged("tree-check-lib/mishka_mob.ex")) {
            compose.onAllNodesWithTag("tree-toggle-lib", useUnmergedTree = true)[1]
                .performScrollTo()
                .performClick()
            compose.waitUntil(10_000) { tagged("tree-check-lib/mishka_mob.ex") }
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
        require(tagged(child)) {
            "expected lib to start expanded, with its children on screen"
        }

        // By tag, not by glyph: every arrow on the page reads "▾", and the
        // first one belongs to the example above this one. Index 1 is the
        // checkbox example — the two examples that share the default id are the
        // first two on the page, which `mix test` asserts so this index cannot
        // quietly drift.
        compose.onAllNodesWithTag("tree-toggle-lib", useUnmergedTree = true)[1]
            .performScrollTo()
            .performClick()
        compose.waitUntil(10_000) { !tagged(child) }
    }

    @Test
    fun the_disabled_node_sends_nothing() {
        val before = captionText()

        checkbox("mix.exs").performClick()

        compose.waitForIdle()
        Thread.sleep(600)

        require(captionText() == before) { "a disabled node changed the checked set" }
    }

    @Test
    fun holding_a_row_selects_the_range() {
        // Shift+click has no finger. A long press is what the range moved onto,
        // and this is the only thing that proves the gesture arrives at all —
        // the selection it produces is otherwise indistinguishable from four
        // separate taps.
        tap("multi-clear")
        tap("multi-row-ada")
        compose.waitUntil(10_000) { tagged("multi-ada-selected") }

        hold("multi-row-fen")

        compose.waitUntil(10_000) { tagged("multi-fen-selected") }
        require(tagged("multi-bo-selected") && tagged("multi-dee-selected")) {
            "the hold selected its own row but not the run leading up to it"
        }
        // DESIGN and ENGINEERING are selectable: false and Eve is disabled. All
        // three sit inside the run and none of them may join it.
        require(tagged("multi-eng-idle")) { "a header joined the range" }
        require(tagged("multi-eve-idle")) { "a disabled row joined the range" }
    }

    @Test
    fun a_tap_adds_rather_than_replacing() {
        tap("multi-clear")
        tap("multi-row-ada")
        tap("multi-row-cy")

        compose.waitUntil(10_000) { tagged("multi-cy-selected") }
        require(tagged("multi-ada-selected")) {
            "the second tap replaced the first — multiple: true was not applied"
        }
    }

    @Test
    fun a_header_row_cannot_be_selected() {
        tap("multi-clear")

        // No handler at all is wired on this row, so the touch lands on nothing.
        // That is the assertion: a category heading is not a destination.
        tap("multi-row-design")

        require(tagged("multi-design-idle")) { "a selectable: false header was selected" }
        require(tagged("multi-ada-idle")) { "tapping the header selected its children" }
    }

    @Test
    fun the_arrow_tag_says_which_way_it_points() {
        // The glyph is "▸" or "▾" — or, in this example, "+" and "−" — and none
        // of them is readable from a device test. The state is in the tag on the
        // arrow rather than on the Box around it, because a target renamed by
        // the act of using it can only be used once.
        if (!tagged("strict-lib-open")) tap("strict-toggle-lib")
        require(tagged("strict-lib-open")) { "could not get the branch open to start" }

        tap("strict-toggle-lib")

        compose.waitUntil(10_000) { tagged("strict-lib-closed") }
        require(!tagged("strict-row-lib/mishka_mob.ex")) {
            "the arrow flipped but the branch's children stayed on screen"
        }

        tap("strict-toggle-lib")
        compose.waitUntil(10_000) { tagged("strict-lib-open") }
    }

    @Test
    fun an_unfetched_branch_reports_a_load_before_it_opens() {
        // has_children: true with no children. The first tap is a request, not
        // a state change — so the row goes busy and stays shut until the screen
        // answers, which is the whole reason on_load_children is its own event.
        tap("async-reset")
        require(tagged("async-assets-closed")) { "the branch did not start closed" }

        tap("async-row-assets", settle = 0L)

        compose.waitUntil(10_000) { tagged("async-assets-loading") }
        require(tagged("async-assets-closed")) {
            "the branch opened before its children had arrived"
        }

        compose.waitUntil(10_000) { tagged("async-row-assets/logo.png") }
        require(tagged("async-assets-open")) {
            "the children arrived but the branch never opened"
        }
    }

    @Test
    fun a_strict_check_does_not_cascade() {
        if (!tagged("strict-lib-open")) tap("strict-toggle-lib")
        if (tagged("strict-lib-checked")) tap("strict-check-lib")
        require(tagged("strict-lib-empty")) { "could not get the parent unchecked to start" }

        tap("strict-check-lib")

        compose.waitUntil(10_000) { tagged("strict-lib-checked") }
        require(tagged("strict-lib/mishka_mob.ex-empty")) {
            "check_strictly cascaded to a descendant"
        }

        // Leave it as we found it: the screen outlives this test.
        tap("strict-check-lib")
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Expand and select",
            "Checkboxes cascade",
            "Multiple, and hold for a range",
            "Headers, and children on demand",
            "Strict checks, everything open",
            "Tree select",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }

    /**
     * The checkbox for the node with [value], scrolled into view.
     *
     * A checkbox carries no text, so there is nothing to match on; the tree
     * gives each one an `:id`, which Mob turns into a native testTag. Indexed,
     * because the page renders more than one tree and only the checkbox example
     * builds these under the default prefix — index 0 is the one under test.
     */
    private fun checkbox(value: String) =
        compose.onAllNodesWithTag("tree-check-$value", useUnmergedTree = true)[0]
            .performScrollTo()
}
