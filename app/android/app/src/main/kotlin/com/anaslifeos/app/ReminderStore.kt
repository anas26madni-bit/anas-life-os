package com.anaslifeos.app

import android.content.Context
import org.json.JSONObject
import java.time.Instant
import java.time.YearMonth
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.UUID

internal data class ReminderRecord(
    val reminderId: Int,
    val occurrenceUuid: String,
    val scheduledAtMillis: Long,
    val exact: Boolean,
    val vibration: Boolean,
    val flash: Boolean,
    val voice: Boolean,
    val fullScreen: Boolean,
    val priority: String,
    val frequency: String,
    val interval: Int,
    val weekdayMask: Int,
    val dayOfMonth: Int?,
    val monthOfYear: Int?,
    val timezoneId: String,
    val endType: String,
    val endAtMillis: Long?,
    val occurrenceLimit: Int?,
    val occurrenceCount: Int,
    val snoozeMinutes: Int,
    val maxSnoozes: Int,
    val snoozeCount: Int,
    val autoSnooze: Boolean,
    val escalationStep: Int,
    val parentOccurrenceUuid: String?,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("reminderId", reminderId)
        put("occurrenceUuid", occurrenceUuid)
        put("scheduledAtMillis", scheduledAtMillis)
        put("exact", exact)
        put("vibration", vibration)
        put("flash", flash)
        put("voice", voice)
        put("fullScreen", fullScreen)
        put("priority", priority)
        put("frequency", frequency)
        put("interval", interval)
        put("weekdayMask", weekdayMask)
        put("dayOfMonth", dayOfMonth)
        put("monthOfYear", monthOfYear)
        put("timezoneId", timezoneId)
        put("endType", endType)
        put("endAtMillis", endAtMillis)
        put("occurrenceLimit", occurrenceLimit)
        put("occurrenceCount", occurrenceCount)
        put("snoozeMinutes", snoozeMinutes)
        put("maxSnoozes", maxSnoozes)
        put("snoozeCount", snoozeCount)
        put("autoSnooze", autoSnooze)
        put("escalationStep", escalationStep)
        put("parentOccurrenceUuid", parentOccurrenceUuid)
    }

    fun nextOccurrence(): ReminderRecord? {
        if (frequency == "none") return null
        if (endType == "afterOccurrences" &&
            occurrenceLimit != null &&
            occurrenceCount >= occurrenceLimit
        ) {
            return null
        }
        val zone = runCatching { ZoneId.of(timezoneId) }.getOrDefault(ZoneId.systemDefault())
        val current = Instant.ofEpochMilli(scheduledAtMillis).atZone(zone)
        val next = when (frequency) {
            "daily", "custom" -> current.plusDays(interval.toLong())
            "weekly" -> nextWeekly(current)
            "monthly" -> nextMonthly(current)
            "yearly" -> nextYearly(current)
            else -> return null
        }
        val nextMillis = next.toInstant().toEpochMilli()
        if (endType == "onDate" && endAtMillis != null && nextMillis > endAtMillis) {
            return null
        }
        return copy(
            occurrenceUuid = UUID.randomUUID().toString(),
            scheduledAtMillis = nextMillis,
            occurrenceCount = occurrenceCount + 1,
            snoozeCount = 0,
            parentOccurrenceUuid = null,
        )
    }

    fun snoozed(nowMillis: Long): ReminderRecord? {
        if (snoozeCount >= maxSnoozes) return null
        return copy(
            occurrenceUuid = UUID.randomUUID().toString(),
            scheduledAtMillis = nowMillis + snoozeMinutes * 60_000L,
            frequency = "none",
            occurrenceCount = 1,
            snoozeCount = snoozeCount + 1,
            autoSnooze = false,
            parentOccurrenceUuid = occurrenceUuid,
        )
    }

    private fun nextWeekly(current: ZonedDateTime): ZonedDateTime {
        if (weekdayMask == 0) return current.plusWeeks(interval.toLong())
        for (days in 1..(7 * interval)) {
            val candidate = current.plusDays(days.toLong())
            val bit = 1 shl (candidate.dayOfWeek.value - 1)
            if (weekdayMask and bit != 0) return candidate
        }
        return current.plusWeeks(interval.toLong())
    }

    private fun nextMonthly(current: ZonedDateTime): ZonedDateTime {
        val month = YearMonth.from(current).plusMonths(interval.toLong())
        val day = (dayOfMonth ?: current.dayOfMonth).coerceAtMost(month.lengthOfMonth())
        return current.withYear(month.year).withMonth(month.monthValue).withDayOfMonth(day)
    }

    private fun nextYearly(current: ZonedDateTime): ZonedDateTime {
        val year = current.year + interval
        val month = monthOfYear ?: current.monthValue
        val maxDay = YearMonth.of(year, month).lengthOfMonth()
        val day = (dayOfMonth ?: current.dayOfMonth).coerceAtMost(maxDay)
        return current.withYear(year).withMonth(month).withDayOfMonth(day)
    }

    companion object {
        fun fromJson(value: JSONObject): ReminderRecord = ReminderRecord(
            reminderId = value.getInt("reminderId"),
            occurrenceUuid = value.getString("occurrenceUuid"),
            scheduledAtMillis = value.getLong("scheduledAtMillis"),
            exact = value.optBoolean("exact"),
            vibration = value.optBoolean("vibration", true),
            flash = value.optBoolean("flash"),
            voice = value.optBoolean("voice"),
            fullScreen = value.optBoolean("fullScreen"),
            priority = value.optString("priority", "normal"),
            frequency = value.optString("frequency", "none"),
            interval = value.optInt("interval", 1).coerceAtLeast(1),
            weekdayMask = value.optInt("weekdayMask"),
            dayOfMonth = value.optionalInt("dayOfMonth"),
            monthOfYear = value.optionalInt("monthOfYear"),
            timezoneId = value.optString("timezoneId", ZoneId.systemDefault().id),
            endType = value.optString("endType", "never"),
            endAtMillis = value.optionalLong("endAtMillis"),
            occurrenceLimit = value.optionalInt("occurrenceLimit"),
            occurrenceCount = value.optInt("occurrenceCount", 1),
            snoozeMinutes = value.optInt("snoozeMinutes", 10).coerceIn(1, 1440),
            maxSnoozes = value.optInt("maxSnoozes", 3).coerceIn(0, 20),
            snoozeCount = value.optInt("snoozeCount"),
            autoSnooze = value.optBoolean("autoSnooze"),
            escalationStep = value.optInt("escalationStep").coerceAtLeast(0),
            parentOccurrenceUuid = value.optionalString("parentOccurrenceUuid"),
        )
    }
}

internal class ReminderStore(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    @Synchronized
    fun save(record: ReminderRecord) {
        check(preferences.edit().putString(KEY_PREFIX + record.occurrenceUuid, record.toJson().toString()).commit())
    }

    @Synchronized
    fun remove(occurrenceUuid: String) {
        preferences.edit().remove(KEY_PREFIX + occurrenceUuid).apply()
    }

    @Synchronized
    fun records(): List<ReminderRecord> = preferences.all
        .filterKeys { it.startsWith(KEY_PREFIX) }
        .values
        .mapNotNull { value -> runCatching { ReminderRecord.fromJson(JSONObject(value as String)) }.getOrNull() }

    @Synchronized
    fun recordsFor(reminderId: Int): List<ReminderRecord> = records().filter { it.reminderId == reminderId }

    @Synchronized
    fun find(occurrenceUuid: String): ReminderRecord? = preferences
        .getString(KEY_PREFIX + occurrenceUuid, null)
        ?.let { runCatching { ReminderRecord.fromJson(JSONObject(it)) }.getOrNull() }

    companion object {
        private const val PREFERENCES = "reminder_schedule_v1"
        private const val KEY_PREFIX = "occurrence_"
    }
}

private fun JSONObject.optionalInt(key: String): Int? =
    if (isNull(key) || !has(key)) null else getInt(key)

private fun JSONObject.optionalLong(key: String): Long? =
    if (isNull(key) || !has(key)) null else getLong(key)

private fun JSONObject.optionalString(key: String): String? =
    if (isNull(key) || !has(key)) null else getString(key)
