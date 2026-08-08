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
 * End-to-end tests for the Tooltip page.
 *
 * The web reveals a tooltip on hover or focus, and a phone has neither. The
 * touch equivalent is a long press — the same gesture the context menu opens
 * on — and [holding_a_control_reveals_its_hint] is the thing the port shipped
 * without: it had a bubble and no way to summon it.
 *
 * Everything here asserts on TAGS. The whole page is one scroll, every example
 * renders a tooltip, and each `code:` block is a text node too — so a page-wide
 * text query is answered by whichever example happens to contain the string.
 *
 * Run with `mix e2e TooltipTest`.
 */
@RunWith(AndroidJUnit4::class)
class TooltipTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A short hint about the control it wraps"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    // performScrollTo() throws inside a Popup — "Semantic Node has no parent
    // layout with a Scroll SemanticsAction" — because the panel renders in its
    // own window, which is not inside the page's scroll. It is only ever a
    // convenience (bring the node on screen first), so attempt it and carry on.
    private fun hold(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    private fun tap(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    @Before
    fun openTooltipScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Tooltip", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so the assigns an earlier test left
        // behind are still there. Put the page back to how it mounts: nothing
        // held open, and both dismissable hints showing.
        for (id in listOf("copy", "share", "trash")) {
            if (tagged("tip-$id-open")) hold("tip-$id-trigger")
        }
        for (id in listOf("dismiss-soft", "dismiss-sticky")) {
            if (!tagged("$id-open")) hold("$id-trigger")
        }
    }

    @Test
    fun holding_a_control_reveals_its_hint() {
        require(!tagged("tip-copy-open")) { "this hint was already showing" }

        hold("tip-copy-trigger")

        compose.waitUntil(10_000) { tagged("tip-copy-open") }
        // The arrow's tag carries the side because a drawn triangle is not
        // something a device test can read — no text, no glyph, just a path.
        require(tagged("tip-copy-arrow-bottom")) { "the hint opened without its arrow" }
    }

    @Test
    fun holding_it_again_puts_the_hint_away() {
        hold("tip-copy-trigger")
        compose.waitUntil(10_000) { tagged("tip-copy-open") }

        hold("tip-copy-trigger")

        compose.waitUntil(10_000) { !tagged("tip-copy-open") }
    }

    @Test
    fun holding_another_control_moves_the_hint() {
        hold("tip-copy-trigger")
        compose.waitUntil(10_000) { tagged("tip-copy-open") }

        hold("tip-share-trigger")

        compose.waitUntil(10_000) { tagged("tip-share-open") }
        require(!tagged("tip-copy-open")) { "two hints were showing at once" }
    }

    @Test
    fun a_plain_tap_uses_the_control_and_leaves_the_hint_shut() {
        // The hold must not swallow the ordinary tap: the control keeps doing
        // whatever it did, which is why the trigger carries both handlers on
        // one combinedClickable rather than trading one for the other.
        //
        // Two taps, because the assign survives the Activity — a single one
        // would also pass against the value an earlier RUN of this test left
        // behind. The second has to move it.
        tap("tip-share-trigger")
        compose.waitUntil(10_000) { showing("tapped share") }

        tap("tip-copy-trigger")

        compose.waitUntil(10_000) { showing("tapped copy") }
        require(!tagged("tip-copy-open")) { "a plain tap revealed the hint" }
        require(!tagged("tip-share-open")) { "a plain tap revealed the hint" }
    }

    @Test
    fun every_side_draws_the_arrow_that_points_back() {
        for (side in listOf("top", "bottom", "left", "right")) {
            // The arrow lives in the bubble's own window; scrolling to it throws.
            val node = compose.onNodeWithTag("side-$side-arrow-$side", useUnmergedTree = true)
            runCatching { node.performScrollTo() }
            node.assertIsDisplayed()
        }
    }

    @Test
    fun align_places_the_bubble_without_moving_the_trigger() {
        // All three are pinned open; what differs is where the bubble lands,
        // which only the tag can confirm is even present on the page.
        for (id in listOf("align-start", "align-center", "align-end")) {
            require(tagged("$id-open")) { "$id did not render its bubble" }
            require(tagged("$id-trigger")) { "$id did not render its trigger" }
        }
    }

    @Test
    fun tapping_the_hint_dismisses_it() {
        require(tagged("dismiss-soft-open")) { "this hint was not showing to begin with" }

        tap("dismiss-soft-open")

        compose.waitUntil(10_000) { !tagged("dismiss-soft-open") }
    }

    @Test
    fun close_on_tap_false_keeps_the_hint_up_until_a_hold() {
        require(tagged("dismiss-sticky-open")) { "this hint was not showing to begin with" }

        tap("dismiss-sticky-open")
        require(tagged("dismiss-sticky-open")) { "close_on_tap={false} dismissed anyway" }

        hold("dismiss-sticky-trigger")

        compose.waitUntil(10_000) { !tagged("dismiss-sticky-open") }
    }

    @Test
    fun a_disabled_tooltip_never_opens() {
        hold("tip-off-trigger")

        // disabled drops the hold handler rather than ignoring the event, so
        // there is nothing to arrive and nothing to ignore.
        require(!tagged("tip-off-open")) { "a disabled tooltip opened" }
    }

    @Test
    fun a_closed_tooltip_contributes_no_node_at_all() {
        require(tagged("bare-open")) { "the trigger-less bubble did not render" }
        require(!tagged("bare-shut-open")) { "a closed tooltip still occupied the layout" }
    }

    @Test
    fun styling_reaches_every_bubble() {
        for (id in listOf("style-dark", "style-token", "style-plum")) {
            val node = compose.onNodeWithTag("$id-open", useUnmergedTree = true)
            runCatching { node.performScrollTo() }
            node.assertIsDisplayed()
        }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Hold to reveal",
            "Every side, with an arrow",
            "Align, and the two offsets",
            "Tap the hint to dismiss",
            "Disabled",
            "Colours, size and a static nudge",
            "Without a trigger",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
    /**
     * A REAL touch, through the system — not compose.performClick.
     *
     * The panel lives in its own window, and an outside tap only reaches it as
     * the window manager delivering ACTION_OUTSIDE to a touch-modal window.
     * Compose's synthetic click is injected straight into one window's
     * semantics tree and never crosses that boundary, so it can neither dismiss
     * the popup nor prove that a finger would.
     */
    private fun tapOutsideAt(xDp: Float, yDp: Float) {
        val density = compose.activity.resources.displayMetrics.density
        val x = xDp * density
        val y = yDp * density
        val instr = androidx.test.platform.app.InstrumentationRegistry.getInstrumentation()
        val down = android.os.SystemClock.uptimeMillis()

        // UiDevice, not Instrumentation.sendPointerSync. The panel is its own window, and
        // androidx's own PopupDismissTest says why: "Need to click via UiDevice as this
        // click has to propagate to multiple windows". sendPointerSync goes through the
        // inject-into-self path, which on API 34+ refuses any event landing outside a
        // window this app owns — the exact IllegalArgumentException CI was throwing.
        //
        // UiDevice takes SCREEN coordinates, so the activity's own offset has to be added
        // back: elementFrames is relative to the activity window.
        val origin = intArrayOf(0, 0)
        compose.activity.window.decorView.getLocationOnScreen(origin)
        val sx = (origin[0] + x).toInt()
        val sy = (origin[1] + y).toInt()

        android.util.Log.i("TapProbe", "window=(${x},${y}) origin=(${origin[0]},${origin[1]}) screen=($sx,$sy)")

        androidx.test.uiautomator.UiDevice
            .getInstance(androidx.test.platform.app.InstrumentationRegistry.getInstrumentation())
            .click(sx, sy)

        compose.waitForIdle()
    }

    private fun frameOf(tag: String): androidx.compose.ui.geometry.Rect? {
        val json = org.json.JSONObject(MobBridge.elementFrames())
        if (!json.has(tag)) return null
        val a = json.getJSONArray(tag)
        val x = a.getDouble(0).toFloat()
        val y = a.getDouble(1).toFloat()
        return androidx.compose.ui.geometry.Rect(
            x, y, x + a.getDouble(2).toFloat(), y + a.getDouble(3).toFloat()
        )
    }

    /**
     * The same complaint as the preview card: an open hint could only be
     * dismissed by finding the bubble itself, which on a phone is exactly the
     * thing the finger is covering.
     */
    @Test
    fun a_tap_outside_the_bubble_dismisses_it() {
        if (!tagged("tip-copy-open")) hold("tip-copy-trigger")
        compose.waitUntil(10_000) { tagged("tip-copy-open") }
        Thread.sleep(500)

        val bubble = frameOf("tip-copy-open") ?: error("the bubble has no frame")
        tapOutsideAt(10f, bubble.bottom + 120f)

        compose.waitUntil(10_000) { !tagged("tip-copy-open") }
    }
}
