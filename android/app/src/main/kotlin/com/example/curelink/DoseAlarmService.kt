package com.example.curelink

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.content.pm.ServiceInfo

class DoseAlarmService : Service() {
    private var player: MediaPlayer? = null
    private var activeAlarmId: Int = INVALID_ALARM_ID
    private val stopHandler = Handler(Looper.getMainLooper())
    private val stopAlarm = Runnable { stopSelf() }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            val requestedId = intent.getIntExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, INVALID_ALARM_ID)
            if (requestedId == INVALID_ALARM_ID || requestedId == activeAlarmId) stopSelf()
            return START_NOT_STICKY
        }

        activeAlarmId = intent?.getIntExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, INVALID_ALARM_ID)
            ?: INVALID_ALARM_ID
        startForegroundCompat(buildForegroundNotification())
        stopHandler.removeCallbacks(stopAlarm)
        startAlarmTone()
        stopHandler.postDelayed(stopAlarm, MAX_RING_DURATION_MS)
        return START_NOT_STICKY
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildForegroundNotification(): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Active medication alarm", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "Keeps the medication alarm playing until it is dismissed"
                    setSound(null, null)
                    enableVibration(false)
                },
            )
        }
        val openApp = PendingIntent.getActivity(
            this,
            NOTIFICATION_ID,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Medication alarm is ringing")
            .setContentText("Open CureLink to confirm or snooze this dose.")
            .setCategory(Notification.CATEGORY_ALARM)
            .setOngoing(true)
            .setContentIntent(openApp)
            .build()
    }

    private fun startAlarmTone() {
        stopPlayer()
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            ?: return
        try {
            player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(this@DoseAlarmService, alarmUri)
                isLooping = true
                setWakeMode(this@DoseAlarmService, PowerManager.PARTIAL_WAKE_LOCK)
                setOnPreparedListener { mediaPlayer ->
                    mediaPlayer.setVolume(1f, 1f)
                    mediaPlayer.start()
                }
                setOnErrorListener { _, _, _ -> stopSelf(); true }
                prepareAsync()
            }
        } catch (_: Exception) {
            stopSelf()
        }
    }

    private fun stopPlayer() {
        stopHandler.removeCallbacks(stopAlarm)
        player?.let { mediaPlayer ->
            try {
                if (mediaPlayer.isPlaying) mediaPlayer.stop()
            } catch (_: IllegalStateException) {
                // The system can interrupt playback while the device changes audio routes.
            }
            mediaPlayer.release()
        }
        player = null
    }

    override fun onDestroy() {
        stopPlayer()
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(NOTIFICATION_ID)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val ACTION_RING = "com.example.curelink.action.RING_DOSE_ALARM"
        const val ACTION_STOP = "com.example.curelink.action.STOP_DOSE_ALARM"
        const val INVALID_ALARM_ID = -1
        private const val CHANNEL_ID = "active_dose_alarm_v1"
        private const val NOTIFICATION_ID = 73104
        private const val MAX_RING_DURATION_MS = 2 * 60 * 1000L

        fun stopIfActive(context: Context, alarmId: Int) {
            val intent = Intent(context, DoseAlarmService::class.java)
                .setAction(ACTION_STOP)
                .putExtra(DoseAlarmReceiver.EXTRA_ALARM_ID, alarmId)
            context.startService(intent)
        }
    }
}
