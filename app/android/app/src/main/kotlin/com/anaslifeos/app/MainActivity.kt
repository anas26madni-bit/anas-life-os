package com.anaslifeos.app

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val custody = DatabaseKeyCustody(applicationContext)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DATABASE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "loadOrCreateDatabaseKey" -> result.success(custody.loadOrCreate())
                    "databaseDirectory" -> result.success(applicationContext.noBackupFilesDir.absolutePath)
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error(
                    "database_key_unavailable",
                    "Encrypted database key custody is unavailable.",
                    error.javaClass.simpleName,
                )
            }
        }
    }

    private companion object {
        const val DATABASE_CHANNEL = "com.anaslifeos.app/database"
    }
}

private class DatabaseKeyCustody(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
    private val secureRandom = SecureRandom()

    @Synchronized
    fun loadOrCreate(): ByteArray {
        val ciphertext = preferences.getString(CIPHERTEXT, null)
        val initializationVector = preferences.getString(INITIALIZATION_VECTOR, null)
        if (ciphertext != null || initializationVector != null) {
            require(ciphertext != null && initializationVector != null) {
                "Wrapped database key record is incomplete."
            }
            return unwrap(
                Base64.decode(ciphertext, Base64.NO_WRAP),
                Base64.decode(initializationVector, Base64.NO_WRAP),
            ).also(::validateDatabaseKey)
        }

        val databaseKey = ByteArray(DATABASE_KEY_BYTES).also(secureRandom::nextBytes)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, wrappingKey())
        val wrapped = cipher.doFinal(databaseKey)
        val committed = preferences.edit()
            .putString(CIPHERTEXT, Base64.encodeToString(wrapped, Base64.NO_WRAP))
            .putString(INITIALIZATION_VECTOR, Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
            .commit()
        check(committed) { "Wrapped database key could not be persisted." }
        return databaseKey
    }

    private fun unwrap(ciphertext: ByteArray, initializationVector: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            wrappingKey(),
            GCMParameterSpec(GCM_TAG_BITS, initializationVector),
        )
        return cipher.doFinal(ciphertext)
    }

    private fun wrappingKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE_PROVIDER)
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setKeySize(WRAPPING_KEY_BITS)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return generator.generateKey()
    }

    private fun validateDatabaseKey(key: ByteArray) {
        require(key.size == DATABASE_KEY_BYTES) { "Database key has an invalid length." }
    }

    private companion object {
        const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        const val KEY_ALIAS = "anas_life_os_database_wrapping_key_v1"
        const val PREFERENCES = "database_key_custody_v1"
        const val CIPHERTEXT = "ciphertext"
        const val INITIALIZATION_VECTOR = "initialization_vector"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val WRAPPING_KEY_BITS = 256
        const val DATABASE_KEY_BYTES = 32
        const val GCM_TAG_BITS = 128
    }
}