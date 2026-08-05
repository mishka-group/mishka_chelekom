package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performImeAction
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTextReplacement
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Field page.
 *
 * A field is mostly wiring, and the wiring only shows up when a real user types
 * into it — which is why this suite drives the keyboard rather than inspecting
 * the tree.
 *
 * [errors_stay_hidden_until_you_touch_a_field] is the behaviour the web calls
 * `used_input?`. A form that scolds you about six fields before you have typed
 * anything is the default outcome of "just render the changeset errors", and
 * nothing in a unit test notices the difference.
 *
 * [an_error_replaces_the_hint] is the component's one real rule: showing
 * "we'll never share this" directly above "email is invalid" buries the thing
 * the user has to act on.
 *
 * Run with `mix e2e FieldTest`.
 */
@RunWith(AndroidJUnit4::class)
class FieldTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "labelled control with a description"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

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
     * Type into the field carrying [tag].
     *
     * NOT by placeholder: a placeholder is only in the tree while the field is
     * EMPTY, so the second edit of the same field finds nothing. That is a
     * property of every Compose TextField, and it made three tests here fail
     * with "there are no existing nodes for that selector" before the showcase
     * gave its inputs ids.
     */
    private fun typeInto(tag: String, text: String) {
        compose.onNodeWithTag(tag).performScrollTo().performTextReplacement(text)
        compose.waitForIdle()
        Thread.sleep(500)
    }

    @Before
    fun openFieldScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Field", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // Every test starts from a clean form — the BEAM outlives the Activity,
        // so a previous test's typing and its submitted? flag both survive.
        // WAIT for it to land: a tap is a round-trip to the BEAM and back, and
        // a fixed sleep let the first assertion race the re-render.
        if (showing("Reset")) {
            tap("Reset")
            compose.waitUntil(15_000) { !showing("Required.") && !showing("Pick a role.") }
        }
    }

    @Test
    fun errors_stay_hidden_until_you_touch_a_field() {
        compose.onAllNodesWithText("Full name", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Freshly reset: every field is empty and therefore invalid, but the user
        // has typed nothing, so the form must be silent.
        require(!showing("At least 2 characters")) { "an untouched field is already complaining" }
        require(!showing("That does not look like an email")) {
            "an untouched email field is already complaining"
        }

        // Touching ONE field reveals its error and only its error.
        typeInto("fld-name", "A")
        compose.waitUntil(10_000) { showing("At least 2 characters") }

        require(!showing("That does not look like an email")) {
            "touching the name field revealed the email field's error"
        }
    }

    @Test
    fun submitting_reveals_every_error_at_once() {
        compose.onAllNodesWithText("Create account", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        require(!showing("Pick a role")) { "the role error showed before submit" }

        tap("Create account")
        compose.waitUntil(10_000) { showing("Pick a role") }

        // Submit touches everything, so the fields the user never reached speak up.
        require(showing("Required.")) { "submit did not reveal the untouched name/email errors" }
    }

    @Test
    fun an_error_replaces_the_hint() {
        compose.onAllNodesWithText("Email address", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // The hint is visible while the field is clean.
        require(showing("only use this to send account notifications")) {
            "the email hint is not showing"
        }

        typeInto("fld-email", "nope")
        compose.waitUntil(10_000) { showing("That does not look like an email") }

        // And the hint is GONE — not merely pushed below the error.
        require(!showing("only use this to send account notifications")) {
            "the hint survived alongside the error"
        }
    }

    @Test
    fun a_valid_form_reports_itself_valid() {
        compose.onAllNodesWithText("Full name", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // Assert field by field rather than only at the end: a single "it never
        // said valid" failure cannot tell you WHICH field refused the input.
        typeInto("fld-name", "Ada Lovelace")
        require(!showing("At least 2 characters")) { "the name field rejected a valid name" }

        typeInto("fld-email", "ada@example.com")
        require(!showing("That does not look like an email")) {
            "the email field rejected a valid address"
        }

        typeInto("fld-age", "36")
        require(!showing("Must be 18 or older")) { "the age field rejected 36" }
        require(!showing("Digits only")) { "the age field did not receive digits" }

        compose.onNodeWithTag("fld-age").performImeAction()
        compose.waitForIdle()
        Thread.sleep(500)

        tap("Owner")
        compose.waitUntil(10_000) { tagged("fld-role-owner-selected") }

        // No submit tap here on purpose. The summary tracks validity live, so
        // filling the form is enough to prove the rules accept it — and a
        // synthetic click on a button that typing has just pushed under the soft
        // keyboard is unreliable in this harness. The submit PATH is covered by
        // submitting_reveals_every_error_at_once, which starts from a clean form.
        //
        // "Ready to submit", not "Valid": the props table contains "Validation
        // messages", so a substring check on "Valid" is true on a page nobody
        // has touched — that assertion would have passed either way.
        compose.waitUntil(15_000) { showing("Ready to submit") }

        // Every entry below has to name an error and nothing else the page
        // renders. The bio entry read "Up to 160 characters", which is verbatim
        // the bio field's permanently visible hint, so the diagnostic accused
        // bio on every single failure no matter what had actually gone wrong.
        // The showcase now words that error "At most 160 characters.", the way
        // the name field already worded its own length error.
        require(showing("Ready to submit")) {
            "a fully filled form still reports errors: " +
                listOf(
                    "Required.",
                    "At least 2 characters",
                    "does not look like an email",
                    "Must be 18 or older",
                    "Digits only",
                    "Pick a role.",
                    "At most 160 characters",
                ).filter { showing(it) }
        }

        // Optional fields stay optional: bio and age were left alone by the
        // valid path above, and a submitted form must not invent errors for them.
        require(!showing("Required.")) { "a valid form still reports required fields" }

        // And bio specifically, which nothing here asserted before: while its
        // error and its hint were the same sentence, this line could not have
        // been written — the hint held it false whatever the validator did.
        require(!showing("At most 160 characters")) {
            "an empty bio was reported as too long"
        }
    }

    @Test
    fun the_age_field_is_optional_but_validated_when_filled() {
        compose.onAllNodesWithText("Age", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        typeInto("fld-age", "12")
        compose.waitUntil(10_000) { showing("Must be 18 or older") }

        // Blank is fine — an optional field must not complain when cleared.
        typeInto("fld-age", "")
        compose.waitUntil(10_000) { !showing("Must be 18 or older") }
    }

    @Test
    fun the_role_picker_records_a_choice() {
        compose.onAllNodesWithText("Role", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        // A <select> on the web is a segmented control here; its selection is a
        // fill colour, so the state rides in the testTag.
        require(!tagged("fld-role-admin-selected")) { "a role was already chosen" }

        tap("Admin")
        compose.waitUntil(10_000) { tagged("fld-role-admin-selected") }

        require(!showing("Pick a role.")) { "the role error survived a valid choice" }
    }

    @Test
    fun reset_clears_the_form_and_re_hides_the_errors() {
        compose.onAllNodesWithText("Full name", substring = false)[0].performScrollTo()
        compose.waitForIdle()

        typeInto("fld-name", "A")
        compose.waitUntil(10_000) { showing("At least 2 characters") }

        compose.onAllNodesWithText("Reset", substring = false)[0].performScrollTo()
        tap("Reset")

        // Reset clears the touched set as well as the values, so the form goes
        // quiet again rather than complaining about the fields it just emptied.
        compose.waitUntil(10_000) { !showing("At least 2 characters") }
        require(!showing("Required.")) { "reset left the form scolding an untouched user" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Label, hint and required",
            "Errors replace the hint",
            "A whole form",
            "Disabled",
            "Fieldset",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
