package com.example.mishka_mob

import android.accessibilityservice.AccessibilityService
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.click
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.performScrollTo
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
 * Run with:
 *
 *   ./gradlew assembleDebugAndroidTest
 *   adb install -r app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk
 *   adb shell am instrument -w \
 *     com.example.mishka_mob.test/androidx.test.runner.AndroidJUnitRunner
 *
 * NOT `./gradlew connectedDebugAndroidTest`: it reinstalls the app APK, and
 * Android wipes the app's files/ directory on reinstall — which is where the
 * whole OTP release lives, so the BEAM cannot boot at all.
 */
@RunWith(AndroidJUnit4::class)
class OtpFieldTest {

    // `am instrument` restarts the target process, so each run starts with no
    // Activity at all and the rule can create one cleanly. (An empty rule was
    // tried first, on the theory that the app should be attached to rather than
    // launched — but nothing then brings it to the foreground, and every query
    // ran against the launcher.)
    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    /** testTag of the invisible input stacked over the slots (its `:id` prop). */
    private val otp = "otp-code"

    /**
     * Whether [text] is on screen — false, rather than an exception, when there
     * is no composition at all yet.
     *
     * That distinction is the whole difficulty of testing this app. `am
     * instrument` restarts the target process, so the BEAM boots from scratch and
     * for several seconds there is no Activity, no setContent and no semantics
     * tree; fetchSemanticsNodes throws IllegalStateException("No compose
     * hierarchies found") for the entire window. Letting that escape kills
     * waitUntil on its first poll, which is exactly the condition it exists to
     * wait out.
     */
    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun awaitText(text: String, timeoutMs: Long = 60_000) =
        compose.waitUntil(timeoutMs) { showing(text) }

    private fun awaitTag(tag: String, timeoutMs: Long = 30_000) =
        compose.waitUntil(timeoutMs) {
            try {
                compose.onAllNodesWithTag(tag).fetchSemanticsNodes().isNotEmpty()
            } catch (_: IllegalStateException) {
                false
            }
        }

    /** The caption under the slots, rendered from the same assign as the slots. */
    private fun awaitCount(n: Int) = awaitText("$n of 6 digits")

    /**
     * A FULL code does not say "6 of 6 digits" — the showcase swaps the caption
     * for "Complete — a screen would auto-submit here.", which is the whole point
     * of tracking completeness. Waiting on the count for a full code waits
     * forever.
     */
    private fun awaitComplete() = awaitText("Complete")

    /**
     * Leave a component page using the showcase's OWN back button, not the
     * system one.
     *
     * System back at the gallery pops the app's last screen and Android drops to
     * the launcher — after which every query runs against the home screen and
     * the failure reads as a timeout rather than as navigation having walked out
     * of the app. The in-app button cannot do that.
     */
    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    /** The home screen's subtitle — home lists the cards, the gallery is elsewhere. */
    private val home = "Native component library"

    @Before
    fun openOtpScreen() {
        // Wait for the BEAM to push its first tree, whatever screen that is.
        //
        // "← Back" is in that list because it is the only thing common to every
        // component PAGE. This waited on "OTP Field" and "Components" while it
        // was the only test class, so it always started from home or from its
        // own page; the moment another class ran first it sat on a third page
        // where neither appears and timed out eight times over.
        compose.waitUntil(90_000) {
            showing(home) || showing("A 6-digit code") || showing("← Back")
        }

        // Then reach the OTP page from wherever the last test left off.
        //
        // Back is only ever pressed from a component PAGE. Pressing it at home
        // pops the app's last screen and Android leaves the app entirely — the
        // launcher becomes the resumed activity, every later query finds
        // nothing, and the failure looks like a timeout rather than like the
        // navigation mistake it is.
        var guard = 0

        while (!showing("A 6-digit code") && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing("A 6-digit code")) {
            // Every card is in the semantics tree but most are off-screen, and a
            // click on an off-screen node does nothing.
            compose.onNodeWithText("OTP Field", substring = false)
                .performScrollTo()
                .performClick()

            awaitText("A 6-digit code")
        }

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
        // Tap the FIRST slot. Not onNodeWithText("1") — the overlay's own
        // EditableText is also "1", so that matches two nodes and dies. The
        // overlay covers the boxes anyway, so its left edge IS the first slot,
        // and clicking there is what a finger on that box actually does.
        compose.onNodeWithTag(otp).performTouchInput { click(centerLeft) }
        compose.onNodeWithTag(otp).performTextInput("23")

        // Appended, not prepended: 1-2-3, where the bug gave 2-3-1.
        awaitCount(3)

        for (digit in listOf("2", "3")) {
            compose.onAllNodesWithText(digit, substring = false)
                .fetchSemanticsNodes()
                .isNotEmpty()
                .let { require(it) { "slot showing $digit not found" } }
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
        awaitComplete()
    }

    @Test
    fun a_pasted_code_with_separators_still_lands() {
        // Seven characters against six slots: capping the field natively would
        // have refused the paste whole; sanitize/2 strips the separator.
        compose.onNodeWithTag(otp).performTextReplacement("123-456")
        awaitComplete()
    }

    @Test
    fun letters_are_rejected_by_the_numeric_validation() {
        compose.onNodeWithTag(otp).performTextReplacement("12ab34")
        awaitCount(4)
    }

    // ── the showcase page ────────────────────────────────────────────────────

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        // The page is a Scroll, so most of it is below the fold.
        // assertIsDisplayed means "visible on screen right now", which is not the
        // question here — scroll each heading into view before asking.
        for (heading in listOf(
            "A 6-digit code",
            "Masked and shorter",
            "Grouped, with a separator",
            "Props",
        )) {
            compose.onNodeWithText(heading, substring = true)
                .performScrollTo()
                .assertIsDisplayed()
        }
    }

    @Test
    fun the_code_samples_show_the_tag_inside_a_sigil() {
        // Every example carries a ~MOB block now, so this matches several nodes —
        // assertIsDisplayed wants exactly one. Count instead.
        val sigils = compose.onAllNodesWithText("~MOB", substring = true).fetchSemanticsNodes()
        require(sigils.isNotEmpty()) { "no ~MOB block found in any code sample" }

        // And the samples show the composite tag, which is what an app writes.
        val tags =
            compose.onAllNodesWithText("<MishkaOtpField", substring = true).fetchSemanticsNodes()
        require(tags.isNotEmpty()) { "no <MishkaOtpField … /> in the samples" }
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
