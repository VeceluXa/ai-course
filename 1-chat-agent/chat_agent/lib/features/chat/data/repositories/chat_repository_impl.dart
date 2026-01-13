import 'package:dio/dio.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/openai_api_client.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final OpenAiApiClient _client;

  @override
  Stream<String> streamAssistantResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) {
    return _client.streamResponse(
      messages: messages,
      modelId: modelId,
      cancelToken: cancelToken,
    );
  }
}
