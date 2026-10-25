package com.example.curelink

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.firebase.Timestamp
import com.google.firebase.firestore.FirebaseFirestore
import org.json.JSONArray
import java.util.concurrent.atomic.AtomicBoolean

class DoseTakenActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_MARK_TAKEN) return
        val payload = intent.getStringExtra(DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD)
        val parts = payload?.split('|')
        val alarmId = intent.getIntExtra(
            DoseAlarmReceiver.EXTRA_ALARM_ID,
            DoseAlarmService.INVALID_ALARM_ID,
        )

        DoseAlarmService.stopIfActive(context, alarmId)
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager)
            .cancel(DoseAlarmService.NOTIFICATION_ID)

        if (parts == null || parts.size != 2) {
            cancelFlutterDoseNotifications(context, payload.orEmpty())
            return
        }
        cancelFlutterDoseNotifications(context, parts[1])

        val pendingResult = goAsync()
        val finished = AtomicBoolean(false)
        val finish = Runnable {
            if (finished.compareAndSet(false, true)) pendingResult.finish()
        }
        Handler(Looper.getMainLooper()).postDelayed(finish, BROADCAST_TIMEOUT_MS)

        try {
            val now = Timestamp.now()
            FirebaseFirestore.getInstance()
                .collection("users").document(parts[0])
                .collection("doses").document(parts[1])
                .update(
                    mapOf(
                        "status" to "taken",
                        "takenAt" to now,
                        "snoozedUntil" to null,
                        "updatedAt" to now,
                    ),
                )
                .addOnCompleteListener { task ->
                    if (!task.isSuccessful) {
                        Log.e(TAG, "Could not save Taken action", task.exception)
                    }
                    finish.run()
                }
        } catch (error: Exception) {
            Log.e(TAG, "Could not start Taken action update", error)
            finish.run()
        }
    }

    private fun cancelFlutterDoseNotifications(context: Context, doseId: String) {
        val notificationIds = listOf(
            stableNotificationId("$doseId:due"),
            stableNotificationId("$doseId:late"),
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as android.app.NotificationManager
        for (notificationId in notificationIds) {
            val receiverIntent = Intent().setClassName(
                context,
                "com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver",
            )
            val pendingIntent = android.app.PendingIntent.getBroadcast(
                context,
                notificationId,
                receiverIntent,
                android.app.PendingIntent.FLAG_NO_CREATE or android.app.PendingIntent.FLAG_IMMUTABLE,
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
            notificationManager.cancel(notificationId)
        }
        removeFlutterNotificationCacheEntries(context, notificationIds.toSet())
    }

    private fun removeFlutterNotificationCacheEntries(context: Context, ids: Set<Int>) {
        try {
            val preferences = context.getSharedPreferences(
                FLUTTER_NOTIFICATION_CACHE,
                Context.MODE_PRIVATE,
            )
            val json = preferences.getString(FLUTTER_NOTIFICATION_CACHE, null) ?: return
            val stored = JSONArray(json)
            val kept = JSONArray()
            for (index in 0 until stored.length()) {
                val notification = stored.optJSONObject(index) ?: continue
                if (!ids.contains(notification.optInt("id"))) kept.put(notification)
            }
            preferences.edit().putString(FLUTTER_NOTIFICATION_CACHE, kept.toString()).apply()
        } catch (error: Exception) {
            Log.w(TAG, "Could not clean old scheduled notifications", error)
        }
    }

    private fun stableNotificationId(value: String): Int {
        var hash = 0x811c9dc5L
        for (unit in value) {
            hash = ((hash xor unit.code.toLong()) * 0x01000193L) and 0x7fffffffL
        }
        return 0x10000000 or (hash.toInt() and 0x6fffffff)
    }

    companion object {
        const val ACTION_MARK_TAKEN = "com.example.curelink.action.MARK_DOSE_TAKEN"
        private const val TAG = "CureLinkTakenAction"
        private const val FLUTTER_NOTIFICATION_CACHE = "scheduled_notifications"
        private const val BROADCAST_TIMEOUT_MS = 8000L
    }
}
