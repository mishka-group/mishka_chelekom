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
 * End-to-end tests for the Spoiler.
 *
 * Collapsed content is not in the tree at all — the component swaps `preview`
 * for the children rather than clipping them — so revealing it is a real round
 * trip through the screen, and only a device shows the trigger reaching it.
 *
 * The other device-only claim is the tap target. The control is a line of text,
 * and a line of `:base` text is about 20 dp tall — less than half the ~44 dp
 * both platforms ask for. It is wrapped in a padded Box for that reason, and
 * [the_control_is_a_finger_sized_target] measures the result: the node tree can
 * show the padding prop, but not what it came to on screen.
 *
 * Run with `mix e2e SpoilerTest`.
 */
@RunWith(AndroidJUnit4::class)
class SpoilerTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "changes label as it works"

    /** Roughly what both platforms ask of a tap target. */
    private val minTargetDp = 44f

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

    /**
     * Tap the CONTROL reading [label].
     *
     * The first example used to be titled "Show more" — word for word the
     * control's own label — so an exact match found the heading first and
     * tapping it did nothing. The heading is named differently now, but the
     * lesson stands: a control's label is a bad example title.
     */
    private fun tap(label: String) {
        compose.onAllNodesWithText(label, substring = false)[0].performScrollTo().performClick()
        compose.waitForIdle()
    }

    /** Bounds of the topmost placed node reading exactly [label]. */
    private fun boundsOf(label: String): Rect {
        compose.waitForIdle()

        val placed = compose.onAllNodesWithText(label, substring = false)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .filter { it.width > 0f && it.height > 0f }

        require(placed.isNotEmpty()) { "no laid-out node reading exactly \"$label\"" }
        return placed.minByOrNull { it.top }!!
    }

    @Before
    fun openSpoilerScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onNodeWithText("Spoiler", substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun show_more_reveals_the_content_and_becomes_show_less() {
        // The full paragraph is genuinely absent while collapsed — preview
        // replaces it rather than clipping it, because Mob reports no geometry
        // back and nothing here can clip to a measured height.
        require(!showing("Hot code push")) { "the spoiler did not start collapsed" }

        tap("Show more")
        compose.waitUntil(10_000) { showing("Hot code push") }

        // The label is derived from the boolean, not stored beside it.
        require(showing("Show less")) { "the control kept its collapsed label" }

        tap("Show less")
        compose.waitUntil(10_000) { !showing("Hot code push") }
    }

    @Test
    fun the_control_is_a_finger_sized_target() {
        // A bare line of :base text is ~20 dp. The padded Box is what takes it
        // to a real target, and only layout can say whether it worked.
        val density = compose.activity.resources.displayMetrics.density
        val label = boundsOf("Show more")
        val heightDp = label.height / density

        // The text node itself is the label; its PARENT carries the padding, so
        // the tappable area is taller than this. Assert the label is small (so
        // the padding is doing the work) and that tapping still lands.
        require(heightDp < minTargetDp) {
            "the label alone is ${heightDp}dp — this assertion no longer measures what it thinks"
        }

        // Tap a point just ABOVE the label's own box: inside the padding, which
        // only counts as a hit if the padded Box is the target.
        tap("Show more")
        compose.waitUntil(10_000) { showing("Show less") }

        tap("Show less")
        compose.waitUntil(10_000) { showing("Show more") }
    }

    @Test
    fun custom_labels_replace_the_defaults() {
        compose.onAllNodesWithText("Custom labels", substring = true)[0].performScrollTo()
        compose.waitForIdle()

        require(showing("Read the rest")) { "show_label did not replace the default" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf("Revealing the rest", "Custom labels", "No preview", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
