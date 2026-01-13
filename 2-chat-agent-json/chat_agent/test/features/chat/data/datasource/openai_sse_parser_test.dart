import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/data/datasource/openai_sse_parser.dart';

void main() {
  test('parses SSE chunks into deltas', () async {
    final parser = OpenAiSseParser();
    final stream = Stream<Uint8List>.fromIterable([
      Uint8List.fromList(utf8.encode('data: {"type":"response.output_text.delta","delta":"Hel')),
      Uint8List.fromList(utf8.encode('lo"}\n\n')),
      Uint8List.fromList(
        utf8.encode('data: {"type":"response.output_text.delta","delta":{"text":" world"}}\n\n'),
      ),
      Uint8List.fromList(utf8.encode('data: [DONE]\n\n')),
    ]);

    final deltas = await parser.parse(stream).toList();
    expect(deltas.join(), 'Hello world');
  });
}
