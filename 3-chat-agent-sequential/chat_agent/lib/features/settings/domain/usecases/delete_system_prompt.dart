import '../repositories/system_prompt_repository.dart';

class DeleteSystemPrompt {
  DeleteSystemPrompt(this._repository);

  final SystemPromptRepository _repository;

  Future<void> call() => _repository.deleteSystemPrompt();
}
