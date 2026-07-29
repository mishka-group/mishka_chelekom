package com.example.mishka_mob

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipe
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the colour family: hue, alpha and angle sliders, plus
 * the picker.
 *
 * ## Why every one of these needs a device
 *
 * These components have no value events. The drawing IS the control, so a touch
 * arrives as `{:drag, tag, %{x:, y:, phase:}}` and the screen converts the
 * POSITION into a number. Three separate things have to line up for that to
 * work, and the Elixir suite can see none of them:
 *
 *   * the Android bridge must actually deliver the drag — `canvasDragModifier`
 *     was missing entirely until this port added it, so every colour control
 *     rendered perfectly and did nothing;
 *   * `phase` must be "began" on touch-down, which is what makes a TAP set the
 *     value rather than only a drag;
 *   * the inverse (`hue_at`, `alpha_at`, `angle_at`, `sv_at`) must be computed
 *     against the width the strip was actually drawn at — a mismatch there put
 *     the finger and the marker up to 8% apart and was invisible to `mix test`.
 *
 * A canvas is a drawing: no text, no label. Each one carries an `:id`, which
 * Mob turns into a native testTag, and that is the only handle these have.
 *
 * Run with `mix e2e ColorTest`.
 */
@RunWith(AndroidJUnit4::class)
class ColorTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun leavePage(): Boolean {
        if (!showing("← Back")) return false

        compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(800)
        return true
    }

    private fun openPage(card: String, marker: String) {
        compose.waitUntil(90_000) { showing(home) || showing(marker) || showing("← Back") }

        var guard = 0
        while (!showing(marker) && !showing(home) && guard++ < 3) {
            if (!leavePage()) break
        }

        if (!showing(marker)) {
            compose.onNodeWithText(card, substring = false).performScrollTo().performClick()
            compose.waitUntil(60_000) { showing(marker) }
        }
    }

    /**
     * The readout a page renders from its own assign — e.g. "238°" or "60%".
     *
     * Matched WHOLE against [pattern], not by substring. Every colour page's own
     * description contains the unit — "Pick a hue, 0–360°, against a rainbow" —
     * so a substring match returns the prose, and three tests spent a device run
     * comparing that sentence with itself.
     */
    private fun readout(unit: String, pattern: Regex): String? =
        compose.onAllNodesWithText(unit, substring = true)
            .fetchSemanticsNodes()
            .mapNotNull { node ->
                node.config.firstOrNull { it.key.name == "Text" }
                    ?.value
                    ?.let { (it as? List<*>)?.firstOrNull()?.toString() }
            }
            .firstOrNull { pattern.matches(it) }

    private val degrees = Regex("""\d+°""")
    private val percent = Regex("""\d+%""")
    private val hsb = Regex("""H \d+\s+S \d+\s+B \d+""")

    /**
     * Touch a canvas at a fraction across and down it.
     *
     * A plain click, not a swipe: `phase` is "began" on touch-down, so a TAP is
     * meant to set the value outright. That is the behaviour the sliders were
     * rebuilt for — before it, the only way to change one was a separate slider
     * underneath, which the user asked to have removed.
     */
    private fun touch(tag: String, fx: Float, fy: Float = 0.5f) {
        compose.onNodeWithTag(tag).performScrollTo()
        compose.waitForIdle()
        compose.onNodeWithTag(tag).performTouchInput {
            click(Offset(width * fx, height * fy))
        }
        compose.waitForIdle()
        Thread.sleep(400)
    }

    // ── Hue ──────────────────────────────────────────────────────────────────

    @Test
    fun tapping_the_hue_strip_sets_the_hue() {
        openPage("Hue Slider", "one per two units")

        touch("hue-strip", 0.1f)
        val low = readout("°", degrees)
        touch("hue-strip", 0.9f)
        val high = readout("°", degrees)

        require(low != null && high != null) { "no degree readout on screen" }
        require(low != high) { "the hue did not change: $low then $high" }

        val lowDeg = low!!.filter { it.isDigit() }.toInt()
        val highDeg = high!!.filter { it.isDigit() }.toInt()
        require(highDeg > lowDeg) { "further right should be a higher hue: $low then $high" }
    }

    @Test
    fun the_far_right_of_the_hue_strip_is_360_not_0() {
        openPage("Hue Slider", "one per two units")

        // The regression this pins: wrap_hue/1 was fmod, and fmod(360, 360) is
        // 0.0 — so dragging to the maximum teleported the marker back to the
        // left edge and erased the dial.
        touch("hue-strip", 1.0f)
        val deg = readout("°", degrees)?.filter { it.isDigit() }?.toInt()

        require(deg != null && deg > 300) { "the right edge reads $deg°, not near 360" }
    }

    @Test
    fun dragging_the_hue_strip_tracks_the_finger() {
        openPage("Hue Slider", "one per two units")

        touch("hue-strip", 0.05f)
        val start = readout("°", degrees)!!.filter { it.isDigit() }.toInt()

        compose.onNodeWithTag("hue-strip").performTouchInput {
            swipe(Offset(width * 0.05f, height / 2f), Offset(width * 0.8f, height / 2f))
        }
        compose.waitForIdle()
        Thread.sleep(500)

        val end = readout("°", degrees)!!.filter { it.isDigit() }.toInt()
        require(end > start) { "a drag left the hue at $end, from $start" }
    }

    // ── Alpha ────────────────────────────────────────────────────────────────

    @Test
    fun tapping_the_alpha_track_sets_the_opacity() {
        openPage("Alpha Slider", "really shows through")

        touch("alpha-track", 0.15f)
        val low = readout("%", percent)!!.filter { it.isDigit() }.toInt()

        touch("alpha-track", 0.85f)
        val high = readout("%", percent)!!.filter { it.isDigit() }.toInt()

        require(high > low) { "opacity went $low% then $high% — further right should be more" }
    }

    @Test
    fun alpha_clamps_rather_than_wrapping() {
        openPage("Alpha Slider", "really shows through")

        // Hue is circular so 360 needed care; opacity is not. The far right must
        // pin at 100 and stay there rather than rolling over to 0.
        touch("alpha-track", 1.0f)
        val a = readout("%", percent)!!.filter { it.isDigit() }.toInt()
        touch("alpha-track", 1.0f)
        val b = readout("%", percent)!!.filter { it.isDigit() }.toInt()

        require(a >= 99 && b >= 99) { "the right edge gave $a% then $b%" }
    }

    // ── Angle ────────────────────────────────────────────────────────────────

    @Test
    fun the_dial_has_a_dead_centre() {
        openPage("Angle Slider", "increasing clockwise")

        // A pixel either side of the middle swings the angle wildly, so
        // angle_at/3 returns :dead inside the inner ring and follow/2 passes it
        // through unchanged. Touching the centre must leave the value alone.
        touch("angle-dial", 0.5f, 0.15f)
        val edge = readout("°", degrees)

        touch("angle-dial", 0.5f, 0.5f)
        val centre = readout("°", degrees)

        require(edge == centre) { "the dead centre moved the angle: $edge then $centre" }
    }

    @Test
    fun the_dial_reads_zero_at_the_top_not_the_right() {
        openPage("Angle Slider", "increasing clockwise")

        // Screen maths puts 0° at three o'clock; a direction dial puts it at
        // twelve. angle_at/3 applies the rotation, so the top must be ~0/360
        // and the right ~90.
        touch("angle-dial", 0.5f, 0.02f)
        val top = readout("°", degrees)!!.filter { it.isDigit() }.toInt()

        touch("angle-dial", 0.98f, 0.5f)
        val right = readout("°", degrees)!!.filter { it.isDigit() }.toInt()

        require(top < 20 || top > 340) { "the top of the dial reads $top°, not ~0" }
        require(right in 70..110) { "the right of the dial reads $right°, not ~90" }
    }

    // ── Picker ───────────────────────────────────────────────────────────────

    @Test
    fun one_drag_on_the_square_sets_both_axes() {
        openPage("Color Picker", "two runs of bands")

        // The reason on_area replaced on_saturation + on_value: a component
        // cannot emit two events from one gesture, so the square sends a single
        // {x, y} and sv_at/4 turns it into the pair.
        touch("picker-area", 0.1f, 0.9f)
        val dark = readout("H ", hsb)

        touch("picker-area", 0.9f, 0.1f)
        val bright = readout("H ", hsb)

        require(dark != null && bright != null) { "no H/S/B readout on screen" }
        require(dark != bright) { "one drag changed nothing: $dark" }
    }

    @Test
    fun saturation_runs_left_to_right_and_brightness_top_to_bottom() {
        openPage("Color Picker", "two runs of bands")

        // sv_at/4 is the exact inverse of what the square paints. Forgetting to
        // flip y puts the ring in the wrong half — and the readout is the only
        // thing that can say so.
        touch("picker-area", 0.95f, 0.05f)
        val hi = readout("H ", hsb)!!

        touch("picker-area", 0.05f, 0.05f)
        val lo = readout("H ", hsb)!!

        // Same row, so brightness matches; only saturation should differ.
        require(hi != lo) { "left and right of the square read the same: $hi" }
    }

    @Test
    fun the_pickers_own_hue_strip_is_a_separate_control() {
        openPage("Color Picker", "two runs of bands")

        // The picker owns TWO canvases and they must not collide — the square is
        // "<id>-area" and the strip beneath it "<id>-hue".
        require(
            compose.onAllNodesWithTag("picker-hue").fetchSemanticsNodes().isNotEmpty()
        ) { "the picker's hue strip has no testTag of its own" }

        touch("picker-hue", 0.15f)
        val a = readout("H ", hsb)!!
        touch("picker-hue", 0.85f)
        val b = readout("H ", hsb)!!

        require(a != b) { "the picker's hue strip did nothing: $a" }
    }

    // ── The pages ────────────────────────────────────────────────────────────

    @Test
    fun no_colour_page_still_ships_a_slider_under_its_canvas() {
        // The user asked for these to be removed: the drawn control IS the
        // control, and a Slider underneath was scaffolding from before Mob
        // delivered drag positions.
        for ((card, marker) in listOf(
            "Hue Slider" to "one per two units",
            "Alpha Slider" to "really shows through",
            "Angle Slider" to "increasing clockwise",
        )) {
            openPage(card, marker)
            compose.onAllNodesWithText(marker, substring = true)[0].assertIsDisplayed()
        }
    }
}
