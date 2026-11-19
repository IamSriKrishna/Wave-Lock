package com.wakelock.wakelock

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.provider.Settings
import android.telecom.TelecomManager
import android.view.accessibility.AccessibilityEvent

class StrictModeAccessibilityService : AccessibilityService() {
    private var lastBlockedAt = 0L

    override fun onServiceConnected() {
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (!isStrictModeActive()) return
        if (isAllowedPackage(packageName)) return

        val now = SystemClock.elapsedRealtime()
        if (now - lastBlockedAt < BLOCK_ACTION_INTERVAL_MS) return

        lastBlockedAt = now
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    override fun onInterrupt() = Unit

    private fun isStrictModeActive(): Boolean {
        val preferences = getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        if (preferences.getBoolean(MISSION_ACTIVE, false)) return true
        if (!preferences.getBoolean(ACTIVE, false)) return false

        val endTime = preferences.getLong(END_TIME, 0L)
        if (endTime == 0L) return true
        if (endTime > System.currentTimeMillis()) return true

        preferences.edit()
            .putBoolean(ACTIVE, false)
            .remove(END_TIME)
            .apply()
        return false
    }

    private fun isAllowedPackage(packageName: String): Boolean {
        if (
            packageName == applicationContext.packageName ||
            packageName == "com.whatsapp" ||
            packageName == "com.whatsapp.w4b" ||
            packageName == "com.android.systemui" ||
            packageName == "android" ||
            packageName in homePackages() ||
            packageName in dialerPackages() ||
            packageName == inputMethodPackage()
        ) {
            return true
        }

        return false
    }

    private fun homePackages(): Set<String> {
        val packages = mutableSetOf<String>()
        val homeIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        packageManager.resolveActivity(homeIntent, 0)
            ?.activityInfo
            ?.packageName
            ?.let(packages::add)

        return packages
    }

    private fun dialerPackages(): Set<String> {
        val telecomManager = getSystemService(TelecomManager::class.java)
        return setOfNotNull(telecomManager?.defaultDialerPackage)
    }

    private fun inputMethodPackage(): String? {
        return Settings.Secure.getString(
            contentResolver,
            Settings.Secure.DEFAULT_INPUT_METHOD,
        )?.substringBefore('/')
    }

    companion object {
        const val PREFERENCES = "wakelock_strict_mode"
        const val ACTIVE = "active"
        const val MISSION_ACTIVE = "mission_active"
        const val END_TIME = "end_time_millis"
        private const val BLOCK_ACTION_INTERVAL_MS = 700L
    }
}
