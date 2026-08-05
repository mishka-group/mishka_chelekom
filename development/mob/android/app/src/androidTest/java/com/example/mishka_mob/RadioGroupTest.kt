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
 * End-to-end tests for the Radio Group page.
 *
 * The group's reason to exist is that ONE handler serves every option: each
 * reports the same tag widened with its own id, which is what replaces the
 * browser's shared `name`. [one_handler_serves_every_option] is that claim.
 *
 * As with a lone radio, the selection is a dot rather than text, so the ring's
 * testTag carries it — here prefixed by the group id, so a single option can be
 * named: `rg-plan-pro-selected`.
 *
 * Run with `mix e2e RadioGroupTest`.
 */
@RunWith(AndroidJUnit4::class)
class RadioGroupTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "labelled set of mutually exclusive"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /** useUnmergedTree — a tappable option Row merges away its ring's testTag. */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun ringBounds(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out ring tagged \"$tag\"")

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

    /**
     * Press an option through its ring tag rather than its label. [tap] takes
     * `onAllNodesWithText(label)[0]`, and "Free" and "Pro" are each rendered by
     * three groups on this page — all bound to the same @rg_plan, only the first
     * carrying an id. A tap that drifted onto one of the others therefore still
     * turned every rg-plan assertion green: the test could not tell which group
     * it had pressed. A tag names one group by construction, and onNodeWithTag
     * fails loudly rather than picking a first match if that ever stops holding.
     *
     * The tag sits on the ring while the on_tap sits on its Row, so the touch
     * lands at the ring's centre and the Row's clickable is what receives it.
     */
    private fun tapRing(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(300)
    }

    @Before
    fun openRadioGroupScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Radio Group", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    /**
     * Option ids, not labels: the labels are shared with two other groups on the
     * page, so a label does not name an option here — the ring tag does.
     */
    private val plans = listOf("free", "pro", "team")

    /**
     * The BEAM outlives the Activity, so a previous test's tap survives into
     * this one. Read the selection rather than assuming the mount value — and
     * fail loudly if the group somehow holds two.
     */
    private fun selectedPlan(): String =
        plans.singleOrNull { tagged("rg-plan-$it-selected") }
            ?: error("expected exactly one selection, got " +
                plans.filter { tagged("rg-plan-$it-selected") })

    @Test
    fun one_handler_serves_every_option() {
        compose.onAllNodesWithText("PLAN", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val current = selectedPlan()
        val id = plans.first { it != current }

        // Each option widens the SAME on_change tag with its own id. If that
        // widening broke, the tap would still land and simply do nothing — so
        // assert the state moved, not that the tap happened.
        //
        // Pressed by tag: tapping the label reached whichever group came first
        // in tree order, and since all three write @rg_plan the assertions below
        // passed no matter which one that was — including for a regression that
        // broke only the id-carrying group this test names.
        tapRing("rg-plan-$id-empty")
        compose.waitUntil(10_000) { tagged("rg-plan-$id-selected") }
        require(selectedPlan() == id) { "the group holds more than one selection" }

        // The summary renders from the same assign, proving a clause matched
        // rather than the ring merely repainting.
        compose.waitUntil(10_000) { showing("Selected: $id") }
    }

    /** A ring's bounds whichever state it is in — the selection may have moved. */
    private fun anyRing(prefix: String): Rect =
        if (tagged("$prefix-selected")) ringBounds("$prefix-selected")
        else ringBounds("$prefix-empty")

    @Test
    fun horizontal_lays_the_options_in_a_row() {
        // Scroll to the LAST option, not to the "SIZE" heading: performScrollTo
        // moves the minimum distance, so scrolling to a heading parks it at the
        // bottom edge and leaves the row beneath it off-screen — where Compose
        // reports zero bounds and every measurement below reads as missing.
        compose.onAllNodesWithText("L", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val s = anyRing("rg-size-s")
        val m = anyRing("rg-size-m")
        val l = anyRing("rg-size-l")

        // Side by side, not stacked: only layout can catch an orientation that
        // silently fell back to a Column.
        require(m.left >= s.right) { "S and M are not on one line: $s vs $m" }
        require(l.left >= m.right) { "M and L are not on one line: $m vs $l" }
        require(kotlin.math.abs(s.top - l.top) < 2f) { "the row is not aligned: $s vs $l" }
    }

    @Test
    fun a_disabled_option_is_inert_while_its_neighbour_works() {
        compose.onAllNodesWithText("ONE OPTION OFF", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Tapping the unavailable option must not move the selection. The group
        // cascades `disabled` per option, and an option that merely LOOKS grey
        // while still reporting is the failure this catches. Compare before and
        // after rather than naming a value — the selection carries between tests.
        val before = selectedPlan()

        tap("Team (unavailable)")
        Thread.sleep(400)
        require(selectedPlan() == before) { "a disabled option reported a selection" }
    }

    @Test
    fun a_disabled_group_cascades_to_every_option() {
        // The OFF group shows the same @rg_plan as the first example, so while
        // :pro is the plan a cascade that failed would send {:rg_plan, :pro} and
        // change nothing anyone could see. Park the selection elsewhere first,
        // through the group that really works, so the tap has something to prove.
        if (selectedPlan() == "pro") {
            tapRing("rg-plan-team-empty")
            compose.waitUntil(10_000) { tagged("rg-plan-team-selected") }
        }

        compose.onAllNodesWithText("WHOLE GROUP OFF", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The group carries a live on_change, so `disabled` cascading to every
        // option is the only thing that can stop a tap. Its rings are still
        // tagged, which is how we can tell it rendered rather than vanished.
        require(tagged("rg-off-free-empty") || tagged("rg-off-free-selected")) {
            "the disabled group did not render"
        }

        val before = selectedPlan()
        require(before != "pro") { "the tap below cannot fail while :pro is selected" }
        require(tagged("rg-off-pro-empty")) {
            "the OFF group's Pro ring is not empty while the plan is $before"
        }

        // This group's options are labelled "(off)" precisely so a click here
        // cannot land on the tappable "Pro" of the first example — three groups
        // on this page would otherwise share the label, and the wrong one is
        // the one that works, so the test would pass while proving nothing.
        tap("Pro (off)")
        Thread.sleep(400)

        // Until the showcase wired on_change onto this group there was nothing
        // to fire, so both requires below could only observe a MISSING handler —
        // deleting `disabled={true}` left the test green. They now fail if the
        // cascade stops reaching an option: once in the shared assign, and once
        // in the OFF group's own ring, which is the half scoped to the group
        // this test names.
        require(selectedPlan() == before) {
            "a disabled group reported a selection: $before -> ${selectedPlan()}"
        }
        require(tagged("rg-off-pro-empty")) { "a disabled option filled its own ring" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A labelled group",
            "Horizontal",
            "Disabled option and group",
            "Colour and size",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
