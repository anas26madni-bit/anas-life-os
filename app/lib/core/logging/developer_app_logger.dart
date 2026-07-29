import 'dart:convert';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';

import 'app_logger.dart';

@LazySingleton(as: AppLogger)
final class DeveloperAppLogger implements AppLogger {
  static const _name = 'AnasLifeOS';

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) {
    _write('DEBUG', message, context: context);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _write(
      'ERROR',
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _write(
      'FATAL',
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {
    _write('INFO', message, context: context);
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _write(
      'WARNING',
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void _write(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    final safeContext = Map<String, Object?>.from(context)
      ..removeWhere((key, _) => _sensitiveKeys.contains(key.toLowerCase()));
    developer.log(
      jsonEncode({
        'level': level,
        'message': message,
        if (safeContext.isNotEmpty) 'context': safeContext,
      }),
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static const _sensitiveKeys = {
    'password',
    'pin',
    'secret',
    'token',
    'key',
    'content',
  };
}
