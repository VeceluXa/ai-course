import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/domain/entities/model_info.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/models_repository.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/load_models.dart';

class FakeModelsRepository implements ModelsRepository {
  FakeModelsRepository({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<List<ModelInfo>> loadModels() async {
    if (shouldFail) {
      throw Exception('failed');
    }
    return const [ModelInfo(id: 'gpt-test', displayName: 'GPT Test')];
  }
}

void main() {
  test('LoadModels returns models when repository succeeds', () async {
    final usecase = LoadModels(FakeModelsRepository());
    final result = await usecase();

    expect(result.isFallback, isFalse);
    expect(result.models.length, 1);
    expect(result.models.first.id, 'gpt-test');
  });

  test('LoadModels returns fallback when repository fails', () async {
    final usecase = LoadModels(FakeModelsRepository(shouldFail: true));
    final result = await usecase();

    expect(result.isFallback, isTrue);
    expect(result.models, isNotEmpty);
  });
}
