package com.anaslifeos.app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.hardware.camera2.CameraManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONObject
import java.util.Locale

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val occurrenceUuid = intent.getStringExtra(ReminderAlarmScheduler.EXTRA_OCCURRENCE_UUID) ?: return
        val store = ReminderStore(context)
        val record = store.find(occurrenceUuid) ?: return
        store.remove(occurrenceUuid)
        val now = System.currentTimeMillis()
        ReminderEventStore(context).append(record, "triggered", now)
        record.nextOccurrence()?.let { ReminderAlarmScheduler(context).schedule(it) }
        if (record.autoSnooze) {
            record.snoozed(now)?.let { ReminderAlarmScheduler(context).schedule(it) }
        }
        ReminderNotificationPresenter(context).show(record)
    }
}

class ReminderActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val recordJson = intent.getStringExtra(EXTRA_RECORD) ?: return
        val record = runCatching { ReminderRecord.fromJson(JSONObject(recordJson)) }.getOrNull() ?: return
        val scheduler = ReminderAlarmScheduler(context)
        scheduler.cancelChildren(record.occurrenceUuid)
        val now = System.currentTimeMillis()
        when (intent.action) {
            ACTION_SNOOZE -> {
                record.snoozed(now)?.let(scheduler::schedule)
                ReminderEventStore(context).append(record, "snoozed", now)
            }
            ACTION_COMPLETE -> ReminderEventStore(context).append(record, "completed", now)
            else -> ReminderEventStore(context).append(record, "dismissed", now)
        }
        NotificationManagerCompat.from(context).cancel(record.reminderId)
    }

    companion object {
        const val ACTION_SNOOZE = "com.anaslifeos.app.action.REMINDER_SNOOZE"
        const val ACTION_DISMISS = "com.anaslifeos.app.action.REMINDER_DISMISS"
        const val ACTION_COMPLETE = "com.anaslifeos.app.action.REMINDER_COMPLETE"
        const val EXTRA_RECORD = "reminder_record"
    }
}

class ReminderRestoreReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action in SUPPORTED_ACTIONS) {
            ReminderAlarmScheduler(context).restoreAll()
        }
    }

    companion object {
        private val SUPPORTED_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
        )
    }
}

private class ReminderNotificationPresenter(private val context: Context) {
    private val notificationManager = context.getSystemService(NotificationManager::class.java)

    fun show(record: ReminderRecord) {
        createChannels()
        val channel = if (record.priority in setOf("high", "critical")) CHANNEL_HIGH else CHANNEL_NORMAL
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val launchPending = launchIntent?.let {
            PendingIntent.getActivity(
                context,
                record.reminderId,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val notification = NotificationCompat.Builder(context, channel)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(context.getString(R.string.reminder_notification_title))
            .setContentText(context.getString(R.string.reminder_notification_body))
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setPriority(priority(record.priority))
            .setAutoCancel(true)
            .setOnlyAlertOnce(false)
            .setContentIntent(launchPending)
            .setDeleteIntent(actionIntent(record, ReminderActionReceiver.ACTION_DISMISS, 1))
            .addAction(
                android.R.drawable.ic_lock_idle_alarm,
                context.getString(R.string.reminder_action_snooze),
                actionIntent(record, ReminderActionReceiver.ACTION_SNOOZE, 2),
            )
            .addAction(
                android.R.drawable.checkbox_on_background,
                context.getString(R.string.reminder_action_complete),
                actionIntent(record, ReminderActionReceiver.ACTION_COMPLETE, 3),
            )
            .apply {
                if (record.vibration) setVibrate(longArrayOf(0, 250, 150, 250))
                if (record.fullScreen && launchPending != null) setFullScreenIntent(launchPending, true)
            }
            .build()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        ) {
            notificationManager.notify(record.reminderId, notification)
        }
        if (record.voice) speak()
        if (record.flash) flash()
    }

    private fun actionIntent(record: ReminderRecord, action: String, discriminator: Int): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            record.occurrenceUuid.hashCode() xor discriminator,
            Intent(context, ReminderActionReceiver::class.java).apply {
                this.action = action
                putExtra(ReminderActionReceiver.EXTRA_RECORD, record.toJson().toString())
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    private fun createChannels() {
        notificationManager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_NORMAL,
                context.getString(R.string.reminder_channel_normal),
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = context.getString(R.string.reminder_channel_normal_description) },
        )
        notificationManager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_HIGH,
                context.getString(R.string.reminder_channel_urgent),
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = context.getString(R.string.reminder_channel_urgent_description)
                enableLights(true)
                lightColor = Color.WHITE
                enableVibration(true)
            },
        )
    }

    private fun speak() {
        var engine: TextToSpeech? = null
        engine = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                engine?.language = Locale.getDefault()
                engine?.speak(
                    context.getString(R.string.reminder_voice_message),
                    TextToSpeech.QUEUE_FLUSH,
                    null,
                    "anas_life_os_reminder",
                )
            }
            Handler(Looper.getMainLooper()).postDelayed({ engine?.shutdown() }, 5_000L)
        }
    }

    private fun flash() {
        if (context.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) return
        val cameraManager = context.getSystemService(CameraManager::class.java)
        val cameraId = runCatching {
            cameraManager.cameraIdList.firstOrNull { id ->
                cameraManager.getCameraCharacteristics(id)
                    .get(android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            }
        }.getOrNull() ?: return
        runCatching {
            cameraManager.setTorchMode(cameraId, true)
            Handler(Looper.getMainLooper()).postDelayed(
                { runCatching { cameraManager.setTorchMode(cameraId, false) } },
                750L,
            )
        }
    }

    private fun priority(value: String): Int = when (value) {
        "critical" -> NotificationCompat.PRIORITY_MAX
        "high" -> NotificationCompat.PRIORITY_HIGH
        "low" -> NotificationCompat.PRIORITY_LOW
        else -> NotificationCompat.PRIORITY_DEFAULT
    }

    companion object {
        private const val CHANNEL_NORMAL = "reminders_normal_v1"
        private const val CHANNEL_HIGH = "reminders_urgent_v1"
    }
}
