import '../repositories/api_key_repository.dart';

class SaveApiKey {
  SaveApiKey(this._repository);

  final ApiKeyRepository _repository;

  Future<void> call(String key) => _repository.saveApiKey(key);
}
