package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
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
 * End-to-end tests for the Toggle page.
 *
 * [a_toggle_hugs_its_label] is the reported regression. The button is a Box, and
 * a Box given neither a width nor `fill_width` FILLS its parent — so every
 * toggle rendered as one full-width slab and a toolbar of them was impossible.
 * The chip fell into the identical trap one component earlier. Only layout can
 * catch it: the node tree is perfectly correct either way, so this measures.
 *
 * Pressed differs from idle by FILL COLOUR alone, and colour is not in the
 * accessibility tree, so the state rides in the testTag: `tg-bold-pressed` /
 * `tg-bold-idle`.
 *
 * Run with `mix e2e ToggleTest`.
 */
@RunWith(AndroidJUnit4::class)
class ToggleTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "button that stays pressed"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** useUnmergedTree — a tappable Box merges its label's semantics over its own tag. */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun stateOf(prefix: String): String? =
        listOf("pressed", "idle").firstOrNull { tagged("$prefix-$it") }

    /** Bounds of a toggle whichever state it is in. */
    private fun toggleBounds(prefix: String): Rect =
        boundsOf("$prefix-" + (stateOf(prefix) ?: error("\"$prefix\" is untagged")))

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    private fun boundsOfText(label: String): Rect =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node reading \"$label\"")

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
    fun openToggleScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            // Exact match: "Toggle" must not open the "Toggle Group" card.
            compose.onAllNodesWithText("Toggle", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun a_toggle_hugs_its_label() {
        compose.onAllNodesWithText("Bold", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val bold = toggleBounds("tg-bold")
        val italic = toggleBounds("tg-italic")

        // Three buttons share one row, so none may be anywhere near full width.
        require(bold.width in 1f..400f) { "the toggle is not button-sized: $bold" }

        // And they sit side by side rather than each taking its own line — which
        // is exactly what a filling Box produced.
        require(italic.left >= bold.right - 2f) {
            "toggles are not on one line: $bold vs $italic"
        }
    }

    @Test
    fun a_longer_label_makes_a_wider_button() {
        compose.onAllNodesWithText("A much longer label", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Measure the BUTTON, not its text. A Text hugs its content whatever its
        // parent does, so a text-bounds assertion here passes even when the Box
        // is filling the row — which is exactly the bug being guarded.
        val short = toggleBounds("tg-hug")
        val long = toggleBounds("tg-long")

        require(long.width > short.width) {
            "toggles do not size to their label: short=$short long=$long"
        }
    }

    @Test
    fun fill_width_true_still_spans_when_asked_for() {
        compose.onAllNodesWithText("Full width", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Hugging is the default, not the only option — the opt-in must still work.
        val hugging = toggleBounds("tg-hug")
        val spanning = toggleBounds("tg-fill")

        require(spanning.width > hugging.width * 2) {
            "fill_width did not span: hugging=$hugging spanning=$spanning"
        }
    }

    @Test
    fun pressing_flips_only_that_button() {
        compose.onAllNodesWithText("Bold", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Read the current state rather than assume it: the BEAM outlives the
        // Activity, so a previous test's tap survives into this one.
        val boldBefore = stateOf("tg-bold")
        val italicBefore = stateOf("tg-italic")

        tap("Bold")
        compose.waitUntil(10_000) { stateOf("tg-bold") != boldBefore }

        require(stateOf("tg-italic") == italicBefore) { "pressing Bold disturbed Italic" }

        // The summary renders from the same assigns, so it is the honest witness
        // that the tap reached a handle_info clause rather than merely repainting.
        require(showing("Pressed:") || showing("Nothing pressed")) {
            "the example rendered no summary"
        }
    }

    @Test
    fun a_disabled_toggle_is_inert_but_still_shows_its_state() {
        compose.onAllNodesWithText("Locked on", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Disabled wires no handler, so this must not move.
        tap("Locked on")
        Thread.sleep(400)

        require(showing("Locked on")) { "the disabled toggle vanished" }
        require(showing("Locked off")) { "the disabled idle toggle vanished" }

        // Locked-on and locked-off must not read the same. Colour is invisible to
        // the tree, so the tags carry it: a disabled toggle still reports whether
        // it is pressed, which is the whole reason it stays filled when greyed.
        require(stateOf("tg-lockon") == "pressed") { "a disabled pressed toggle lost its state" }
        require(stateOf("tg-lockoff") == "idle") { "a disabled idle toggle gained a state" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A toolbar",
            "It hugs its label",
            "Styled by props",
            "Disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
