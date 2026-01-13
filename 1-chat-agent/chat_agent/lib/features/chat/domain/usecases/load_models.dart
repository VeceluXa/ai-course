import '../../domain/entities/model_info.dart';
import '../repositories/models_repository.dart';

class LoadModelsResult {
  const LoadModelsResult({required this.models, required this.isFallback});

  final List<ModelInfo> models;
  final bool isFallback;
}

class LoadModels {
  LoadModels(this._repository);

  final ModelsRepository _repository;

  static const List<ModelInfo> fallbackModels = [
    ModelInfo(id: 'gpt-4.1-mini', displayName: 'GPT-4.1 Mini'),
    ModelInfo(id: 'gpt-4o-mini', displayName: 'GPT-4o Mini'),
    ModelInfo(id: 'gpt-4.1', displayName: 'GPT-4.1'),
  ];

  Future<LoadModelsResult> call() async {
    try {
      final models = await _repository.loadModels();
      return LoadModelsResult(models: models, isFallback: false);
    } catch (_) {
      return const LoadModelsResult(models: fallbackModels, isFallback: true);
    }
  }
}
