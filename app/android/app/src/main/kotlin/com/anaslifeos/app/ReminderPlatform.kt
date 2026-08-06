package com.anaslifeos.app

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

internal class ReminderPlatform(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    private val context = activity.applicationContext
    private val scheduler = ReminderAlarmScheduler(context)
    private val eventStore = ReminderEventStore(context)

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "schedule" -> {
                    val record = ReminderRecord.fromJson(JSONObject(call.arguments as Map<*, *>))
                    ensurePermissions(record.flash)
                    scheduler.schedule(record)
                    result.success(null)
                }
                "cancel" -> {
                    scheduler.cancelReminder(call.argument<Int>("reminderId")!!)
                    result.success(null)
                }
                "canScheduleExact" -> result.success(scheduler.canScheduleExact())
                "drainEvents" -> result.success(eventStore.drain())
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("reminder_platform_failed", "The reminder operation failed safely.", error.javaClass.simpleName)
        }
    }

    private fun ensurePermissions(needsCamera: Boolean) {
        val missing = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
            ) add(Manifest.permission.POST_NOTIFICATIONS)
            if (needsCamera && activity.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                add(Manifest.permission.CAMERA)
            }
        }
        if (missing.isNotEmpty()) activity.requestPermissions(missing.toTypedArray(), PERMISSION_REQUEST)
    }

    companion object {
        private const val CHANNEL = "com.anaslifeos.app/reminders"
        private const val PERMISSION_REQUEST = 4104
    }
}

internal class ReminderAlarmScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(AlarmManager::class.java)
    private val store = ReminderStore(context)

    fun canScheduleExact(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()

    fun schedule(record: ReminderRecord) {
        store.save(record)
        scheduleAlarm(record)
    }

    fun cancelReminder(reminderId: Int) {
        store.recordsFor(reminderId).forEach { record ->
            alarmManager.cancel(pendingIntent(record))
            store.remove(record.occurrenceUuid)
        }
    }

    fun cancelChildren(parentOccurrenceUuid: String) {
        store.records().filter { it.parentOccurrenceUuid == parentOccurrenceUuid }.forEach { record ->
            alarmManager.cancel(pendingIntent(record))
            store.remove(record.occurrenceUuid)
        }
    }

    fun restoreAll() {
        val now = System.currentTimeMillis()
        store.records().forEach { record ->
            if (record.scheduledAtMillis > now) {
                scheduleAlarm(record)
            } else {
                store.remove(record.occurrenceUuid)
                ReminderEventStore(context).append(record, "ignored", now)
                record.nextOccurrence()?.let(::schedule)
            }
        }
    }

    private fun scheduleAlarm(record: ReminderRecord) {
        val operation = pendingIntent(record)
        if (record.exact && canScheduleExact()) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                record.scheduledAtMillis,
                operation,
            )
        } else {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                record.scheduledAtMillis,
                operation,
            )
        }
    }

    private fun pendingIntent(record: ReminderRecord): PendingIntent = PendingIntent.getBroadcast(
        context,
        record.occurrenceUuid.hashCode(),
        Intent(context, ReminderReceiver::class.java).apply {
            action = ACTION_TRIGGER
            putExtra(EXTRA_OCCURRENCE_UUID, record.occurrenceUuid)
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    companion object {
        const val ACTION_TRIGGER = "com.anaslifeos.app.action.REMINDER_TRIGGER"
        const val EXTRA_OCCURRENCE_UUID = "occurrence_uuid"
    }
}

internal class ReminderEventStore(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    @Synchronized
    fun append(record: ReminderRecord, action: String, occurredAtMillis: Long) {
        val event = JSONObject().apply {
            put("reminderId", record.reminderId)
            put("occurrenceUuid", record.occurrenceUuid)
            put("action", action)
            put("occurredAtMillis", occurredAtMillis)
        }
        val events = preferences.getStringSet(EVENTS, emptySet()).orEmpty().toMutableSet()
        events.add(event.toString())
        val bounded = events.sorted().takeLast(MAX_EVENTS).toSet()
        check(preferences.edit().putStringSet(EVENTS, bounded).commit())
    }

    @Synchronized
    fun drain(): List<Map<String, Any>> {
        val events = preferences.getStringSet(EVENTS, emptySet()).orEmpty()
            .mapNotNull { value -> runCatching { JSONObject(value) }.getOrNull() }
            .map { event ->
                mapOf(
                    "reminderId" to event.getInt("reminderId"),
                    "occurrenceUuid" to event.getString("occurrenceUuid"),
                    "action" to event.getString("action"),
                    "occurredAtMillis" to event.getLong("occurredAtMillis"),
                )
            }
        check(preferences.edit().remove(EVENTS).commit())
        return events
    }

    companion object {
        private const val PREFERENCES = "reminder_event_queue_v1"
        private const val EVENTS = "events"
        private const val MAX_EVENTS = 1000
    }
}
