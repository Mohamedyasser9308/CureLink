
package com.example.curelink

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration

class DoseAlarmService : Service() {

    private var player: MediaPlayer? = null
    private var activeAlarmId: Int = INVALID_ALARM_ID
    private var activeDosePayload: String? = null
    private var doseStatusListener: ListenerRegistration? = null

    companion object {
        const val ACTION_RING =
            "com.example.curelink.action.RING_DOSE_ALARM"

        const val ACTION_STOP =
            "com.example.curelink.action.STOP_DOSE_ALARM"

        const val INVALID_ALARM_ID = -1
        const val NOTIFICATION_ID = 73104

        private const val ACTIVE_ALARM_KEY = "active_alarm_id"
        private const val CHANNEL_ID = "active_dose_alarm_v2"
        private const val TAG = "CureLinkDoseAlarm"

        fun showAlarmNotification(
            context: Context,
            alarmId: Int,
            payload: String?
        ) {
            val manager = context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

            manager.notify(
                NOTIFICATION_ID,
                buildAlarmNotification(context, alarmId, payload)
            )
        }

        private fun buildAlarmNotification(
            context: Context,
            alarmId: Int,
            payload: String?
        ): Notification {
            val manager = context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Medication alarm",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description =
                        "Shows active medication alarms"

                    // The foreground service plays the alarm sound itself.
                    setSound(null, null)
                    enableVibration(false)
                    lockscreenVisibility =
                        Notification.VISIBILITY_PUBLIC
                }

                manager.createNotificationChannel(channel)
            }

            val openIntent = Intent(
                context,
                MainActivity::class.java
            ).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                )
                putExtra(
                    DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD,
                    payload
                )
            }

            val openApp = PendingIntent.getActivity(
                context,
                NOTIFICATION_ID,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

            val markTakenIntent = Intent(
                context,
                DoseTakenActionReceiver::class.java
            ).apply {
                action =
                    DoseTakenActionReceiver.ACTION_MARK_TAKEN

                putExtra(
                    DoseAlarmReceiver.EXTRA_ALARM_ID,
                    alarmId
                )

                putExtra(
                    DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD,
                    payload
                )
            }

            val markTaken = PendingIntent.getBroadcast(
                context,
                NOTIFICATION_ID + 1,
                markTakenIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

            val builder = if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
            ) {
                Notification.Builder(context, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }

            return builder
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("Medication reminder")
                .setContentText("Tap Taken to confirm this dose.")
                .setCategory(Notification.CATEGORY_ALARM)
                .setPriority(Notification.PRIORITY_MAX)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
                .setOngoing(true)
                .setContentIntent(openApp)
                .setFullScreenIntent(openApp, true)
                .addAction(
                    android.R.drawable.checkbox_on_background,
                    "Taken",
                    markTaken
                )
                .build()
        }

        fun stopIfActive(
            context: Context,
            alarmId: Int
        ) {
            val preferences = context.getSharedPreferences(
                DoseAlarmBootReceiver.PREFERENCES,
                Context.MODE_PRIVATE
            )

            if (
                preferences.getInt(
                    ACTIVE_ALARM_KEY,
                    INVALID_ALARM_ID
                ) != alarmId
            ) {
                return
            }

            context.stopService(
                Intent(context, DoseAlarmService::class.java)
            )

            preferences.edit()
                .remove(ACTIVE_ALARM_KEY)
                .apply()

            val manager = context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

            manager.cancel(NOTIFICATION_ID)
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "DoseAlarmService created")
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        if (intent?.action == ACTION_STOP) {
            val requestedId = intent.getIntExtra(
                DoseAlarmReceiver.EXTRA_ALARM_ID,
                INVALID_ALARM_ID
            )

            if (
                requestedId == INVALID_ALARM_ID ||
                requestedId == activeAlarmId
            ) {
                stopSelf()
            }

            return START_NOT_STICKY
        }

        activeAlarmId = intent?.getIntExtra(
            DoseAlarmReceiver.EXTRA_ALARM_ID,
            INVALID_ALARM_ID
        ) ?: INVALID_ALARM_ID

        activeDosePayload = intent?.getStringExtra(
            DoseAlarmReceiver.EXTRA_DOSE_PAYLOAD
        )

        Log.i(
            TAG,
            "Starting alarm service: id=$activeAlarmId"
        )

        getSharedPreferences(
            DoseAlarmBootReceiver.PREFERENCES,
            MODE_PRIVATE
        ).edit()
            .putInt(ACTIVE_ALARM_KEY, activeAlarmId)
            .apply()

        try {
            startForegroundCompat(
                buildForegroundNotification()
            )
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Could not start foreground notification",
                error
            )
            stopSelf()
            return START_NOT_STICKY
        }

        watchDoseConfirmation(activeDosePayload)
        startAlarmTone()

        return START_NOT_STICKY
    }

    private fun startForegroundCompat(
        notification: Notification
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(
                NOTIFICATION_ID,
                notification
            )
        }
    }

    private fun buildForegroundNotification(): Notification {
        return buildAlarmNotification(
            this,
            activeAlarmId,
            activeDosePayload
        )
    }

    private fun watchDoseConfirmation(payload: String?) {
        doseStatusListener?.remove()
        doseStatusListener = null

        if (payload.isNullOrBlank()) return

        val parts = payload.split('|')

        if (parts.size != 2) {
            Log.w(TAG, "Invalid dose payload")
            return
        }

        try {
            doseStatusListener = FirebaseFirestore.getInstance()
                .collection("users")
                .document(parts[0])
                .collection("doses")
                .document(parts[1])
                .addSnapshotListener { snapshot, error ->

                    if (error != null) {
                        Log.w(
                            TAG,
                            "Could not watch dose confirmation",
                            error
                        )
                        return@addSnapshotListener
                    }

                    val status = snapshot?.getString("status")

                    if (status == "taken") {
                        Log.i(
                            TAG,
                            "Dose marked taken; stopping alarm"
                        )
                        stopSelf()
                    }
                }
        } catch (error: Exception) {
            Log.e(
                TAG,
                "Could not start dose confirmation listener",
                error
            )
        }
    }

    private fun startAlarmTone() {
        val alarmUri = RingtoneManager.getDefaultUri(
            RingtoneManager.TYPE_ALARM
        )

        val notificationUri = RingtoneManager.getDefaultUri(
            RingtoneManager.TYPE_NOTIFICATION
        )

        playAlarmTone(
            alarmUri ?: notificationUri,
            notificationUri?.takeIf {
                alarmUri != null && it != alarmUri
            }
        )
    }

    private fun playAlarmTone(
        uri: Uri?,
        fallbackUri: Uri?
    ) {
        stopPlayer()

        if (uri == null) {
            Log.e(TAG, "No alarm or notification sound URI available")
            return
        }

        try {
            player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(
                            AudioAttributes.CONTENT_TYPE_SONIFICATION
                        )
                        .build()
                )

                setDataSource(this@DoseAlarmService, uri)
                isLooping = true

                setWakeMode(
                    this@DoseAlarmService,
                    PowerManager.PARTIAL_WAKE_LOCK
                )

                setOnPreparedListener { mediaPlayer ->
                    try {
                        mediaPlayer.setVolume(1f, 1f)
                        mediaPlayer.start()
                        Log.i(TAG, "Alarm sound started")
                    } catch (error: Exception) {
                        Log.e(TAG, "Could not start alarm playback", error)
                    }
                }

                setOnErrorListener { _, what, extra ->
                    Log.e(
                        TAG,
                        "Alarm playback failed: what=$what extra=$extra"
                    )

                    if (fallbackUri != null) {
                        playAlarmTone(fallbackUri, null)
                    }

                    true
                }

                prepareAsync()
            }
        } catch (error: Exception) {
            Log.e(TAG, "Could not prepare alarm playback", error)

            if (fallbackUri != null) {
                playAlarmTone(fallbackUri, null)
            }
        }
    }

    private fun stopPlayer() {
        val currentPlayer = player
        player = null

        if (currentPlayer != null) {
            try {
                currentPlayer.setOnPreparedListener(null)
                currentPlayer.setOnErrorListener(null)

                if (currentPlayer.isPlaying) {
                    currentPlayer.stop()
                }
            } catch (_: Exception) {
                // The player may already have stopped.
            } finally {
                try {
                    currentPlayer.release()
                } catch (_: Exception) {
                    // Nothing else to release.
                }
            }
        }
    }

    override fun onDestroy() {
        Log.i(TAG, "DoseAlarmService destroyed")

        doseStatusListener?.remove()
        doseStatusListener = null

        stopPlayer()

        val preferences = getSharedPreferences(
            DoseAlarmBootReceiver.PREFERENCES,
            MODE_PRIVATE
        )

        if (
            preferences.getInt(
                ACTIVE_ALARM_KEY,
                INVALID_ALARM_ID
            ) == activeAlarmId
        ) {
            preferences.edit()
                .remove(ACTIVE_ALARM_KEY)
                .apply()
        }

        val manager = getSystemService(
            Context.NOTIFICATION_SERVICE
        ) as NotificationManager

        manager.cancel(NOTIFICATION_ID)

        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
