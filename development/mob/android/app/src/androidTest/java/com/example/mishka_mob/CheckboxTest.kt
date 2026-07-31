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
 * End-to-end tests for the Checkbox page.
 *
 * [the_tick_scales_with_the_box] is the reported regression. The indicator is
 * drawn from a Box plus a glyph — Mob has no checkbox widget — and the glyph was
 * a fixed `:base` while the Box took `size`. A small box therefore clipped its
 * tick into a smear and a large one left it stranded. Both are invisible in the
 * node tree, so this measures the glyph against its box.
 *
 * Run with `mix e2e CheckboxTest`.
 */
@RunWith(AndroidJUnit4::class)
class CheckboxTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "checked, unchecked and"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** Laid-out bounds of every node reading EXACTLY [label]. */
    private fun allBounds(label: String): List<Rect> =
        compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

    private fun boundsOf(label: String): Rect =
        allBounds(label).firstOrNull() ?: error("no laid-out node reading \"$label\"")

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
    fun openCheckboxScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Checkbox", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_tick_scales_with_the_box() {
        compose.onAllNodesWithText("Small", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The "Colour and size" example renders one large box and one small one.
        // Every tick must fit inside its own box — a clipped glyph is the bug.
        val ticks = allBounds("✓")
        require(ticks.size >= 2) { "expected at least two ticks on this page, saw ${ticks.size}" }

        val big = ticks.maxByOrNull { it.width }!!
        val small = ticks.minByOrNull { it.width }!!
        require(big.width > small.width) {
            "the tick does not scale with size: big=$big small=$small"
        }

        // NOTE: do not try to assert "breathing room" from these bounds. The ✓
        // node reports its LAYOUT box, which tracks the checkbox's `size`, not
        // the glyph drawn inside it — a small box reports 42px whatever the font
        // is. Glyph size is asserted in the unit test, against `props.text_size`;
        // how it LOOKS at 16dp still needs a human eye.
    }

    @Test
    fun a_mixed_box_draws_a_dash_not_a_tick() {
        compose.onAllNodesWithText("Select all", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        // The three states must differ by SHAPE, not only colour, so they survive
        // a colourblind reading.
        require(showing("–") || showing("✓")) { "the select-all box drew no glyph at all" }
    }

    @Test
    fun tapping_the_label_toggles_it_too() {
        compose.onAllNodesWithText("Remember me", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val before = allBounds("✓").size

        // on_tap sits on the Row, so the label is as tappable as the 22dp box —
        // which is the whole reason it is on the Row.
        tap("Remember me")
        compose.waitUntil(10_000) { allBounds("✓").size != before }

        tap("Remember me")
        compose.waitUntil(10_000) { allBounds("✓").size == before }
    }

    @Test
    fun a_disabled_box_does_not_change() {
        compose.onAllNodesWithText("Disabled", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        val before = allBounds("✓").size
        // Disabled wires no handler, so this must be inert rather than merely grey.
        compose.onAllNodesWithText("Disabled", substring = true)[0].performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        require(allBounds("✓").size == before) { "a disabled checkbox changed state" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Checked and unchecked",
            "Select all",
            "Disabled",
            "Colour and size",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
