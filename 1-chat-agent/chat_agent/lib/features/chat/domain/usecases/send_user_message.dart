import 'package:uuid/uuid.dart';

import '../entities/chat_message.dart';

class SendUserMessage {
  SendUserMessage({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  ChatMessage call(String content) {
    return ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: content,
    );
  }
}
