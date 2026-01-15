import 'package:dio/dio.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/openai_api_client.dart';
import '../datasource/openai_system_prompt.dart';
import '../../../settings/domain/repositories/system_prompt_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client, this._systemPromptRepository);

  final OpenAiApiClient _client;
  final SystemPromptRepository _systemPromptRepository;

  @override
  Stream<String> streamAssistantResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) async* {
    String systemPrompt;
    try {
      final override = await _systemPromptRepository.getSystemPrompt();
      systemPrompt = buildOpenAiSystemPrompt(override: override);
    } catch (_) {
      systemPrompt = buildOpenAiSystemPrompt(override: null);
    }

    final enrichedMessages = [
      ChatMessage(
        id: 'system',
        role: ChatRole.system,
        content: systemPrompt,
      ),
      ...messages,
    ];
    yield* _client.streamResponse(
      messages: enrichedMessages,
      modelId: modelId,
      cancelToken: cancelToken,
    );
  }
}
