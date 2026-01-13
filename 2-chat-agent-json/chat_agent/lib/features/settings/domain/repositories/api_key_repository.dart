abstract class ApiKeyRepository {
  Future<String?> getApiKey();
  Future<void> saveApiKey(String key);
  Future<void> deleteApiKey();
}
