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
        typeInto("cb-one-input", "zzzzz")

        compose.waitUntil(10_000) { showing("No matches") }
        require(!listed("cb-one", "ir")) { "an option survived a query nothing matches" }
    }

    @Test
    fun the_clear_button_empties_the_query() {
        typeInto("cb-one-input", "zzzzz")
        compose.waitUntil(10_000) { showing("No matches") }

        tapTag("cb-one-on_clear")

        // Clearing restores the full list, which is the observable half.
        compose.waitUntil(10_000) { listed("cb-one", "ir") && listed("cb-one", "de") }
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
