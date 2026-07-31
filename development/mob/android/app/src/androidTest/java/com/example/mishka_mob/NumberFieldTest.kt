package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Number Field page.
 *
 * [the_control_is_one_joined_strip] is the reported regression. It used to be a
 * stepper, a gap, a bordered field that FILLED the row, and another stepper — so
 * the two buttons drifted to opposite edges of the screen with a wide empty box
 * marooned between them. The web draws one bordered strip. Only measurement can
 * tell the difference: the node tree is equally correct either way.
 *
 * The steppers all read "−" or "+", and every number field on the page has a
 * pair, so they are addressed by tag: `nf-qty-down`, `nf-qty-up`.
 *
 * Run with `mix e2e NumberFieldTest`.
 */
@RunWith(AndroidJUnit4::class)
class NumberFieldTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "numeric input with decrement"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    private fun valueOf(tag: String): String =
        compose.onNodeWithTag(tag).fetchSemanticsNode()
            .config.firstOrNull { it.key.name == "EditableText" }
            ?.value?.toString()
            ?: error("no editable text on \"$tag\"")

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    private fun tapTag(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    @Before
    fun openNumberFieldScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Number Field", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_control_is_one_joined_strip() {
        compose.onNodeWithTag("nf-qty").performScrollTo()
        compose.waitForIdle()

        val down = boundsOf("nf-qty-down")
        val field = boundsOf("nf-qty")
        val up = boundsOf("nf-qty-up")

        // Adjacent and in order. The tolerance is not slack: a stepper reports
        // its OUTER box while a Compose TextField reports its inner text area,
        // inset by Material's own horizontal padding — about 8dp a side — so a
        // perfectly joined strip still shows ~24px between those two rectangles.
        // The bug this guards against was two 8dp Spacers AND a value slot that
        // filled the row, which is caught by the width assertion below.
        val inset = 30f
        require(field.left >= down.right - 1f) { "value overlaps the − stepper: $down vs $field" }
        require(up.left >= field.right - 1f) { "+ stepper overlaps the value: $field vs $up" }
        require(field.left - down.right < inset) { "a real gap before the value: $down vs $field" }
        require(up.left - field.right < inset) { "a real gap after the value: $field vs $up" }

        // And the whole strip hugs rather than spanning the screen. Before the
        // fix this measured ~845px on a 1080px screen.
        val strip = up.right - down.left
        require(strip in 1f..700f) { "the strip is not compact: $strip" }

        // Nothing but the two hairlines separates the parts: the strip is the
        // sum of its pieces, not its pieces plus spacers.
        val parts = down.width + up.width + (field.right - field.left) + 2f * inset
        require(strip <= parts + 8f) { "the strip is wider than its parts: $strip vs $parts" }

        // The steppers are square and the same size.
        require(kotlin.math.abs(down.width - down.height) < 2f) { "the − stepper is not square: $down" }
        require(kotlin.math.abs(down.width - up.width) < 2f) { "the steppers differ in size" }
    }

    @Test
    fun fill_width_spans_while_the_default_hugs() {
        compose.onNodeWithTag("nf-wide").performScrollTo()
        compose.waitForIdle()

        val hugging = boundsOf("nf-hug-up").right - boundsOf("nf-hug-down").left
        val spanning = boundsOf("nf-wide-up").right - boundsOf("nf-wide-down").left

        require(spanning > hugging * 1.5f) {
            "fill_width did not span: hugging=$hugging spanning=$spanning"
        }
    }

    @Test
    fun the_steppers_move_the_value_and_clamp() {
        compose.onNodeWithTag("nf-qty").performScrollTo()
        compose.waitForIdle()

        val before = valueOf("nf-qty").toInt()

        tapTag("nf-qty-up")
        compose.waitUntil(10_000) { valueOf("nf-qty").toInt() != before }
        require(valueOf("nf-qty").toInt() == before + 1) { "+ moved by more than one step" }

        tapTag("nf-qty-down")
        compose.waitUntil(10_000) { valueOf("nf-qty").toInt() == before }
    }

    @Test
    fun a_stepper_goes_inert_at_its_bound() {
        compose.onNodeWithTag("nf-qty").performScrollTo()
        compose.waitForIdle()

        // Walk to the top of the 1..10 range, then keep pressing.
        var guard = 0
        while (valueOf("nf-qty").toInt() < 10 && guard++ < 15) {
            tapTag("nf-qty-up")
        }

        require(valueOf("nf-qty") == "10") { "never reached the max: ${valueOf("nf-qty")}" }

        // The + is unwired at the bound, so this must not push past it — and the
        // node is still there and still laid out, just inert.
        tapTag("nf-qty-up")
        Thread.sleep(400)
        require(valueOf("nf-qty") == "10") { "the + stepped past its max" }

        // Coming back down works, which proves the clamp is not a freeze.
        tapTag("nf-qty-down")
        compose.waitUntil(10_000) { valueOf("nf-qty") == "9" }
    }

    @Test
    fun percent_shows_a_fraction_as_a_percentage() {
        compose.onNodeWithTag("nf-pct").performScrollTo()
        compose.waitForIdle()

        // The assign holds 0.075. The field must read 7.5%, not 0.075 and not
        // 0.075% — the displayed number is never the stored one here.
        require(valueOf("nf-pct").endsWith("%")) { "percent lost its sign: ${valueOf("nf-pct")}" }
        require(valueOf("nf-pct") == "7.5%") { "0.075 did not read as 7.5%: ${valueOf("nf-pct")}" }

        require(showing("a fraction")) { "the caption explaining the fraction is missing" }
    }

    @Test
    fun currency_groups_and_prefixes() {
        compose.onNodeWithTag("nf-price").performScrollTo()
        compose.waitForIdle()

        require(valueOf("nf-price") == "$1,999.99") {
            "currency formatting is wrong: ${valueOf("nf-price")}"
        }

        // And stepping keeps the format rather than dropping back to a raw float.
        tapTag("nf-price-up")
        compose.waitUntil(10_000) { valueOf("nf-price") == "$2,000.00" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Whole numbers",
            "Decimal steps",
            "Currency and percent",
            "It hugs, or it spans",
            "Empty and disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
