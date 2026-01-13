import 'package:flutter_test/flutter_test.dart';
import 'package:openai_chat_app/features/chat/domain/repositories/selected_model_repository.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/get_selected_model.dart';
import 'package:openai_chat_app/features/chat/domain/usecases/set_selected_model.dart';

class FakeSelectedModelRepository implements SelectedModelRepository {
  String? _selected;

  @override
  Future<void> clearSelectedModelId() async {
    _selected = null;
  }

  @override
  Future<String?> getSelectedModelId() async {
    return _selected;
  }

  @override
  Future<void> setSelectedModelId(String modelId) async {
    _selected = modelId;
  }
}

void main() {
  test('Selected model usecases store and retrieve model id', () async {
    final repository = FakeSelectedModelRepository();
    final setSelectedModel = SetSelectedModel(repository);
    final getSelectedModel = GetSelectedModel(repository);

    await setSelectedModel('gpt-4.1-mini');
    final selected = await getSelectedModel();

    expect(selected, 'gpt-4.1-mini');
  });
}
