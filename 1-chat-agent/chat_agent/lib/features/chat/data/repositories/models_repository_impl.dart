import '../../../../core/error/failure.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/repositories/models_repository.dart';
import '../datasource/openai_api_client.dart';

class ModelsRepositoryImpl implements ModelsRepository {
  ModelsRepositoryImpl(this._client);

  final OpenAiApiClient _client;

  @override
  Future<List<ModelInfo>> loadModels() async {
    try {
      final models = await _client.listModels();
      return models
          .map((model) => ModelInfo(
                id: model.id,
                displayName: _toDisplayName(model.id),
              ))
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure(FailureType.unknown, 'Unable to load models.');
    }
  }

  String _toDisplayName(String id) {
    return id
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
