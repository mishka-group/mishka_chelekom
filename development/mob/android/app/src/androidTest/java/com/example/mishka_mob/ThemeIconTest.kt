package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.longClick
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Theme Icon page.
 *
 * Everything this component does is paint: a variant, a colour, a corner radius.
 * None of that is readable from a device test — `onNodeWithTag` cannot see a
 * fill and there is no text to query — which is exactly why the component emits
 * markers derived from its `id`. So these tests address tags and geometry, never
 * page text: the gallery renders every example into one scrolling column and the
 * code samples are text nodes too, so a page-wide text query is answered by
 * whichever example happens to contain the string.
 *
 * Run with `mix e2e ThemeIconTest`.
 */
@RunWith(AndroidJUnit4::class)
class ThemeIconTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "themed container around one icon"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    private fun hold(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true)
            .performScrollTo()
            .performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    // Scroll to the node being measured, not to its heading: performScrollTo
    // moves the MINIMUM distance, so a heading parks at the bottom edge and
    // everything under it reports a zero-sized frame.
    private fun widthOf(tag: String): Int {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        node.performScrollTo()
        compose.waitForIdle()
        return node.fetchSemanticsNode().size.width
    }

    // The BEAM outlives the Activity, so the counter does not start at zero on a
    // second run. Read where it is and assert the STEP.
    private fun taps(): Int {
        for (n in 0..40) if (tagged("ti-taps-$n")) return n
        throw AssertionError("the tap counter is not on the page")
    }

    @Before
    fun openThemeIconScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Theme Icon", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun every_variant_is_addressable_because_a_colour_is_not() {
        // The seven variants differ only in paint. Without the `<id>-<variant>`
        // marker there is nothing here for a device test to hold on to at all.
        for (variant in listOf(
            "filled", "light", "outline", "subtle", "white", "default", "gradient",
        )) {
            require(tagged("ti-var-$variant")) { "no marker for the $variant variant" }
        }
    }

    @Test
    fun the_size_scale_is_real_geometry() {
        val xs = widthOf("ti-size-xs")
        val xl = widthOf("ti-size-xl")

        require(xs > 0) { "the xs icon measured zero — it was off-screen, not small" }
        require(xl > xs * 2) { "xl ($xl) should be well over twice xs ($xs)" }
    }

    @Test
    fun a_labelled_icon_is_distinguishable_from_a_decorative_one() {
        // This is the whole of the web component's accessibility story —
        // role="img" + aria-label versus aria-hidden. Mob has nothing to
        // announce into, so the distinction lives in the tag or nowhere.
        require(tagged("ti-meaning-labelled")) { "the labelled icon is not marked as such" }
        require(tagged("ti-plain-decorative")) { "the unlabelled icon is not marked decorative" }
        require(!tagged("ti-plain-labelled")) { "an unlabelled icon claimed a label" }
    }

    @Test
    fun holding_a_labelled_icon_reveals_what_it_means() {
        hold("ti-meaning")
        compose.waitUntil(10_000) { tagged("ti-held-deploy") }

        // Hold the other one: a transition, not an existence check, because the
        // BEAM keeps its assigns across Activity restarts and the first tag may
        // already be there when the class starts.
        hold("ti-meaning-alt")

        compose.waitUntil(10_000) { tagged("ti-held-rollback") }
        require(!tagged("ti-held-deploy")) { "both labels were reported at once" }
    }

    @Test
    fun a_decorative_icon_has_nothing_to_reveal() {
        hold("ti-meaning")
        compose.waitUntil(10_000) { tagged("ti-held-deploy") }

        hold("ti-plain")

        require(tagged("ti-held-deploy")) { "holding a decorative icon reported something" }
    }

    @Test
    fun a_plain_tap_is_not_a_hold() {
        hold("ti-meaning-alt")
        compose.waitUntil(10_000) { tagged("ti-held-rollback") }

        tap("ti-meaning")

        require(tagged("ti-held-rollback")) { "a tap fired the long press handler" }
    }

    @Test
    fun tapping_the_icon_reports_it() {
        val before = taps()

        tap("ti-basic")

        compose.waitUntil(10_000) { tagged("ti-taps-${before + 1}") }
    }

    @Test
    fun the_switcher_fills_exactly_the_chosen_option() {
        // A switcher is three of these in a row, and "active" is a fill — so the
        // variant marker is what says which one is on.
        tap("ti-sw-dark")
        compose.waitUntil(10_000) { tagged("ti-sw-dark-filled") }

        tap("ti-sw-light")

        compose.waitUntil(10_000) { tagged("ti-sw-light-filled") }
        require(tagged("ti-sw-dark-subtle")) { "the old choice stayed filled" }
        require(!tagged("ti-sw-dark-filled")) { "two options were active at once" }
    }

    @Test
    fun a_caller_supplied_icon_still_gets_its_container() {
        // Children are the icon — here a canvas drawing, which has no text and no
        // semantics of its own, so the container's markers are the only evidence
        // it was wrapped rather than dropped.
        require(tagged("ti-drawn")) { "the drawn icon is missing" }
        require(tagged("ti-drawn-default")) { "the drawn icon lost its variant" }
        require(tagged("ti-drawn-alt-outline")) { "the outlined drawn icon lost its variant" }
    }

    @Test
    fun the_gradient_keeps_its_own_shape() {
        // The gradient is painted into a canvas because no Box has a gradient
        // background. It must still be an icon-sized square, not a canvas that
        // grew or collapsed.
        val flat = widthOf("ti-size-lg")
        val gradient = widthOf("ti-grad-round")

        require(gradient == flat) { "the gradient icon is $gradient wide, the flat one $flat" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "One icon, wrapped",
            "Variants",
            "Sizes",
            "Radius",
            "Colour",
            "Gradient",
            "What the icon means",
            "Your own icon",
            "A theme switcher, built from three",
            "Marquee",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
