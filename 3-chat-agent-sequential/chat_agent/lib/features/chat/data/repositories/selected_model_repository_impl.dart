import '../../../../core/error/failure.dart';
import '../../../../core/platform/prefs_store.dart';
import '../../domain/repositories/selected_model_repository.dart';

class SelectedModelRepositoryImpl implements SelectedModelRepository {
  SelectedModelRepositoryImpl(this._prefsStore);

  static const String _storageKey = 'selected_model_id';

  final PrefsStore _prefsStore;

  @override
  Future<void> clearSelectedModelId() async {
    try {
      await _prefsStore.remove(_storageKey);
    } catch (_) {
      throw const Failure(FailureType.storage, 'Unable to clear model preference.');
    }
  }

  @override
  Future<String?> getSelectedModelId() async {
    try {
      return await _prefsStore.getString(_storageKey);
    } catch (_) {
      throw const Failure(FailureType.storage, 'Unable to load model preference.');
    }
  }

  @override
  Future<void> setSelectedModelId(String modelId) async {
    try {
      await _prefsStore.setString(_storageKey, modelId);
    } catch (_) {
      throw const Failure(FailureType.storage, 'Unable to save model preference.');
    }
  }
}
