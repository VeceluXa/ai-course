import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/adaptive_scaffold.dart';
import '../../../core/config/system_prompt.dart';
import '../state/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _controller = TextEditingController();
  final _promptController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(settingsControllerProvider.select((state) => state.apiKey), (prev, next) {
      if (next != null && _controller.text != next) {
        _controller.text = next;
      }
      if (next == null && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    ref.listen<String?>(
        settingsControllerProvider.select((state) => state.errorMessage), (prev, next) {
      if (next == null || next == prev) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      });
    });

    ref.listen<String?>(
        settingsControllerProvider.select((state) => state.successMessage), (prev, next) {
      if (next == null || next == prev) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      });
    });

    ref.listen(settingsControllerProvider, (prev, next) {
      final hadKey = prev?.hasKey ?? false;
      if (!hadKey && next.hasKey && !next.isValidating) {
        context.go('/chat');
      }
    });

    final state = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final canSave = _controller.text.trim().isNotEmpty;
    final storedPrompt = state.systemPrompt?.trim();
    final isUsingDefaultPrompt = storedPrompt == null || storedPrompt.isEmpty;
    final resolvedPrompt = isUsingDefaultPrompt ? defaultSystemPrompt : storedPrompt;

    final scaffold = AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: state.hasKey,
        leading: state.hasKey
            ? BackButton(onPressed: () => context.go('/chat'))
            : null,
      ),
      body: ListView(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Bring Your Own Key',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your OpenAI API key is stored locally in secure storage and is never logged. '
            'You can remove it at any time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'OpenAI API Key',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _obscure ? 'Show key' : 'Hide key',
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  IconButton(
                    tooltip: 'Paste',
                    icon: const Icon(Icons.paste),
                    onPressed: _pasteFromClipboard,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.isValidating || !canSave
                ? null
                : () => notifier.saveAndValidate(_controller.text.trim()),
            icon: state.isValidating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(state.isValidating ? 'Validating…' : 'Save & Validate'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: state.hasKey ? notifier.deleteKey : null,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove key'),
          ),
          const SizedBox(height: 32),
          Text(
            'System prompt',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how the assistant behaves for every chat.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  resolvedPrompt,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: state.isSavingPrompt
                    ? null
                    : () => _showSystemPromptDialog(
                          context: context,
                          notifier: notifier,
                          initialPrompt: resolvedPrompt,
                          showReset: !isUsingDefaultPrompt,
                        ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
          if (!isUsingDefaultPrompt) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: state.isSavingPrompt ? null : notifier.resetSystemPrompt,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset to default'),
            ),
          ],
        ],
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (state.hasKey) {
            context.go('/chat');
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: scaffold,
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    setState(() {
      _controller.text = text.trim();
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _showSystemPromptDialog({
    required BuildContext context,
    required SettingsController notifier,
    required String initialPrompt,
    required bool showReset,
  }) async {
    _promptController.text = initialPrompt;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit system prompt'),
          content: TextField(
            controller: _promptController,
            maxLines: 10,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Enter a custom system prompt',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            if (showReset)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  notifier.resetSystemPrompt();
                },
                child: const Text('Reset'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                notifier.saveSystemPrompt(_promptController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
