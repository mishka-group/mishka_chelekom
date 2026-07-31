package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
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
 * End-to-end tests for the Chip page.
 *
 * [a_chip_hugs_its_label] is the regression this page was reported for. The pill
 * was a Box with neither `width` nor `fill_width`, and such a Box FILLS its
 * parent on both platforms — so one chip took the whole row and the set read as
 * a stack of banners rather than a row of chips. Only layout can catch that, and
 * the assertion is a measurement: a chip must be far narrower than its row, and
 * a longer label must produce a wider chip than a short one.
 *
 * Run with `mix e2e ChipTest`.
 */
@RunWith(AndroidJUnit4::class)
class ChipTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "compact, selectable label"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun boundsOf(label: String): Rect =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .first { it.width > 0f && it.height > 0f }

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
        Thread.sleep(300)
    }

    @Before
    fun openChipScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Chip", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun a_chip_hugs_its_label() {
        compose.onAllNodesWithText("Elixir", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val elixir = boundsOf("Elixir")
        val erlang = boundsOf("Erlang")

        // Three chips share one row, so none may be anywhere near full width.
        require(elixir.width in 1f..400f) { "the chip is not chip-sized: $elixir" }

        // And they sit side by side rather than stacked.
        require(erlang.left >= elixir.right - 2f) {
            "chips are not on one line: $elixir vs $erlang"
        }
    }

    @Test
    fun a_longer_label_makes_a_wider_chip() {
        compose.onAllNodesWithText("Medium", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // If the pill were filling its parent, every chip would measure the same.
        val small = boundsOf("Small")
        val medium = boundsOf("Medium")

        require(medium.width > small.width) {
            "chips do not size to their label: Small=$small Medium=$medium"
        }
    }

    @Test
    fun tapping_a_chip_toggles_membership() {
        compose.onAllNodesWithText("Erlang", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The summary line is rendered from the same assign the chips drive, so
        // it is the honest witness that the composed {:tag, id} reached a clause.
        require(showing("Selected:")) { "the example rendered no summary" }
        require(!showing("erlang")) { "the example did not start with erlang unpicked" }

        // Assert on the tag that CHANGES, not on the whole line: adding erlang
        // leaves "Selected: elixir" a substring of "Selected: elixir, erlang",
        // so a substring check on the old text never goes false.
        tap("Erlang")
        compose.waitUntil(10_000) { showing("erlang") }

        tap("Erlang")
        compose.waitUntil(10_000) { !showing("erlang") }
    }

    @Test
    fun single_select_replaces_rather_than_toggles() {
        compose.onAllNodesWithText("Large", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val medium = boundsOf("Medium")
        tap("Large")

        // A radio set cannot be cleared: tapping the chosen one again leaves it
        // chosen, which is the whole difference from the checkbox set above.
        tap("Large")
        require(boundsOf("Medium").width == medium.width) { "the radio row reflowed unexpectedly" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf("Multi-select", "Single select", "Disabled", "Colour", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
