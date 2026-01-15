import '../repositories/system_prompt_repository.dart';

class SaveSystemPrompt {
  SaveSystemPrompt(this._repository);

  final SystemPromptRepository _repository;

  Future<void> call(String prompt) => _repository.saveSystemPrompt(prompt);
}
