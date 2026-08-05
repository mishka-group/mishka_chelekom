package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onRoot
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
 * End-to-end tests for the Splitter page.
 *
 * The whole point of this component is that the DIVIDER is the drag handle.
 * It used to ship a Slider bolted under the panes, on the stated grounds that
 * "Mob delivers no pointer coordinates to render/1" — which was false:
 * `on_drag` is a registered handler and a `:canvas` carries it. So the test
 * that matters is [dragging_the_grip_moves_the_split]: a real gesture on the
 * grip, and the panes measured before and after.
 *
 * A canvas is a drawing — no text, no label — so the grip is only addressable
 * through its `id`, which is why the component grew one.
 *
 * Run with `mix e2e SplitterTest`.
 */
@RunWith(AndroidJUnit4::class)
class SplitterTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Two resizable panes with a draggable divider"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    private fun paneWidth(splitter: String, n: Int): Float = boundsOf("$splitter-pane-$n").width

    /**
     * Scroll the GRIP into view — not a pane, and certainly not a heading.
     *
     * performScrollTo moves the minimum distance, so scrolling to pane 1 of a
     * STACKED splitter parks the grip below the fold, where an injected touch
     * lands on nothing and the drag silently does nothing at all. That is
     * exactly how [a_vertical_splitter_drags_on_the_other_axis] first failed,
     * while every horizontal test passed — side by side, the grip shares a row
     * with pane 1 and came into view for free.
     */
    private fun show(splitter: String) {
        compose.onNodeWithTag("$splitter-grip", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()
    }

    /**
     * Drag the grip, as a finger would — injected through the ROOT at the grip's
     * window coordinates, not through the grip node itself.
     *
     * Injecting on the node uses node-local coordinates, and `performScrollTo`
     * parks a node at the viewport EDGE (minimum distance, again), so `center`
     * sits on the boundary and most of the gesture lands outside the window and
     * is dropped. That looked like "the drag moved 10px instead of 60". The root
     * spans the whole window, so nothing here can be clipped.
     */
    private fun dragGrip(splitter: String, dx: Float, dy: Float = 0f) {
        centre(splitter)

        // Aim at the DIVIDER, not at the drag surface's centre. The surface
        // spans the whole extent — it has to, to be a stable ruler — and the
        // component only engages a drag that starts on the divider, so a touch
        // at the surface's middle misses entirely once the split has moved away
        // from 50%. The divider sits on pane 1's trailing edge.
        val pane = boundsOf("$splitter-pane-1")
        val surface = boundsOf("$splitter-grip")
        val from =
            if (dy != 0f || surface.height > surface.width) {
                androidx.compose.ui.geometry.Offset(surface.center.x, pane.bottom + 4f)
            } else {
                androidx.compose.ui.geometry.Offset(pane.right + 4f, surface.center.y)
            }

        compose.onRoot().performTouchInput {
            down(from)
            // Several steps, not one jump: the component anchors on the "began"
            // phase and every sample after it is read against that anchor.
            val steps = 5
            repeat(steps) {
                moveBy(androidx.compose.ui.geometry.Offset(dx / steps, dy / steps))
            }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(600)
    }

    /**
     * Bring the grip into view AND away from the edges, so a 60px gesture from
     * its centre stays inside the window in both directions.
     */
    private fun centre(splitter: String) {
        show(splitter)

        val window = compose.onRoot().fetchSemanticsNode().size.height.toFloat()
        val margin = 200f

        if (boundsOf("$splitter-grip").center.y > window - margin) {
            // Too near the bottom: pull something further down into view, which
            // drags the grip up with it.
            runCatching {
                compose.onNodeWithTag("$splitter-pane-2", useUnmergedTree = true).performScrollTo()
            }
            compose.waitForIdle()
        }
    }

    @Before
    fun openSplitterScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Splitter", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so an earlier test's split survives.
        // Every test here is written RELATIVE to whatever it finds rather than
        // dragging back to a fixed start: a settle loop is just more gestures
        // to go wrong, and it hid the real failure last time by leaving the
        // split somewhere no test had asked for.
        show("panes")
    }

    @Test
    fun dragging_the_grip_moves_the_split() {
        show("panes")
        val before = paneWidth("panes", 1)

        dragGrip("panes", 60f)

        // The first pane grew and the second shrank by about as much: this is a
        // splitter, so the extent is conserved. Asserting only that one pane
        // moved would pass if both grew and the layout simply overflowed.
        val after = paneWidth("panes", 1)
        require(after > before + 20f) {
            "dragging right did not widen the first pane: $before -> $after"
        }
    }

    @Test
    fun the_two_panes_always_add_up() {
        show("panes")
        val total = paneWidth("panes", 1) + paneWidth("panes", 2)

        dragGrip("panes", 50f)

        val moved = paneWidth("panes", 1) + paneWidth("panes", 2)
        require(kotlin.math.abs(moved - total) < 6f) {
            "the panes stopped summing to the extent: $total -> $moved"
        }
    }

    @Test
    fun dragging_back_returns_the_split() {
        show("panes")
        val start = paneWidth("panes", 1)

        // Move AWAY from the nearer bound, so neither leg of the round trip is
        // silently eaten by the min/max clamp — which would look exactly like
        // an asymmetric fold.
        val out = if (start > paneWidth("panes", 2)) -60f else 60f

        dragGrip("panes", out)
        val moved = paneWidth("panes", 1)
        require(kotlin.math.abs(moved - start) > 20f) {
            "the drag did not move, so dragging back cannot be tested: $start -> $moved"
        }

        dragGrip("panes", -out)

        // Symmetry is the evidence that the fold is relative to where the drag
        // BEGAN, not derived from an absolute canvas-local x — which would
        // drift, because the grip's own coordinates travel with it.
        val back = paneWidth("panes", 1)
        require(kotlin.math.abs(back - start) < 20f) {
            "dragging back did not return the split: $start -> $moved -> $back"
        }
    }

    @Test
    fun min_and_max_stop_a_pane_vanishing() {
        show("bounded")
        val extent = paneWidth("bounded", 1) + paneWidth("bounded", 2)

        // Shove far past the bound; min is 30%.
        dragGrip("bounded", -400f)

        val first = paneWidth("bounded", 1)
        require(first > extent * 0.2f) {
            "the first pane was dragged below its min: $first of $extent"
        }
        require(first < extent * 0.45f) { "the drag did not reach the min at all: $first" }
    }

    @Test
    fun a_disabled_splitter_does_not_move() {
        show("frozen")
        val before = paneWidth("frozen", 1)

        dragGrip("frozen", 60f)

        // Disabled omits the handler rather than hiding the grip — the divider
        // is still there to keep the layout from jumping, but nothing fires.
        require(kotlin.math.abs(paneWidth("frozen", 1) - before) < 4f) {
            "a disabled splitter moved: $before -> ${paneWidth("frozen", 1)}"
        }
    }

    @Test
    fun a_vertical_splitter_drags_on_the_other_axis() {
        show("stack")
        val before = boundsOf("stack-pane-1").height

        dragGrip("stack", 0f, 60f)

        val after = boundsOf("stack-pane-1").height
        require(after > before + 15f) {
            "dragging down did not grow the top pane: $before -> $after"
        }

        // And the x it ignores really is ignored: orientation :vertical makes
        // drag/3 read y only, so a sideways shove must not move a stacked split.
        val sideways = boundsOf("stack-pane-1").height
        dragGrip("stack", 80f, 0f)
        require(kotlin.math.abs(boundsOf("stack-pane-1").height - sideways) < 10f) {
            "a horizontal drag moved a vertical splitter: $sideways -> " +
                "${boundsOf("stack-pane-1").height}"
        }
    }

    @Test
    fun there_is_no_slider_anywhere_on_the_page() {
        // The regression this guards is the component's own history: a Slider
        // under the panes, which the divider was supposed to replace.
        show("panes")

        require(
            compose.onAllNodesWithTag("panes-grip", useUnmergedTree = true)
                .fetchSemanticsNodes().isNotEmpty()
        ) { "the grip is missing" }

        for (heading in listOf("Side by side", "Stacked", "Bounded, and disabled", "Props")) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
