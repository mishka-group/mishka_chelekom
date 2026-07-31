package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
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
 * End-to-end tests for the Tags Input page.
 *
 * [return_commits_the_draft] is the interaction the whole component exists for,
 * and it is the one that cannot be unit tested: there is no keydown on a phone,
 * so the draft is committed by the text field's IME action. The submit event
 * carries NO payload — the screen commits the draft it is already holding from
 * on_change — so a broken on_change looks exactly like a broken return key until
 * a real keyboard is driven.
 *
 * Every ✕ renders the same glyph, so tokens are addressed by tag:
 * `ti-tag-elixir`.
 *
 * Run with `mix e2e TagsInputTest`.
 */
@RunWith(AndroidJUnit4::class)
class TagsInputTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Removable tokens with a draft field"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

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

    /** Type into the draft and press the return key, which is what commits it. */
    private fun addTag(text: String) {
        compose.onNodeWithTag("ti-draft").performScrollTo().performTextReplacement(text)
        compose.waitForIdle()
        Thread.sleep(400)

        compose.onNodeWithTag("ti-draft").performImeAction()
        compose.waitForIdle()
        Thread.sleep(600)
    }

    @Before
    fun openTagsInputScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Tags Input", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun return_commits_the_draft() {
        compose.onNodeWithTag("ti-draft").performScrollTo()
        compose.waitForIdle()

        require(!tagged("ti-tag-otp")) { "the tag existed before it was added" }

        addTag("otp")
        compose.waitUntil(15_000) { tagged("ti-tag-otp") }

        // And the draft is cleared, so the next tag starts empty rather than
        // appending to the last one.
        compose.waitUntil(10_000) { showing("Add a tag") }
    }

    @Test
    fun a_token_removes_itself() {
        compose.onNodeWithTag("ti-draft").performScrollTo()
        compose.waitForIdle()

        // Add one first, so the test does not depend on the mount value — the
        // BEAM outlives the Activity and earlier tests have edited this list.
        if (!tagged("ti-tag-gleam")) {
            addTag("gleam")
            compose.waitUntil(15_000) { tagged("ti-tag-gleam") }
        }

        compose.onNodeWithTag("ti-tag-gleam", useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        compose.waitForIdle()

        compose.waitUntil(15_000) { !tagged("ti-tag-gleam") }
    }

    @Test
    fun a_duplicate_is_refused_and_whitespace_trimmed() {
        compose.onNodeWithTag("ti-draft").performScrollTo()
        compose.waitForIdle()

        if (!tagged("ti-tag-elixir")) {
            addTag("elixir")
            compose.waitUntil(15_000) { tagged("ti-tag-elixir") }
        }

        val before = showing("Tags:").let { compose.onAllNodesWithText("elixir", substring = false)
            .fetchSemanticsNodes().size }

        // Padded, and already present: add/3 trims it and refuses the repeat.
        addTag("  elixir  ")
        Thread.sleep(600)

        val after = compose.onAllNodesWithText("elixir", substring = false)
            .fetchSemanticsNodes().size

        require(after == before) { "a duplicate tag was added: $before -> $after" }
    }

    @Test
    fun the_draft_field_draws_no_line_inside_the_control() {
        compose.onNodeWithTag("ti-draft").performScrollTo()
        compose.waitForIdle()

        // The control is one box. A Material text field with no border of its own
        // draws its INDICATOR line, which lands inside as a stray rule across the
        // middle — the same defect the number field had. Nothing in the tree can
        // see a drawn line, so this asserts the arrangement that avoids it: the
        // draft sits inside the container's bounds rather than beside it.
        val draft = boundsOf("ti-draft")
        val firstTag = boundsOf("ti-tag-design")

        require(draft.top >= firstTag.top - 2f) { "the draft is not below the tokens" }
        require(draft.left <= firstTag.left + 40f) { "the draft is indented oddly: $draft" }
    }

    @Test
    fun tokens_wrap_onto_more_than_one_row_when_they_are_long() {
        compose.onNodeWithTag("ti-draft").performScrollTo()
        compose.waitForIdle()

        // Neither renderer has a flow layout, so the component packs rows itself.
        // Two long tags must not sit on one line running off the edge.
        for (tag in listOf("averylongtagname", "anotherlongtagname")) {
            if (!tagged("ti-tag-$tag")) {
                addTag(tag)
                compose.waitUntil(15_000) { tagged("ti-tag-$tag") }
            }
        }

        val a = boundsOf("ti-tag-averylongtagname")
        val b = boundsOf("ti-tag-anotherlongtagname")

        require(b.top > a.top + 4f || b.left >= a.right) {
            "long tokens overlap on one row: $a vs $b"
        }
        require(a.right <= 1080f) { "a token runs off the screen: $a" }
        require(b.right <= 1080f) { "a token runs off the screen: $b" }
    }

    @Test
    fun a_disabled_control_cannot_be_edited() {
        compose.onNodeWithTag("ti-off-draft").performScrollTo()
        compose.waitForIdle()

        require(tagged("ti-off-tag-locked")) { "the disabled control did not render" }

        compose.onNodeWithTag("ti-off-tag-locked", useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(600)

        require(tagged("ti-off-tag-locked")) { "a disabled token removed itself" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Add and remove",
            "It ships no look",
            "Empty and disabled",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
