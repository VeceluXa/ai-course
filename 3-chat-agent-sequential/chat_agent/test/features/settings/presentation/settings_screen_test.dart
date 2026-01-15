import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/domain/entities/model_info.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/models_repository.dart';
import 'package:openai_chat_app/features/settings/domain/repositories/api_key_repository.dart';
import 'package:openai_chat_app/features/settings/domain/repositories/system_prompt_repository.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/delete_api_key.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/delete_system_prompt.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/get_api_key.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/get_system_prompt.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/save_api_key.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/save_system_prompt.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/validate_api_key.dart';
import 'package:openai_chat_app/features/settings/presentation/settings_screen.dart';
import 'package:openai_chat_app/features/settings/state/settings_controller.dart';

class FakeApiKeyRepository implements ApiKeyRepository {
  String? stored;

  @override
  Future<void> deleteApiKey() async {
    stored = null;
  }

  @override
  Future<String?> getApiKey() async => stored;

  @override
  Future<void> saveApiKey(String key) async {
    stored = key;
  }
}

class FakeSystemPromptRepository implements SystemPromptRepository {
  String? stored;

  @override
  Future<void> deleteSystemPrompt() async {
    stored = null;
  }

  @override
  Future<String?> getSystemPrompt() async => stored;

  @override
  Future<void> saveSystemPrompt(String prompt) async {
    stored = prompt;
  }
}

class FakeModelsRepository implements ModelsRepository {
  @override
  Future<List<ModelInfo>> loadModels() async => const [];
}

void main() {
  testWidgets('Settings screen shows system prompt section', (tester) async {
    final apiRepo = FakeApiKeyRepository();
    final promptRepo = FakeSystemPromptRepository();
    final modelsRepo = FakeModelsRepository();
    final controller = SettingsController(
      getApiKey: GetApiKey(apiRepo),
      saveApiKey: SaveApiKey(apiRepo),
      deleteApiKey: DeleteApiKey(apiRepo),
      validateApiKey: ValidateApiKey(modelsRepo),
      getSystemPrompt: GetSystemPrompt(promptRepo),
      saveSystemPrompt: SaveSystemPrompt(promptRepo),
      deleteSystemPrompt: DeleteSystemPrompt(promptRepo),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('System prompt'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });
}
