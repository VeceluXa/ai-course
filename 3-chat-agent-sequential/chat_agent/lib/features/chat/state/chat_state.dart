import '../domain/entities/chat_message.dart';
import '../domain/entities/model_info.dart';

class ChatState {
  static const Object _unset = Object();

  final List<ChatMessage> messages;
  final List<ModelInfo> models;
  final List<ModelInfo> recommendedModels;
  final ModelInfo? selectedModel;
  final bool isStreaming;
  final bool isLoadingModels;
  final String? errorMessage;
  final bool usedFallbackModels;

  const ChatState({
    required this.messages,
    required this.models,
    required this.recommendedModels,
    required this.selectedModel,
    required this.isStreaming,
    required this.isLoadingModels,
    required this.errorMessage,
    required this.usedFallbackModels,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      models: [],
      recommendedModels: [],
      selectedModel: null,
      isStreaming: false,
      isLoadingModels: true,
      errorMessage: null,
      usedFallbackModels: false,
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ModelInfo>? models,
    List<ModelInfo>? recommendedModels,
    ModelInfo? selectedModel,
    bool? isStreaming,
    bool? isLoadingModels,
    Object? errorMessage = _unset,
    bool? usedFallbackModels,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      models: models ?? this.models,
      recommendedModels: recommendedModels ?? this.recommendedModels,
      selectedModel: selectedModel ?? this.selectedModel,
      isStreaming: isStreaming ?? this.isStreaming,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      usedFallbackModels: usedFallbackModels ?? this.usedFallbackModels,
    );
  }
}
