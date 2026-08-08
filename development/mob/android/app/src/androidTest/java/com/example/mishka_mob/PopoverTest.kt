package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
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
 * End-to-end tests for the Popover page.
 *
 * The port shipped with the panel shell and nothing else — no trigger, no way
 * to open it, and no tags to address any of it by. Every assertion here reads a
 * testTag rather than page text, for the reason the last sweep found in twelve
 * other suites: the whole page is one eagerly-rendered tree, the sixth example
 * is a popover pinned open={true}, and every code sample is a text node too. A
 * page-wide text query is answered by whichever example happens to contain the
 * string.
 *
 * The trigger's open state rides in its own tag (`-trigger-open` /
 * `-trigger-closed`) because the only other thing that says so is its fill, and
 * a device test cannot read a colour.
 *
 * Run with `mix e2e PopoverTest`.
 */
@RunWith(AndroidJUnit4::class)
class PopoverTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "A trigger that toggles a panel"

    /** Every interactive example on the page, by the id it was given. */
    private val examples = listOf("pop", "hold", "above", "beside", "aligned")

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    // performScrollTo() throws inside a Popup — "Semantic Node has no parent
    // layout with a Scroll SemanticsAction" — because the panel now renders in
    // its own window, which is not inside the page's scroll. It is only ever a
    // convenience here (bring the node on screen first), so attempt it and carry
    // on. frames() already uses this idiom below.
    private fun tap(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    private fun hold(tag: String) {
        val node = compose.onNodeWithTag(tag, useUnmergedTree = true)
        runCatching { node.performScrollTo() }
        node.performTouchInput { longClick() }
        compose.waitForIdle()
        Thread.sleep(500)
    }

    /**
     * Scroll the panel into view and measure it against its trigger. Scrolling
     * to the PANEL rather than to a heading matters: performScrollTo moves the
     * minimum distance, so parking a heading at the bottom edge leaves whatever
     * is under it off-screen, where bounds report zero size.
     */
    /**
     * The trigger's and the panel's frames, both laid out.
     *
     * Scroll to the TRIGGER, not the panel: with side={:top} the panel sits
     * above the trigger, so scrolling the panel into view can leave the trigger
     * below the fold — where Compose reports zero bounds and the comparison is
     * against Rect(0,0,0,0), which is not a failure of the component.
     */
    private fun frames(id: String): Pair<Rect, Rect> {
        // Deliberately does NOT scroll: `tap` already brought the trigger on
        // screen before opening, and scrolling afterwards moves the anchor out
        // from under a panel that is still catching up.
        //
        // A popup window follows its anchor ASYNCHRONOUSLY — Compose polls for
        // the anchor's on-screen position changing rather than being notified —
        // so a frame read the instant the panel appears catches it in flight,
        // by as much as ~94dp on this page. Settle first: read until the pair
        // stops moving, which is also what a user's eye waits for.
        compose.waitForIdle()

        var previous = laidOut("$id-trigger-open") to laidOut("$id-panel")
        repeat(20) {
            Thread.sleep(50)
            compose.waitForIdle()
            val now = laidOut("$id-trigger-open") to laidOut("$id-panel")
            if (now == previous) return now
            previous = now
        }
        return previous
    }

    /**
     * One coordinate space for both halves, via MobBridge's own frame table.
     *
     * The panel renders in its own window now, so its boundsInRoot is relative
     * to THAT window while the trigger's is relative to the page's scrollable
     * content: a trigger scrolled to the bottom of a long page reads y=2256 on
     * a 2400px screen while the panel beside it reads y=42, and every geometric
     * assertion becomes noise. `frameTrackingModifier` translates every id'd
     * node through getLocationOnScreen into the ACTIVITY's window space, which
     * is the one space the two share. (SemanticsNode.positionOnScreen would
     * also do it, but it does not exist in this Compose version.)
     *
     * Reading it here doubles as the check that the translation works at all.
     */
    private fun frameTable(): Map<String, Rect> {
        val json = org.json.JSONObject(MobBridge.elementFrames())
        val out = mutableMapOf<String, Rect>()
        for (key in json.keys()) {
            val a = json.getJSONArray(key)
            val x = a.getDouble(0).toFloat()
            val y = a.getDouble(1).toFloat()
            out[key] = Rect(x, y, x + a.getDouble(2).toFloat(), y + a.getDouble(3).toFloat())
        }
        return out
    }

    private fun laidOutOrNull(tag: String): Rect? =
        // Present in the semantics tree AND non-degenerate in the frame table.
        // The tag check comes first: a stale frame outlives the node that wrote
        // it, since nothing clears the table when a panel closes.
        if (!tagged(tag)) {
            null
        } else {
            frameTable()[tag]?.takeIf { it.width > 0f && it.height > 0f }
        }

    private fun laidOut(tag: String): Rect =
        laidOutOrNull(tag) ?: error("no laid-out node tagged \"$tag\"")

    @Before
    fun openPopoverScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Popover", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so a panel an earlier test opened is
        // still open. Each example owns its own assign — that is the whole
        // reason they are not shared — so close them one by one.
        for (id in examples) {
            if (tagged("$id-trigger-open")) tap("$id-trigger-open")
        }
    }

    @Test
    fun tapping_the_trigger_opens_the_panel() {
        require(!tagged("pop-panel")) { "this popover was already open" }

        tap("pop-trigger-closed")

        compose.waitUntil(10_000) { tagged("pop-panel") }
        require(tagged("pop-trigger-open")) { "the panel opened but its trigger still reads closed" }
        require(!tagged("pop-trigger-closed")) { "the trigger reported both states at once" }
    }

    @Test
    fun the_panel_carries_its_title_description_and_beak() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-panel") }

        // The web wires these through aria-labelledby / aria-describedby. Mob
        // exposes no accessibility semantics, so they are rendered instead —
        // and each gets its own tag, since a panel-wide text query would be
        // answered by any of the six examples.
        require(tagged("pop-title")) { "the title slot rendered nothing" }
        require(tagged("pop-desc")) { "the description slot rendered nothing" }
        require(tagged("pop-arrow")) { "arrow={true} drew no beak" }
    }

    @Test
    fun the_footer_close_puts_it_away() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-close") }

        tap("pop-close")

        require(!tagged("pop-panel")) { "the close action left the panel up" }
        require(tagged("pop-trigger-closed")) { "the trigger did not go back to closed" }
    }

    @Test
    fun a_long_press_opens_it_too() {
        require(!tagged("hold-panel")) { "the hold example was already open" }

        hold("hold-trigger-closed")

        // open_on_hold is the port of open_on_hover: a phone has no pointer to
        // rest on something, and a long press is what it has instead.
        compose.waitUntil(10_000) { tagged("hold-panel") }
    }

    @Test
    fun a_long_press_only_ever_opens() {
        hold("hold-trigger-closed")
        compose.waitUntil(10_000) { tagged("hold-panel") }

        hold("hold-trigger-open")

        // A hover never toggled, so neither does this. The tap is the toggle.
        require(tagged("hold-panel")) { "a second hold closed the panel" }

        tap("hold-trigger-open")
        require(!tagged("hold-panel")) { "the long press swallowed the ordinary tap" }
    }

    @Test
    fun side_top_puts_the_panel_above_its_trigger() {
        tap("above-trigger-closed")
        compose.waitUntil(10_000) { tagged("above-panel") }

        val (trigger, panel) = frames("above")

        require(panel.bottom <= trigger.top) {
            "side={:top} did not lift the panel above its trigger: trigger=$trigger panel=$panel"
        }
    }

    /**
     * The whole point of the change, stated as geometry.
     *
     * "Which side it takes" holds `above` and `beside` in one Column. When the
     * panel was a sibling in that Column, opening either one pushed the other
     * down the page by the panel's height — the accordion the user reported.
     * A floating panel cannot move it at all.
     */
    @Test
    fun opening_a_panel_does_not_move_the_sibling_below_it() {
        // Bring the pair on screen and record where the LOWER trigger sits.
        runCatching {
            compose.onNodeWithTag("beside-trigger-closed", useUnmergedTree = true).performScrollTo()
        }
        compose.waitForIdle()
        val before = laidOut("beside-trigger-closed")

        // Open the one ABOVE it, without scrolling in between.
        compose.onNodeWithTag("above-trigger-closed", useUnmergedTree = true).performClick()
        compose.waitUntil(10_000) { tagged("above-panel") }
        Thread.sleep(400)
        compose.waitForIdle()

        val after = laidOut("beside-trigger-closed")

        require(kotlin.math.abs(before.top - after.top) <= 1f) {
            "opening a popover displaced its sibling: $before -> $after. The panel is in flow."
        }

        // And the panel is real, not merely absent: it has area, and it is
        // drawn over the page rather than between the two triggers.
        val panel = laidOut("above-panel")
        require(panel.width > 0f && panel.height > 0f) { "the panel has no area: $panel" }
    }

    /**
     * Reported by the user: an open panel "comes with us in scroll".
     *
     * It did. The position clamp ran unconditionally, so once the trigger had
     * scrolled off the top of the page the panel was dragged back inside the
     * window and sat there — anchored to nothing, following the reader down the
     * page. The clamp now applies only while the anchor is on screen, and the
     * popup window no longer lets the window manager clip it back into view.
     */
    @Test
    fun the_panel_leaves_the_screen_with_its_trigger() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-panel") }
        Thread.sleep(500)

        // Scroll the PAGE — not the panel, which is in its own window and
        // swallows the gesture.
        compose.onAllNodesWithText("Props", substring = true)[0].performScrollTo()
        compose.waitForIdle()
        Thread.sleep(800)

        val table = frameTable()
        val trigger = table["pop-trigger-open"] ?: error("the trigger left the frame table")

        require(trigger.top < -100f) {
            "the page did not scroll far enough to prove anything: trigger=$trigger"
        }

        val panel = table["pop-panel"]
        require(panel == null || panel.bottom <= 0f) {
            "the panel stayed on screen after its trigger scrolled away: " +
                "trigger=$trigger panel=$panel"
        }
    }

    /**
     * Also reported: tapping outside an open panel did not close it.
     *
     * The panel's window reports the outside tap through on_open_change and the
     * SCREEN closes it — the window never closes itself, or it would vanish
     * while `open` stayed true and the trigger kept its -trigger-open tag.
     */
    @Test
    fun a_tap_outside_the_panel_closes_it() {
        tap("pop-trigger-closed")
        compose.waitUntil(10_000) { tagged("pop-panel") }
        Thread.sleep(500)

        val panel = laidOut("pop-panel")

        // A REAL touch, through the system — not compose.performClick.
        //
        // The panel lives in its own window, and an outside tap only reaches it
        // as the window manager delivering ACTION_OUTSIDE to a touch-modal
        // window. Compose's synthetic click is injected straight into one
        // window's semantics tree and never crosses that boundary, so it can
        // neither dismiss the popup nor prove that a finger would.
        val density = compose.activity.resources.displayMetrics.density
        val x = 10f * density
        val y = (panel.bottom + 80f) * density
        val instr = androidx.test.platform.app.InstrumentationRegistry.getInstrumentation()
        val down = android.os.SystemClock.uptimeMillis()

        run {
            val decor = compose.activity.window.decorView
            val ins = androidx.core.view.ViewCompat.getRootWindowInsets(decor)
                ?.getInsets(androidx.core.view.WindowInsetsCompat.Type.systemBars())
            android.util.Log.i(
                "TapProbe",
                "density=$density window=${decor.width}x${decor.height}px " +
                    "insets=top:${ins?.top ?: -1},bottom:${ins?.bottom ?: -1} " +
                    "tap=(${x},${y})px inWindow=${x >= 0 && y >= 0 && x < decor.width && y < decor.height} " +
                    "aboveNav=${y < decor.height - (ins?.bottom ?: 0)}"
            )
        }

        instr.uiAutomation.injectInputEvent(
            android.view.MotionEvent.obtain(
                down, down, android.view.MotionEvent.ACTION_DOWN, x, y, 0
            ).apply { source = android.view.InputDevice.SOURCE_TOUCHSCREEN },
            true,
        )
        instr.uiAutomation.injectInputEvent(
            android.view.MotionEvent.obtain(
                down, down + 60, android.view.MotionEvent.ACTION_UP, x, y, 0
            ).apply { source = android.view.InputDevice.SOURCE_TOUCHSCREEN },
            true,
        )
        compose.waitForIdle()

        compose.waitUntil(10_000) { !tagged("pop-panel") }
        require(tagged("pop-trigger-closed")) {
            "the panel closed but the trigger still reads open — the window and " +
                "the assign are out of step"
        }
    }

    @Test
    fun side_right_puts_them_abreast() {
        tap("beside-trigger-closed")
        compose.waitUntil(10_000) { tagged("beside-panel") }

        val (trigger, panel) = frames("beside")

        require(panel.left >= trigger.right) {
            "side={:right} did not put the panel beside the trigger: trigger=$trigger panel=$panel"
        }
        // Abreast, not stacked — align={:start} lines the panel's top up with
        // the trigger's, UNLESS the window clamp moves it, which is what
        // happens here: performScrollTo moves the minimum distance, so the
        // trigger ends up near the bottom edge and the panel is pushed up to
        // stay on screen. The web's positionPopup clamps exactly the same way,
        // so accept either — but not a panel that has drifted below its anchor,
        // which no rule would produce.
        val aligned = kotlin.math.abs(panel.top - trigger.top) <= 2f
        val clampedUp = panel.top < trigger.top && panel.bottom <= trigger.bottom
        require(aligned || clampedUp) {
            "align={:start} neither lined the tops up nor clamped upward: " +
                "trigger=$trigger panel=$panel"
        }
        // The panel really is to the RIGHT of the trigger now. It used to share
        // a Row with it, where "beside" was whatever space the trigger left
        // over; the panel is in its own window and the trigger hugs its label,
        // so this is a plain geometric fact.
        require(panel.left >= trigger.right - 1f) {
            "the panel is not to the right of the trigger: trigger=$trigger panel=$panel"
        }
    }

    @Test
    fun align_end_pushes_a_narrow_panel_to_the_trailing_edge() {
        tap("aligned-trigger-closed")
        compose.waitUntil(10_000) { tagged("aligned-panel") }

        val (trigger, panel) = frames("aligned")

        // align={:end} means the panel's trailing edge lines up with the
        // TRIGGER's, which is the web's contract. It used to mean "the right of
        // a full-width trigger", i.e. the screen edge, because the trigger
        // spanned the page; the trigger hugs now, so this is the real thing.
        require(panel.width > 0f && panel.height > 0f) { "the panel has no area: $panel" }

        // align={:end} lines the panel's trailing edge up with the TRIGGER's —
        // unless doing so would push it off the leading edge, in which case the
        // clamp wins and it pins flush at the screen's padding. Both are the
        // web's behaviour, and this example hits the second: the trigger sits
        // ~110dp wide near the left edge, so a 220dp panel cannot have its
        // right edge at the trigger's without its left going negative.
        val aligned = kotlin.math.abs(panel.right - trigger.right) <= 2f
        val clamped = panel.left <= 32f && panel.right > trigger.right
        require(aligned || clamped) {
            "align={:end} neither lined the trailing edges up nor clamped: " +
                "trigger=$trigger panel=$panel"
        }
    }

    @Test
    fun a_disabled_trigger_cannot_open_anything() {
        tap("off-trigger-closed")

        // disabled wires no handler at all, so there is nothing to fire.
        require(!tagged("off-panel")) { "a disabled trigger opened its panel" }
        require(tagged("off-trigger-closed")) { "a disabled trigger changed state" }
    }

    @Test
    fun the_pinned_example_needs_no_trigger_at_all() {
        // Omit `trigger` and the popover is the panel alone — which is how Menu
        // and the select-style components use it. Its parts are still tagged.
        require(tagged("chrome-panel")) { "the pinned-open example rendered no panel" }
        require(tagged("chrome-title") && tagged("chrome-desc")) {
            "the pinned example lost its title or description"
        }
        require(!tagged("chrome-trigger-closed") && !tagged("chrome-trigger-open")) {
            "a popover with no trigger prop drew one anyway"
        }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Tap the trigger",
            "Hold to open",
            "Which side it takes",
            "A narrow panel has somewhere to go",
            "Disabled, and without a chevron",
            "Chrome",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
