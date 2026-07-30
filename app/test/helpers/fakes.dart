import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/database/database_initializer.dart';
import 'package:anas_life_os/core/logging/app_logger.dart';

class FakeAppLogger implements AppLogger {
  final messages = <String>[];

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) {
    messages.add(message);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {
    messages.add(message);
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }
}

class FakeDatabaseInitializer extends DatabaseInitializer {
  FakeDatabaseInitializer(this.report, {this.delay = Duration.zero})
    : super(FakeAppLogger());

  final DatabaseFoundationReport report;
  final Duration delay;

  @override
  Future<DatabaseFoundationReport> verifyFoundation() async {
    await Future<void>.delayed(delay);
    return report;
  }
}
