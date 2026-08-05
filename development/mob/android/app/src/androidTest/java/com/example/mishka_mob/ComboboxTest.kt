package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTextReplacement
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Combobox page.
 *
 * Filtering is a pure function with its own unit tests; what a device adds is
 * everything around it — that typing actually reaches the filter, that a chip
 * shows the selection while the list is open, and that the create row appears
 * for a query no option matches.
 *
 * [typing_filters_the_list] is the whole chain: keystroke → on_query →
 * handle_change → filter/3 → re-render. A break anywhere in it looks identical
 * from the outside, and every link but the last is invisible to a unit test.
 *
 * Run with `mix e2e ComboboxTest`.
 */
@RunWith(AndroidJUnit4::class)
class ComboboxTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "text field that filters"

    /**
     * cb-one's own empty text, which nothing else on the page renders. The
     * empty state used to be checked with "No matches", which is the fourth
     * example's TITLE and the props table's printed default for `empty_text` —
     * both on screen from mount, so the wait returned on its first poll and a
     * panel that collapsed to nothing instead of saying so passed either test.
     */
    private val emptyRow = "No country by that name"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun picked(box: String, option: String): Boolean =
        tagged("$box-option-$option-selected")

    private fun listed(box: String, option: String): Boolean =
        picked(box, option) || tagged("$box-option-$option-idle")

    /**
     * A group heading, matched EXACTLY. The examples' code samples contain
     * `group: "FRUIT"` as literal text, so a substring check for a heading is
     * true whether or not the heading is rendered.
     */
    private fun heading(text: String): Boolean =
        compose.onAllNodesWithText(text, substring = false).fetchSemanticsNodes().isNotEmpty()

    private fun optionsOf(box: String, ids: List<String>): List<String> =
        ids.filter { listed(box, it) }

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
        Thread.sleep(500)
    }

    private fun typeInto(tag: String, text: String) {
        compose.onNodeWithTag(tag).performScrollTo().performTextReplacement(text)
        compose.waitForIdle()
        Thread.sleep(600)
    }

    @Before
    fun openComboboxScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Combobox", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's query and open
        // state both survive. Reset the query and open each list through its own
        // trigger — the examples now start CLOSED, like the web, rather than
        // hardcoding open={true} and standing permanently expanded.
        typeInto("cb-one-input", "")
        typeInto("cb-food-input", "")

        ensureOpen("cb-one", "ir")
        ensureOpen("cb-food", "apple")
    }

    /** Open a list through its ▾ if it is not already showing [probe]. */
    private fun ensureOpen(box: String, probe: String) {
        if (!listed(box, probe)) {
            tapTag("$box-on_toggle")
            compose.waitUntil(10_000) { listed(box, probe) }
        }
    }

    @Test
    fun typing_filters_the_list() {
        require(listed("cb-one", "de")) { "Germany is missing before filtering" }

        val all = listOf("ir", "uk", "de", "jp", "br", "se", "tr")

        typeInto("cb-one-input", "ira")
        compose.waitUntil(15_000) { optionsOf("cb-one", all) == listOf("ir") }

        // Accent- and case-insensitive: the point of fold/1.
        require(optionsOf("cb-one", all) == listOf("ir")) {
            "\"ira\" filtered to " + optionsOf("cb-one", all)
        }

        // Accents folded BOTH ways: an unaccented query finds an accented label,
        // which is what a phone keyboard actually produces.
        typeInto("cb-one-input", "turkiye")
        compose.waitUntil(15_000) { optionsOf("cb-one", all) == listOf("tr") }
        require(optionsOf("cb-one", all) == listOf("tr")) {
            "\"turkiye\" filtered to " + optionsOf("cb-one", all)
        }
    }

    @Test
    fun no_matches_says_so_rather_than_collapsing() {
        // The row has to APPEAR, so prove it is absent while the list is full —
        // otherwise a permanently-rendered row would satisfy the wait below.
        require(!showing(emptyRow)) { "the empty row is showing before any query" }

        typeInto("cb-one-input", "zzzzz")

        compose.waitUntil(10_000) { showing(emptyRow) }
        require(!listed("cb-one", "ir")) { "an option survived a query nothing matches" }
    }

    @Test
    fun the_clear_button_empties_the_query() {
        typeInto("cb-one-input", "zzzzz")

        // Gate on something only the typing can produce. Waiting for a string
        // the page renders anyway established nothing, so the ✕ was tapped with
        // the full list still up — and "the options came back" below was true
        // because they had never left. Both option tags and the empty row have
        // to agree that the query reached the filter.
        compose.waitUntil(10_000) {
            !listed("cb-one", "ir") && !listed("cb-one", "de") && showing(emptyRow)
        }

        tapTag("cb-one-on_clear")

        // Clearing restores the full list, which is the observable half.
        compose.waitUntil(10_000) { listed("cb-one", "ir") && listed("cb-one", "de") }

        // And empties the FIELD, which is what the button is named for: the
        // restored list only proves the query the filter saw is now blank, not
        // that the text the user typed is gone from the box.
        val left = compose.onNodeWithTag("cb-one-input").fetchSemanticsNode()
            .config.firstOrNull { it.key.name == "EditableText" }?.value?.toString() ?: ""
        require(left.isEmpty()) { "the ✕ left the query in the field: '$left'" }
    }

    @Test
    fun the_trigger_opens_and_closes_the_list() {
        // @Before opened it through this same button, so getting here at all is
        // half the assertion.
        require(listed("cb-one", "ir")) { "the list is not open" }

        tapTag("cb-one-on_toggle")
        compose.waitUntil(10_000) { !listed("cb-one", "ir") }

        tapTag("cb-one-on_toggle")
        compose.waitUntil(10_000) { listed("cb-one", "ir") }
    }

    @Test
    fun a_chosen_option_becomes_a_removable_chip() {
        compose.onNodeWithTag("cb-food-input").performScrollTo()
        compose.waitForIdle()


        // A chip is the only thing showing the selection while the list is open —
        // without it a multi-select is a guessing game.
        require(tagged("cb-food-chip-apple")) { "the mounted selection has no chip" }
        require(picked("cb-food", "apple")) { "the chosen option is not ticked" }

        tapTag("cb-food-chip-apple")
        compose.waitUntil(10_000) { !tagged("cb-food-chip-apple") }
        require(!picked("cb-food", "apple")) { "removing the chip left the option ticked" }

        // And picking it again brings the chip back.
        tapTag("cb-food-option-apple-idle")
        compose.waitUntil(10_000) { tagged("cb-food-chip-apple") }
    }

    @Test
    fun groups_and_disabled_options_survive_filtering() {
        compose.onNodeWithTag("cb-food-input").performScrollTo()
        compose.waitForIdle()

        require(heading("FRUIT")) { "the first group heading is missing" }
        require(heading("VEGETABLE")) { "the second group heading is missing" }

        // Options used to be flattened to {id, label}, which threw both `group`
        // and `disabled` away.
        require(listed("cb-food", "durian")) { "the disabled option did not render" }

        tapTag("cb-food-option-durian-idle")
        Thread.sleep(500)
        require(!picked("cb-food", "durian")) { "a disabled option was selectable" }

        // Filtering keeps the heading of whatever survives, and drops the rest.
        typeInto("cb-food-input", "carrot")
        compose.waitUntil(10_000) { !listed("cb-food", "apple") }
        require(heading("VEGETABLE")) { "the surviving run lost its heading" }
        require(!heading("FRUIT")) { "an empty run kept its heading" }
    }

    @Test
    fun creatable_offers_a_row_for_an_unmatched_query() {
        compose.onNodeWithTag("cb-food-input").performScrollTo()
        compose.waitForIdle()

        require(!showing("Create \"")) { "a create row showed for an empty query" }

        typeInto("cb-food-input", "Pear")
        compose.waitUntil(10_000) { showing("Create \"Pear\"") }

        tapTag("cb-food-option-create-idle")
        compose.waitUntil(15_000) { tagged("cb-food-chip-pear") }

        // The created option joins the list under its own heading, and the query
        // is cleared so the next one starts fresh.
        require(heading("CREATED")) { "the created option has no group" }
    }

    @Test
    fun an_exact_match_suppresses_the_create_row() {
        compose.onNodeWithTag("cb-food-input").performScrollTo()
        compose.waitForIdle()

        // A PARTIAL match still offers to create — the web offers "Ban" while
        // "Banana" is listed — but an exact one must not.
        typeInto("cb-food-input", "Ban")
        compose.waitUntil(10_000) { showing("Create \"Ban\"") }

        typeInto("cb-food-input", "Banana")
        compose.waitUntil(10_000) { !showing("Create \"") }
        require(listed("cb-food", "banana")) { "the exact match vanished" }
    }

    @Test
    fun tapping_the_field_opens_the_list() {
        // Close it first — @Before opens it, and "already open" proves nothing.
        tapTag("cb-one-on_toggle")
        compose.waitUntil(10_000) { !listed("cb-one", "ir") }

        // A tap into the field focuses it, and focus is what opens the list.
        // Without this a user has to find the ▾ before they can search.
        compose.onNodeWithTag("cb-one-input").performScrollTo().performClick()
        compose.waitForIdle()

        compose.waitUntil(10_000) { listed("cb-one", "ir") }
    }

    @Test
    fun typing_opens_the_list_too() {
        tapTag("cb-one-on_toggle")
        compose.waitUntil(10_000) { !listed("cb-one", "ir") }

        // Someone who taps and starts typing before the list appears must not
        // have to tap again.
        typeInto("cb-one-input", "ira")

        compose.waitUntil(10_000) { listed("cb-one", "ir") }
    }

    @Test
    fun tapping_outside_the_control_closes_the_list() {
        require(listed("cb-one", "ir")) { "the list is not open" }

        // The caption below the control is part of the card, not the combobox.
        // The list renders in flow rather than in an overlay, so nothing covers
        // the page to catch this — the screen puts an on_tap on the container,
        // and a child's own handler consumes taps on the control and its options.
        // useUnmergedTree: the container carries the on_tap, and a clickable
        // parent MERGES its children's semantics — so a merged lookup returns
        // the whole card and performClick hits its CENTRE, which is the option
        // list, whose own handler consumes the tap. The caption's own node is
        // the only thing guaranteed to be outside the control.
        compose.onAllNodesWithText("Tap the field to open it", substring = true, useUnmergedTree = true)[0]
            .performScrollTo()
            .performClick()
        compose.waitForIdle()

        compose.waitUntil(10_000) { !listed("cb-one", "ir") }
    }

    @Test
    fun picking_an_option_does_not_close_a_multiple_list() {
        ensureOpen("cb-food", "banana")

        // The backdrop must not swallow taps meant for the list, and blur must
        // not close it: a multi-select that shut on every pick would be
        // exhausting, and both mistakes look identical from here.
        val before = picked("cb-food", "banana")
        tapTag(if (before) "cb-food-option-banana-selected" else "cb-food-option-banana-idle")

        compose.waitUntil(10_000) { picked("cb-food", "banana") != before }
        require(listed("cb-food", "apple")) { "picking closed a multiple list" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Filter and choose",
            "Multiple",
            "Grouped, creatable",
            "No matches",
            "starts_with",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
