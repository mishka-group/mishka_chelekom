package com.example.mishka_mob

import android.view.MotionEvent
import android.view.View
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.isPopup
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

    // DIAG-BEGIN
    val timeline = mutableListOf<String>()
    fun sample(label: String) {
        val f = focusedWindow(device)
        timeline += "$label ${f.removePrefix("mCurrentFocus=")}"
        return
    }
    sample("t0")
    val giveUp = System.currentTimeMillis() + FOCUS_WAIT_MS
    var attempted = false
    while (!ours(focusedWindow(device)) && System.currentTimeMillis() < giveUp) {
        Thread.sleep(500)
        sample("wait")
        if (!attempted && System.currentTimeMillis() > giveUp - FOCUS_WAIT_MS / 2) {
            attempted = true
            // Re-assert the activity as the top one: a singleTop launch of the activity that is
            // already on top only re-delivers the intent, which MainActivity ignores.
            device.executeShellCommand("am start --activity-single-top -n ${activity.packageName}/.MainActivity")
            sample("after-am-start")
        }
    }
    val focus = focusedWindow(device)
    dump(device, "before-tap")

    val touches = java.util.Collections.synchronizedList(mutableListOf<String>())
    runOnUiThread {
        onAllNodes(isPopup()).fetchSemanticsNodes(atLeastOneRootRequired = false).forEach { node ->
            val top = (node.root as? View)?.rootView
            top?.setOnTouchListener { _, e ->
                touches += "action=${MotionEvent.actionToString(e.actionMasked)} x=${e.x} y=${e.y}"
                false
            }
        }
    }
    // DIAG-END

    val where = "window=($x,$y)dp origin=(${origin[0]},${origin[1]}) screen=($sx,$sy) $focus"
    android.util.Log.i("TapProbe", where)
    android.util.Log.i("TapProbe", "timeline: $timeline")

    device.click(sx, sy)
    waitForIdle()

    try {
        waitUntil(DISMISS_WAIT_MS, dismissed)
        android.util.Log.i("TapProbe", "dismissed; popup window saw $touches")
    } catch (e: Throwable) {
        dump(device, "after-tap")
        throw AssertionError(
            "a system tap at $where did not dismiss the popup within ${DISMISS_WAIT_MS}ms; " +
                "focus timeline: $timeline; popup window saw $touches; " +
                "focus afterwards: ${focusedWindow(device)}",
            e,
        )
    }
}

// DIAG-BEGIN
private fun ours(focusLine: String): Boolean =
    focusLine.contains("com.example.mishka_mob") || focusLine.contains("Pop-Up Window")

private fun dump(device: UiDevice, label: String) {
    fun log(line: String) = android.util.Log.i("TapProbe", "$label| ${line.take(500)}")
    val window = device.executeShellCommand("dumpsys window windows").lineSequence().map { it.trim() }
    window
        .filter {
            it.startsWith("Window #") || it.startsWith("mCurrentFocus") || it.startsWith("mFocusedApp") ||
                it.contains("mViewVisibility") || it.startsWith("isVisible") || it.contains("canReceiveKeys") ||
                it.startsWith("mAttrs=") || it.startsWith("mHasSurface")
        }
        .take(160)
        .forEach { log("win: $it") }
    device.executeShellCommand("dumpsys activity activities").lineSequence().map { it.trim() }
        .filter {
            it.contains("topResumedActivity") || it.contains("ResumedActivity") || it.contains("mFocusedApp") ||
                it.contains("mFocusedRootTask") || it.startsWith("* Task{") || it.startsWith("* Hist")
        }
        .take(40)
        .forEach { log("act: $it") }
    device.executeShellCommand("dumpsys input").lineSequence().map { it.trim() }
        .filter {
            it.startsWith("name='") || Regex("^\\d+: name='").containsMatchIn(it) ||
                it.contains("FocusedApplications") || it.contains("FocusedWindows") ||
                it.contains("focusedWindow") || it.contains("TouchStates") || it.contains("Window:")
        }
        .take(60)
        .forEach { log("inp: $it") }
}
// DIAG-END

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
private const val FOCUS_WAIT_MS = 12_000L
private const val DISMISS_WAIT_MS = 10_000L
