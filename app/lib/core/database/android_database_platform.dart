import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'database_key.dart';
import 'database_key_provider.dart';

final class AndroidDatabasePlatform implements DatabaseKeyProvider {
  const AndroidDatabasePlatform({
    MethodChannel channel = const MethodChannel('com.anaslifeos.app/database'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<DatabaseKey> loadOrCreate() async {
    final bytes = await _channel.invokeMethod<Uint8List>(
      'loadOrCreateDatabaseKey',
    );
    if (bytes == null) {
      throw const PlatformException(
        code: 'database_key_unavailable',
        message: 'Android did not return a database key.',
      );
    }
    return DatabaseKey(bytes);
  }

  Future<Directory> databaseDirectory() async {
    final path = await _channel.invokeMethod<String>('databaseDirectory');
    if (path == null || path.trim().isEmpty) {
      throw const PlatformException(
        code: 'database_directory_unavailable',
        message: 'Android did not return a database directory.',
      );
    }
    return Directory(path);
  }
}
