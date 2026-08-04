package com.example.mishka_mob

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.click
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
 * End-to-end tests for the Drawer page.
 *
 * The web drawer is a gesture-driven sheet — swipe to dismiss, snap points, a
 * drag handle — and none of that is readable from text. Every assertion here is
 * on a testTag: the page renders nine drawers into one scrolling tree, and the
 * code samples are text nodes too, so a page-wide text query would be answered
 * by whichever example happened to contain the string.
 *
 * The state with no text at all rides in the tags. `<id>-panel` says the drawer
 * is open, and `sheet-snap-<n>` says which snap point is active — a height in
 * pixels cannot be attributed to a snap point without it.
 *
 * Gesture distances are fractions of the screen rather than pixel constants, so
 * they mean the same number of dp on any density; the component's thresholds
 * are in dp.
 *
 * Run with `mix e2e DrawerTest`.
 */
@RunWith(AndroidJUnit4::class)
class DrawerTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "An edge-anchored panel that slides in over a dimmed backdrop"

    private val drawers =
        listOf("side", "size", "sheet", "head", "skin", "chrome", "locked", "bare", "edge")

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

    private fun root(): Rect = compose.onRoot().fetchSemanticsNode().boundsInRoot

    /** Roughly 117dp of vertical travel — past the sheet's 48dp threshold, inside one snap step. */
    private fun step(): Float = root().height * 0.15f

    /** Roughly 150dp sideways, which clears the 64dp default threshold on any density. */
    private fun reach(): Float = root().width * 0.4f

    /** Tap a trigger on the PAGE — inside the scroll, so it may need scrolling to. */
    private fun tapOnPage(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    /**
     * Tap something in the OVERLAY. No performScrollTo: the overlay is stacked
     * over the page rather than inside its scroll, so asking to scroll to it
     * would drive the page's scroller instead and move the wrong thing.
     */
    private fun tapOnOverlay(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    /** A finger on a tagged node, dragged in several steps as a real one is. */
    private fun drag(tag: String, dx: Float, dy: Float) {
        val from = boundsOf(tag).center

        compose.onRoot().performTouchInput {
            down(from)
            // Several samples, not one jump: the fold anchors on the "began"
            // phase and reads every later sample against that anchor.
            val steps = 5
            repeat(steps) { moveBy(Offset(dx / steps, dy / steps)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(600)
    }

    /**
     * A tap at an absolute point — the only way to hit a backdrop, whose centre
     * is behind the panel it dims.
     */
    private fun tapAt(x: Float, y: Float) {
        compose.onRoot().performTouchInput { click(Offset(x, y)) }
        compose.waitForIdle()
        Thread.sleep(400)
    }

    private fun open(id: String) {
        if (!tagged("$id-panel")) tapOnPage("$id-open")
        compose.waitUntil(10_000) { tagged("$id-panel") }
    }

    private fun close(id: String) {
        if (!tagged("$id-panel")) return
        // header={false} means no ✕ — that drawer carries its own way out,
        // which is the whole point of the example.
        tapOnOverlay(if (id == "chrome") "chrome-signout" else "$id-close")
        compose.waitUntil(10_000) { !tagged("$id-panel") }
    }

    private fun closeAll() {
        for (id in drawers) close(id)
    }

    /** Which snap point the sheet is parked on, or 0 when it is closed. */
    private fun snapIndex(): Int {
        for (i in 1..3) if (tagged("sheet-snap-$i")) return i
        return 0
    }

    /**
     * Park the sheet on a snap point, whatever it inherited from an earlier
     * test — the BEAM outlives the Activity, so the sheet keeps its height.
     * Only ever drags UP toward a higher point, because a drag DOWN from the
     * smallest one dismisses rather than snapping.
     */
    private fun settleAt(index: Int) {
        open("sheet")

        var guard = 0
        while (snapIndex() != index && guard++ < 6) {
            drag("sheet-handle", 0f, if (snapIndex() < index) -step() else step())
        }

        require(snapIndex() == index) { "could not park the sheet at snap $index" }
    }

    @Before
    fun openDrawerScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Drawer", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // An earlier test's drawer is still open, and an open drawer covers the
        // whole page — every trigger below would be untappable.
        closeAll()
    }

    @Test
    fun a_trigger_opens_the_drawer_and_the_close_button_shuts_it() {
        require(!tagged("side")) { "the drawer was already open" }

        tapOnPage("side-open-right")

        compose.waitUntil(10_000) { tagged("side-panel") }
        // The root tag is the open signal: a closed drawer renders nothing at
        // all, so there is no colour or glyph to read instead.
        require(tagged("side")) { "the panel rendered without its overlay root" }

        tapOnOverlay("side-close")
        compose.waitUntil(10_000) { !tagged("side-panel") }
        require(!tagged("side")) { "the overlay outlived the panel" }
    }

    @Test
    fun each_side_anchors_the_panel_to_its_own_edge() {
        tapOnPage("side-open-left")
        compose.waitUntil(10_000) { tagged("side-panel") }
        val left = boundsOf("side-panel")
        require(left.left < 4f) { "a left drawer did not start at the left edge: ${left.left}" }
        close("side")

        tapOnPage("side-open-right")
        compose.waitUntil(10_000) { tagged("side-panel") }
        val right = boundsOf("side-panel")
        require(right.right > root().right - 4f) {
            "a right drawer did not reach the right edge: ${right.right} of ${root().right}"
        }
        require(right.left > left.left + 20f) { "both sides rendered in the same place" }
        close("side")

        tapOnPage("side-open-bottom")
        compose.waitUntil(10_000) { tagged("side-panel") }
        val bottom = boundsOf("side-panel")
        // The system navigation bar sits below the app's root, so a sheet flush
        // with the bottom edge stops short of root().bottom by that inset. 4dp
        // was too tight to be measuring the thing it meant to measure.
        require(bottom.bottom > root().bottom - 80f) {
            "a bottom sheet floated off its edge: ${bottom.bottom} of ${root().bottom}"
        }
        // A sheet fills the width and hugs its content height. The Android
        // renderer needs a Column for that: a Box wraps its content there, and
        // collapsed the sheet to content WIDTH instead.
        require(bottom.width > root().width - 4f) { "the sheet did not fill the width" }
        require(bottom.height < root().height / 2f) { "the sheet filled the height" }
    }

    @Test
    fun size_changes_the_panel_width() {
        tapOnPage("size-open-xs")
        compose.waitUntil(10_000) { tagged("size-panel") }
        val small = boundsOf("size-panel").width
        close("size")

        tapOnPage("size-open-xl")
        compose.waitUntil(10_000) { tagged("size-panel") }
        val large = boundsOf("size-panel").width

        // 240dp against 384dp — a 1.6x span no rounding can blur.
        require(large > small * 1.4f) { "size did not change the panel width: $small -> $large" }
    }

    @Test
    fun a_backdrop_tap_dismisses() {
        open("head")
        val panel = boundsOf("head-panel")

        // Aim beside the panel, not at the scrim's centre: the scrim spans the
        // whole screen and its middle is underneath the panel.
        tapAt(panel.left / 2f, root().center.y)

        compose.waitUntil(10_000) { !tagged("head-panel") }
    }

    @Test
    fun an_undismissable_drawer_ignores_the_backdrop() {
        open("locked")
        val panel = boundsOf("locked-panel")

        tapAt(root().center.x, panel.top / 2f)

        require(tagged("locked-panel")) { "dismissible={false} was dismissed by the backdrop" }

        // …and the drawer's own exit still works, which is the only way out it
        // has. (That the inert backdrop still absorbs rather than passing the
        // tap through is asserted in the unit test, where the scrim's handler
        // is readable; on device there is no guaranteed target underneath.)
        tapOnOverlay("locked-done")
        compose.waitUntil(10_000) { !tagged("locked-panel") }
    }

    @Test
    fun without_a_scrim_there_is_no_backdrop() {
        open("bare")

        require(tagged("bare-panel")) { "the panel is missing" }
        require(!tagged("bare-scrim")) { "scrim={false} still rendered a backdrop" }

        // Every other drawer has one, so this is a property of the prop rather
        // than of the tag never being emitted at all.
        close("bare")
        open("head")
        require(tagged("head-scrim")) { "a default drawer lost its backdrop" }
    }

    @Test
    fun the_header_parts_are_addressable_and_header_false_drops_them() {
        open("head")

        for (part in listOf("head-title", "head-description", "head-close", "head-scrim")) {
            require(tagged(part)) { "expected a node tagged $part" }
        }

        close("head")
        open("chrome")

        require(tagged("chrome-panel")) { "the custom-chrome drawer did not open" }
        require(!tagged("chrome-close")) { "header={false} still rendered the built-in ✕" }
        require(!tagged("chrome-title")) { "header={false} still rendered the built-in title" }
    }

    @Test
    fun dragging_the_handle_down_steps_one_snap_point() {
        settleAt(3)
        val tall = boundsOf("sheet-panel").height

        drag("sheet-handle", 0f, step())

        require(snapIndex() == 2) { "a downward drag did not step to snap 2: ${snapIndex()}" }
        require(boundsOf("sheet-panel").height < tall - 20f) {
            "the snap tag moved but the sheet did not shrink"
        }
    }

    @Test
    fun snap_sequential_moves_one_point_per_flick_however_far_the_finger_goes() {
        settleAt(3)

        // Far enough to clear every point at once — and to land below the
        // smallest, which is where a non-sequential sheet would fly off.
        drag("sheet-handle", 0f, boundsOf("sheet-panel").height * 0.9f)

        require(snapIndex() == 2) { "a long flick skipped past snap 2: ${snapIndex()}" }
        require(tagged("sheet-panel")) { "a long flick dismissed a sheet above its smallest point" }
    }

    @Test
    fun dragging_the_handle_up_grows_the_sheet() {
        settleAt(1)
        val short = boundsOf("sheet-panel").height

        drag("sheet-handle", 0f, -step())

        require(snapIndex() == 2) { "an upward drag did not step to snap 2: ${snapIndex()}" }
        require(boundsOf("sheet-panel").height > short + 20f) { "the sheet did not grow" }
    }

    @Test
    fun a_short_drag_leaves_the_sheet_where_it_was() {
        settleAt(2)
        val height = boundsOf("sheet-panel").height

        // Well under the 48dp threshold at any density.
        drag("sheet-handle", 0f, 40f)

        require(snapIndex() == 2) { "a nudge moved the sheet to ${snapIndex()}" }
        require(kotlin.math.abs(boundsOf("sheet-panel").height - height) < 8f) {
            "a nudge resized the sheet"
        }
    }

    @Test
    fun swiping_the_sheet_off_dismisses_it() {
        settleAt(1)

        // From the smallest point, a drag below it is a dismissal — 80% of the
        // sheet's own height, so the gesture stays on screen.
        drag("sheet-handle", 0f, boundsOf("sheet-panel").height * 0.8f)

        compose.waitUntil(10_000) { !tagged("sheet-panel") }
        require(!tagged("sheet")) { "the sheet dismissed but left its overlay behind" }
    }

    @Test
    fun a_sideways_drag_does_not_dismiss_a_bottom_sheet() {
        settleAt(2)

        // swipe_direction follows the side, so a bottom sheet reads y only.
        drag("sheet-handle", reach(), 0f)

        require(tagged("sheet-panel")) { "a horizontal drag dismissed a vertical sheet" }
        require(snapIndex() == 2) { "a horizontal drag moved the snap point" }
    }

    @Test
    fun the_edge_swipe_area_opens_a_closed_drawer() {
        require(!tagged("edge-panel")) { "the edge drawer was already open" }
        // It is the one part of a CLOSED drawer that draws anything.
        require(tagged("edge-swipe-area")) { "the swipe area is missing while closed" }

        drag("edge-swipe-area", reach(), 0f)

        compose.waitUntil(10_000) { tagged("edge-panel") }
        require(!tagged("edge-swipe-area")) { "the swipe area stayed live under an open drawer" }

        // And the handle takes it back out the way it came in — one fold serves
        // both directions. Drag to the screen edge rather than by a constant,
        // so the gesture cannot run off the window on a narrow device.
        drag("edge-handle", -(boundsOf("edge-handle").center.x - 8f), 0f)
        compose.waitUntil(10_000) { !tagged("edge-panel") }
    }

    @Test
    fun a_drag_along_the_edge_does_not_open_it() {
        require(!tagged("edge-panel")) { "the edge drawer was already open" }

        // Along the edge, not across it. The outward direction cannot be tested
        // here — the patch is 16dp from the screen edge, so a drag away from
        // the drawer immediately leaves the window and its samples are dropped,
        // which would pass whatever the component did. A drag on the other AXIS
        // is a real gesture that must still be ignored.
        drag("edge-swipe-area", 0f, step())

        require(!tagged("edge-panel")) { "a drag along the edge opened the drawer" }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "A trigger, and any side",
            "Panel width",
            "Bottom sheet",
            "Title, description",
            "Custom colours",
            "Custom chrome",
            "Undismissable",
            "Swipe in from the edge",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
