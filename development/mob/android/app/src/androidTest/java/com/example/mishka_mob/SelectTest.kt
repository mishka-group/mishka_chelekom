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
 * End-to-end tests for the Select page.
 *
 * The two behaviours that separate a select from a menu are both about what
 * happens AFTER a pick: single mode replaces the value and closes the list,
 * multiple accumulates and stays open. `toggle/3` returns `{value, close?}` for
 * exactly that reason, and a screen that ignores the second element gets a
 * multi-select that slams shut after every tap.
 *
 * A chosen option is marked with a ✓, and a glyph cannot be attributed to one
 * row among several — so state rides in the tags: `sel-pizza-option-onion-selected`.
 *
 * Run with `mix e2e SelectTest`.
 */
@RunWith(AndroidJUnit4::class)
class SelectTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "trigger showing the current choice"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun open(select: String): Boolean = tagged("$select-trigger-open")

    private fun picked(select: String, option: String): Boolean =
        tagged("$select-option-$option-selected")

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

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

    /** Open a select if it is not already open. */
    private fun openIt(select: String) {
        if (!open(select)) {
            tapTag("$select-trigger-closed")
            compose.waitUntil(10_000) { open(select) }
        }
    }

    private fun closeIt(select: String) {
        if (open(select)) {
            tapTag("$select-trigger-open")
            compose.waitUntil(10_000) { !open(select) }
        }
    }

    @Before
    fun openSelectScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Select", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // Leave every list closed, so each test starts from the same shape —
        // the BEAM outlives the Activity and open? survives between tests.
        for (select in listOf("sel-country", "sel-lang", "sel-pizza")) {
            closeIt(select)
        }
    }

    @Test
    fun the_list_is_hidden_until_the_trigger_is_tapped() {
        compose.onNodeWithTag("sel-country-trigger-closed").performScrollTo()
        compose.waitForIdle()

        // Closed means the options are not merely hidden — they are not rendered.
        require(!tagged("sel-country-option-uk-idle")) { "options exist while closed" }
        require(!tagged("sel-country-option-uk-selected")) { "options exist while closed" }

        openIt("sel-country")
        require(tagged("sel-country-option-uk-idle") || tagged("sel-country-option-uk-selected")) {
            "opening did not render the options"
        }
    }

    @Test
    fun single_mode_replaces_the_value_and_CLOSES() {
        openIt("sel-country")

        tapTag("sel-country-option-ir-idle")

        // Both halves matter. toggle/3 returns {value, close?} precisely so the
        // screen can do this, and a screen that drops close? leaves the list
        // hanging open over the rest of the page.
        compose.waitUntil(10_000) { !open("sel-country") }
        require(showing("Iran")) { "the trigger did not show the new choice" }

        openIt("sel-country")
        require(picked("sel-country", "ir")) { "the chosen option is not ticked" }
        require(!picked("sel-country", "uk")) { "single mode kept a second choice" }

        // And picking another REPLACES rather than accumulating.
        tapTag("sel-country-option-de-idle")
        compose.waitUntil(10_000) { !open("sel-country") }
        openIt("sel-country")

        require(picked("sel-country", "de")) { "the new choice is not ticked" }
        require(!picked("sel-country", "ir")) { "single mode accumulated two values" }
    }

    @Test
    fun multiple_mode_accumulates_and_STAYS_OPEN() {
        openIt("sel-pizza")

        val before = picked("sel-pizza", "onion")

        tapTag(if (before) "sel-pizza-option-onion-selected" else "sel-pizza-option-onion-idle")
        compose.waitUntil(10_000) { picked("sel-pizza", "onion") != before }

        // The whole point: a multi-select that closed after every pick would be
        // exhausting, so the list must still be open.
        require(open("sel-pizza")) { "the list closed after a pick in multiple mode" }

        // And the other choice is untouched — picking adds rather than replaces.
        require(picked("sel-pizza", "pepperoni")) { "picking onion cleared pepperoni" }
    }

    @Test
    fun groups_put_a_heading_above_each_run() {
        openIt("sel-pizza")

        require(showing("CLASSIC")) { "the first group heading is missing" }
        require(showing("VEGGIE")) { "the second group heading is missing" }

        // A heading belongs to the run BELOW it: Cheese and Pepperoni sit under
        // CLASSIC, Mushroom and Onion under VEGGIE. Order is the grouping.
        //
        // Scroll the LAST of the three into view first. Anything still below the
        // fold reports zero bounds, and comparing a real y against 0 would make
        // this pass or fail on scroll position rather than on grouping.
        val pepperoniTag =
            if (picked("sel-pizza", "pepperoni")) "sel-pizza-option-pepperoni-selected"
            else "sel-pizza-option-pepperoni-idle"

        compose.onAllNodesWithText("VEGGIE", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        val classic = compose.onAllNodesWithText("CLASSIC", substring = false)
            .fetchSemanticsNodes().first().boundsInRoot
        val veggie = compose.onAllNodesWithText("VEGGIE", substring = false)
            .fetchSemanticsNodes().first().boundsInRoot

        val pepperoni = boundsOf(pepperoniTag)

        require(pepperoni.top > classic.top) { "Pepperoni is not under CLASSIC" }
        require(pepperoni.top < veggie.top) { "Pepperoni fell under VEGGIE" }
    }

    @Test
    fun the_trigger_shows_the_placeholder_when_nothing_is_chosen() {
        openIt("sel-lang")

        // Clear whatever earlier runs left behind.
        for (lang in listOf("elixir", "erlang", "gleam")) {
            if (picked("sel-lang", lang)) {
                tapTag("sel-lang-option-$lang-selected")
                compose.waitUntil(10_000) { !picked("sel-lang", lang) }
            }
        }

        require(showing("Choose any")) { "an empty multi-select lost its placeholder" }

        // And a choice replaces the placeholder with the label.
        tapTag("sel-lang-option-elixir-idle")
        compose.waitUntil(10_000) { picked("sel-lang", "elixir") }
        require(showing("Elixir")) { "the trigger did not show the chosen label" }
    }

    @Test
    fun a_disabled_select_cannot_open() {
        compose.onNodeWithTag("sel-off-trigger-closed").performScrollTo()
        compose.waitForIdle()

        tapTag("sel-off-trigger-closed")
        Thread.sleep(500)

        require(!tagged("sel-off-trigger-open")) { "a disabled select opened" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Single choice",
            "Multiple",
            "Grouped",
            "Disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
