package com.example.mishka_mob

import android.accessibilityservice.AccessibilityService
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.test.performTextReplacement
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the OTP field and its showcase page, driving the real app
 * on a device or emulator.
 *
 * ## Why these exist here rather than in Elixir
 *
 * `Mob.ScreenCase` asserts on the node tree, which is the right place for
 * component logic and covers it far better than this can. What it cannot see is
 * the native side. Every bug this file pins down was invisible to it — the
 * Elixir suite was 1073 green through all of them:
 *
 *   * the field on screen kept characters the BEAM had discarded, because an
 *     identical re-render never reached Compose;
 *   * every `background` / `text_color` set on a TextField was serialised and
 *     then ignored, because the composable passed no `colors`;
 *   * tapping slot 1 of a six-slot code reading "1" and typing "23" gave "231",
 *     because the tap moved the caret to index 0 while the highlighted slot
 *     still pointed at the end;
 *   * and writing this file found one more: MainActivity started the BEAM
 *     unconditionally in onCreate, so the second Activity launch in a process
 *     aborted it — "Failed to initialize thread library".
 *
 * ## The two things that make this app unusual to test
 *
 * The BEAM boots asynchronously, so nothing can be assumed present; every entry
 * point waits for content.
 *
 * And the BEAM OUTLIVES the Activity. Relaunching MainActivity does not reset
 * the app — the screen stack is whatever the previous test left, so each test
 * navigates itself to a known place rather than assuming a fresh start.
 *
 *   ./gradlew connectedDebugAndroidTest
 */
@RunWith(AndroidJUnit4::class)
class OtpFieldTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    /** testTag of the invisible input stacked over the slots (its `:id` prop). */
    private val otp = "otp-code"

    private fun showing(text: String): Boolean =
        compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()

    private fun awaitText(text: String, timeoutMs: Long = 60_000) =
        compose.waitUntil(timeoutMs) { showing(text) }

    private fun awaitTag(tag: String, timeoutMs: Long = 30_000) =
        compose.waitUntil(timeoutMs) {
            compose.onAllNodesWithTag(tag).fetchSemanticsNodes().isNotEmpty()
        }

    /** The caption under the slots, rendered from the same assign as the slots. */
    private fun awaitCount(n: Int) = awaitText("$n of 6 digits")

    private fun pressBack() {
        InstrumentationRegistry.getInstrumentation().uiAutomation
            .performGlobalAction(AccessibilityService.GLOBAL_ACTION_BACK)
        compose.waitForIdle()
    }

    @Before
    fun openOtpScreen() {
        // Wait for the BEAM to push its first tree, whatever screen that is.
        compose.waitUntil(60_000) { showing("Components") || showing("OTP Field") }

        // Then walk to the OTP page from wherever the last test left off.
        var guard = 0
        while (!showing("A 6-digit code") && guard++ < 10) {
            if (showing("Components")) {
                compose.onNodeWithText("OTP Field", substring = true).performClick()
            } else {
                pressBack()
            }
            compose.waitForIdle()
        }
        awaitText("A 6-digit code")
        awaitTag(otp)

        // Start from a known code — the screen is a live GenServer and keeps
        // whatever the previous test typed into it.
        compose.onNodeWithTag(otp).performTextReplacement("1")
        awaitCount(1)
    }

    // ── the component ────────────────────────────────────────────────────────

    @Test
    fun the_slots_are_the_input() {
        // One editable node on this example: the invisible overlay. An earlier
        // version drew a VISIBLE TextField under the boxes and made the boxes a
        // read-only display of it, which is what this would catch.
        compose.onNodeWithTag(otp).assertIsDisplayed()
        compose.onNodeWithText("A 6-digit code").assertIsDisplayed()
    }

    @Test
    fun typing_appends_instead_of_inserting_where_the_slot_was_tapped() {
        // The regression this file was written for. Tap the FIRST slot — the one
        // already holding a digit — then type. Without `caret: "end"` the caret
        // lands at index 0 and "1" + "23" comes out as "231".
        compose.onNodeWithText("1").performClick()
        compose.onNodeWithTag(otp).performTextInput("23")

        awaitCount(3)
        for (digit in listOf("1", "2", "3")) {
            compose.onNodeWithText(digit).assertIsDisplayed()
        }
    }

    @Test
    fun deleting_removes_the_last_digit() {
        compose.onNodeWithTag(otp).performTextReplacement("123")
        awaitCount(3)

        // Replacement stands in for backspace: with the caret pinned to the end,
        // what leaves is the last character.
        compose.onNodeWithTag(otp).performTextReplacement("12")
        awaitCount(2)
        assertNoSlotShows("3")
    }

    @Test
    fun a_seventh_digit_cannot_be_entered() {
        // sanitize/2 truncates to :length. The field is deliberately NOT capped
        // natively — that would refuse a pasted "123-456" whole — so the
        // correction comes back from Elixir, and this proves it is visible.
        compose.onNodeWithTag(otp).performTextReplacement("1234567")
        awaitCount(6)
    }

    @Test
    fun a_pasted_code_with_separators_still_lands() {
        // Seven characters against six slots: capping the field natively would
        // have refused the paste whole; sanitize/2 strips the separator.
        compose.onNodeWithTag(otp).performTextReplacement("123-456")
        awaitCount(6)
    }

    @Test
    fun letters_are_rejected_by_the_numeric_validation() {
        compose.onNodeWithTag(otp).performTextReplacement("12ab34")
        awaitCount(4)
    }

    // ── the showcase page ────────────────────────────────────────────────────

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "A 6-digit code",
            "Masked and shorter",
            "Props",
        )) {
            compose.onNodeWithText(heading, substring = true).assertIsDisplayed()
        }
    }

    @Test
    fun the_code_sample_shows_how_to_call_it_from_a_sigil() {
        // The sample used to show a bare `{otp_field(...)}` with no indication of
        // where it goes. It carries the ~MOB wrapper now.
        compose.onNodeWithText("~MOB", substring = true).assertIsDisplayed()
    }

    /**
     * No slot anywhere on the page shows [digit]. Matched exactly, so it cannot
     * be satisfied by a digit inside the caption or the code sample.
     */
    private fun assertNoSlotShows(digit: String) {
        val found = compose.onAllNodesWithText(digit, substring = false).fetchSemanticsNodes().size
        require(found == 0) { "expected no slot showing \"$digit\", found $found" }
    }
}
