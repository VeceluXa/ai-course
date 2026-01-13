import '../../../chat/domain/repositories/models_repository.dart';

class ValidateApiKey {
  ValidateApiKey(this._modelsRepository);

  final ModelsRepository _modelsRepository;

  Future<void> call() async {
    await _modelsRepository.loadModels();
  }
}
