
package com.example.curelink

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class DoseAlarmBootReceiver : BroadcastReceiver() {

    companion object {
        const val PREFERENCES = "curelink_dose_alarm_schedule"

        private const val KEY_PREFIX = "alarm_"
        private const val PAYLOAD_PREFIX = "payload_"
        private const val TAG = "CureLinkDoseAlarm"

        private const val ACTION_QUICKBOOT_POWERON =
            "android.intent.action.QUICKBOOT_POWERON"

        fun keyFor(alarmId: Int): String =
            "$KEY_PREFIX$alarmId"

        fun payloadKeyFor(alarmId: Int): String =
            "$PAYLOAD_PREFIX$alarmId"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action

        val supportedActions = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            ACTION_QUICKBOOT_POWERON,
            AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED
        )

        if (action !in supportedActions) return

        Log.i(TAG, "Restoring alarms after action=$action")

        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val preferences = context.getSharedPreferences(
            PREFERENCES,
            Context.MODE_PRIVATE
        )

        for ((key, value) in preferences.all) {
            if (!key.startsWith(KEY_PREFIX) || value !is Long) {
                continue
            }

            val alarmId = key
                .removePrefix(KEY_PREFIX)
                .toIntOrNull() ?: continue

            val atMillis = value

            if (atMillis <= System.currentTimeMillis()) {
                Log.i(TAG, "Removing expired alarm ID=$alarmId")

                preferences.edit()
                    .remove(key)
                    .remove(payloadKeyFor(alarmId))
                    .apply()

                continue
            }

            val payload = preferences.getString(
                payloadKeyFor(alarmId),
                null
            )

            val alarmIntent = Intent(
                context,
                DoseAlarmReceiver::class.java
            ).apply {
                putExtra(
                    DoseAlarmReceiver.EXTRA_ALARM_ID,
                    alarmId
                )
                putExtra(
                    DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD,
                    payload
                )
            }

            val pending = PendingIntent.getBroadcast(
                context,
                alarmId,
                alarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

            val showAppIntent = Intent(
                context,
                MainActivity::class.java
            ).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                )
            }

            val showApp = PendingIntent.getActivity(
                context,
                alarmId + 900000000,
                showAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

            try {
                if (
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                    !alarmManager.canScheduleExactAlarms()
                ) {
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        atMillis,
                        pending
                    )

                    Log.w(
                        TAG,
                        "Restored alarm as inexact: ID=$alarmId"
                    )
                } else {
                    alarmManager.setAlarmClock(
                        AlarmManager.AlarmClockInfo(
                            atMillis,
                            showApp
                        ),
                        pending
                    )

                    Log.i(
                        TAG,
                        "Restored exact alarm: ID=$alarmId at=$atMillis"
                    )
                }
            } catch (error: Exception) {
                Log.e(
                    TAG,
                    "Could not restore alarm ID=$alarmId",
                    error
                )
            }
        }
    }
}
