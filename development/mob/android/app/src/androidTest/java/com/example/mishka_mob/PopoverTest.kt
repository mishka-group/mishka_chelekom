package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.longClick
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Popover page.
 *
 * The port shipped with the panel shell and nothing else — no trigger, no way
 * to open it, and no tags to address any of it by. Every assertion here reads a
 * testTag rather than page text, for the reason the last sweep found in twelve
 * other suites: the whole page is one eagerly-rendered tree, the sixth example
 * is a popover pinned open={true}, and every code sample is a text node too. A
 * page-wide text query is answered by whichever example happens to contain the
 * string.
 *
 * The trigger's open state rides in its own tag (`-trigger-open` /
 * `-trigger-closed`) because the only other thing that says so is its fill, and
 * a device test cannot read a colour.
 *
 * Run with `mix e2e PopoverTest`.
 */
@RunWith(AndroidJUnit4::class)
class PopoverTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A trigger that toggles a panel"

    /** Every interactive example on the page, by the id it was given. */
    private val examples = listOf("pop", "hold", "above", "beside", "aligned")

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    private fun hold(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true)
            .performScrollTo()
            .performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    /**
     * Scroll the panel into view and measure it against its trigger. Scrolling
     * to the PANEL rather than to a heading matters: performScrollTo moves the
     * minimum distance, so parking a heading at the bottom edge leaves whatever
     * is under it off-screen, where bounds report zero size.
     */
    /**
     * The trigger's and the panel's frames, both laid out.
     *
     * Scroll to the TRIGGER, not the panel: with side={:top} the panel sits
     * above the trigger, so scrolling the panel into view can leave the trigger
     * below the fold — where Compose reports zero bounds and the comparison is
     * against Rect(0,0,0,0), which is not a failure of the component.
     */
    private fun frames(id: String): Pair<Rect, Rect> {
        // Scroll to whichever end brings BOTH into view. side={:top} puts the
        // panel above the trigger and align={:end} can put it below, so
        // favouring either one alone leaves the other off-screen at zero
        // bounds — which reads as a component failure and is not one.
        for (anchor in listOf("$id-trigger-open", "$id-panel")) {
            runCatching {
                compose.onNodeWithTag(anchor, useUnmergedTree = true).performScrollTo()
            }
            compose.waitForIdle()

            val trigger = laidOutOrNull("$id-trigger-open")
            val panel = laidOutOrNull("$id-panel")
            if (trigger != null && panel != null) return trigger to panel
        }

        return laidOut("$id-trigger-open") to laidOut("$id-panel")
    }

    private fun laidOutOrNull(tag: String): Rect? =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }

    private fun laidOut(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    @Before
    fun openPopoverScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Popover", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so a panel an earlier test opened is
        // still open. Each example owns its own assign — that is the whole
        // reason they are not shared — so close them one by one.
        for (id in examples) {
            if (tagged("$id-trigger-open")) tap("$id-trigger-open")
        }
    }

    @Test
    fun tapping_the_trigger_opens_the_panel() {
        require(!tagged("pop-panel")) { "this popover was already open" }

        tap("pop-trigger-closed")

        compose.waitUntil(10_000) { tagged("pop-panel") }
        require(tagged("pop-trigger-open")) { "the panel opened but its trigger still reads closed" }
        require(!tagged("pop-trigger-closed")) { "the trigger reported both states at once" }
    }

    @Test
    fun the_panel_carries_its_title_description_and_beak() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-panel") }

        // The web wires these through aria-labelledby / aria-describedby. Mob
        // exposes no accessibility semantics, so they are rendered instead —
        // and each gets its own tag, since a panel-wide text query would be
        // answered by any of the six examples.
        require(tagged("pop-title")) { "the title slot rendered nothing" }
        require(tagged("pop-desc")) { "the description slot rendered nothing" }
        require(tagged("pop-arrow")) { "arrow={true} drew no beak" }
    }

    @Test
    fun the_footer_close_puts_it_away() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-close") }

        tap("pop-close")

        require(!tagged("pop-panel")) { "the close action left the panel up" }
        require(tagged("pop-trigger-closed")) { "the trigger did not go back to closed" }
    }

    @Test
    fun a_long_press_opens_it_too() {
        require(!tagged("hold-panel")) { "the hold example was already open" }

        hold("hold-trigger-closed")

        // open_on_hold is the port of open_on_hover: a phone has no pointer to
        // rest on something, and a long press is what it has instead.
        compose.waitUntil(10_000) { tagged("hold-panel") }
    }

    @Test
    fun a_long_press_only_ever_opens() {
        hold("hold-trigger-closed")
        compose.waitUntil(10_000) { tagged("hold-panel") }

        hold("hold-trigger-open")

        // A hover never toggled, so neither does this. The tap is the toggle.
        require(tagged("hold-panel")) { "a second hold closed the panel" }

        tap("hold-trigger-open")
        require(!tagged("hold-panel")) { "the long press swallowed the ordinary tap" }
    }

    @Test
    fun side_top_puts_the_panel_above_its_trigger() {
        tap("above-trigger-closed")
        compose.waitUntil(10_000) { tagged("above-panel") }

        val (trigger, panel) = frames("above")

        require(panel.bottom <= trigger.top) {
            "side={:top} did not lift the panel above its trigger: trigger=$trigger panel=$panel"
        }
    }

    @Test
    fun side_right_puts_them_abreast() {
        tap("beside-trigger-closed")
        compose.waitUntil(10_000) { tagged("beside-panel") }

        val (trigger, panel) = frames("beside")

        require(panel.left >= trigger.right) {
            "side={:right} did not put the panel beside the trigger: trigger=$trigger panel=$panel"
        }
        // Abreast, not stacked — they share vertical space.
        require(panel.top < trigger.bottom && trigger.top < panel.bottom) {
            "the panel and its trigger do not overlap vertically: trigger=$trigger panel=$panel"
        }
        // And the trigger hugged its label rather than eating the row. An
        // unweighted child measured first would have starved the panel to zero.
        require(panel.width > trigger.width) {
            "the trigger claimed the row: trigger=$trigger panel=$panel"
        }
    }

    @Test
    fun align_end_pushes_a_narrow_panel_to_the_trailing_edge() {
        tap("aligned-trigger-closed")
        compose.waitUntil(10_000) { tagged("aligned-panel") }

        val (trigger, panel) = frames("aligned")

        // width={220} is what gives align somewhere to go — a panel that fills
        // its parent looks identical at every alignment.
        require(panel.width < trigger.width) { "the panel ignored its width: panel=$panel" }
        require(panel.left > trigger.left) {
            "align={:end} left the panel at the leading edge: trigger=$trigger panel=$panel"
        }
    }

    @Test
    fun a_disabled_trigger_cannot_open_anything() {
        tap("off-trigger-closed")

        // disabled wires no handler at all, so there is nothing to fire.
        require(!tagged("off-panel")) { "a disabled trigger opened its panel" }
        require(tagged("off-trigger-closed")) { "a disabled trigger changed state" }
    }

    @Test
    fun the_pinned_example_needs_no_trigger_at_all() {
        // Omit `trigger` and the popover is the panel alone — which is how Menu
        // and the select-style components use it. Its parts are still tagged.
        require(tagged("chrome-panel")) { "the pinned-open example rendered no panel" }
        require(tagged("chrome-title") && tagged("chrome-desc")) {
            "the pinned example lost its title or description"
        }
        require(!tagged("chrome-trigger-closed") && !tagged("chrome-trigger-open")) {
            "a popover with no trigger prop drew one anyway"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Tap the trigger",
            "Hold to open",
            "Which side it takes",
            "A narrow panel has somewhere to go",
            "Disabled, and without a chevron",
            "Chrome",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
