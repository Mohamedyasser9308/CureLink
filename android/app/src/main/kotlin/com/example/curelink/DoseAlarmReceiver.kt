
package com.example.curelink

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class DoseAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_ALARM_ID = "dose_alarm_id"
        const val EXTRA_DOSE_PAYLOAD = "dose_payload"

        private const val TAG = "CureLinkDoseAlarm"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(
            EXTRA_ALARM_ID,
            DoseAlarmService.INVALID_ALARM_ID
        )

        val payload = intent.getStringExtra(EXTRA_DOSE_PAYLOAD)

        if (alarmId == DoseAlarmService.INVALID_ALARM_ID) {
            Log.e(TAG, "Received alarm with invalid ID")
            return
        }

        Log.i(
            TAG,
            "Alarm receiver fired: id=$alarmId payload=$payload"
        )

        // This alarm has fired. Remove its saved schedule entry.
        context.getSharedPreferences(
            DoseAlarmBootReceiver.PREFERENCES,
            Context.MODE_PRIVATE
        ).edit()
            .remove(DoseAlarmBootReceiver.keyFor(alarmId))
            .remove(DoseAlarmBootReceiver.payloadKeyFor(alarmId))
            .apply()

        val serviceIntent = Intent(
            context,
            DoseAlarmService::class.java
        ).apply {
            action = DoseAlarmService.ACTION_RING
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_DOSE_PAYLOAD, payload)
        }

        try {
            DoseAlarmService.showAlarmNotification(
                context,
                alarmId,
                payload
            )
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Could not show alarm notification: id=$alarmId",
                error
            )
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }

            Log.i(
                TAG,
                "Alarm service start requested: id=$alarmId"
            )
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Could not start alarm service: id=$alarmId",
                error
            )
        }
    }
}
