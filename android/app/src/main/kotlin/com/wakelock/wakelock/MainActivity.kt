
package com.wakelock.wakelock

import android.content.ComponentName
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import java.util.Calendar
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.wakelock/app_selection"
    private val strictModeChannelName = "com.wakelock/strict_mode"
    private val appUsageChannelName = "com.wakelock/app_usage"

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appUsageChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getWeeklyUsage" -> {
                    try {
                        result.success(getWeeklyUsage())
                    } catch (error: Exception) {
                        result.error(
                            "APP_USAGE_ERROR",
                            error.message,
                            null
                        )
                    }
                }

                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
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

    private fun hasUsageAccess(): Boolean {
        val appOpsManager = getSystemService(AppOpsManager::class.java)
        return appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        ) == AppOpsManager.MODE_ALLOWED
    }

    private fun getWeeklyUsage(): Map<String, Any> {
        val hasAccess = hasUsageAccess()
        val days = (0..6).map { offset ->
            val dayCalendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.DAY_OF_YEAR, -6 + offset)
            }
            dayCalendar.timeInMillis
        }

        if (!hasAccess) {
            return mapOf(
                "hasAccess" to false,
                "days" to days.map { dayStart ->
                    mapOf("dayStartMillis" to dayStart, "apps" to emptyList<Map<String, Any>>())
                }
            )
        }

        val end = System.currentTimeMillis()
        val usageStatsManager = getSystemService(UsageStatsManager::class.java)

        return mapOf(
            "hasAccess" to true,
            "days" to days.mapIndexed { index, dayStart ->
                val dayEnd = days.getOrNull(index + 1) ?: end
                val apps = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY,
                    dayStart,
                    dayEnd
                ).orEmpty().mapNotNull { usage ->
                    if (
                        usage.packageName == packageName ||
                        usage.totalTimeInForeground <= 0L ||
                        packageManager.getLaunchIntentForPackage(usage.packageName) == null
                    ) {
                        return@mapNotNull null
                    }

                    val appInfo = try {
                        packageManager.getApplicationInfo(usage.packageName, 0)
                    } catch (_: PackageManager.NameNotFoundException) {
                        return@mapNotNull null
                    }

                    mapOf(
                        "packageName" to usage.packageName,
                        "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                        "durationMillis" to usage.totalTimeInForeground
                    )
                }
                mapOf(
                    "dayStartMillis" to dayStart,
                    "apps" to apps.sortedByDescending {
                        it["durationMillis"] as Long
                    }
                )
            }
        )
    }
}
