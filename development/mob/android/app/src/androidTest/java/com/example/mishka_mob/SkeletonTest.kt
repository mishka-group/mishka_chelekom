package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
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
import kotlin.math.abs

/**
 * End-to-end tests for the Skeleton page.
 *
 * A placeholder has no text and no events, so almost nothing about it is
 * assertable from the node tree — which is exactly why it needs a device test.
 * The component numbers its bars into native testTags (`id-0`, `id-1`, …) for
 * this purpose, and every assertion here is a MEASUREMENT.
 *
 * [the_bars_have_a_real_height] guards a bug that is invisible on this platform:
 * iOS's MobBox applies a Box's `height` only inside its `fixedWidth > 0` branch,
 * so a childless bar measured 0pt tall and the whole placeholder disappeared —
 * `:text` and the default `:block` alike. Android was always fine, so this
 * asserts the invariant rather than the symptom: a bar must have height.
 *
 * [the_last_line_really_is_shorter] is Android-only by nature. The short line is
 * a Row weight, and the iOS renderer never parses weight — see the moduledoc.
 *
 * Run with `mix e2e SkeletonTest`.
 */
@RunWith(AndroidJUnit4::class)
class SkeletonTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "has not arrived"

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
    fun openSkeletonScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Skeleton", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_bars_have_a_real_height() {
        compose.onNodeWithTag("sk-text-2").performScrollTo()
        compose.waitForIdle()

        // A bar carries no text and no children of its own, so "it rendered" and
        // "it is 0pt tall" look identical in the tree. Measure it.
        for (tag in listOf("sk-text-0", "sk-text-1", "sk-text-2")) {
            val bar = compose.onNodeWithTag(tag).fetchSemanticsNode().boundsInRoot
            require(bar.height > 0f) { "$tag has no height: $bar" }
            require(bar.width > 0f) { "$tag has no width: $bar" }
        }
    }

    @Test
    fun the_last_line_really_is_shorter() {
        // THE device-only claim. The short line is a Row WEIGHT — 60% of a parent
        // whose width nothing in Elixir knows — so only real layout can say
        // whether it landed. Scroll to the LAST bar: bringing the first into view
        // can leave the third below the fold, and an unplaced node reports zero.
        compose.onNodeWithTag("sk-text-2").performScrollTo()
        compose.waitForIdle()

        val first = compose.onNodeWithTag("sk-text-0").fetchSemanticsNode().boundsInRoot
        val last = compose.onNodeWithTag("sk-text-2").fetchSemanticsNode().boundsInRoot

        require(first.width > 0f && last.width > 0f) {
            "a bar was not laid out: first=$first last=$last"
        }
        require(last.width < first.width) {
            "the last bar is ${last.width} against ${first.width} — it did not come out short"
        }

        val ratio = last.width / first.width
        require(ratio > 0.5f && ratio < 0.7f) { "the last bar is $ratio of the width, not ~0.6" }
    }

    @Test
    fun loading_swaps_the_placeholder_for_content_of_the_same_shape() {
        // Before: no name. After: the row it stood in for, and the avatar sits
        // where the circle was — same size, so nothing jumps.
        if (showing("Ada Lovelace")) {
            tap("Reset")
            compose.waitUntil(10_000) { !showing("Ada Lovelace") }
        }

        tap("Load")
        compose.waitUntil(10_000) { showing("Ada Lovelace") }

        val name = boundsOf("Ada Lovelace")
        val caption = boundsOf("Wrote the first program")

        require(caption.top > name.top) { "the two lines are not stacked" }
        require(abs(name.left - caption.left) < 2f) { "the two lines do not share a left edge" }

        // The avatar renders its INITIALS. It used to be handed a `name` prop
        // MishkaAvatar does not have, so the circle came up empty.
        require(showing("AL")) { "the avatar rendered no initials" }

        tap("Reset")
        compose.waitUntil(10_000) { !showing("Ada Lovelace") }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Standing in for a real row",
            "Text",
            "Blocks and circles",
            "It does not shimmer",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
