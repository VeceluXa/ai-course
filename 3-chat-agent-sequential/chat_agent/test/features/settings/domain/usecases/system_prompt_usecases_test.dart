import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/settings/domain/repositories/system_prompt_repository.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/delete_system_prompt.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/get_system_prompt.dart';
import 'package:openai_chat_app/features/settings/domain/usecases/save_system_prompt.dart';

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

void main() {
  test('GetSystemPrompt returns stored prompt', () async {
    final repo = FakeSystemPromptRepository()..stored = 'Custom prompt';
    final usecase = GetSystemPrompt(repo);

    final result = await usecase();

    expect(result, 'Custom prompt');
  });

  test('SaveSystemPrompt stores prompt', () async {
    final repo = FakeSystemPromptRepository();
    final usecase = SaveSystemPrompt(repo);

    await usecase('New prompt');

    expect(repo.stored, 'New prompt');
  });

  test('DeleteSystemPrompt clears stored prompt', () async {
    final repo = FakeSystemPromptRepository()..stored = 'Old prompt';
    final usecase = DeleteSystemPrompt(repo);

    await usecase();

    expect(repo.stored, isNull);
  });
}
