package com.example.mishka_mob

import android.view.View
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.junit4.AndroidComposeTestRule
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice

/**
 * A REAL touch, through the system — not compose.performClick — that lands
 * outside every frame in [keepClear], then waits for [dismissed] to turn true.
 *
 * A popup lives in its own window, and an outside tap only reaches it as the
 * window manager delivering ACTION_OUTSIDE to a touch-modal window. Compose's
 * synthetic click is injected straight into one window's semantics tree and
 * never crosses that boundary, so it can neither dismiss the popup nor prove
 * that a finger would.
 *
 * UiDevice, not Instrumentation.sendPointerSync. androidx's own PopupDismissTest
 * says why: "Need to click via UiDevice as this click has to propagate to
 * multiple windows". sendPointerSync goes through the inject-into-self path,
 * which on API 34+ refuses any event landing outside a window this app owns —
 * the exact IllegalArgumentException CI was throwing.
 *
 * Where it lands matters as much as how. The first version tapped at x = 10dp,
 * which is inside the back-gesture zone on a gesture-navigation device: the
 * system took the touch, started a back gesture and cancelled it, and the app
 * saw nothing. That happened on the release job's emulator and never on a
 * phone with three-button navigation, which has no such zone. So the tap goes
 * down the middle of the screen, in the band above or below [keepClear], and
 * never within [EDGE_DP] of a side or the top or [BOTTOM_DP] of the bottom.
 *
 * [keepClear] is in dp and activity-window space, which is what
 * MobBridge.elementFrames reports: the popup and its trigger. The tap goes
 * [GAP_DP] clear of them, so it is outside the popup and not on the trigger.
 *
 * Window focus is waited for first and reported either way. The popup is
 * focusable, so the window that has it is the popup's, not the activity's, and
 * the answer comes from the window manager rather than from
 * Activity.hasWindowFocus. A missing focus does not stop the tap, because a
 * touch does not need it; it is named in the failure instead, so a timeout says
 * what the screen looked like rather than only that nothing closed.
 */
fun AndroidComposeTestRule<*, MainActivity>.tapOutside(
    vararg keepClear: Rect,
    dismissed: () -> Boolean,
) {
    val metrics = activity.resources.displayMetrics
    val widthDp = metrics.widthPixels / metrics.density
    val heightDp = metrics.heightPixels / metrics.density

    val below = keepClear.maxOf { it.bottom } + GAP_DP
    val above = keepClear.minOf { it.top } - GAP_DP
    val x = widthDp / 2f
    val y =
        when {
            below <= heightDp - BOTTOM_DP -> below
            above >= EDGE_DP -> above
            else ->
                error(
                    "no room to tap clear of ${keepClear.toList()} on a ${widthDp}x${heightDp}dp " +
                        "screen without entering a system gesture zone"
                )
        }

    // UiDevice takes SCREEN coordinates, and elementFrames is relative to the
    // content view, so that view's own offset is added back.
    val origin = intArrayOf(0, 0)
    activity.findViewById<View>(android.R.id.content).getLocationOnScreen(origin)
    val sx = (origin[0] + x * metrics.density).toInt()
    val sy = (origin[1] + y * metrics.density).toInt()

    val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    var focus = focusedWindow(device)
    val giveUp = System.currentTimeMillis() + FOCUS_WAIT_MS
    while (focus == NO_FOCUS && System.currentTimeMillis() < giveUp) {
        Thread.sleep(250)
        focus = focusedWindow(device)
    }

    val where = "window=($x,$y)dp origin=(${origin[0]},${origin[1]}) screen=($sx,$sy) $focus"
    android.util.Log.i("TapProbe", where)

    device.click(sx, sy)
    waitForIdle()

    try {
        waitUntil(DISMISS_WAIT_MS, dismissed)
    } catch (e: Throwable) {
        throw AssertionError(
            "a system tap at $where did not dismiss the popup within ${DISMISS_WAIT_MS}ms; " +
                "focus afterwards: ${focusedWindow(device)}",
            e,
        )
    }
}

private const val NO_FOCUS = "mCurrentFocus=null"

/** The window manager's own line for who has input focus, e.g. `mCurrentFocus=Window{… Pop-Up Window}`. */
private fun focusedWindow(device: UiDevice): String =
    device
        .executeShellCommand("dumpsys window")
        .lineSequence()
        .map { it.trim() }
        .firstOrNull { it.startsWith("mCurrentFocus=") }
        ?: "mCurrentFocus=unknown"

private const val EDGE_DP = 48f
private const val BOTTOM_DP = 96f
private const val GAP_DP = 80f
private const val FOCUS_WAIT_MS = 10_000L
private const val DISMISS_WAIT_MS = 10_000L
