abstract class SystemPromptRepository {
  Future<String?> getSystemPrompt();
  Future<void> saveSystemPrompt(String prompt);
  Future<void> deleteSystemPrompt();
}
