package com.example.mishka_mob

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
 * End-to-end tests for the Checkbox Group page.
 *
 * [the_parent_always_agrees_with_its_children] is the component's whole claim:
 * the "select all" parent is not a special widget, it is an ordinary checkbox
 * whose mixed state is DERIVED from the selection. Nothing enforces that but
 * `parent_state/2`, and a screen that drifts out of sync renders a tick over a
 * half-empty list — which reads as correct until you count.
 *
 * The tick and the dash are DRAWN on a canvas, so there is no text in the tree
 * to assert on. Every row's state rides in its testTag instead:
 * `cg-langs-otp-checked`, `cg-langs-all-mixed`. See MishkaCheckbox's moduledoc.
 *
 * Run with `mix e2e CheckboxGroupTest`.
 */
@RunWith(AndroidJUnit4::class)
class CheckboxGroupTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "tristate select-all parent"

    private val langs = listOf("beam" to "BEAM", "otp" to "OTP", "phoenix" to "Phoenix", "ecto" to "Ecto")

    /**
     * NOT the default "Select all": the first example's HEADING is also exactly
     * "Select all", and an exact-text lookup returns the heading first — so the
     * tap landed on a section title and silently did nothing. The showcase gives
     * this parent a distinct label, which also tells the reader what "all" means.
     */
    private val parentLabel = "Select all libraries"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /**
     * useUnmergedTree: every row carries an on_tap, and a clickable Row MERGES
     * its children's semantics — which swallows the indicator's own testTag.
     * Without the flag every row reads as stateless.
     */
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    /** "checked" | "mixed" | "empty", or null when no such indicator exists. */
    private fun stateOf(prefix: String): String? =
        listOf("checked", "mixed", "empty").firstOrNull { tagged("$prefix-$it") }

    private fun checkedLangs(): List<String> =
        langs.map { it.first }.filter { stateOf("cg-langs-$it") == "checked" }

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
    fun openCheckboxGroupScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            // Exact match: "Checkbox Group" must not open the "Checkbox" card.
            compose.onAllNodesWithText("Checkbox Group", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    /** The parent state `parent_state/2` should be showing for a given selection. */
    private fun expectedParent(checked: List<String>): String = when {
        checked.isEmpty() -> "empty"
        checked.size == langs.size -> "checked"
        else -> "mixed"
    }

    @Test
    fun the_parent_always_agrees_with_its_children() {
        compose.onAllNodesWithText(parentLabel, substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // An invariant, not a fixture: it holds for whatever the selection
        // happens to be, which matters because the BEAM outlives the Activity
        // and a previous test's taps survive into this one.
        require(stateOf("cg-langs-all") == expectedParent(checkedLangs())) {
            "parent shows ${stateOf("cg-langs-all")} for ${checkedLangs()}"
        }

        // Flip one child and it must still hold — this is the half that breaks
        // when a screen updates the list without re-deriving the parent.
        tap("OTP")
        compose.waitForIdle()
        Thread.sleep(300)

        require(stateOf("cg-langs-all") == expectedParent(checkedLangs())) {
            "after toggling OTP the parent shows ${stateOf("cg-langs-all")} for ${checkedLangs()}"
        }
    }

    @Test
    fun the_parent_fills_up_when_partial_and_clears_only_when_full() {
        compose.onAllNodesWithText(parentLabel, substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // select_all/2: a partial selection FILLS UP rather than clearing — the
        // mixed state is asking to be completed. Only a full selection clears.
        val wasFull = checkedLangs().size == langs.size

        tap(parentLabel)
        compose.waitUntil(10_000) { (checkedLangs().size == langs.size) != wasFull }

        if (wasFull) {
            require(checkedLangs().isEmpty()) { "a full group did not clear: ${checkedLangs()}" }
        } else {
            require(checkedLangs().size == langs.size) {
                "a partial group did not fill up: ${checkedLangs()}"
            }
        }

        // Now it is definitely full, so the next tap must clear it.
        tap(parentLabel)
        compose.waitUntil(10_000) { checkedLangs().isEmpty() }
        require(stateOf("cg-langs-all") == "empty") { "the parent did not follow the clear" }
    }

    @Test
    fun an_item_tap_carries_its_own_id() {
        compose.onAllNodesWithText("Phoenix", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // One handler serves the group, so the id has to ride in the tag. If the
        // widening broke, the tap would land and silently do nothing.
        val before = stateOf("cg-langs-phoenix")
        val others = checkedLangs().filter { it != "phoenix" }.toSet()

        tap("Phoenix")
        compose.waitUntil(10_000) { stateOf("cg-langs-phoenix") != before }

        // And it must move ONLY that row — a reducer that rebuilds the list can
        // easily drop the others.
        require(checkedLangs().filter { it != "phoenix" }.toSet() == others) {
            "toggling phoenix disturbed the other rows"
        }

        // The summary must NAME the row the tap just moved. Accepting either
        // "Selected:" or "Nothing selected" proved nothing — summary/1 covers
        // every possible value between those two clauses, so it was already
        // true before the tap and stayed true with the handler unwired. The
        // lowercase id can only come from the summary: the labels on this page
        // are "Phoenix" and "Phoenix (off)", and showing() is case-sensitive.
        val phoenixChecked = stateOf("cg-langs-phoenix") == "checked"
        require(showing("phoenix") == phoenixChecked) {
            "the summary disagrees with the row: checked=$phoenixChecked, " +
                "summary shows phoenix=${showing("phoenix")}"
        }
    }

    @Test
    fun a_disabled_item_cannot_be_toggled() {
        compose.onAllNodesWithText("Ecto (unavailable)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Disabled wires no handler, so this must be inert rather than merely
        // grey — a control that looks disabled and still reports is the bug.
        val before = stateOf("cg-one-ecto")

        tap("Ecto (unavailable)")
        Thread.sleep(500)

        require(stateOf("cg-one-ecto") == before) { "a disabled item toggled" }
    }

    @Test
    fun a_disabled_group_cascades_to_its_parent_too() {
        compose.onAllNodesWithText("Select all (off)", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The parent is the row most likely to escape a cascade, because it is
        // built separately from the items.
        val parentBefore = stateOf("cg-off-all")
        val beamBefore = stateOf("cg-off-beam")

        tap("Select all (off)")
        Thread.sleep(500)

        require(stateOf("cg-off-all") == parentBefore) { "a disabled parent toggled" }
        require(stateOf("cg-off-beam") == beamBefore) { "a disabled group's item toggled" }
    }

    @Test
    fun a_group_without_select_all_renders_no_parent() {
        compose.onAllNodesWithText("NOTIFY ME BY", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // No parent means no parent row AND no divider — the whole block is
        // omitted rather than rendered empty.
        require(stateOf("cg-notify-email") != null) { "the plain group did not render" }
        require(stateOf("cg-notify-all") == null) { "a group without select_all grew a parent" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Select all",
            "Without a parent",
            "Disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
