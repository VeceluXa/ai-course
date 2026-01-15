import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/adaptive_scaffold.dart';
import '../../../app/theme/breakpoints.dart';
import '../state/chat_controller.dart';
import 'widgets/composer.dart';
import 'widgets/empty_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/model_picker_sheet.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(chatControllerProvider.select((state) => state.errorMessage),
        (prev, next) {
      if (next == null || next == prev) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      });
    });

    ref.listen<int>(chatControllerProvider.select((state) => state.messages.length),
        (prev, next) {
      if (next == 0 || prev == next) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });

    ref.listen<String?>(
        chatControllerProvider.select((state) {
          if (state.messages.isEmpty) return null;
          return state.messages.last.content;
        }), (prev, next) {
      if (next == null || next == prev) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });

    final state = ref.watch(chatControllerProvider);
    final notifier = ref.read(chatControllerProvider.notifier);

    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(state.selectedModel?.displayName ?? 'Select model'),
              onPressed: () => _showModelPicker(context),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isLoadingModels) const LinearProgressIndicator(),
          if (_shouldShowBanner(state.errorMessage))
            MaterialBanner(
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: notifier.retryLastFailed,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: state.messages.isEmpty
                ? EmptyState(
                    onSuggestionSelected: (suggestion) {
                      _composerController.text = suggestion;
                      _composerController.selection = TextSelection.fromPosition(
                        TextPosition(offset: suggestion.length),
                      );
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return MessageBubble(
                        message: message,
                        modelLabel: state.selectedModel?.displayName,
                        onRetry: message.isError
                            ? () => notifier.retryAssistant(message.id)
                            : null,
                      );
                    },
                  ),
          ),
          if (state.isStreaming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const TypingIndicator(),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant is typing…',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _composerController,
            builder: (context, value, child) {
              return Composer(
                controller: _composerController,
                isStreaming: state.isStreaming,
                onSend: () {
                  final text = _composerController.text;
                  _composerController.clear();
                  notifier.sendMessage(text);
                },
                onStop: notifier.stopStreaming,
              );
            },
          ),
        ],
      ),
    );
  }

  bool _shouldShowBanner(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('no internet') || lower.contains('timed out');
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    const threshold = 48.0;
    final isAtBottom = position.maxScrollExtent - position.pixels <= threshold;
    _shouldAutoScroll = isAtBottom;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients || !_shouldAutoScroll) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showModelPicker(BuildContext context) async {
    final state = ref.read(chatControllerProvider);
    final notifier = ref.read(chatControllerProvider.notifier);
    final width = MediaQuery.of(context).size.width;

    final sheet = ModelPickerSheet(
      models: state.models,
      recommendedModels: state.recommendedModels,
      selectedModelId: state.selectedModel?.id,
      onSelected: notifier.selectModel,
    );

    if (width < Breakpoints.medium) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => sheet,
      );
    } else {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: sheet,
          ),
        ),
      );
    }
  }
}
