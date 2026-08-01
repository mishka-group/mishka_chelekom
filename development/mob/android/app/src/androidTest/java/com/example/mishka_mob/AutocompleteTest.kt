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
 * End-to-end tests for the Autocomplete page.
 *
 * An autocomplete differs from a combobox in one respect, and it is the one
 * worth driving: the QUERY is the value. Choosing a suggestion fills the field
 * in rather than selecting an id, and the panel then has nothing left to say.
 *
 * [choosing_fills_the_field_and_closes] and
 * [an_exactly_typed_suggestion_leaves_no_dead_panel] are the two halves of that.
 * The second guards a bug this page used to have: the whole option list was
 * blanked once the query matched exactly, so the still-open panel showed
 * "No suggestions" — false, and nothing could dismiss it.
 *
 * Run with `mix e2e AutocompleteTest`.
 */
@RunWith(AndroidJUnit4::class)
class AutocompleteTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "text field that suggests"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    /** Is [city] offered by the [box] autocomplete right now? */
    private fun offered(box: String, city: String): Boolean =
        tagged("$box-option-$city-idle") || tagged("$box-option-$city-selected")

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
    fun openAutocompleteScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Autocomplete", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's text survives.
        // Clearing is TYPING, and typing opens the panel — so close it again,
        // or every test starts from a state the first one is asserting against.
        typeInto("ac-city-input", "")
        closeCard()
    }

    /** Tap the caption inside the first card's backdrop. */
    private fun closeCard() {
        compose.onAllNodesWithText("Tap the field to open it", substring = true, useUnmergedTree = true)[0]
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    @Test
    fun the_panel_is_closed_until_the_field_is_tapped() {
        // It used to be pinned open={true}, standing permanently expanded with
        // every city listed before the user touched anything.
        require(!offered("ac-city", "Tehran")) { "the panel started open" }

        // Park focus on the OTHER field first. on_focus fires on a focus CHANGE,
        // and @Before cleared this one by typing — which left it focused — so a
        // tap on an already-focused field is a no-op and opens nothing. That is
        // a property of focus events, not of this component, and it is why a
        // real user never hits it: they were not already in the field.
        compose.onNodeWithTag("ac-any-input").performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
        closeCard()

        require(!offered("ac-city", "Tehran")) { "the panel opened without a tap" }

        compose.onNodeWithTag("ac-city-input").performScrollTo().performClick()
        compose.waitForIdle()

        compose.waitUntil(10_000) { offered("ac-city", "Tehran") }
    }

    @Test
    fun typing_filters_by_PREFIX_by_default() {
        typeInto("ac-city-input", "te")

        // :starts_with is the default, which is what "autocomplete" means — a
        // combobox defaults to :contains.
        compose.waitUntil(10_000) { offered("ac-city", "Tehran") }
        require(!offered("ac-city", "Istanbul")) { "prefix mode matched mid-word" }
    }

    @Test
    fun choosing_fills_the_field_and_closes() {
        typeInto("ac-city-input", "te")
        compose.waitUntil(10_000) { offered("ac-city", "Tehran") }

        tapTag("ac-city-option-Tehran-idle")

        // The query IS the value: the suggestion's TEXT lands in the field.
        compose.waitUntil(10_000) { !offered("ac-city", "Tehran") }
        require(showing("Tehran")) { "the chosen suggestion did not fill the field" }
    }

    @Test
    fun an_exactly_typed_suggestion_leaves_no_dead_panel() {
        typeInto("ac-city-input", "Tehran")
        Thread.sleep(600)

        // The panel used to blank its whole option list here and then draw
        // "No suggestions" — which is false, and which nothing could dismiss
        // because there was no trigger, no focus wiring and no backdrop.
        require(!showing("No suggestions")) {
            "typing the answer produced a false empty panel"
        }
    }

    @Test
    fun a_query_nothing_matches_still_says_so() {
        typeInto("ac-city-input", "zzzzz")

        // The empty panel is information HERE — the distinction the fix turns on.
        compose.waitUntil(10_000) { showing("No suggestions") }
    }

    @Test
    fun tapping_outside_closes_the_panel() {
        typeInto("ac-city-input", "te")
        compose.waitUntil(10_000) { offered("ac-city", "Tehran") }

        // The caption, NOT the example's title: the title is rendered by the
        // screen OUTSIDE the container that carries the backdrop, so tapping it
        // is not "inside the card" at all. useUnmergedTree because a clickable
        // parent merges its children — a merged lookup returns the whole card
        // and clicks its centre, which is the panel itself.
        closeCard()

        compose.waitUntil(10_000) { !offered("ac-city", "Tehran") }
    }

    @Test
    fun the_two_examples_no_longer_move_in_lockstep() {
        typeInto("ac-city-input", "te")
        Thread.sleep(500)

        // They shared one assign, so typing in either rewrote the other's field.
        val other = compose.onNodeWithTag("ac-any-input").fetchSemanticsNode()
            .config.firstOrNull { it.key.name == "EditableText" }?.value?.toString() ?: ""

        require(other != "te") { "the second field mirrored the first: '$other'" }
    }

    @Test
    fun the_pills_picker_adds_on_tap_and_removes_on_a_second_tap() {
        compose.onNodeWithTag("ac-pills-draft").performScrollTo().performClick()
        compose.waitForIdle()
        compose.waitUntil(10_000) { tagged("ac-pick-Grace Hopper-idle") }

        // Tapping a name adds it as a pill.
        tapTag("ac-pick-Grace Hopper-idle")
        compose.waitUntil(10_000) { tagged("ac-pick-Grace Hopper-selected") }

        // Tapping the SAME name again removes it. One clause does both, which is
        // also what makes a duplicate impossible rather than a rule enforced
        // separately on each path and forgotten on one of them.
        tapTag("ac-pick-Grace Hopper-selected")
        compose.waitUntil(10_000) { tagged("ac-pick-Grace Hopper-idle") }
    }

    @Test
    fun the_same_person_cannot_be_added_twice() {
        compose.onNodeWithTag("ac-pills-draft").performScrollTo().performClick()
        compose.waitForIdle()
        compose.waitUntil(10_000) { tagged("ac-pick-Alan Turing-idle") }

        tapTag("ac-pick-Alan Turing-idle")
        compose.waitUntil(10_000) { tagged("ac-pick-Alan Turing-selected") }

        // One pill, not two — count the pills carrying that exact label.
        val pills = compose.onAllNodesWithText("Alan Turing", substring = false)
            .fetchSemanticsNodes().size

        tapTag("ac-pick-Alan Turing-selected")
        compose.waitUntil(10_000) { tagged("ac-pick-Alan Turing-idle") }

        tapTag("ac-pick-Alan Turing-idle")
        compose.waitUntil(10_000) { tagged("ac-pick-Alan Turing-selected") }

        require(
            compose.onAllNodesWithText("Alan Turing", substring = false)
                .fetchSemanticsNodes().size == pills
        ) { "adding the same person again produced a second pill" }
    }

    @Test
    fun typing_filters_the_pills_picker() {
        compose.onNodeWithTag("ac-pills-draft").performScrollTo().performClick()
        compose.waitForIdle()
        compose.waitUntil(10_000) { tagged("ac-pick-Ada Lovelace-selected") }

        typeInto("ac-pills-draft", "gra")

        compose.waitUntil(10_000) { tagged("ac-pick-Grace Hopper-idle") }
        require(!tagged("ac-pick-Alan Turing-idle")) { "the picker did not filter" }

        typeInto("ac-pills-draft", "")
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Suggest as you type",
            "Contains matching",
            "Pills input",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
