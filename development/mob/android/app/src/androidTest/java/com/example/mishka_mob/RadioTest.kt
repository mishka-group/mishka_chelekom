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
 * End-to-end tests for the Radio page.
 *
 * [only_one_option_stays_selected] is the invariant the whole component exists
 * for. The web gets it free — a shared `name` makes the browser enforce it — but
 * there is no form and no browser here, so exclusivity is entirely the screen's
 * handler. Nothing in the component can guarantee it, which is exactly why it is
 * asserted on a device.
 *
 * The selection is a DOT, not text, so there is nothing in the tree to read. The
 * ring's testTag carries the state instead (`rd-pro-selected` / `rd-pro-empty`);
 * see MishkaRadio's moduledoc.
 *
 * Run with `mix e2e RadioTest`.
 */
@RunWith(AndroidJUnit4::class)
class RadioTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "option in a mutually exclusive"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /**
     * useUnmergedTree: every radio row carries an on_tap, and a clickable Row
     * MERGES its children's semantics — which swallows the ring's own testTag.
     * Without this flag the tags are invisible and every assertion here reads
     * as "not selected".
     */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    /**
     * A ring's state as its own tag spells it — "selected" or "empty". Null when
     * the row is not in the tree at all, which is how a vanished example reads,
     * and also when both tags somehow exist at once.
     */
    private fun ringState(prefix: String): String? =
        listOf("selected", "empty").singleOrNull { tagged("$prefix-$it") }

    private fun ringBounds(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out ring tagged \"$tag\"")

    private val plans = listOf("free" to "Free", "pro" to "Pro", "team" to "Team")

    /**
     * Which plan is selected right now. The BEAM outlives the Activity, so a
     * previous test's tap survives into this one — every assertion here reads
     * the current selection rather than assuming the mount value.
     */
    private fun selectedPlan(): String =
        plans.map { it.first }.singleOrNull { tagged("rd-$it-selected") }
            ?: error("expected exactly one selected plan, got " +
                plans.map { it.first }.filter { tagged("rd-$it-selected") })

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
    fun openRadioScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            // Exact match: "Radio" must not open the "Radio Group" card.
            compose.onAllNodesWithText("Radio", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun only_one_option_stays_selected() {
        compose.onAllNodesWithText("Free", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val before = selectedPlan()
        val (id, label) = plans.first { it.first != before }

        tap(label)
        compose.waitUntil(10_000) { tagged("rd-$id-selected") }

        // The half a checkbox would get wrong: selecting one must UNSELECT the
        // other. `selectedPlan` fails outright if two rings are filled at once,
        // which is the bug this exists to catch.
        require(selectedPlan() == id) { "picking $id did not clear $before" }
    }

    @Test
    fun re_tapping_the_selection_keeps_it() {
        compose.onAllNodesWithText("Team", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        tap("Team")
        compose.waitUntil(10_000) { tagged("rd-team-selected") }

        // A radio set cannot be cleared by re-tapping — the whole behavioural
        // difference from a checkbox, and one line in the handler, so nothing
        // but a device test notices when it regresses.
        tap("Team")
        Thread.sleep(400)
        require(selectedPlan() == "team") { "re-tapping cleared the selection" }
    }

    @Test
    fun the_summary_line_proves_the_event_reached_a_clause() {
        compose.onAllNodesWithText("Free", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The summary renders from the same assign the radios drive, so it is
        // the honest witness that the composed {:rd_plan, id} tag matched a
        // clause — a ring can repaint without any event arriving.
        require(showing("Selected:")) { "the example rendered no summary" }

        val (id, label) = plans.first { it.first != selectedPlan() }
        tap(label)
        compose.waitUntil(10_000) { showing("Selected: $id") }
    }

    @Test
    fun the_ring_scales_and_stays_round() {
        compose.onAllNodesWithText("Small", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val big = ringBounds("rd-large-selected")
        val small = ringBounds("rd-small-selected")

        require(big.width > small.width) { "size did not scale the ring: $big vs $small" }

        // A square ring is a circle once corner_radius is size/2 — an oblong one
        // renders as a lozenge, which is what an inherited height would produce.
        for ((name, r) in listOf("large" to big, "small" to small)) {
            require(kotlin.math.abs(r.width - r.height) < 2f) { "the $name ring is not round: $r" }
        }
    }

    @Test
    fun a_disabled_radio_does_not_change() {
        compose.onAllNodesWithText("Locked off", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Read both rings BEFORE the tap: an end state that merely happens to
        // look right proves nothing, so the test pins the starting point and
        // then demands neither ring moved.
        val offBefore = ringState("rd-locked-off")
        val onBefore = ringState("rd-locked-on")
        require(offBefore == "empty" && onBefore == "selected") {
            "the disabled example did not start as declared: off=$offBefore, on=$onBefore"
        }

        // Disabled wires no handler, so this must be inert rather than merely grey.
        compose.onAllNodesWithText("Locked off", substring = false)[0].performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        // These used to be showing("Locked off") / showing("Locked on"). A label
        // is a plain Text that never varies with `checked` — the selection is a
        // dot — so both strings stayed on the page whether the tap was swallowed
        // or wired the row and flipped it. The ring's tag is the only witness of
        // selection, so a tap that reached a handler now fails here.
        require(ringState("rd-locked-off") == offBefore) {
            "tapping a disabled radio changed it: $offBefore -> ${ringState("rd-locked-off")}"
        }
        require(!tagged("rd-locked-off-selected")) { "the disabled empty radio grew a dot" }
        require(ringState("rd-locked-on") == onBefore) {
            "the disabled selected radio lost its dot: ${ringState("rd-locked-on")}"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Pick one",
            "Circle, not a tick",
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
