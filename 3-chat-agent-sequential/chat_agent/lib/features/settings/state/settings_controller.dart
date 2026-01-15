import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/di/providers.dart';
import '../domain/usecases/delete_api_key.dart';
import '../domain/usecases/delete_system_prompt.dart';
import '../domain/usecases/get_api_key.dart';
import '../domain/usecases/get_system_prompt.dart';
import '../domain/usecases/save_api_key.dart';
import '../domain/usecases/save_system_prompt.dart';
import '../domain/usecases/validate_api_key.dart';
import 'settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({
    required GetApiKey getApiKey,
    required SaveApiKey saveApiKey,
    required DeleteApiKey deleteApiKey,
    required ValidateApiKey validateApiKey,
    required GetSystemPrompt getSystemPrompt,
    required SaveSystemPrompt saveSystemPrompt,
    required DeleteSystemPrompt deleteSystemPrompt,
  })  : _getApiKey = getApiKey,
        _saveApiKey = saveApiKey,
        _deleteApiKey = deleteApiKey,
        _validateApiKey = validateApiKey,
        _getSystemPrompt = getSystemPrompt,
        _saveSystemPrompt = saveSystemPrompt,
        _deleteSystemPrompt = deleteSystemPrompt,
        super(SettingsState.initial()) {
    _load();
  }

  final GetApiKey _getApiKey;
  final SaveApiKey _saveApiKey;
  final DeleteApiKey _deleteApiKey;
  final ValidateApiKey _validateApiKey;
  final GetSystemPrompt _getSystemPrompt;
  final SaveSystemPrompt _saveSystemPrompt;
  final DeleteSystemPrompt _deleteSystemPrompt;

  Future<void> _load() async {
    String? apiKey;
    String? systemPrompt;
    String? errorMessage;

    try {
      apiKey = await _getApiKey();
    } on Failure catch (failure) {
      errorMessage = failure.message;
    }

    try {
      systemPrompt = await _getSystemPrompt();
    } on Failure catch (failure) {
      errorMessage ??= failure.message;
    }

    state = state.copyWith(
      isLoading: false,
      apiKey: apiKey,
      systemPrompt: systemPrompt,
      errorMessage: errorMessage,
    );
  }

  Future<void> saveAndValidate(String key) async {
    state = state.copyWith(
      isValidating: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await _saveApiKey(key);
      await _validateApiKey();
      state = state.copyWith(
        isValidating: false,
        apiKey: key,
        successMessage: 'API key saved and validated.',
      );
    } on Failure catch (failure) {
      try {
        await _deleteApiKey();
      } catch (_) {}
      state = state.copyWith(
        isValidating: false,
        apiKey: null,
        errorMessage: failure.message,
      );
    } catch (error) {
      try {
        await _deleteApiKey();
      } catch (_) {}
      state = state.copyWith(
        isValidating: false,
        apiKey: null,
        errorMessage: 'Unable to validate the API key.',
      );
    }
  }

  Future<void> deleteKey() async {
    state = state.copyWith(errorMessage: null, successMessage: null);
    try {
      await _deleteApiKey();
      state = state.copyWith(
        apiKey: null,
        successMessage: 'API key removed.',
      );
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.message);
    }
  }

  Future<void> saveSystemPrompt(String prompt) async {
    final trimmed = prompt.trim();
    state = state.copyWith(
      isSavingPrompt: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      if (trimmed.isEmpty) {
        await _deleteSystemPrompt();
        state = state.copyWith(
          isSavingPrompt: false,
          systemPrompt: null,
          successMessage: 'System prompt reset to default.',
        );
        return;
      }
      await _saveSystemPrompt(trimmed);
      state = state.copyWith(
        isSavingPrompt: false,
        systemPrompt: trimmed,
        successMessage: 'System prompt updated.',
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isSavingPrompt: false,
        errorMessage: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSavingPrompt: false,
        errorMessage: 'Unable to update the system prompt.',
      );
    }
  }

  Future<void> resetSystemPrompt() async {
    state = state.copyWith(
      isSavingPrompt: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await _deleteSystemPrompt();
      state = state.copyWith(
        isSavingPrompt: false,
        systemPrompt: null,
        successMessage: 'System prompt reset to default.',
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isSavingPrompt: false,
        errorMessage: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSavingPrompt: false,
        errorMessage: 'Unable to reset the system prompt.',
      );
    }
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final getApiKey = ref.read(getApiKeyProvider);
  final saveApiKey = ref.read(saveApiKeyProvider);
  final deleteApiKey = ref.read(deleteApiKeyProvider);
  final validateApiKey = ref.read(validateApiKeyProvider);
  final getSystemPrompt = ref.read(getSystemPromptProvider);
  final saveSystemPrompt = ref.read(saveSystemPromptProvider);
  final deleteSystemPrompt = ref.read(deleteSystemPromptProvider);

  return SettingsController(
    getApiKey: getApiKey,
    saveApiKey: saveApiKey,
    deleteApiKey: deleteApiKey,
    validateApiKey: validateApiKey,
    getSystemPrompt: getSystemPrompt,
    saveSystemPrompt: saveSystemPrompt,
    deleteSystemPrompt: deleteSystemPrompt,
  );
});
