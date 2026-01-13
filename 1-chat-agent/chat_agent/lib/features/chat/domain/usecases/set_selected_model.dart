import '../repositories/selected_model_repository.dart';

class SetSelectedModel {
  SetSelectedModel(this._repository);

  final SelectedModelRepository _repository;

  Future<void> call(String modelId) => _repository.setSelectedModelId(modelId);
}
