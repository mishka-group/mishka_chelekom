package com.example.mishka_mob

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import java.io.File

class MainActivity : ComponentActivity() {

    companion object {
        private const val TAG = "MishkaMob"
        init { System.loadLibrary("mishka_mob") }
    }

    external fun nativeSetActivity(activity: Activity)
    external fun nativeStartBeam()
    external fun nativeNotifyOrientation(orient: String)
    external fun nativeNotifyConnectivity(
        online: Boolean,
        transport: String,
        expensive: Boolean,
        validated: Boolean,
    )

    // ── Network connectivity ──────────────────────────────────────────────
    // A ConnectivityManager.NetworkCallback drives Mob.Device.network_state/0
    // and the :network subscription. registerDefaultNetworkCallback fires an
    // initial onCapabilitiesChanged, so the BEAM-side cache is seeded at start.
    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    private fun registerNetworkCallback() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager ?: return
        connectivityManager = cm
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
                pushConnectivity(caps)
            }

            override fun onLost(network: Network) {
                // Don't blindly report offline: on a wifi->cellular handoff the
                // lost default's onLost can arrive after the new default has
                // settled, which would leave us stuck offline. Re-check the
                // current active network before concluding there's no path.
                val active = connectivityManager?.activeNetwork
                val caps = active?.let { connectivityManager?.getNetworkCapabilities(it) }
                pushConnectivity(caps)
            }
        }
        networkCallback = callback
        try {
            cm.registerDefaultNetworkCallback(callback)
        } catch (_: Throwable) {
        }
    }

    private fun pushConnectivity(caps: NetworkCapabilities?) {
        if (caps == null) {
            notifyConnectivitySafe(false, "none", false, false)
            return
        }
        val transport = when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "wired"
            else -> "other"
        }
        val expensive = !caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        // Android actively probes for real internet reachability — false on a
        // captive portal / before validation. iOS has no equivalent (:unavailable).
        val validated = caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        notifyConnectivitySafe(true, transport, expensive, validated)
    }

    private fun notifyConnectivitySafe(
        online: Boolean,
        transport: String,
        expensive: Boolean,
        validated: Boolean,
    ) {
        try {
            nativeNotifyConnectivity(online, transport, expensive, validated)
        } catch (_: Throwable) {
        }
    }

    // ── File picker launcher ──────────────────────────────────────────────
    private val filePickerLauncher =
        registerForActivityResult(ActivityResultContracts.OpenMultipleDocuments()) { uris ->
            MobBridge.handleFilesResult(uris)
        }

    fun launchFilePicker() {
        filePickerLauncher.launch(arrayOf("*/*"))
    }

    // ── Permission result ─────────────────────────────────────────────────
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 9001) {
            val granted = grantResults.isNotEmpty() &&
                grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            MobBridge.onPermissionResult(granted)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Edge-to-edge: lets the content draw behind the (transparent) status
        // and navigation bars instead of being letterboxed by opaque system
        // bars. Must be called BEFORE super.onCreate() per AndroidX docs.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        MobBridge.init(this)

        registerNetworkCallback()

        // Register activated plugins' Kotlin bridge classes (generated by
        // mob_dev at build time). Each register() caches its own jclass +
        // method IDs natively so the plugin's NIF can call into it; the
        // Activity is then handed to any bridge implementing
        // io.mob.plugin.MobActivityAware. Must run before the BEAM starts.
        io.mob.plugin.MobPluginBootstrap.registerAll(this)

        // Forward launcher-supplied env vars into the BEAM process. Set BEFORE
        // nativeStartBeam below so the BEAM (and Mob.Dist in particular) sees
        // them when it reads getenv()/System.get_env/1.
        //
        //   mob_node_suffix — appended to the configured node name
        //                     (`<app>_android` → `<app>_android_<suffix>`).
        //                     Lets multiple Android phones running the same
        //                     app coexist in Mac's shared EPMD.
        //   mob_dist_port   — Erlang dist listen port (default 9100).
        intent?.extras?.getString("mob_node_suffix")?.takeIf { it.isNotEmpty() }?.let { suffix ->
            android.system.Os.setenv("MOB_NODE_SUFFIX", suffix, true)
            Log.i(TAG, "onCreate: MOB_NODE_SUFFIX=$suffix")
        }

        intent?.extras?.getInt("mob_dist_port", -1)?.takeIf { it > 0 }?.let { port ->
            android.system.Os.setenv("MOB_DIST_PORT", port.toString(), true)
            Log.i(TAG, "onCreate: MOB_DIST_PORT=$port")
        }

        // Check if launched from a notification tap
        intent?.extras?.getString("mob_notification_json")?.let { json ->
            MobBridge.setLaunchNotification(json)
        }

        setContent {
            val state by MobBridge.rootState
            val themeColors by MobBridge.themeColors

            BackHandler(enabled = state.node != null) { MobBridge.nativeHandleBack() }

            // Material 3 chrome (NavigationBar, Button, …) pulls its colours
            // from `MaterialTheme.colorScheme`. We want those to match the
            // BEAM-side `Mob.Theme` so the system widgets don't clash with
            // mob's own primitives. `themeColors` updates via
            // `:mob_nif.set_theme/1` whenever `Mob.Theme.set(...)` runs.
            //
            // There's a brief window at launch — Compose evaluates setContent
            // before the BEAM finishes `mount/3` and pushes the first theme
            // — so the null branch falls back to Material's stock dark
            // scheme, which usually reads as a fine placeholder until the
            // real palette arrives.
            val colorScheme = themeColors?.let { tc ->
                darkColorScheme(
                    primary          = colorFromMap(tc, "primary",          0xFF6750A4),
                    onPrimary        = colorFromMap(tc, "on_primary",       0xFFFFFFFF),
                    secondary        = colorFromMap(tc, "secondary",        0xFF625B71),
                    onSecondary      = colorFromMap(tc, "on_secondary",     0xFFFFFFFF),
                    background       = colorFromMap(tc, "background",       0xFF1C1B1F),
                    onBackground     = colorFromMap(tc, "on_background",    0xFFE6E1E5),
                    surface          = colorFromMap(tc, "surface",          0xFF1C1B1F),
                    onSurface        = colorFromMap(tc, "on_surface",       0xFFE6E1E5),
                    // Mob's `surface_raised` / `muted` map onto Material 3's
                    // surfaceVariant / onSurfaceVariant — same role.
                    surfaceVariant   = colorFromMap(tc, "surface_raised",   0xFF49454F),
                    onSurfaceVariant = colorFromMap(tc, "muted",            0xFFCAC4D0),
                    outline          = colorFromMap(tc, "border",           0xFF938F99),
                    error            = colorFromMap(tc, "error",            0xFFF2B8B5),
                    onError          = colorFromMap(tc, "on_error",         0xFFFFFFFF),
                )
            } ?: darkColorScheme()

            MaterialTheme(colorScheme = colorScheme) {
                AnimatedContent(
                    targetState   = state,
                    contentKey    = { it.navKey },
                    transitionSpec = {
                        when (targetState.transition) {
                            "push" ->
                                slideInHorizontally(animationSpec = tween(300)) { it } togetherWith
                                slideOutHorizontally(animationSpec = tween(300)) { -it / 3 }
                            "pop" ->
                                slideInHorizontally(animationSpec = tween(300)) { -it / 3 } togetherWith
                                slideOutHorizontally(animationSpec = tween(300)) { it }
                            "reset" ->
                                fadeIn(animationSpec = tween(250)) togetherWith
                                fadeOut(animationSpec = tween(250))
                            else ->
                                EnterTransition.None togetherWith ExitTransition.None
                        }
                    },
                    label = "nav"
                ) { s ->
                    s.node?.let { RenderNode(it, modifier = Modifier.fillMaxSize().safeDrawingPadding()) }
                }
            }
        }

        // If the project ships embedded Python (mix mob.enable pythonx), the
        // APK contains assets/python/{stdlib,lib-dynload}/. Extract those to
        // filesDir on first launch and tell the BEAM where they landed via
        // env vars consumed by <App>.PythonPaths. Idempotent — re-launches
        // skip extraction once the marker file is present.
        extractPythonAssetsIfNeeded()

        Log.i(TAG, "onCreate — handing off to BEAM")
        nativeSetActivity(this)
        Thread({ nativeStartBeam() }, "beam-main").start()
    }

    private fun extractPythonAssetsIfNeeded() {
        val pythonRoot = File(filesDir, "python")
        val marker = File(pythonRoot, ".extracted")

        // libpython3.13.so is auto-extracted by the APK installer to the
        // app's nativeLibraryDir — point Pythonx.init/4 at it.
        val libPython = File(applicationInfo.nativeLibraryDir, "libpython3.13.so")

        if (libPython.exists()) {
            android.system.Os.setenv("MOB_PYTHON_DL", libPython.absolutePath, true)
        }

        // Skip extraction if no assets ship Python (project doesn't use Pythonx)
        // or if extraction has already happened.
        val assetList = try { assets.list("python") ?: emptyArray() } catch (_: Throwable) { emptyArray() }
        if (assetList.isEmpty() || marker.exists()) {
            if (pythonRoot.exists()) {
                android.system.Os.setenv("MOB_PYTHON_HOME", pythonRoot.absolutePath, true)
            }
            return
        }

        Log.i(TAG, "extractPythonAssets: extracting assets/python → ${pythonRoot.absolutePath}")
        copyAssetTree("python", pythonRoot)
        flattenLibDynload(pythonRoot)
        marker.createNewFile()
        android.system.Os.setenv("MOB_PYTHON_HOME", pythonRoot.absolutePath, true)
        Log.i(TAG, "extractPythonAssets: done")
    }

    // Chaquopy ships lib-dynload/<abi>/*.so per architecture; CPython expects
    // them flat in lib-dynload/. Move the device's primary-abi `.so` files
    // up one level and discard the rest.
    private fun flattenLibDynload(pythonRoot: File) {
        val libDynload = File(pythonRoot, "lib/python3.13/lib-dynload")
        if (!libDynload.isDirectory) return

        val deviceAbi = android.os.Build.SUPPORTED_ABIS.firstOrNull() ?: return
        val abiDir = File(libDynload, deviceAbi)
        if (!abiDir.isDirectory) return

        abiDir.listFiles()?.forEach { src ->
            val dst = File(libDynload, src.name)
            if (!dst.exists()) src.renameTo(dst)
        }
        // Drop the other-abi dirs to free space.
        libDynload.listFiles { f -> f.isDirectory }?.forEach { it.deleteRecursively() }
    }

    private fun copyAssetTree(srcPath: String, destDir: File) {
        val children = assets.list(srcPath) ?: emptyArray()

        if (children.isEmpty()) {
            // Leaf: copy the file
            destDir.parentFile?.mkdirs()
            assets.open(srcPath).use { input ->
                destDir.outputStream().use { output -> input.copyTo(output) }
            }
            return
        }

        destDir.mkdirs()
        for (child in children) {
            copyAssetTree("$srcPath/$child", File(destDir, child))
        }
    }

    // Called when a notification is tapped and the activity already exists at
    // the top of the stack (singleTop launch mode). If BEAM is running, deliver
    // the notification directly; otherwise store it for delivery on boot.
    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.extras?.getString("mob_notification_json")?.let { json ->
            val pid = io.mob.plugin.MobNotifyHub.notifyPid
            if (pid != 0L) {
                MobBridge.nativeDeliverNotification(pid, json)
            } else {
                MobBridge.setLaunchNotification(json)
            }
        }
    }

    // Manifest declares `android:configChanges` including `uiMode`, so a
    // dark/light toggle delivers here instead of recreating the activity.
    // Forward to MobBridge so Mob.Device :appearance subscribers can react
    // (e.g. re-resolve Mob.Theme.Adaptive without an app restart).
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val nightMode = newConfig.uiMode and Configuration.UI_MODE_NIGHT_MASK
        val scheme = if (nightMode == Configuration.UI_MODE_NIGHT_YES) "dark" else "light"
        MobBridge.notifyColorSchemeChanged(scheme)

        // Forward the new orientation to the BEAM so Mob.Device.orientation/0 and
        // the :display subscription reflect a rotation (mob_send_orientation_changed).
        val orient = when (display?.rotation) {
            android.view.Surface.ROTATION_90 -> "landscape_left"
            android.view.Surface.ROTATION_270 -> "landscape_right"
            android.view.Surface.ROTATION_180 -> "portrait_upside_down"
            else -> "portrait"
        }
        try {
            nativeNotifyOrientation(orient)
        } catch (_: Throwable) {
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        val cm = connectivityManager
        val cb = networkCallback
        if (cm != null && cb != null) {
            try {
                cm.unregisterNetworkCallback(cb)
            } catch (_: Throwable) {
            }
        }
    }

    // Pulls an ARGB long out of the BEAM-pushed theme map, falling back to
    // a Material 3 stock dark value when the key isn't present (e.g. a
    // custom theme that doesn't define every Material 3 slot).
    private fun colorFromMap(map: Map<String, Long>, key: String, fallback: Long): Color =
        Color(map[key] ?: fallback)
}
