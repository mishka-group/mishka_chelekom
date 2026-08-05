package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Color Swatch surface component.
 *
 * Loading Overlay and Skeleton used to live here too; each has its own class
 * now (LoadingOverlayTest, SkeletonTest), named after what it covers.
 *
 * ## Why these three together
 *
 * Each asserts something the Elixir suite structurally cannot.
 *
 * The swatch's selection is a round trip through the screen — the tree shows
 * `on_tap: {pid, {:sw_pick, :blue}}` whether or not anything receives it.
 *
 * The overlay's whole purpose is that it EATS the taps aimed at what it covers,
 * and "a tap did not happen" is a statement about hit-testing, not about nodes.
 * [the_overlay_absorbs_taps_aimed_at_what_it_covers] is the one that matters.
 *
 * And the skeleton's short last line is a Row weight — 60% of a parent whose
 * width nothing in Elixir knows. Only real layout can say whether it landed.
 *
 * Run with `mix e2e SurfaceTest`.
 */
@RunWith(AndroidJUnit4::class)
class SurfaceTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"

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

    private fun openPage(card: String, marker: String) {
        compose.waitUntil(90_000) { showing(home) || showing(marker) || showing("← Back") }

        var guard = 0
        while (!showing(marker) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(marker)) {
            compose.onNodeWithText(card, substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(marker) }
        }
    }

    /**
     * Scroll the first node matching [label] into view, then click it.
     *
     * Both halves matter. performClick fires at the node's coordinates whether
     * or not those are on screen, so clicking something below the fold misses
     * silently — no exception, no event.
     */
    private fun tap(label: String, exact: Boolean = true) {
        compose.onAllNodesWithText(label, substring = !exact)[0].performScrollTo().performClick()
        compose.waitForIdle()
    }

    /**
     * Click without scrolling first, and without waiting for idle.
     *
     * Both are unusable while the overlay is up: its indicator is an
     * INDETERMINATE Progress, which animates forever, so Compose never reports
     * idle and performScrollTo blocks until Espresso's timeout. The target is
     * already on screen at that point — it is the thing the scrim covers.
     */
    private fun tapWhileBusy(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performClick()
        Thread.sleep(600)
    }

    // ── Color Swatch ─────────────────────────────────────────────────────────

    @Test
    fun picking_a_swatch_reaches_the_screen_and_comes_back() {
        openPage("Color Swatch", "transparency checkerboard")

        // The readout under the palette is rendered from the assign the tap
        // sets, so this is the round trip and not a local highlight. A swatch
        // carries no text at all, so it is reached by its :id — which Mob turns
        // into a native testTag.
        compose.waitUntil(10_000) { showing("Violet") }

        compose.onNodeWithTag("swatch-green").performScrollTo().performClick()
        compose.waitUntil(10_000) { showing("Green") }

        require(!showing("Violet")) { "the old pick is still shown" }

        compose.onNodeWithTag("swatch-red").performScrollTo().performClick()
        compose.waitUntil(10_000) { showing("Red") }
    }

    @Test
    fun the_swatch_page_renders_every_example_and_the_props_table() {
        openPage("Color Swatch", "transparency checkerboard")

        for (heading in listOf("A palette", "Disabled", "Transparency", "Shapes and sizes", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }

    // ── Loading Overlay ──────────────────────────────────────────────────────

    @Test
    fun the_overlay_absorbs_taps_aimed_at_what_it_covers() {
        openPage("Loading Overlay", "absorbs taps")

        // Tap the card underneath: the count rises.
        tap("Order #1042")
        compose.waitUntil(10_000) { showing("Tapped once") }

        // Now cover it, and tap the same place again.
        //
        // The BUTTON's label is the visibility signal, not the word "Saving…":
        // that appears in this example's own code sample as well, so it is on
        // screen whether or not the scrim is.
        tap("Start saving")
        compose.waitUntil(10_000) { showing("Finish") }

        tapWhileBusy("Order #1042")

        require(showing("Tapped once")) {
            "the count moved through the scrim — the overlay is not absorbing taps"
        }

        // And it starts working again once the overlay lifts.
        tapWhileBusy("Finish")
        compose.waitUntil(10_000) { showing("Start saving") }
        tap("Order #1042")
        compose.waitUntil(10_000) { showing("Tapped 2 times") }
    }

    @Test
    fun an_invisible_overlay_covers_nothing() {
        openPage("Loading Overlay", "absorbs taps")

        compose.onAllNodesWithText("the overlay below is invisible", substring = true)[0]
            .performScrollTo()
            .assertIsDisplayed()
    }
}
