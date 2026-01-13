import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.onSuggestionSelected,
  });

  final ValueChanged<String> onSuggestionSelected;

  static const List<String> _suggestions = [
    'Summarize today\'s top tech news.',
    'Draft a friendly email requesting a meeting.',
    'Explain a complex topic in simple terms.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to OpenAI Chat', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Ask a question or start with a suggestion below.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (suggestion) => ActionChip(
                    label: Text(suggestion),
                    onPressed: () => onSuggestionSelected(suggestion),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
