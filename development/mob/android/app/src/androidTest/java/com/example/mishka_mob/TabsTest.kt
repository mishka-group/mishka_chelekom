package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeLeft
import androidx.compose.ui.test.swipeRight
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Tabs page.
 *
 * A tab announces itself with a colour and a 2dp underline, and a device test
 * can read neither — so the component folds the state into its own test tag
 * (`<id>-tab-<tab>-active|idle|disabled`). That is what makes "which tab is
 * selected" answerable here at all.
 *
 * The headline test is [the_strip_drags_sideways_to_reach_tabs_past_the_edge].
 * The strip shipped as a bare Row, which cannot wrap, so the fifth tab was
 * drawn off-screen and was unreachable for good — invisible on this page until
 * an example had more tabs than fit.
 *
 * Run with `mix e2e TabsTest`.
 */
@RunWith(AndroidJUnit4::class)
class TabsTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A tab strip with one visible panel"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    /**
     * A node's x, unclipped and NOT filtered on a positive size — a tab scrolled
     * off the left of its strip reports zero bounds, and its position is exactly
     * what these tests measure.
     */
    private fun rawLeft(tag: String): Float =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull()
            ?.boundsInRoot
            ?.left
            ?: error("no node tagged \"$tag\"")

    /** Put a strip back at its leading edge, so a test starts from a known place. */
    private fun rewind(strip: String) {
        show(strip)
        repeat(6) {
            compose.onNodeWithTag("$strip-strip", useUnmergedTree = true)
                .performTouchInput { swipeRight() }
            compose.waitForIdle()
            Thread.sleep(200)
        }
    }

    /** Which tab of [strip] is active, by reading the state out of the tags. */
    private fun activeTab(strip: String, tabs: List<String>): String? =
        tabs.firstOrNull { tagged("$strip-tab-$it-active") }

    /** Whichever state tag a tab currently carries. */
    private fun stateOf(strip: String, tab: String): String =
        listOf("idle", "active", "disabled").firstOrNull { tagged("$strip-tab-$tab-$it") }
            ?: error("no tab tagged \"$strip-tab-$tab-*\"")

    /**
     * Bring a strip into view by scrolling to its PANEL.
     *
     * Not to a trigger: `performScrollTo` drives the nearest scrollable
     * ancestor, and a trigger's nearest scrollable ancestor is now the strip
     * itself — so scrolling to one slides the strip sideways and leaves the
     * page exactly where it was, with the whole component off-screen. The panel
     * sits outside the Scroll, so it moves the page.
     */
    private fun show(strip: String) {
        compose.onNodeWithTag("$strip-panel", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
    }

    private fun tapTab(strip: String, tab: String) {
        show(strip)

        // The trigger is a tappable Column, which MERGES its children's
        // semantics — hence useUnmergedTree on every tag query here.
        compose.onNodeWithTag("$strip-tab-$tab-${stateOf(strip, tab)}", useUnmergedTree = true)
            .performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    @Before
    fun openTabsScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Tabs", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun tapping_a_tab_selects_it_and_swaps_the_panel() {
        val tabs = listOf("overview", "specs", "support")

        tapTab("main", "specs")

        require(activeTab("main", tabs) == "specs") {
            "tapping Specs did not select it — active is ${activeTab("main", tabs)}"
        }
        // The panel is the tab's own children, so selecting must change what is
        // under the strip, not merely recolour the label.
        compose.waitUntil(10_000) { showing("Content-sized tabs") }

        tapTab("main", "support")
        require(activeTab("main", tabs) == "support") { "tapping Support did not select it" }
        compose.waitUntil(10_000) { showing("Each panel is the tab's own children") }
    }

    @Test
    fun exactly_one_tab_is_active_at_a_time() {
        val tabs = listOf("overview", "specs", "support")

        tapTab("main", "specs")

        val active = tabs.count { tagged("main-tab-$it-active") }
        require(active == 1) { "expected one active tab, found $active" }
    }

    @Test
    fun the_strip_drags_sideways_to_reach_tabs_past_the_edge() {
        // "settings" is the ninth tab, well past a phone's width. Before the
        // strip scrolled it was drawn off-screen and could never be tapped.
        rewind("many")

        val strip = boundsOf("many-strip")
        // Read whichever state the first tab carries: an earlier test in this
        // class may have left a different tab selected, and the BEAM outlives
        // the Activity.
        val first = "many-tab-inbox-${stateOf("many", "inbox")}"
        val firstBefore = rawLeft(first)

        compose.onNodeWithTag("many-strip", useUnmergedTree = true)
            .performTouchInput { swipeLeft() }
        compose.waitForIdle()
        Thread.sleep(600)

        // The strip moved: the first tab slid left, out of view.
        val firstAfter = rawLeft(first)
        require(firstAfter < firstBefore - 40f) {
            "the strip did not scroll: first tab was at $firstBefore, now $firstAfter"
        }

        // And the strip itself stayed put — it is the CONTENT that moved, not
        // the whole page.
        require(kotlin.math.abs(boundsOf("many-strip").left - strip.left) < 4f) {
            "the page scrolled instead of the strip"
        }
    }

    @Test
    fun a_tab_revealed_by_dragging_is_tappable_and_shows_its_panel() {
        rewind("many")

        repeat(4) {
            compose.onNodeWithTag("many-strip", useUnmergedTree = true)
                .performTouchInput { swipeLeft() }
            compose.waitForIdle()
            Thread.sleep(300)
        }

        // This is the whole point: a tab that was unreachable before now works.
        tapTab("many", "settings")

        require(tagged("many-tab-settings-active")) { "the last tab did not select" }
        compose.waitUntil(10_000) { showing("you had to drag to get here") }
    }

    @Test
    fun a_disabled_tab_does_not_select() {
        val tabs = listOf("overview", "locked", "specs")
        val before = activeTab("locked", tabs)

        require(tagged("locked-tab-locked-disabled")) { "the Locked tab is not marked disabled" }

        tapTab("locked", "locked")

        // Disabled wires no handler at all, so this is genuinely inert rather
        // than merely grey.
        require(activeTab("locked", tabs) == before) {
            "a disabled tab selected: $before -> ${activeTab("locked", tabs)}"
        }
        require(!tagged("locked-tab-locked-active")) { "the disabled tab became active" }
    }

    @Test
    fun each_strip_keeps_its_own_selection() {
        // The examples used to share assigns — two of them with different tab
        // ids — so picking in one silently reset another.
        tapTab("main", "support")
        tapTab("plain", "three")

        require(tagged("main-tab-support-active")) { "the first strip lost its selection" }
        require(tagged("plain-tab-three-active")) { "the second strip did not keep its own" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A tab strip",
            "Too many to fit",
            "Without the indicator",
            "Disabled tab",
            "Colour and spacing",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
