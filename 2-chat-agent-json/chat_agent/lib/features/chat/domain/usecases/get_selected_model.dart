import '../repositories/selected_model_repository.dart';

class GetSelectedModel {
  GetSelectedModel(this._repository);

  final SelectedModelRepository _repository;

  Future<String?> call() => _repository.getSelectedModelId();
}
