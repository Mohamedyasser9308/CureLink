package com.example.curelink

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class DoseAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, -1)
        context.getSharedPreferences(DoseAlarmBootReceiver.PREFERENCES, Context.MODE_PRIVATE)
            .edit().remove(DoseAlarmBootReceiver.keyFor(alarmId)).apply()
        val serviceIntent = Intent(context, DoseAlarmService::class.java)
            .setAction(DoseAlarmService.ACTION_RING)
            .putExtra(EXTRA_ALARM_ID, alarmId)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (_: RuntimeException) {
            // The already-scheduled local notification remains the fallback
            // if Android revokes the exact-alarm or foreground-service grant.
        }
    }

    companion object {
        const val EXTRA_ALARM_ID = "dose_alarm_id"
    }
}
