import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/data/datasource/openai_sse_parser.dart';

void main() {
  test('OpenAiSseParser emits deltas as they arrive', () async {
    final parser = OpenAiSseParser();
    final payload = [
      'data: {"type":"response.output_text.delta","delta":"Hel"}\n\n',
      'data: {"type":"response.output_text.delta","delta":{"text":"lo"}}\n\n',
      'data: [DONE]\n\n',
    ].join();
    final stream = Stream<Uint8List>.fromIterable(
      [Uint8List.fromList(utf8.encode(payload))],
    );

    final deltas = await parser.parse(stream).toList();
    expect(deltas, ['Hel', 'lo']);
  });

  test('OpenAiSseParser extracts nested content text', () async {
    final parser = OpenAiSseParser();
    final payload = [
      'data: {"type":"response.output_text.delta","delta":{"content":[{"text":"Hi"}]}}\n\n',
      'data: [DONE]\n\n',
    ].join();
    final stream = Stream<Uint8List>.fromIterable(
      [Uint8List.fromList(utf8.encode(payload))],
    );

    final deltas = await parser.parse(stream).toList();
    expect(deltas.join(), 'Hi');
  });
}
