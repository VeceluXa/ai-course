import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/domain/entities/chat_message.dart';
import 'package:openai_chat_app/features/chat/presentation/widgets/assistant_json_card.dart';
import 'package:openai_chat_app/features/chat/presentation/widgets/message_bubble.dart';

void main() {
  test('AssistantJsonPayload parses valid JSON', () {
    const raw = '''
{
  "text": "Hello",
  "links": ["https://example.com"],
  "language": "en",
  "additional_questions": ["Any details?"],
  "model": "gpt-4.1-mini",
  "model_parameters": {"temperature": 0.2},
  "extra": "ok"
}
''';
    final payload = AssistantJsonPayload.tryParse(raw);
    expect(payload, isNotNull);
    expect(payload!.text, 'Hello');
    expect(payload.links, ['https://example.com']);
    expect(payload.language, 'en');
    expect(payload.additionalQuestions, ['Any details?']);
    expect(payload.model, 'gpt-4.1-mini');
  });

  test('AssistantJsonPayload returns null for invalid JSON', () {
    const raw = 'not json';
    final payload = AssistantJsonPayload.tryParse(raw);
    expect(payload, isNull);
  });

  testWidgets('MessageBubble renders JSON card content', (tester) async {
    const content = '''
{
  "text": "Hi there",
  "links": ["https://example.com"],
  "language": "en",
  "additional_questions": ["Need anything else?"],
  "model": "gpt-4.1-mini",
  "model_parameters": {"temperature": 0.2}
}
''';
    final message = ChatMessage(
      id: '1',
      role: ChatRole.assistant,
      content: content,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            onRetry: null,
            modelLabel: 'GPT-4.1 Mini',
          ),
        ),
      ),
    );

    expect(find.text('GPT-4.1 Mini'), findsOneWidget);
    expect(find.text('Hi there'), findsOneWidget);
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('• Need anything else?'), findsOneWidget);
    expect(find.text('References'), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);
  });

  testWidgets('MessageBubble shows streaming content as it arrives', (tester) async {
    const content = 'Partial response...';
    final message = ChatMessage(
      id: '2',
      role: ChatRole.assistant,
      content: content,
      isStreaming: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            onRetry: null,
            modelLabel: null,
          ),
        ),
      ),
    );

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(markdown.data, content);
  });
}
