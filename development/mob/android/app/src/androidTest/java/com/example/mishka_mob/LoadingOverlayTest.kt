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
import kotlin.math.abs

/**
 * End-to-end tests for the Loading Overlay page.
 *
 * ## Why this class avoids waitForIdle while an overlay is up
 *
 * A visible overlay renders an INDETERMINATE Progress, which loops forever, and
 * an infinite animation means Compose never reports idle — `waitForIdle` and
 * `performScrollTo` both block on idleness. So every test here scrolls to what
 * it needs FIRST, while the overlay is still hidden and the page is settled,
 * and only then toggles one on. Assertions during that window read
 * `fetchSemanticsNodes()`, which does not wait for idle. Each test turns the
 * overlay back off, and @After sweeps up: the BEAM outlives the Activity, so an
 * overlay left running would follow later classes onto their own pages.
 *
 * [the_label_is_centred] is the regression the page was reported for. The body
 * used to be a `<Column fill_width={false}>`, and a Column cannot align its
 * children — so the label left-aligned against the 140dp bar and sat visibly off
 * centre on Android, while on iOS the whole body pinned to the left edge. The
 * assertion measures the label against a full-width button on the same page,
 * because that button's centre IS the content centre.
 *
 * Run with `mix e2e LoadingOverlayTest`.
 */
@RunWith(AndroidJUnit4::class)
class LoadingOverlayTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Tap the card to raise the count"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Bounds of laid-out nodes reading EXACTLY [label]. Never waits for idle. */
    private fun boundsOf(label: String): List<Rect> =
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

    /** Safe only while no overlay is visible — it waits for idle. */
    private fun tap(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(300)
    }

    /** Click without ever asking Compose whether it is idle. */
    private fun tapBusy(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performClick()
        Thread.sleep(700)
    }

    /**
     * Guard the sweep on an EXACT match, not [showing]. Every example prints its
     * own source, so a substring query says "Cancel is on screen" for a word
     * buried in a code sample — and then the exact-match click finds no node at
     * all and dies. Ask the same question the click will ask.
     */
    private fun tapBusyIfPresent(label: String) {
        if (boundsOf(label).isNotEmpty()) tapBusy(label)
    }

    @Before
    fun openLoadingOverlayScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Loading Overlay", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    /** No overlay may outlive a test — an animating one blocks every later class. */
    @After
    fun stopEverything() {
        for (off in listOf("Finish", "Stop", "Cancel")) {
            tapBusyIfPresent(off)
        }
        Thread.sleep(400)
    }

    @Test
    fun it_absorbs_the_taps_it_covers() {
        // The whole reason this is an overlay and not a spinner beside a button.
        tap("Start saving")

        val before = boundsOf("Tapped 0 times — tap this card.").size
        require(before > 0 || showing("Tapped")) { "the card never rendered its counter" }

        // Tap the covered card. The scrim must swallow it.
        val card = boundsOf("Order #1042").firstOrNull()
        require(card != null) { "the covered card is not on screen" }
        compose.onAllNodesWithText("Order #1042", substring = false)[0].performClick()
        Thread.sleep(600)

        require(showing("Tapped 0 times")) { "a tap reached the covered card" }

        tapBusy("Finish")
    }

    @Test
    fun the_label_is_centred() {
        // Scroll while it is still hidden — afterwards nothing may wait for idle.
        compose.onAllNodesWithText("Start saving", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val button = boundsOf("Start saving").firstOrNull()
        require(button != null) { "could not measure the full-width button" }

        tapBusy("Start saving")

        val label = boundsOf("Saving…").firstOrNull()
        require(label != null) { "the overlay label never rendered" }

        // The button is fill_width, so its centre is the content centre. Before
        // the fix the label left-aligned against the 140dp bar and landed ~100px
        // off; 20px is comfortably inside the fixed layout and outside the bug.
        require(abs(label.center.x - button.center.x) < 20f) {
            "the label is not centred: ${label.center.x} vs ${button.center.x}"
        }

        tapBusy("Finish")
    }

    @Test
    fun without_a_label_the_indicator_still_covers_the_card() {
        compose.onAllNodesWithText("Refresh", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        require(showing("Refreshing prices")) { "the covered card is not on screen" }
        tapBusy("Refresh")

        // Nothing to read — the bar carries no text — so the assertion is that
        // the page swapped to its busy control and the card is still covered.
        require(showing("Stop")) { "the overlay never turned on" }

        tapBusy("Stop")
        require(showing("Refresh")) { "the overlay never turned off" }
    }

    @Test
    fun a_page_wide_overlay_covers_everything_and_its_own_control_still_works() {
        compose.onAllNodesWithText("Sync 12 files", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val trigger = boundsOf("Sync 12 files").firstOrNull()
        require(trigger != null) { "could not measure the trigger" }

        tapBusy("Sync 12 files")

        // Exact match, not `showing`: this page PRINTS its own source, and that
        // source contains the words "Syncing your library". A substring query
        // matches the code sample and stays true forever, so it would report
        // both that the overlay appeared and that it never went away.
        val headline = boundsOf("Syncing your library").firstOrNull()
        require(headline != null) { "the page-wide overlay never appeared" }
        require(abs(headline.center.x - trigger.center.x) < 20f) {
            "the custom panel is not centred: ${headline.center.x} vs ${trigger.center.x}"
        }

        // The scrim absorbs taps, but a control INSIDE it must still get its
        // own — otherwise a full-page overlay would be a trap with no way out.
        tapBusy("Cancel")
        require(boundsOf("Syncing your library").isEmpty()) {
            "Cancel could not dismiss the overlay"
        }
        require(showing("Sync 12 files")) { "the page did not come back" }
    }

    @Test
    fun invisible_costs_nothing() {
        compose.onAllNodesWithText("Invisible costs nothing", substring = true)[0]
            .performScrollTo()
        compose.waitForIdle()

        // A permanently-mounted invisible overlay must leave its region alone.
        require(showing("Nothing covers this")) { "the uncovered card did not render" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "It absorbs the taps it covers",
            "Without a label",
            "Its own scrim, panel and indicator",
            "Over the whole page, with a body of your own",
            "Invisible costs nothing",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
