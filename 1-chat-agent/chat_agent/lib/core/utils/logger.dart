import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'redaction.dart';

class AppLogger {
  const AppLogger();

  void logRequest(String method, Uri uri, Map<String, dynamic> headers) {
    if (!kDebugMode) return;
    final redactedHeaders = redactHeaders(headers);
    developer.log('[HTTP] $method $uri', name: 'openai_chat_app.http');
    developer.log('[HTTP] headers=$redactedHeaders', name: 'openai_chat_app.http');
    debugPrint('[HTTP] $method $uri');
    debugPrint('[HTTP] headers=$redactedHeaders');
  }

  void logResponse(int statusCode, Uri uri) {
    if (!kDebugMode) return;
    developer.log('[HTTP] $statusCode $uri', name: 'openai_chat_app.http');
    debugPrint('[HTTP] $statusCode $uri');
  }

  void logError(Object error, Uri? uri, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(
      '[HTTP] error=$error uri=$uri',
      name: 'openai_chat_app.http',
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[HTTP] error=$error uri=$uri');
  }

  void logInfo(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'openai_chat_app');
    debugPrint(message);
  }

  void logWarning(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'openai_chat_app', level: 900);
    debugPrint('WARN: $message');
  }

  void logException(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: 'openai_chat_app',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    debugPrint('ERROR: $message -> $error');
  }
}
