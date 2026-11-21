package com.wakelock.wakelock

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONObject
import java.util.Calendar

class HabitAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, 0)
        val title = intent.getStringExtra(EXTRA_TITLE) ?: return
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""
        val payload = intent.getStringExtra(EXTRA_PAYLOAD) ?: ""

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_BODY, body)
            putExtra(EXTRA_PAYLOAD, payload)
        }
        context.startActivity(launchIntent)

        if (!intent.getBooleanExtra(EXTRA_ONE_SHOT, false)) {
            schedule(
                context = context,
                alarmId = alarmId,
                title = title,
                body = body,
                payload = payload,
                weekday = intent.getIntExtra(EXTRA_WEEKDAY, 0),
                timeMinutes = intent.getIntExtra(EXTRA_TIME_MINUTES, 0),
            )
        }
    }

    companion object {
        const val EXTRA_ALARM_ID = "habit_alarm_id"
        const val EXTRA_TITLE = "habit_alarm_title"
        const val EXTRA_BODY = "habit_alarm_body"
        const val EXTRA_PAYLOAD = "habit_alarm_payload"
        const val EXTRA_WEEKDAY = "habit_alarm_weekday"
        const val EXTRA_TIME_MINUTES = "habit_alarm_time_minutes"
        const val EXTRA_ONE_SHOT = "habit_alarm_one_shot"

        private const val PREFERENCES = "habit_alarm_schedule"
        private const val KEY_PREFIX = "alarm_"
        private const val ACTION_ALARM = "com.wakelock.wakelock.HABIT_ALARM"

        fun schedule(
            context: Context,
            alarmId: Int,
            title: String,
            body: String,
            payload: String,
            weekday: Int,
            timeMinutes: Int,
        ) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                throw SecurityException("Alarms & reminders permission is required.")
            }

            val alarmData = JSONObject()
                .put(EXTRA_ALARM_ID, alarmId)
                .put(EXTRA_TITLE, title)
                .put(EXTRA_BODY, body)
                .put(EXTRA_PAYLOAD, payload)
                .put(EXTRA_WEEKDAY, weekday)
                .put(EXTRA_TIME_MINUTES, timeMinutes)

            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_PREFIX + alarmId, alarmData.toString())
                .apply()

            val pendingIntent = pendingIntent(
                context,
                alarmId,
                alarmData.toIntentExtras(context),
            )
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                nextOccurrence(weekday, timeMinutes),
                pendingIntent,
            )
        }

        fun scheduleSnooze(
            context: Context,
            alarmId: Int,
            title: String,
            body: String,
            payload: String,
        ) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                throw SecurityException("Alarms & reminders permission is required.")
            }

            val snoozeId = alarmId xor 0x40000000
            val intent = Intent(context, HabitAlarmReceiver::class.java).apply {
                action = ACTION_ALARM
                putExtra(EXTRA_ALARM_ID, snoozeId)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
                putExtra(EXTRA_PAYLOAD, payload)
                putExtra(EXTRA_ONE_SHOT, true)
            }
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                System.currentTimeMillis() + SNOOZE_MILLIS,
                PendingIntent.getBroadcast(
                    context,
                    snoozeId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
        }

        fun cancel(context: Context, alarmId: Int) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            val pendingIntent = pendingIntent(context, alarmId, null)
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .edit()
                .remove(KEY_PREFIX + alarmId)
                .apply()
        }

        fun restore(context: Context) {
            val preferences = context.getSharedPreferences(
                PREFERENCES,
                Context.MODE_PRIVATE,
            )
            for ((key, value) in preferences.all) {
                if (!key.startsWith(KEY_PREFIX) || value !is String) continue
                try {
                    val alarm = JSONObject(value)
                    schedule(
                        context = context,
                        alarmId = alarm.getInt(EXTRA_ALARM_ID),
                        title = alarm.getString(EXTRA_TITLE),
                        body = alarm.getString(EXTRA_BODY),
                        payload = alarm.getString(EXTRA_PAYLOAD),
                        weekday = alarm.getInt(EXTRA_WEEKDAY),
                        timeMinutes = alarm.getInt(EXTRA_TIME_MINUTES),
                    )
                } catch (error: Exception) {
                    Log.e("HabitAlarmReceiver", "Failed to restore $key", error)
                }
            }
        }

        private fun pendingIntent(
            context: Context,
            alarmId: Int,
            extras: Intent?,
        ): PendingIntent {
            val intent = extras ?: Intent(context, HabitAlarmReceiver::class.java).apply {
                action = ACTION_ALARM
            }
            return PendingIntent.getBroadcast(
                context,
                alarmId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun nextOccurrence(weekday: Int, timeMinutes: Int): Long {
            val targetDay = if (weekday == 7) {
                Calendar.SUNDAY
            } else {
                weekday + 1
            }
            val now = Calendar.getInstance()
            val next = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, timeMinutes / 60)
                set(Calendar.MINUTE, timeMinutes % 60)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                while (get(Calendar.DAY_OF_WEEK) != targetDay || !after(now)) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            return next.timeInMillis
        }

        private fun JSONObject.toIntentExtras(context: Context): Intent =
            Intent(context, HabitAlarmReceiver::class.java).apply {
                action = ACTION_ALARM
                putExtra(EXTRA_ALARM_ID, getInt(EXTRA_ALARM_ID))
                putExtra(EXTRA_TITLE, getString(EXTRA_TITLE))
                putExtra(EXTRA_BODY, getString(EXTRA_BODY))
                putExtra(EXTRA_PAYLOAD, getString(EXTRA_PAYLOAD))
                putExtra(EXTRA_WEEKDAY, getInt(EXTRA_WEEKDAY))
                putExtra(EXTRA_TIME_MINUTES, getInt(EXTRA_TIME_MINUTES))
            }

        private const val SNOOZE_MILLIS = 5 * 60 * 1000L
    }
}

class HabitAlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        HabitAlarmReceiver.restore(context)
    }
}
