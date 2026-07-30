package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.isToggleable
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
 * End-to-end tests for the Switch page.
 *
 * A switch carries no text of its own — the label is a sibling Text inside the
 * native Toggle's Row — so the switches are reached with `isToggleable()` and
 * matched to their example by BOUNDS. That is also what lets the tests assert
 * the thing the page was reported for.
 *
 * [the_switch_leads_when_the_label_prop_is_omitted] is that report. The page's
 * "Without a label" example used to hand-build the very arrangement `label=`
 * already produces — text, spacer, switch — so it looked identical to the
 * labelled example and demonstrated nothing. It now puts the switch FIRST, which
 * `label=` cannot do, and this measures it.
 *
 * [toggling_one_example_leaves_the_others_alone] guards a state bug: that same
 * example was bound to `@sw_bluetooth`, the assign the labelled Bluetooth switch
 * already owned, so moving either moved both.
 *
 * Run with `mix e2e SwitchTest`.
 */
@RunWith(AndroidJUnit4::class)
class SwitchTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "mapped onto Mob's native Toggle"

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

    /** Every laid-out switch on screen, with its bounds. */
    private fun switches(): List<Pair<Int, Rect>> =
        compose.onAllNodes(isToggleable())
            .fetchSemanticsNodes()
            .mapIndexed { i, n -> i to n.boundsInRoot }
            .filter { it.second.width > 0f && it.second.height > 0f }

    /** The switch whose vertical centre is nearest [label]'s. */
    private fun switchBeside(label: String): Pair<Int, Rect> {
        val row = boundsOf(label)
        return switches().minByOrNull { kotlin.math.abs(it.second.center.y - row.center.y) }
            ?: error("no switch laid out near \"$label\"")
    }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    @Before
    fun openSwitchScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Switch", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_switch_leads_when_the_label_prop_is_omitted() {
        compose.onAllNodesWithText("Airplane mode", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val text = boundsOf("Airplane mode")
        val (_, sw) = switchBeside("Airplane mode")

        // THE difference. With `label=` the switch can only trail; omitting it is
        // what buys you the other order, and this is the only way to see that.
        require(sw.right <= text.left + 2f) {
            "the switch does not lead the text: switch=$sw text=$text"
        }
    }

    @Test
    fun a_labelled_switch_trails_its_label() {
        compose.onAllNodesWithText("Bluetooth", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val text = boundsOf("Bluetooth")
        val (_, sw) = switchBeside("Bluetooth")

        require(sw.left >= text.right - 2f) {
            "the labelled switch does not trail: switch=$sw text=$text"
        }
    }

    @Test
    fun toggling_one_example_leaves_the_others_alone() {
        // The summary line is rendered from the Wi-Fi/Bluetooth assigns, so it is
        // the honest witness for "did another example move?".
        compose.onAllNodesWithText("Airplane mode", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val (index, _) = switchBeside("Airplane mode")
        compose.onAllNodes(isToggleable())[index].performClick()
        compose.waitForIdle()
        Thread.sleep(400)

        compose.onAllNodesWithText("Bluetooth", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        require(showing("Bluetooth is off")) {
            "toggling the unlabelled switch moved the Bluetooth example too"
        }

        // Put it back.
        compose.onAllNodesWithText("Airplane mode", substring = false)[0].performScrollTo()
        compose.waitForIdle()
        val (again, _) = switchBeside("Airplane mode")
        compose.onAllNodes(isToggleable())[again].performClick()
        compose.waitForIdle()
    }

    @Test
    fun a_disabled_switch_cannot_be_moved() {
        compose.onAllNodesWithText("Locked on", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val (index, before) = switchBeside("Locked on")
        compose.onAllNodes(isToggleable())[index].performClick()
        compose.waitForIdle()
        Thread.sleep(400)

        // Disabled here means "no handler is wired", so the control renders
        // normally and simply never changes. Its own example says so.
        val (_, after) = switchBeside("Locked on")
        require(before == after) { "the disabled switch moved: $before -> $after" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "With a label",
            "Custom colour",
            "Disabled",
            "Without a label",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
