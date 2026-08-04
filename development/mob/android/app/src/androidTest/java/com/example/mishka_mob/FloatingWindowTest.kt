package com.example.mishka_mob

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Floating Window page.
 *
 * The component's whole claim is that it DRAGS, and that claim is only worth
 * anything on a device: the moduledoc used to say "Mob delivers no pointer
 * coordinates to render/1, so the drag cannot be ported", which was false all
 * along — `on_drag` is a registered handler and a `:canvas` carries it.
 * [dragging_the_title_bar_moves_the_window] is the test that settles it, with a
 * real gesture and the window's bounds measured before and after.
 *
 * Everything here asserts on TAGS, never on page text. All six examples render
 * into one scrolling page and the code samples are text nodes too, so a
 * page-wide text query is answered by whichever example happens to contain the
 * string. The position is in a tag for the same reason: an offset is no more
 * readable to a device test than a colour is.
 *
 * Run with `mix e2e FloatingWindowTest`.
 */
@RunWith(AndroidJUnit4::class)
class FloatingWindowTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A window you drag by its title bar"

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

    private fun show(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
    }

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    /**
     * A point inside a window's title bar — the top 48dp of the panel, and the
     * only band that starts a drag.
     *
     * Taken as a fraction of the panel rather than in dp, because the injected
     * coordinates are pixels and the geometry is written in dp: whatever the
     * device's density, 15% down a 100dp window is inside a 48dp bar.
     */
    private fun titleBar(window: String): Offset {
        val panel = boundsOf(window)

        return Offset(panel.left + panel.width * 0.3f, panel.top + panel.height * 0.15f)
    }

    /**
     * Drag from a point, as a finger would — injected through the ROOT rather
     * than through the drag surface itself.
     *
     * The surface is a canvas spanning the whole stage, and injecting on a node
     * uses node-local coordinates; `performScrollTo` parks a node at the
     * viewport edge (minimum distance), so half a gesture aimed at the node's
     * own centre can land outside the window and be dropped. The root spans the
     * whole window, so nothing here can be clipped.
     */
    private fun dragFrom(from: Offset, dx: Float, dy: Float = 0f) {
        compose.onRoot().performTouchInput {
            down(from)
            // Several samples, not one jump: the fold anchors on the :began
            // phase and reads every sample after it against that anchor.
            val steps = 5
            repeat(steps) { moveBy(Offset(dx / steps, dy / steps)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(600)
    }

    @Before
    fun openFloatingWindowScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Floating Window", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so the previous test's window is still
        // wherever it left it. Every example has a control that puts it back,
        // which is why each one carries its own assigns: resetting one must not
        // disturb another.
        tap("win-reset")
        tap("step-reset")
        if (!tagged("closable-window")) tap("closable-open")
    }

    @Test
    fun dragging_the_title_bar_moves_the_window() {
        show("win-window")
        val before = boundsOf("win-window")

        dragFrom(titleBar("win-window"), dx = 90f)

        val after = boundsOf("win-window")
        require(after.left > before.left + 30f) {
            "dragging right did not move the window: ${before.left} -> ${after.left}"
        }
        // The readout carries the position in its tag, because a device test can
        // read neither an offset nor the text of the right example.
        require(!tagged("win-pos-20-12")) { "the window reports the position it started at" }
    }

    @Test
    fun a_drag_that_starts_below_the_title_bar_moves_nothing() {
        show("win-window")
        val panel = boundsOf("win-window")

        // The drag surface covers the whole stage — it must, to be a stable
        // ruler — so without the handle test every touch anywhere would teleport
        // the window to the finger.
        dragFrom(Offset(panel.left + panel.width * 0.3f, panel.bottom - panel.height * 0.1f), 90f)

        require(tagged("win-pos-20-12")) {
            "a drag that began in the body moved the window anyway"
        }
    }

    @Test
    fun the_handle_says_when_it_is_being_dragged() {
        show("win-window")
        require(tagged("win-handle")) { "the idle handle is not tagged" }

        val from = titleBar("win-window")
        compose.onRoot().performTouchInput { down(from) }

        // data-dragging on the web; here it has to be in the tag, because the
        // only other place the state shows is the strip's colour.
        compose.waitUntil(10_000) { tagged("win-handle-dragging") }

        compose.onRoot().performTouchInput {
            moveBy(Offset(60f, 0f))
            up()
        }
        compose.waitForIdle()

        compose.waitUntil(10_000) { tagged("win-handle") }
        require(!tagged("win-handle-dragging")) { "the handle stayed dragging after the lift" }
    }

    @Test
    fun an_arrow_moves_the_window_one_step() {
        compose.waitUntil(10_000) { tagged("step-pos-0-0") }

        tap("step-nudge-right")

        // step is 20, and it is read from the window's own props — it used to be
        // a documented prop that nothing read.
        compose.waitUntil(10_000) { tagged("step-pos-20-0") }

        tap("step-nudge-down")
        compose.waitUntil(10_000) { tagged("step-pos-20-20") }

        tap("step-nudge-up")
        tap("step-nudge-left")
        compose.waitUntil(10_000) { tagged("step-pos-0-0") }
    }

    @Test
    fun the_arrows_stop_at_the_stage_edge() {
        compose.waitUntil(10_000) { tagged("step-pos-0-0") }

        // A 240 stage and a 200 window: two steps of 20 reach the edge, and
        // every tap after that must do nothing. Clamping to the stage instead of
        // the stage MINUS the window would let it walk most of the way out.
        repeat(5) { tap("step-nudge-right") }

        compose.waitUntil(10_000) { tagged("step-pos-40-0") }
    }

    @Test
    fun the_close_button_hides_the_window_and_reopening_brings_it_back() {
        require(tagged("closable-window")) { "the window was not open to begin with" }

        tap("closable-close")

        compose.waitUntil(10_000) { !tagged("closable-window") }

        tap("closable-open")
        compose.waitUntil(10_000) { tagged("closable-window") }
    }

    @Test
    fun a_window_with_no_drag_surface_still_takes_taps_in_its_body() {
        // Reopening clears the counter, so this starts from a known number.
        tap("closable-open")
        compose.waitUntil(10_000) { tagged("closable-pings-0") }

        tap("closable-ping")

        // The body sits above the drag surface where there is one, and this
        // window has none at all — no on_move, no canvas.
        compose.waitUntil(10_000) { tagged("closable-pings-1") }
    }

    @Test
    fun a_drag_surface_exists_only_where_the_window_can_move() {
        require(tagged("win-drag") && tagged("step-drag")) {
            "a window with on_move and bounds has no drag surface"
        }
        require(!tagged("closable-drag") && !tagged("custom-drag")) {
            "a window with no on_move laid a drag surface over its own body"
        }
    }

    @Test
    fun arrows_appear_only_when_something_is_listening_for_them() {
        require(tagged("step-nudge-up") && tagged("step-nudge-down")) {
            "the arrows are missing from the window that wired on_move"
        }
        // show_nudges: false on the first window, and no on_move at all on the
        // last two — an arrow nobody listens to is a control that renders
        // perfectly and does nothing.
        require(!tagged("win-nudge-up")) { "show_nudges: false still drew the arrows" }
        require(!tagged("closable-nudge-up") && !tagged("custom-nudge-up")) {
            "arrows were drawn for a window with no on_move"
        }
    }

    @Test
    fun the_arrows_are_full_touch_targets() {
        show("step-nudge-left")

        // Measured against the window's own width rather than converted to dp:
        // that window is 200dp wide and an arrow is 48dp, so the ratio is the
        // same figure at any density. The old arrows were 4dp of padding round a
        // glyph — about 20dp of target, which is a miss more often than a tap.
        val window = boundsOf("step-window").width

        for (direction in listOf("left", "up", "down", "right")) {
            val arrow = boundsOf("step-nudge-$direction")

            require(arrow.width > window * 0.2f) {
                "the $direction arrow is ${arrow.width}px of a ${window}px window, under 48dp"
            }
            require(arrow.height >= arrow.width - 2f) { "the $direction arrow is not square" }
        }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Drag it by the title bar",
            "Nudge, for precision",
            "A window that closes",
            "Its own title bar",
            "Props"
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
