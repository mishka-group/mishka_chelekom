package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
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
 * End-to-end tests for the Menu page.
 *
 * A menu row says what it is with a glyph — ✓, ●, ▸ — and a device test cannot
 * attribute a character to a row. So the component appends the state to the
 * row's own tag: `<test_id>-checked` / `-unchecked` for a checkbox and radio,
 * `-open` / `-closed` for a submenu. Every assertion here reads those.
 *
 * The two that matter most are [ticking_a_checkbox_leaves_the_menu_open] —
 * a menu that dismissed on every tick would be unusable for multi-select — and
 * [a_submenu_reveals_its_rows_inline], because a flyout has nowhere to go on a
 * phone.
 *
 * Run with `mix e2e MenuTest`.
 */
@RunWith(AndroidJUnit4::class)
class MenuTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A list of actions revealed from a trigger"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    /** The menu is closed until its trigger is pressed, and closing is the screen's job. */
    private fun openMenu() {
        if (!tagged("row-edit")) {
            compose.onNodeWithTag("menu-trigger", useUnmergedTree = true)
                .performScrollTo()
                .performClick()
            compose.waitForIdle()
            Thread.sleep(500)
        }
    }

    @Before
    fun openMenuScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Menu", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        openMenu()
    }

    @Test
    fun a_closed_menu_renders_nothing_at_all() {
        // Close it via a command row, which is what closes the menu.
        tap("row-edit")

        require(!tagged("row-edit")) { "the menu stayed open after a command" }
        require(!tagged("row-grid-checked") && !tagged("row-grid-unchecked")) {
            "menu rows survived while the menu was closed"
        }
    }

    @Test
    fun picking_a_command_reports_its_own_id() {
        tap("row-dup")

        compose.waitUntil(10_000) { showing("Picked: dup") }
    }

    @Test
    fun ticking_a_checkbox_leaves_the_menu_open() {
        val before = tagged("row-grid-checked")

        tap(if (before) "row-grid-checked" else "row-grid-unchecked")

        // The tick flipped…
        require(tagged("row-grid-checked") != before) {
            "the checkbox did not toggle: checked was $before, still ${tagged("row-grid-checked")}"
        }
        // …and the menu is still up. A menu that dismissed on every tick could
        // never be used to set more than one thing.
        require(tagged("row-edit")) { "ticking a checkbox closed the menu" }
    }

    @Test
    fun a_radio_group_moves_its_selection() {
        require(tagged("row-name-checked") || tagged("row-date-checked")) {
            "neither radio is selected to begin with"
        }

        tap(if (tagged("row-date-checked")) "row-name-unchecked" else "row-date-unchecked")

        // Exactly one of the pair is selected — that is what a radio group means.
        val checked = listOf("row-name-checked", "row-date-checked").count { tagged(it) }
        require(checked == 1) { "expected one selected radio, found $checked" }
        require(tagged("row-edit")) { "choosing a radio closed the menu" }
    }

    @Test
    fun a_submenu_reveals_its_rows_inline() {
        require(tagged("row-share-closed")) { "the submenu did not start closed" }
        require(!tagged("row-copy")) { "a closed submenu rendered its rows" }

        tap("row-share-closed")

        // Inline, under the trigger — a flyout has nowhere to go on a phone.
        require(tagged("row-share-open")) { "the submenu trigger did not open" }
        require(tagged("row-copy") && tagged("row-email")) {
            "the submenu opened but revealed no rows"
        }

        // And its rows sit to the RIGHT of the trigger: they are indented.
        val trigger = compose.onAllNodesWithTag("row-share-open", useUnmergedTree = true)
            .fetchSemanticsNodes().first().boundsInRoot
        val nested = compose.onAllNodesWithTag("row-copy", useUnmergedTree = true)
            .fetchSemanticsNodes().first().boundsInRoot

        require(nested.left > trigger.left + 8f) {
            "the submenu rows are not indented: trigger=$trigger nested=$nested"
        }
        require(nested.top > trigger.top) { "the submenu rows are not below their trigger" }
    }

    @Test
    fun a_row_inside_a_submenu_still_reports_and_closes() {
        tap("row-share-closed")
        tap("row-copy")

        compose.waitUntil(10_000) { showing("Picked: copy") }
        require(!tagged("row-edit")) { "a submenu command did not close the menu" }
    }

    @Test
    fun a_disabled_row_does_nothing() {
        tap("row-archive")

        // Disabled wires no handler at all, so the menu neither reports nor closes.
        require(tagged("row-edit")) { "a disabled row closed the menu" }
        require(!showing("Picked: archive")) { "a disabled row reported a selection" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Every row kind",
            "Plain actions",
            "As a sheet",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
