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
 * End-to-end tests for the Separator page.
 *
 * A rule has no text and no state — it draws a line — so everything worth
 * asserting here is geometry, and geometry needs a tag. That is why the
 * component grew an `id`: without one there is nothing in the semantics tree
 * to address, and a test could only claim the page rendered.
 *
 * Run with `mix e2e SeparatorTest`.
 */
@RunWith(AndroidJUnit4::class)
class SeparatorTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A thematic rule between groups of content"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /**
     * Bounds of a tagged node, after scrolling it into view.
     *
     * `performScrollTo` moves the MINIMUM distance, so scrolling to a heading
     * parks the content below it off-screen where bounds read as zero. Scroll
     * to the thing being measured, never to its heading.
     */
    private fun boundsOf(tag: String): Rect {
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)[0].performScrollTo()
        compose.waitForIdle()

        return compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")
    }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    @Before
    fun openSeparatorScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Separator", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun a_plain_rule_is_a_hairline_across_the_width() {
        val rule = boundsOf("sep-plain")

        // Thin on one axis, wide on the other — that is the whole claim a rule
        // makes, and it is the one a wrong `thickness` or a dropped `fill`
        // would break.
        require(rule.height < 4f) { "the default rule is not a hairline: $rule" }
        require(rule.width > 100f) { "the rule did not span its column: $rule" }
    }

    @Test
    fun thickness_is_honoured_and_is_not_the_default() {
        val thin = boundsOf("sep-plain")
        val thick = boundsOf("sep-thick")

        // thickness={3} against the default 1. Asserting the ORDER rather than
        // exact dp keeps this honest across densities while still failing if
        // the prop stops being read — which is what "3 is thicker than 1" means
        // and what a hardcoded 1 would break.
        require(thick.height > thin.height) {
            "thickness={3} was not thicker than the default: $thick vs $thin"
        }
    }

    @Test
    fun a_labelled_rule_centres_its_label_between_two_equal_lines() {
        val start = boundsOf("sep-or-line-start")
        val end = boundsOf("sep-or-line-end")

        // Both lines carry weight={1}, so they split the leftover width evenly.
        // This is the assertion that would catch the weight being dropped —
        // and it is exactly what does NOT hold on iOS, where weight is read
        // nowhere at all (IOS_TODO item 13).
        require(kotlin.math.abs(start.width - end.width) < 4f) {
            "the flanking lines are not equal: start=$start end=$end"
        }
        require(start.width > 8f) { "the flanking lines collapsed: $start" }
        require(start.left < end.left) { "the lines are out of order: $start then $end" }

        compose.onAllNodesWithText("or continue with", substring = false)[0].assertIsDisplayed()
    }

    @Test
    fun a_longer_label_takes_width_from_the_lines_not_from_the_page() {
        val shortLabelLine = boundsOf("sep-year-line-start")
        val longLabelLine = boundsOf("sep-or-line-start")

        // "1994" against "or continue with" in the same column. The lines flex;
        // the row does not grow. A rule whose lines had fixed widths would push
        // the long label out of the row instead.
        require(shortLabelLine.width > longLabelLine.width) {
            "the shorter label did not leave more room for its lines: " +
                "1994=$shortLabelLine vs 'or continue with'=$longLabelLine"
        }
    }

    @Test
    fun a_vertical_rule_is_tall_and_thin_rather_than_wide_and_flat() {
        val rule = boundsOf("sep-vert")

        require(rule.width < 4f) { "the vertical rule is not a hairline: $rule" }
        require(rule.height > rule.width) { "the vertical rule did not stand up: $rule" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Plain rule",
            "Labelled",
            "Colour and thickness",
            "Vertical",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
