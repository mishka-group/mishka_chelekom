package com.example.mishka_mob

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.net.Uri
import android.opengl.GLES30
import android.opengl.GLSurfaceView
import android.os.SystemClock
import android.speech.tts.TextToSpeech
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import android.util.Log
import android.media.AudioManager
import java.util.UUID
import java.io.ByteArrayOutputStream
import java.io.File
import java.lang.ref.WeakReference
import java.nio.ByteBuffer
import java.nio.ByteOrder
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size as ComposeSize
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import android.graphics.Bitmap
import android.graphics.Paint
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.platform.testTag
import android.view.PixelCopy
import android.view.WindowManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.QuestionMark
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.AcUnit
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DividerDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.State
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Typeface
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.view.HapticFeedbackConstants
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import org.json.JSONArray
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import org.json.JSONObject
import androidx.camera.core.CameraSelector
import androidx.camera.core.Preview as CameraPreview
import androidx.camera.core.UseCase
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.LifecycleOwner

/**
 * Bridge between the BEAM and Jetpack Compose.
 *
 * The BEAM calls setRootJson(json) (via mob_nif's set_root/1) whenever the
 * screen re-renders. MutableState triggers recomposition automatically —
 * no main-thread dispatch needed for state writes.
 *
 * Tap events: Compose onClick calls nativeSendTap(handle), which routes
 * to mob_send_tap() in mob_nif.c and sends {:tap, tag} to the registered PID.
 *
 * Holds the rendered tree and the nav transition to animate.
 *
 * navKey only increments on actual navigation transitions (push/pop/reset).
 * AnimatedContent in MainActivity uses navKey as the contentKey so that
 * same-screen BEAM re-renders (transition == "none") recompose the existing
 * composable in place — no content swap, no focus loss, no keyboard dismissal.
 */
data class RootState(val navKey: Int, val transition: String, val node: MobNode?)

object MobBridge {

    private val _rootState = mutableStateOf(RootState(0, "none", null))
    val rootState: State<RootState> get() = _rootState

    // Compose-observable theme palette pushed from `Mob.Theme.set/1` via
    // `:mob_nif.set_theme/1`. Null until the BEAM side calls Mob.Theme.set
    // for the first time; the MaterialTheme wrapper in MainActivity reads
    // this and falls back to a sensible default while it's still null.
    // Keys are the semantic token strings (`"primary"`, `"on_surface"`,
    // `"surface_raised"`, `"muted"`, …) — the same names mob's renderer
    // uses on the Elixir side. Values are ARGB longs already resolved
    // through theme.color_map / Mob.Renderer.colors so MaterialTheme can
    // call `Color(it)` directly.
    private val _themeColors = mutableStateOf<Map<String, Long>?>(null)
    val themeColors: State<Map<String, Long>?> get() = _themeColors

    /** Called from mob_nif.zig (nif_set_theme) whenever `Mob.Theme.set/1`
     *  runs on the BEAM side. The JSON is the resolved-token map: atom
     *  names → ARGB ints (e.g. `{"primary":4286331629,"surface":...}`).
     *  The Compose-state write hops to the main thread so recomposition
     *  fires safely. */
    @JvmStatic
    fun setTheme(json: String) {
        try {
            val obj = JSONObject(json)
            val map = mutableMapOf<String, Long>()
            val keys = obj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                val value = obj.opt(key)
                if (value is Number) map[key] = value.toLong()
            }
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                _themeColors.value = map
            }
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "setTheme failed: ${e.message}")
        }
    }

    // Persists LazyListState across re-renders so scroll position survives data
    // updates. Keyed by the on_end_reached handle integer, which is stable within
    // a screen (same render-order index after each clear_taps). Cleared on
    // navigation transitions (push/pop/reset) where the list is genuinely new.
    private val lazyListStates = mutableMapOf<Int, LazyListState>()

    fun getOrCreateLazyListState(handle: Int): LazyListState =
        lazyListStates.getOrPut(handle) { LazyListState() }

    // ── Test harness: id-addressable scroll registry + in-process capture ──────
    //
    // Gives a remotely-connected agent (Mob.Test.screenshot/scroll_info/scroll_to)
    // pixels and deterministic scroll over Erlang dist, with no adb/xcrun. A
    // ScrollHandle carries whichever Compose scroll state backs the node plus its
    // measured viewport; the :scroll / lazy-list composables register themselves
    // here by their :id prop.
    class ScrollHandle {
        var scrollState: ScrollState? = null // pixel-precise vertical/horizontal scroll
        var lazyState: LazyListState? = null // item-indexed list
        var viewportPx: Int = 0 // measured viewport extent (for ScrollState kind)
        var horizontal: Boolean = false
    }

    // Concurrent: written from the Compose main thread (registration), read from
    // the NIF/binder thread (scrollInfo/scrollTo). computeIfAbsent keeps creation
    // atomic so a registration race can't drop a handle.
    private val scrollHandlesById = ConcurrentHashMap<String, ScrollHandle>()
    private val mainScope = CoroutineScope(Dispatchers.Main)

    fun scrollHandle(id: String): ScrollHandle =
        scrollHandlesById.computeIfAbsent(id) { ScrollHandle() }

    // ── Element frame registry (positions without a screenshot) ────────────────
    //
    // Any rendered node with an :id gets a frameTrackingModifier that records its
    // window bounds (px) here and tags it with a Compose testTag. elementFrames()
    // returns them in dp so an agent can locate/drive elements by id over dist
    // with no image bytes. Populated by RenderNodeInner.
    //
    // Concurrent: written from the Compose main thread (onGloballyPositioned),
    // iterated from the NIF/binder thread (elementFrames). ConcurrentHashMap's
    // weakly-consistent iteration can't throw ConcurrentModificationException.
    private val elementFramesById = ConcurrentHashMap<String, FloatArray>()

    fun recordElementFrame(id: String, x: Float, y: Float, w: Float, h: Float) {
        elementFramesById[id] = floatArrayOf(x, y, w, h)
    }

    fun frameTrackingModifier(id: String): Modifier =
        Modifier
            .testTag(id)
            .onGloballyPositioned { c ->
                val b = c.boundsInWindow()
                recordElementFrame(id, b.left, b.top, b.width, b.height)
            }

    /** JSON {id:[x,y,w,h], ...} in dp (matches screenInfo / tap_xy units). */
    @JvmStatic
    fun elementFrames(): String {
        val density = activityRef?.get()?.resources?.displayMetrics?.density ?: 1f
        val o = JSONObject()
        for ((id, f) in elementFramesById) {
            val arr = org.json.JSONArray()
            arr.put((f[0] / density).toDouble())
            arr.put((f[1] / density).toDouble())
            arr.put((f[2] / density).toDouble())
            arr.put((f[3] / density).toDouble())
            o.put(id, arr)
        }
        return o.toString()
    }

    /**
     * Capture the activity window in-process and return PNG/JPEG bytes.
     * Called from nif_screenshot/3 via JNI. `scale` is a multiplier of native
     * resolution (1.0 = full, 0.5 = half). Returns null when there is no live
     * window (e.g. backgrounded) so the NIF can report {:error, :no_window}.
     */
    @JvmStatic
    fun screenshot(format: String, quality: Int, scale: Double): ByteArray? {
        val activity = activityRef?.get() ?: return null
        val window = activity.window ?: return null
        val decor = window.decorView
        val w = decor.width
        val h = decor.height
        if (w <= 0 || h <= 0) return null

        val src = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val latch = java.util.concurrent.CountDownLatch(1)
        var ok = false
        val handler = android.os.Handler(android.os.Looper.getMainLooper())

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PixelCopy.request(window, src, { result ->
                ok = result == PixelCopy.SUCCESS
                latch.countDown()
            }, handler)
        } else {
            // Pre-O fallback: draw the decor view (misses SurfaceView/GL layers).
            handler.post {
                ok =
                    try {
                        decor.draw(android.graphics.Canvas(src)); true
                    } catch (e: Throwable) {
                        false
                    }
                latch.countDown()
            }
        }

        if (!latch.await(2, java.util.concurrent.TimeUnit.SECONDS) || !ok) return null

        val bmp =
            if (scale > 0.0 && scale != 1.0) {
                Bitmap.createScaledBitmap(
                    src,
                    (w * scale).toInt().coerceAtLeast(1),
                    (h * scale).toInt().coerceAtLeast(1),
                    true
                )
            } else {
                src
            }

        val out = java.io.ByteArrayOutputStream()
        if (format == "jpeg") {
            bmp.compress(Bitmap.CompressFormat.JPEG, quality.coerceIn(0, 100), out)
        } else {
            bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
        return out.toByteArray()
    }

    /**
     * Read a scroll view's offset/extent as a flat JSON object (the shape
     * Mob.Test.scroll_info/2 decodes). Returns null when no scroll view is
     * registered under `id`. `kind` is "pixel" for ScrollState (px units) or
     * "index" for LazyListState (item-index units; viewport = visible items).
     */
    @JvmStatic
    fun scrollInfo(id: String): String? {
        val h = scrollHandlesById[id] ?: return null

        h.scrollState?.let { s ->
            val vp = h.viewportPx.toDouble()
            val maxV = s.maxValue.toDouble()
            val content = maxV + vp
            val off = s.value.toDouble()
            val o = JSONObject()
            if (h.horizontal) {
                o.put("offset_x", off); o.put("offset_y", 0.0)
                o.put("content_w", content); o.put("content_h", vp)
                o.put("viewport_w", vp); o.put("viewport_h", vp)
                o.put("max_x", maxV); o.put("max_y", 0.0)
            } else {
                o.put("offset_x", 0.0); o.put("offset_y", off)
                o.put("content_w", vp); o.put("content_h", content)
                o.put("viewport_w", vp); o.put("viewport_h", vp)
                o.put("max_x", 0.0); o.put("max_y", maxV)
            }
            o.put("kind", "pixel")
            return o.toString()
        }

        h.lazyState?.let { ls ->
            val li = ls.layoutInfo
            val total = li.totalItemsCount.toDouble()
            val visible = li.visibleItemsInfo.size.toDouble()
            val first = ls.firstVisibleItemIndex.toDouble()
            val maxIdx = (total - visible).coerceAtLeast(0.0)
            val o = JSONObject()
            o.put("offset_x", 0.0); o.put("offset_y", first)
            o.put("content_w", 0.0); o.put("content_h", total)
            o.put("viewport_w", 0.0); o.put("viewport_h", visible)
            o.put("max_x", 0.0); o.put("max_y", maxIdx)
            o.put("kind", "index")
            return o.toString()
        }

        return null
    }

    /**
     * Scroll the view registered under `id` to absolute (x, y). Pixel views use
     * the relevant axis; index lists use y as an item index. Runs the suspend
     * scroll on the main thread and blocks the NIF thread until it completes.
     */
    @JvmStatic
    fun scrollTo(id: String, x: Double, y: Double): Boolean {
        val h = scrollHandlesById[id] ?: return false
        val latch = java.util.concurrent.CountDownLatch(1)
        var ok = false
        mainScope.launch {
            try {
                val s = h.scrollState
                val ls = h.lazyState
                when {
                    s != null -> {
                        val target = (if (h.horizontal) x else y).toInt()
                        s.scrollTo(target.coerceIn(0, s.maxValue))
                        ok = true
                    }
                    ls != null -> {
                        ls.scrollToItem(y.toInt().coerceAtLeast(0))
                        ok = true
                    }
                }
            } catch (e: Throwable) {
                ok = false
            } finally {
                latch.countDown()
            }
        }
        latch.await(2, java.util.concurrent.TimeUnit.SECONDS)
        return ok
    }

    private var activityRef: WeakReference<Activity>? = null

    /** Called from mob_nif.c via JNI — initialise anything activity-scoped. */
    @JvmStatic
    fun init(activity: Activity) {
        activityRef = WeakReference(activity)
        extractOtpIfNeeded(activity)
        copyMobLogos(activity)
        ensureUsbReceiver(activity.applicationContext)
    }

    /**
     * Lock the activity to an ActivityInfo.SCREEN_ORIENTATION_* constant
     * (SCREEN_ORIENTATION_UNSPECIFIED = -1 to unlock). Called from
     * mob_nif.zig's nif_device_lock_orientation via the cached orientationLock
     * JMethodID. setRequestedOrientation must run on the UI thread.
     */
    @JvmStatic
    fun orientationLock(orientation: Int) {
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            try {
                activity.requestedOrientation = orientation
            } catch (_: Throwable) {
            }
        }
    }

    /**
     * Keep the screen on (FLAG_KEEP_SCREEN_ON) while `on != 0`, clear it
     * otherwise. Called from mob_nif.zig's nif_device_keep_awake via the cached
     * keepAwake JMethodID. Window flags must be set on the UI thread. No
     * permission required.
     */
    @JvmStatic
    fun keepAwake(on: Int) {
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            if (on != 0) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        }
    }

    /**
     * Extracts the bundled OTP runtime from `assets/otp.zip` into `<filesDir>/otp/`.
     *
     * Release builds (assembleRelease / bundleRelease) ship the OTP tree as an
     * asset zip because Play Store installs can't `adb push` it. The extractor
     * runs once on first launch (and again after each app update, keyed by
     * PackageInfo.lastUpdateTime).
     *
     * Debug builds skip extraction — `mix mob.deploy --native --android` pushes
     * the OTP tree directly to `<filesDir>/otp/` via adb, so no asset zip exists
     * and this method becomes a no-op.
     *
     * Pattern mirrors elixir-desktop's `Bridge.kt:unpackZip()`.
     */
    private fun extractOtpIfNeeded(activity: Activity) {
        val assetList = try { activity.assets.list("") ?: emptyArray() } catch (_: Exception) { return }
        if ("otp.zip" !in assetList) return

        val otpDir = java.io.File(activity.filesDir, "otp")
        val marker = java.io.File(otpDir, ".installed_version")
        val expectedVersion = activity.packageManager
            .getPackageInfo(activity.packageName, 0).lastUpdateTime.toString()

        if (marker.exists() && marker.readText() == expectedVersion) return

        if (otpDir.exists()) otpDir.deleteRecursively()
        otpDir.mkdirs()

        activity.assets.open("otp.zip").use { input ->
            java.util.zip.ZipInputStream(java.io.BufferedInputStream(input)).use { zis ->
                val buffer = ByteArray(8192)
                while (true) {
                    val entry = zis.nextEntry ?: break
                    val out = java.io.File(otpDir, entry.name)
                    if (entry.isDirectory) {
                        out.mkdirs()
                    } else {
                        out.parentFile?.mkdirs()
                        java.io.FileOutputStream(out).use { fos ->
                            var n = zis.read(buffer)
                            while (n != -1) { fos.write(buffer, 0, n); n = zis.read(buffer) }
                        }
                    }
                    zis.closeEntry()
                }
            }
        }

        marker.writeText(expectedVersion)
        android.util.Log.i("MobBridge", "extracted OTP runtime, version=$expectedVersion")
    }

    /** Extracts Mob logo PNGs from APK assets to the OTP root so Elixir can reference them. */
    private fun copyMobLogos(activity: Activity) {
        val otpDir = java.io.File(activity.filesDir, "otp").also { it.mkdirs() }
        listOf("mob_logo_dark.png", "mob_logo_light.png").forEach { name ->
            try {
                activity.assets.open(name).use { input ->
                    java.io.File(otpDir, name).outputStream().use { output -> input.copyTo(output) }
                }
            } catch (e: Exception) {
                android.util.Log.w("MobBridge", "Could not copy logo asset $name: $e")
            }
        }
    }

    /**
     * Called from nif_color_scheme via JNI. Returns "light" or "dark" based on
     * the current night-mode UI configuration. Falls back to "light" if the
     * activity is gone (shouldn't happen in practice).
     */
    @JvmStatic
    fun getColorScheme(): String {
        val activity = activityRef?.get() ?: return "light"
        val nightMode =
            activity.resources.configuration.uiMode and
                android.content.res.Configuration.UI_MODE_NIGHT_MASK
        return if (nightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES) "dark"
        else "light"
    }

    /** Called from nif_exit_app via JNI — backgrounds the app without killing it. */
    @JvmStatic
    fun moveToBack() {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread { activity.moveTaskToBack(true) }
        }
    }

    /**
     * Called from MainActivity.onConfigurationChanged when uiMode flips.
     * Forwards to the BEAM via JNI so Mob.Device :appearance subscribers
     * see {:mob_device, :color_scheme_changed, :light | :dark}.
     */
    @JvmStatic
    fun notifyColorSchemeChanged(scheme: String) {
        nativeNotifyColorScheme(scheme)
    }

    /** JNI bridge — implemented in beam_jni.c. */
    @JvmStatic external fun nativeNotifyColorScheme(scheme: String)

    /** Called from mob_nif.c's nif_set_root — updates Compose state. */
    @JvmStatic
    fun setRootJson(json: String, transition: String) {
        // Navigation transitions mean a genuinely different screen — old list state
        // is no longer relevant and would scroll the wrong list to a stale position.
        val newKey = if (transition != "none") {
            lazyListStates.clear()
            scrollHandlesById.clear()
            elementFramesById.clear()
            _rootState.value.navKey + 1
        } else {
            _rootState.value.navKey
        }
        _rootState.value = RootState(newKey, transition, JSONObject(json).toMobNode())
    }

    /** Called from Compose onClick — routes tap back to BEAM via C. */
    @JvmStatic
    external fun nativeSendTap(handle: Int)

    /** Called from Compose onChange — routes change value back to BEAM via C. */
    @JvmStatic
    external fun nativeSendChangeStr(handle: Int, value: String)
    @JvmStatic
    external fun nativeSendChangeBool(handle: Int, value: Boolean)
    @JvmStatic
    external fun nativeSendChangeFloat(handle: Int, value: Float)

    @JvmStatic external fun nativeSendFocus(handle: Int)
    @JvmStatic external fun nativeSendBlur(handle: Int)
    @JvmStatic external fun nativeSendSubmit(handle: Int)

    /** Called from BackHandler in MainActivity when the system back gesture fires. */
    @JvmStatic external fun nativeHandleBack()

    // ── Native delivery stubs — implemented in beam_jni.c ────────────────────
    @JvmStatic external fun nativeDeliverAtom2(pid: Long, a1: String, a2: String)
    @JvmStatic external fun nativeDeliverAtom3(pid: Long, a1: String, a2: String, a3: String)
    @JvmStatic external fun nativeDeliverMotion(pid: Long, ax: Double, ay: Double, az: Double,
                                                  gx: Double, gy: Double, gz: Double, ts: Long)
    @JvmStatic external fun nativeDeliverMotionMag(pid: Long, ax: Double, ay: Double, az: Double,
                                                  gx: Double, gy: Double, gz: Double,
                                                  mx: Double, my: Double, mz: Double,
                                                  heading: Double, ts: Long)
    @JvmStatic external fun nativeDeliverFileResult(pid: Long, event: String, sub: String, json: String?)
    @JvmStatic external fun nativeDeliverPushToken(pid: Long, token: String)
    @JvmStatic external fun nativeDeliverNotification(pid: Long, json: String)
    @JvmStatic external fun nativeSetLaunchNotification(json: String?)
    @JvmStatic external fun nativeDeliverWebViewMessage(pid: Long, json: String)
    @JvmStatic external fun nativeDeliverWebViewBlocked(pid: Long, url: String)
    @JvmStatic external fun nativeDeliverAlertAction(action: String)

    // ── Pending callback PIDs ──────────────────────────────────────────────
    var pendingPermissionPid:  Long = 0
    var pendingPermissionCap:  String = ""
    var pendingFilesPid:       Long = 0

    // ── Permissions ────────────────────────────────────────────────────────
    @JvmStatic
    fun request_permission(pid: Long, cap: String) {
        pendingPermissionPid = pid
        pendingPermissionCap = cap
        val activity = activityRef?.get() ?: run {
            nativeDeliverAtom3(pid, "permission", cap, "denied"); return
        }
        val perms = when (cap) {
            "camera"        -> arrayOf(android.Manifest.permission.CAMERA)
            "microphone"    -> arrayOf(android.Manifest.permission.RECORD_AUDIO)
            "photo_library" -> if (android.os.Build.VERSION.SDK_INT >= 33)
                arrayOf(android.Manifest.permission.READ_MEDIA_IMAGES, android.Manifest.permission.READ_MEDIA_VIDEO)
            else arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE)
            "notifications" -> if (android.os.Build.VERSION.SDK_INT >= 33)
                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS)
            else { nativeDeliverAtom3(pid, "permission", "notifications", "granted"); return }
            // Fall through to a plugin-supplied capability (e.g. mob_location
            // once :location leaves core). Unknown -> denied.
            else -> io.mob.plugin.MobPluginBootstrap.permissionsFor(cap)
                ?: run { nativeDeliverAtom3(pid, "permission", cap, "denied"); return }
        }
        if (perms.all { ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED }) {
            nativeDeliverAtom3(pid, "permission", cap, "granted")
        } else {
            ActivityCompat.requestPermissions(activity, perms, PERM_REQUEST_CODE)
        }
    }

    @JvmStatic
    fun onPermissionResult(granted: Boolean) {
        nativeDeliverAtom3(pendingPermissionPid, "permission", pendingPermissionCap, if (granted) "granted" else "denied")
    }

    // ── File picker ───────────────────────────────────────────────────────
    @JvmStatic
    fun files_pick(pid: Long, typesJson: String) {
        pendingFilesPid = pid
        activityRef?.get()?.let { (it as? MainActivity)?.launchFilePicker() }
            ?: nativeDeliverAtom2(pid, "files", "cancelled")
    }

    @JvmStatic
    fun handleFilesResult(uris: List<Uri>) {
        val pid = pendingFilesPid
        if (uris.isEmpty()) { nativeDeliverAtom2(pid, "files", "cancelled"); return }
        val activity = activityRef?.get() ?: return
        Thread {
            try {
                val items = uris.mapIndexed { i, uri ->
                    val name = uri.lastPathSegment ?: "file_$i"
                    val tmp = File(activity.cacheDir, "mob_file_${System.currentTimeMillis()}_$name")
                    activity.contentResolver.openInputStream(uri)?.use { it.copyTo(tmp.outputStream()) }
                    val size = tmp.length()
                    val mime = activity.contentResolver.getType(uri) ?: "application/octet-stream"
                    """{"path":"${tmp.absolutePath}","name":"$name","mime":"$mime","size":$size}"""
                }
                val json = "[${items.joinToString(",")}]"
                nativeDeliverFileResult(pid, "files", "picked", json)
            } catch (e: Exception) {
                nativeDeliverAtom2(pid, "files", "cancelled")
            }
        }.start()
    }

    // ── Audio recording ───────────────────────────────────────────────────
    private var audioRecorder: MediaRecorder? = null
    private var audioPath: String? = null
    private var audioStartMs: Long = 0
    private var audioPid: Long = 0

    @JvmStatic
    fun audio_start_recording(pid: Long, optsJson: String) {
        audioPid = pid
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            try {
                val tmp = File(activity.cacheDir, "mob_audio_${System.currentTimeMillis()}.m4a")
                audioPath = tmp.absolutePath
                audioStartMs = SystemClock.elapsedRealtime()
                val rec = if (android.os.Build.VERSION.SDK_INT >= 31)
                    MediaRecorder(activity)
                else @Suppress("DEPRECATION") MediaRecorder()
                rec.setAudioSource(MediaRecorder.AudioSource.MIC)
                rec.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                rec.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                rec.setOutputFile(audioPath)
                rec.prepare()
                rec.start()
                audioRecorder = rec
            } catch (e: Exception) {
                nativeDeliverAtom3(pid, "audio", "error", "setup_failed")
            }
        }
    }

    @JvmStatic
    fun audio_stop_recording() {
        val rec = audioRecorder ?: return
        val pid = audioPid
        val path = audioPath ?: return
        val duration = (SystemClock.elapsedRealtime() - audioStartMs) / 1000.0
        audioRecorder = null
        try {
            rec.stop()
            rec.release()
            val json = """[{"path":"$path","duration":$duration}]"""
            nativeDeliverFileResult(pid, "audio", "recorded", json)
        } catch (e: Exception) {
            nativeDeliverAtom3(pid, "audio", "error", "stop_failed")
        }
    }

    // ── Audio input metering (mic level probe, no recording kept) ──────────
    // Pairs with Mob.Audio.start_input_metering/input_level/stop_input_metering
    // and the zig NIF (mob). MediaRecorder to a throwaway file with getMaxAmplitude
    // as the level; the NIF converts amplitude (0..32767, -1 = not metering) to dBFS.
    private var meterRecorder: MediaRecorder? = null
    private var meterPath: String? = null

    @JvmStatic
    fun audio_start_input_metering() {
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            try {
                val tmp = File(activity.cacheDir, "mob_meter_${System.currentTimeMillis()}.m4a")
                meterPath = tmp.absolutePath
                val rec = if (android.os.Build.VERSION.SDK_INT >= 31)
                    MediaRecorder(activity)
                else @Suppress("DEPRECATION") MediaRecorder()
                rec.setAudioSource(MediaRecorder.AudioSource.MIC)
                rec.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                rec.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                rec.setOutputFile(meterPath)
                rec.prepare()
                rec.start()
                meterRecorder = rec
            } catch (e: Exception) {
                meterRecorder = null
            }
        }
    }

    @JvmStatic
    fun audio_input_level(): Int {
        val rec = meterRecorder ?: return -1
        return try { rec.maxAmplitude } catch (e: Exception) { -1 }
    }

    @JvmStatic
    fun audio_stop_input_metering() {
        val rec = meterRecorder ?: return
        meterRecorder = null
        try {
            rec.stop()
            rec.release()
        } catch (e: Exception) {
        }
        meterPath?.let { runCatching { File(it).delete() } }
        meterPath = null
    }

    // ── Audio playback ─────────────────────────────────────────────────────
    private var audioPlayer: MediaPlayer? = null
    private var playbackPid: Long = 0
    private var playbackPath: String? = null

    @JvmStatic
    fun audio_play(pid: Long, path: String, optsJson: String) {
        playbackPid  = pid
        playbackPath = path
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            try {
                audioPlayer?.release()
                audioPlayer = null
                val opts = org.json.JSONObject(optsJson)
                val loop   = opts.optBoolean("loop", false)
                val volume = opts.optDouble("volume", 1.0).toFloat()
                val player = MediaPlayer()
                player.setDataSource(path)
                player.isLooping = loop
                player.setVolume(volume, volume)
                player.setOnCompletionListener {
                    val p = playbackPid
                    val pp = playbackPath ?: ""
                    audioPlayer = null
                    playbackPath = null
                    val json = """[{"path":"$pp"}]"""
                    nativeDeliverFileResult(p, "audio", "playback_finished", json)
                }
                player.setOnErrorListener { _, _, _ ->
                    val p = playbackPid
                    audioPlayer = null
                    playbackPath = null
                    nativeDeliverAtom3(p, "audio", "playback_error", "player_error")
                    true
                }
                player.prepare()
                player.start()
                audioPlayer = player
            } catch (e: Exception) {
                nativeDeliverAtom3(pid, "audio", "playback_error", "setup_failed")
            }
        }
    }

    // ── Scheduled audio playback (sample-accurate sync) ───────────────────
    //
    // Schedules `path` to start at absolute local wall-clock time `atWallMs`
    // (in `System.currentTimeMillis()` terms). Each scheduled note runs on
    // a dedicated audio-priority thread that sleeps until just before the
    // target moment, busy-waits the final ~3 ms for precise wakeup, then
    // writes the entire WAV to a freshly-built AudioTrack in STATIC mode
    // and calls play(). The audio hardware clock then fires the samples
    // at its sample rate.
    //
    // Per-device calibration: `AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER`
    // gives the device's native low-latency buffer hint; we subtract that
    // converted-to-ms from the target as our best estimate of end-to-end
    // output latency. Pro-audio capable devices report tiny values
    // (~2 ms); budget devices report larger (~20–40 ms).
    private val scheduledTracks = mutableListOf<AudioTrack>()
    private var cachedOutputLatencyMs: Long = -1L

    // WAV-header cache. Re-parsing the chunk walker each call costs
    // ~5–10 ms. Cache the format/offset record (small) — NOT the PCM
    // bytes, which can be tens of MB per stem. Streaming reads happen
    // from disk via RandomAccessFile inside the audio thread.
    private val wavCache = java.util.concurrent.ConcurrentHashMap<String, WavInfo>()

    // Pre-warm flag: at the first audio_play_at we play a brief silent
    // buffer so the audio HAL is hot before the first real note hits.
    // Without this the first note inherits cold-start latency.
    private var audioWarmedUp = false

    private fun warmUpAudio() {
        if (audioWarmedUp) return
        audioWarmedUp = true
        try {
            val minBuf = AudioTrack.getMinBufferSize(
                44100, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT,
            )
            val warm = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build(),
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(44100)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build(),
                )
                .setBufferSizeInBytes(minBuf)
                .setTransferMode(AudioTrack.MODE_STATIC)
                .build()
            val silence = ByteArray(minBuf)
            warm.write(silence, 0, silence.size)
            warm.setVolume(0f)
            warm.play()
            android.os.Handler(activityRef?.get()?.mainLooper ?: return).postDelayed({
                try { warm.stop(); warm.release() } catch (_: Exception) {}
            }, 200)
        } catch (_: Exception) {}
    }

    private fun outputLatencyMs(): Long {
        if (cachedOutputLatencyMs >= 0) return cachedOutputLatencyMs
        val activity = activityRef?.get() ?: return 0L
        val am = activity.getSystemService(Activity.AUDIO_SERVICE) as? AudioManager
        val frames = am?.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER)?.toIntOrNull() ?: 1024
        val rate = am?.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE)?.toIntOrNull() ?: 44100
        cachedOutputLatencyMs = (frames * 1000L) / rate
        Log.i("MobBridge", "audio output latency: ${cachedOutputLatencyMs}ms (frames=$frames rate=$rate)")
        return cachedOutputLatencyMs
    }

    // Minimal WAV chunk walker. Handles the canonical RIFF/WAVE format with
    // any number of intermediate chunks (LIST, INFO, etc.) between `fmt ` and
    // `data`. Returns the raw PCM data + sample rate + channel count, or null
    // if the file isn't a 16-bit PCM WAV.
    // WAV header info — the bare minimum needed to open an AudioTrack
    // and seek to the PCM data. We deliberately do NOT keep the PCM
    // bytes in memory; for multi-MB stems that'd be wasteful. Instead
    // we cache this little record and stream from disk at play time.
    private data class WavInfo(
        val sampleRate: Int,
        val channels: Int,
        val dataOffset: Long,
        val dataLength: Long,
    )

    private fun decodeWavHeader(path: String): WavInfo? {
        val file = java.io.File(path)
        if (!file.exists()) return null

        val raf = java.io.RandomAccessFile(file, "r")
        try {
            val riff = ByteArray(12)
            if (raf.read(riff) < 12) return null
            if (String(riff, 0, 4) != "RIFF") return null
            if (String(riff, 8, 4) != "WAVE") return null

            var sampleRate = 0
            var channels = 0
            var bitsPerSample = 0

            while (raf.filePointer < file.length() - 8) {
                val hdr = ByteArray(8)
                if (raf.read(hdr) < 8) return null
                val tag = String(hdr, 0, 4)
                val sz = ((hdr[4].toInt() and 0xff)) or
                    ((hdr[5].toInt() and 0xff) shl 8) or
                    ((hdr[6].toInt() and 0xff) shl 16) or
                    ((hdr[7].toInt() and 0xff) shl 24)

                when (tag) {
                    "fmt " -> {
                        val fmt = ByteArray(sz)
                        if (raf.read(fmt) < sz) return null
                        channels = (fmt[2].toInt() and 0xff) or
                            ((fmt[3].toInt() and 0xff) shl 8)
                        sampleRate = ((fmt[4].toInt() and 0xff)) or
                            ((fmt[5].toInt() and 0xff) shl 8) or
                            ((fmt[6].toInt() and 0xff) shl 16) or
                            ((fmt[7].toInt() and 0xff) shl 24)
                        bitsPerSample = (fmt[14].toInt() and 0xff) or
                            ((fmt[15].toInt() and 0xff) shl 8)
                    }
                    "data" -> {
                        if (bitsPerSample != 16 || channels !in 1..2) return null
                        return WavInfo(sampleRate, channels, raf.filePointer, sz.toLong())
                    }
                    else -> raf.seek(raf.filePointer + sz)
                }
            }
            return null
        } finally {
            raf.close()
        }
    }

    @JvmStatic
    fun audio_play_at(pid: Long, path: String, optsJson: String, atWallMsStr: String) {
        val atWallMs = atWallMsStr.toLongOrNull() ?: return

        // One background thread per scheduled note. The thread sleeps
        // until the target moment (minus the device's measured output
        // latency), then writes the entire audio buffer to a freshly
        // created AudioTrack. The audio hardware clock then fires the
        // samples at its sample rate, giving us sub-buffer-tick accuracy
        // from the moment the write completes.
        //
        // Why not stream silence ahead of time on the audio thread? Mid-
        // range Android devices struggle when many AudioTracks are
        // simultaneously feeding silence chunks — buffer-underrun
        // glitches result. This "sleep, then write the audio in one shot"
        // approach trades ~10–20 ms of scheduler jitter on each note's
        // start for clean playback. For multi-device sync within a single
        // device class (e.g. two Motos), they share the same jitter
        // distribution and still line up.
        warmUpAudio()

        Thread {
            android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO)
            var track: AudioTrack? = null
            var raf: java.io.RandomAccessFile? = null
            try {
                val opts = org.json.JSONObject(optsJson)
                val volume = opts.optDouble("volume", 1.0).toFloat()

                val info = wavCache.getOrPut(path) {
                    decodeWavHeader(path) ?: run {
                        Log.w("MobBridge", "audio_play_at: cannot decode $path")
                        return@Thread
                    }
                }

                // Coarse sleep + fine busy-wait. Thread.sleep accuracy is
                // ~5–10 ms even at audio priority — enough to be audible.
                // Sleep until ~3 ms before target, then spin to hit the
                // exact moment.
                val target = atWallMs - outputLatencyMs()
                val coarseSleep = target - System.currentTimeMillis() - 3L
                if (coarseSleep > 0) Thread.sleep(coarseSleep)
                while (System.currentTimeMillis() < target) {
                    // Busy-wait the final ~3 ms.
                }

                val channelMask = if (info.channels == 1) {
                    AudioFormat.CHANNEL_OUT_MONO
                } else {
                    AudioFormat.CHANNEL_OUT_STEREO
                }
                val minBuf = AudioTrack.getMinBufferSize(
                    info.sampleRate, channelMask, AudioFormat.ENCODING_PCM_16BIT,
                )
                // ~160 ms of headroom in the track buffer. STREAM mode
                // lets the feeder loop write() block naturally when the
                // buffer is full — no manual chunking math needed.
                val bufferSize = minBuf * 16

                track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build(),
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(info.sampleRate)
                            .setChannelMask(channelMask)
                            .build(),
                    )
                    .setBufferSizeInBytes(bufferSize)
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .build()

                track.setVolume(volume)
                track.play()
                synchronized(scheduledTracks) { scheduledTracks.add(track) }

                // Stream PCM from disk in 64 KB chunks. `write()` blocks
                // when the track's internal buffer is full, which is
                // exactly the backpressure we want — the audio hardware
                // drains at its sample rate, the feeder writes only as
                // fast as the device consumes.
                raf = java.io.RandomAccessFile(path, "r")
                raf.seek(info.dataOffset)
                val chunk = ByteArray(64 * 1024)
                var remaining = info.dataLength
                while (remaining > 0) {
                    val toRead = minOf(chunk.size.toLong(), remaining).toInt()
                    val read = raf.read(chunk, 0, toRead)
                    if (read <= 0) break
                    val written = track.write(chunk, 0, read)
                    if (written <= 0) break
                    remaining -= written
                }
            } catch (e: Exception) {
                Log.e("MobBridge", "audio_play_at failed: ${e.message}", e)
            } finally {
                try { raf?.close() } catch (_: Exception) {}
                if (track != null) {
                    try { track!!.stop(); track!!.release() } catch (_: Exception) {}
                    synchronized(scheduledTracks) { scheduledTracks.remove(track) }
                }
            }
        }.apply {
            isDaemon = true
            name = "MobAudioPlayAt"
            start()
        }
    }

    @JvmStatic
    fun audio_stop_playback() {
        // Stop the legacy MediaPlayer path (used by audio_play for short
        // tones) AND the scheduled AudioTrack path (used by audio_play_at
        // for full-song streams). Earlier this function bailed early
        // with `audioPlayer ?: return` when no MediaPlayer was active,
        // leaving scheduled tracks running.
        audioPlayer?.let { p ->
            audioPlayer = null
            playbackPath = null
            try { p.stop(); p.release() } catch (_: Exception) {}
        }
        synchronized(scheduledTracks) {
            for (t in scheduledTracks) {
                try { t.stop(); t.release() } catch (_: Exception) {}
            }
            scheduledTracks.clear()
        }
    }

    @JvmStatic
    fun audio_set_volume(volStr: String) {
        val vol = volStr.toFloatOrNull() ?: 1.0f
        audioPlayer?.setVolume(vol, vol)
        synchronized(scheduledTracks) {
            for (t in scheduledTracks) {
                try { t.setVolume(vol) } catch (_: Exception) {}
            }
        }
    }

    // ── Storage ───────────────────────────────────────────────────────────
    @JvmStatic
    fun storage_dir(type: String): String? {
        val ctx = activityRef?.get() ?: return null
        return when (type) {
            "temp"        -> ctx.cacheDir.absolutePath + "/mob_temp"
            "documents"   -> ctx.filesDir.absolutePath + "/documents"
            "cache"       -> ctx.cacheDir.absolutePath
            "app_support" -> ctx.filesDir.absolutePath
            "icloud"      -> null
            else          -> null
        }.also { path -> path?.let { java.io.File(it).mkdirs() } }
    }

    @JvmStatic
    fun storage_external_files_dir(type: String): String? {
        val ctx = activityRef?.get() ?: return null
        val envType = when (type) {
            "documents"  -> android.os.Environment.DIRECTORY_DOCUMENTS
            "pictures"   -> android.os.Environment.DIRECTORY_PICTURES
            "movies"     -> android.os.Environment.DIRECTORY_MOVIES
            "music"      -> android.os.Environment.DIRECTORY_MUSIC
            "downloads"  -> android.os.Environment.DIRECTORY_DOWNLOADS
            "dcim"       -> android.os.Environment.DIRECTORY_DCIM
            else         -> android.os.Environment.DIRECTORY_DOCUMENTS
        }
        return ctx.getExternalFilesDir(envType)?.absolutePath
    }

    @JvmStatic
    fun storage_save_to_media_store(pid: Long, path: String, type: String) {
        val ctx = activityRef?.get() ?: run {
            nativeDeliverAtom3(pid, "storage", "error", "no_context")
            return
        }
        val file = java.io.File(path)
        val ext  = file.extension.lowercase()
        val mimeType = when {
            type == "image" || ext in listOf("jpg","jpeg","png","gif","webp","heic") -> "image/*"
            type == "video" || ext in listOf("mp4","mov","m4v","avi","mkv")          -> "video/*"
            type == "audio" || ext in listOf("m4a","mp3","aac","wav","flac","ogg")   -> "audio/*"
            else -> "*/*"
        }
        val collection = when {
            mimeType.startsWith("image") -> android.provider.MediaStore.Images.Media.getContentUri(
                android.provider.MediaStore.VOLUME_EXTERNAL_PRIMARY)
            mimeType.startsWith("video") -> android.provider.MediaStore.Video.Media.getContentUri(
                android.provider.MediaStore.VOLUME_EXTERNAL_PRIMARY)
            mimeType.startsWith("audio") -> android.provider.MediaStore.Audio.Media.getContentUri(
                android.provider.MediaStore.VOLUME_EXTERNAL_PRIMARY)
            else -> android.provider.MediaStore.Files.getContentUri(
                android.provider.MediaStore.VOLUME_EXTERNAL_PRIMARY)
        }
        try {
            val values = android.content.ContentValues().apply {
                put(android.provider.MediaStore.MediaColumns.DISPLAY_NAME, file.name)
                put(android.provider.MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(android.provider.MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = ctx.contentResolver.insert(collection, values)
                ?: throw Exception("insert returned null")
            ctx.contentResolver.openOutputStream(uri)?.use { out ->
                file.inputStream().use { it.copyTo(out) }
            }
            values.clear()
            values.put(android.provider.MediaStore.MediaColumns.IS_PENDING, 0)
            ctx.contentResolver.update(uri, values, null, null)
            val json = org.json.JSONArray().apply {
                put(org.json.JSONObject().put("path", path))
            }.toString()
            nativeDeliverFileResult(pid, "storage", "saved_to_library", json)
        } catch (e: Exception) {
            nativeDeliverAtom3(pid, "storage", "error", "save_failed")
        }
    }

    // ── Camera preview ────────────────────────────────────────────────────
    internal var previewCameraProvider: ProcessCameraProvider? = null

    @JvmStatic
    fun camera_start_preview(pid: Long, optsJson: String) {
        try {
            val facing = JSONObject(optsJson).optString("facing", "back")
            _previewFacing.value = facing
        } catch (_: Exception) {}
    }

    @JvmStatic
    fun camera_stop_preview() {
        _previewFacing.value = null
        previewCameraProvider?.unbindAll()
        previewCameraProvider = null
    }

    private val _previewFacing = mutableStateOf<String?>(null)
    val previewFacing: State<String?> get() = _previewFacing

    // ── Alerts / action sheets / toasts ───────────────────────────────────

    @JvmStatic
    fun alert_show(title: String, message: String, buttonsJson: String) {
        val activity = activityRef?.get() ?: return
        val buttons = parseButtonsJson(buttonsJson)
        activity.runOnUiThread {
            val builder = android.app.AlertDialog.Builder(activity)
            if (title.isNotEmpty()) builder.setTitle(title)
            if (message.isNotEmpty()) builder.setMessage(message)
            val positives = buttons.filter { it["style"] != "cancel" }
            val cancels   = buttons.filter { it["style"] == "cancel" }
            positives.firstOrNull()?.let { btn ->
                val action = btn["action"] ?: "dismiss"
                builder.setPositiveButton(btn["label"]) { _, _ -> nativeDeliverAlertAction(action) }
            }
            positives.getOrNull(1)?.let { btn ->
                val action = btn["action"] ?: "dismiss"
                builder.setNeutralButton(btn["label"]) { _, _ -> nativeDeliverAlertAction(action) }
            }
            cancels.firstOrNull()?.let { btn ->
                val action = btn["action"] ?: "dismiss"
                builder.setNegativeButton(btn["label"]) { _, _ -> nativeDeliverAlertAction(action) }
            }
            builder.setOnCancelListener { nativeDeliverAlertAction("dismiss") }
            builder.show()
        }
    }

    @JvmStatic
    fun action_sheet_show(title: String, buttonsJson: String) {
        val activity = activityRef?.get() ?: return
        val buttons = parseButtonsJson(buttonsJson)
        val nonCancel = buttons.filter { it["style"] != "cancel" }
        val cancel    = buttons.firstOrNull { it["style"] == "cancel" }
        val labels    = nonCancel.map { it["label"] ?: "" }.toTypedArray()
        activity.runOnUiThread {
            val builder = android.app.AlertDialog.Builder(activity)
            if (title.isNotEmpty()) builder.setTitle(title)
            builder.setItems(labels) { _, which ->
                val action = nonCancel[which]["action"] ?: "dismiss"
                nativeDeliverAlertAction(action)
            }
            cancel?.let { btn ->
                val action = btn["action"] ?: "dismiss"
                builder.setNegativeButton(btn["label"]) { _, _ -> nativeDeliverAlertAction(action) }
            }
            builder.setOnCancelListener { nativeDeliverAlertAction("dismiss") }
            builder.show()
        }
    }

    @JvmStatic
    fun toast_show(message: String, duration: String) {
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            val dur = if (duration == "long") android.widget.Toast.LENGTH_LONG
                      else android.widget.Toast.LENGTH_SHORT
            android.widget.Toast.makeText(activity, message, dur).show()
        }
    }

    private fun parseButtonsJson(json: String): List<Map<String, String>> {
        return try {
            val arr = org.json.JSONArray(json)
            (0 until arr.length()).map { i ->
                val obj = arr.getJSONObject(i)
                mapOf("label"  to obj.optString("label"),
                      "style"  to obj.optString("style"),
                      "action" to obj.optString("action"))
            }
        } catch (e: Exception) { emptyList() }
    }

    // ── WebView ────────────────────────────────────────────────────────────
    @Volatile var webView: android.webkit.WebView? = null

    @JvmStatic
    fun webview_eval_js(code: String) {
        val wv = webView ?: return
        activityRef?.get()?.runOnUiThread { wv.evaluateJavascript(code, null) }
    }

    @JvmStatic
    fun webview_post_message(json: String) {
        val escaped = json.replace("\\", "\\\\").replace("'", "\\'")
        webview_eval_js("window.mob&&window.mob._dispatch('$escaped')")
    }

    @JvmStatic
    fun webview_can_go_back(): Boolean {
        val wv = webView ?: return false
        val latch = java.util.concurrent.CountDownLatch(1)
        var result = false
        activityRef?.get()?.runOnUiThread {
            result = wv.canGoBack()
            latch.countDown()
        } ?: latch.countDown()
        latch.await(1, java.util.concurrent.TimeUnit.SECONDS)
        return result
    }

    @JvmStatic
    fun webview_go_back() {
        val wv = webView ?: return
        activityRef?.get()?.runOnUiThread { wv.goBack() }
    }

    // ── Motion sensors ─────────────────────────────────────────────────────
    private var sensorManager: SensorManager? = null
    private var sensorListener: SensorEventListener? = null
    private var motionPid: Long = 0
    private var accelData = floatArrayOf(0f, 0f, 0f)
    private var gyroData  = floatArrayOf(0f, 0f, 0f)
    private var magData   = floatArrayOf(0f, 0f, 0f)
    private var headingDeg = -1.0   // <0 => unavailable; delivered as nil
    private var hasMag = false

    // `spec` is "<interval>" or "<interval>,magnetometer" — the sensor request is
    // encoded in the string by nif_motion_start (the JNI signature stays
    // (JLjava/lang/String;)V). We only register the magnetometer + rotation-vector
    // when the app asked for it, so a plain accel/gyro consumer never pays the
    // extra sensor cost nor gets a 5-key map it didn't request.
    @JvmStatic
    fun motion_start(pid: Long, spec: String) {
        motionPid = pid
        val parts = spec.split(",")
        val intervalMs = parts.getOrNull(0)?.toLongOrNull() ?: 100L
        val wantMag = parts.contains("magnetometer")
        val activity = activityRef?.get() ?: return
        val sm = activity.getSystemService(android.content.Context.SENSOR_SERVICE) as SensorManager
        sensorManager = sm
        // hasMag drives the map shape only when the caller wanted the compass:
        // requested + hardware => real mag/heading; requested + no hardware =>
        // NaN mag / heading -1 sentinels (the native layer maps them to nil) so
        // the mag/heading keys are always present when :magnetometer was asked for.
        hasMag = wantMag && sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) != null
        val rot = FloatArray(9)
        val orientation = FloatArray(3)
        val listener = object : SensorEventListener {
            var lastSendMs = 0L
            override fun onSensorChanged(event: SensorEvent) {
                when (event.sensor.type) {
                    Sensor.TYPE_ACCELEROMETER  -> accelData = event.values.copyOf()
                    Sensor.TYPE_GYROSCOPE      -> gyroData  = event.values.copyOf()
                    Sensor.TYPE_MAGNETIC_FIELD -> magData   = event.values.copyOf()
                    Sensor.TYPE_ROTATION_VECTOR -> {
                        SensorManager.getRotationMatrixFromVector(rot, event.values)
                        SensorManager.getOrientation(rot, orientation)
                        var az = Math.toDegrees(orientation[0].toDouble())
                        if (az < 0.0) az += 360.0
                        headingDeg = az
                    }
                }
                val now = System.currentTimeMillis()
                if (now - lastSendMs >= intervalMs) {
                    lastSendMs = now
                    if (wantMag) {
                        val nan = Double.NaN
                        nativeDeliverMotionMag(pid,
                            accelData[0].toDouble(), accelData[1].toDouble(), accelData[2].toDouble(),
                            gyroData[0].toDouble(),  gyroData[1].toDouble(),  gyroData[2].toDouble(),
                            if (hasMag) magData[0].toDouble() else nan,
                            if (hasMag) magData[1].toDouble() else nan,
                            if (hasMag) magData[2].toDouble() else nan,
                            if (hasMag) headingDeg else -1.0, now)
                    } else {
                        nativeDeliverMotion(pid,
                            accelData[0].toDouble(), accelData[1].toDouble(), accelData[2].toDouble(),
                            gyroData[0].toDouble(),  gyroData[1].toDouble(),  gyroData[2].toDouble(),
                            now)
                    }
                }
            }
            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
        }
        sensorListener = listener
        sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.let {
            sm.registerListener(listener, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        sm.getDefaultSensor(Sensor.TYPE_GYROSCOPE)?.let {
            sm.registerListener(listener, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        if (hasMag) {
            sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)?.let {
                sm.registerListener(listener, it, SensorManager.SENSOR_DELAY_NORMAL)
            }
            sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)?.let {
                sm.registerListener(listener, it, SensorManager.SENSOR_DELAY_NORMAL)
            }
        }
    }

    @JvmStatic
    fun motion_stop() {
        sensorListener?.let { sensorManager?.unregisterListener(it) }
        sensorListener = null
    }

    // scanner_scan / handleScanResult moved to the mob_scanner plugin
    // (io.mob.scanner.MobScannerBridge + MobScannerActivity).


    // notify_schedule / notify_cancel / notify_register_push moved to the
    // mob_notify plugin (io.mob.notify.MobNotifyBridge); shared delivery state
    // lives in the generated io.mob.plugin.MobNotifyHub. The channel id +
    // delivery thunks/receiver stay host-side (delivery is core/host-owned).
    private const val PERM_REQUEST_CODE = 9001

    @JvmStatic
    fun setLaunchNotification(json: String?) {
        nativeSetLaunchNotification(json)
    }

    /**
     * Called from nif_safe_area via JNI — returns [top, right, bottom, left] in dp.
     * Reads the window's system bar insets on the UI thread.
     */
    @JvmStatic
    fun getSafeArea(): FloatArray {
        val activity = activityRef?.get() ?: return FloatArray(4)
        val density = activity.resources.displayMetrics.density
        val result = FloatArray(4)
        val latch = java.util.concurrent.CountDownLatch(1)
        activity.runOnUiThread {
            val insets = activity.window.decorView.rootWindowInsets
            if (insets != null) {
                result[0] = insets.systemWindowInsetTop    / density
                result[1] = insets.systemWindowInsetRight  / density
                result[2] = insets.systemWindowInsetBottom / density
                result[3] = insets.systemWindowInsetLeft   / density
            }
            latch.countDown()
        }
        try { latch.await() } catch (e: InterruptedException) { Thread.currentThread().interrupt() }
        return result
    }

    /** Called from nif_haptic via JNI — fires haptic feedback on the UI thread. */
    @JvmStatic
    fun haptic(type: String) {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread {
                val view     = activity.window.decorView
                val constant = when (type) {
                    "light"   -> HapticFeedbackConstants.VIRTUAL_KEY
                    "medium"  -> HapticFeedbackConstants.CLOCK_TICK
                    "heavy"   -> HapticFeedbackConstants.LONG_PRESS
                    "success" -> if (Build.VERSION.SDK_INT >= 30) HapticFeedbackConstants.CONFIRM
                                 else HapticFeedbackConstants.CLOCK_TICK
                    "error"   -> if (Build.VERSION.SDK_INT >= 30) HapticFeedbackConstants.REJECT
                                 else HapticFeedbackConstants.LONG_PRESS
                    "warning" -> HapticFeedbackConstants.CLOCK_TICK
                    else      -> HapticFeedbackConstants.VIRTUAL_KEY
                }
                @Suppress("DEPRECATION")
                view.performHapticFeedback(constant, HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING)
            }
        }
    }

    /**
     * Called from nif_torch via JNI — toggles the rear-camera torch on ("on") or
     * off (any other value). Uses CameraManager.setTorchMode, so no capture
     * session and no CAMERA permission are needed. No-op on a device with no
     * flash unit, and swallows the transient failures (torch in use / camera
     * unavailable) rather than crashing the caller.
     */
    @JvmStatic
    fun torch(state: String) {
        val activity = activityRef?.get() ?: return
        val cm = activity.getSystemService(Context.CAMERA_SERVICE) as? CameraManager ?: return
        try {
            val camId = cm.cameraIdList.firstOrNull { id ->
                cm.getCameraCharacteristics(id).get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            } ?: return
            cm.setTorchMode(camId, state == "on")
        } catch (e: Exception) {
            Log.w("MobBridge", "torch($state) failed: ${e.message}")
        }
    }

    // ── Text-to-speech ──────────────────────────────────────────────────────
    // TextToSpeech initializes asynchronously; we keep one engine alive and
    // queue the first utterance until onInit fires.
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var ttsPending: Pair<String, String>? = null

    /** Called from nif_tts_speak via JNI — speaks text via TextToSpeech.
     *  optsJson may carry {"rate":Float,"pitch":Float,"voice":"en-US"} (all optional). */
    @JvmStatic
    fun ttsSpeak(text: String, optsJson: String) {
        val activity = activityRef?.get() ?: return
        activity.runOnUiThread {
            if (tts == null) {
                tts = TextToSpeech(activity.applicationContext) { status ->
                    ttsReady = status == TextToSpeech.SUCCESS
                    val pending = ttsPending
                    ttsPending = null
                    if (ttsReady && pending != null) speakNow(pending.first, pending.second)
                }
            }
            if (ttsReady) speakNow(text, optsJson) else ttsPending = text to optsJson
        }
    }

    private fun speakNow(text: String, optsJson: String) {
        val engine = tts ?: return
        try {
            val opts = org.json.JSONObject(optsJson)
            if (opts.has("rate")) engine.setSpeechRate(opts.getDouble("rate").toFloat())
            if (opts.has("pitch")) engine.setPitch(opts.getDouble("pitch").toFloat())
            if (opts.has("voice"))
                engine.setLanguage(java.util.Locale.forLanguageTag(opts.getString("voice")))
        } catch (_: Exception) {
        }
        engine.speak(text, TextToSpeech.QUEUE_ADD, null, "mob_tts_${System.currentTimeMillis()}")
    }

    /** Called from nif_tts_stop via JNI — stops any in-progress speech immediately. */
    @JvmStatic
    fun ttsStop() {
        tts?.stop()
    }

    /** Called from nif_clipboard_put via JNI — writes text to the system clipboard. */
    @JvmStatic
    fun clipboardPut(text: String) {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread {
                val cm = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                cm.setPrimaryClip(ClipData.newPlainText("mob", text))
            }
        }
    }

    /**
     * Called from nif_clipboard_get via JNI — returns clipboard text or null.
     * Blocks the calling thread until the UI thread has read the clipboard.
     */
    @JvmStatic
    fun clipboardGet(): String? {
        val activity = activityRef?.get() ?: return null
        val result   = arrayOfNulls<String>(1)
        val latch    = java.util.concurrent.CountDownLatch(1)
        activity.runOnUiThread {
            try {
                val cm = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                result[0] = cm.primaryClip?.getItemAt(0)?.coerceToText(activity)?.toString()
            } finally {
                latch.countDown()
            }
        }
        try { latch.await() } catch (e: InterruptedException) { Thread.currentThread().interrupt() }
        return result[0]
    }

    /** Called from nif_share_text via JNI — opens the system share sheet. */
    @JvmStatic
    fun shareText(text: String) {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread {
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                activity.startActivity(Intent.createChooser(intent, null))
            }
        }
    }

    /** Called from nif_open_url via JNI — hands a URL to the OS to open in the
     *  default browser/handler. Fire-and-forget; failures are silently ignored. */
    @JvmStatic
    fun openUrl(url: String) {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    android.util.Log.w("MobBridge", "openUrl failed for $url: ${e.message}")
                }
            }
        }
    }

    /** Called from nif_open_settings via JNI — opens an OS settings screen.
     *  target is "app" | "notifications" | "exact_alarm". Fire-and-forget;
     *  failures are silently ignored. */
    @JvmStatic
    fun openSettings(target: String) {
        activityRef?.get()?.let { activity ->
            activity.runOnUiThread {
                try {
                    val pkgUri = Uri.parse("package:" + activity.packageName)
                    val intent = when (target) {
                        "notifications" ->
                            Intent(android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(
                                    android.provider.Settings.EXTRA_APP_PACKAGE,
                                    activity.packageName,
                                )
                        "exact_alarm" ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                Intent(
                                    android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                                    pkgUri,
                                )
                            } else {
                                Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS, pkgUri)
                            }
                        else ->
                            Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS, pkgUri)
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    activity.startActivity(intent)
                } catch (e: Exception) {
                    android.util.Log.w("MobBridge", "openSettings failed for $target: ${e.message}")
                }
            }
        }
    }

    /** Called from nif_audio_output_status via JNI — reads system audio config
     *  so Mob.Audio.output_status/0 can answer "is sound configured to play".
     *  Returns float[4] = [volume0..1, muted(0/1), routeCode, otherAudio(0/1)].
     *  routeCode: 1=speaker 2=headphones 3=bluetooth 4=receiver 0=none. */
    @JvmStatic
    fun audioOutputStatus(): FloatArray {
        val activity = activityRef?.get() ?: return FloatArray(4)
        val am = activity.getSystemService(Activity.AUDIO_SERVICE) as? AudioManager
            ?: return FloatArray(4)
        val max = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC).toFloat()
        val cur = am.getStreamVolume(AudioManager.STREAM_MUSIC).toFloat()
        val volume = if (max > 0f) cur / max else 0f
        val muted =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                am.isStreamMute(AudioManager.STREAM_MUSIC)
            ) {
                1f
            } else {
                0f
            }
        val other = if (am.isMusicActive) 1f else 0f
        // Best-effort active route: Android routes media to BT/wired when one
        // is connected, so pick the highest-priority connected output.
        var route = 1f // builtin speaker
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            var hasBt = false
            var hasWired = false
            for (d in am.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
                when (d.type) {
                    android.media.AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
                    android.media.AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
                    -> hasBt = true
                    android.media.AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                    android.media.AudioDeviceInfo.TYPE_WIRED_HEADSET,
                    android.media.AudioDeviceInfo.TYPE_USB_HEADSET,
                    -> hasWired = true
                }
            }
            route = if (hasBt) 3f else if (hasWired) 2f else 1f
        }
        return floatArrayOf(volume, muted, route, other)
    }

    /** Called from nif_audio_output_level via JNI — reads the actual output
     *  signal level so Mob.Audio.output_level/1 can tell live audio from
     *  silence. Meters Mob.Audio's OWN player session (`source` == "mob") with a
     *  short-lived Visualizer; RECORD_AUDIO is sufficient for an own-session tap.
     *
     *  Returns: float[2] = [rms_db, peak_db] on success, else a length-1 error
     *  code the NIF maps to an atom — 1 unsupported_on_platform, 2
     *  needs_record_audio, 3 not_playing.
     *
     *  "mix" (the global output mix) is unsupported: attaching a Visualizer to
     *  session 0 is privileged on modern Android (ERROR_NO_INIT for a normal
     *  app), so global device-audio capture lives in a separate
     *  MediaProjection-based plugin, not here. */
    @JvmStatic
    fun audioOutputLevel(source: String): FloatArray {
        if (source != "mob") return floatArrayOf(1f) // unsupported_on_platform
        val sessionId = audioPlayer?.audioSessionId ?: return floatArrayOf(3f) // not_playing
        return try {
            val v = android.media.audiofx.Visualizer(sessionId)
            try {
                v.measurementMode = android.media.audiofx.Visualizer.MEASUREMENT_MODE_PEAK_RMS
                v.captureSize = android.media.audiofx.Visualizer.getCaptureSizeRange()[1]
                v.enabled = true
                // Let the measurement window collect a few audio frames before
                // reading; an immediate read returns the silence sentinel.
                Thread.sleep(60)
                val m = android.media.audiofx.Visualizer.MeasurementPeakRms()
                val rc = v.getMeasurementPeakRms(m)
                v.enabled = false
                if (rc != android.media.audiofx.Visualizer.SUCCESS) {
                    floatArrayOf(2f) // needs_record_audio (most common measure failure)
                } else {
                    // mPeak / mRms are in millibels (1/100 dB).
                    floatArrayOf(m.mRms / 100f, m.mPeak / 100f)
                }
            } finally {
                v.release()
            }
        } catch (e: Throwable) {
            // Usually a SecurityException: RECORD_AUDIO not granted at runtime.
            android.util.Log.w("MobBridge", "audioOutputLevel($source) failed: ${e.message}")
            floatArrayOf(2f) // needs_record_audio
        }
    }
    // ── Mob.Peripheral.VendorUsb ─────────────────────────────────────────────
    //
    // Android USB host. Talks to USB devices over bulk endpoints — surfaced to
    // Elixir via Mob.Peripheral.VendorUsb. iOS NIF returns :unsupported (iOS has
    // no public USB-host API).
    //
    // State lives in this object (singleton). Sessions are integer handles
    // returned from open(); reused only after process restart.

    private const val ACTION_USB_PERMISSION = "com.example.mishka_mob.USB_PERMISSION"

    private data class UsbSession(
        val pid: Long,
        val device: UsbDevice,
        val connection: UsbDeviceConnection,
        val iface: UsbInterface,
        val epIn: UsbEndpoint?,
        val epOut: UsbEndpoint?,
        val running: AtomicBoolean = AtomicBoolean(true),
        @Volatile var readThread: Thread? = null,
        @Volatile var readChunkBytes: Int = 4096
    )

    private val usbSessions = ConcurrentHashMap<Int, UsbSession>()
    private val usbNextSession = AtomicInteger(1)
    private val usbPendingPermission =
        ConcurrentHashMap<String, MutableList<Long>>()
    private var usbReceiverRegistered = false

    @JvmStatic
    fun vendor_usb_list_devices(pid: Long, filterJson: String) {
        try {
            val ctx = activityRef?.get() ?: return
            val mgr = ctx.getSystemService(Context.USB_SERVICE) as? UsbManager ?: return

            val filter = try { JSONObject(filterJson) } catch (e: Exception) { JSONObject() }
            val wantVid = if (filter.has("vendor_id") && !filter.isNull("vendor_id")) {
                val v = filter.optInt("vendor_id", -1); if (v >= 0) v else null
            } else null
            val wantPid = if (filter.has("product_id") && !filter.isNull("product_id")) {
                val v = filter.optInt("product_id", -1); if (v >= 0) v else null
            } else null

            val arr = JSONArray()
            for (dev in mgr.deviceList.values) {
                if (wantVid != null && dev.vendorId != wantVid) continue
                if (wantPid != null && dev.productId != wantPid) continue
                arr.put(usbDeviceJson(dev))
            }
            nativeDeliverVendorUsbDevices(pid, arr.toString())
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_list_devices failed: ${e.message}", e)
            nativeDeliverVendorUsbEvent(pid, -1, "error", "exception")
        }
    }

    @JvmStatic
    fun vendor_usb_request_permission(pid: Long, ref: String) {
        try {
            val ctx = activityRef?.get() ?: return
            val mgr = ctx.getSystemService(Context.USB_SERVICE) as? UsbManager ?: return
            val dev = mgr.deviceList[ref]
            if (dev == null) {
                // Device gone before we could prompt — emit a denied event so the
                // caller's state machine doesn't stall.
                nativeDeliverVendorUsbPermission(pid, false, """{"ref":"$ref"}""")
                return
            }

            if (mgr.hasPermission(dev)) {
                nativeDeliverVendorUsbPermission(pid, true, usbDeviceJson(dev).toString())
                return
            }

            usbPendingPermission.compute(ref) { _, existing ->
                (existing ?: mutableListOf()).also { it.add(pid) }
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
                PendingIntent.FLAG_MUTABLE else 0
            val intent = PendingIntent.getBroadcast(
                ctx, 0, Intent(ACTION_USB_PERMISSION).setPackage(ctx.packageName), flags
            )
            mgr.requestPermission(dev, intent)
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_request_permission failed: ${e.message}", e)
            nativeDeliverVendorUsbEvent(pid, -1, "error", "exception")
        }
    }

    @JvmStatic
    fun vendor_usb_open(pid: Long, optsJson: String) {
        try {
            val ctx = activityRef?.get() ?: return
            val mgr = ctx.getSystemService(Context.USB_SERVICE) as? UsbManager ?: return

            val opts = try { JSONObject(optsJson) } catch (e: Exception) {
                nativeDeliverVendorUsbEvent(pid, -1, "error", "bad_opts"); return
            }
            val ref = opts.optString("ref")
            val ifaceIdx = opts.optInt("interface", 0)
            val wantEpIn = if (opts.has("endpoint_in") && !opts.isNull("endpoint_in"))
                opts.getInt("endpoint_in") else null
            val wantEpOut = if (opts.has("endpoint_out") && !opts.isNull("endpoint_out"))
                opts.getInt("endpoint_out") else null

            val dev = mgr.deviceList[ref] ?: run {
                nativeDeliverVendorUsbEvent(pid, -1, "error", "device_gone"); return
            }
            if (!mgr.hasPermission(dev)) {
                nativeDeliverVendorUsbEvent(pid, -1, "error", "no_permission"); return
            }
            if (ifaceIdx < 0 || ifaceIdx >= dev.interfaceCount) {
                nativeDeliverVendorUsbEvent(pid, -1, "error", "bad_interface"); return
            }

            val conn = mgr.openDevice(dev) ?: run {
                nativeDeliverVendorUsbEvent(pid, -1, "error", "open_failed"); return
            }
            val iface = dev.getInterface(ifaceIdx)
            if (!conn.claimInterface(iface, true)) {
                conn.close()
                nativeDeliverVendorUsbEvent(pid, -1, "error", "interface_busy"); return
            }

            // Endpoint resolution: explicit user choice wins; otherwise pick the
            // first bulk IN/OUT we find on the interface.
            var epIn: UsbEndpoint? = null
            var epOut: UsbEndpoint? = null
            for (i in 0 until iface.endpointCount) {
                val ep = iface.getEndpoint(i)
                if (ep.type != UsbConstants.USB_ENDPOINT_XFER_BULK) continue
                if (ep.direction == UsbConstants.USB_DIR_IN) {
                    if (wantEpIn == null || wantEpIn == ep.address) epIn = epIn ?: ep
                } else {
                    if (wantEpOut == null || wantEpOut == ep.address) epOut = epOut ?: ep
                }
            }
            if (epIn == null && epOut == null) {
                conn.releaseInterface(iface); conn.close()
                nativeDeliverVendorUsbEvent(pid, -1, "error", "no_bulk_endpoints"); return
            }

            val sessionId = usbNextSession.getAndIncrement()
            val session = UsbSession(pid, dev, conn, iface, epIn, epOut)
            usbSessions[sessionId] = session
            nativeDeliverVendorUsbOpened(pid, sessionId, usbDeviceJson(dev).toString())
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_open failed: ${e.message}", e)
            nativeDeliverVendorUsbEvent(pid, -1, "error", "exception")
        }
    }

    @JvmStatic
    fun vendor_usb_bulk_write(pid: Long, sessionId: Int, bytes: ByteArray, timeoutMs: Int) {
        try {
            val s = usbSessions[sessionId] ?: run {
                nativeDeliverVendorUsbEvent(pid, sessionId, "error", "no_session"); return
            }
            val ep = s.epOut ?: run {
                nativeDeliverVendorUsbEvent(pid, sessionId, "error", "no_out_endpoint"); return
            }

            // Run write off the caller thread — bulkTransfer can block for up to
            // timeoutMs and we don't want to block whatever Kotlin queue the NIF
            // call landed on. The NIF is already marked DIRTY_JOB_IO_BOUND.
            Thread {
                val written = try {
                    s.connection.bulkTransfer(ep, bytes, bytes.size, timeoutMs)
                } catch (e: Exception) {
                    nativeDeliverVendorUsbEvent(pid, sessionId, "error", "write_failed"); return@Thread
                }
                if (written < 0) {
                    nativeDeliverVendorUsbEvent(pid, sessionId, "error", "write_timeout")
                } else {
                    nativeDeliverVendorUsbWriteComplete(pid, sessionId, written)
                }
            }.apply { name = "MobUsbWrite-$sessionId" }.start()
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_bulk_write failed: ${e.message}", e)
            nativeDeliverVendorUsbEvent(pid, -1, "error", "exception")
        }
    }

    @JvmStatic
    fun vendor_usb_start_reading(pid: Long, sessionId: Int, chunkBytes: Int) {
        try {
            val s = usbSessions[sessionId] ?: run {
                nativeDeliverVendorUsbEvent(pid, sessionId, "error", "no_session"); return
            }
            val ep = s.epIn ?: run {
                nativeDeliverVendorUsbEvent(pid, sessionId, "error", "no_in_endpoint"); return
            }
            if (s.readThread != null) return  // idempotent

            s.readChunkBytes = chunkBytes.coerceAtLeast(64)
            s.running.set(true)

            s.readThread = Thread {
                val maxPacket = ep.maxPacketSize
                val buf = ByteArray(maxOf(s.readChunkBytes, maxPacket))
                while (s.running.get()) {
                    val n = try {
                        s.connection.bulkTransfer(ep, buf, buf.size, 100)
                    } catch (e: Exception) {
                        if (s.running.get()) {
                            nativeDeliverVendorUsbEvent(pid, sessionId, "disconnected", "io_error")
                        }
                        break
                    }
                    if (n > 0) {
                        val out = if (n == buf.size) buf else buf.copyOf(n)
                        nativeDeliverVendorUsbData(pid, sessionId, out, n)
                    }
                    // n < 0 is a 100ms timeout — normal, just loop.
                }
            }.apply { name = "MobUsbRead-$sessionId"; isDaemon = true }
            s.readThread?.start()
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_start_reading failed: ${e.message}", e)
            nativeDeliverVendorUsbEvent(pid, -1, "error", "exception")
        }
    }

    @JvmStatic
    fun vendor_usb_stop_reading(sessionId: Int) {
        try {
            val s = usbSessions[sessionId] ?: return
            s.running.set(false)
            s.readThread?.interrupt()
            s.readThread = null
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_stop_reading failed: ${e.message}", e)
        }
    }

    @JvmStatic
    fun vendor_usb_close(sessionId: Int) {
        try {
            val s = usbSessions.remove(sessionId) ?: return
            val pid = s.pid
            s.running.set(false)
            try { s.readThread?.interrupt() } catch (_: Exception) {}
            try { s.connection.releaseInterface(s.iface) } catch (_: Exception) {}
            try { s.connection.close() } catch (_: Exception) {}
            nativeDeliverVendorUsbEvent(pid, sessionId, "closed", "ok")
        } catch (e: Exception) {
            android.util.Log.w("MobBridge", "vendor_usb_close failed: ${e.message}", e)
        }
    }

    // Helper: build the public `device` JSON shape used everywhere.
    private fun usbDeviceJson(dev: UsbDevice): JSONObject {
        return JSONObject().apply {
            put("vendor_id",    dev.vendorId)
            put("product_id",   dev.productId)
            put("manufacturer", dev.manufacturerName ?: JSONObject.NULL)
            put("product",      dev.productName      ?: JSONObject.NULL)
            put("serial",
                try { dev.serialNumber ?: JSONObject.NULL } catch (e: SecurityException) { JSONObject.NULL })
            put("ref",          dev.deviceName)
        }
    }

    // BroadcastReceiver for permission grants + hot-unplug. Registered once
    // from MobBridge.init via ensureUsbReceiver.
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            when (intent.action) {
                ACTION_USB_PERMISSION -> {
                    val dev: UsbDevice? = if (Build.VERSION.SDK_INT >= 33)
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                    else
                        @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    val ref = dev?.deviceName ?: return
                    val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                    val waiters = usbPendingPermission.remove(ref) ?: return
                    val json = usbDeviceJson(dev).toString()
                    for (pid in waiters) {
                        nativeDeliverVendorUsbPermission(pid, granted, json)
                    }
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val dev: UsbDevice? = if (Build.VERSION.SDK_INT >= 33)
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                    else
                        @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    val ref = dev?.deviceName ?: return
                    // Tear down any sessions on the now-departed device. Iterate
                    // a snapshot so close() can mutate the underlying map.
                    for ((sessionId, s) in usbSessions.toMap()) {
                        if (s.device.deviceName == ref) {
                            s.running.set(false)
                            try { s.readThread?.interrupt() } catch (_: Exception) {}
                            try { s.connection.releaseInterface(s.iface) } catch (_: Exception) {}
                            try { s.connection.close() } catch (_: Exception) {}
                            usbSessions.remove(sessionId)
                            nativeDeliverVendorUsbEvent(s.pid, sessionId, "disconnected", "detached")
                        }
                    }
                }
            }
        }
    }

    private fun ensureUsbReceiver(ctx: Context) {
        if (usbReceiverRegistered) return
        val filter = IntentFilter().apply {
            addAction(ACTION_USB_PERMISSION)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ctx.registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            ctx.registerReceiver(usbReceiver, filter)
        }
        usbReceiverRegistered = true
    }

    // Native callbacks — implemented in beam_jni.c → mob_deliver_vendor_usb_*.
    @JvmStatic external fun nativeDeliverVendorUsbDevices(pid: Long, json: String)
    @JvmStatic external fun nativeDeliverVendorUsbPermission(
        pid: Long, granted: Boolean, deviceJson: String)
    @JvmStatic external fun nativeDeliverVendorUsbOpened(
        pid: Long, sessionId: Int, deviceJson: String)
    @JvmStatic external fun nativeDeliverVendorUsbData(
        pid: Long, sessionId: Int, bytes: ByteArray, len: Int)
    @JvmStatic external fun nativeDeliverVendorUsbWriteComplete(
        pid: Long, sessionId: Int, bytesWritten: Int)
    @JvmStatic external fun nativeDeliverVendorUsbEvent(
        pid: Long, sessionId: Int, tag: String, reason: String)

}

// ── Composables ───────────────────────────────────────────────────────────────

// ── Native view component registry ───────────────────────────────────────────
// Register platform-native Composables by name at app startup. The name is the
// Elixir module with "Elixir." stripped and "." replaced with "_":
//   MyApp.ChartComponent → "MyApp_ChartComponent"
//
//   MobNativeViewRegistry.register("MyApp_ChartComponent") { props, send ->
//       ChartView(data = props["data"]) { index ->
//           send("tapped", mapOf("index" to index))
//       }
//   }

typealias MobNativeSend = (event: String, payload: Map<String, Any>) -> Unit
typealias MobNativeViewFactory = @Composable (props: Map<String, Any?>, send: MobNativeSend) -> Unit

object MobNativeViewRegistry {
    private val factories = mutableMapOf<String, MobNativeViewFactory>()

    fun register(name: String, factory: MobNativeViewFactory) {
        factories[name] = factory
    }

    @Composable
    fun render(node: MobNode) {
        val name = node.props["module"] as? String ?: return
        val factory = factories[name] ?: return
        val handle = (node.props["component_handle"] as? Number)?.toInt() ?: return
        val send: MobNativeSend = { event, payload ->
            try {
                val json = org.json.JSONObject(payload).toString()
                nativeDeliverComponentEvent(handle, event, json)
            } catch (_: Exception) {}
        }
        factory(node.props, send)
    }

    external fun nativeDeliverComponentEvent(handle: Int, event: String, payloadJson: String)
}

/** Renders a MobNode tree produced by Mob.Renderer. */
@Composable
fun RenderNode(node: MobNode, modifier: Modifier = Modifier) {
    val ox = floatProp(node.props, "offset_x") ?: 0f
    val oy = floatProp(node.props, "offset_y") ?: 0f
    if (ox != 0f || oy != 0f) {
        Box(modifier = Modifier.offset(x = ox.dp, y = oy.dp)) {
            RenderNodeInner(node, modifier)
        }
    } else {
        RenderNodeInner(node, modifier)
    }
}

@Composable
private fun RenderNodeInner(node: MobNode, modifier: Modifier) {
    // Apply on_tap as a clickable modifier for any node type except button —
    // button installs its own onClick via the Button composable. Mirrors iOS,
    // where most node types pick up onTapGesture via .ifLet(node.onTap).
    val tapHandle = intProp(node.props, "on_tap")
    val tapModifier = if (tapHandle != null && node.type != "button") {
        modifier.clickable { MobBridge.nativeSendTap(tapHandle) }
    } else modifier
    val base = tapModifier.then(nodeModifier(node.props))
    // Track on-screen frame + set a testTag for any node carrying an :id, so the
    // agent can read positions (Mob.Test.element_frames) without a screenshot.
    val trackId = node.props["id"] as? String
    val m = if (trackId != null) base.then(MobBridge.frameTrackingModifier(trackId)) else base
    when (node.type) {
        "column" -> Column(modifier = m) {
            node.children.forEach { child ->
                val w = floatProp(child.props, "weight")
                RenderNode(child, if (w != null) Modifier.weight(w) else Modifier)
            }
        }
        "row" -> Row(modifier = m, verticalAlignment = rowAlignProp(node.props)) {
            node.children.forEach { child ->
                val w = floatProp(child.props, "weight")
                RenderNode(child, if (w != null) Modifier.weight(w) else Modifier)
            }
        }
        // Box defaults to fillMaxWidth (matching iOS .frame(maxWidth: .infinity))
        // when no explicit width is set; otherwise it uses the explicit
        // width applied via nodeModifier above.
        // contentAlignment derives from the "align" prop ("center" /
        // "top_leading" / etc.) — defaults to TopStart for back-compat.
        "box" -> {
            val hasWidth = floatProp(node.props, "width") != null
            val boxModifier = if (hasWidth) m else m.fillMaxWidth()
            Box(modifier = boxModifier, contentAlignment = boxAlignProp(node.props)) {
                node.children.forEach { RenderNode(it) }
            }
        }
        "scroll" -> {
            val scrollState = rememberScrollState()
            val horizontal = node.props["axis"] == "horizontal"
            // Register by :id so Mob.Test.scroll_info/scroll_to can address it,
            // and record the measured viewport (ScrollState doesn't expose it).
            val id = node.props["id"] as? String
            val regMod: Modifier =
                if (id != null) {
                    val handle = MobBridge.scrollHandle(id)
                    handle.scrollState = scrollState
                    handle.horizontal = horizontal
                    Modifier.onGloballyPositioned {
                        handle.viewportPx = if (horizontal) it.size.width else it.size.height
                    }
                } else {
                    Modifier
                }
            if (horizontal) {
                Row(modifier = m.then(regMod).horizontalScroll(scrollState)) {
                    node.children.forEach { RenderNode(it) }
                }
            } else {
                Column(modifier = m.then(regMod).verticalScroll(scrollState).imePadding()) {
                    node.children.forEach { RenderNode(it) }
                }
            }
        }
        "text"       -> MobText(node, m)
        "button"     -> MobButton(node, m)
        "tab_bar"    -> MobTabBar(node, m)
        "text_field" -> MobTextField(node, m)
        "toggle"     -> MobToggle(node, m)
        "slider"     -> MobSlider(node, m)
        "divider"    -> MobDivider(node, m)
        "spacer"     -> MobSpacer(node, m)
        "progress"   -> MobProgress(node, m)
        "image"      -> MobImage(node, m)
        "icon"       -> MobIcon(node, m)
        "lazy_list"  -> MobLazyList(node, m)
        "video"          -> MobVideoPlayer(node, m)
        "camera_preview" -> MobCameraPreview(node, m)
        "web_view"       -> MobWebView(node, m)
        "native_view"    -> MobNativeViewRegistry.render(node)
        "canvas"         -> MobCanvas(node, m)
        "gpu_view"       -> MobGpuView(node, m)
    }
}

@Composable
private fun MobText(node: MobNode, modifier: Modifier) {
    val text          = node.props["text"] as? String ?: ""
    val color         = colorProp(node.props, "text_color")
    val fontSize      = sizeProp(node.props, "text_size")
    val fontWeight    = fontWeightProp(node.props)
    val fontStyle     = if (boolProp(node.props, "italic") == true) FontStyle.Italic else FontStyle.Normal
    val textAlign     = textAlignProp(node.props)
    val letterSpacing = floatProp(node.props, "letter_spacing")
    val lineHeightMul = floatProp(node.props, "line_height")
    val fontFamily    = fontFamilyProp(node.props, LocalContext.current)
    val tapHandle     = intProp(node.props, "on_tap")

    val resolvedLineHeight = if (lineHeightMul != null && fontSize != TextUnit.Unspecified)
        (lineHeightMul * fontSize.value).sp else TextUnit.Unspecified

    val tappableModifier = if (tapHandle != null)
        modifier.clickable { MobBridge.nativeSendTap(tapHandle) } else modifier

    // text_align is a no-op when the Text wraps to its content width — the
    // alignment only matters if the Text is wider than its content. Apply
    // fillMaxWidth in that case so center/right alignment behaves like iOS.
    val textModifier = if (textAlign != null && boolProp(node.props, "fill_width") != false &&
        floatProp(node.props, "width") == null) {
        tappableModifier.fillMaxWidth()
    } else tappableModifier

    Text(
        text          = text,
        modifier      = textModifier,
        color         = color,
        fontSize      = fontSize,
        fontWeight    = fontWeight,
        fontStyle     = fontStyle,
        textAlign     = textAlign,
        lineHeight    = resolvedLineHeight,
        letterSpacing = letterSpacing?.sp ?: TextUnit.Unspecified,
        fontFamily    = fontFamily,
    )
}

@Composable
private fun MobButton(node: MobNode, modifier: Modifier) {
    val label       = node.props["text"] as? String ?: ""
    val tapHandle   = intProp(node.props, "on_tap")
    val bgColor     = colorProp(node.props, "background")
    val cornerRad   = floatProp(node.props, "corner_radius") ?: 0f

    val fillWidth = boolProp(node.props, "fill_width") ?: false

    val colors = if (bgColor != Color.Unspecified)
        ButtonDefaults.buttonColors(containerColor = bgColor)
    else
        ButtonDefaults.buttonColors()

    // fill_width and corner_radius are driven by Elixir props (set in component
    // defaults but overridable per-node). Shape overrides M3's stadium default.
    Button(
        onClick  = { tapHandle?.let { MobBridge.nativeSendTap(it) } },
        modifier = if (fillWidth) modifier.fillMaxWidth() else modifier,
        colors   = colors,
        shape    = RoundedCornerShape(cornerRad.dp),
    ) {
        val textColor = colorProp(node.props, "text_color")
        val fontSize  = sizeProp(node.props, "text_size")
        Text(text = label, color = textColor, fontSize = fontSize,
             maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}

@Composable
private fun MobTextField(node: MobNode, modifier: Modifier) {
    val changeHandle  = intProp(node.props, "on_change")
    val focusHandle   = intProp(node.props, "on_focus")
    val blurHandle    = intProp(node.props, "on_blur")
    val submitHandle  = intProp(node.props, "on_submit")
    val placeholder   = node.props["placeholder"] as? String ?: ""
    val keyboardController = LocalSoftwareKeyboardController.current

    val isSecure = boolProp(node.props, "secure") ?: false
    // `secure: true` overrides any explicit `keyboard:` choice — Compose's
    // PasswordVisualTransformation pairs naturally with KeyboardType.Password
    // (autocorrect off, no suggestions strip). Apps wanting numeric PINs that
    // still mask the input should layer their own masking on a Number keyboard.
    val keyboardType = if (isSecure) {
        KeyboardType.Password
    } else when (node.props["keyboard"] as? String) {
        "number"  -> KeyboardType.Number
        "decimal" -> KeyboardType.Decimal
        "email"   -> KeyboardType.Email
        "phone"   -> KeyboardType.Phone
        "url"     -> KeyboardType.Uri
        else      -> KeyboardType.Text
    }
    val imeAction = when (node.props["return_key"] as? String) {
        "next"   -> ImeAction.Next
        "go"     -> ImeAction.Go
        "search" -> ImeAction.Search
        "send"   -> ImeAction.Send
        else     -> ImeAction.Done
    }

    var localValue by remember(node.props["value"]) {
        mutableStateOf(node.props["value"] as? String ?: "")
    }

    // Only fill width when explicitly asked. The unconditional fillMaxWidth
    // we used to apply broke layouts like ImperialInput's row of three
    // text_fields — the first field swallowed all the row's width and the
    // siblings got 0 px (silently invisible).
    val fillWidth = boolProp(node.props, "fill_width") ?: false
    val tfModifier = if (fillWidth) modifier.fillMaxWidth() else modifier

    TextField(
        value         = localValue,
        onValueChange = { new ->
            localValue = new
            changeHandle?.let { MobBridge.nativeSendChangeStr(it, new) }
        },
        placeholder   = { Text(placeholder) },
        modifier      = tfModifier
            .onFocusChanged { state ->
                if (state.isFocused) focusHandle?.let { MobBridge.nativeSendFocus(it) }
                else                 blurHandle?.let  { MobBridge.nativeSendBlur(it)  }
            },
        singleLine      = true,
        visualTransformation =
            if (isSecure) PasswordVisualTransformation() else VisualTransformation.None,
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType, imeAction = imeAction),
        keyboardActions = KeyboardActions(onAny = {
            submitHandle?.let { MobBridge.nativeSendSubmit(it) }
            // dismiss for terminal actions; Next intentionally keeps keyboard open
            if (imeAction != ImeAction.Next) keyboardController?.hide()
        }),
    )
}

@Composable
private fun MobToggle(node: MobNode, modifier: Modifier) {
    val handle  = intProp(node.props, "on_change")
    val checked = boolProp(node.props, "value") ?: false
    val color   = colorProp(node.props, "color")
    Row(modifier = modifier, verticalAlignment = Alignment.CenterVertically) {
        node.props["label"]?.let {
            Text(text = it as String, modifier = Modifier.weight(1f))
        }
        Switch(
            checked         = checked,
            onCheckedChange = { new -> handle?.let { MobBridge.nativeSendChangeBool(it, new) } },
            colors          = if (color != Color.Unspecified)
                SwitchDefaults.colors(checkedThumbColor = color)
            else
                SwitchDefaults.colors(),
        )
    }
}

@Composable
private fun MobSlider(node: MobNode, modifier: Modifier) {
    val handle   = intProp(node.props, "on_change")
    val minVal   = floatProp(node.props, "min") ?: 0f
    val maxVal   = floatProp(node.props, "max") ?: 1f
    val color    = colorProp(node.props, "color")
    var localVal by remember(node.props["value"]) {
        mutableStateOf(floatProp(node.props, "value") ?: minVal)
    }
    Slider(
        value         = localVal,
        onValueChange = { new ->
            localVal = new
            handle?.let { MobBridge.nativeSendChangeFloat(it, new) }
        },
        valueRange    = minVal..maxVal,
        modifier      = modifier.fillMaxWidth(),
        colors        = if (color != Color.Unspecified)
            SliderDefaults.colors(thumbColor = color, activeTrackColor = color)
        else
            SliderDefaults.colors(),
    )
}

@Composable
private fun MobDivider(node: MobNode, modifier: Modifier) {
    val thickness = floatProp(node.props, "thickness") ?: 1f
    val color     = colorProp(node.props, "color")
    HorizontalDivider(
        modifier  = modifier,
        thickness = thickness.dp,
        color     = if (color != Color.Unspecified) color else DividerDefaults.color,
    )
}

@Composable
private fun MobSpacer(node: MobNode, modifier: Modifier) {
    val size = floatProp(node.props, "size")
    // size() sets both width and height so Spacer works as a gap in both Column and Row.
    Spacer(modifier = if (size != null) modifier.size(size.dp) else modifier)
}

@Composable
private fun MobProgress(node: MobNode, modifier: Modifier) {
    val value = floatProp(node.props, "value")
    val color = colorProp(node.props, "color")
    val trackColor = if (color != Color.Unspecified) color else Color.Unspecified

    if (value != null) {
        LinearProgressIndicator(
            progress    = { value },
            modifier    = modifier.fillMaxWidth(),
            color       = if (trackColor != Color.Unspecified) trackColor else Color.Unspecified,
        )
    } else {
        LinearProgressIndicator(
            modifier = modifier.fillMaxWidth(),
            color    = if (trackColor != Color.Unspecified) trackColor else Color.Unspecified,
        )
    }
}

@Composable
private fun MobImage(node: MobNode, modifier: Modifier) {
    val src          = node.props["src"] as? String
    val contentScale = when (node.props["content_mode"] as? String) {
        "fill"    -> ContentScale.Crop
        "stretch" -> ContentScale.FillBounds
        else      -> ContentScale.Fit
    }
    val cornerRadius = floatProp(node.props, "corner_radius") ?: 0f
    val fixedWidth   = floatProp(node.props, "width")
    val fixedHeight  = floatProp(node.props, "height")

    // Coil's AsyncImage expects a URL string for remote images or a File object for
    // local paths. Passing a bare path string as a model causes it to treat it as a
    // relative URL and fail silently. Detect local paths and wrap in File.
    val model: Any? = when {
        src == null -> null
        src.startsWith("http://") || src.startsWith("https://") -> src
        else -> java.io.File(src)
    }

    var m = modifier
    if (fixedWidth  != null) m = m.width(fixedWidth.dp)
    if (fixedHeight != null) m = m.height(fixedHeight.dp)
    if (cornerRadius > 0f)   m = m.clip(RoundedCornerShape(cornerRadius.dp))

    AsyncImage(
        model              = model,
        contentDescription = null,
        contentScale       = contentScale,
        modifier           = m,
    )
}

@Composable
private fun MobIcon(node: MobNode, modifier: Modifier) {
    val name        = node.props["name"] as? String ?: "questionmark"
    val tint        = colorProp(node.props, "text_color")
    val fontSizeSp  = sizeProp(node.props, "text_size")
    val sizeDp      = if (fontSizeSp != androidx.compose.ui.unit.TextUnit.Unspecified)
        fontSizeSp.value.dp else 24.dp
    val description = node.props["text"] as? String

    val onTap   = (node.props["on_tap"] as? Number)?.toInt()
    val baseMod = if (onTap != null) modifier.clickable { MobBridge.nativeSendTap(onTap) } else modifier

    Icon(
        imageVector       = materialIconFor(name),
        contentDescription = description,
        tint              = if (tint == Color.Unspecified) Color.Unspecified else tint,
        modifier          = baseMod.size(sizeDp),
    )
}

// Logical icon name → Material icon. Names mirror MobRootView.swift's
// sfSymbolName/1 so the same `name:` prop renders an Apple-styled icon on iOS
// and a Material-styled icon on Android. Unknown names fall back to a "?".
private fun materialIconFor(logical: String): androidx.compose.ui.graphics.vector.ImageVector =
    when (logical) {
        "settings"        -> Icons.Filled.Settings
        "back"            -> Icons.Filled.ArrowBack
        "forward"         -> Icons.Filled.ArrowForward
        "close"           -> Icons.Filled.Close
        "add"             -> Icons.Filled.Add
        "remove"          -> Icons.Filled.Remove
        "edit"            -> Icons.Filled.Edit
        "check"           -> Icons.Filled.Check
        "chevron_right"   -> Icons.Filled.ChevronRight
        "chevron_left"    -> Icons.Filled.ChevronLeft
        "chevron_up"      -> Icons.Filled.KeyboardArrowUp
        "chevron_down"    -> Icons.Filled.ExpandMore
        "info"            -> Icons.Filled.Info
        "warning"         -> Icons.Filled.Warning
        "error"           -> Icons.Filled.Error
        "search"          -> Icons.Filled.Search
        "trash"           -> Icons.Filled.Delete
        "share"           -> Icons.Filled.Share
        "more"            -> Icons.Filled.MoreVert
        "menu"            -> Icons.Filled.Menu
        "refresh"         -> Icons.Filled.Refresh
        "favorite"        -> Icons.Filled.FavoriteBorder
        "favorite_filled" -> Icons.Filled.Favorite
        "star"            -> Icons.Filled.StarBorder
        "star_filled"     -> Icons.Filled.Star
        "user"            -> Icons.Filled.Person
        "home"            -> Icons.Filled.Home
        "expand_more"     -> Icons.Filled.ExpandMore
        "expand_less"     -> Icons.Filled.ExpandLess
        else              -> Icons.Filled.QuestionMark
    }

@Composable
private fun MobCameraPreview(node: MobNode, modifier: Modifier) {
    val facingStr  = (node.props["facing"] as? String) ?: "back"
    val cameraSelector = if (facingStr == "front")
        CameraSelector.DEFAULT_FRONT_CAMERA
    else
        CameraSelector.DEFAULT_BACK_CAMERA
    val context        = LocalContext.current
    val lifecycleOwner = context as LifecycleOwner

    // PreviewView is held in remember so the LaunchedEffect can rebind to
    // the same surface provider across recompositions. COMPATIBLE mode
    // uses TextureView so the preview renders inside the normal Compose
    // Z-order — PERFORMANCE (default) uses SurfaceView which punches
    // through above Compose and hides any overlay drawn on top of the
    // camera (e.g. bounding boxes, status text). FILL_CENTER center-crops
    // the camera image to fill the view.
    val previewView = remember(context) {
        PreviewView(context).apply {
            scaleType = PreviewView.ScaleType.FILL_CENTER
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        }
    }

    // Bind in a LaunchedEffect keyed only on cameraSelector — NOT in
    // AndroidView's update block. The update block re-runs on every
    // recomposition, so wiring the bind there caused continual
    // unbindAll/bind cycles whenever any sibling state ticked (e.g. an
    // FPS counter), making the TextureView surface flicker and fight
    // with overlays.
    LaunchedEffect(cameraSelector) {
        val providerFuture = ProcessCameraProvider.getInstance(context)
        providerFuture.addListener({
            val provider = providerFuture.get()
            MobBridge.previewCameraProvider = provider
            val preview = CameraPreview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            val useCases = mutableListOf<UseCase>(preview)
            try {
                provider.unbindAll()
                provider.bindToLifecycle(lifecycleOwner, cameraSelector, *useCases.toTypedArray())
            } catch (e: Exception) {
                Log.e("MobCamera", "bindToLifecycle failed: ${e.message}")
            }
        }, context.mainExecutor)
    }

    // clipToBounds keeps the TextureView's surface texture from bleeding
    // past the AndroidView's declared layout bounds; without it, sibling
    // Compose nodes adjacent to the preview can be overdrawn by the
    // camera surface.
    AndroidView(modifier = modifier.clipToBounds(), factory = { previewView })
}

private val MOB_JS_SHIM = """
(function(){
  if(window.mob)return;
  var _h=[];
  window.mob={
    send:function(d){MobNative.postMessage(JSON.stringify(d));},
    onMessage:function(h){_h.push(h);return function(){_h=_h.filter(function(x){return x!==h;});};},
    _dispatch:function(j){try{var d=JSON.parse(j);_h.forEach(function(h){h(d);});}catch(e){}}
  };
})();
""".trimIndent()

@Composable
private fun MobWebView(node: MobNode, modifier: Modifier) {
    val url       = node.props["url"] as? String ?: return
    val allowStr  = node.props["allow"] as? String ?: ""
    val allowList = allowStr.split(",").filter { it.isNotEmpty() }
    val title     = node.props["title"] as? String

    // File-chooser plumbing for HTML <input type="file"> inside the WebView
    // (e.g. Livebook's Upload import, attachments). Without a WebChromeClient
    // that handles onShowFileChooser, tapping a file input does nothing.
    val filePathCallback =
        remember { mutableStateOf<android.webkit.ValueCallback<Array<android.net.Uri>>?>(null) }
    val fileChooserLauncher =
        androidx.activity.compose.rememberLauncherForActivityResult(
            androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult()
        ) { result ->
            val uris =
                android.webkit.WebChromeClient.FileChooserParams.parseResult(
                    result.resultCode,
                    result.data,
                )
            filePathCallback.value?.onReceiveValue(uris)
            filePathCallback.value = null
        }

    Column(modifier = modifier) {
        if (title != null) {
            Text(text = title, fontSize = 12.sp,
                 modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp))
        }
        AndroidView(
            modifier = Modifier.weight(1f),
            factory  = { ctx ->
                android.webkit.WebView(ctx).apply {
                    // Fill the AndroidView's allocated bounds. Without explicit
                    // MATCH_PARENT layout params the WebView defaults to
                    // wrap_content, so a full-viewport web app (CSS 100vh/100%,
                    // e.g. an xterm.js terminal) measures its container as 0px
                    // and collapses to nothing. useWideViewPort +
                    // loadWithOverviewMode make the WebView honour the page's
                    // viewport meta so vh units resolve correctly.
                    layoutParams = android.view.ViewGroup.LayoutParams(
                        android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                        android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                    )
                    settings.javaScriptEnabled = true
                    settings.domStorageEnabled = true
                    settings.useWideViewPort = true
                    settings.loadWithOverviewMode = true
                    addJavascriptInterface(object : Any() {
                        @android.webkit.JavascriptInterface
                        fun postMessage(json: String) {
                            MobBridge.nativeDeliverWebViewMessage(0L, json)
                        }
                    }, "MobNative")
                    webViewClient = object : android.webkit.WebViewClient() {
                        override fun onPageFinished(view: android.webkit.WebView, pageUrl: String) {
                            view.evaluateJavascript(MOB_JS_SHIM, null)
                        }
                        override fun shouldOverrideUrlLoading(
                            view: android.webkit.WebView,
                            request: android.webkit.WebResourceRequest
                        ): Boolean {
                            if (allowList.isEmpty()) return false
                            val reqUrl = request.url.toString()
                            if (allowList.any { reqUrl.startsWith(it) }) return false
                            MobBridge.nativeDeliverWebViewBlocked(0L, reqUrl)
                            return true
                        }
                    }
                    webChromeClient = object : android.webkit.WebChromeClient() {
                        override fun onShowFileChooser(
                            webView: android.webkit.WebView?,
                            callback: android.webkit.ValueCallback<Array<android.net.Uri>>?,
                            params: android.webkit.WebChromeClient.FileChooserParams?,
                        ): Boolean {
                            // Cancel any in-flight chooser, then launch the picker the
                            // page asked for (params carries its accept/multiple flags).
                            filePathCallback.value?.onReceiveValue(null)
                            filePathCallback.value = callback
                            val intent = params?.createIntent()
                            return if (intent != null) {
                                try {
                                    fileChooserLauncher.launch(intent)
                                    true
                                } catch (e: Exception) {
                                    filePathCallback.value = null
                                    false
                                }
                            } else {
                                filePathCallback.value = null
                                false
                            }
                        }
                    }
                    MobBridge.webView = this
                    loadUrl(url)
                }
            },
            update = { wv -> MobBridge.webView = wv }
        )
    }
}

// ── Canvas (Mob.Canvas declarative draw spec) ───────────────────────────────
// Renders the node.props["draw"] list via Compose Canvas. Each op is a
// Map<String, Any?> with an "op" key plus op-specific fields, pre-resolved
// by the Elixir renderer (color tokens already converted to ARGB integers).
@Composable
private fun MobCanvas(node: MobNode, modifier: Modifier) {
    val width = floatProp(node.props, "width") ?: 0f
    val height = floatProp(node.props, "height") ?: 0f
    @Suppress("UNCHECKED_CAST")
    val ops: List<Map<String, Any?>> = when (val raw = node.props["draw"]) {
        is JSONArray -> (0 until raw.length()).map { i -> jsonObjectToMap(raw.getJSONObject(i)) }
        is List<*>   -> raw as List<Map<String, Any?>>
        else         -> emptyList()
    }

    val sized = if (width > 0f && height > 0f) {
        modifier.size(width.dp, height.dp)
    } else {
        modifier
    }

    Canvas(modifier = sized) {
        ops.forEach { op -> drawCanvasOp(op) }
    }
}

private fun DrawScope.drawCanvasOp(op: Map<String, Any?>) {
    val opName = op["op"] as? String ?: return
    val color = canvasColor(op["color"])
    val opacity = (op["opacity"] as? Double)?.toFloat() ?: 1f
    val isFill = (op["fill"] as? Boolean) ?: false
    val stroke = canvasStroke(op)

    when (opName) {
        "line" -> drawLine(
            color = color,
            start = Offset(canvasFloat(op["x1"]), canvasFloat(op["y1"])),
            end = Offset(canvasFloat(op["x2"]), canvasFloat(op["y2"])),
            strokeWidth = stroke.width,
            cap = stroke.cap,
            pathEffect = stroke.pathEffect,
            alpha = opacity
        )

        "circle" -> {
            val center = Offset(canvasFloat(op["x"]), canvasFloat(op["y"]))
            val radius = canvasFloat(op["r"])
            if (isFill) {
                drawCircle(color = color, radius = radius, center = center, alpha = opacity)
            } else {
                drawCircle(color = color, radius = radius, center = center, alpha = opacity, style = stroke)
            }
        }

        "ellipse" -> {
            val cx = canvasFloat(op["x"])
            val cy = canvasFloat(op["y"])
            val rx = canvasFloat(op["rx"])
            val ry = canvasFloat(op["ry"])
            val topLeft = Offset(cx - rx, cy - ry)
            val size = ComposeSize(rx * 2, ry * 2)
            if (isFill) {
                drawOval(color = color, topLeft = topLeft, size = size, alpha = opacity)
            } else {
                drawOval(color = color, topLeft = topLeft, size = size, alpha = opacity, style = stroke)
            }
        }

        "arc" -> {
            // Mob.Canvas arc: degrees, 0° to the right, sweeping clockwise.
            // Compose drawArc takes startAngle + sweepAngle in degrees, same convention.
            val cx = canvasFloat(op["x"])
            val cy = canvasFloat(op["y"])
            val r = canvasFloat(op["r"])
            val startDeg = canvasFloat(op["start_deg"])
            val endDeg = canvasFloat(op["end_deg"])
            val sweep = endDeg - startDeg
            drawArc(
                color = color,
                startAngle = startDeg,
                sweepAngle = sweep,
                useCenter = false,
                topLeft = Offset(cx - r, cy - r),
                size = ComposeSize(r * 2, r * 2),
                alpha = opacity,
                style = stroke
            )
        }

        "rect" -> {
            val topLeft = Offset(canvasFloat(op["x"]), canvasFloat(op["y"]))
            val size = ComposeSize(canvasFloat(op["w"]), canvasFloat(op["h"]))
            val radius = canvasFloat(op["radius"])
            if (radius > 0f) {
                val cornerRadius = androidx.compose.ui.geometry.CornerRadius(radius, radius)
                if (isFill) {
                    drawRoundRect(color = color, topLeft = topLeft, size = size,
                        cornerRadius = cornerRadius, alpha = opacity)
                } else {
                    drawRoundRect(color = color, topLeft = topLeft, size = size,
                        cornerRadius = cornerRadius, alpha = opacity, style = stroke)
                }
            } else {
                if (isFill) {
                    drawRect(color = color, topLeft = topLeft, size = size, alpha = opacity)
                } else {
                    drawRect(color = color, topLeft = topLeft, size = size, alpha = opacity, style = stroke)
                }
            }
        }

        "path" -> {
            @Suppress("UNCHECKED_CAST")
            val pts = op["points"] as? List<List<Any?>> ?: return
            if (pts.isEmpty()) return
            val closed = (op["closed"] as? Boolean) ?: false
            val path = Path().apply {
                moveTo(canvasFloat(pts[0].getOrNull(0)), canvasFloat(pts[0].getOrNull(1)))
                for (i in 1 until pts.size) {
                    lineTo(canvasFloat(pts[i].getOrNull(0)), canvasFloat(pts[i].getOrNull(1)))
                }
                if (closed || isFill) close()
            }
            if (isFill) {
                drawPath(path = path, color = color, alpha = opacity)
            } else {
                drawPath(path = path, color = color, alpha = opacity, style = stroke)
            }
        }

        "text" -> {
            val str = op["text"] as? String ?: return
            val size = canvasFloat(op["size"])
            val anchor = op["anchor"] as? String ?: "start"
            val weight = op["weight"] as? String
            // Compose has no DrawScope text primitive prior to TextMeasurer; the
            // simplest cross-version path is the platform Canvas via drawIntoCanvas.
            // Anchor is handled by measuring with Paint and offsetting x.
            drawIntoCanvas { canvas ->
                val paint = Paint().apply {
                    isAntiAlias = true
                    textSize = size
                    this.color = color.toArgb()
                    alpha = (opacity * 255).toInt().coerceIn(0, 255)
                    typeface = canvasTypeface(weight)
                }
                val measured = paint.measureText(str)
                val x = canvasFloat(op["x"])
                val y = canvasFloat(op["y"])
                val drawX = when (anchor) {
                    "center" -> x - measured / 2f
                    "end"    -> x - measured
                    else     -> x
                }
                // Compose Canvas positions text by baseline; offset by font ascent
                // so y is the top edge (matches SwiftUI Canvas convention).
                val baseline = y - paint.fontMetrics.ascent
                canvas.nativeCanvas.drawText(str, drawX, baseline, paint)
            }
        }

        "image" -> {
            // Image asset rendering deferred — needs context-aware loading from the
            // app's drawable resources or asset catalog. Tracked separately.
        }
    }
}

// Canvas coordinates from BEAM are in dp (matching the canvas's declared
// width/height). Compose's DrawScope works in pixels, so convert dp→px here.
private fun DrawScope.canvasFloat(v: Any?): Float {
    val dp = when (v) {
        is Float  -> v
        is Double -> v.toFloat()
        is Int    -> v.toFloat()
        is Long   -> v.toFloat()
        else      -> 0f
    }
    return dp.dp.toPx()
}

private fun canvasColor(v: Any?): Color = when (v) {
    is Long   -> Color(v.toInt())
    is Int    -> Color(v)
    is Double -> Color(v.toLong().toInt())
    is String -> {
        // Hex string fallback ("#rrggbb"). Pre-resolved ARGB integers are the
        // hot path; this is for raw color strings that bypass theme resolution.
        if (v.startsWith("#") && v.length == 7) {
            val rgb = v.substring(1).toLong(16)
            val r = ((rgb shr 16) and 0xFF).toInt()
            val g = ((rgb shr 8) and 0xFF).toInt()
            val b = (rgb and 0xFF).toInt()
            Color(red = r, green = g, blue = b)
        } else Color.Black
    }
    else      -> Color.Black
}

private fun DrawScope.canvasStroke(op: Map<String, Any?>): Stroke {
    val width = canvasFloat(op["width"]).let { if (it > 0f) it else 1f }
    val cap = when (op["cap"] as? String) {
        "round"  -> StrokeCap.Round
        "square" -> StrokeCap.Square
        else     -> StrokeCap.Butt
    }
    val join = when (op["join"] as? String) {
        "round" -> StrokeJoin.Round
        "bevel" -> StrokeJoin.Bevel
        else    -> StrokeJoin.Miter
    }
    @Suppress("UNCHECKED_CAST")
    val dashList = (op["dash"] as? List<Any?>)?.map { canvasFloat(it) }?.toFloatArray()
    val pathEffect = if (dashList != null && dashList.isNotEmpty()) {
        PathEffect.dashPathEffect(dashList, 0f)
    } else null
    return Stroke(width = width, cap = cap, join = join, pathEffect = pathEffect)
}

private fun canvasTypeface(weight: String?): Typeface = when (weight) {
    "bold", "semibold", "medium" -> Typeface.DEFAULT_BOLD
    else -> Typeface.DEFAULT
}

// ── GpuView ──────────────────────────────────────────────────────────────
//
// Fragment-shader-driven GPU surface backed by GLSurfaceView + GLES 3.0.
// Mirrors the iOS Mob.GpuView (MTKView + Metal) — same component API on
// the BEAM side; the shader source is GLSL ES 3.0 instead of MSL.
//
// The host owns the vertex shader (a passthrough that emits a full-screen
// quad with a varying v_uv in (0..1)). The user supplies a fragment
// shader that declares:
//
//   #version 300 es
//   precision highp float;
//   in vec2 v_uv;
//   out vec4 frag_color;
//   layout(std140) uniform Uniforms { ... };
//
// Uniforms arrive as a positional list packed by BEAM in the order the
// user wrote them. We std140-pack into a UBO at GL_BIND_BUFFER_BASE
// index 0, which the shader reads as a Uniforms block.

@Composable
private fun MobGpuView(node: MobNode, modifier: Modifier) {
    val width = floatProp(node.props, "width") ?: 0f
    val height = floatProp(node.props, "height") ?: 0f

    val shaderSrc: String = when (val raw = node.props["shader"]) {
        is String -> raw
        is JSONObject -> raw.optString("android", "")
        is Map<*, *> -> (raw["android"] as? String) ?: ""
        else -> ""
    }

    val uniformBytes: ByteArray = packGpuUniforms(node.props["uniforms"])

    val sized = if (width > 0f && height > 0f) {
        modifier.size(width.dp, height.dp)
    } else {
        modifier
    }

    // Surface the GL renderer's compile-error state to Compose so we can
    // overlay it on the failed view (parity with iOS MobGpuView). The
    // renderer runs on the GLSurfaceView's GL thread; the callback bounces
    // back to the main thread via mutableStateOf to keep Compose happy.
    val compileError = remember { mutableStateOf<String?>(null) }

    Box(modifier = sized) {
        AndroidView(
            factory = { ctx ->
                MobGpuSurfaceView(ctx) { err ->
                    ctx.mainExecutor.execute { compileError.value = err }
                }.also { v ->
                    v.applyShader(shaderSrc)
                    v.applyUniforms(uniformBytes)
                }
            },
            update = { view ->
                view.applyShader(shaderSrc)
                view.applyUniforms(uniformBytes)
            }
        )
        compileError.value?.let { err ->
            // Translucent red overlay matches the iOS MobGpuView contract:
            // a broken shader stays visible (not invisible) and the error
            // text is right on top of the offending view.
            Text(
                text = err,
                modifier = Modifier
                    .fillMaxSize()
                    .background(androidx.compose.ui.graphics.Color(0xC0FF0000))
                    .padding(8.dp),
                color = androidx.compose.ui.graphics.Color.White,
                fontSize = 12.sp
            )
        }
    }
}

private fun packGpuUniforms(raw: Any?): ByteArray {
    val list: List<Any?> = when (raw) {
        is JSONArray -> (0 until raw.length()).map { raw.get(it) }
        is List<*> -> raw
        else -> return ByteArray(0)
    }

    // std140-ish packing — matches the iOS-side Swift packer:
    //   number (Double/Long/Int) -> 4 bytes at 4-byte align
    //   JSONArray/List of 2      -> 8 bytes (float2) at 8-byte align
    //   JSONArray/List of 4      -> 16 bytes (float4) at 16-byte align
    //   float3 not supported in v1.
    //
    // The shader-side std140 Uniforms block reads members in the same
    // order. User is responsible for declaring matching positions.
    val sink = java.io.ByteArrayOutputStream()

    fun alignTo(n: Int) {
        val pad = (n - sink.size() % n) % n
        repeat(pad) { sink.write(0) }
    }

    fun writeF32(f: Float) {
        val bb = ByteBuffer.allocate(4).order(ByteOrder.nativeOrder())
        bb.putFloat(f)
        sink.write(bb.array())
    }

    fun writeI32(i: Int) {
        val bb = ByteBuffer.allocate(4).order(ByteOrder.nativeOrder())
        bb.putInt(i)
        sink.write(bb.array())
    }

    for (v in list) {
        when (v) {
            is Long -> {
                alignTo(4)
                writeI32(v.toInt())
            }
            is Int -> {
                alignTo(4)
                writeI32(v)
            }
            is Number -> {
                alignTo(4)
                writeF32(v.toFloat())
            }
            is JSONArray -> {
                val n = v.length()
                if (n == 2) {
                    alignTo(8)
                    writeF32(v.getDouble(0).toFloat())
                    writeF32(v.getDouble(1).toFloat())
                } else if (n == 4) {
                    alignTo(16)
                    for (i in 0 until 4) writeF32(v.getDouble(i).toFloat())
                }
            }
            is List<*> -> {
                val n = v.size
                if (n == 2) {
                    alignTo(8)
                    for (i in 0 until 2) writeF32((v[i] as Number).toFloat())
                } else if (n == 4) {
                    alignTo(16)
                    for (i in 0 until 4) writeF32((v[i] as Number).toFloat())
                }
            }
        }
    }
    return sink.toByteArray()
}

private class MobGpuSurfaceView(
    context: android.content.Context,
    onCompileError: (String?) -> Unit = {}
) : GLSurfaceView(context) {
    private val renderer = MobGpuRenderer(onCompileError)

    init {
        setEGLContextClientVersion(3)
        setRenderer(renderer)
        renderMode = RENDERMODE_CONTINUOUSLY
    }

    fun applyShader(source: String) {
        queueEvent { renderer.recompile(source) }
        requestRender()
    }

    fun applyUniforms(bytes: ByteArray) {
        queueEvent { renderer.uniformBytes = bytes }
        requestRender()
    }
}

private class MobGpuRenderer(private val onCompileError: (String?) -> Unit) :
    GLSurfaceView.Renderer {
    @Volatile
    var uniformBytes: ByteArray = ByteArray(0)

    private var program = 0
    private var ubo = 0
    private var vbo = 0
    private var vao = 0
    private var pendingSource: String? = null
    private var currentHash: Int = 0
    private var compileError: String? = null
    private var viewportW = 1
    private var viewportH = 1

    private fun setCompileError(err: String?) {
        if (err == compileError) return
        compileError = err
        onCompileError(err)
    }

    private val passthroughVertex = """
        #version 300 es
        in vec2 a_pos;
        out vec2 v_uv;
        void main() {
            gl_Position = vec4(a_pos, 0.0, 1.0);
            v_uv = a_pos * 0.5 + 0.5;
        }
    """.trimIndent()

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        // Full-screen quad as a triangle strip in NDC.
        val verts = floatArrayOf(
            -1f, -1f,
             1f, -1f,
            -1f,  1f,
             1f,  1f
        )
        val bb = ByteBuffer.allocateDirect(verts.size * 4).order(ByteOrder.nativeOrder())
        val fb = bb.asFloatBuffer()
        fb.put(verts).position(0)

        val vbos = IntArray(1); GLES30.glGenBuffers(1, vbos, 0); vbo = vbos[0]
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vbo)
        GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, verts.size * 4, fb, GLES30.GL_STATIC_DRAW)

        val vaos = IntArray(1); GLES30.glGenVertexArrays(1, vaos, 0); vao = vaos[0]
        GLES30.glBindVertexArray(vao)
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vbo)
        GLES30.glEnableVertexAttribArray(0)
        GLES30.glVertexAttribPointer(0, 2, GLES30.GL_FLOAT, false, 0, 0)

        val ubos = IntArray(1); GLES30.glGenBuffers(1, ubos, 0); ubo = ubos[0]
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        viewportW = width; viewportH = height
        GLES30.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        pendingSource?.let {
            compileNow(it)
            pendingSource = null
        }

        GLES30.glClearColor(0f, 0f, 0f, 1f)
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)

        if (program == 0) return

        GLES30.glUseProgram(program)

        // Upload uniforms as UBO contents bound at binding point 0.
        if (uniformBytes.isNotEmpty()) {
            GLES30.glBindBuffer(GLES30.GL_UNIFORM_BUFFER, ubo)
            val bb = ByteBuffer.wrap(uniformBytes)
            GLES30.glBufferData(GLES30.GL_UNIFORM_BUFFER, uniformBytes.size, bb, GLES30.GL_DYNAMIC_DRAW)
            GLES30.glBindBufferBase(GLES30.GL_UNIFORM_BUFFER, 0, ubo)
        }

        GLES30.glBindVertexArray(vao)
        GLES30.glDrawArrays(GLES30.GL_TRIANGLE_STRIP, 0, 4)
    }

    fun recompile(source: String) {
        val hash = source.hashCode()
        if (hash == currentHash && program != 0) return
        currentHash = hash
        pendingSource = source
    }

    private fun compileNow(source: String) {
        val vs = compileShader(GLES30.GL_VERTEX_SHADER, passthroughVertex) ?: return
        val fs = compileShader(GLES30.GL_FRAGMENT_SHADER, source) ?: run {
            GLES30.glDeleteShader(vs)
            return
        }

        val prog = GLES30.glCreateProgram()
        GLES30.glAttachShader(prog, vs)
        GLES30.glAttachShader(prog, fs)
        GLES30.glBindAttribLocation(prog, 0, "a_pos")
        GLES30.glLinkProgram(prog)
        val status = IntArray(1)
        GLES30.glGetProgramiv(prog, GLES30.GL_LINK_STATUS, status, 0)
        if (status[0] == 0) {
            setCompileError("link: " + GLES30.glGetProgramInfoLog(prog))
            GLES30.glDeleteProgram(prog)
            GLES30.glDeleteShader(vs); GLES30.glDeleteShader(fs)
            program = 0
            return
        }

        // Bind the shader's `Uniforms` block to binding point 0.
        val blockIdx = GLES30.glGetUniformBlockIndex(prog, "Uniforms")
        if (blockIdx != GLES30.GL_INVALID_INDEX) {
            GLES30.glUniformBlockBinding(prog, blockIdx, 0)
        }

        if (program != 0) GLES30.glDeleteProgram(program)
        program = prog
        setCompileError(null)
        GLES30.glDeleteShader(vs); GLES30.glDeleteShader(fs)
    }

    private fun compileShader(type: Int, source: String): Int? {
        val s = GLES30.glCreateShader(type)
        GLES30.glShaderSource(s, source)
        GLES30.glCompileShader(s)
        val status = IntArray(1)
        GLES30.glGetShaderiv(s, GLES30.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) {
            setCompileError(GLES30.glGetShaderInfoLog(s))
            GLES30.glDeleteShader(s)
            return null
        }
        return s
    }
}

@Composable
private fun MobVideoPlayer(node: MobNode, modifier: Modifier) {
    val src = node.props["src"] as? String ?: return
    val autoplay = boolProp(node.props, "autoplay") ?: false
    val context = LocalContext.current
    // ExoPlayer / Media3 video player.
    // Requires: implementation 'androidx.media3:media3-exoplayer:1.3.0'
    //           implementation 'androidx.media3:media3-ui:1.3.0'
    // Stubbed until Media3 dependency is added to build.gradle.
    // Replace this Box with the full player implementation when the dep is present:
    androidx.compose.foundation.layout.Box(
        modifier = modifier
            .background(Color.Black),
        contentAlignment = androidx.compose.ui.Alignment.Center
    ) {
        Text("Video: $src", color = Color.White, fontSize = 12.sp)
    }
}

@Composable
private fun MobLazyList(node: MobNode, modifier: Modifier) {
    val handle    = intProp(node.props, "on_end_reached")
    // Use a persistent LazyListState keyed by handle so scroll position survives
    // BEAM re-renders. rememberLazyListState() would reset to 0 on every data
    // update because AnimatedContent creates a fresh composition for each new
    // RootState, even when only list items changed (no navigation).
    val listState = remember(handle) {
        if (handle != null) MobBridge.getOrCreateLazyListState(handle)
        else LazyListState()
    }

    // Register by :id so Mob.Test.scroll_info/scroll_to can address this list.
    (node.props["id"] as? String)?.let { id ->
        MobBridge.scrollHandle(id).lazyState = listState
    }

    val reachedEnd by remember {
        derivedStateOf {
            val lastVisible = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: -1
            val total       = listState.layoutInfo.totalItemsCount
            total > 0 && lastVisible >= total - 1
        }
    }

    LaunchedEffect(reachedEnd) {
        if (reachedEnd) handle?.let { MobBridge.nativeSendTap(it) }
    }

    LazyColumn(state = listState, modifier = modifier.fillMaxWidth()) {
        items(node.children) { child -> RenderNode(child) }
    }
}

@Composable
private fun MobTabBar(node: MobNode, modifier: Modifier) {
    val tabs     = tabDefsProp(node.props)
    val activeId = (node.props["active"] as? String) ?: tabs.firstOrNull()?.get("id") ?: ""
    val handle   = intProp(node.props, "on_tab_select")
    val activeIdx = tabs.indexOfFirst { it["id"] == activeId }.coerceAtLeast(0)

    Scaffold(
        modifier  = modifier,
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { index, tab ->
                    NavigationBarItem(
                        selected = index == activeIdx,
                        onClick  = { handle?.let { MobBridge.nativeSendChangeStr(it, tab["id"] ?: "") } },
                        label    = { Text(tab["label"] ?: "") },
                        icon     = { Icon(materialIconForLogical(tab["icon"] ?: ""), contentDescription = tab["label"]) }
                    )
                }
            }
        }
    ) { innerPadding ->
        if (activeIdx < node.children.size) {
            RenderNode(node.children[activeIdx], Modifier.padding(innerPadding))
        }
    }
}

// ── Modifier helpers ──────────────────────────────────────────────────────────

private fun nodeModifier(props: Map<String, Any?>): Modifier {
    var m: Modifier = Modifier
    val cornerRadius = floatProp(props, "corner_radius") ?: 0f
    val shape = if (cornerRadius > 0f) RoundedCornerShape(cornerRadius.dp) else null

    // Background must come before padding so it fills the full area (including
    // padding space). If background were applied after padding, it would only
    // draw behind the inner content area — making empty boxes invisible.
    // When a corner radius is present, clip the background to that shape so
    // rectangular bleed doesn't show through the rounded corners.
    longColorProp(props, "background")?.let { bg ->
        m = if (shape != null) m.background(bg, shape) else m.background(bg)
    }

    // Border (opt-in: requires both border_color and border_width). Drawn on
    // the same shape as the background so rounded boxes get a proper outline.
    val borderColor = longColorProp(props, "border_color")
    val borderWidth = floatProp(props, "border_width") ?: 0f
    if (borderColor != null && borderWidth > 0f) {
        m = if (shape != null) m.border(borderWidth.dp, borderColor, shape)
            else m.border(borderWidth.dp, borderColor)
    }

    val uniform = intProp(props, "padding")
    val top     = intProp(props, "padding_top")
    val right   = intProp(props, "padding_right")
    val bottom  = intProp(props, "padding_bottom")
    val left    = intProp(props, "padding_left")
    val hasEdge = top != null || right != null || bottom != null || left != null
    m = when {
        hasEdge  -> m.padding(
            top    = (top    ?: uniform ?: 0).dp,
            end    = (right  ?: uniform ?: 0).dp,
            bottom = (bottom ?: uniform ?: 0).dp,
            start  = (left   ?: uniform ?: 0).dp,
        )
        uniform != null -> m.padding(uniform.dp)
        else            -> m
    }

    // Clip children to shape after padding so the rounded mask covers the
    // entire padded area, not just the inner content.
    if (shape != null) m = m.clip(shape)

    if (boolProp(props, "fill_width") == true) m = m.fillMaxWidth()
    // fill_height: true stretches the node to the parent's vertical bounds.
    // Used by full-screen overlay boxes whose center alignment needs the
    // viewport as its reference frame, not the contained children's height.
    if (boolProp(props, "fill_height") == true) m = m.fillMaxHeight()

    // Explicit width / height — when set, the node uses that exact size
    // instead of stretching to fill its parent. Used by SquareTriangle's
    // ring cells (110x110 boxes acting as rings via corner_radius +
    // border).
    floatProp(props, "width")?.let  { w -> m = m.width(w.dp) }
    floatProp(props, "height")?.let { h -> m = m.height(h.dp) }

    // aspect_ratio: lock a node to width:height = ratio. Common use is
    // <Box fill_width={true} aspect_ratio={1.0}> to make a square area
    // (e.g. camera preview + overlay canvas that need to match the
    // model's center-cropped square frame so coords align).
    floatProp(props, "aspect_ratio")?.let { r -> if (r > 0f) m = m.aspectRatio(r) }

    // Per-node offset is NOT applied here. Compose's Modifier.offset on the
    // node's own modifier chain didn't displace siblings reliably when stacking
    // multiple offset boxes inside a parent Box. RenderNode wraps the whole
    // node in an outer Box(Modifier.offset(...)) instead — see RenderNode.
    return m
}

// ── Typography helpers ────────────────────────────────────────────────────────

private fun fontWeightProp(props: Map<String, Any?>): FontWeight? =
    when (props["font_weight"] as? String) {
        "bold"     -> FontWeight.Bold
        "semibold" -> FontWeight.SemiBold
        "medium"   -> FontWeight.Medium
        "light"    -> FontWeight.Light
        "thin"     -> FontWeight.Thin
        else       -> null
    }

private fun textAlignProp(props: Map<String, Any?>): TextAlign? =
    when (props["text_align"] as? String) {
        "center" -> TextAlign.Center
        "right"  -> TextAlign.End
        else     -> null
    }

// Recursively convert org.json.JSONObject/JSONArray trees to plain Kotlin
// Map<String, Any?> / List<Any?> so they're usable by code that expects
// Kotlin collections (e.g. MobCanvas's "draw" op list).
private fun jsonObjectToMap(obj: JSONObject): Map<String, Any?> {
    val result = mutableMapOf<String, Any?>()
    for (key in obj.keys()) {
        result[key] = jsonValueToKotlin(obj.get(key))
    }
    return result
}

private fun jsonValueToKotlin(v: Any?): Any? = when (v) {
    is JSONObject -> jsonObjectToMap(v)
    is JSONArray  -> (0 until v.length()).map { i -> jsonValueToKotlin(v.get(i)) }
    JSONObject.NULL -> null
    else -> v
}

private fun fontFamilyProp(props: Map<String, Any?>, context: android.content.Context?): FontFamily? {
    val name = props["font"] as? String ?: return null
    // Custom fonts ship uncompressed in res/font/<normalized>.ttf (build-copied
    // from priv/fonts/ + plugin assets.fonts). Normalise the prop the same way
    // the build named the resource, look it up by id, and load it as a Typeface.
    // Fall back to a system family name (sans-serif, monospace, …), then null.
    if (context != null) {
        var resName = name.lowercase().replace(Regex("[^a-z0-9_]"), "_")
        if (!resName.matches(Regex("^[a-z].*"))) resName = "f_$resName"
        val resId = context.resources.getIdentifier(resName, "font", context.packageName)
        if (resId != 0) {
            try {
                val tf = androidx.core.content.res.ResourcesCompat.getFont(context, resId)
                if (tf != null) return FontFamily(tf)
            } catch (_: Exception) { }
        }
    }
    return try { FontFamily(Typeface.create(name, Typeface.NORMAL)) }
    catch (_: Exception) { null }
}

// ── Tab bar helpers ───────────────────────────────────────────────────────────

// Logical icon name → Material Icon. Mirrors the iOS sfSymbolName/2 lookup so
// the same Elixir tab declaration ("history", "qr_code", etc.) renders a
// platform-native icon on each side. Falls back to a visible Star for unknown
// names so missing mappings show up in the UI rather than failing silently.
private fun materialIconForLogical(logical: String): androidx.compose.ui.graphics.vector.ImageVector =
    when (logical) {
        "home"      -> Icons.Filled.Home
        "history"   -> Icons.Filled.History
        "list"      -> Icons.Filled.List
        "qr_code"   -> Icons.Filled.QrCode
        "link"      -> Icons.Filled.Link
        "snowflake" -> Icons.Filled.AcUnit
        "star"      -> Icons.Filled.Star
        "settings"  -> Icons.Filled.Settings
        "search"    -> Icons.Filled.Search
        "user"      -> Icons.Filled.Person
        else        -> Icons.Filled.Star
    }

private fun tabDefsProp(props: Map<String, Any?>): List<Map<String, String>> {
    return when (val raw = props["tabs"]) {
        is JSONArray -> (0 until raw.length()).map { i ->
            val obj = raw.getJSONObject(i)
            mapOf("id" to obj.optString("id"), "label" to obj.optString("label"), "icon" to obj.optString("icon"))
        }
        else -> emptyList()
    }
}

// ── Prop extraction ───────────────────────────────────────────────────────────

// Vertical alignment for Row from the `align:` prop — :top / :center / :bottom
// (atom from Elixir arrives as a String). Defaults to CenterVertically because
// that matches the most common visual expectation (e.g. icon next to title);
// opt back into Top with align: :top.
private fun rowAlignProp(props: Map<String, Any?>): Alignment.Vertical =
    when (props["align"] as? String) {
        "top"    -> Alignment.Top
        "bottom" -> Alignment.Bottom
        else     -> Alignment.CenterVertically
    }

// 2D alignment for Box content — same string keys as iOS so the
// renderer doesn't have to discriminate per platform.
private fun boxAlignProp(props: Map<String, Any?>): Alignment =
    when (props["align"] as? String) {
        "center"          -> Alignment.Center
        "top"             -> Alignment.TopCenter
        "top_center"      -> Alignment.TopCenter
        "top_trailing"    -> Alignment.TopEnd
        "leading"         -> Alignment.CenterStart
        "trailing"        -> Alignment.CenterEnd
        "bottom"          -> Alignment.BottomCenter
        "bottom_leading"  -> Alignment.BottomStart
        "bottom_center"   -> Alignment.BottomCenter
        "bottom_trailing" -> Alignment.BottomEnd
        else              -> Alignment.TopStart
    }

private fun colorProp(props: Map<String, Any?>, key: String): Color =
    longColorProp(props, key) ?: Color.Unspecified

private fun longColorProp(props: Map<String, Any?>, key: String): Color? =
    when (val v = props[key]) {
        is Long   -> Color(v.toInt())
        is Int    -> Color(v)
        is Double -> Color(v.toLong().toInt())
        else      -> null
    }

private fun sizeProp(props: Map<String, Any?>, key: String): TextUnit =
    when (val v = props[key]) {
        is Double -> v.toFloat().sp
        is Float  -> v.sp
        is Int    -> v.sp
        is Long   -> v.toFloat().sp
        else      -> TextUnit.Unspecified
    }

private fun intProp(props: Map<String, Any?>, key: String): Int? =
    when (val v = props[key]) {
        is Int    -> v
        is Long   -> v.toInt()
        is Double -> v.toInt()
        else      -> null
    }

private fun floatProp(props: Map<String, Any?>, key: String): Float? =
    when (val v = props[key]) {
        is Double -> v.toFloat()
        is Float  -> v
        is Int    -> v.toFloat()
        is Long   -> v.toFloat()
        else      -> null
    }

private fun boolProp(props: Map<String, Any?>, key: String): Boolean? =
    when (val v = props[key]) {
        is Boolean -> v
        is String  -> v == "true"
        else       -> null
    }

// ── Notification broadcast receiver ─────────────────────────────────────────
// Receives alarms from AlarmManager and posts the notification to the system tray.
// Also delivers the event to the running BEAM screen process if one is registered.
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: android.content.Context, intent: android.content.Intent) {
        val title   = intent.getStringExtra("title") ?: ""
        val body    = intent.getStringExtra("body")  ?: ""
        val id      = intent.getStringExtra("id")    ?: "mob"
        val dataStr = intent.getStringExtra("data")  ?: "{}"

        // Payload MainActivity.onCreate / onNewIntent expect under this key; they
        // forward it to the BEAM (delivered now if running, else on next boot).
        val json = """{"id":"$id","title":"$title","body":"$body","source":"local","data":$dataStr}"""

        // Tap action: bring MainActivity (singleTop) to the foreground carrying
        // the payload. Without a content intent the tap is a no-op.
        val tapIntent = android.content.Intent(context, MainActivity::class.java).apply {
            flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or
                android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("mob_notification_json", json)
        }
        val contentPi = PendingIntent.getActivity(
            context, id.hashCode(), tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val nm = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as NotificationManager
        val notif = NotificationCompat.Builder(context, io.mob.plugin.MobNotifyHub.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(contentPi)
            .setAutoCancel(true)
            .build()
        nm.notify(id.hashCode(), notif)
    }

}
