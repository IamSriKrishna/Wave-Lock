package com.wakelock.wakelock

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val strictModeChannel = "com.wakelock/strict_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            strictModeChannel,
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
                    val endTimeMillis = call.argument<Long>("endTimeMillis")
                    val preferences = getSharedPreferences(
                        StrictModeAccessibilityService.PREFERENCES,
                        MODE_PRIVATE,
                    )

                    if (
                        active &&
                        (!isStrictModeAccessibilityEnabled() ||
                            endTimeMillis == null ||
                            endTimeMillis <= System.currentTimeMillis())
                    ) {
                        preferences.edit()
                            .putBoolean(StrictModeAccessibilityService.ACTIVE, false)
                            .remove(StrictModeAccessibilityService.END_TIME)
                            .apply()
                    } else {
                        preferences.edit()
                            .putBoolean(StrictModeAccessibilityService.ACTIVE, active)
                            .apply {
                                if (active) {
                                    putLong(
                                        StrictModeAccessibilityService.END_TIME,
                                        endTimeMillis!!,
                                    )
                                } else {
                                    remove(StrictModeAccessibilityService.END_TIME)
                                }
                            }
                            .apply()
                    }

                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isStrictModeAccessibilityEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val serviceName = ComponentName(
            this,
            StrictModeAccessibilityService::class.java,
        ).flattenToString()

        return TextUtils.SimpleStringSplitter(':').run {
            setString(enabledServices)
            any { it.equals(serviceName, ignoreCase = true) }
        }
    }
}
