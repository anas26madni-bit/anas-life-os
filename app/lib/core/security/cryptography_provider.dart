import 'dart:typed_data';

/// Replaceable cryptographic boundary. Implementations begin in Sprint 10.
abstract interface class CryptographyProvider {
  Future<Uint8List> encrypt({
    required Uint8List plaintext,
    required String keyReference,
  });

  Future<Uint8List> decrypt({
    required Uint8List ciphertext,
    required String keyReference,
  });
}

/// Android Keystore-backed key lifecycle boundary.
abstract interface class MasterKeyProvider {
  Future<String> createWrappedMasterKey();

  Future<void> invalidate(String keyReference);
}

/// Argon2id backup-key derivation boundary.
abstract interface class BackupKeyDeriver {
  Future<Uint8List> derive({
    required String passphrase,
    required Uint8List salt,
  });
}
