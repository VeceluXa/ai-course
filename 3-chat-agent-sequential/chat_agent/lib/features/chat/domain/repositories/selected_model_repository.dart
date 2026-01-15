abstract class SelectedModelRepository {
  Future<String?> getSelectedModelId();
  Future<void> setSelectedModelId(String modelId);
  Future<void> clearSelectedModelId();
}
