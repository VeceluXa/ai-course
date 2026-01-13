import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/di/providers.dart';
import '../domain/usecases/delete_api_key.dart';
import '../domain/usecases/get_api_key.dart';
import '../domain/usecases/save_api_key.dart';
import '../domain/usecases/validate_api_key.dart';
import 'settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({
    required GetApiKey getApiKey,
    required SaveApiKey saveApiKey,
    required DeleteApiKey deleteApiKey,
    required ValidateApiKey validateApiKey,
  })  : _getApiKey = getApiKey,
        _saveApiKey = saveApiKey,
        _deleteApiKey = deleteApiKey,
        _validateApiKey = validateApiKey,
        super(SettingsState.initial()) {
    _load();
  }

  final GetApiKey _getApiKey;
  final SaveApiKey _saveApiKey;
  final DeleteApiKey _deleteApiKey;
  final ValidateApiKey _validateApiKey;

  Future<void> _load() async {
    try {
      final key = await _getApiKey();
      state = state.copyWith(isLoading: false, apiKey: key);
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
    }
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
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final getApiKey = ref.read(getApiKeyProvider);
  final saveApiKey = ref.read(saveApiKeyProvider);
  final deleteApiKey = ref.read(deleteApiKeyProvider);
  final validateApiKey = ref.read(validateApiKeyProvider);

  return SettingsController(
    getApiKey: getApiKey,
    saveApiKey: saveApiKey,
    deleteApiKey: deleteApiKey,
    validateApiKey: validateApiKey,
  );
});
