import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/data/datasource/openai_api_client.dart';
import '../../features/chat/data/datasource/openai_sse_parser.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/data/repositories/models_repository_impl.dart';
import '../../features/chat/data/repositories/selected_model_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/repositories/models_repository.dart';
import '../../features/chat/domain/repositories/selected_model_repository.dart';
import '../../features/chat/domain/usecases/get_selected_model.dart';
import '../../features/chat/domain/usecases/load_models.dart';
import '../../features/chat/domain/usecases/send_user_message.dart';
import '../../features/chat/domain/usecases/set_selected_model.dart';
import '../../features/chat/domain/usecases/stream_assistant_response.dart';
import '../../features/settings/data/datasource/secure_storage_datasource.dart';
import '../../features/settings/data/repositories/api_key_repository_impl.dart';
import '../../features/settings/domain/repositories/api_key_repository.dart';
import '../../features/settings/domain/usecases/delete_api_key.dart';
import '../../features/settings/domain/usecases/get_api_key.dart';
import '../../features/settings/domain/usecases/save_api_key.dart';
import '../../features/settings/domain/usecases/validate_api_key.dart';
import '../platform/prefs_store.dart';
import '../platform/secure_kv_store.dart';
import '../utils/logger.dart';

final loggerProvider = Provider<AppLogger>((ref) => const AppLogger());

final secureKvStoreProvider = Provider<SecureKvStore>((ref) {
  return SecureStorageDataSource();
});

final prefsStoreProvider = Provider<PrefsStore>((ref) {
  return SharedPrefsStore();
});

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  return ApiKeyRepositoryImpl(ref.read(secureKvStoreProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  final apiKeyRepository = ref.read(apiKeyRepositoryProvider);
  dio.interceptors.add(AuthInterceptor(apiKeyRepository.getApiKey));
  dio.interceptors.add(LoggingInterceptor(ref.read(loggerProvider)));
  return dio;
});

final openAiSseParserProvider = Provider<OpenAiSseParser>((ref) {
  return OpenAiSseParser(logger: ref.read(loggerProvider));
});

final openAiApiClientProvider = Provider<OpenAiApiClient>((ref) {
  return OpenAiApiClient(
    dio: ref.read(dioProvider),
    sseParser: ref.read(openAiSseParserProvider),
    logger: ref.read(loggerProvider),
  );
});

final modelsRepositoryProvider = Provider<ModelsRepository>((ref) {
  return ModelsRepositoryImpl(ref.read(openAiApiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(openAiApiClientProvider));
});

final selectedModelRepositoryProvider = Provider<SelectedModelRepository>((ref) {
  return SelectedModelRepositoryImpl(ref.read(prefsStoreProvider));
});

final loadModelsProvider = Provider<LoadModels>((ref) {
  return LoadModels(ref.read(modelsRepositoryProvider));
});

final getSelectedModelProvider = Provider<GetSelectedModel>((ref) {
  return GetSelectedModel(ref.read(selectedModelRepositoryProvider));
});

final setSelectedModelProvider = Provider<SetSelectedModel>((ref) {
  return SetSelectedModel(ref.read(selectedModelRepositoryProvider));
});

final sendUserMessageProvider = Provider<SendUserMessage>((ref) {
  return SendUserMessage();
});

final streamAssistantResponseProvider = Provider<StreamAssistantResponse>((ref) {
  return StreamAssistantResponse(ref.read(chatRepositoryProvider));
});

final getApiKeyProvider = Provider<GetApiKey>((ref) {
  return GetApiKey(ref.read(apiKeyRepositoryProvider));
});

final saveApiKeyProvider = Provider<SaveApiKey>((ref) {
  return SaveApiKey(ref.read(apiKeyRepositoryProvider));
});

final deleteApiKeyProvider = Provider<DeleteApiKey>((ref) {
  return DeleteApiKey(ref.read(apiKeyRepositoryProvider));
});

final validateApiKeyProvider = Provider<ValidateApiKey>((ref) {
  return ValidateApiKey(ref.read(modelsRepositoryProvider));
});
