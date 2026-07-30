package com.example.mishka_mob

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

/**
 * End-to-end tests for the Rolling Number page.
 *
 * The component itself is one Text node — the interesting half is that it CANNOT
 * animate itself. `steps/3` is a pure function and the screen walks the sequence
 * on a timer, so the only honest device assertion is the round trip: tap, and the
 * number must arrive at the target. The easing is unit-tested off steps/3
 * instead (mishka_rolling_number_test.exs), where it is exact and not a race.
 *
 * String trap, as on every page in this gallery: each example prints its own
 * source, so "1234567" and "1,284" appear in the samples whether or not anything
 * rendered. A code sample is ONE Text node holding the whole snippet, so an
 * exact-match query never collides with it — every assertion here uses
 * substring = false. The "Roll to 1,284" button is likewise a longer exact
 * string than the rendered "1,284", so the two never confuse each other.
 *
 * Run with `mix e2e RollingNumberTest`.
 */
@RunWith(AndroidJUnit4::class)
class RollingNumberTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "eased by the screen"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Nodes reading EXACTLY [label] that were really laid out. */
    private fun placed(label: String): Int =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .count { it.boundsInRoot.width > 0f && it.boundsInRoot.height > 0f }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    private fun tap(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(250)
    }

    @Before
    fun openRollingNumberScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Rolling Number", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    /**
     * The BEAM outlives the Activity, so the page keeps whatever value an earlier
     * test left. Reset rather than assuming the mount default.
     */
    @Before
    @After
    fun resetTheNumber() {
        if (showing("Reset")) {
            tap("Reset")
            compose.waitForIdle()
        }
    }

    @Test
    fun the_number_rolls_all_the_way_to_its_target() {
        tap("Roll to 1,284")

        // steps/3 always lands exactly on the target — an eased walk that stopped
        // one step short would still look plausible on screen, which is why the
        // assertion is the exact landing value and not "it changed".
        compose.waitUntil(15_000) { placed("1,284") > 0 }
    }

    @Test
    fun it_counts_down_as_happily_as_up() {
        tap("Roll to 1,284")
        compose.waitUntil(15_000) { placed("1,284") > 0 }

        tap("Roll down to 42")
        compose.waitUntil(15_000) { placed("42") > 0 }
        require(placed("1,284") == 0) { "the number never left its previous target" }
    }

    @Test
    fun reset_returns_it_to_zero() {
        tap("Roll to 1,284")
        compose.waitUntil(15_000) { placed("1,284") > 0 }

        tap("Reset")
        compose.waitUntil(10_000) { placed("0") > 0 }
    }

    @Test
    fun grouping_renders_every_separator_the_description_promises() {
        // The page claims a comma, a space, none, and a preserved sign. All four
        // used to be claimed and only three rendered.
        for (rendered in listOf("1,234,567", "1 234 567", "1234567", "-98,765")) {
            compose.onAllNodesWithText(rendered, substring = false)[0].performScrollTo()
            compose.waitForIdle()
            require(placed(rendered) > 0) { "the grouping example never rendered $rendered" }
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Counting up",
            "Counting down",
            "Grouping",
            "Size and colour",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
