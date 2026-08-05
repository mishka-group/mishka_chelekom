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
 * End-to-end tests for the Preview Card page.
 *
 * The web component is a trigger plus a popup, and the trigger is the half this
 * port shipped without: it drew the card and left every caller to invent what
 * opened it. On the web that is a hover; on a touch screen it is a long press,
 * which is what [holding_a_name_reveals_its_card] asserts.
 *
 * Everything here reads TAGS. Every example on this page renders into one
 * scrolling column, the code samples are text nodes too, and the states this
 * component has — open, which side it took, where the arrow sits — are a
 * position and a colour, neither of which a device test can read. So the
 * component folds them into its tags instead: `<id>-open`, `<id>-popup-<side>`,
 * `<id>-arrow-<align>`.
 *
 * Run with `mix e2e PreviewCardTest`.
 */
@RunWith(AndroidJUnit4::class)
class PreviewCardTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Hold a name to reveal its card of detail"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun hold(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    // performScrollTo() throws inside a Popup — "Semantic Node has no parent
    // layout with a Scroll SemanticsAction" — because the panel renders in its
    // own window, which is not inside the page's scroll. It is only ever a
    // convenience (bring the node on screen first), so attempt it and carry on.
    private fun tap(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    @Before
    fun openPreviewCardScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Preview Card", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's card is still
        // open. Holding a trigger TOGGLES it, so shut whichever one is up —
        // by tag, because the second and fourth examples are pinned open and
        // any page-wide text query is answered by one of those.
        for (id in listOf("pc-elixir", "pc-phoenix")) {
            if (tagged("$id-open")) hold("$id-trigger")
        }
        if (tagged("pc-top-popup-top")) hold("pc-top-trigger")
        if (tagged("pc-side-popup-right")) hold("pc-side-trigger")
    }

    @Test
    fun holding_a_name_reveals_its_card() {
        require(!tagged("pc-elixir-open")) { "this card was already open" }

        hold("pc-elixir-trigger")

        compose.waitUntil(10_000) { tagged("pc-elixir-open") }
        require(!tagged("pc-elixir-closed")) { "the root still claims to be closed" }

        // The popup and every part of it, so a broken header cannot hide behind
        // a root that merely says "open".
        for (part in listOf("popup-bottom", "avatar", "title", "subtitle", "description", "footer")) {
            require(tagged("pc-elixir-$part")) { "the card opened without its $part" }
        }
    }

    @Test
    fun a_plain_tap_does_not_reveal_it() {
        // The long press must not swallow the ordinary tap: the web's trigger is
        // a link, and tapping a link still follows it. That is why on_tap and
        // on_hold are separate props rather than one repurposed handler.
        //
        // Tap the other one first: the BEAM outlives the Activity, so asserting
        // a tag that an earlier test may already have set would pass without
        // anything happening here.
        tap("pc-elixir-trigger")
        compose.waitUntil(10_000) { tagged("pc-visited-pc-elixir") }

        tap("pc-phoenix-trigger")

        compose.waitUntil(10_000) { tagged("pc-visited-pc-phoenix") }
        require(!tagged("pc-phoenix-open")) { "a plain tap opened the card" }
        require(!tagged("pc-elixir-open")) { "a plain tap opened the card" }
    }

    @Test
    fun holding_another_name_moves_the_card() {
        hold("pc-elixir-trigger")
        compose.waitUntil(10_000) { tagged("pc-elixir-open") }

        hold("pc-phoenix-trigger")

        // One `open` assign, so there is still exactly one card — it belongs to
        // the other name now.
        compose.waitUntil(10_000) { tagged("pc-phoenix-open") }
        require(!tagged("pc-elixir-open")) { "both cards were open at once" }
    }

    @Test
    fun holding_it_again_closes_it() {
        hold("pc-elixir-trigger")
        compose.waitUntil(10_000) { tagged("pc-elixir-open") }

        hold("pc-elixir-trigger")

        // Nothing here closes the card but the screen — there is no pointer to
        // move away, so the hold has to toggle.
        compose.waitUntil(10_000) { tagged("pc-elixir-closed") }
        require(!tagged("pc-elixir-popup-bottom")) { "the popup outlived the open state" }
    }

    @Test
    fun the_trigger_survives_the_closed_state() {
        // The popup is what disappears; the trigger is what you hold, so it has
        // to be there when there is nothing to see.
        require(tagged("pc-elixir-trigger")) { "the trigger vanished with the card" }
        require(tagged("pc-elixir-closed")) { "the closed root carries no tag" }
    }

    @Test
    fun the_side_and_the_alignment_are_in_the_tags() {
        hold("pc-elixir-trigger")
        compose.waitUntil(10_000) { tagged("pc-elixir-arrow-center") }

        hold("pc-top-trigger")
        compose.waitUntil(10_000) { tagged("pc-top-popup-top") }
        require(tagged("pc-top-arrow-end")) { "align={:end} did not reach the arrow" }

        hold("pc-side-trigger")
        compose.waitUntil(10_000) { tagged("pc-side-popup-right") }
        require(tagged("pc-side-arrow-start")) { "align={:start} did not reach the arrow" }

        // Each example owns its own assign, so opening one leaves the others as
        // they were — a shared assign would make every assertion above true of
        // whichever card happened to be last.
        require(tagged("pc-top-popup-top")) { "opening one card closed another" }
    }

    @Test
    fun the_footer_belongs_to_the_card_and_acts() {
        hold("pc-elixir-trigger")
        compose.waitUntil(10_000) { tagged("pc-elixir-footer") }

        // An earlier run may have left it following — the BEAM outlives the
        // Activity, and the follow state is a screen assign like any other.
        if (tagged("pc-elixir-follow-on")) {
            tap("pc-elixir-follow-on")
            compose.waitUntil(10_000) { tagged("pc-elixir-follow-off") }
        }

        tap("pc-elixir-follow-off")

        // "Follow" and "Following" differ by a word and a colour, so the button
        // states its own state in its tag.
        compose.waitUntil(10_000) { tagged("pc-elixir-follow-on") }
        require(tagged("pc-followed-pc-elixir")) { "the footer tap never reached the screen" }

        tap("pc-elixir-follow-on")
        compose.waitUntil(10_000) { tagged("pc-elixir-follow-off") }
    }

    @Test
    fun the_pinned_card_needs_no_trigger_at_all() {
        // Leave the trigger out and it is the popup alone — the shape this port
        // used to be, still supported.
        require(tagged("pc-static-popup-bottom")) { "the pinned card did not render" }
        require(tagged("pc-static-avatar")) { "an image avatar did not render" }
        require(tagged("pc-bare-popup-bottom")) { "a card of nothing but a title did not render" }
        require(!tagged("pc-static-trigger")) { "a card with no trigger grew one" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Hold a name",
            "Above the trigger",
            "Beside the trigger",
            "Pinned open",
            "Scroller",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
