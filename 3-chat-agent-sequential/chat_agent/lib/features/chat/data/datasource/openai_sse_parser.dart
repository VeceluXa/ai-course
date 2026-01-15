import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/utils/logger.dart';

class OpenAiSseParser {
  OpenAiSseParser({AppLogger? logger}) : _logger = logger;

  final AppLogger? _logger;
  Stream<String> parse(Stream<Uint8List> byteStream) async* {
    var buffer = '';
    final dataLines = <String>[];

    await for (final chunk in byteStream.cast<List<int>>().transform(utf8.decoder)) {
      buffer += chunk;
      while (buffer.contains('\n')) {
        final index = buffer.indexOf('\n');
        var line = buffer.substring(0, index);
        buffer = buffer.substring(index + 1);
        line = line.replaceAll('\r', '');

        if (line.isEmpty) {
          if (dataLines.isNotEmpty) {
            final payload = dataLines.join('\n').trim();
            dataLines.clear();
            if (payload == '[DONE]') {
              _logger?.logInfo('[SSE] done');
              return;
            }
            final delta = _parseDelta(payload);
            if (delta.isNotEmpty) {
              _logger?.logInfo('[SSE] delta length=${delta.length}');
              yield delta;
            }
          }
          continue;
        }

        if (line.startsWith('data:')) {
          final data = line.substring(5).trimLeft();
          if (data.isNotEmpty) {
            dataLines.add(data);
          }
        }
      }
    }

    if (dataLines.isNotEmpty) {
      final payload = dataLines.join('\n').trim();
      if (payload.isNotEmpty && payload != '[DONE]') {
        final delta = _parseDelta(payload);
        if (delta.isNotEmpty) {
          _logger?.logInfo('[SSE] delta length=${delta.length}');
          yield delta;
        }
      }
    }
  }

  String _parseDelta(String payload) {
    try {
      final jsonData = jsonDecode(payload);
      if (jsonData is! Map<String, dynamic>) return '';
      final eventType = jsonData['type'];
      if (eventType is String) {
        _logger?.logInfo('[SSE] event=$eventType');
      }
      final delta = jsonData['delta'];
      if (delta == null) return '';
      return _extractText(delta);
    } catch (error, stackTrace) {
      _logger?.logException('[SSE] Failed to parse payload', error, stackTrace);
      return '';
    }
  }

  String _extractText(dynamic value) {
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final text = value['text'];
      if (text is String) return text;
      final content = value['content'];
      if (content is List) return _extractText(content);
      final outputText = value['output_text'];
      if (outputText is String) return outputText;
      if (outputText is List) return _extractText(outputText);
    }
    if (value is List) {
      final buffer = StringBuffer();
      for (final item in value) {
        final chunk = _extractText(item);
        if (chunk.isNotEmpty) {
          buffer.write(chunk);
        }
      }
      return buffer.toString();
    }
    return '';
  }
}
