import 'package:dio/dio.dart';

import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class StreamAssistantResponse {
  StreamAssistantResponse(this._repository);

  final ChatRepository _repository;

  Stream<String> call({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  }) {
    return _repository.streamAssistantResponse(
      messages: messages,
      modelId: modelId,
      cancelToken: cancelToken,
    );
  }
}
