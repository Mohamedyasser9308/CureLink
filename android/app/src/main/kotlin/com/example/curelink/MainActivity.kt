package com.example.curelink

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "curelink/alarm")
            .setMethodCallHandler { call, result ->
                val alarmId = call.argument<Int>("id")
                when (call.method) {
                    "schedule" -> {
                        if (alarmId == null) {
                            result.error("invalid_alarm", "Alarm ID is missing", null)
                            return@setMethodCallHandler
                        }
                        val atMillis = call.argument<Long>("atMillis")
                        if (atMillis == null) {
                            result.error("invalid_alarm", "Alarm time is missing", null)
                            return@setMethodCallHandler
                        }
                        val exact = call.argument<Boolean>("exact") ?: false
                        val intent = Intent(this, DoseAlarmReceiver::class.java)
                            .putExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, alarmId)
                        val pending = PendingIntent.getBroadcast(
                            this,
                            alarmId,
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                        )
                        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
                        try {
                            if (exact && (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms())) {
                                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
                            } else {
                                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
                            }
                            getSharedPreferences(DoseAlarmBootReceiver.PREFERENCES, MODE_PRIVATE)
                                .edit().putLong(DoseAlarmBootReceiver.keyFor(alarmId), atMillis).apply()
                            result.success(null)
                        } catch (error: SecurityException) {
                            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
                            getSharedPreferences(DoseAlarmBootReceiver.PREFERENCES, MODE_PRIVATE)
                                .edit().putLong(DoseAlarmBootReceiver.keyFor(alarmId), atMillis).apply()
                            result.success(null)
                        }
                    }
                    "cancel" -> {
                        if (alarmId == null) {
                            result.error("invalid_alarm", "Alarm ID is missing", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, DoseAlarmReceiver::class.java)
                        val pending = PendingIntent.getBroadcast(
                            this,
                            alarmId,
                            intent,
                            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
                        )
                        if (pending != null) {
                            (getSystemService(ALARM_SERVICE) as AlarmManager).cancel(pending)
                            pending.cancel()
                        }
                        getSharedPreferences(DoseAlarmBootReceiver.PREFERENCES, MODE_PRIVATE)
                            .edit().remove(DoseAlarmBootReceiver.keyFor(alarmId)).apply()
                        DoseAlarmService.stopIfActive(this, alarmId)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
