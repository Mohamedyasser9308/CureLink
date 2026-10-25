
package com.example.curelink

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var alarmChannel: MethodChannel? = null

    companion object {
        private const val TAG = "CureLinkDoseAlarm"
        private const val CHANNEL_NAME = "curelink/alarm"
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val payload = intent.getStringExtra(
            DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD
        )

        if (!payload.isNullOrBlank()) {
            alarmChannel?.invokeMethod("doseAlarmOpened", payload)
        }
    }

    override fun onResume() {
        super.onResume()
        restoreDoseAlarms()
    }

    private fun createAlarmPendingIntent(
        alarmId: Int,
        payload: String?
    ): PendingIntent {
        val receiverIntent = Intent(
            this,
            DoseAlarmReceiver::class.java
        ).apply {
            putExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD, payload)
        }

        return PendingIntent.getBroadcast(
            this,
            alarmId,
            receiverIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun createShowAppPendingIntent(
        alarmId: Int
    ): PendingIntent {
        val showIntent = Intent(
            this,
            MainActivity::class.java
        ).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
        }

        return PendingIntent.getActivity(
            this,
            alarmId + 900000000,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun registerAlarm(
        alarmManager: AlarmManager,
        alarmId: Int,
        atMillis: Long,
        payload: String?
    ): Boolean {
        if (atMillis <= System.currentTimeMillis()) {
            Log.w(TAG, "Skipping expired alarm ID=$alarmId")
            return false
        }

        val pending = createAlarmPendingIntent(alarmId, payload)
        val showApp = createShowAppPendingIntent(alarmId)

        return try {
            if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                Log.w(
                    TAG,
                    "Exact-alarm permission denied; using inexact fallback for ID=$alarmId"
                )

                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    atMillis,
                    pending
                )
            } else {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(atMillis, showApp),
                    pending
                )
            }

            Log.i(
                TAG,
                "Alarm registered: id=$alarmId at=$atMillis"
            )
            true
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Could not register alarm ID=$alarmId",
                error
            )
            false
        }
    }

    private fun restoreDoseAlarms() {
        val alarmManager =
            getSystemService(ALARM_SERVICE) as AlarmManager

        val preferences = getSharedPreferences(
            DoseAlarmBootReceiver.PREFERENCES,
            MODE_PRIVATE
        )

        for ((key, value) in preferences.all) {
            if (!key.startsWith("alarm_") || value !is Long) {
                continue
            }

            val alarmId = key
                .removePrefix("alarm_")
                .toIntOrNull() ?: continue

            val payload = preferences.getString(
                DoseAlarmBootReceiver.payloadKeyFor(alarmId),
                null
            )

            registerAlarm(
                alarmManager = alarmManager,
                alarmId = alarmId,
                atMillis = value,
                payload = payload
            )
        }
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )

        alarmChannel = channel

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "takeLaunchDosePayload" -> {
                    val payload = intent.getStringExtra(
                        DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD
                    )

                    intent.removeExtra(
                        DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD
                    )

                    result.success(payload)
                }

                "getPermissionStatus" -> {
                    val alarmManager =
                        getSystemService(ALARM_SERVICE) as AlarmManager

                    val notificationManager =
                        getSystemService(NOTIFICATION_SERVICE) as NotificationManager

                    val powerManager =
                        getSystemService(POWER_SERVICE) as PowerManager

                    val preferences = getSharedPreferences(
                        DoseAlarmBootReceiver.PREFERENCES,
                        MODE_PRIVATE
                    )

                    val savedAlarms = preferences.all
                        .filter {
                            it.key.startsWith("alarm_") &&
                                it.value is Long
                        }
                        .values
                        .mapNotNull { it as? Long }
                        .filter { it > System.currentTimeMillis() }
                        .sorted()

                    val doseChannelEnabled =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            notificationManager
                                .getNotificationChannel("dose_alarms_v3")
                                ?.importance != NotificationManager.IMPORTANCE_NONE
                        } else {
                            true
                        }

                    val nativeAlarmChannelEnabled =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            notificationManager
                                .getNotificationChannel("active_dose_alarm_v2")
                                ?.importance != NotificationManager.IMPORTANCE_NONE
                        } else {
                            true
                        }

                    val exactAlarmsAllowed =
                        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                            alarmManager.canScheduleExactAlarms()

                    val fullScreenAllowed =
                        Build.VERSION.SDK_INT < 34 ||
                            notificationManager.canUseFullScreenIntent()

                    result.success(
                        mapOf(
                            "notifications" to notificationManager.areNotificationsEnabled(),
                            "doseChannel" to doseChannelEnabled,
                            "nativeAlarmChannel" to nativeAlarmChannelEnabled,
                            "exactAlarms" to exactAlarmsAllowed,
                            "fullScreen" to fullScreenAllowed,
                            "batteryOptimizationIgnored" to
                                powerManager.isIgnoringBatteryOptimizations(packageName),
                            "scheduledAlarmCount" to savedAlarms.size,
                            "nextAlarmMillis" to savedAlarms.firstOrNull()
                        )
                    )
                }

                "openPermissionSettings" -> {
                    val kind = call.argument<String>("kind")

                    val settingsIntent = when (kind) {

                        "notifications" ->
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(
                                    Settings.EXTRA_APP_PACKAGE,
                                    packageName
                                )

                        "exactAlarms" ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                Intent(
                                    Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                                    Uri.parse("package:$packageName")
                                )
                            } else {
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName")
                                )
                            }

                        "fullScreen" ->
                            if (Build.VERSION.SDK_INT >= 34) {
                                Intent(
                                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                                    Uri.parse("package:$packageName")
                                )
                            } else {
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName")
                                )
                            }

                        "battery" ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName")
                                )
                            } else {
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName")
                                )
                            }

                        "doseChannel", "nativeAlarmChannel" ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                Intent(
                                    Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS
                                ).apply {
                                    putExtra(
                                        Settings.EXTRA_APP_PACKAGE,
                                        packageName
                                    )
                                    putExtra(
                                        Settings.EXTRA_CHANNEL_ID,
                                        if (kind == "nativeAlarmChannel") {
                                            "active_dose_alarm_v2"
                                        } else {
                                            "dose_alarms_v3"
                                        }
                                    )
                                }
                            } else {
                                Intent(
                                    Settings.ACTION_APP_NOTIFICATION_SETTINGS
                                )
                            }

                        else -> {
                            result.error(
                                "invalid_permission",
                                "Unknown permission setting",
                                null
                            )
                            return@setMethodCallHandler
                        }
                    }.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                    try {
                        startActivity(settingsIntent)
                        result.success(null)
                    } catch (error: Exception) {
                        Log.e(
                            TAG,
                            "Could not open permission settings: $kind",
                            error
                        )

                        try {
                            startActivity(
                                Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:$packageName")
                                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            )
                            result.success(null)
                        } catch (fallbackError: Exception) {
                            result.error(
                                "settings_error",
                                fallbackError.message,
                                null
                            )
                        }
                    }
                }

                "schedule" -> {
                    val alarmId = call.argument<Int>("id")
                    val atMillis = call.argument<Number>("atMillis")?.toLong()
                    val payload = call.argument<String>("payload")

                    if (alarmId == null || atMillis == null) {
                        result.error(
                            "invalid_alarm",
                            "Alarm ID or alarm time is missing",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    if (atMillis <= System.currentTimeMillis()) {
                        result.error(
                            "invalid_alarm_time",
                            "Alarm time must be in the future",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val alarmManager =
                        getSystemService(ALARM_SERVICE) as AlarmManager

                    val scheduled = registerAlarm(
                        alarmManager = alarmManager,
                        alarmId = alarmId,
                        atMillis = atMillis,
                        payload = payload
                    )

                    if (!scheduled) {
                        result.error(
                            "alarm_schedule_failed",
                            "Android could not register this alarm. Check alarm permissions and logs.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    getSharedPreferences(
                        DoseAlarmBootReceiver.PREFERENCES,
                        MODE_PRIVATE
                    ).edit()
                        .putLong(
                            DoseAlarmBootReceiver.keyFor(alarmId),
                            atMillis
                        )
                        .putString(
                            DoseAlarmBootReceiver.payloadKeyFor(alarmId),
                            payload
                        )
                        .apply()

                    result.success(null)
                }

                "cancel" -> {
                    val alarmId = call.argument<Int>("id")

                    if (alarmId == null) {
                        result.error(
                            "invalid_alarm",
                            "Alarm ID is missing",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val pending = PendingIntent.getBroadcast(
                        this,
                        alarmId,
                        Intent(this, DoseAlarmReceiver::class.java),
                        PendingIntent.FLAG_NO_CREATE or
                            PendingIntent.FLAG_IMMUTABLE
                    )

                    if (pending != null) {
                        val alarmManager =
                            getSystemService(ALARM_SERVICE) as AlarmManager

                        alarmManager.cancel(pending)
                        pending.cancel()
                    }

                    getSharedPreferences(
                        DoseAlarmBootReceiver.PREFERENCES,
                        MODE_PRIVATE
                    ).edit()
                        .remove(DoseAlarmBootReceiver.keyFor(alarmId))
                        .remove(DoseAlarmBootReceiver.payloadKeyFor(alarmId))
                        .apply()

                    if (call.argument<Boolean>("stopRinging") == true) {
                        DoseAlarmService.stopIfActive(this, alarmId)
                    }

                    Log.i(TAG, "Alarm cancelled: id=$alarmId")
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
