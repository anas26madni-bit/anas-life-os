package com.anaslifeos.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.util.Base64
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.bouncycastle.crypto.generators.Argon2BytesGenerator
import org.bouncycastle.crypto.params.Argon2Parameters
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.security.KeyStore
import java.security.MessageDigest
import java.security.SecureRandom
import java.util.UUID
import java.util.concurrent.TimeUnit
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import javax.crypto.Cipher
import javax.crypto.CipherInputStream
import javax.crypto.CipherOutputStream
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties

internal class BackupPlatform(
    private val activity: Activity,
    messenger: BinaryMessenger,
    private val databaseKeys: DatabaseKeyCustody,
) {
    private var pendingPicker: MethodChannel.Result? = null
    private var pendingRequest = 0
    private val engine = BackupArchiveEngine(activity.applicationContext, databaseKeys)

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "selectDestination" -> launchPicker(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE), DESTINATION_REQUEST, result)
                "selectImport" -> launchPicker(
                    Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = ARCHIVE_MIME
                    },
                    IMPORT_REQUEST,
                    result,
                )
                "createArchive" -> {
                    val args = requireNotNull(call.arguments as? Map<*, *>)
                    val outcome = engine.createManual(
                        databaseSnapshot = File(requireNotNull(args["databaseSnapshotPath"] as? String)),
                        managedFiles = (args["managedFilePaths"] as? List<*>)
                            .orEmpty().mapNotNull { (it as? String)?.let(::File) },
                        destinationTree = Uri.parse(requireNotNull(args["destinationUri"] as? String)),
                        passphrase = requireNotNull(args["passphrase"] as? String),
                        backupName = requireNotNull(args["backupName"] as? String),
                    )
                    result.success(
                        mapOf(
                            "uri" to outcome.uri.toString(),
                            "sizeBytes" to outcome.sizeBytes,
                            "sha256" to outcome.sha256,
                        ),
                    )
                }
                "restoreArchive" -> {
                    val args = requireNotNull(call.arguments as? Map<*, *>)
                    result.success(
                        engine.restore(
                            Uri.parse(requireNotNull(args["sourceUri"] as? String)),
                            requireNotNull(args["passphrase"] as? String),
                        ),
                    )
                }
                "configureAutomatic" -> {
                    val args = requireNotNull(call.arguments as? Map<*, *>)
                    AutomaticBackupConfiguration(activity.applicationContext).enable(
                        destination = requireNotNull(args["destinationUri"] as? String),
                        frequency = requireNotNull(args["frequency"] as? String),
                        retention = requireNotNull(args["retentionCount"] as? Int),
                        passphrase = requireNotNull(args["passphrase"] as? String),
                    )
                    result.success(null)
                }
                "disableAutomatic" -> {
                    AutomaticBackupConfiguration(activity.applicationContext).disable()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("backup_operation_failed", "The backup operation failed safely.", error.javaClass.simpleName)
        }
    }

    private fun launchPicker(intent: Intent, request: Int, result: MethodChannel.Result) {
        check(pendingPicker == null) { "A storage picker is already active." }
        pendingPicker = result
        pendingRequest = request
        activity.startActivityForResult(intent, request)
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != pendingRequest || pendingPicker == null) return false
        val result = pendingPicker
        pendingPicker = null
        pendingRequest = 0
        val uri = data?.data
        if (resultCode == Activity.RESULT_OK && uri != null) {
            val flags = data.flags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            runCatching { activity.contentResolver.takePersistableUriPermission(uri, flags) }
            result?.success(uri.toString())
        } else {
            result?.success(null)
        }
        return true
    }

    companion object {
        private const val CHANNEL = "com.anaslifeos.app/backup"
        private const val DESTINATION_REQUEST = 9201
        private const val IMPORT_REQUEST = 9202
        internal const val ARCHIVE_MIME = "application/vnd.anas-life-os.backup"
    }
}

private data class ArchiveOutcome(val uri: Uri, val sizeBytes: Long, val sha256: String)

private class BackupArchiveEngine(
    private val context: Context,
    private val databaseKeys: DatabaseKeyCustody,
) {
    private val random = SecureRandom()

    fun createManual(
        databaseSnapshot: File,
        managedFiles: List<File>,
        destinationTree: Uri,
        passphrase: String,
        backupName: String,
    ): ArchiveOutcome {
        require(databaseSnapshot.isFile) { "Database snapshot is unavailable." }
        val salt = ByteArray(SALT_BYTES).also(random::nextBytes)
        val key = derive(passphrase, salt)
        return createArchive(databaseSnapshot, managedFiles, destinationTree, backupName, salt, key)
            .also { key.fill(0) }
    }

    fun createAutomatic(
        destinationTree: Uri,
        retention: Int,
        salt: ByteArray,
        key: ByteArray,
    ): ArchiveOutcome {
        val database = File(context.noBackupFilesDir, DATABASE_NAME)
        val name = "anas-life-os-auto-${System.currentTimeMillis()}.alos"
        val files = buildList {
            addAll(context.filesDir.walkTopDown().filter(File::isFile))
            listOf(File(database.path + "-wal"), File(database.path + "-shm"))
                .filterTo(this, File::isFile)
        }
        return createArchive(database, files, destinationTree, name, salt, key).also {
            pruneAutomatic(destinationTree, retention)
        }
    }

    private fun createArchive(
        database: File,
        managedFiles: List<File>,
        destinationTree: Uri,
        backupName: String,
        salt: ByteArray,
        key: ByteArray,
    ): ArchiveOutcome {
        require(database.isFile) { "Database is unavailable." }
        val parent = DocumentsContract.buildDocumentUriUsingTree(
            destinationTree,
            DocumentsContract.getTreeDocumentId(destinationTree),
        )
        val document = requireNotNull(
            DocumentsContract.createDocument(
                context.contentResolver,
                parent,
                BackupPlatform.ARCHIVE_MIME,
                backupName,
            ),
        ) { "Backup destination is unavailable." }
        val initializationVector = ByteArray(IV_BYTES).also(random::nextBytes)
        val digest = MessageDigest.getInstance("SHA-256")
        try {
            context.contentResolver.openOutputStream(document, "w").use { raw ->
                requireNotNull(raw)
                val digesting = java.security.DigestOutputStream(BufferedOutputStream(raw), digest)
                val header = DataOutputStream(digesting)
                header.write(MAGIC)
                header.write(salt)
                header.write(initializationVector)
                header.flush()
                val cipher = Cipher.getInstance(TRANSFORMATION).apply {
                    init(
                        Cipher.ENCRYPT_MODE,
                        SecretKeySpec(key, "AES"),
                        GCMParameterSpec(TAG_BITS, initializationVector),
                    )
                }
                ZipOutputStream(CipherOutputStream(digesting, cipher)).use { zip ->
                    val acceptedFiles = managedFiles.filter(File::isFile)
                    val manifest = JSONObject().apply {
                        put("formatVersion", 1)
                        put("databaseName", DATABASE_NAME)
                        put("createdAt", System.currentTimeMillis())
                        put("files", JSONArray(acceptedFiles.mapIndexed { index, file ->
                            JSONObject().put("entry", "files/$index").put("path", file.canonicalPath)
                        }))
                    }
                    zip.entry("manifest.json", manifest.toString().toByteArray())
                    zip.entry("database/$DATABASE_NAME", database)
                    zip.entry("database/key.bin", databaseKeys.loadOrCreate())
                    acceptedFiles.forEachIndexed { index, file -> zip.entry("files/$index", file) }
                }
            }
            val size = context.contentResolver.openAssetFileDescriptor(document, "r")?.use { it.length } ?: 0L
            return ArchiveOutcome(document, size, digest.digest().toHex())
        } catch (error: Exception) {
            runCatching { DocumentsContract.deleteDocument(context.contentResolver, document) }
            throw error
        }
    }

    fun restore(source: Uri, passphrase: String): Int {
        val stage = File(context.cacheDir, "restore-${UUID.randomUUID()}").apply { mkdirs() }
        val restoredDatabase = File(stage, DATABASE_NAME)
        val restoredKey = File(stage, "key.bin")
        var manifest: JSONObject? = null
        try {
            context.contentResolver.openInputStream(source).use { raw ->
                val input = DataInputStream(BufferedInputStream(requireNotNull(raw)))
                require(input.readNBytes(MAGIC.size).contentEquals(MAGIC)) { "Backup format is invalid." }
                val salt = input.readNBytes(SALT_BYTES)
                val iv = input.readNBytes(IV_BYTES)
                require(salt.size == SALT_BYTES && iv.size == IV_BYTES) { "Backup header is incomplete." }
                val key = derive(passphrase, salt)
                val cipher = Cipher.getInstance(TRANSFORMATION).apply {
                    init(Cipher.DECRYPT_MODE, SecretKeySpec(key, "AES"), GCMParameterSpec(TAG_BITS, iv))
                }
                ZipInputStream(CipherInputStream(input, cipher)).use { zip ->
                    while (true) {
                        val entry = zip.nextEntry ?: break
                        when (entry.name) {
                            "manifest.json" -> manifest = JSONObject(zip.readBytes().toString(Charsets.UTF_8))
                            "database/$DATABASE_NAME" -> restoredDatabase.outputStream().use(zip::copyTo)
                            "database/key.bin" -> restoredKey.outputStream().use(zip::copyTo)
                            else -> if (entry.name.startsWith("files/")) {
                                File(stage, entry.name.replace('/', '_')).outputStream().use(zip::copyTo)
                            }
                        }
                        zip.closeEntry()
                    }
                }
                key.fill(0)
            }
            val metadata = requireNotNull(manifest)
            require(metadata.getInt("formatVersion") == 1) { "Backup version is unsupported." }
            require(restoredDatabase.length() > 0L && restoredKey.length() == 32L) { "Backup is incomplete." }
            applyAtomically(restoredDatabase, restoredKey.readBytes(), metadata, stage)
            return metadata.getJSONArray("files").length()
        } finally {
            stage.deleteRecursively()
        }
    }

    private fun applyAtomically(database: File, databaseKey: ByteArray, manifest: JSONObject, stage: File) {
        val target = File(context.noBackupFilesDir, DATABASE_NAME)
        val rollback = File(context.noBackupFilesDir, "$DATABASE_NAME.restore-rollback")
        if (rollback.exists()) rollback.delete()
        if (target.exists()) check(target.renameTo(rollback)) { "Active database could not be staged." }
        try {
            check(database.renameTo(target)) { "Restored database could not be installed." }
            databaseKeys.replace(databaseKey)
            File(target.path + "-wal").delete()
            File(target.path + "-shm").delete()
            val files = manifest.getJSONArray("files")
            for (index in 0 until files.length()) {
                val item = files.getJSONObject(index)
                val destination = File(item.getString("path")).canonicalFile
                require(destination.path.startsWith(context.applicationInfo.dataDir)) {
                    "A managed file destination is outside application storage."
                }
                val staged = File(stage, item.getString("entry").replace('/', '_'))
                if (staged.isFile) {
                    destination.parentFile?.mkdirs()
                    staged.copyTo(destination, overwrite = true)
                }
            }
            rollback.delete()
        } catch (error: Exception) {
            target.delete()
            if (rollback.exists()) rollback.renameTo(target)
            throw error
        } finally {
            databaseKey.fill(0)
        }
    }

    private fun derive(passphrase: String, salt: ByteArray): ByteArray {
        require(passphrase.isNotEmpty()) { "Backup passphrase is required." }
        val output = ByteArray(32)
        val generator = Argon2BytesGenerator()
        generator.init(
            Argon2Parameters.Builder(Argon2Parameters.ARGON2_id)
                .withSalt(salt)
                .withIterations(3)
                .withMemoryAsKB(64 * 1024)
                .withParallelism(1)
                .build(),
        )
        generator.generateBytes(passphrase.toCharArray(), output)
        return output
    }

    private fun pruneAutomatic(tree: Uri, retention: Int) {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree,
            DocumentsContract.getTreeDocumentId(tree),
        )
        val records = mutableListOf<Pair<Uri, Long>>()
        context.contentResolver.query(
            children,
            arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID, DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_LAST_MODIFIED),
            null,
            null,
            null,
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val name = cursor.getString(1)
                if (name.startsWith("anas-life-os-auto-") && name.endsWith(".alos")) {
                    records += DocumentsContract.buildDocumentUriUsingTree(tree, cursor.getString(0)) to cursor.getLong(2)
                }
            }
        }
        records.sortedByDescending { it.second }.drop(retention.coerceIn(1, 30)).forEach {
            DocumentsContract.deleteDocument(context.contentResolver, it.first)
        }
    }

    private fun ZipOutputStream.entry(name: String, bytes: ByteArray) {
        putNextEntry(ZipEntry(name))
        write(bytes)
        closeEntry()
    }

    private fun ZipOutputStream.entry(name: String, file: File) {
        putNextEntry(ZipEntry(name))
        FileInputStream(file).use { it.copyTo(this) }
        closeEntry()
    }

    companion object {
        private val MAGIC = "ALOSBKP1".toByteArray(Charsets.US_ASCII)
        private const val DATABASE_NAME = "anas_life_os.db"
        private const val SALT_BYTES = 16
        private const val IV_BYTES = 12
        private const val TAG_BITS = 128
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
    }
}

private class AutomaticBackupConfiguration(private val context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    fun enable(destination: String, frequency: String, retention: Int, passphrase: String) {
        require(retention in 1..30)
        val salt = ByteArray(16).also(SecureRandom()::nextBytes)
        val derived = derive(passphrase, salt)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply {
            init(Cipher.ENCRYPT_MODE, wrappingKey())
        }
        val wrapped = cipher.doFinal(derived)
        derived.fill(0)
        check(
            preferences.edit()
                .putString(DESTINATION, destination)
                .putString(SALT, Base64.encodeToString(salt, Base64.NO_WRAP))
                .putString(KEY, Base64.encodeToString(wrapped, Base64.NO_WRAP))
                .putString(IV, Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
                .putInt(RETENTION, retention)
                .commit(),
        )
        val intervalDays = if (frequency == "weekly") 7L else 1L
        val request = PeriodicWorkRequestBuilder<AutomaticBackupWorker>(intervalDays, TimeUnit.DAYS)
            .setConstraints(
                Constraints.Builder()
                    .setRequiresBatteryNotLow(true)
                    .setRequiresStorageNotLow(true)
                    .build(),
            )
            .build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            request,
        )
    }

    fun disable() {
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        preferences.edit().clear().apply()
    }

    fun read(): AutomaticConfiguration? {
        val destination = preferences.getString(DESTINATION, null) ?: return null
        val salt = Base64.decode(preferences.getString(SALT, null) ?: return null, Base64.NO_WRAP)
        val wrapped = Base64.decode(preferences.getString(KEY, null) ?: return null, Base64.NO_WRAP)
        val iv = Base64.decode(preferences.getString(IV, null) ?: return null, Base64.NO_WRAP)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply {
            init(Cipher.DECRYPT_MODE, wrappingKey(), GCMParameterSpec(128, iv))
        }
        return AutomaticConfiguration(
            Uri.parse(destination),
            preferences.getInt(RETENTION, 7).coerceIn(1, 30),
            salt,
            cipher.doFinal(wrapped),
        )
    }

    private fun derive(passphrase: String, salt: ByteArray): ByteArray {
        val output = ByteArray(32)
        Argon2BytesGenerator().apply {
            init(
                Argon2Parameters.Builder(Argon2Parameters.ARGON2_id)
                    .withSalt(salt).withIterations(3).withMemoryAsKB(64 * 1024).withParallelism(1).build(),
            )
            generateBytes(passphrase.toCharArray(), output)
        }
        return output
    }

    private fun wrappingKey(): SecretKey {
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (store.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
            init(
                KeyGenParameterSpec.Builder(
                    KEY_ALIAS,
                    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
                ).setKeySize(256).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build(),
            )
        }.generateKey()
    }

    companion object {
        private const val PREFERENCES = "automatic_backup_v1"
        private const val DESTINATION = "destination"
        private const val SALT = "salt"
        private const val KEY = "wrapped_key"
        private const val IV = "iv"
        private const val RETENTION = "retention"
        private const val KEY_ALIAS = "anas_life_os_automatic_backup_key_v1"
        const val WORK_NAME = "anas_life_os_automatic_backup"
    }
}

private data class AutomaticConfiguration(
    val destination: Uri,
    val retention: Int,
    val salt: ByteArray,
    val key: ByteArray,
)

internal class AutomaticBackupWorker(context: Context, parameters: WorkerParameters) :
    CoroutineWorker(context, parameters) {
    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val foreground = applicationContext.getSharedPreferences("backup_runtime_v1", Context.MODE_PRIVATE)
            .getBoolean("app_foreground", false)
        if (foreground) return@withContext Result.retry()
        val configuration = AutomaticBackupConfiguration(applicationContext).read()
            ?: return@withContext Result.success()
        try {
            BackupArchiveEngine(applicationContext, DatabaseKeyCustody(applicationContext)).createAutomatic(
                configuration.destination,
                configuration.retention,
                configuration.salt,
                configuration.key,
            )
            Result.success()
        } catch (_: Exception) {
            Result.retry()
        } finally {
            configuration.key.fill(0)
        }
    }
}

private fun ByteArray.toHex(): String = joinToString("") { "%02x".format(it) }
