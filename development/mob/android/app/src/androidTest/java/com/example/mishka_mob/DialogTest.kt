package com.example.mishka_mob

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertHasClickAction
import androidx.compose.ui.test.assertHasNoClickAction
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Dialog page.
 *
 * Every assertion here reads a testTag, never page text. The page is one
 * scrolling column of seven examples and each example ships a `code:` sample,
 * so "on_open_change" and "dismissible" are text nodes several times over — a
 * page-wide text query is answered by whichever sample happens to contain the
 * string, not by the dialog under test.
 *
 * The tags come from the component's `id`: `<id>-open` exists only while the
 * dialog is up (presence IS the open state), the backdrop names whether it dims
 * (`-backdrop-modal` / `-backdrop-plain`, since `modal` is otherwise a
 * difference of colour alone), and a disabled trigger says so in its own tag.
 *
 * Each example owns a SEPARATE assign and a separate id, which is what lets
 * [each_example_owns_its_own_dialog] mean anything.
 *
 * Run with `mix e2e DialogTest`.
 */
@RunWith(AndroidJUnit4::class)
class DialogTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A centred modal over a dimmed backdrop"

    private val dialogs = listOf(
        "dlg-basic",
        "dlg-slots",
        "dlg-dismiss",
        "dlg-forced",
        "dlg-plain",
        "dlg-tinted",
        "dlg-disabled",
    )

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

    private fun settle() {
        compose.waitForIdle()
        Thread.sleep(500)
    }

    /** A trigger lives in the scrolling page, so it has to be brought into view. */
    private fun tapTrigger(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        settle()
    }

    /** Anything inside the overlay is already on screen — and has no scrollable ancestor. */
    private fun tapOverlay(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performClick()
        settle()
    }

    /**
     * The backdrop spans the window and the panel is drawn on top of it, dead
     * centre — so `performClick` on the backdrop node aims at its own centre and
     * lands on the PANEL, which absorbs taps by design. Inject through the root
     * in the upper eighth instead, which is backdrop and nothing else.
     *
     * A fraction of the height, not a fixed pixel offset: a few pixels down is
     * still the theme switcher's row. Only ever aimed at a backdrop that HAS a
     * handler — an inert one has no hit shape, so the touch would sail through
     * to whatever the page has parked underneath.
     */
    private fun tapBackdrop(tag: String) {
        val b = boundsOf(tag)
        compose.onRoot().performTouchInput { click(Offset(b.center.x, b.top + b.height * 0.12f)) }
        settle()
    }

    private fun backdropOf(id: String): String =
        if (tagged("$id-backdrop-modal")) "$id-backdrop-modal" else "$id-backdrop-plain"

    private fun openDialog(id: String) {
        if (!tagged("$id-open")) tapTrigger("$id-trigger")
        compose.waitUntil(10_000) { tagged("$id-open") }
    }

    /**
     * The BEAM outlives the Activity, so a dialog an earlier test opened is
     * still up — and while it is, its backdrop covers every trigger on the page.
     */
    private fun closeAnyOpen() {
        for (id in dialogs) {
            if (!tagged("$id-open")) continue
            if (tagged("$id-close")) tapOverlay("$id-close") else tapBackdrop(backdropOf(id))
        }
    }

    @Before
    fun openDialogScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Dialog", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        closeAnyOpen()
    }

    @Test
    fun a_closed_dialog_renders_nothing_at_all() {
        for (id in dialogs) {
            require(!tagged("$id-open")) { "$id was still open after the reset" }
            require(!tagged("$id-panel")) { "$id drew a panel while closed" }
            require(!tagged("$id-title")) { "$id drew a title while closed" }
        }
    }

    @Test
    fun opening_a_dialog_renders_the_whole_anatomy() {
        openDialog("dlg-basic")

        // Every part the web names with a data-part, named here with a tag.
        for (part in listOf("panel", "backdrop-modal", "title", "description", "content", "footer")) {
            require(tagged("dlg-basic-$part")) { "the dialog opened without its $part" }
        }
    }

    @Test
    fun tapping_the_backdrop_dismisses_and_reports_the_new_state() {
        openDialog("dlg-dismiss")

        compose.onNodeWithTag("dlg-dismiss-backdrop-modal", useUnmergedTree = true)
            .assertHasClickAction()
        tapBackdrop("dlg-dismiss-backdrop-modal")

        compose.waitUntil(10_000) { !tagged("dlg-dismiss-open") }
        // on_open_change carries the new state, exactly like the web's {open}.
        // The readout folds it into its own tag: the words "on_open_change"
        // also appear in the code sample above it, so text proves nothing.
        require(tagged("dlg-dismiss-readout-false")) {
            "the backdrop closed the dialog but on_open_change reported nothing"
        }
    }

    @Test
    fun an_inert_backdrop_leaves_the_choice_to_the_footer() {
        openDialog("dlg-forced")

        // Asserted rather than tapped: dismissible: false wires no handler at
        // all, so the backdrop has no hit shape and an injected touch would sail
        // through to whatever the scrolling page has parked underneath — which,
        // if that happened to be another example's trigger, would open a SECOND
        // dialog over this one and make the rest of the test meaningless.
        compose.onNodeWithTag("dlg-forced-backdrop-modal", useUnmergedTree = true)
            .assertHasNoClickAction()
        require(tagged("dlg-forced-open")) { "the forced dialog closed on its own" }

        // The footer is the only way out, which is the whole point.
        tapOverlay("dlg-forced-close")
        compose.waitUntil(10_000) { !tagged("dlg-forced-open") }
    }

    @Test
    fun a_tap_on_the_panel_does_not_fall_through_to_the_backdrop() {
        openDialog("dlg-basic")

        // Inside the panel's own padding, above everything the caller put there
        // — and mid-width, because `corner_radius` clips the corners out of the
        // hit shape too, so a touch near one would fall straight through.
        val panel = boundsOf("dlg-basic-panel")
        compose.onRoot().performTouchInput { click(Offset(panel.center.x, panel.top + 8f)) }
        settle()

        require(tagged("dlg-basic-open")) { "the dialog dismissed itself through its own panel" }
    }

    @Test
    fun a_non_modal_dialog_names_its_undimmed_backdrop() {
        openDialog("dlg-plain")

        // modal={false} differs from the default by nothing but the scrim's
        // alpha, and a device test cannot read a colour — so it reads the tag.
        require(tagged("dlg-plain-backdrop-plain")) { "the non-modal backdrop is missing" }
        require(!tagged("dlg-plain-backdrop-modal")) { "modal={false} still dimmed the page" }
    }

    @Test
    fun the_slot_form_builds_the_same_parts_as_the_string_props() {
        openDialog("dlg-slots")

        for (part in listOf("title", "description", "content", "footer")) {
            require(tagged("dlg-slots-$part")) { "the slot form skipped its $part" }
        }
    }

    @Test
    fun a_disabled_trigger_opens_nothing() {
        require(tagged("dlg-disabled-trigger-disabled")) { "the disabled trigger is not tagged" }
        require(!tagged("dlg-disabled-trigger")) { "a disabled trigger kept the enabled tag" }

        compose.onNodeWithTag("dlg-disabled-trigger-disabled", useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        settle()

        require(!tagged("dlg-disabled-open")) { "a disabled trigger opened the dialog" }
    }

    @Test
    fun each_example_owns_its_own_dialog() {
        openDialog("dlg-basic")

        require(!tagged("dlg-tinted-open")) { "one trigger opened two dialogs" }
        require(!tagged("dlg-forced-open")) { "one trigger opened two dialogs" }

        tapOverlay("dlg-basic-close")
        compose.waitUntil(10_000) { !tagged("dlg-basic-open") }

        openDialog("dlg-tinted")
        require(!tagged("dlg-basic-open")) { "the previous example's dialog came back" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "The whole anatomy",
            "Slots, not strings",
            "Tap outside to dismiss",
            "Forced choice",
            "Not modal",
            "Custom chrome",
            "A disabled trigger",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
