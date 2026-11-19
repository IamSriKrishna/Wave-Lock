
package com.wakelock.wakelock

import android.content.ComponentName
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.wakelock/app_selection"
    private val strictModeChannelName = "com.wakelock/strict_mode"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (error: Exception) {
                        result.error(
                            "APP_DISCOVERY_ERROR",
                            error.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            strictModeChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isStrictModeAccessibilityEnabled())
                }

                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }

                "setStrictModeActive" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    val endTime = call.argument<Number>("endTimeMillis")?.toLong()
                    val preferences = getSharedPreferences(
                        StrictModeAccessibilityService.PREFERENCES,
                        MODE_PRIVATE
                    )

                    if (
                        active &&
                        isStrictModeAccessibilityEnabled() &&
                        endTime != null &&
                        endTime > System.currentTimeMillis()
                    ) {
                        preferences.edit()
                            .putBoolean(StrictModeAccessibilityService.ACTIVE, true)
                            .putLong(StrictModeAccessibilityService.END_TIME, endTime)
                            .apply()
                    } else {
                        preferences.edit()
                            .putBoolean(StrictModeAccessibilityService.ACTIVE, false)
                            .remove(StrictModeAccessibilityService.END_TIME)
                            .apply()
                    }

                    result.success(null)
                }

                "setMissionStrictModeActive" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    getSharedPreferences(
                        StrictModeAccessibilityService.PREFERENCES,
                        MODE_PRIVATE
                    ).edit()
                        .putBoolean(StrictModeAccessibilityService.MISSION_ACTIVE, active)
                        .apply()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isStrictModeAccessibilityEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val serviceName = ComponentName(
            this,
            StrictModeAccessibilityService::class.java
        ).flattenToString()

        return enabledServices.split(':').any { it.equals(serviceName, ignoreCase = true) }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {

        val packageManager = packageManager

        val applications = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledApplications(
                PackageManager.ApplicationInfoFlags.of(0)
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstalledApplications(0)
        }

        return applications.mapNotNull { appInfo ->

            val packageName = appInfo.packageName

            // Only include apps that have a launcher activity.
            val launchIntent =
                packageManager.getLaunchIntentForPackage(packageName)

            if (launchIntent == null || packageName == this.packageName) {
                return@mapNotNull null
            }

            val isSystemApp =
                (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0

            val appName = packageManager
                .getApplicationLabel(appInfo)
                .toString()

            mapOf(
                "packageName" to packageName,
                "appName" to appName,
                "isSystemApp" to isSystemApp
            )
        }.sortedBy {
            it["appName"].toString().lowercase()
        }
    }
}
