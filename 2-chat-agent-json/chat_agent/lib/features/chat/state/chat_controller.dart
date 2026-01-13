import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/logger.dart';
import '../../../core/error/failure.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/model_info.dart';
import '../domain/usecases/get_selected_model.dart';
import '../domain/usecases/load_models.dart';
import '../domain/usecases/send_user_message.dart';
import '../domain/usecases/set_selected_model.dart';
import '../domain/usecases/stream_assistant_response.dart';
import 'chat_state.dart';

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required LoadModels loadModels,
    required GetSelectedModel getSelectedModel,
    required SetSelectedModel setSelectedModel,
    required SendUserMessage sendUserMessage,
    required StreamAssistantResponse streamAssistantResponse,
    required AppLogger logger,
  })  : _loadModels = loadModels,
        _getSelectedModel = getSelectedModel,
        _setSelectedModel = setSelectedModel,
        _sendUserMessage = sendUserMessage,
        _streamAssistantResponse = streamAssistantResponse,
        _logger = logger,
        _uuid = const Uuid(),
        super(ChatState.initial()) {
    _initialize();
  }

  final LoadModels _loadModels;
  final GetSelectedModel _getSelectedModel;
  final SetSelectedModel _setSelectedModel;
  final SendUserMessage _sendUserMessage;
  final StreamAssistantResponse _streamAssistantResponse;
  final AppLogger _logger;
  final Uuid _uuid;

  CancelToken? _cancelToken;

  static const List<String> _recommendedIds = [
    'gpt-4.1-mini',
    'gpt-4o-mini',
    'gpt-4.1',
  ];

  Future<void> _initialize() async {
    final result = await _loadModels();
    final models = result.models;
    final recommended = _resolveRecommended(models);
    String? selectedId;
    try {
      selectedId = await _getSelectedModel();
    } catch (_) {
      selectedId = null;
    }
    final selected = _resolveSelectedModel(models, recommended, selectedId);

    if (selected != null) {
      try {
        await _setSelectedModel(selected.id);
      } catch (_) {}
    }

    state = state.copyWith(
      models: models,
      recommendedModels: recommended,
      selectedModel: selected,
      isLoadingModels: false,
      usedFallbackModels: result.isFallback,
    );
  }

  List<ModelInfo> _resolveRecommended(List<ModelInfo> models) {
    final recommended = models.where((model) => _recommendedIds.contains(model.id)).toList();
    if (recommended.isNotEmpty) return recommended;
    return models.take(3).toList();
  }

  ModelInfo? _resolveSelectedModel(
    List<ModelInfo> models,
    List<ModelInfo> recommended,
    String? selectedId,
  ) {
    if (selectedId != null) {
      final existing = models.where((model) => model.id == selectedId).toList();
      if (existing.isNotEmpty) return existing.first;
    }
    if (recommended.isNotEmpty) return recommended.first;
    if (models.isNotEmpty) return models.first;
    return null;
  }

  Future<void> selectModel(ModelInfo model) async {
    state = state.copyWith(selectedModel: model);
    try {
      await _setSelectedModel(model.id);
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    if (state.isStreaming || text.trim().isEmpty) {
      return;
    }
    final userMessage = _sendUserMessage(text.trim());
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      content: '',
      isStreaming: true,
    );

    final updatedMessages = [...state.messages, userMessage, assistantMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isStreaming: true,
      errorMessage: null,
    );

    await _streamAssistant(assistantMessageId: assistantMessage.id, baseMessages: updatedMessages);
  }

  Future<void> retryAssistant(String assistantMessageId) async {
    if (state.isStreaming) return;
    final messages = [...state.messages];
    final index = messages.indexWhere((message) => message.id == assistantMessageId);
    if (index <= 0) return;
    final userIndex = messages.lastIndexWhere(
      (message) => message.role == ChatRole.user,
      index - 1,
    );
    if (userIndex == -1) return;

    messages.removeAt(index);
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      content: '',
      isStreaming: true,
    );
    messages.insert(index, assistantMessage);

    state = state.copyWith(
      messages: messages,
      isStreaming: true,
      errorMessage: null,
    );

    await _streamAssistant(assistantMessageId: assistantMessage.id, baseMessages: messages);
  }

  Future<void> _streamAssistant({
    required String assistantMessageId,
    required List<ChatMessage> baseMessages,
  }) async {
    final model = state.selectedModel;
    if (model == null) {
      state = state.copyWith(
        isStreaming: false,
        errorMessage: 'Select a model to continue.',
      );
      return;
    }

    final requestMessages = baseMessages
        .where((message) => !message.isError)
        .where((message) => message.content.isNotEmpty)
        .toList();

    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    try {
      await for (final delta in _streamAssistantResponse(
        messages: requestMessages,
        modelId: model.id,
        cancelToken: cancelToken,
      )) {
        _appendDelta(assistantMessageId, delta);
      }
      _finishStreaming(assistantMessageId);
    } on Failure catch (failure) {
      _logger.logWarning('[Chat] streaming failed: ${failure.message}');
      _markError(assistantMessageId, failure.message);
    } catch (error, stackTrace) {
      _logger.logException('[Chat] streaming failed unexpectedly', error, stackTrace);
      _markError(assistantMessageId, 'Unable to generate a response.');
    } finally {
      _cancelToken = null;
    }
  }

  void _appendDelta(String messageId, String delta) {
    final updatedMessages = state.messages.map((message) {
      if (message.id != messageId) return message;
      return message.copyWith(content: message.content + delta);
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  void _finishStreaming(String messageId) {
    for (final message in state.messages) {
      if (message.id == messageId && message.content.isNotEmpty) {
        _logger.logJsonString('[Assistant] JSON response', message.content);
        break;
      }
    }
    final updatedMessages = state.messages.map((message) {
      if (message.id != messageId) return message;
      return message.copyWith(isStreaming: false);
    }).toList();
    state = state.copyWith(messages: updatedMessages, isStreaming: false);
  }

  void _markError(String messageId, String errorMessage) {
    final updatedMessages = state.messages.map((message) {
      if (message.id != messageId) return message;
      return message.copyWith(isStreaming: false, isError: true, errorMessage: errorMessage);
    }).toList();
    state = state.copyWith(messages: updatedMessages, isStreaming: false, errorMessage: errorMessage);
  }

  void stopStreaming() {
    _cancelToken?.cancel('User cancelled');
    _cancelToken = null;
    _logger.logInfo('[Chat] streaming cancelled by user');
    final updatedMessages = state.messages.map((message) {
      if (!message.isStreaming) return message;
      return message.copyWith(isStreaming: false);
    }).toList();
    state = state.copyWith(messages: updatedMessages, isStreaming: false);
  }

  void retryLastFailed() {
    final failed = state.messages.lastWhere(
      (message) => message.isError,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.assistant,
        content: '',
      ),
    );
    if (failed.id.isEmpty) return;
    retryAssistant(failed.id);
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final loadModels = ref.read(loadModelsProvider);
  final getSelectedModel = ref.read(getSelectedModelProvider);
  final setSelectedModel = ref.read(setSelectedModelProvider);
  final sendUserMessage = ref.read(sendUserMessageProvider);
  final streamAssistantResponse = ref.read(streamAssistantResponseProvider);
  final logger = ref.read(loggerProvider);

  return ChatController(
    loadModels: loadModels,
    getSelectedModel: getSelectedModel,
    setSelectedModel: setSelectedModel,
    sendUserMessage: sendUserMessage,
    streamAssistantResponse: streamAssistantResponse,
    logger: logger,
  );
});
