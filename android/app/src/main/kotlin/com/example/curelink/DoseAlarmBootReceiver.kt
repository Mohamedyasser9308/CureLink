package com.example.curelink

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class DoseAlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            intent.action != ACTION_QUICKBOOT_POWERON &&
            intent.action != AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED) return

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val canScheduleExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            alarmManager.canScheduleExactAlarms()

        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        for ((key, value) in preferences.all) {
            if (!key.startsWith(KEY_PREFIX) || value !is Long) continue
            val alarmId = key.removePrefix(KEY_PREFIX).toIntOrNull() ?: continue
            val pending = PendingIntent.getBroadcast(
                context,
                alarmId,
                Intent(context, DoseAlarmReceiver::class.java)
                    .putExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, alarmId),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try {
                if (canScheduleExact) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, value, pending)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, value, pending)
                }
            } catch (_: SecurityException) {
                // The Flutter local-notification boot receiver restores the regular reminder.
            }
        }
    }

    companion object {
        const val PREFERENCES = "curelink_dose_alarm_schedule"
        private const val KEY_PREFIX = "alarm_"
        private const val ACTION_QUICKBOOT_POWERON = "android.intent.action.QUICKBOOT_POWERON"

        fun keyFor(alarmId: Int) = "$KEY_PREFIX$alarmId"
    }
}
