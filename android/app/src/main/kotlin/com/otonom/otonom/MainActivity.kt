package com.otonom.otonom

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.otonom.app/dynamic_icon"

    private val brandAliases = mapOf(
        "tesla" to ".MainActivityTesla",
        "bmw" to ".MainActivityBmw",
        "togg" to ".MainActivityTogg",
        "mercedes" to ".MainActivityMercedes",
        "porsche" to ".MainActivityPorsche",
        "audi" to ".MainActivityAudi"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "setAlternateIcon") {
                    val iconKey = call.argument<String>("iconKey") ?: "tesla"
                    val switched = switchLauncherAlias(iconKey)
                    result.success(switched)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun switchLauncherAlias(selectedKey: String): Boolean {
        return try {
            val targetSuffix = brandAliases[selectedKey] ?: ".MainActivityTesla"
            val pm = applicationContext.packageManager
            val pkg = applicationContext.packageName

            // Enable selected alias first so the launcher always has an active entry
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg$targetSuffix"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            for ((_, suffix) in brandAliases) {
                if (suffix != targetSuffix) {
                    pm.setComponentEnabledSetting(
                        ComponentName(pkg, "$pkg$suffix"),
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }
            }
            true
        } catch (_: Exception) {
            false
        }
    }
}
