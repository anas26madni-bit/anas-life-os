package com.anaslifeos.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.security.SecureRandom
import java.util.concurrent.Executor
import kotlin.math.min
import org.bouncycastle.crypto.generators.Argon2BytesGenerator
import org.bouncycastle.crypto.params.Argon2Parameters

internal class SecurityPlatform(
    private val activity: FragmentActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val preferences = activity.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
    private val random = SecureRandom()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor: Executor = ContextCompat.getMainExecutor(activity)

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "status" -> result.success(status())
                "configurePin" -> result.success(configurePin(requiredPin(call)))
                "changePin" -> result.success(changePin(requiredString(call, "currentPin"), requiredString(call, "newPin")))
                "verifyPin" -> result.success(verifyPin(requiredPin(call)))
                "disablePin" -> result.success(disablePin(requiredPin(call)))
                "authenticateBiometric" -> authenticateBiometric(call, result)
                "setSecureWindow" -> {
                    setSecureWindow(call.arguments as? Boolean ?: false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: IllegalArgumentException) {
            result.error("invalid_security_request", "The security request is invalid.", null)
        } catch (error: Exception) {
            result.error("security_unavailable", "Device security is unavailable.", error.javaClass.simpleName)
        }
    }

    private fun status(): Map<String, Any> = mapOf(
        "hasPin" to hasPin(),
        "biometricAvailable" to biometricAvailable(),
        "failedAttempts" to preferences.getInt(FAILED_ATTEMPTS, 0),
        "cooldownSeconds" to cooldownSeconds(),
    )

    private fun configurePin(pin: String): Map<String, Any> {
        require(!hasPin()) { "A current PIN is required to replace the PIN." }
        persistPin(pin)
        clearFailures()
        return success()
    }

    private fun changePin(currentPin: String, newPin: String): Map<String, Any> {
        val verification = verifyPin(currentPin)
        if (verification["success"] != true) return verification
        persistPin(newPin)
        clearFailures()
        return success()
    }

    private fun verifyPin(pin: String): Map<String, Any> {
        val remaining = cooldownSeconds()
        if (remaining > 0) return failure(remaining)
        val salt = preferences.getString(PIN_SALT, null)?.hexToBytes() ?: return failure(0)
        val expected = preferences.getString(PIN_HASH, null)?.hexToBytes() ?: return failure(0)
        if (MessageDigest.isEqual(expected, derive(pin, salt))) {
            clearFailures()
            return success()
        }
        val failures = preferences.getInt(FAILED_ATTEMPTS, 0) + 1
        val cooldown = if (failures >= FAILURE_LIMIT) {
            min(MAX_COOLDOWN_SECONDS, BASE_COOLDOWN_SECONDS shl min(failures - FAILURE_LIMIT, 5))
        } else {
            0
        }
        preferences.edit()
            .putInt(FAILED_ATTEMPTS, failures)
            .putLong(COOLDOWN_UNTIL, System.currentTimeMillis() + cooldown * 1000L)
            .commit()
        return failure(cooldown)
    }

    private fun disablePin(pin: String): Map<String, Any> {
        val verification = verifyPin(pin)
        if (verification["success"] != true) return verification
        preferences.edit().remove(PIN_SALT).remove(PIN_HASH).remove(FAILED_ATTEMPTS)
            .remove(COOLDOWN_UNTIL).commit()
        return success()
    }

    private fun authenticateBiometric(call: MethodCall, result: MethodChannel.Result) {
        if (!hasPin() || !biometricAvailable()) {
            result.success(failure(0))
            return
        }
        val prompt = BiometricPrompt(
            activity,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    clearFailures()
                    result.success(success())
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    result.success(failure(cooldownSeconds()))
                }

                override fun onAuthenticationFailed() = Unit
            },
        )
        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle(requiredString(call, "title"))
            .setSubtitle(requiredString(call, "subtitle"))
            .setNegativeButtonText(requiredString(call, "cancelLabel"))
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            .build()
        mainHandler.post { prompt.authenticate(info) }
    }

    private fun setSecureWindow(enabled: Boolean) {
        mainHandler.post {
            if (enabled) activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            else activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun persistPin(pin: String) {
        validatePin(pin)
        val salt = ByteArray(SALT_BYTES).also(random::nextBytes)
        check(preferences.edit().putString(PIN_SALT, salt.toHex()).putString(PIN_HASH, derive(pin, salt).toHex()).commit())
    }

    private fun derive(pin: String, salt: ByteArray): ByteArray {
        val generator = Argon2BytesGenerator()
        generator.init(
            Argon2Parameters.Builder(Argon2Parameters.ARGON2_id)
                .withSalt(salt).withIterations(3).withMemoryAsKB(65_536).withParallelism(2).build(),
        )
        return ByteArray(HASH_BYTES).also { generator.generateBytes(pin.toCharArray(), it) }
    }

    private fun biometricAvailable(): Boolean = BiometricManager.from(activity).canAuthenticate(
        BiometricManager.Authenticators.BIOMETRIC_STRONG,
    ) == BiometricManager.BIOMETRIC_SUCCESS

    private fun cooldownSeconds(): Int =
        ((preferences.getLong(COOLDOWN_UNTIL, 0L) - System.currentTimeMillis()).coerceAtLeast(0L) / 1000L)
            .toInt()

    private fun hasPin() = preferences.contains(PIN_SALT) && preferences.contains(PIN_HASH)
    private fun clearFailures() { preferences.edit().remove(FAILED_ATTEMPTS).remove(COOLDOWN_UNTIL).commit() }
    private fun requiredPin(call: MethodCall) = requiredString(call, "pin").also(::validatePin)
    private fun requiredString(call: MethodCall, key: String) = call.argument<String>(key)?.trim().orEmpty().also { require(it.isNotEmpty()) }
    private fun validatePin(pin: String) { require(pin.length >= 6 && pin.all(Char::isDigit)) }
    private fun success() = mapOf("success" to true, "failedAttempts" to 0, "cooldownSeconds" to 0)
    private fun failure(cooldown: Int) = mapOf("success" to false, "failedAttempts" to preferences.getInt(FAILED_ATTEMPTS, 0), "cooldownSeconds" to cooldown)
    private fun ByteArray.toHex() = joinToString("") { "%02x".format(it) }
    private fun String.hexToBytes() = chunked(2).map { it.toInt(16).toByte() }.toByteArray()

    private companion object {
        const val CHANNEL = "com.anaslifeos.app/security"
        const val PREFERENCES = "security_verifier_v1"
        const val PIN_SALT = "pin_salt"
        const val PIN_HASH = "pin_hash"
        const val FAILED_ATTEMPTS = "failed_attempts"
        const val COOLDOWN_UNTIL = "cooldown_until"
        const val FAILURE_LIMIT = 5
        const val BASE_COOLDOWN_SECONDS = 30
        const val MAX_COOLDOWN_SECONDS = 900
        const val SALT_BYTES = 16
        const val HASH_BYTES = 32
    }
}
