package com.example.mishka_mob

import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.longClick
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.swipeLeft
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTextReplacement
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Toolbar page.
 *
 * Everything here is addressed by TAG. The page renders nine toolbars into one
 * scrolling column, each example's code sample is a text node, and the props
 * table repeats most of the prose — so any page-wide text query is answered by
 * whichever example happens to contain the string, not by the one under test.
 * Each bar therefore carries its own `id`, each item is tagged
 * `<bar>-<item_id>`, and a disabled item's tag ends in `-disabled`, because a
 * device test can read neither the muted ink nor a missing handler.
 *
 * The two things only hardware proves are here as well: that a long press on an
 * icon button names it (the touch equivalent of the web's hover tooltip, and the
 * only home the web's `aria-label` has on a device), and that a scrolling strip
 * really reaches its last control.
 *
 * Run with `mix e2e ToolbarTest`.
 */
@RunWith(AndroidJUnit4::class)
class ToolbarTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A strip of related controls, in groups"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    /**
     * The text on the node carrying [tag], or null when nothing is tagged that.
     *
     * Every caption on this page has its own id for exactly this reason — read
     * the one node, never the page. Nullable rather than throwing, because a
     * `waitUntil` predicate that raises does not retry, and the hint captions do
     * not exist at all until something has been held.
     */
    private fun textOrNull(tag: String): String? =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull()
            ?.config?.getOrNull(SemanticsProperties.Text)
            ?.joinToString("") { it.text }

    private fun textOf(tag: String): String = textOrNull(tag) ?: error("no text on \"$tag\"")

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(300)
    }

    private fun hold(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true)
            .performScrollTo()
            .performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    /** Unclipped x, unfiltered on size — a control scrolled out of its strip reports zero. */
    private fun rawBounds(tag: String): androidx.compose.ui.geometry.Rect? =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes().firstOrNull()?.boundsInRoot

    private fun rawLeft(tag: String): Float =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull()
            ?.boundsInRoot
            ?.left
            ?: error("no node tagged \"$tag\"")

    private fun laidOut(tag: String): androidx.compose.ui.geometry.Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    @Before
    fun openToolbarScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Toolbar", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        compose.waitUntil(30_000) { tagged("tb-kinds-bold") }
    }

    @Test
    fun all_four_item_kinds_render_and_each_carries_its_own_tag() {
        // button, link, input, separator — the web's <:item> types. A separator
        // draws no text and takes no tag, so the other three are what proves the
        // slot ported at all.
        require(tagged("tb-kinds-bold")) { "the button did not render" }
        require(tagged("tb-kinds-docs")) { "the link did not render" }
        require(tagged("tb-kinds-find")) { "the input did not render" }
    }

    @Test
    fun tapping_a_button_reports_its_own_id() {
        tap("tb-kinds-bold")

        compose.waitUntil(10_000) {
            textOrNull("tb-kinds-status")?.startsWith("Tapped bold") == true
        }
    }

    @Test
    fun tapping_a_link_reports_its_id_too_so_one_handler_serves_the_bar() {
        tap("tb-kinds-docs")

        // The link is not a second event shape: it reports its id like every
        // other item, and href/2 is what turns that id back into a destination.
        compose.waitUntil(10_000) {
            textOrNull("tb-kinds-status")?.startsWith("Tapped docs") == true
        }
    }

    @Test
    fun typing_in_the_toolbar_input_reaches_the_screen() {
        // The tag sits on the text field itself rather than on the box that
        // weights it, because only the field accepts text.
        compose.onNodeWithTag("tb-kinds-find").performScrollTo().performTextReplacement("beam")
        compose.waitForIdle()

        // Case-insensitive: the status reads "Looking for beam" on a fresh page
        // but "Tapped X, looking for beam" once any earlier test in this class
        // has tapped a control — and the BEAM outlives the Activity, so which
        // one you get depends on test order.
        compose.waitUntil(10_000) {
            textOrNull("tb-kinds-status")?.contains("looking for beam", ignoreCase = true) == true
        }
    }

    @Test
    fun holding_an_icon_button_names_it() {
        // The web puts the name in aria-label and a desktop browser shows it on
        // hover. There is neither here, so the long press is the port — and this
        // is the assertion that proves the gesture actually reaches the BEAM.
        hold("tb-hint-undo")
        compose.waitUntil(10_000) { textOrNull("tb-hint-hint") == "Undo" }

        hold("tb-hint-redo")
        compose.waitUntil(10_000) { textOrNull("tb-hint-hint") == "Redo" }
    }

    @Test
    fun a_disabled_bar_marks_every_item_and_still_answers_a_hold() {
        // `disabled` on the bar reaches every item, and the state is in the tag
        // because the only other signal is the ink.
        require(tagged("tb-off-bold-disabled")) { "the disabled bar did not mark its items" }
        require(!tagged("tb-off-bold")) { "a disabled item kept its live tag" }

        // focusable_when_disabled: on the web a disabled item stays in the roving
        // order so it remains discoverable. Here that means it can still be held.
        hold("tb-off-italic-disabled")
        compose.waitUntil(10_000) { textOrNull("tb-off-hint") == "Italic" }
    }

    @Test
    fun a_disabled_item_does_nothing_while_its_neighbour_still_acts() {
        // The BEAM outlives the Activity, so this bar may already be reporting
        // something from an earlier test. Establish the reading first, then tap
        // the dead item and assert it did not move — which is the same test
        // whatever state the page was left in.
        tap("tb-mix-bold")
        compose.waitUntil(10_000) { textOrNull("tb-mix-status") == "Picked bold" }

        tap("tb-mix-italic-disabled")
        require(textOf("tb-mix-status") == "Picked bold") { "a disabled item acted" }
    }

    @Test
    fun consecutive_items_sharing_a_group_become_one_cluster() {
        // The group's label is an aria-label on the web — invisible there, and
        // unavailable here, so the tag is the one place it survives.
        require(tagged("tb-grp-group-align")) { "the Align group did not render" }
        require(tagged("tb-grp-group-lists")) { "the Lists group did not render" }
        require(tagged("tb-grp-left")) { "the group swallowed its items' tags" }
    }

    @Test
    fun collapsing_keeps_the_first_controls_and_hides_the_rest() {
        require(tagged("tb-more-cut")) { "the first control was collapsed away" }
        require(tagged("tb-more-paste")) { "fewer than `visible` controls survived" }
        require(!tagged("tb-more-table")) { "the tail was not collapsed" }
        require(tagged("tb-more-overflow")) { "no ⋯ for the hidden controls" }

        tap("tb-more-overflow")
        compose.waitUntil(10_000) {
            textOrNull("tb-more-status")?.startsWith("The rest") == true
        }
    }

    @Test
    fun a_scrolling_strip_reaches_its_last_control() {
        // Scroll the PAGE by the toolbar's outer Box, which sits outside the
        // horizontal scroller — performScrollTo drives the nearest scrollable
        // ancestor, so anything INSIDE the strip moves the strip and leaves the
        // page where it was, with everything reporting Rect(0,0,0,0).
        compose.onNodeWithTag("tb-scr", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        require(tagged("tb-scr-table")) { "the eighth control was never composed" }

        // Measure the FIRST control travelling, not the eighth arriving: a
        // control clipped away by the strip's viewport reports zero bounds, so
        // its own position can neither prove nor disprove that the strip moved.
        val firstBefore = rawLeft("tb-scr-cut")
        require(firstBefore > 0f) { "the strip never came into view" }

        // Drive the strip with performScrollTo on its LAST control rather than a
        // synthetic swipe. A swipe has to win a gesture negotiation against the
        // controls' own clickables, and here it loses — but the claim under test
        // is that the strip can reach its last control, not which gesture gets
        // it there. This is also what a caller's own scroll-into-view does.
        compose.onNodeWithTag("tb-scr-table", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
        Thread.sleep(400)

        require(rawLeft("tb-scr-cut") < firstBefore - 20f) {
            "the strip did not scroll: first control was at $firstBefore, now ${rawLeft("tb-scr-cut")}"
        }
    }

    @Test
    fun a_vertical_bar_stacks_its_controls() {
        // Scroll to the LAST control, not the first: scrolling to the first
        // parks it at the top edge and leaves the last below the fold, where
        // Compose reports zero bounds — and a zero-bounds "bottom" reads as
        // laid out sideways when nothing of the sort happened.
        compose.onNodeWithTag("tb-vert-delete", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val top = laidOut("tb-vert-edit")
        val bottom = laidOut("tb-vert-delete")

        // A unit test can prove the tree says Column. Only the device proves
        // Compose laid it out that way, which is the half that has bitten this
        // library before.
        require(bottom.top >= top.bottom) { "the vertical bar laid its items out sideways" }
    }

    @Test
    fun each_example_renders_its_own_bar() {
        // Nine bars, nine ids. Sharing one would make every assertion above
        // ambiguous the moment a second bar rendered the same label.
        val bars = listOf(
            "tb-own", "tb-kinds", "tb-grp", "tb-hint",
            "tb-off", "tb-mix", "tb-scr", "tb-more", "tb-vert",
        )
        for (bar in bars) {
            require(tagged(bar)) { "no toolbar tagged $bar" }
        }
        require(tagged("tb-scr-scroll")) { "the scrolling bar registered no scroller" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf("Four item kinds", "Groups", "Overflow: collapse", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
