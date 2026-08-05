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
 * End-to-end tests for the Accordion.
 *
 * The open set lives in the SCREEN — a composite is a pure function of its
 * props — so every one of these is a round trip: tap a header, the screen
 * recomputes the set, the panel appears in the next render. `mix test` proves
 * the transition is correct; only a device proves the trigger reaches it.
 *
 * [an_open_change_reports_the_direction] is the one that matters most. on_toggle
 * says which trigger was hit and nothing else, so "did it open or close" was a
 * question a screen could not answer without recomputing it — and the answer now
 * travels in the tag.
 *
 * Run with `mix e2e AccordionTest`.
 */
@RunWith(AndroidJUnit4::class)
class AccordionTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Knowing which way it went"

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
    fun openAccordionScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Accordion", substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun a_header_opens_its_panel() {
        // The body is only in the tree while the panel is open — a closed item
        // renders its trigger and nothing else, which is what makes this a real
        // assertion rather than a visibility check.
        tap("Is it styled?")
        compose.waitUntil(10_000) { showing("ships behaviour only") }
    }

    @Test
    fun one_at_a_time_closes_the_previous_panel() {
        // "a native port for Mob", not "A component library for Phoenix" — the
        // latter is in this example's own CODE SAMPLE, so it is on screen
        // whether or not the panel is open.
        tap("What is Mishka Chelekom?")
        compose.waitUntil(10_000) { showing("a native port for Mob") }

        tap("Is this real native UI?")
        compose.waitUntil(10_000) { showing("expands to SwiftUI") }

        require(!showing("a native port for Mob")) {
            "the first panel stayed open — multiple defaults to false"
        }
    }

    @Test
    fun an_open_change_reports_the_direction() {
        // The new half. Tapping the SAME trigger twice must log two different
        // things; on_toggle could only ever have said "shipping" both times.
        tap("Shipping")
        compose.waitUntil(10_000) { showing("shipping opened") }

        tap("Shipping")
        compose.waitUntil(10_000) { showing("shipping closed") }
    }

    @Test
    fun a_disabled_item_does_not_open() {
        tap("I am disabled")
        compose.waitForIdle()
        Thread.sleep(600)

        require(!showing("You should not be able to reach this text")) {
            "a disabled trigger opened its panel"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "One at a time",
            "Multiple open",
            "Knowing which way it went",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
