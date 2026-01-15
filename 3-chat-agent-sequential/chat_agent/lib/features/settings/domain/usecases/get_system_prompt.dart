import '../repositories/system_prompt_repository.dart';

class GetSystemPrompt {
  GetSystemPrompt(this._repository);

  final SystemPromptRepository _repository;

  Future<String?> call() => _repository.getSystemPrompt();
}
