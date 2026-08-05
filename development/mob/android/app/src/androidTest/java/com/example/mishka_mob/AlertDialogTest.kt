package com.example.mishka_mob

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
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Alert Dialog page.
 *
 * The one rule that separates this from a plain Dialog is that its backdrop
 * does not dismiss it, and [the_backdrop_neither_dismisses_nor_leaks] is the
 * test for it. It asserts the stronger half too: the backdrop must SWALLOW the
 * tap. A Compose Box with a background but no pointer input paints over the
 * page without consuming a touch, so until the port wired an absorbing handler
 * a user could reach straight past the dim and press the button that opened the
 * dialog — which is precisely the ambiguity an alert dialog exists to remove.
 *
 * ## Tags, never page text
 *
 * Every example renders into one scrolling column and each prints its own
 * source, so "Discard changes?" is on screen from the moment the page mounts
 * whether or not anything is open. Only a testTag says which dialog is up,
 * which is why the component takes an `id`.
 *
 * Run with `mix e2e AlertDialogTest`.
 */
@RunWith(AndroidJUnit4::class)
class AlertDialogTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A confirmation modal whose backdrop will not dismiss it"

    // Every dialog on the page and the action that closes it. An open alert
    // dialog absorbs every tap, so one left behind takes the rest of the class
    // down with it — including the tap on ← Back.
    private val closers = listOf(
        "ad-confirm" to "ad-confirm-cancel-neutral",
        "ad-stubborn" to "ad-stubborn-ok-neutral",
        "ad-delete" to "ad-delete-cancel-neutral",
        "ad-slots" to "ad-slots-ok-neutral",
        "ad-chrome" to "ad-chrome-ok-neutral"
    )

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    /** Tap a tagged node WITHOUT scrolling — safe while an overlay is up. */
    /**
     * Click a node through the ROOT at its own coordinates.
     *
     * performClick() on the node itself silently did nothing for the trailing
     * action button — the handler never ran, verified by logging inside it —
     * while the leading one worked. Injecting at the measured centre through the
     * root sidesteps whatever hit-testing the overlay's z-stack was doing, and
     * it fails loudly (no bounds) rather than quietly if the node is not laid
     * out.
     */
    private fun tap(tag: String) {
        val at = compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull { it.boundsInRoot.width > 0f && it.boundsInRoot.height > 0f }
            ?.boundsInRoot
            ?.center
            ?: error("no laid-out node tagged \"$tag\"")

        compose.onRoot().performTouchInput { click(at) }
        compose.waitForIdle()
        Thread.sleep(400)
    }

    /** Scroll it into view first. Only safe while nothing covers the page. */
    private fun scrollAndTap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
        tap(tag)
    }

    private fun open(id: String, trigger: String) {
        scrollAndTap(trigger)
        compose.waitUntil(10_000) { tagged("$id-open") }
    }

    private fun closeAnythingOpen() {
        for ((id, closer) in closers) {
            if (tagged("$id-open")) tap(closer)
        }
    }

    @Before
    fun openAlertDialogScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        // Before anything else: an open dialog swallows the tap on ← Back too.
        closeAnythingOpen()

        // Leave and re-enter even when the page is already up. The BEAM outlives
        // the Activity and holds this page's assigns, so a test that deleted the
        // account would otherwise hand the next test an already-deleted one; a
        // fresh push re-runs mount/1 and puts every example back to its start.
        var guard = 0
        while (!showing(home) && guard++ < 4) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        compose.onAllNodesWithText("Alert Dialog", substring = false)[0]
            .performScrollTo()
            .performClick()
        compose.waitUntil(60_000) { showing(page) }
    }

    @After
    fun leaveNothingOpen() {
        closeAnythingOpen()
    }

    @Test
    fun the_backdrop_neither_dismisses_nor_leaks() {
        // Read the counter's tag while the page is still clear: the count lives
        // in the tag, because a device test cannot read a number off a label.
        compose.onNodeWithTag("ad-stubborn-leaks-0", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        open("ad-stubborn", "ad-stubborn-trigger")

        // The counter card sits directly under the backdrop, so clicking its
        // centre is a backdrop tap aimed at something that WOULD react.
        tap("ad-stubborn-leaks-0")

        require(tagged("ad-stubborn-open")) { "the backdrop dismissed an alert dialog" }
        require(tagged("ad-stubborn-leaks-0")) { "the tap went through the backdrop" }

        tap("ad-stubborn-ok-neutral")
        compose.waitUntil(10_000) { !tagged("ad-stubborn-open") }
    }

    @Test
    fun the_backdrop_is_inert_away_from_the_panel_too() {
        // The dialog above passes dismissible={true} and is refused it; this one
        // never asks. Between them the backdrop is proven inert either way. The
        // panel is centred, so 5% down the backdrop is dim and nothing else.
        open("ad-confirm", "ad-confirm-trigger")

        compose.onNodeWithTag("ad-confirm-backdrop-modal", useUnmergedTree = true)
            .performTouchInput { click(percentOffset(0.5f, 0.05f)) }
        compose.waitForIdle()
        Thread.sleep(500)

        require(tagged("ad-confirm-open")) { "a backdrop tap closed the dialog" }
        require(tagged("ad-confirm-choice-none")) { "the backdrop reported a choice" }
    }

    @Test
    fun close_true_fires_on_close() {
        open("ad-confirm", "ad-confirm-trigger")

        // Cancel carries close: true and no handler of its own — the port of the
        // web's data-close — so tapping it has to fire the dialog's on_close.
        tap("ad-confirm-cancel-neutral")

        compose.waitUntil(10_000) { !tagged("ad-confirm-open") }
        require(tagged("ad-confirm-choice-cancel")) { "on_close never ran" }
    }

    @Test
    fun an_action_with_its_own_handler_wins() {
        open("ad-confirm", "ad-confirm-trigger")

        tap("ad-confirm-go-primary")

        compose.waitUntil(10_000) { !tagged("ad-confirm-open") }
        require(tagged("ad-confirm-choice-discard")) { "the explicit on_tap lost to on_close" }
    }

    @Test
    fun the_destructive_action_says_so_in_its_tag() {
        require(tagged("ad-delete-state-intact")) { "the page did not start intact" }

        open("ad-delete", "ad-delete-trigger")

        // :error against :surface_raised is the only difference between these
        // two buttons on screen, and a fill is not something this test can read.
        require(tagged("ad-delete-go-danger")) { "the destructive button is untagged" }
        require(tagged("ad-delete-cancel-neutral")) { "the safe button is untagged" }

        tap("ad-delete-go-danger")

        compose.waitUntil(10_000) { !tagged("ad-delete-open") }
        require(tagged("ad-delete-state-gone")) { "the destructive action did nothing" }
    }

    @Test
    fun cancelling_the_destructive_dialog_deletes_nothing() {
        open("ad-delete", "ad-delete-trigger")

        tap("ad-delete-cancel-neutral")

        compose.waitUntil(10_000) { !tagged("ad-delete-open") }
        require(tagged("ad-delete-state-intact")) { "Cancel deleted the account" }
    }

    @Test
    fun a_title_made_of_nodes_still_carries_the_title_tag() {
        open("ad-slots", "ad-slots-trigger")

        // The web's <:title> and <:description> are slots, not strings. Ported,
        // they still have to be the tagged parts a test addresses.
        require(tagged("ad-slots-title")) { "the title slot lost its tag" }
        require(tagged("ad-slots-description")) { "the description slot lost its tag" }
        require(tagged("ad-slots-footer")) { "the actions slot lost its tag" }

        tap("ad-slots-ok-neutral")
        compose.waitUntil(10_000) { !tagged("ad-slots-open") }
    }

    @Test
    fun every_data_part_became_a_test_tag() {
        open("ad-chrome", "ad-chrome-trigger")

        // Dialog's part names, not a set of this component's own: an alert
        // dialog IS a dialog, and a test should not have to know which it has.
        val parts = listOf(
            "open", "backdrop-modal", "panel",
            "title", "description", "content", "footer"
        )
        for (part in parts) {
            require(tagged("ad-chrome-$part")) { "no testTag for the $part part" }
        }

        tap("ad-chrome-ok-neutral")

        // -open exists ONLY while open, so its absence IS the closed state —
        // there is no second tag to look for. The panel goes with it.
        compose.waitUntil(10_000) { !tagged("ad-chrome-open") }
        require(!tagged("ad-chrome-panel")) { "the panel outlived the dialog" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Confirm or cancel",
            "The backdrop will not dismiss it",
            "Destructive",
            "A title that is not a string",
            "Its own chrome",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
