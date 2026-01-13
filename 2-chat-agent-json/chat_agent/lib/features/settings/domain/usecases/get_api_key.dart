import '../repositories/api_key_repository.dart';

class GetApiKey {
  GetApiKey(this._repository);

  final ApiKeyRepository _repository;

  Future<String?> call() => _repository.getApiKey();
}
