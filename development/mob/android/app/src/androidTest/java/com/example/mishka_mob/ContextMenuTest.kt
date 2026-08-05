package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
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
 * End-to-end tests for the Context Menu page.
 *
 * The web opens this on right-click, and its own keyboard notes name the touch
 * equivalent: a long press. That is what [holding_a_row_opens_its_actions]
 * asserts, and it is the thing the port shipped without — the moduledoc claimed
 * "Mob's Android bridge exposes no long-press gesture", when in fact the handler
 * was registered all along and only this bridge had not wired it.
 *
 * Run with `mix e2e ContextMenuTest`.
 */
@RunWith(AndroidJUnit4::class)
class ContextMenuTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "The actions for a particular row or object"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun hold(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true)
            .performScrollTo()
            .performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    @Before
    fun openContextMenuScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Context Menu", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's open menu is
        // still open. Holding a row TOGGLES it, so close whichever one is up.
        //
        // Tags, not text: the SECOND example on this page is a menu pinned
        // open={true} whose rows include "Rename", so any page-wide text query
        // is true from the moment the page mounts.
        for (row in listOf("report", "notes")) {
            if (!tagged("act-$row-rename")) continue
            hold("row-$row")
        }
    }

    @Test
    fun holding_a_row_opens_its_actions() {
        require(!tagged("act-report-rename")) { "this row's menu was already open" }

        hold("row-report")

        compose.waitUntil(10_000) { tagged("act-report-rename") }
        require(tagged("act-report-duplicate") && tagged("act-report-delete")) {
            "the menu opened but did not render its rows"
        }
    }

    @Test
    fun a_plain_tap_on_the_row_does_not_open_it() {
        // The long press must not swallow the ordinary tap — a row keeps doing
        // whatever it already did, which is why this is on_long_press rather
        // than a repurposed on_tap.
        compose.onNodeWithTag("row-report", useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(400)

        require(!tagged("act-report-rename")) { "a plain tap opened the context menu" }
    }

    @Test
    fun the_menu_names_the_row_it_belongs_to() {
        hold("row-report")

        // for_label is the whole reason this is not just a Menu: on a phone
        // there is no cursor to open at, so the subject has to be stated.
        compose.waitUntil(10_000) { showing("report.pdf") }
    }

    @Test
    fun holding_a_different_row_moves_the_menu() {
        hold("row-report")
        compose.waitUntil(10_000) { tagged("act-report-rename") }

        hold("row-notes")

        // Still one menu, now belonging to the other row.
        compose.waitUntil(10_000) { tagged("act-notes-rename") }
        require(!tagged("act-report-rename")) { "both rows' menus were open at once" }
    }

    @Test
    fun picking_an_action_reports_it_and_closes() {
        hold("row-report")
        compose.waitUntil(10_000) { tagged("act-report-rename") }

        compose.onNodeWithTag("act-report-rename", useUnmergedTree = true).performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        compose.waitUntil(10_000) { showing("rename on") }
        require(!tagged("act-report-duplicate")) { "the menu stayed open after an action" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf("Hold a row", "Without a subject", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
