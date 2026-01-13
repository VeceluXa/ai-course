import 'package:dio/dio.dart';

import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<String> streamAssistantResponse({
    required List<ChatMessage> messages,
    required String modelId,
    required CancelToken cancelToken,
  });
}
