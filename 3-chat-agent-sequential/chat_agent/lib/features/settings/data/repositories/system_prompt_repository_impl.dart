import '../../../../core/error/failure.dart';
import '../../../../core/platform/prefs_store.dart';
import '../../domain/repositories/system_prompt_repository.dart';

class SystemPromptRepositoryImpl implements SystemPromptRepository {
  SystemPromptRepositoryImpl(this._prefsStore);

  static const String _storageKey = 'system_prompt';

  final PrefsStore _prefsStore;

  @override
  Future<void> deleteSystemPrompt() async {
    try {
      await _prefsStore.remove(_storageKey);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to reset the system prompt.');
    }
  }

  @override
  Future<String?> getSystemPrompt() async {
    try {
      return await _prefsStore.getString(_storageKey);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to load the system prompt.');
    }
  }

  @override
  Future<void> saveSystemPrompt(String prompt) async {
    try {
      await _prefsStore.setString(_storageKey, prompt);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to save the system prompt.');
    }
  }
}
