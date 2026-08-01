package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsNotEnabled
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
 * End-to-end tests for the JSON Input page.
 *
 * The error state is conveyed by COLOUR — a reddened border and a red message —
 * and a device test cannot read a colour. What it can read is everything that
 * failed when the colour token was wrong: the field used the token `:danger`,
 * which existed in no theme and no fallback palette, so it reached the renderer
 * as the string "danger". A border needs BOTH a colour and a width, so invalid
 * JSON did not redden the box, it DELETED the box's outline — which is a
 * measurable geometric change, and that is what [an_invalid_field_keeps_its_box]
 * asserts.
 *
 * Run with `mix e2e JsonInputTest`.
 */
@RunWith(AndroidJUnit4::class)
class JsonInputTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    // The page's own description, verbatim from `entry/0` — not the usage
    // rule's wording, which is what the first version of this file waited for.
    private val page = "A validated JSON textarea"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    /**
     * The error message belonging to ONE field.
     *
     * The page permanently renders an *Invalid* example, so its parser message
     * is on screen from the moment the page mounts. A page-wide
     * [showing]("unexpected byte") is therefore true before a test types
     * anything — which made [blank_is_not_an_error] fail for the wrong reason
     * and made two other tests pass while asserting nothing. Ask the field.
     */
    private fun errorOf(id: String): String? =
        compose.onAllNodesWithTag("$id-error", useUnmergedTree = true)
            .fetchSemanticsNodes()
            .firstOrNull()
            ?.config
            ?.getOrNull(SemanticsProperties.Text)
            ?.joinToString("") { it.text }

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

    private fun typeInto(tag: String, text: String) {
        compose.onNodeWithTag(tag).performScrollTo().performTextReplacement(text)
        compose.waitForIdle()
        Thread.sleep(600)
    }

    @Before
    fun openJsonInputScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("JSON Input", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's text survives.
        typeInto("json-valid", "{\"name\": \"mishka\", \"stars\": 42}")
    }

    @Test
    fun an_invalid_field_keeps_its_box() {
        val valid = boundsOf("json-valid")

        typeInto("json-valid", "{oops}")
        compose.waitUntil(10_000) { errorOf("json-valid") != null }

        // The bug this guards: an unresolvable border colour made nodeModifier
        // skip the border entirely, so the invalid field lost its outline
        // instead of reddening it. The outline is not readable, but the box it
        // encloses is — a field that still lays out at the same width and a
        // sane height is a field that still has a box drawn round it.
        val invalid = boundsOf("json-valid")

        require(kotlin.math.abs(invalid.width - valid.width) < 4f) {
            "the invalid field changed width: $valid vs $invalid"
        }
        require(invalid.height > 0f) { "the invalid field collapsed: $invalid" }
    }

    @Test
    fun the_parser_speaks_for_itself() {
        typeInto("json-valid", "{oops}")

        // Jason's own message, position and all — not a generic "Invalid JSON".
        // Read from THIS field's message: the neighbouring Invalid example also
        // shows a parser message, and it is a different one ("position 9"), so
        // a page-wide match would be satisfied by a field nobody touched.
        compose.waitUntil(10_000) { errorOf("json-valid")?.contains("position 1") == true }

        val message = errorOf("json-valid")
        require(message != null && message.contains("unexpected byte at position 1")) {
            "the field did not report Jason's own message, it said: $message"
        }
    }

    @Test
    fun blank_is_not_an_error() {
        // Prove the message exists first, so that its ABSENCE below is a real
        // change and not a tag that never resolved.
        typeInto("json-valid", "{oops}")
        compose.waitUntil(10_000) { errorOf("json-valid") != null }

        typeInto("json-valid", "")
        Thread.sleep(600)

        // An untouched field is not a mistake, and the web version does not
        // paint one red either.
        require(errorOf("json-valid") == null) {
            "an empty field reported: ${errorOf("json-valid")}"
        }

        // …while the example that is MEANT to be broken still says so. Without
        // this, tagging the message wrongly would make the assertion above pass
        // by finding nothing at all.
        require(errorOf("json-broken") != null) { "the invalid example lost its message" }
    }

    @Test
    fun a_bare_scalar_is_valid_json() {
        typeInto("json-valid", "42")
        compose.waitUntil(10_000) { showing("Parses: true") }

        typeInto("json-valid", "\"just a string\"")
        compose.waitUntil(10_000) { showing("Parses: true") }
    }

    @Test
    fun the_caption_follows_what_was_typed() {
        typeInto("json-valid", "{\"a\": 1}")
        compose.waitUntil(10_000) { showing("Parses: true") }

        typeInto("json-valid", "{\"a\": }")
        compose.waitUntil(10_000) { showing("Parses: false") }
    }

    @Test
    fun a_disabled_field_cannot_be_typed_into() {
        compose.onNodeWithTag("json-off").performScrollTo()
        compose.waitForIdle()

        // enabled={false}, not merely a withheld handler: a field that only
        // withholds its handler still takes a caret and accepts typing, then
        // throws every keystroke away.
        compose.onNodeWithTag("json-off").assertIsNotEnabled()
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Valid, and validated on the server",
            "Invalid shows the parser's own message",
            "Disabled",
            "Number formatter",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
