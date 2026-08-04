package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Tree Select page.
 *
 * Everything this component says about itself, it says in a colour and a glyph:
 * a placeholder is muted where a real selection is not, and open is a ▴ where
 * closed is a ▾. None of that is in the accessibility tree, and the trigger's
 * only text is whatever the caller passed — so the assertions here are all on
 * tags, with the state folded into the name: `ts-file-trigger-open`,
 * `ts-team-placeholder`, `ts-file-panel`.
 *
 * Text queries would be answered by the wrong thing anyway. Five examples share
 * one scrolling page, every example's source is drawn as an ordinary text node,
 * and the snippets spell out the very labels the triggers show.
 *
 * Run with `mix e2e TreeSelectTest`.
 */
@RunWith(AndroidJUnit4::class)
class TreeSelectTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "with a tree in a panel beneath it"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun open(select: String): Boolean = tagged("$select-trigger-open")

    /**
     * Does this select's own value read [text]?
     *
     * [showing] cannot answer that: the code sample above each example prints
     * the same labels, so a page-wide query is true from the moment the page
     * mounts — true even if the trigger never followed the pick. The value node
     * carries its own tag, and unmerged, because the tappable trigger merges its
     * label away.
     */
    private fun valueShows(select: String, text: String): Boolean =
        compose.onAllNodes(
            hasTestTag("$select-value") and hasText(text, substring = true),
            useUnmergedTree = true,
        ).fetchSemanticsNodes().isNotEmpty()

    private fun caretIs(select: String, glyph: String): Boolean =
        compose.onAllNodes(
            hasTestTag("$select-caret") and hasText(glyph, substring = false),
            useUnmergedTree = true,
        ).fetchSemanticsNodes().isNotEmpty()

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    private fun tapTag(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(500)
    }

    private fun openIt(select: String) {
        if (!open(select)) {
            tapTag("$select-trigger-closed")
            compose.waitUntil(10_000) { open(select) }
        }
    }

    /**
     * Leave the page and come back, so every test starts from a fresh `mount/1`.
     *
     * The BEAM outlives the Activity, so which panel is open and what has been
     * picked both survive between tests — and unlike an open menu, a selection
     * cannot be un-picked by tapping it again. Re-entering the page is the only
     * way back to "nothing selected", so this does it unconditionally rather
     * than trying to undo whatever the last test left.
     */
    @Before
    fun openTreeSelectScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (showing("← Back") && guard++ < 3) {
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        compose.onAllNodesWithText("Tree Select", substring = false)[0]
            .performScrollTo()
            .performClick()
        compose.waitUntil(60_000) { showing(page) }
    }

    @Test
    fun the_panel_is_hidden_until_the_trigger_is_tapped() {
        require(!open("ts-file")) { "the page did not mount closed" }

        // Closed means the panel is not rendered at all, not merely hidden —
        // the web leaves the div in place with display:none.
        require(!tagged("ts-file-panel")) { "the panel exists while closed" }
        require(!tagged("ts-file-tree-row-lib")) { "the tree exists while closed" }

        openIt("ts-file")

        require(tagged("ts-file-panel")) { "opening rendered no panel" }
        require(tagged("ts-file-tree-row-lib")) { "the panel opened without its tree" }
    }

    @Test
    fun the_caret_follows_the_panel() {
        require(caretIs("ts-file", "▾")) { "a closed select is not pointing down" }

        openIt("ts-file")

        require(caretIs("ts-file", "▴")) { "the caret did not flip when the panel opened" }
    }

    @Test
    fun picking_a_file_fills_the_trigger_and_CLOSES() {
        openIt("ts-file")

        // Rows are addressable because the tree inside the panel carries its own
        // id — five panels sharing MishkaTree's default would collide.
        tapTag("ts-file-tree-row-lib/app.ex")

        // Both halves matter: a tree select that showed the choice and left the
        // panel hanging open over the rest of the page would not be a select.
        compose.waitUntil(10_000) { !open("ts-file") }
        require(valueShows("ts-file", "lib/app.ex")) { "the trigger did not show the new choice" }
        require(!tagged("ts-file-placeholder")) { "the trigger kept its placeholder tag" }
    }

    @Test
    fun expanding_a_branch_is_not_a_choice() {
        openIt("ts-file")

        tapTag("ts-file-tree-toggle-lib")

        // The tree owns expansion; only a selection closes the panel. Collapsing
        // a branch inside an open panel must leave the panel where it is.
        require(open("ts-file")) { "expanding a branch closed the panel" }
        require(tagged("ts-file-tree-lib-closed")) { "the branch did not collapse" }
        require(!tagged("ts-file-tree-row-lib/app.ex")) { "the collapsed branch kept its rows" }
    }

    @Test
    fun the_placeholder_gives_way_to_the_chosen_label() {
        // data-placeholder on the web; a muted ink here, which is why it is in
        // the tag instead.
        require(tagged("ts-team-placeholder")) { "an empty select lost its placeholder" }
        require(!tagged("ts-team-value")) { "an empty select claims to hold a value" }

        openIt("ts-team")
        tapTag("ts-team-tree-row-ana")

        compose.waitUntil(10_000) { tagged("ts-team-value") }
        require(!tagged("ts-team-placeholder")) { "the placeholder outlived the choice" }
        // The tree reports the node's VALUE ("ana"); the screen maps it to the
        // label, and the trigger is where you can tell which one arrived.
        require(valueShows("ts-team", "Ana")) { "the trigger shows the value, not the label" }
    }

    @Test
    fun a_disabled_select_cannot_open() {
        require(tagged("ts-off-trigger-disabled")) { "the disabled trigger is not marked as one" }

        tapTag("ts-off-trigger-disabled")
        Thread.sleep(500)

        // The screen's :ts_off_toggle clause is live — so what fails to happen
        // here is the component dropping the handler, not a missing one.
        require(!tagged("ts-off-trigger-open")) { "a disabled tree select opened" }
        require(!tagged("ts-off-panel")) { "a disabled tree select rendered its panel" }
    }

    @Test
    fun open_renders_the_panel_expanded_with_no_handler_at_all() {
        require(tagged("ts-pinned-panel")) { "open={true} did not render the panel" }
        require(open("ts-pinned")) { "the pinned trigger does not report itself open" }

        tapTag("ts-pinned-trigger-open")

        // Nothing dismisses a panel but the caller: with no on_toggle there is
        // no state to change, so this one stays open.
        require(tagged("ts-pinned-panel")) { "a select with no on_toggle closed itself" }
    }

    @Test
    fun a_long_selection_stays_on_one_line_and_leaves_the_caret_its_place() {
        // Measure the short label FIRST, while it is on screen: bounds are
        // clipped to the viewport, so anything below the fold reports zero and
        // the comparison would be against nothing.
        compose.onNodeWithTag("ts-off-value", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
        val short = boundsOf("ts-off-value")

        compose.onNodeWithTag("ts-long-value", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val value = boundsOf("ts-long-value")
        val caret = boundsOf("ts-long-caret")
        val root = boundsOf("ts-long")

        // Compose measures a Row's UNWEIGHTED children first, so before the
        // value was wrapped in a weighted Box a 47-character path took the whole
        // row and the caret was measured at zero width, off the end of it.
        require(caret.left >= value.right) { "the value overran the caret" }
        require(caret.right <= root.right + 1f) { "the caret was pushed outside the component" }

        // And it is ONE line: a Text squeezed narrower than its content wraps
        // character by character, which would make this several times taller
        // than the short label one example down.
        require(value.height <= short.height * 1.6f) {
            "the long label wrapped (${value.height}) rather than ellipsising (${short.height})"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Trigger and panel",
            "Placeholder",
            "Open from the start",
            "A long selection",
            "Disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
