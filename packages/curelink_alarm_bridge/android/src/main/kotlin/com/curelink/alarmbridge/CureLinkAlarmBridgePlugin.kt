package com.curelink.alarmbridge

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.net.Uri
import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Registers CureLink's native alarm channel in every Flutter engine,
 * including WorkManager's headless engine. */
class CureLinkAlarmBridgePlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private lateinit var appContext: Context
    private var channel: MethodChannel? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "schedule" -> schedule(call, result)
            "cancel" -> cancel(call, result)
            "takeLaunchDosePayload" -> result.success(null)
            "getPermissionStatus" -> result.success(permissionStatus())
            "openPermissionSettings" -> openPermissionSettings(call, result)
            else -> result.notImplemented()
        }
    }

    private fun schedule(call: MethodCall, result: MethodChannel.Result) {
        val alarmId = call.argument<Int>("id")
        val atMillis = call.argument<Number>("atMillis")?.toLong()
        val payload = call.argument<String>("payload")
        if (alarmId == null || atMillis == null) {
            result.error("invalid_alarm", "Alarm ID or alarm time is missing", null)
            return
        }
        if (atMillis <= System.currentTimeMillis()) {
            result.error("invalid_alarm_time", "Alarm time must be in the future", null)
            return
        }

        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val receiverIntent = Intent().setClassName(
            appContext,
            "${appContext.packageName}.DoseAlarmReceiver",
        ).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_DOSE_PAYLOAD, payload)
        }
        val pending = PendingIntent.getBroadcast(
            appContext,
            alarmId,
            receiverIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val showIntent = Intent().setClassName(
            appContext,
            "${appContext.packageName}.MainActivity",
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val showApp = PendingIntent.getActivity(
            appContext,
            alarmId + 900000000,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
            } else {
                alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(atMillis, showApp), pending)
            }
            appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit()
                .putLong(keyFor(alarmId), atMillis)
                .putString(payloadKeyFor(alarmId), payload)
                .apply()
            result.success(null)
        } catch (error: Exception) {
            result.error("alarm_schedule_failed", error.message, null)
        }
    }

    private fun cancel(call: MethodCall, result: MethodChannel.Result) {
        val alarmId = call.argument<Int>("id")
        if (alarmId == null) {
            result.error("invalid_alarm", "Alarm ID is missing", null)
            return
        }

        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val receiverIntent = Intent().setClassName(
            appContext,
            "${appContext.packageName}.DoseAlarmReceiver",
        )
        val pending = PendingIntent.getBroadcast(
            appContext,
            alarmId,
            receiverIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        )
        if (pending != null) {
            alarmManager.cancel(pending)
            pending.cancel()
        }
        appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit()
            .remove(keyFor(alarmId))
            .remove(payloadKeyFor(alarmId))
            .apply()

        if (call.argument<Boolean>("stopRinging") == true) stopRingingIfActive(alarmId)
        result.success(null)
    }

    private fun stopRingingIfActive(alarmId: Int) {
        val preferences = appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        if (preferences.getInt(ACTIVE_ALARM_KEY, INVALID_ALARM_ID) != alarmId) return
        appContext.stopService(
            Intent().setClassName(appContext, "${appContext.packageName}.DoseAlarmService"),
        )
        preferences.edit()
            .remove(ACTIVE_ALARM_KEY)
            .remove(ACTIVE_DOSE_PAYLOAD_KEY)
            .apply()
        (appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(ACTIVE_NOTIFICATION_ID)
    }

    private fun permissionStatus(): Map<String, Any?> {
        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val notifications = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val powerManager = appContext.getSystemService(Context.POWER_SERVICE) as PowerManager
        val preferences = appContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val savedAlarms = preferences.all
            .filter { it.key.startsWith(KEY_PREFIX) && it.value is Long }
            .values.filterIsInstance<Long>()
            .filter { it > System.currentTimeMillis() }
            .sorted()
        val doseChannelEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notifications.getNotificationChannel("dose_alarms_v3")?.importance != NotificationManager.IMPORTANCE_NONE
        } else true
        val nativeChannelEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notifications.getNotificationChannel("active_dose_alarm_v2")?.importance != NotificationManager.IMPORTANCE_NONE
        } else true
        return mapOf(
            "notifications" to notifications.areNotificationsEnabled(),
            "doseChannel" to doseChannelEnabled,
            "nativeAlarmChannel" to nativeChannelEnabled,
            "exactAlarms" to (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()),
            "fullScreen" to (Build.VERSION.SDK_INT < 34 || notifications.canUseFullScreenIntent()),
            "batteryOptimizationIgnored" to powerManager.isIgnoringBatteryOptimizations(appContext.packageName),
            "scheduledAlarmCount" to savedAlarms.size,
            "nextAlarmMillis" to savedAlarms.firstOrNull(),
        )
    }

    private fun openPermissionSettings(call: MethodCall, result: MethodChannel.Result) {
        val kind = call.argument<String>("kind")
        val intent = when (kind) {
            "notifications" -> Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, appContext.packageName)
            "exactAlarms" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:${appContext.packageName}"))
            } else appSettingsIntent()
            "fullScreen" -> if (Build.VERSION.SDK_INT >= 34) {
                Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, Uri.parse("package:${appContext.packageName}"))
            } else appSettingsIntent()
            "battery" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:${appContext.packageName}"))
            } else appSettingsIntent()
            "doseChannel", "nativeAlarmChannel" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, appContext.packageName)
                    .putExtra(Settings.EXTRA_CHANNEL_ID, if (kind == "nativeAlarmChannel") "active_dose_alarm_v2" else "dose_alarms_v3")
            } else Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            else -> {
                result.error("invalid_permission", "Unknown permission setting", null)
                return
            }
        }.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("activity_unavailable", "Permission settings can only be opened from the app UI.", intent.action)
            return
        }
        try {
            currentActivity.startActivity(intent)
            result.success(null)
        } catch (error: Exception) {
            result.error("settings_error", error.message, null)
        }
    }

    private fun appSettingsIntent() = Intent(
        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
        Uri.parse("package:${appContext.packageName}"),
    )

    private fun keyFor(id: Int) = "$KEY_PREFIX$id"
    private fun payloadKeyFor(id: Int) = "$PAYLOAD_PREFIX$id"

    companion object {
        private const val CHANNEL_NAME = "curelink/alarm"
        private const val PREFERENCES = "curelink_dose_alarm_schedule"
        private const val KEY_PREFIX = "alarm_"
        private const val PAYLOAD_PREFIX = "payload_"
        private const val ACTIVE_ALARM_KEY = "active_alarm_id"
        private const val ACTIVE_DOSE_PAYLOAD_KEY = "active_dose_payload"
        private const val INVALID_ALARM_ID = -1
        private const val ACTIVE_NOTIFICATION_ID = 73104
        private const val EXTRA_ALARM_ID = "dose_alarm_id"
        private const val EXTRA_DOSE_PAYLOAD = "dose_payload"
    }
}
