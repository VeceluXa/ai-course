import '../repositories/api_key_repository.dart';

class DeleteApiKey {
  DeleteApiKey(this._repository);

  final ApiKeyRepository _repository;

  Future<void> call() => _repository.deleteApiKey();
}
