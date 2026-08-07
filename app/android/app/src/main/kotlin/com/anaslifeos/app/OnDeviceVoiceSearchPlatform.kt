package com.anaslifeos.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class OnDeviceVoiceSearchPlatform(
    private val activity: MainActivity,
    messenger: BinaryMessenger,
) : RecognitionListener {
    private var recognizer: SpeechRecognizer? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingLocale: String? = null

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(isAvailable(call.argument("locale")))
                "listen" -> listen(call.argument("locale"), result)
                "cancel" -> {
                    release()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != MICROPHONE_PERMISSION_REQUEST) return
        val result = pendingResult ?: return
        val locale = pendingLocale
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED && locale != null) {
            start(locale, result)
        } else {
            clearPending()
            result.error("microphone_denied", "Microphone permission was not granted.", null)
        }
    }

    private fun isAvailable(locale: String?): Boolean =
        locale in SUPPORTED_LOCALES &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)

    private fun listen(locale: String?, result: MethodChannel.Result) {
        if (!isAvailable(locale)) {
            result.error(
                "on_device_voice_unavailable",
                "On-device voice search is unavailable; use typed search.",
                null,
            )
            return
        }
        if (pendingResult != null) {
            result.error("voice_search_busy", "Voice search is already active.", null)
            return
        }
        if (
            ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            pendingResult = result
            pendingLocale = locale
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                MICROPHONE_PERMISSION_REQUEST,
            )
            return
        }
        start(requireNotNull(locale), result)
    }

    private fun start(locale: String, result: MethodChannel.Result) {
        release()
        pendingResult = result
        pendingLocale = locale
        recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity).also {
            it.setRecognitionListener(this)
            it.startListening(
                Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(
                        RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                        RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
                    )
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                    putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
                    putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
                    putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, activity.packageName)
                },
            )
        }
    }

    override fun onResults(results: Bundle) {
        val transcript = results
            .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull()
            ?.trim()
        val result = pendingResult
        clearPending()
        release()
        if (transcript.isNullOrEmpty()) {
            result?.error("voice_search_empty", "No speech was recognized.", null)
        } else {
            result?.success(transcript)
        }
    }

    override fun onError(error: Int) {
        val result = pendingResult
        clearPending()
        release()
        result?.error("voice_search_failed", "On-device voice search failed.", error)
    }

    private fun clearPending() {
        pendingResult = null
        pendingLocale = null
    }

    private fun release() {
        recognizer?.cancel()
        recognizer?.destroy()
        recognizer = null
    }

    override fun onReadyForSpeech(params: Bundle?) = Unit
    override fun onBeginningOfSpeech() = Unit
    override fun onRmsChanged(rmsdB: Float) = Unit
    override fun onBufferReceived(buffer: ByteArray?) = Unit
    override fun onEndOfSpeech() = Unit
    override fun onPartialResults(partialResults: Bundle?) = Unit
    override fun onEvent(eventType: Int, params: Bundle?) = Unit

    private companion object {
        const val CHANNEL = "com.anaslifeos.app/on_device_voice_search"
        const val MICROPHONE_PERMISSION_REQUEST = 7007
        val SUPPORTED_LOCALES = setOf("en-US", "ur-PK")
    }
}
