import 'dart:typed_data';

import 'database_constants.dart';

final class DatabaseKey {
  DatabaseKey(Uint8List bytes) : _bytes = Uint8List.fromList(bytes) {
    if (_bytes.length != DatabaseConstants.keyLengthBytes) {
      throw ArgumentError.value(
        bytes.length,
        'bytes',
        'Database keys must contain exactly '
            '${DatabaseConstants.keyLengthBytes} bytes.',
      );
    }
  }

  final Uint8List _bytes;

  String get hexadecimal => _bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}
