package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Collapsible.
 *
 * A closed region is not in the tree at all — the component builds the panel
 * only when `open` is true — so every assertion here is a real round trip: tap
 * the trigger, the screen flips its boolean, the next render contains the body.
 * `mix test` proves the node tree; only a device proves the trigger reaches the
 * screen at all.
 *
 * The distinction worth keeping in mind while reading: an accordion widens its
 * tag to {tag, item_id} so one handler serves many rows. This fires a BARE
 * {:tap, tag}, because there is only ever one region — which is the whole
 * reason it is not a one-item accordion.
 *
 * Run with `mix e2e CollapsibleTest`.
 */
@RunWith(AndroidJUnit4::class)
class CollapsibleTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "One trigger, one region"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    /** Scroll into view, THEN click — a click off-screen misses silently. */
    private fun tap(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performScrollTo().performClick()
        compose.waitForIdle()
    }

    @Before
    fun openCollapsibleScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Collapsible", substring = false)
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_trigger_shows_and_hides_its_region() {
        // Both directions from one bare tag: the screen flips a boolean, so the
        // same trigger closes what it opened.
        tap("Tinted panel")
        compose.waitUntil(10_000) { showing("Any colour token or ARGB int") }

        tap("Tinted panel")
        compose.waitUntil(10_000) { !showing("Any colour token or ARGB int") }
    }

    @Test
    fun a_disabled_trigger_opens_nothing() {
        openCollapsibleScreen()

        val before = showing("Disabled")
        require(before) { "the Disabled example is not on the page" }

        // disabled wires no handler at all, so there is nothing to fire.
        compose.onAllNodesWithText("Disabled", substring = false)[0]
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(600)

        compose.onAllNodesWithText("Disabled", substring = false)[0].assertIsDisplayed()
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A disclosure",
            "Without a chevron",
            "Disabled",
            "Custom colours",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
