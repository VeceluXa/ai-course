import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openai_chat_app/features/chat/domain/entities/model_info.dart';
import 'package:dio/dio.dart';
import 'package:openai_chat_app/features/chat/domain/entities/chat_message.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/models_repository.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/selected_model_repository.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/get_selected_model.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/load_models.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/send_user_message.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/set_selected_model.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/stream_assistant_response.dart';
import 'package:openai_chat_app/features/chat/presentation/chat_screen.dart';
import 'package:openai_chat_app/core/di/providers.dart';

class FakeModelsRepository implements ModelsRepository {
  FakeModelsRepository(this.models);

  final List<ModelInfo> models;

  @override
  Future<List<ModelInfo>> loadModels() async => models;
}

class FakeSelectedModelRepository implements SelectedModelRepository {
  FakeSelectedModelRepository(this.modelId);

  String? modelId;

  @override
  Future<void> clearSelectedModelId() async {
    modelId = null;
  }

  @override
  Future<String?> getSelectedModelId() async => modelId;

  @override
  Future<void> setSelectedModelId(String modelId) async {
    this.modelId = modelId;
  }
}

class FakeChatRepository implements ChatRepository {
  @override
  Stream<String> streamAssistantResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) async* {}
}

void main() {
  testWidgets('Empty state is shown when there are no messages', (tester) async {
    final modelsRepo = FakeModelsRepository(
      const [ModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 Mini')],
    );
    final selectedRepo = FakeSelectedModelRepository('gpt-4.1-mini');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadModelsProvider.overrideWithValue(LoadModels(modelsRepo)),
          getSelectedModelProvider.overrideWithValue(GetSelectedModel(selectedRepo)),
          setSelectedModelProvider.overrideWithValue(SetSelectedModel(selectedRepo)),
          sendUserMessageProvider.overrideWithValue(SendUserMessage()),
          streamAssistantResponseProvider.overrideWithValue(
            StreamAssistantResponse(FakeChatRepository()),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Welcome to OpenAI Chat'), findsOneWidget);
  });

  testWidgets('Model chip shows selected model label', (tester) async {
    final modelsRepo = FakeModelsRepository(
      const [ModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 Mini')],
    );
    final selectedRepo = FakeSelectedModelRepository('gpt-4.1-mini');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadModelsProvider.overrideWithValue(LoadModels(modelsRepo)),
          getSelectedModelProvider.overrideWithValue(GetSelectedModel(selectedRepo)),
          setSelectedModelProvider.overrideWithValue(SetSelectedModel(selectedRepo)),
          sendUserMessageProvider.overrideWithValue(SendUserMessage()),
          streamAssistantResponseProvider.overrideWithValue(
            StreamAssistantResponse(FakeChatRepository()),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('GPT-4.1 Mini'), findsOneWidget);
  });

  testWidgets('Composer send button enabled and disabled', (tester) async {
    final modelsRepo = FakeModelsRepository(
      const [ModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 Mini')],
    );
    final selectedRepo = FakeSelectedModelRepository('gpt-4.1-mini');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loadModelsProvider.overrideWithValue(LoadModels(modelsRepo)),
          getSelectedModelProvider.overrideWithValue(GetSelectedModel(selectedRepo)),
          setSelectedModelProvider.overrideWithValue(SetSelectedModel(selectedRepo)),
          sendUserMessageProvider.overrideWithValue(SendUserMessage()),
          streamAssistantResponseProvider.overrideWithValue(
            StreamAssistantResponse(FakeChatRepository()),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final sendFinder = find.widgetWithIcon(IconButton, Icons.send);
    IconButton sendButton = tester.widget(sendFinder);
    expect(sendButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    sendButton = tester.widget(sendFinder);
    expect(sendButton.onPressed, isNotNull);
  });
}
