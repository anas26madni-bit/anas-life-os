import 'dart:typed_data';

/// Secure storage contract only. No Sprint 1 implementation persists secrets.
abstract interface class SecureStorage {
  Future<void> write(String key, Uint8List value);

  Future<Uint8List?> read(String key);

  Future<void> delete(String key);
}
