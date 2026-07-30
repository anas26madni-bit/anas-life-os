import 'dart:io';

import 'database_constants.dart';

final class DatabaseFileResolver {
  const DatabaseFileResolver(this._supportDirectory);

  final Future<Directory> Function() _supportDirectory;

  Future<File> resolve() async {
    final directory = await _supportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}${Platform.pathSeparator}${DatabaseConstants.name}');
  }
}
