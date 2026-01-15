import '../../../../core/error/failure.dart';
import '../../../../core/platform/secure_kv_store.dart';
import '../../domain/repositories/api_key_repository.dart';

class ApiKeyRepositoryImpl implements ApiKeyRepository {
  ApiKeyRepositoryImpl(this._secureStore);

  static const String _storageKey = 'openai_api_key';

  final SecureKvStore _secureStore;

  @override
  Future<void> deleteApiKey() async {
    try {
      await _secureStore.delete(_storageKey);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to delete the API key.');
    }
  }

  @override
  Future<String?> getApiKey() async {
    try {
      return await _secureStore.read(_storageKey);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to load the API key.');
    }
  }

  @override
  Future<void> saveApiKey(String key) async {
    try {
      await _secureStore.write(_storageKey, key);
    } catch (error) {
      throw const Failure(FailureType.storage, 'Unable to save the API key.');
    }
  }
}
