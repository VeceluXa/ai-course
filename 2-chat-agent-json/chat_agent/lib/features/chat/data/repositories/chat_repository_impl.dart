import 'package:dio/dio.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/openai_api_client.dart';
import '../datasource/openai_system_prompt.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final OpenAiApiClient _client;

  @override
  Stream<String> streamAssistantResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) {
    final enrichedMessages = [
      ChatMessage(
        id: 'system',
        role: ChatRole.system,
        content: buildOpenAiSystemPrompt(modelId: modelId),
      ),
      ...messages,
    ];
    return _client.streamResponse(
      messages: enrichedMessages,
      modelId: modelId,
      cancelToken: cancelToken,
    );
  }
}
