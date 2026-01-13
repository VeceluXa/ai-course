import '../entities/model_info.dart';

abstract class ModelsRepository {
  Future<List<ModelInfo>> loadModels();
}
